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

//let snapshotImage = WidgetImage(name: "Loading...", image: Image(systemName: "clock").resizable())
let dogPlaceholder = WidgetImage(name: "...", image: Image(uiImage: UIImage(named: "dog")!))
let catPlaceholder = WidgetImage(name: "...", image: Image(uiImage: UIImage(named: "cat")!))
let errorImage = WidgetImage(name: "error", image: Image(systemName: "mic"))

