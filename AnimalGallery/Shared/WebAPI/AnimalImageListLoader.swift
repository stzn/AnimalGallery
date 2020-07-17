//
//  AnimalImageListLoader.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/02/27.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

struct AnimalImageListLoader {
    let load: (BreedType, @escaping (Result<[AnimalImage], Error>) -> Void) -> Void
}

#if DEBUG
extension AnimalImageListLoader {
    static var stub = AnimalImageListLoader { _, callback in
        callback(.success([.anyAnimalImage, .anyAnimalImage, .anyAnimalImage]))
    }
}
#endif
