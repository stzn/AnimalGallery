//
//  String+.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/07/04.
//

import Foundation

extension String {
    var firstLetterCapitalized: String {
        prefix(1).capitalized + dropFirst()
    }
}
