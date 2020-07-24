//
//  ImageAPI.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/02/25.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

final class ImageDataWebLoader {
    private let client: HTTPClient
    private let queue: DispatchQueue
    init(client: HTTPClient,
         queue: DispatchQueue = DispatchQueue(label: "ImageDataWebLoader")) {
        self.client = client
        self.queue = queue
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
        task.wrapped = client.send(request: URLRequest(url: url)) { [weak self] data in
            self?.queue.async {
                completion(data)
            }
        }
        return task
    }
}
