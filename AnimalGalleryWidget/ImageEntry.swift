//
//  ImageEntry.swift
//  AnimalGalleryWidgetExtension
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
    var date: Date
    let type: AnimalType
    let nextDate: Date
    let image: WidgetImage

    var widgetURL: URL {
        switch type {
        case .dog:
            return URL(string: "dogs:///\(dogURLName)")!
        case .cat:
            return URL(string: "cats:///\(catURLName)")!
        }
    }

    private var dogURLName: String {
        let name = image.name.replacingOccurrences(of: " ", with: "")
        if let index = name.firstIndex(of: "-") {
            return name.prefix(upTo: index).lowercased()
        }
        return name.lowercased()
    }

    private var catURLName: String {
        let name = image.name.replacingOccurrences(of: " ", with: "-")
        return name.lowercased()
    }
}

