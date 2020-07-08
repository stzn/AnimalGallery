//
//  WidgetEntryView.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/09.
//

import SwiftUI
import WidgetKit

struct WidgetEntryView : View {
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
                        nameText
                        timeLeftText
                    }
                    .padding()
                }
            }
            .widgetURL(entry.widgetURL)
        default:
            ZStack(alignment: .bottom) {
                Color.white
                entry.image.image
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                VStack(spacing: 0) {
                    nameText
                    timeLeftText
                }
                .padding()
            }
            .widgetURL(entry.widgetURL)
        }
    }

    private var nameText: some View {
        switch family {
        case .systemSmall:
            return StrokeText(text: entry.image.name,
                       width: 1, color: .white)
                .foregroundColor(.black)
                .font(.body)
        default:
            return StrokeText(text: entry.image.name,
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
            WidgetEntryView(entry: .init(date: Date(), type: .dog, nextDate: Date(), image: placeholder))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
