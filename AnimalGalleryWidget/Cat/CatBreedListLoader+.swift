//
//  CatBreedListLoader+.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/09/02.
//

import Foundation

extension CatBreedListLoader {
    func loadRandomBreeds(limit: Int, completion: @escaping (Result<[Breed], Error>) -> Void) {
        load(requestBuilder: { url in
            CatAPIURLRequestFactory.makeURLRequest(
                    from: url, queryItems: [URLQueryItem(name: "limit", value: "\(limit)")])
        }) {
                completion(
                    $0.map { models in models.map { Breed(id: $0.id, name: $0.name) } }
                )
            }
    }

    enum LoaderError: Swift.Error {
        case failToCreateBreed
    }

    func loadBreedByName(_ name: String, completion: @escaping (Result<Breed, Error>) -> Void) {
        load(requestBuilder: { url in
            CatAPIURLRequestFactory.makeURLRequest(
                    from: url.appendingPathComponent("breeds/search"),
                queryItems: [URLQueryItem(name: "q", value: name)])
        }) { result in
            completion(Result {
                guard let breed = try? result.get().first else {
                    throw LoaderError.failToCreateBreed
                }
                return breed
            })
        }
    }
}
