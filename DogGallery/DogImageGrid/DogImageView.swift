//
//  DogImage.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/07/04.
//

import SwiftUI

final class DogImageViewModel: ObservableObject {
    @Published var imageData: Data? = nil
    @Published var error: Error? = nil
    var task: HTTPClientTask?

    deinit {
        cancel()
    }

    func loadImageData(from url: URL, using loader: ImageDataLoader) {
        task = loader.load(from: url) { result in
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

struct DogImageView: View {
    @StateObject var model = DogImageViewModel()

    private let dogImage: DogImage
    private let loader: ImageDataLoader

    init(imageDataLoader: ImageDataLoader, dogImage: DogImage) {
        self.dogImage = dogImage
        self.loader = imageDataLoader
    }

    var body: some View {
        content
            .onAppear {
                model.loadImageData(
                    from: dogImage.imageURL, using: loader)
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

struct DogImageView_Previews: PreviewProvider {
    static var previews: some View {
        DogImageView(imageDataLoader: StubImageDataLoader(),
                     dogImage: .anyDogImage)
    }
}

