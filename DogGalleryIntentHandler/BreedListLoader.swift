//
//  BreedListLoader.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/07/05.
//

import Foundation

enum BreedListLoader {
    static func loadDogBreedList(completion: @escaping (Result<[IntentBreed], Error>) -> Void) {
        struct BreedListAPIModel: Decodable {
            let message: [String: [String]]
            let status: String
        }

        let url = dogAPIbaseURL.appendingPathComponent("breeds/list/all")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse,
                  200..<299 ~= response.statusCode else {
                return
            }

            guard let data = data,
                  let model = try? JSONDecoder().decode(BreedListAPIModel.self, from: data)  else {
                return
            }
            let breeds = model.message.keys.map { name in
                IntentBreed(identifier: name, display: name)
            }
            completion(.success(breeds))
        }.resume()
    }

    static func loadCatBreedList(completion: @escaping (Result<[IntentBreed], Error>) -> Void) {
        struct BreedListAPIModel: Decodable {
            let id: String
            let name: String
        }

        let url = catAPIbaseURL.appendingPathComponent("breeds")
        guard let request = createURLRequest(from: url) else {
            assertionFailure("should not be nil")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse,
                  200..<299 ~= response.statusCode else {
                return
            }

            guard let data = data,
                  let models = try? JSONDecoder().decode([BreedListAPIModel].self, from: data)  else {
                return
            }
            let breeds = models.map { model in
                IntentBreed(identifier: model.id, display: model.name)
            }
            completion(.success(breeds))
        }.resume()
    }

    private static func createURLRequest(from url: URL,
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
