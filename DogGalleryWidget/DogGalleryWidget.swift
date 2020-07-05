//
//  DogGalleryWidget.swift
//  DogGalleryWidget
//
//  Created by Shinzan Takata on 2020/07/04.
//

import WidgetKit
import SwiftUI
import AudioToolbox

struct PlaceholderView : View {
    var body: some View {
        DogGalleryWidgetEntryView(
            entry: .init(date: Date(), dogImage: placeholder))
    }
}

struct DogGalleryWidgetEntryView : View {
    var entry: DogImageTimeline.Entry

    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemMedium:
            ZStack {
                Color.gray
                HStack {
                    entry.dogImage.image
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(10)
                        .padding()
                    VStack {
                        nameText
                        timeLeftText
                    }
                    .padding()
                }
            }
        default:
            ZStack(alignment: .center) {
                Color.white
                entry.dogImage.image
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                VStack {
                    Spacer()
                    nameText
                    timeLeftText
                }
                .padding(.bottom)
            }
        }
    }

    private var nameText: some View {
        switch family {
        case .systemSmall:
            return StrokeText(text: entry.dogImage.name,
                       width: 1, color: .white)
                .foregroundColor(.black)
                .font(.body)
        default:
            return StrokeText(text: entry.dogImage.name,
                       width: 1, color: .white)
                .foregroundColor(.black)
                .font(.largeTitle)
        }
    }

    private var timeLeftText: some View {
        switch family {
        case .systemSmall:
            return LeftTimeTextView(
                date: entry.nextDate,
                style: .timer, width: 1, color: .white)
                .foregroundColor(.black)
                .font(.body)
        default:
            return LeftTimeTextView(date: entry.nextDate, style: .timer, width: 1, color: .white)
                .foregroundColor(.black)
                .font(.largeTitle)
        }
    }
}

@main
struct DogGalleryWidget: Widget {
    private let kind: String = "DogGalleryWidget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DogImageTimeline(), placeholder: PlaceholderView()) { entry in
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

private let placeholder = WidgetDogImage(name: "sample", image: Image(uiImage: UIImage(named: "placeholder")!))
private let error = WidgetDogImage(name: "error", image: Image(systemName: "mic"))

struct DogImageTimeline: TimelineProvider {
    typealias Entry = DogImageEntry

    func snapshot(with context: Context, completion: @escaping (DogImageEntry) -> ()) {
        let entry = DogImageEntry(date: Date(), dogImage: placeholder)
        completion(entry)
    }

    func timeline(with context: Context, completion: @escaping (Timeline<DogImageEntry>) -> ()) {
        let entryDate = Date()
        let refreshDate = Calendar.current.date(
            byAdding: .minute, value: 60, to: entryDate)!
        RandomDogImageLoader.loadRandom { result in
            switch result {
            case .success(let image):
                notifyUpdate()
                completion(
                    .init(entries: [.init(date: entryDate, dogImage: image)],
                          policy: .after(refreshDate))
                )
            case .failure:
                completion(
                    .init(entries: [.init(date: entryDate, dogImage: error)],
                          policy: .atEnd))
            }
        }
    }

    private func notifyUpdate() {
        AudioServicesPlayAlertSoundWithCompletion(
            SystemSoundID(kSystemSoundID_Vibrate)) { }
    }
}


struct DogGalleryWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DogGalleryWidgetEntryView(entry: .init(date: Date(), dogImage: placeholder))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
