//
//  BreedListLoader.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/02/27.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

protocol BreedListLoader {
    func load(completion: @escaping (Result<[Breed], Error>) -> Void)
}