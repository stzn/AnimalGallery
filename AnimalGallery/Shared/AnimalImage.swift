//
//  AnimalImage.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

struct AnimalImage: Equatable, Decodable, Hashable {
    let imageURL: URL
}

extension AnimalImage: Identifiable {
    var id: URL { imageURL }
}

extension AnimalImage {
    static var anyAnimalImage: AnimalImage {
        AnimalImage(imageURL: URL(string: "https://\(UUID().uuidString).image.com")!)
    }
}
