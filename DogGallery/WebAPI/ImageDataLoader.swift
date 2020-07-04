//
//  ImageDataLoader.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/02/27.
//  Copyright © 2020 shiz. All rights reserved.
//

import Combine
import Foundation

protocol ImageDataLoader {
    func load(from url: URL) -> AnyPublisher<Data, Error>
}
