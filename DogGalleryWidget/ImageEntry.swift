//
//  ImageEntry.swift
//  DogGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/09.
//

import Foundation
import WidgetKit

enum AnimalType {
    case dog
    case cat
}

struct ImageEntry: TimelineEntry {
    public var date: Date
    let type: AnimalType
    let nextDate: Date
    let image: WidgetImage

    var widgetURL: URL {
        switch type {
        case .dog:
            return URL(string: "dogs:///\(image.breedName)")!
        case .cat:
            return URL(string: "cats:///\(image.breedName)")!
        }
    }
}

