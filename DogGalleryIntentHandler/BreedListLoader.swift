//
//  BreedListLoader.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/07/05.
//

import Foundation

enum BreedListLoader {
    static func load(completion: @escaping (Result<[IntentBreed], Error>) -> Void) {
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
}
