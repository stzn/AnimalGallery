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

    var breedName: String {
        if let index = name.firstIndex(of: "-") {
            return name.prefix(upTo: index).lowercased()
        }
        return name.lowercased()
    }
}

let snapshotImage = WidgetImage(name: "Loading...", image: Image(systemName: "clock"))
let placeholder = WidgetImage(name: "...", image: Image(uiImage: UIImage(named: "placeholder")!))
let errorImage = WidgetImage(name: "error", image: Image(systemName: "mic"))

