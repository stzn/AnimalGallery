//
//  APIClient.swift
//  AnimalGallery
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
    func send(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            completion(.success(data))
        }
        task.resume()
        return task
    }
}

