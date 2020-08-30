//
//  RemoteListLoader.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/08/30.
//

import Foundation

struct RemoteListLoader<Resource, APIModel: Decodable> {
    let request: URLRequest
    let client: HTTPClient
    let queue: DispatchQueue = DispatchQueue(label: "RemoteListLoaderQueue")
    let mapper: (APIModel) -> Result<Resource, Error>

    func load(completion: @escaping (Result<Resource, Error>) -> Void) {
        call(request) { result in
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            guard let apiModel = try? result.get() else {
                return
            }
            completion(mapper(apiModel))
        }
    }

    private func call(_ request: URLRequest, completion: @escaping (Result<APIModel, Error>) -> Void) {
        client.send(request: request) { result in
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            queue.async {
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

}
