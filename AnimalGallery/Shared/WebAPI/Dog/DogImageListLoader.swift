//
//  DogImageListLoader.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/09/02.
//

import Foundation


typealias DogImageListLoader = RemoteImageListLoader<[AnimalImage], DogImageListMapper.APIModel>

extension DogImageListLoader {
    convenience init(client: HTTPClient) {
        self.init(
            client: client,
            requestBuilder: { breedType in
                URLRequest(url: dogAPIbaseURL.appendingPathComponent("/breed/\(breedType!)/images"))
            },
            mapper: DogImageListMapper.map)
    }
}
