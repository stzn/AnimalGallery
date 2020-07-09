//
//  WidgetImage.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/09.
//

import SwiftUI

struct WidgetImage {
    var name: String
    var image: Image
}

extension WidgetImage: Identifiable {
    var id: String { name }
}

let dogPlaceholder = WidgetImage(name: "...", image: Image("dog"))
let catPlaceholder = WidgetImage(name: "...", image: Image("cat"))
let errorImage = WidgetImage(name: "error", image: Image(systemName: "mic"))

