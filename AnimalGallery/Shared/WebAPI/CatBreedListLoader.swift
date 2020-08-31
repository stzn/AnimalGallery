//
//  CatWebAPI.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/07/09.
//

import Foundation

typealias CatBreedListLoader = RemoteListLoader<[Breed], [CatBreedListMapper.APIModel]>

extension CatBreedListLoader {
    convenience init(client: HTTPClient) {
        self.init(url: catBreedListAPIURL,
                  client: client, mapper: CatBreedListMapper.map)
    }

    func load(completion: @escaping (Result<Resource, Error>) -> Void) {
        call(URLRequest(url: self.url)) { [weak self] result in
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

enum CatAPIURLRequestFactory {
    static func makeURLRequest(_ url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue(catAPIKey, forHTTPHeaderField: "x-api-key")
        return request
    }

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

enum CatBreedListMapper {
    struct APIModel: Decodable {
        let id: String
        let name: String
    }

    static func map(_ apiModels: [APIModel]) -> Result<[Breed], Error> {
        .success(apiModels.map { Breed(id: $0.id, name: $0.name) })
    }
}

enum CatImageListMapper {
    struct APIModel: Decodable {
        let models: [Content]

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.models = try container.decode([Content].self)
        }
    }

    struct Content: Decodable {
        let url: URL
        let breeds: [Breed]

        struct Breed: Decodable {
            let name: String
        }
    }

    static func map(_ apiModel: APIModel) -> Result<[AnimalImage], Error> {
        .success(
            apiModel.models.map { $0.url }.map(AnimalImage.init(imageURL:))
        )
    }
}
