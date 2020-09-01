//
//  AnimalBundle.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/09.
//

import SwiftUI
import WidgetKit

@main
struct AnimalBundle: WidgetBundle {
    private let client: HTTPClient = {
        let session = URLSession.shared
        return URLSessionHTTPClient(session: session)
    }()

    @WidgetBundleBuilder
    var body: some Widget {
        dogWidget
        catWidget
    }

    private var catWidget: CatGalleryWidget {
        var widget = CatGalleryWidget()

        widget.imageLoader = CatImageLoader(
            breedListLoader: CatBreedListLoader(client: client),
            imageListLoader: CatImageListLoader(client: client),
            imageDataLoader: ImageDataWebLoader(client: client))
        return widget
    }

    private var dogWidget: DogGalleryWidget {
        var widget = DogGalleryWidget()
        widget.imageLoader = DogImageLoader(
            imageDataLoader: .init(client: client),
            imageURLListLoader: .init(client: client),
            imageListLoader: .init(client: client)
        )
        return widget
    }
}
