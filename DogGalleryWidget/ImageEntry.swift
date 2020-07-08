//
//  ImageEntry.swift
//  DogGalleryWidgetExtension
//
//  Created by Shinzan Takata on 2020/07/09.
//

import Foundation
import WidgetKit

struct ImageEntry: TimelineEntry {
    public var date: Date
    let nextDate: Date
    let image: WidgetImage
}

