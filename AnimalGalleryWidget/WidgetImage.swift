//
//  WidgetImage.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/09.
//

import SwiftUI

struct WidgetImage: Identifiable {
    var id: String
    var name: String
    var image: Image
}

var anyID: String {
    UUID().uuidString
}

let dogPlaceholder = WidgetImage(id: anyID, name: "...", image: Image("dog"))
let catPlaceholder = WidgetImage(id: anyID, name: "...", image: Image("cat"))
let errorImage = WidgetImage(id: anyID, name: "error", image: Image(systemName: "mic"))

