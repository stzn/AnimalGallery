//
//  CatGalleryWidget.swift
//  DogGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/08.
//

import WidgetKit
import SwiftUI

struct CatGalleryWidget: Widget {
    private let kind: String = "CatGalleryWidget"

    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: DynamicBreedSelectionIntent.self,
                            provider: ImageTimeline(imageLoader: CatImageLoader()),
                            placeholder: PlaceholderView()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Cat Image")
        .description("Have a break!")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
