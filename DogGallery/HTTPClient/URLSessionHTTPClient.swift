//
//  APIClient.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

extension URLSessionDataTask: HTTPClientTask {}

struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    init(session: URLSession) {
        self.session = session
    }

    @discardableResult
    func send(request: URLRequest, completion: @escaping (Result<Response, Error>) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(HTTPClientError.invalidResponse(response)))
                return
            }
            if let apiError = HTTPClientError.error(from: httpResponse) {
                completion(.failure(apiError))
                return
            }
            guard let data = data else {
                completion(.failure(HTTPClientError.noData))
                return
            }
            completion(.success(Response(data: data, response: httpResponse)))
        }
        task.resume()
        return task
    }
}

