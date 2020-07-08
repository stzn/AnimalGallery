//
//  PlaceholderView.swift
//  DogGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/06.
//

import SwiftUI

struct PlaceholderView : View {
    var body: some View {
        WidgetEntryView(
            entry: .init(date: Date(), nextDate: Date(), image: placeholder))
    }
}
