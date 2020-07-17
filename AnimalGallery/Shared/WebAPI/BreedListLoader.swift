//
//  BreedListLoader.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/02/27.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

struct BreedListLoader {
    let load: (@escaping (Result<[Breed], Error>) -> Void) -> Void
}

#if DEBUG
extension BreedListLoader {
    static var stub = BreedListLoader { callback in callback(.success([.anyBreed, .anyBreed, .anyBreed])) }
}
#endif
