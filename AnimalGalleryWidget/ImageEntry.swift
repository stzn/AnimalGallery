//
//  ImageEntry.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/09.
//

import Foundation
import WidgetKit

struct ImageEntry: TimelineEntry {
    var date: Date
    let nextDate: Date
    let images: [WidgetImage]
}

func makeEntry(from result: Result<[WidgetImage], Error>,
                       entryDate: Date, refreshDate: Date) -> ImageEntry {
    switch result {
    case .success(let images):
        return ImageEntry(date: entryDate, nextDate: refreshDate, images: images)
    case .failure:
        return ImageEntry(date: entryDate, nextDate: refreshDate, images: [errorImage])
    }
}
