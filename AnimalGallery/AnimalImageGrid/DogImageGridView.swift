//
//  DogImageGridView.swift
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
    @Published var dogImages: [AnimalImage] = []
    @Published var error: Error? = nil
    
    func loadBreeds(of type: BreedType,
                    dogImageListLoader: DogImageListLoader) {
        dogImageListLoader.load(of: type) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let dogImages):
                    self?.dogImages = dogImages
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
    let dogImageListLoader: DogImageListLoader
    let imageDataLoader: ImageDataLoader

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(model.dogImages) {
                    DogImageView(imageDataLoader: imageDataLoader, dogImage: $0)
                }
            }
            .padding()
            .navigationTitle(breed.name.firstLetterCapitalized)
            Spacer()
        }
        .onAppear {
            model.loadBreeds(of: breed.id,
                             dogImageListLoader:dogImageListLoader)
        }
    }
}

struct DogImageGridView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AnimalImageGridView(breed: Breed.anyBreed,
                             dogImageListLoader: StubDogImageListLoader(),
                             imageDataLoader: StubImageDataLoader())
        }
    }
}
