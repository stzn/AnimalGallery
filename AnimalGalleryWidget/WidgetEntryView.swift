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

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemMedium:
            ZStack {
                Color.white
                HStack {
                    entry.image.image
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                    VStack {
                        timeLeftText
                    }
                    .padding()
                }
            }
            .widgetURL(widgetURL)
        default:
            ZStack(alignment: .bottom) {
                Color.white
                entry.image.image
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                VStack(spacing: 0) {
                    timeLeftText
                }
            }
            .widgetURL(widgetURL)
        }
    }

    private var widgetURL: URL {
        switch type {
        case .dog:
            return URL(string: "\(type.deepLinkScheme):///\(dogURLName)")!
        case .cat:
            return URL(string: "\(type.deepLinkScheme):///\(catURLName)")!
        }
    }

    private var dogURLName: String {
        let name = entry.image.name.replacingOccurrences(of: " ", with: "")
        if let index = name.firstIndex(of: "-") {
            return name.prefix(upTo: index).lowercased()
        }
        return name.lowercased()
    }

    private var catURLName: String {
        let name = entry.image.name.replacingOccurrences(of: " ", with: "-")
        return name.lowercased()
    }

    private var timeLeftText: some View {
        switch family {
        case .systemSmall:
            return LeftTimeTextView(
                date: entry.nextDate,
                style: .timer, width: 1, color: .white)
                .foregroundColor(.black)
                .font(.system(.body, design: .monospaced))
        default:
            return LeftTimeTextView(date: entry.nextDate, style: .timer, width: 1, color: .white)
                .foregroundColor(.black)
                .font(.system(.largeTitle, design: .monospaced))
        }
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetEntryView(type: .dog,
                            entry: .init(date: Date(), nextDate: Date(), image: dogPlaceholder))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
