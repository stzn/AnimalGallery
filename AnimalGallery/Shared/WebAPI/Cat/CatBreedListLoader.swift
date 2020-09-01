//
//  CatWebAPI.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/07/09.
//

import Foundation

typealias CatBreedListLoader = RemoteListLoader<[Breed], [CatBreedListMapper.APIModel]>

extension CatBreedListLoader {
    convenience init(client: HTTPClient) {
        self.init(url: catBreedListAPIURL,
                  client: client, mapper: CatBreedListMapper.map)
    }

    func load(completion: @escaping (Result<Resource, Error>) -> Void) {
        call(URLRequest(url: self.url)) { [weak self] result in
            guard let self = self else {
                return
            }

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

enum CatBreedListMapper {
    struct APIModel: Decodable {
        let id: String
        let name: String
    }

    static func map(_ apiModels: [APIModel]) -> Result<[Breed], Error> {
        .success(apiModels.map { Breed(id: $0.id, name: $0.name) })
    }
}
