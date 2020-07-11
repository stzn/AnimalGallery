//
//  WebAPI.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/02/27.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

protocol WebAPI {
    var client: HTTPClient { get }
    var baseURL: URL { get }
    var queue: DispatchQueue { get }
}

extension WebAPI {
    func call<M: Decodable>(_ type: M.Type, _ request: URLRequest, completion: @escaping (Result<M, Error>) -> Void) {
        client.send(request: request) { result in
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            queue.async {
                completion(
                    result.flatMap { response in
                        Result {
                            try JSONDecoder().decode(M.self, from: response.data)
                        }
                    }
                )
            }
        }
    }
}
