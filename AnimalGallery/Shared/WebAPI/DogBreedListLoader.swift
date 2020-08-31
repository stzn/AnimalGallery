//
//  Dog.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

typealias DogBreedListLoader = RemoteListLoader<[Breed], DogBreedListMapper.APIModel>

extension DogBreedListLoader {
    convenience init(client: HTTPClient) {
        self.init(url: dogBreedListAPIURL,
                  client: client, mapper: DogBreedListMapper.map)
    }

    func load(completion: @escaping (Result<Resource, Error>) -> Void) {
        call(URLRequest(url: self.url)) { result in
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

enum DogBreedListMapper {
    struct APIModel: Decodable {
        let message: [String: [String]]
        let status: String
    }

    static func map(_ apiModel: APIModel) -> Result<[Breed], Error> {
        .success(apiModel.message.map { Breed(id: $0.key, name: $0.key) })
    }
}

enum DogImageListMapper {
    struct APIModel: Decodable {
        let message: [String]
        let status: String
    }

    static func map(_ apiModel: APIModel) -> Result<[AnimalImage], Error> {
        .success(
            apiModel.message.compactMap { urlString -> AnimalImage? in
                guard let url = URL(string: urlString) else {
                    return nil
                }
                return AnimalImage(imageURL: url)
            }
        )
    }
}
