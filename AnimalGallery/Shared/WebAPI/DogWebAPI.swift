//
//  Dog.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

enum DogListMapper {
    private struct BreedListAPIModel: Decodable {
        let message: [String: [String]]
        let status: String
    }

    static func map(_ data: Data) -> Result<[Breed], Error> {
        Result {
            try JSONDecoder().decode(BreedListAPIModel.self, from: data)
                .message
                .map { Breed(id: $0.key, name: $0.key) }
        }
    }
}

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
