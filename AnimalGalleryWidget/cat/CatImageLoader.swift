//
//  CatImageLoader.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/08.
//

import SwiftUI

struct CatImageLoader: ImageLoadable {
    private let webAPI: CatWebAPI
    private let imageWebLoader: ImageDataWebLoader

    init(client: HTTPClient) {
        webAPI = CatWebAPI(client: client)
        imageWebLoader = ImageDataWebLoader(client: client)
    }

    func loadImage(for identifier: String,
                   entryDate: Date,
                   refreshDate: Date,
                   completion: @escaping (ImageEntry) -> Void) {
        if identifier == "random" {
            loadRandom { result in
                let entry = makeEntry(from: result, entryDate: entryDate, refreshDate: refreshDate)
                completion(entry)
            }
        } else {
            loadRandomInBreed(identifier) { result in
                let entry = makeEntry(from: result, entryDate: entryDate, refreshDate: refreshDate)
                completion(entry)
            }
        }
    }

    func loadRandom(completion: @escaping (Result<[WidgetImage], Error>) -> Void) {
        webAPI.loadRandomBreeds(limit: 3) { result in
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            guard let breeds = try? result.get() else {
                return
            }
            loadCatImagesInBreeds(for: breeds, completion: completion)
        }
    }

    private func loadCatImagesInBreeds(
        for breeds: [Breed],
        completion: @escaping (Result<[WidgetImage], Error>) -> Void) {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "CatImageLoaderQueueInRandom")
        var widgetImages: [WidgetImage] = []
        breeds.forEach { breed in
            queue.async(group: group) {
                group.enter()
                webAPI.load(of: breed.id, limit: 1) { result in
                    if case .failure(let error) = result {
                        completion(.failure(error))
                        group.leave()
                        return
                    }
                    guard let images = try? result.get(),
                          let url = images.map(\.imageURL).first else {
                        group.leave()
                        return
                    }
                    self.loadCatImage(from: url, for: breed) { result in
                        defer { group.leave() }
                        guard let image = try? result.get() else {
                            return
                        }
                        widgetImages.append(image)
                    }
                }
            }
        }

        group.notify(queue: queue) {
            completion(.success(widgetImages))
        }
    }

    func loadRandomInBreed(_ breed: BreedType,
                           completion: @escaping (Result<[WidgetImage], Error>) -> Void) {
        webAPI.load(of: breed, limit: 3) { result in
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            guard let images = try? result.get() else {
                return
            }
            self.loadCatImages(from: images.map(\.imageURL),
                               for: Breed(id: breed, name: breed),
                               completion: completion)
        }
    }

    private func loadCatImages(from urls: [URL],
                               for breed: Breed,
                               completion: @escaping (Result<[WidgetImage], Error>) -> Void) {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "CatImageLoaderQueue")
        var widgetImages: [WidgetImage] = []
        urls.forEach { url in
            queue.async(group: group) {
                group.enter()
                self.loadCatImage(from: url, for: breed) { result in
                    defer { group.leave() }
                    guard let image = try? result.get() else {
                        return
                    }
                    widgetImages.append(image)
                }
            }
        }

        group.notify(queue: queue) {
            completion(.success(widgetImages))
        }
    }

    private func loadCatImage(from url: URL,
                              for breed: Breed,
                              completion: @escaping (Result<WidgetImage, Error>) -> Void) {
        enum Error: Swift.Error {
            case failToCreateImage
        }

        _ = imageWebLoader.load(from: url) { result in
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            guard let data = try? result.get(),
                  let image = UIImage(data: data) else {
                return
            }
            completion(.success(
                WidgetImage(id: url.absoluteString, name: breed.name,
                            image: Image(uiImage: image), widgetURLKey: breed.id))
            )
        }
    }
}

extension CatWebAPI {
    func load(of breed: BreedType? = nil, limit: Int = 100, completion: @escaping (Result<[AnimalImage], Error>) -> Void) {
        var queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        if let breed = breed {
            queryItems.append(URLQueryItem(name: "breed_id", value: breed))
        }
        let request = CatAPIURLRequestFactory.makeURLRequest(
                from: catAPIbaseURL.appendingPathComponent("/images/search"),
                queryItems: queryItems)

        call(Root.self, request) { [weak self] result in
            guard let self = self else {
                assertionFailure("should not be nil")
                return
            }
            completion(result.map(self.convert(from:)))
        }
    }

    func loadRandomBreeds(limit: Int, completion: @escaping (Result<[Breed], Error>) -> Void) {
        let request = CatAPIURLRequestFactory.makeURLRequest(
                from: catBreedListAPIbaseURL, queryItems: [URLQueryItem(name: "limit", value: "\(limit)")])
        RemoteListLoader(request: request, client: client, mapper: CatListMapper.map)
            .load {
                completion(
                    $0.map { models in models.map { Breed(id: $0.id, name: $0.name) } }
                )
            }
    }

    func loadBreedByName(_ name: String, completion: @escaping (Result<Breed, Error>) -> Void) {
        enum Error: Swift.Error {
            case failToCreateBreed
        }

        let url = catAPIbaseURL.appendingPathComponent("breeds/search")
        let request = CatAPIURLRequestFactory.makeURLRequest(
                from: url, queryItems: [URLQueryItem(name: "q", value: name)])
        RemoteListLoader(request: request, client: client, mapper: CatListMapper.map)
            .load { result in
                completion(
                    Result {
                        guard let breed = try? result.get().first else {
                            throw Error.failToCreateBreed
                        }
                        return breed
                    }
                )
            }
    }
}
