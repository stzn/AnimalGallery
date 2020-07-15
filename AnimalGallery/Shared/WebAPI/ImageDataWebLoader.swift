//
//  ImageAPI.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/02/25.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

final class ImageDataWebLoader {
    private let queue = DispatchQueue(label: "ImageWebAPI")
    private let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }

    private final class Task: HTTPClientTask {
        private var completion: ((Result<Data, Error>) -> Void)?
        var wrapped: HTTPClientTask?
        init(_ completion: @escaping ((Result<Data, Error>) -> Void)) {
            self.completion = completion
        }

        func completion(with result: Result<Data, Error>) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletion()
            wrapped?.cancel()
        }

        func preventFurtherCompletion() {
            completion = nil
        }
    }

    func load(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> HTTPClientTask {
        let task = Task(completion)
        task.wrapped = client.send(request: URLRequest(url: url)) { [weak self] result in
            self?.queue.async {
                completion(result.map(\.data))
            }
        }
        return task
    }
}
