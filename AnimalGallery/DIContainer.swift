//
//  DIContainer.swift
//  AnimalGallery
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

typealias BreedListLoader = (@escaping (Result<[Breed], Error>) -> Void) -> Void

extension DIContainer {
    struct Loaders {
        let dogBreedListLoader: BreedListLoader
        let catBreedListLoader: BreedListLoader
        let dogImageListLoader: AnimalImageListLoader
        let catImageListLoader: AnimalImageListLoader
        let imageDataLoader: ImageDataLoader

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

            let dogListLoader = RemoteListLoader(
                request: URLRequest(url: dogBreedListAPIURL),
                client: client, mapper: DogListMapper.map)

            let catListLoader = RemoteListLoader(
                request: CatAPIURLRequestFactory.makeURLRequest(from: catBreedListAPIbaseURL),
                client: client, mapper: CatListMapper.map)

            let dogWebAPI = DogWebAPI(client: client)
            let catWebAPI = CatWebAPI(client: client)
            let imageWebLoader = ImageDataWebLoader(client: client)

            return .init(dogBreedListLoader: dogListLoader.load(completion:),
                         catBreedListLoader: catListLoader.load(completion:),
                         dogImageListLoader: AnimalImageListLoader(load: dogWebAPI.load(of:completion:)),
                         catImageListLoader: AnimalImageListLoader(load: catWebAPI.load(of:completion:)),
                         imageDataLoader: ImageDataLoader(load: imageWebLoader.load(from:completion:))
            )
        }
    }
}

#if DEBUG
extension DIContainer.Loaders {
    static var stub: Self {
        .init(dogBreedListLoader: { callback in
                callback(.success([.anyBreed, .anyBreed, .anyBreed])) },
              catBreedListLoader: { callback in
                callback(.success([.anyBreed, .anyBreed, .anyBreed])) },
              dogImageListLoader: .stub,
              catImageListLoader: .stub,
              imageDataLoader: .stub)
    }
}
#endif
