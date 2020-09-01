//
//  DogImageListMapper.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/09/02.
//

import Foundation

enum DogImageListMapper {
    struct APIModel: Decodable {
        let message: [String]
        let status: String
    }

    static func map(_ apiModel: APIModel) -> Result<[AnimalImage], Error> {
        .success(
            apiModel.message.compactMap { urlString -> AnimalImage? in
                guard let url = URL(string: urlString) else {
                    return nil
                }
                return AnimalImage(imageURL: url)
            }
        )
    }
}
