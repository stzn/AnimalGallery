//
//  PlaceholderView.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/06.
//

import SwiftUI
import WidgetKit

struct PlaceholderView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily

    private let animalType: AnimalType
    init(type: AnimalType) {
        self.animalType = type
    }
    var body: some View {
        switch animalType {
        case .dog:
            entryView(dogPlaceholder)
        case .cat:
            entryView(catPlaceholder)
        }
    }

    private func entryView(_ placeholder: WidgetImage) -> WidgetEntryView {
        var widgetImages: [WidgetImage] = []
        switch family {
        case .systemSmall:
            widgetImages = [WidgetImage](repeating: placeholder, count: 1)
        case .systemMedium:
            widgetImages = [WidgetImage](repeating: placeholder, count: 2)
        case .systemLarge:
            widgetImages = [WidgetImage](repeating: placeholder, count: 3)
        @unknown default:
            fatalError()
        }
        return
            WidgetEntryView(
                type: animalType,
                entry: .init(date: Date(),
                         nextDate: Date(),
                         images: widgetImages))
    }
}
