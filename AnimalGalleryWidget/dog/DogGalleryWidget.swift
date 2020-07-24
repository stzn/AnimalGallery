//
//  DogGalleryWidget.swift
//  DogGalleryWidget
//
//  Created by Shinzan Takata on 2020/07/04.
//

import WidgetKit
import SwiftUI

struct DogGalleryWidget: Widget {
    private let kind: String = "DogGalleryWidget"

    var client: HTTPClient!

    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: DynamicDogBreedSelectionIntent.self,
                            provider: DogImageTimeline(imageLoader: DogImageLoader(client: client))) { entry in
            WidgetEntryView(type: .dog, entry: entry)
        }
        .configurationDisplayName("Dog Image")
        .description("Have a break!")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
