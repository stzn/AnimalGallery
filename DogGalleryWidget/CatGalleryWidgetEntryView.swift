//
//  CatGalleryWidgetEntryView.swift
//  DogGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/08.
//

import SwiftUI
import WidgetKit

struct CatGalleryWidgetEntryView : View {
    var entry: CatImageTimeline.Entry

    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemMedium:
            ZStack {
                Color.white
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
            .widgetURL(URL(string: "dogs:///\(entry.dogImage.breedName)")!)
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
            .widgetURL(URL(string: "dogs:///\(entry.dogImage.breedName)")!)
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
                .font(.system(.body, design: .monospaced))
        default:
            return LeftTimeTextView(date: entry.nextDate, style: .timer, width: 1, color: .white)
                .foregroundColor(.black)
                .font(.system(.largeTitle, design: .monospaced))
        }
    }
}

struct CatGalleryWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CatGalleryWidgetEntryView(entry: .init(date: Date(), nextDate: Date(), dogImage: placeholder))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
