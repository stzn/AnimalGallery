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
    private final class Task: HTTPClientTask {
        func cancel() {
        }
    }

    private let data: Data
    init(data: Data = stubImage) {
        self.data = data
    }

    func load(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> HTTPClientTask {
        completion(.success(data))
        return Task()
    }
}

struct StubBreedListLoader: BreedListLoader {
    private let breeds: [Breed]
    init(breeds: [Breed] = [.anyBreed, .anyBreed, .anyBreed]) {
        self.breeds = breeds
    }

    func load(completion: @escaping (Result<[Breed], Error>) -> Void) {
        completion(.success(breeds))
    }
}

struct StubDogImageListLoader: DogImageListLoader {
    private let images: [DogImage]
    init(images: [DogImage] = [.anyDogImage, .anyDogImage, .anyDogImage]) {
        self.images = images
    }

    func load(of breed: BreedType, completion: @escaping (Result<[DogImage], Error>) -> Void) {
        completion(.success(images))
    }
}
