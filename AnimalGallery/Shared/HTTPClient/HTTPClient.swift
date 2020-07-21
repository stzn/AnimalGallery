//
//  APIClient.swift
//  Networking
//
//  Created by Shinzan Takata on 2020/02/01.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

protocol HTTPClientTask {
    func cancel()
}

protocol HTTPClient {
    @discardableResult
    func send(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> HTTPClientTask
}
