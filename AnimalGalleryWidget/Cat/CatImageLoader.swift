//
//  CatImageLoader.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/08.
//

import SwiftUI

struct CatImageLoader {
    private let breedListLoader: CatBreedListLoader
    private let imageListLoader: CatImageListLoader
    private let imageDataLoader: ImageDataWebLoader

    init(breedListLoader: CatBreedListLoader,
         imageListLoader: CatImageListLoader,
         imageDataLoader: ImageDataWebLoader) {
        self.breedListLoader = breedListLoader
        self.imageListLoader = imageListLoader
        self.imageDataLoader = imageDataLoader
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

        _ = imageDataLoader.load(from: url) { result in
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
