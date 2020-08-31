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
typealias AnimalImageListLoader = (BreedType?, @escaping (Result<[AnimalImage], Error>) -> Void) -> Void

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

            let dogListLoader = DogBreedListLoader(client: client)

            let catListLoader = CatBreedListLoader(client: client)
            
            let dogImageListLoader = RemoteImageListLoader(
                client: client,
                requestBuilder: { breedType in
                    URLRequest(url: dogAPIbaseURL.appendingPathComponent("/breed/\(breedType!)/images"))
                },
                mapper: DogImageListMapper.map)

            let catImageListLoader = RemoteImageListLoader(
                client: client,
                requestBuilder: { breedType in
                    CatAPIURLRequestFactory.makeURLRequest(
                            from: catImageListAPIURL,
                            queryItems: [URLQueryItem(name: "breed_id", value: breedType)])
                },
                mapper: CatImageListMapper.map)

            let imageWebLoader = ImageDataWebLoader(client: client)

            return .init(dogBreedListLoader: dogListLoader.load(completion:),
                         catBreedListLoader: catListLoader.load(completion:),
                         dogImageListLoader: dogImageListLoader.load(of:completion:),
                         catImageListLoader: catImageListLoader.load(of:completion:),
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
              dogImageListLoader: { _, callback in
                callback(.success([.anyAnimalImage, .anyAnimalImage, .anyAnimalImage]))
              },
              catImageListLoader: { _, callback in
                callback(.success([.anyAnimalImage, .anyAnimalImage, .anyAnimalImage]))
              },
              imageDataLoader: .stub)
    }
}
#endif
