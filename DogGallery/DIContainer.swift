//
//  DIContainer.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/02/26.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct DIContainer: EnvironmentKey {
    let loaders: Loaders

    static var defaultValue: Self { Self.default }
    private static let `default` = Self(loaders: .live)
}

extension EnvironmentValues {
    var injected: DIContainer {
        get { self[DIContainer.self] }
        set { self[DIContainer.self] = newValue }
    }
}

extension DIContainer {
    struct Loaders {
        let dogBreedListLoader: BreedListLoader
        let catBreedListLoader: BreedListLoader
        let dogImageListLoader: AnimalImageListLoader
        let catImageListLoader: AnimalImageListLoader
        let imageDataLoader: ImageDataLoader

        static var stub: Self {
            .init(dogBreedListLoader: StubBreedListLoader(),
                  catBreedListLoader: StubBreedListLoader(),
                  dogImageListLoader: StubAnimalImageListLoader(),
                  catImageListLoader: StubAnimalImageListLoader(),
                  imageDataLoader: StubImageDataLoader())
        }

        static var live: Self {
            let loaders = configureLoaders()
            return Loaders(
                dogBreedListLoader: loaders.dogBreedListLoader,
                catBreedListLoader: loaders.catBreedListLoader,
                dogImageListLoader: loaders.dogImageListLoader,
                catImageListLoader: loaders.catImageListLoader,
                imageDataLoader: loaders.imageDataLoader)
        }

        private static func configuredURLSession() -> URLSession {
            let configuration = URLSessionConfiguration.default
            return URLSession(configuration: configuration)
        }

        private static func configureLoaders() -> Self {
            let session = configuredURLSession()
            let client = URLSessionHTTPClient(session: session)

            let dogWebAPI = DogWebAPI(client: client)
            let catWebAPI = CatWebAPI(client: client)
            let imageWebLoader = ImageDataWebLoader(client: client)

            return .init(dogBreedListLoader: dogWebAPI,
                         catBreedListLoader: catWebAPI,
                         dogImageListLoader: dogWebAPI,
                         catImageListLoader: catWebAPI,
                         imageDataLoader: imageWebLoader
            )
        }
    }
}

