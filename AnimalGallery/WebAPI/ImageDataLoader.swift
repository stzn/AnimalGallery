//
//  ImageDataLoader.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/02/27.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

protocol ImageDataLoader {
    func load(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> HTTPClientTask
}
