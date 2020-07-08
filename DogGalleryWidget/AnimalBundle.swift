//
//  AnimalBundle.swift
//  DogGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/09.
//

import SwiftUI
import WidgetKit

@main
struct AnimalBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        DogGalleryWidget()
        CatGalleryWidget()
    }
}
