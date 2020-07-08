//
//  ImageTimeline.swift
//  DogGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/09.
//

import AudioToolbox
import Foundation
import WidgetKit

protocol ImageLoadable {
    func loadImage(for identifier: String,
                   entryDate: Date,
                   refreshDate: Date,
                   completion: @escaping (ImageEntry) -> Void)
}

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
        let entry = Entry(date: currentDate,
                          type: animaltype,
                          nextDate: currentDate,
                          image: snapshotImage)
        completion(entry)
    }

    func timeline(for configuration: Intent, with context: Context,
                  completion: @escaping (Timeline<Entry>) -> ()) {
        let identifier = configuration.intentBreed?.identifier ?? "random"
        let entryDate = Date()
        let refreshDate = Calendar.current.date(
            byAdding: .minute, value: 60, to: entryDate)!

        imageLoader.loadImage(for: identifier, entryDate: entryDate, refreshDate: refreshDate) { entry in
            completion(.init(entries: [entry], policy: .after(refreshDate)))
        }
    }

    private func notifyUpdate() {
        AudioServicesPlayAlertSoundWithCompletion(
            SystemSoundID(kSystemSoundID_Vibrate)) { }
    }
}

