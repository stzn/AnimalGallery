//
//  APIClient.swift
//  Networking
//
//  Created by Shinzan Takata on 2020/02/01.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

protocol HTTPClient {
    func send(request: URLRequest) -> AnyPublisher<Response, Error>
}
