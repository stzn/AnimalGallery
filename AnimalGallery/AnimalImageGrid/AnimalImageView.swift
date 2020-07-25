//
//  AnimalImage.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/07/04.
//

import SwiftUI

final class AnimalImageViewModel: ObservableObject {
    @Published var imageData: Data? = nil
    @Published var error: Error? = nil
    var task: HTTPClientTask?

    deinit {
        cancel()
    }

    func loadImageData(from url: URL, using loader: ImageDataLoader) {
        task = loader.load(url) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let data):
                    self?.imageData = data
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }

    func cancel() {
        task?.cancel()
    }
}

struct AnimalImageView: View {
    @Environment(\.injected) var container: DIContainer
    @StateObject var model = AnimalImageViewModel()

    private let image: AnimalImage

    init(image: AnimalImage) {
        self.image = image
    }

    var body: some View {
        content
            .onAppear {
                model.loadImageData(from: image.imageURL,
                                    using: container.loaders.imageDataLoader)
            }
    }

    private var content: some View {
        Group {
            switch (model.imageData, model.error) {
            case (.none, .none):
                ProgressView("loading.....")
            case (let .some(data), .none):
                Image(uiImage: UIImage(data: data)!)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()
            default:
                Image(systemName: "xmark.octagon.fill")
            }
        }
    }
}

struct AnimalImageView_Previews: PreviewProvider {
    static var previews: some View {
        AnimalImageView(image: .anyAnimalImage)
    }
}

