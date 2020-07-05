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
    let nextDate: Date = Calendar.current.date(byAdding: .minute, value: 60, to: Date())!
    let dogImage: WidgetDogImage
}

struct DogImageTimeline: IntentTimelineProvider {
    typealias Intent = DynamicBreedSelectionIntent
    typealias Entry = DogImageEntry

    func snapshot(for configuration: Intent, with context: Context,
                  completion: @escaping (Entry) -> ()) {
        let entry = Entry(date: Date(), dogImage: placeholder)
        completion(entry)
    }

    func timeline(for configuration: Intent, with context: Context,
                  completion: @escaping (Timeline<Entry>) -> ()) {
        let identifier = configuration.intentBreed?.identifier ?? "random"
        let entryDate = Date()
        let refreshDate = Calendar.current.date(
            byAdding: .minute, value: 60, to: entryDate)!

        if identifier == "random" {
            loadRandom(entryDate: entryDate) { result in
                switch result {
                case .success(let entry):
                    completion(
                        .init(entries: [entry], policy: .after(refreshDate))
                    )
                case .failure:
                    let error = Entry(date: entryDate, dogImage: errorImage)
                    completion(
                        .init(entries: [error], policy: .atEnd)
                    )
                }
            }
        } else {
            loadRandomInBreed(breed: Breed(name: identifier),
                              entryDate: entryDate) { result in
                switch result {
                case .success(let entry):
                    completion(
                        .init(entries: [entry], policy: .after(refreshDate))
                    )
                case .failure:
                    let error = Entry(date: entryDate, dogImage: errorImage)
                    completion(
                        .init(entries: [error], policy: .atEnd)
                    )
                }
            }
        }
    }

    private func loadRandom(entryDate: Date,
                            completion: @escaping (Result<Entry, Error>) -> Void) {
        DogImageLoader.loadRandom { result in
            switch result {
            case .success(let image):
                notifyUpdate()
                completion(
                    .success(Entry(date: entryDate, dogImage: image))
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func loadRandomInBreed(breed: Breed, entryDate: Date,
                                   completion: @escaping (Result<Entry, Error>) -> Void) {
        DogImageLoader.loadRandomInBreed(breed) { result in
            switch result {
            case .success(let image):
                notifyUpdate()
                completion(
                    .success(Entry(date: entryDate, dogImage: image))
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
