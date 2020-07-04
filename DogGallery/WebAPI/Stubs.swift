//
//  Stubs.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/07/04.
//

import Combine
import Foundation
import UIKit

private let stubImage = UIImage(systemName: "tray")!.pngData()!

struct StubImageDataLoader: ImageDataLoader {
    private let data: Data
    init(data: Data = stubImage) {
        self.data = data
    }
    func load(from url: URL) -> AnyPublisher<Data, Error> {
        Just(data)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

struct StubBreedListLoader: BreedListLoader {
    private let breeds: [Breed]
    init(breeds: [Breed] = [.anyBreed, .anyBreed, .anyBreed]) {
        self.breeds = breeds
    }
    func load() -> AnyPublisher<[Breed], Error> {
        Just(breeds)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

struct StubDogImageListLoader: DogImageListLoader {
    private let images: [DogImage]
    init(images: [DogImage] = [.anyDogImage, .anyDogImage, .anyDogImage]) {
        self.images = images
    }
    func load(of breed: BreedType) -> AnyPublisher<[DogImage], Error> {
        Just(images)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
