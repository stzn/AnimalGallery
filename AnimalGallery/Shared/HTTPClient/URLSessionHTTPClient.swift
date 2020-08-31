//
//  APIClient.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    init(session: URLSession) {
        self.session = session
    }

    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask

        func cancel() {
            wrapped.cancel()
        }
    }

    @discardableResult
    func send(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: request) { data, response, error in
            completion(Result {
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode,
                      let data = data else {
                    throw URLError(.badServerResponse)
                }
                return data
            })
        }
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
}

