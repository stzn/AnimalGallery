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
    var entry: ImageTimeline.Entry

    @Environment(\.widgetFamily) var family

    var columns: [GridItem] {
        [GridItem](repeating: GridItem(.flexible(minimum: 20), spacing: 10), count: 2)
    }

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            ZStack(alignment: .bottom) {
                entry.images[0].image
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                timeLeftText
            }
            .widgetURL(widgetURL(entry.images[0].name))
        case .systemMedium:
            ZStack {
                BubbleBackground()
                HStack {
                    makeImageList(2)
                    timeLeftText.padding(.leading, 10)
                }
                .padding()
            }
        case .systemLarge:
            ZStack {
                BubbleBackground()
                LazyVGrid(columns: columns) {
                    makeImageList(3)
                    timeLeftText.padding()
                }
                .padding()
            }
        @unknown default:
            fatalError()
        }
    }

    private func makeImageList(_ count: Int) -> some View {
        ForEach(entry.images.prefix(count)) { image in
            image.image
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .clipped()
                .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 4))
                .widgetURL(widgetURL(image.name))
        }
    }

    private func widgetURL(_ name: String) -> URL {
        switch type {
        case .dog:
            return URL(string: "\(type.deepLinkScheme):///\(dogURLName(name))")!
        case .cat:
            return URL(string: "\(type.deepLinkScheme):///\(catURLName(name))")!
        }
    }

    private func dogURLName(_ name: String) -> String {
        let urlName = name.replacingOccurrences(of: " ", with: "")
        if let index = urlName.firstIndex(of: "-") {
            return urlName.prefix(upTo: index).lowercased()
        }
        return urlName.lowercased()
    }

    private func catURLName(_ name: String) -> String {
        let urlName = name.replacingOccurrences(of: " ", with: "-")
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

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetEntryView(type: .dog,
                            entry: createEntry(1))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            WidgetEntryView(type: .dog,
                            entry: createEntry(2))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            WidgetEntryView(
                type: .dog,
                entry: createEntry(3))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }

    private static func createEntry(_ count: Int) -> ImageEntry {
        .init(date: Date(),
              nextDate: Date(),
              images: [WidgetImage](repeating: catPlaceholder, count: count))
    }
}
