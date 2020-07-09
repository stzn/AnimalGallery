//
//  DogImageLoader.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/07/04.
//

import SwiftUI

struct DogImageLoader: ImageLoadable {
    func loadImage(for identifier: String, entryDate: Date, refreshDate: Date, completion: @escaping (ImageEntry) -> Void) {
        if identifier == "random" {
            Self.loadRandom { result in
                switch result {
                case .success(let image):
                    completion(.init(date: entryDate, nextDate: refreshDate, image: image))
                case .failure:
                    completion(
                        ImageEntry(date: entryDate, nextDate: refreshDate, image: errorImage)
                    )
                }
            }
        } else {
            Self.loadRandomInBreed(identifier) { result in
                switch result {
                case .success(let image):
                    completion(.init(date: entryDate, nextDate: refreshDate, image: image))
                case .failure:
                    completion(
                        ImageEntry(date: entryDate, nextDate: refreshDate, image: errorImage)
                    )
                }
            }
        }
    }

    static func loadRandom(completion: @escaping (Result<WidgetImage, Error>) -> Void) {
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
                              completion: @escaping (Result<WidgetImage, Error>) -> Void) {

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
            completion(.success(WidgetImage(name: breed, image: Image(uiImage: image))))
        }.resume()
    }

    private static func extractBreed(from url: URL) -> String {
        url.deletingLastPathComponent().lastPathComponent.firstLetterCapitalized
    }

    static func loadRandomInBreed(_ breedName: BreedType,
                                  completion: @escaping (Result<WidgetImage, Error>) -> Void) {
        struct DogImagesModel: Decodable {
            let message: [String]
            let status: String
        }

        let url = dogAPIbaseURL.appendingPathComponent("/breed/\(breedName)/images")
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
