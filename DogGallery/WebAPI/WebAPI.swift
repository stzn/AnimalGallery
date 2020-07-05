//
//  WebAPI.swift
//  DogGallery
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
            queue.async {
                switch result {
                case .success(let response):
                    do {
                        let json = try JSONDecoder().decode(M.self, from: response.data)
                        completion(.success(json))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
