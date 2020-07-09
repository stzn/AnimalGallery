//
//  AnimalImageGridView.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/07/04.
//

import Combine
import SwiftUI

private let columns = [
    GridItem(.adaptive(minimum: 100, maximum: 200))
]

final class AnimalImageGridViewModel: ObservableObject {
    @Published var images: [AnimalImage] = []
    @Published var error: Error? = nil
    
    func loadBreeds(of type: BreedType,
                    imageListLoader: AnimalImageListLoader) {
        imageListLoader.load(of: type) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let images):
                    self?.images = images
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
}

struct AnimalImageGridView: View {
    @StateObject var model = AnimalImageGridViewModel()

    let breed: Breed
    let imageListLoader: AnimalImageListLoader
    let imageDataLoader: ImageDataLoader

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(model.images) {
                    AnimalImageView(imageDataLoader: imageDataLoader, image: $0)
                }
            }
            .padding()
            .navigationTitle(breed.name.firstLetterCapitalized)
            Spacer()
        }
        .onAppear {
            model.loadBreeds(of: breed.id,
                             imageListLoader: imageListLoader)
        }
    }
}

struct AnimalImageGridView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AnimalImageGridView(breed: Breed.anyBreed,
                             imageListLoader: StubAnimalImageListLoader(),
                             imageDataLoader: StubImageDataLoader())
        }
    }
}
