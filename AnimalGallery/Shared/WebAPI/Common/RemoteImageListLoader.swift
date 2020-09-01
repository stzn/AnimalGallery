//
//  RemoteImageListLoader.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/08/31.
//

import Foundation

final class RemoteImageListLoader<Resource, APIModel: Decodable> {
    let client: HTTPClient
    let requestBuilder: (BreedType?) -> URLRequest
    let mapper: (APIModel) -> Result<Resource, Error>

    init(client: HTTPClient,
         requestBuilder: @escaping (BreedType?) -> URLRequest,
         mapper: @escaping (APIModel) -> Result<Resource, Error>) {
        self.client = client
        self.requestBuilder = requestBuilder
        self.mapper = mapper
    }

    func load(of breedType: BreedType?, completion: @escaping (Result<Resource, Error>) -> Void) {
        call(self.requestBuilder(breedType)) { result in
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

    func call(_ request: URLRequest, completion: @escaping (Result<APIModel, Error>) -> Void) {
        client.send(request: request) { result in
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            completion(
                result.flatMap { data in
                    Result {
                        try JSONDecoder().decode(APIModel.self, from: data)
                    }
                }
            )
        }
    }
}
