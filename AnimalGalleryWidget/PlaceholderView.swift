//
//  PlaceholderView.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/06.
//

import SwiftUI

struct PlaceholderView : View {
    private let animalType: AnimalType
    init(type: AnimalType) {
        self.animalType = type
    }
    var body: some View {
        switch animalType {
        case .dog:
            WidgetEntryView(
                type: animalType,
                entry: .init(date: Date(),
                             nextDate: Date(),
                             image: dogPlaceholder))
        case .cat:
            WidgetEntryView(
                type: animalType,
                entry: .init(date: Date(),
                             nextDate: Date(),
                             image: catPlaceholder))
        }
    }
}
