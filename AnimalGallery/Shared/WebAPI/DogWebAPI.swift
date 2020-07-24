//
//  Dog.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

final class DogWebAPI: WebAPI {
    let baseURL = dogAPIbaseURL
    let client: HTTPClient
    let queue: DispatchQueue
    init(client: HTTPClient,
         queue: DispatchQueue = DispatchQueue(label: "DogWebAPI")) {
        self.client = client
        self.queue = queue
    }
}

extension DogWebAPI {
    struct BreedListAPIModel: Decodable {
        let message: [String: [String]]
        let status: String
    }

    func load(completion: @escaping (Result<[Breed], Error>) -> Void) {
        call(BreedListAPIModel.self,
             URLRequest(url: baseURL.appendingPathComponent("breeds/list/all"))) { result in
            completion(
                result.map { model in model.message.keys.map { Breed(id: $0, name: $0) } }
            )
        }
    }
}

extension DogWebAPI {
    struct DogImageListAPIModel: Decodable {
        let message: [String]
        let status: String
    }

    func load(of breed: BreedType, completion: @escaping (Result<[AnimalImage], Error>) -> Void) {
        call(DogImageListAPIModel.self,
             URLRequest(url: baseURL.appendingPathComponent("/breed/\(breed)/images"))) { [weak self] result in
            guard let self = self else {
                return
            }
            completion(result.map(self.convert(from:)))
        }
    }

    private func convert(from model: DogImageListAPIModel) -> [AnimalImage] {
        let urlStrings = model.message
        let dogImages = urlStrings.compactMap { urlString -> AnimalImage? in
            guard let url = URL(string: urlString) else {
                return nil
            }
            return AnimalImage(imageURL: url)
        }
        return dogImages
    }
}
