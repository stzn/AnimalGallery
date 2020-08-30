//
//  RemoteListLoader.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/08/30.
//

import Foundation

struct RemoteListLoader<Resource> {
    let request: URLRequest
    let client: HTTPClient
    let queue: DispatchQueue = DispatchQueue(label: "RemoteListLoaderQueue")
    let mapper: (Data) -> Result<Resource, Error>

    func load(completion: @escaping (Result<Resource, Error>) -> Void) {
        client.send(request: request) { result in
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            queue.async {
                completion(result.flatMap(mapper))
            }
        }
    }
}
