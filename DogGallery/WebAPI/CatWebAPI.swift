//
//  CatWebAPI.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/07/09.
//

import Foundation

final class CatWebAPI: WebAPI {
    let baseURL = catAPIbaseURL
    let client: HTTPClient
    let queue = DispatchQueue(label: "DogWebAPI")
    init(client: HTTPClient) {
        self.client = client
    }
}

extension CatWebAPI: BreedListLoader {
    struct BreedListAPIModel: Decodable {
        let id: String
        let name: String
    }

    func load(completion: @escaping (Result<[Breed], Error>) -> Void) {
        let url = catAPIbaseURL.appendingPathComponent("breeds")
        guard let request = createURLRequest(from: url) else {
            assertionFailure("should not be nil")
            return
        }
        call([BreedListAPIModel].self, request) { result in
            switch result {
            case .success(let models):
                let breeds = models.map { Breed.init(name: $0.name) }
                completion(.success(breeds))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func createURLRequest(from url: URL,
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
