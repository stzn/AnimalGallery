//
//  RemoteListLoader.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/08/30.
//

import Foundation

final class RemoteListLoader<Resource, APIModel: Decodable> {
    typealias Mapper = (APIModel) -> Result<Resource, Error>
    let url: URL
    let client: HTTPClient
    let mapper: Mapper

    init(
        url: URL,
        client: HTTPClient,
        mapper: @escaping Mapper
    ) {
        self.url = url
        self.client = client
        self.mapper = mapper
    }

    func load(requestBuilder: @escaping (URL) -> URLRequest,
              completion: @escaping (Result<Resource, Error>) -> Void) {
        let request = requestBuilder(self.url)
        call(request) { result in
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

    func call(_ request: URLRequest, completion: @escaping (Result<APIModel, Swift.Error>) -> Void) {
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
