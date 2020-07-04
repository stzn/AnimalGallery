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

final class DogImageGridViewModel: ObservableObject {
    @Published var dogImages: [DogImage] = []
    @Published var error: Error? = nil
    
    private var cancellables = Set<AnyCancellable>()

    func loadBreeds(of type: BreedType,
                    dogImageListLoader: DogImageListLoader) {
        dogImageListLoader.load(of: type)
            .receive(on: DispatchQueue.main)
            .sink { completed in
                if case .failure(let error) = completed {
                    self.error = error
                }
            } receiveValue: { value in
                self.dogImages = value
            }
            .store(in: &cancellables)
    }
}

struct DogImageGridView: View {
    @ObservedObject var model = DogImageGridViewModel()

    let breed: Breed
    let dogImageListLoader: DogImageListLoader
    let imageDataLoader: ImageDataLoader

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(model.dogImages) {
                    DogImageView(imageDataLoader: imageDataLoader,
                                 dogImage: $0)
                }
            }
            .padding()
            .navigationTitle(breed.name)
            Spacer()
        }
        .onAppear {
            model.loadBreeds(of: breed.name,
                             dogImageListLoader:dogImageListLoader)
        }
    }
}

struct DogImageGridView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DogImageGridView(breed: Breed.anyBreed,
                             dogImageListLoader: StubDogImageListLoader(),
                             imageDataLoader: StubImageDataLoader())
        }
    }
}
