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
    func call<M: Decodable>(_ type: M.Type, _ request: URLRequest) -> AnyPublisher<M, Error> {
        client.send(request: request)
            .receive(on: queue)
            .map(\.data)
            .decode(type: M.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
