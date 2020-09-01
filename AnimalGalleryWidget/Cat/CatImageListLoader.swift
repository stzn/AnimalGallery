//
//  CatImageListLoader.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/09/02.
//

import Foundation

typealias CatImageListLoader = RemoteImageListLoader<[AnimalImage], CatImageListMapper.APIModel>

extension CatImageListLoader {
    convenience init(client: HTTPClient, limit: Int = 100) {
        self.init(
            client: client,
            requestBuilder: { breedType in
                var queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
                if let breed = breedType {
                    queryItems.append(URLQueryItem(name: "breed_id", value: breed))
                }
                return CatAPIURLRequestFactory.makeURLRequest(
                        from: catAPIbaseURL.appendingPathComponent("/images/search"),
                        queryItems: queryItems)
            },
            mapper: CatImageListMapper.map)
    }

    func load(of breed: BreedType? = nil, limit: Int = 100, completion: @escaping (Result<[AnimalImage], Error>) -> Void) {
        guard let url = requestBuilder(breed).url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              var queryItems = components.queryItems else {
            return
        }
        queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        components.queryItems = queryItems

        guard let componentsUrl = components.url else {
            return
        }

        call(URLRequest(url: componentsUrl)) { [weak self] result in
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
}
