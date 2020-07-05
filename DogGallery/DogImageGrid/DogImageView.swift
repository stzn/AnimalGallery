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

    func loadImageData(from url: URL, loader: ImageDataLoader) -> HTTPClientTask {
        loader.load(from: url) { result in
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
}

struct DogImageView: View {
    @ObservedObject var model = DogImageViewModel()
    @Binding var tasks: [HTTPClientTask]

    let imageDataLoader: ImageDataLoader
    let dogImage: DogImage

    var body: some View {
        content
            .onAppear {
                let task = model.loadImageData(
                    from: dogImage.imageURL, loader: imageDataLoader)
                tasks.append(task)
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
        DogImageView(tasks: .constant([]),
                     imageDataLoader: StubImageDataLoader(),
                     dogImage: DogImage.anyDogImage)
    }
}

