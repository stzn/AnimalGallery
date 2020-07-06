//
//  DogGalleryWidgetEntryView.swift
//  DogGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/06.
//

import SwiftUI
import WidgetKit

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
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                    VStack {
                        nameText
                        timeLeftText
                    }
                    .padding()
                }
            }
            .widgetURL(URL(string: "dogs:///\(entry.dogImage.name.lowercased())")!)
        default:
            ZStack(alignment: .bottom) {
                Color.white
                entry.dogImage.image
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                VStack(spacing: 0) {
                    nameText
                    timeLeftText
                }
                .padding()
            }
            .widgetURL(URL(string: "dogs:///\(entry.dogImage.name.lowercased())")!)
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
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
        default:
            return LeftTimeTextView(date: entry.nextDate, style: .timer, width: 1, color: .white)
                .foregroundColor(.black)
                .font(.largeTitle)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
        }
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
