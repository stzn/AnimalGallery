//
//  CatWebAPI.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/07/09.
//

import Foundation

final class CatWebAPI: WebAPI {
    let baseURL = catAPIbaseURL
    let client: HTTPClient
    let queue = DispatchQueue(label: "CatWebAPI")
    init(client: HTTPClient) {
        self.client = client
    }

    func makeURLRequest(from url: URL,
                        queryItems: [URLQueryItem] = []) -> URLRequest? {
        var component = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false)
        component?.queryItems = queryItems

        guard let url = component?.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue(catAPIKey, forHTTPHeaderField: "x-api-key")
        return request
    }
}

extension CatWebAPI {
    struct BreedListAPIModel: Decodable {
        let id: String
        let name: String
    }

    func load(completion: @escaping (Result<[Breed], Error>) -> Void) {
        let url = catAPIbaseURL.appendingPathComponent("breeds")
        guard let request = makeURLRequest(from: url) else {
            assertionFailure("should not be nil")
            return
        }
        call([BreedListAPIModel].self, request) { result in
            completion(
                result.map {
                    $0.map { Breed(id: $0.id, name: $0.name) }
                }
            )
        }
    }
}

extension CatWebAPI {
    struct Root: Decodable {
        let models: [CatImageModel]

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.models = try container.decode([CatImageModel].self)
        }
    }

    struct CatImageModel: Decodable {
        let url: URL
        let breeds: [Breed]

        struct Breed: Decodable {
            let name: String
        }
    }

    func load(of breed: BreedType, completion: @escaping (Result<[AnimalImage], Error>) -> Void) {
        guard let request = makeURLRequest(
                from: catAPIbaseURL.appendingPathComponent("/images/search"),
                queryItems: [
                    URLQueryItem(name: "breed_id", value: breed),
                    URLQueryItem(name: "limit", value: "100")
                ]) else {
            assertionFailure("should not be nil")
            return
        }

        call(Root.self, request) { [weak self] result in
            guard let self = self else {
                return
            }
            completion(result.map(self.convert(from:)))
        }
    }

    func convert(from model: Root) -> [AnimalImage] {
        let urls = model.models.map { $0.url }
        let catImages = urls.map(AnimalImage.init(imageURL:))
        return catImages
    }
}

