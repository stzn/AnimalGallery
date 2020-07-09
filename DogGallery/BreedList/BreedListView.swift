//
//  BreedListView.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/07/04.
//

import Combine
import SwiftUI
import WidgetKit

final class BreedListViewModel: ObservableObject {
    @Published var breeds: [Breed] = []
    @Published var error: Error? = nil
    @Published var selectedBreed: BreedType? = nil

    private var cancellables = Set<AnyCancellable>()

    func loadBreeds(breedListLoader: BreedListLoader) {
        breedListLoader.load { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let breeds):
                    let ordered = breeds.sorted(by: { $0.name < $1.name })
                    self?.breeds = ordered
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
}

struct BreedListView: View {
    @Environment(\.injected) var container: DIContainer
    @StateObject var model = BreedListViewModel()

    let animalType: AnimalType

    var body: some View {
        NavigationView {
            content
                .navigationTitle("\(animalType.rawValue) BreedList")
                .navigationBarItems(trailing: Button("Reload") {
                    WidgetCenter.shared.reloadAllTimelines()
                })
        }
        .onAppear {
            model.loadBreeds(
                breedListLoader: breedListLoader)
        }
    }

    private var breedListLoader: BreedListLoader {
        let breedListLoader: BreedListLoader
        switch animalType {
        case .dog:
            breedListLoader = container.loaders.dogBreedListLoader
        case .cat:
            breedListLoader = container.loaders.catBreedListLoader
        }
        return breedListLoader
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

    private var content: some View {
        Group {
            if model.error != nil {
                Image(systemName: "xmark.octagon.fill")
            } else {
                list
            }
        }
    }

    // use VStack for moving to detail page from deep link
    private var list: some View {
        ScrollView {
            VStack {
                ForEach(model.breeds) {
                    navigationLinkToAnimalImages(for: $0)
                        .padding()
                }
                Spacer()
            }.onOpenURL { url in
                let breedName = url.lastPathComponent
                self.model.selectedBreed = breedName
            }
        }
    }

    private func navigationLinkToAnimalImages(for breed: Breed) -> some View {
        NavigationLink(
            destination: AnimalImageGridView(
                breed: breed,
                imageListLoader: imageListLoader,
                imageDataLoader: container.loaders.imageDataLoader),
            tag: breed.id, selection: $model.selectedBreed
        ) {
            BreedRow(breed: breed)
        }
        .buttonStyle(PlainButtonStyle())
        .tag(breed)
    }
}

struct BreedListView_Previews: PreviewProvider {
    private static let devices = [
        "iPhone SE",
        "iPhone 11",
        "iPad Pro (11-inch) (2nd generation)",
    ]

    static var previews: some View {
        ForEach(devices, id: \.self) { name in
            Group {
                BreedListView(animalType: .dog)
                    .previewDevice(PreviewDevice(rawValue: name))
                    .previewDisplayName(name)
                    .colorScheme(.light)
            }
        }
    }
}
