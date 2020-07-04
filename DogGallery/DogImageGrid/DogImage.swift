//
//  DogImage.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

struct DogImage: Equatable, Decodable, Hashable {
    let imageURL: URL
}

extension DogImage: Identifiable {
    var id: URL { imageURL }
}

extension DogImage {
    static var anyDogImage: DogImage {
        DogImage(imageURL: URL(string: "https://\(UUID().uuidString).image.com")!)
    }
}
