//
//  CatImageListLoader.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/09/02.
//

import Foundation

typealias CatImageListLoader = RemoteImageListLoader<[AnimalImage], CatImageListMapper.APIModel>

extension CatImageListLoader {
    convenience init(client: HTTPClient) {
        self.init(
            client: client,
            requestBuilder: { breedType in
                var queryItems: [URLQueryItem] = []
                if let breed = breedType {
                    queryItems.append(URLQueryItem(name: "breed_id", value: breed))
                }
                return CatAPIURLRequestFactory.makeURLRequest(
                        from: catAPIbaseURL.appendingPathComponent("/images/search"),
                        queryItems: queryItems)
            },
            mapper: CatImageListMapper.map)
    }
}
