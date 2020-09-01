//
//  DogImageURLListLoader.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/09/02.
//

import Foundation

typealias DogImageURLListLoader = RemoteListLoader<[URL], DogImageURLListMapper.APIModel>

extension DogImageURLListLoader {
    convenience init(client: HTTPClient) {
    self.init(url: dogAPIbaseURL,
              client: client,
              mapper: DogImageURLListMapper.map)
    }

    func loadRandom(
        count: Int,
        completion: @escaping (Result<[URL], Error>) -> Void) {
            load(requestBuilder:  { URLRequest.init(url: $0.appendingPathComponent("breeds/image/random/\(count)")) },
                  completion: completion)
    }
}

enum DogImageURLListMapper {
    struct APIModel: Decodable {
        let message: [String]
        let status: String
    }

    static func map(_ apiModel: APIModel) -> Result<[URL], Error> {
        .success(apiModel.message.compactMap(URL.init(string:)))
    }
}
