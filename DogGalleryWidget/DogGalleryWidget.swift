//
//  DogGalleryWidget.swift
//  DogGalleryWidget
//
//  Created by Shinzan Takata on 2020/07/04.
//

import WidgetKit
import SwiftUI
import AudioToolbox

@main
struct DogGalleryWidget: Widget {
    private let kind: String = "DogGalleryWidget"

    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,
                            intent: DynamicBreedSelectionIntent.self,
                            provider: DogImageTimeline(),
                            placeholder: PlaceholderView()) { entry in
            DogGalleryWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Dog Image")
        .description("Have a break!")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct DogImageEntry: TimelineEntry {
    public var date: Date
    let nextDate: Date
    let dogImage: WidgetDogImage
}

struct DogImageTimeline: IntentTimelineProvider {
    typealias Intent = DynamicBreedSelectionIntent
    typealias Entry = DogImageEntry

    func snapshot(for configuration: Intent, with context: Context,
                  completion: @escaping (Entry) -> ()) {
        let currentDate = Date()
        let entry = Entry(date: currentDate,
                          nextDate: currentDate,
                          dogImage: snapshotImage)
        completion(entry)
    }

    func timeline(for configuration: Intent, with context: Context,
                  completion: @escaping (Timeline<Entry>) -> ()) {
        let identifier = configuration.intentBreed?.identifier ?? "random"
        let entryDate = Date()
        let refreshDate = Calendar.current.date(
            byAdding: .minute, value: 60, to: entryDate)!

        loadImage(for: identifier, entryDate: entryDate, refreshDate: refreshDate) { entry in
            completion(.init(entries: [entry], policy: .after(refreshDate)))
        }
    }

    private func loadImage(for identifier: String,
                           entryDate: Date,
                           refreshDate: Date,
                           completion: @escaping (Entry) -> Void) {
        if identifier == "random" {
            loadRandom { result in
                switch result {
                case .success(let image):
                    completion(.init(date: entryDate, nextDate: refreshDate, dogImage: image))
                case .failure:
                    completion(
                        Entry(date: entryDate, nextDate: refreshDate, dogImage: errorImage)
                    )
                }
            }
        } else {
            loadRandomInBreed(Breed(name: identifier)) { result in
                switch result {
                case .success(let image):
                    completion(.init(date: entryDate, nextDate: refreshDate, dogImage: image))
                case .failure:
                    completion(
                        Entry(date: entryDate, nextDate: refreshDate, dogImage: errorImage)
                    )
                }
            }
        }
    }

    private func loadRandom(completion: @escaping (Result<WidgetDogImage, Error>) -> Void) {
        DogImageLoader.loadRandom { result in
            switch result {
            case .success(let image):
                notifyUpdate()
                completion(
                    .success(image)
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func loadRandomInBreed(
        _ breed: Breed,
        completion: @escaping (Result<WidgetDogImage, Error>) -> Void) {
        DogImageLoader.loadRandomInBreed(breed) { result in
            switch result {
            case .success(let image):
                notifyUpdate()
                completion(
                    .success(image)
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


    private func notifyUpdate() {
        AudioServicesPlayAlertSoundWithCompletion(
            SystemSoundID(kSystemSoundID_Vibrate)) { }
    }
}
