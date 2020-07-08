//
//  CatImageLoader.swift
//  DogGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/08.
//

import SwiftUI

enum CatImageLoader {
    struct Root: Decodable {
        let models: [WidgetCatImageModel]

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.models = try container.decode([WidgetCatImageModel].self)
        }
    }

    struct WidgetCatImageModel: Decodable {
        let url: URL
        let breeds: [Breed]

        struct Breed: Decodable {
            let name: String
        }
    }

    static func loadRandom(completion: @escaping (Result<WidgetDogImage, Error>) -> Void) {
        guard let request = createURLRequest(
                from: catAPIbaseURL.appendingPathComponent("/images/search"),
                queryItems: [URLQueryItem(name: "limit", value: "1")]) else {
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
                  let root = try? JSONDecoder().decode(Root.self, from: data),
                  let model = root.models.first else {
                return
            }
            let breedName = model.breeds.first?.name ?? ""
            loadCatImage(from: model.url, for: breedName, completion: completion)
        }.resume()
    }

    static func loadRandomInBreed(_ breed: Breed,
                                  completion: @escaping (Result<WidgetDogImage, Error>) -> Void) {
        guard let request = createURLRequest(
                from: catAPIbaseURL.appendingPathComponent("/images/search"),
                queryItems: [
                    URLQueryItem(name: "breed_id", value: breed.id),
                    URLQueryItem(name: "limit", value: "1")
                ]) else {
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
                  let root = try? JSONDecoder().decode(Root.self, from: data),
                  let model = root.models.first,
                  let breedName = model.breeds.first?.name else {
                return
            }
            loadCatImage(from: model.url, for: breedName, completion: completion)
        }.resume()
    }

    private static func loadCatImage(from url: URL,
                                     for breed: String,
                                     completion: @escaping (Result<WidgetDogImage, Error>) -> Void) {

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse,
                  200..<299 ~= response.statusCode else {
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            completion(.success(WidgetDogImage(name: breed, image: Image(uiImage: image))))
        }.resume()
    }

    private static func createURLRequest(from url: URL, queryItems: [URLQueryItem] = []) -> URLRequest? {
        var component = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false)
        component?.queryItems = queryItems

        guard let url = component?.url else {
            return nil
        }
        var request = URLRequest(url: url)
        // please get your own api key(https://thecatapi.com/)
        request.addValue("XXXXXXXXXXXXXX", forHTTPHeaderField: "x-api-key")
        return request
    }
}
