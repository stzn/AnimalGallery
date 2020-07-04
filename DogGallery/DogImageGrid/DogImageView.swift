//
//  DogImage.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/07/04.
//

import Combine
import SwiftUI

final class DogImageViewModel: ObservableObject {
    @Published var imageData: Data? = nil
    @Published var error: Error? = nil

    private var cancellables = Set<AnyCancellable>()
    func loadImageData(from url: URL, loader: ImageDataLoader) {
        loader.load(from: url)
            .receive(on: DispatchQueue.main)
            .sink { finished in
                if case .failure(let error) = finished {
                    self.error = error
                }
            } receiveValue: { value in
                self.imageData = value
            }
            .store(in: &cancellables)
    }
}

struct DogImageView: View {
    @ObservedObject var model = DogImageViewModel()

    let imageDataLoader: ImageDataLoader
    let dogImage: DogImage

    var body: some View {
        content
            .onAppear {
                model.loadImageData(from: dogImage.imageURL,
                                    loader: imageDataLoader)
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
                Image(uiImage: UIImage(systemName: "xmark.octagon.fill")!)
            }
        }
    }
}

struct DogImageView_Previews: PreviewProvider {
    static var previews: some View {
        DogImageView(imageDataLoader: StubImageDataLoader(),
                     dogImage: DogImage.anyDogImage)
    }
}

