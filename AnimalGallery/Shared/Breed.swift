//
//  Breed.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

struct Breed: Equatable, Decodable, Hashable, Identifiable {
    let id: String
    let name: String
}

extension Breed {
    static var anyBreed: Breed {
        let anyID = UUID().uuidString
        return Breed(id: anyID, name: "test\(anyID)")
    }
}
