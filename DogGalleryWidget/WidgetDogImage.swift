//
//  WidgetDogImage.swift
//  DogGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/06.
//

import SwiftUI

struct WidgetDogImage {
    var name: String
    var image: Image

    var breedName: String {
        if let index = name.firstIndex(of: "-") {
            return name.prefix(upTo: index).lowercased()
        }
        return name.lowercased()
    }
}

let snapshotImage = WidgetDogImage(name: "Loading...", image: Image(systemName: "clock"))
let placeholder = WidgetDogImage(name: "...", image: Image(uiImage: UIImage(named: "placeholder")!))
let errorImage = WidgetDogImage(name: "error", image: Image(systemName: "mic"))

