//
//  DogImageLoader.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/07/04.
//

import SwiftUI

enum DogImageLoader {
    static func loadRandom(completion: @escaping (Result<WidgetDogImage, Error>) -> Void) {
        struct WidgetDogImageModel: Decodable {
            let message: String
            let status: String
        }

        let url = dogAPIbaseURL.appendingPathComponent("breeds/image/random")
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
                  let model = try? JSONDecoder().decode(WidgetDogImageModel.self, from: data)  else {
                return
            }

            guard let url = URL(string: model.message) else {
                return
            }
            loadDogImage(from: url, completion: completion)
        }.resume()
    }

    private static func loadDogImage(from url: URL,
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
            let breed = extractBreed(from: url)
            completion(.success(WidgetDogImage(name: breed, image: Image(uiImage: image))))
        }.resume()
    }

    private static func extractBreed(from url: URL) -> String {
        url.deletingLastPathComponent().lastPathComponent.firstLetterCapitalized
    }

    static func loadRandomInBreed(_ breed: Breed,
                                  completion: @escaping (Result<WidgetDogImage, Error>) -> Void) {
        struct DogImagesModel: Decodable {
            let message: [String]
            let status: String
        }

        let url = dogAPIbaseURL.appendingPathComponent("/breed/\(breed.name)/images")
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
                  let model = try? JSONDecoder().decode(DogImagesModel.self, from: data) else {
                return
            }
            let urlString = model.message[Int.random(in: 0..<model.message.count)]
            guard let url = URL(string: urlString) else {
                return
            }

            loadDogImage(from: url, completion: completion)
        }.resume()
    }
}
