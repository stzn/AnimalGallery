//
//  CatImageLoader.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/08.
//

import SwiftUI

struct CatImageLoader: ImageLoadable {
    private let client = URLSessionHTTPClient(session: .shared)
    private let webAPI: CatWebAPI
    private let imageWebLoader: ImageDataWebLoader

    init() {
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
            switch result {
            case .success(let breeds):
                loadCatImagesInBreeds(for: breeds, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
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
                    switch result {
                    case .success(let images):
                        guard let url = images.map(\.imageURL).first else {
                            group.leave()
                            return
                        }
                        self.loadCatImage(from: url, for: breed) { result in
                            switch result {
                            case .success(let image):
                                widgetImages.append(image)
                            case .failure(let error):
                                completion(.failure(error))
                            }
                            group.leave()
                        }
                    case .failure(let error):
                        completion(.failure(error))
                        group.leave()
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
            switch result {
            case .success(let images):
                self.loadCatImages(from: images.map(\.imageURL),
                                   for: Breed(id: breed, name: breed),
                                   completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
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
                    switch result {
                    case .success(let image):
                        widgetImages.append(image)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                    group.leave()
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

        _ = imageWebLoader.load(from: url) { result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    return
                }
                completion(
                    .success(
                        WidgetImage(id: url.absoluteString, name: breed.name,
                                    image: Image(uiImage: image), widgetURLKey: breed.id)
                    )
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension CatWebAPI {
    func load(of breed: BreedType? = nil, limit: Int = 100, completion: @escaping (Result<[AnimalImage], Error>) -> Void) {
        var queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        if let breed = breed {
            queryItems.append(URLQueryItem(name: "breed_id", value: breed))
        }
        guard let request = makeURLRequest(
                from: catAPIbaseURL.appendingPathComponent("/images/search"),
                queryItems: queryItems) else {
            assertionFailure("should not be nil")
            return
        }

        call(Root.self, request) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let model):
                let breeds = self.convert(from: model)
                completion(.success(breeds))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loadRandomBreeds(limit: Int, completion: @escaping (Result<[Breed], Error>) -> Void) {
        let url = catAPIbaseURL.appendingPathComponent("breeds")
        guard let request = makeURLRequest(
                from: url,
                queryItems: [URLQueryItem(name: "limit", value: "\(limit)")]) else {
            assertionFailure("should not be nil")
            return
        }
        call([BreedListAPIModel].self, request) { result in
            switch result {
            case .success(let models):
                let breeds = models.map { Breed(id: $0.id, name: $0.name) }
                completion(.success(breeds))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loadBreedByName(_ name: String, completion: @escaping (Result<Breed, Error>) -> Void) {
        let url = catAPIbaseURL.appendingPathComponent("breeds/search")
        guard let request = makeURLRequest(
                from: url,
                queryItems: [URLQueryItem(name: "q", value: name)]) else {
            assertionFailure("should not be nil")
            return
        }
        call([BreedListAPIModel].self, request) { result in
            switch result {
            case .success(let models):
                guard let breed = models.map({ Breed(id: $0.id, name: $0.name) }).first else {
                    assertionFailure("should not be nil")
                    return
                }
                completion(.success(breed))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
