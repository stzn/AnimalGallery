//
//  DogImageLoader.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/07/04.
//

import SwiftUI

struct DogImageLoader: ImageLoadable {
    private let webAPI: DogWebAPI
    private let imageWebLoader: ImageDataWebLoader

    init(client: HTTPClient) {
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

    func loadRandom(completion: @escaping (Result<[WidgetImage], Error>) -> Void) {
        webAPI.loadRandom(count: 3) { result in
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            guard let urls = try? result.get() else {
                return
            }
            loadDogImages(for: urls, completion: completion)
        }
    }

    func loadRandomInBreed(_ breedName: BreedType,
                           completion: @escaping (Result<[WidgetImage], Error>) -> Void) {
        webAPI.load(of: breedName) { result in
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            guard let images = try? result.get() else {
                return
            }
            let urls = images.prefix(3).map(\.imageURL)
            loadDogImages(for: urls, completion: completion)
        }
    }

    private func loadDogImages(for urls: [URL], completion: @escaping (Result<[WidgetImage], Error>) -> Void) {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "DogImageLoaderQueue")
        var widgetImages: [WidgetImage] = []
        urls.forEach { url in
            queue.async(group: group) {
                group.enter()
                self.loadDogImage(from: url) { result in
                    defer { group.leave() }
                    if case .failure(let error) = result {
                        completion(.failure(error))
                        return
                    }
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

    private func loadDogImage(from url: URL,
                              completion: @escaping (Result<WidgetImage, Error>) -> Void) {
        _ = imageWebLoader.load(from: url) { result in
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            guard let data = try? result.get(),
                  let image = UIImage(data: data) else {
                return
            }
            let breed = extractBreed(from: url)
            completion(.success(
                        WidgetImage(id: url.absoluteString, name: breed,
                                    image: Image(uiImage: image), widgetURLKey: breed)
            ))
        }
    }

    private func extractBreed(from url: URL) -> String {
        url.deletingLastPathComponent().lastPathComponent.firstLetterCapitalized
    }
}

extension DogWebAPI {
    struct WidgetDogImageModel: Decodable {
        let message: [String]
        let status: String
    }

    func loadRandom(
        count: Int,
        completion: @escaping (Result<[URL], Error>) -> Void) {
        call(WidgetDogImageModel.self,
             URLRequest(url: baseURL.appendingPathComponent("breeds/image/random/\(count)"))) { result in
            completion(
                result.map { model in
                    model.message.compactMap(URL.init(string:))
                }
            )
        }
    }
}
