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
        let breedListLoader: BreedListLoader
        let dogImageListLoader: DogImageListLoader
        let imageDataLoader: ImageDataLoader

        static var stub: Self {
            .init(breedListLoader: StubBreedListLoader(),
                  dogImageListLoader: StubDogImageListLoader(),
                  imageDataLoader: StubImageDataLoader())
        }

        static var live: Self {
            let loaders = configureLoaders()
            return Loaders(
                breedListLoader: loaders.breedListLoader,
                dogImageListLoader: loaders.dogImageListLoader,
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
            let imageWebLoader = ImageDataWebLoader(client: client)

            return .init(breedListLoader: dogWebAPI,
                         dogImageListLoader: dogWebAPI,
                         imageDataLoader: imageWebLoader
            )
        }
    }
}

