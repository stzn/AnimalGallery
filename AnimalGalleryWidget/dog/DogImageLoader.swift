//
//  DogImageLoader.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/07/04.
//

import SwiftUI

struct DogImageLoader: ImageLoadable {
    private let client = URLSessionHTTPClient(session: .shared)
    private let webAPI: DogWebAPI
    private let imageWebLoader: ImageDataWebLoader

    init() {
        webAPI = DogWebAPI(client: client)
        imageWebLoader = ImageDataWebLoader(client: client)
    }

    func loadImage(for identifier: String, entryDate: Date, refreshDate: Date, completion: @escaping (ImageEntry) -> Void) {
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

    func loadRandom(completion: @escaping (Result<WidgetImage, Error>) -> Void) {
        webAPI.loadRandom { result in
            switch result {
            case .success(let url):
                loadDogImage(from: url, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loadRandomInBreed(_ breedName: BreedType,
                                  completion: @escaping (Result<WidgetImage, Error>) -> Void) {
        webAPI.load(of: breedName) { result in
            switch result {
            case .success(let images):
                loadDogImage(from: images[0].imageURL, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func loadDogImage(from url: URL,
                              completion: @escaping (Result<WidgetImage, Error>) -> Void) {
        _ = imageWebLoader.load(from: url) { result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    return
                }
                let breed = extractBreed(from: url)
                completion(.success(WidgetImage(name: breed, image: Image(uiImage: image))))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func extractBreed(from url: URL) -> String {
        url.deletingLastPathComponent().lastPathComponent.firstLetterCapitalized
    }
}

extension DogWebAPI {
    struct WidgetDogImageModel: Decodable {
        let message: String
        let status: String
    }

    func loadRandom(completion: @escaping (Result<URL, Error>) -> Void) {
        call(WidgetDogImageModel.self,
             URLRequest(url: baseURL.appendingPathComponent("breeds/image/random"))) { result in
            switch result {
            case .success(let model):
                guard let url = URL(string: model.message) else {
                    return
                }
                completion(.success(url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
