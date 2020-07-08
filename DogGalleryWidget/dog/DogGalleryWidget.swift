//
//  DogGalleryWidget.swift
//  DogGalleryWidget
//
//  Created by Shinzan Takata on 2020/07/04.
//

import WidgetKit
import SwiftUI
import AudioToolbox

struct DogGalleryWidget: Widget {
    private let kind: String = "DogGalleryWidget"

    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: DynamicBreedSelectionIntent.self,
                            provider: ImageTimeline(imageLoader: DogImageLoader()),
                            placeholder: PlaceholderView()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Dog Image")
        .description("Have a break!")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct DogImageEntry: TimelineEntry {
    public var date: Date
    let nextDate: Date
    let dogImage: WidgetImage
}
