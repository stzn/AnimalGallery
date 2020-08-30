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
    let queue: DispatchQueue
    init(client: HTTPClient,
         queue: DispatchQueue = DispatchQueue(label: "CatWebAPI")) {
        self.client = client
        self.queue = queue
    }
}

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
        var request = URLRequest(url: composedUrl)
        request.addValue(catAPIKey, forHTTPHeaderField: "x-api-key")
        return request
    }
}

enum CatListMapper {
    private struct BreedListAPIModel: Decodable {
        let id: String
        let name: String
    }

    static func map(_ data: Data) -> Result<[Breed], Error> {
        Result {
            try JSONDecoder().decode([BreedListAPIModel].self, from: data)
                .map { Breed(id: $0.id, name: $0.name) }
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
        let request = CatAPIURLRequestFactory.makeURLRequest(
                from: catAPIbaseURL.appendingPathComponent("/images/search"),
                queryItems: [URLQueryItem(name: "breed_id", value: breed),
                             URLQueryItem(name: "limit", value: "100")])
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

