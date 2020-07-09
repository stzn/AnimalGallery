//
//  AnimalType.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/07/09.
//

private let prefix = "animalgallery-"

enum AnimalType: String {
    case dog = "Dog"
    case cat = "Cat"

    var deepLinkScheme: String {
        return "\(prefix)\(rawValue)"
    }

    init?(from scheme: String) {
        let rawValue = scheme.replacingOccurrences(of: prefix, with: "")
        guard let type = Self(rawValue: rawValue) else {
            return nil
        }
        self = type
    }
}

