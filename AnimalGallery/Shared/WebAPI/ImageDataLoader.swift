//
//  ImageDataLoader.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/02/27.
//  Copyright © 2020 shiz. All rights reserved.
//

import Foundation
import UIKit

struct ImageDataLoader {
    let load: (URL, @escaping (Result<Data, Error>) -> Void) -> HTTPClientTask
}

#if DEBUG
final class StubTask: HTTPClientTask {
    func cancel() {
    }
}

extension ImageDataLoader {
    static var stub = ImageDataLoader { _, callback in
        callback(.success(UIImage(systemName: "tray")!.pngData()!))
        return StubTask()
    }
}
#endif
