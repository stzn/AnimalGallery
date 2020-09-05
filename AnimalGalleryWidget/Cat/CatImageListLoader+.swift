//
//  CatImageListLoader+.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/09/05.
//

import Foundation

extension CatImageListLoader {
    func load(of breed: BreedType? = nil, limit: Int = 100, completion: @escaping (Result<[AnimalImage], Error>) -> Void) {
        guard let request = makeURLRequest(using: requestBuilder(breed), with: [URLQueryItem(name: "limit", value: "\(limit)")]) else {
            return
        }
        call(request) { [weak self] result in
            guard let self = self else {
                return
            }
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            guard let apiModel = try? result.get() else {
                return
            }
            completion(self.mapper(apiModel))
        }
    }

    private func makeURLRequest(using request: URLRequest,
                               with appendingQueryItems: [URLQueryItem]) -> URLRequest? {

        guard let url = request.url,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              var queryItems = components.queryItems else {
            return nil
        }
        queryItems.append(contentsOf: appendingQueryItems)
        components.queryItems = queryItems

        guard let componentsUrl = components.url else {
            return nil
        }
        return URLRequest(url: componentsUrl)
    }
}
