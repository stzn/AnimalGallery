//
//  CatImageListMapper.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/09/02.
//

import Foundation

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
