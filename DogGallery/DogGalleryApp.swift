//
//  DogGalleryApp.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/07/04.
//

import SwiftUI

@main
struct DogGalleryApp: App {
    private var container = DIContainer.defaultValue

    var body: some Scene {
        WindowGroup {
            BreedListView()
                .environment(\.injected, container)
        }
    }
}
