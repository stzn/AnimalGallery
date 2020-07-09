//
//  Dog.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

final class DogWebAPI: WebAPI {
    let baseURL = dogAPIbaseURL
    let client: HTTPClient
    let queue = DispatchQueue(label: "DogWebAPI")
    init(client: HTTPClient) {
        self.client = client
    }
}

extension DogWebAPI: BreedListLoader {
    struct BreedListAPIModel: Decodable {
        let message: [String: [String]]
        let status: String
    }

    func load(completion: @escaping (Result<[Breed], Error>) -> Void) {
        call(BreedListAPIModel.self,
             URLRequest(url: baseURL.appendingPathComponent("breeds/list/all"))) { result in
            switch result {
            case .success(let model):
                let breeds = model.message.keys.map { Breed(id: $0, name: $0) }
                completion(.success(breeds))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension DogWebAPI: AnimalImageListLoader {
    struct DogImageListAPIModel: Decodable {
        let message: [String]
        let status: String
    }

    func load(of breed: BreedType, completion: @escaping (Result<[AnimalImage], Error>) -> Void) {
        call(DogImageListAPIModel.self,
             URLRequest(url: baseURL.appendingPathComponent("/breed/\(breed)/images"))) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let model):
                let breeds = self.convert(from: model)
                completion(.success(breeds))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func convert(from model: DogImageListAPIModel) -> [AnimalImage] {
        let urlStrings = model.message
        let dogImages = urlStrings.compactMap { urlString -> AnimalImage? in
            guard let url = URL(string: urlString) else {
                return nil
            }
            return AnimalImage(imageURL: url)
        }
        return dogImages
    }
}
