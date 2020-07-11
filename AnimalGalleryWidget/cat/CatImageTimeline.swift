//
//  CatImageTimeline.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/07/10.
//

import AVFoundation
import Foundation
import WidgetKit

struct CatImageTimeline: IntentTimelineProvider {
    typealias Intent = DynamicCatBreedSelectionIntent
    typealias Entry = ImageEntry

    private let imageLoader: ImageLoadable
    init(imageLoader: ImageLoadable) {
        self.imageLoader = imageLoader
    }

    func snapshot(for configuration: Intent, with context: Context,
                  completion: @escaping (Entry) -> ()) {
        let entryDate = Date()
        let refreshDate = Calendar.current.date(
            byAdding: .minute, value: 60, to: entryDate)!
        imageLoader.loadImage(for: "random", entryDate: entryDate, refreshDate: refreshDate) { entry in
            completion(entry)
        }
    }

    func timeline(for configuration: Intent, with context: Context,
                  completion: @escaping (Timeline<Entry>) -> ()) {
        let identifier = configuration.catBreed?.identifier ?? "random"
        let entryDate = Date()
        let refreshDate = Calendar.current.date(
            byAdding: .minute, value: 60, to: entryDate)!
        notifyUpdate()
        imageLoader.loadImage(for: identifier, entryDate: entryDate, refreshDate: refreshDate) { entry in
            completion(.init(entries: [entry], policy: .after(refreshDate)))
        }
    }

    private func notifyUpdate() {
        var soundIdRing: SystemSoundID = 0
        let soundURL = NSURL.fileURL(withPath: Bundle.main.path(forResource: "cat", ofType:"mp3")!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundIdRing)
        AudioServicesPlaySystemSound(soundIdRing)
    }
}

