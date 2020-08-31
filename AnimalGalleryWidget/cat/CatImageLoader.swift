//
//  CatImageLoader.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/08.
//

import SwiftUI

struct CatImageLoader: ImageLoadable {
    private let breedListLoader: CatBreedListLoader
    private let imageListLoader: CatImageListLoader
    private let imageWebLoader: ImageDataWebLoader

    init(breedListLoader: CatBreedListLoader,
         imageListLoader: CatImageListLoader,
         imageWebLoader: ImageDataWebLoader) {
        self.breedListLoader = breedListLoader
        self.imageListLoader = imageListLoader
        self.imageWebLoader = imageWebLoader
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
        breedListLoader.loadRandomBreeds(limit: 3) { result in
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
                imageListLoader.load(of: breed.id, limit: 1) { result in
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
        imageListLoader.load(of: breed, limit: 3) { result in
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

extension CatBreedListLoader {
    func loadRandomBreeds(limit: Int, completion: @escaping (Result<[Breed], Error>) -> Void) {
        load(requestBuilder: { url in
            CatAPIURLRequestFactory.makeURLRequest(
                    from: url, queryItems: [URLQueryItem(name: "limit", value: "\(limit)")])
        }) {
                completion(
                    $0.map { models in models.map { Breed(id: $0.id, name: $0.name) } }
                )
            }
    }

    enum LoaderError: Swift.Error {
        case failToCreateBreed
    }

    func loadBreedByName(_ name: String, completion: @escaping (Result<Breed, Error>) -> Void) {
        load(requestBuilder: { url in
            CatAPIURLRequestFactory.makeURLRequest(
                    from: url.appendingPathComponent("breeds/search"),
                queryItems: [URLQueryItem(name: "q", value: name)])
        }) { result in
            completion(Result {
                guard let breed = try? result.get().first else {
                    throw LoaderError.failToCreateBreed
                }
                return breed
            })
        }
    }

}

typealias CatImageListLoader = RemoteImageListLoader<[AnimalImage], CatImageListMapper.APIModel>

extension CatImageListLoader {
    convenience init(client: HTTPClient, limit: Int = 100) {
        self.init(
            client: client,
            requestBuilder: { breedType in
                var queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
                if let breed = breedType {
                    queryItems.append(URLQueryItem(name: "breed_id", value: breed))
                }
                return CatAPIURLRequestFactory.makeURLRequest(
                        from: catAPIbaseURL.appendingPathComponent("/images/search"),
                        queryItems: queryItems)
            },
            mapper: CatImageListMapper.map)
    }

    func load(of breed: BreedType? = nil, limit: Int = 100, completion: @escaping (Result<[AnimalImage], Error>) -> Void) {
        guard let url = requestBuilder(breed).url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              var queryItems = components.queryItems else {
            return
        }
        queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        components.queryItems = queryItems

        guard let componentsUrl = components.url else {
            return
        }

        call(URLRequest(url: componentsUrl)) { [weak self] result in
            guard let self = self else {
                return
            }
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            guard let apiModel = try? result.get() else {
                return
            }
            completion(self.mapper(apiModel))
        }
    }
}
