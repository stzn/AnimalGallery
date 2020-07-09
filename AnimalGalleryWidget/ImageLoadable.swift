//
//  ImageLoadable.swift
//  AnimalGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/09.
//

import Foundation
import WidgetKit

protocol ImageLoadable {
    func loadImage(for identifier: String,
                   entryDate: Date,
                   refreshDate: Date,
                   completion: @escaping (ImageEntry) -> Void)
}

func makeEntry(from result: Result<WidgetImage, Error>,
                       entryDate: Date, refreshDate: Date) -> ImageEntry {
    switch result {
    case .success(let image):
        return ImageEntry(date: entryDate, nextDate: refreshDate, image: image)
    case .failure:
        return ImageEntry(date: entryDate, nextDate: refreshDate, image: errorImage)
    }
}
