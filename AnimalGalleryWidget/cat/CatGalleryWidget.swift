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

    var client: HTTPClient!
    
    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: DynamicCatBreedSelectionIntent.self,
                            provider: CatImageTimeline(imageLoader: CatImageLoader(client: client)),
                            placeholder: PlaceholderView(type: .cat)) { entry in
            WidgetEntryView(type: .cat, entry: entry)
        }
        .configurationDisplayName("Cat Image")
        .description("Have a break!")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
