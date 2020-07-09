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
            loadRandom(for: identifier) { result in
                switch result {
                case .success(let image):
                    completion(.init(date: entryDate, nextDate: refreshDate, image: image))
                case .failure:
                    completion(
                        ImageEntry(date: entryDate, nextDate: refreshDate, image: errorImage)
                    )
                }
            }
        } else {
            loadRandomInBreed(identifier) { result in
                switch result {
                case .success(let image):
                    completion(.init(date: entryDate, nextDate: refreshDate, image: image))
                case .failure:
                    completion(
                        ImageEntry(date: entryDate, nextDate: refreshDate, image: errorImage)
                    )
                }
            }
        }
    }

    func loadRandom(for identifier: String,
                    completion: @escaping (Result<WidgetImage, Error>) -> Void) {
        webAPI.load(limit: 1) { result in
            switch result {
            case .success(let images):
                loadCatImage(from: images[0].imageURL, for: identifier, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loadRandomInBreed(_ breed: BreedType,
                           completion: @escaping (Result<WidgetImage, Error>) -> Void) {
        webAPI.load(of: breed, limit: 1) { result in
            switch result {
            case .success(let images):
                loadCatImage(from: images[0].imageURL, for: breed, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func loadCatImage(from url: URL,
                              for breed: String,
                              completion: @escaping (Result<WidgetImage, Error>) -> Void) {

        _ = imageWebLoader.load(from: url) { result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    return
                }
                completion(.success(WidgetImage(name: breed, image: Image(uiImage: image))))
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
        guard let request = createURLRequest(
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
}
