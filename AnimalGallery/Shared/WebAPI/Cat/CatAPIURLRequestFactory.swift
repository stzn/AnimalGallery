//
//  CatAPIURLRequestFactory.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/09/02.
//

import Foundation

enum CatAPIURLRequestFactory {
    static func makeURLRequest(from url: URL,
                        queryItems: [URLQueryItem] = []) -> URLRequest {
        var component = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false)
        component?.queryItems = queryItems

        guard let composedUrl = component?.url else {
            assertionFailure("should not be nil")
            return URLRequest(url: url)
        }
        return URLRequest(url: composedUrl)
    }
}
