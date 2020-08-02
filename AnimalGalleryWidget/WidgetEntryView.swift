//
//  WidgetEntryView.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/09.
//

import SwiftUI
import WidgetKit

struct WidgetEntryView : View {
    let type: AnimalType
    var entry: ImageEntry

    @Environment(\.widgetFamily) var family

    var columns: [GridItem] {
        [GridItem](repeating: GridItem(.flexible(minimum: 20), spacing: 10), count: 2)
    }

    var body: some View {
        switch family {
        case .systemSmall:
            systemSmall
        case .systemMedium:
            systemMedium
        case .systemLarge:
            systemLarge
        @unknown default:
            fatalError()
        }
    }

    @ViewBuilder
    private var systemSmall: some View {
        if let image = entry.images.first {
            ZStack(alignment: .bottom) {
                image.image
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .placeholderWhenRedacted()
                timeLeftText
            }
            .widgetURL(widgetURL(image.widgetURLKey))
        } else {
            ZStack(alignment: .bottom) {
                Image(systemName: "mic.fill")
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .placeholderWhenRedacted()
                timeLeftText
            }
        }
    }

    private var systemMedium: some View {
        ZStack {
            BubbleBackground()
            HStack {
                makeImageList(2)
                timeLeftText.padding(.leading, 10)
            }
            .padding()
        }
    }

    private var systemLarge: some View {
        ZStack {
            BubbleBackground()
            LazyVGrid(columns: columns) {
                makeImageList(3)
                timeLeftText.padding()
            }
            .padding()
        }
    }

    private func makeImageList(_ count: Int) -> some View {
        ForEach(entry.images.prefix(count)) { image in
            image.image
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .clipped()
                .placeholderWhenRedacted()
                .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 4))
                .widgetURL(widgetURL(image.widgetURLKey))
        }
    }

    private func widgetURL(_ key: String) -> URL {
        switch type {
        case .dog:
            return URL(string: "\(type.deepLinkScheme):///\(dogURLName(key))")!
        case .cat:
            return URL(string: "\(type.deepLinkScheme):///\(key)")!
        }
    }

    private func dogURLName(_ key: String) -> String {
        let urlName = key.replacingOccurrences(of: " ", with: "")
        if let index = urlName.firstIndex(of: "-") {
            return urlName.prefix(upTo: index).lowercased()
        }
        return urlName.lowercased()
    }

    private var timeLeftText: some View {
        let style: Font.TextStyle
        switch family {
        case .systemSmall:
            style = .body
        case .systemMedium:
            style = .title3
        case .systemLarge:
            style = .largeTitle
        @unknown default:
            fatalError()
        }

        return
            LeftTimeTextView(
                date: entry.nextDate,
                style: .timer, width: 1, color: .white)
            .foregroundColor(.black)
            .lineLimit(1)
            .fixedSize()
            .font(.system(style, design: .monospaced))
            .minimumScaleFactor(0.1)
    }
}

private extension View {
    func placeholderWhenRedacted() -> some View {
        whenRedacted {
            $0.hidden().background(Color.gray)
        }
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetEntryView(type: .dog,
                            entry: createEntry(1))
                .redacted(reason: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            WidgetEntryView(type: .dog,
                            entry: createEntry(2))
                .redacted(reason: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            WidgetEntryView(type: .dog,
                            entry: createEntry(3))
                .redacted(reason: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }

    private static func createEntry(_ count: Int) -> ImageEntry {
        .init(date: Date(),
              nextDate: Date(),
              images: [WidgetImage](repeating: catPlaceholder,
                                    count: count))
    }
}
