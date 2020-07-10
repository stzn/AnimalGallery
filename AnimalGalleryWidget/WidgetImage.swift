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
    var widgetURLKey: String
}

var anyID: String {
    UUID().uuidString
}

var anyKey: String {
    UUID().uuidString
}

let dogPlaceholder = WidgetImage(id: anyID, name: "...", image: Image("dog"), widgetURLKey: anyKey)
let catPlaceholder = WidgetImage(id: anyID, name: "...", image: Image("cat"), widgetURLKey: anyKey)
let errorImage = WidgetImage(id: anyID, name: "error", image: Image(systemName: "mic"), widgetURLKey: anyKey)

