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
}

let placeholder = WidgetDogImage(name: "sample", image: Image(uiImage: UIImage(named: "placeholder")!))
let errorImage = WidgetDogImage(name: "error", image: Image(systemName: "mic"))

