//
//  CatGalleryWidget.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/08.
//

import WidgetKit
import SwiftUI

struct CatGalleryWidget: Widget {
    private let kind: String = "CatGalleryWidget"

    var imageLoader: CatImageLoader!

    public var body: some WidgetConfiguration {
        return IntentConfiguration(kind: kind,
                            intent: DynamicCatBreedSelectionIntent.self,
                            provider: CatImageTimeline(imageLoader: imageLoader)) { entry in
            WidgetEntryView(type: .cat, entry: entry)
        }
        .configurationDisplayName("Cat Image")
        .description("Have a break!")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
