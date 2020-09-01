//
//  AnimalImageGridView.swift
//  AnimalGallery
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

    func loadBreeds(of type: BreedType, using loader: AnimalImageListLoader) {
        loader(type) { result in
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
    @Environment(\.injected) var container: DIContainer
    @StateObject var model = AnimalImageGridViewModel()

    let animalType: AnimalType
    let breed: Breed

    var body: some View {
        ScrollView {
// When scrolling quickly, the app craches.
// LazyVGrid(columns: columns) {
            VStack {
                ForEach(model.images) {
                    AnimalImageView(image: $0)
                }
            }
            .padding()
            .navigationTitle(breed.name.firstLetterCapitalized)
            Spacer()
        }
        .onAppear {
            model.loadBreeds(of: breed.id, using: imageListLoader)
        }
    }

    private var imageListLoader: AnimalImageListLoader {
        let imageListLoader: AnimalImageListLoader
        switch animalType {
        case .dog:
            imageListLoader = container.loaders.dogImageListLoader
        case .cat:
            imageListLoader = container.loaders.catImageListLoader
        }
        return imageListLoader
    }
}

struct AnimalImageGridView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AnimalImageGridView(animalType: .dog, breed: Breed.anyBreed)
        }
    }
}
