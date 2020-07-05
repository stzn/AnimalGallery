//
//  HTTPClientError.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/03/09.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation

enum HTTPClientError : Error {
    case unhandledResponse
    case invalidResponse(URLResponse?)
    case requestError(Int)
    case serverError(Int)
    case noData
    case unknown(Error)

}

extension HTTPClientError {
    static func error(from response: HTTPURLResponse) -> HTTPClientError? {
        switch response.statusCode {
        case 200...299:
            return nil
        case 400...499:
            return .requestError(response.statusCode)
        case 500...599:
            return .serverError(response.statusCode)
        default:
            return .unhandledResponse
        }
    }
}
