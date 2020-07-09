//
//  AnimalGalleryWidget.swift
//  AnimalGalleryWidget
//
//  Created by Shinzan Takata on 2020/07/04.
//

import WidgetKit
import SwiftUI

struct AnimalGalleryWidget: Widget {
    private let kind: String = "AnimalGalleryWidget"

    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: DynamicBreedSelectionIntent.self,
                            provider: ImageTimeline(animaltype: .dog,
                                                    imageLoader: DogImageLoader()),
                            placeholder: PlaceholderView(type: .dog)) { entry in
            WidgetEntryView(type: .dog, entry: entry)
        }
        .configurationDisplayName("Dog Image")
        .description("Have a break!")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
