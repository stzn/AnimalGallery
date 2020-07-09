//
//  ImageTimeline.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/09.
//

import AVFoundation
import Foundation
import WidgetKit

struct ImageTimeline: IntentTimelineProvider {
    typealias Intent = DynamicBreedSelectionIntent
    typealias Entry = ImageEntry

    private let animaltype: AnimalType
    private let imageLoader: ImageLoadable
    init(animaltype: AnimalType, imageLoader: ImageLoadable) {
        self.animaltype = animaltype
        self.imageLoader = imageLoader
    }

    func snapshot(for configuration: Intent, with context: Context,
                  completion: @escaping (Entry) -> ()) {
        let currentDate = Date()

        let placeholder: WidgetImage
        switch animaltype {
        case .dog:
            placeholder = dogPlaceholder
        case .cat:
            placeholder = catPlaceholder
        }

        let entry = Entry(date: currentDate,
                          nextDate: currentDate,
                          image: placeholder)
        completion(entry)
    }

    func timeline(for configuration: Intent, with context: Context,
                  completion: @escaping (Timeline<Entry>) -> ()) {
        let identifier = configuration.intentBreed?.identifier ?? "random"
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
        let soundURL: URL
        switch animaltype {
        case .dog:
            soundURL = NSURL.fileURL(withPath: Bundle.main.path(forResource: "dog", ofType:"mp3")!)
        case .cat:
            soundURL = NSURL.fileURL(withPath: Bundle.main.path(forResource: "cat", ofType:"mp3")!)
        }
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundIdRing)
        AudioServicesPlaySystemSound(soundIdRing)
    }
}

