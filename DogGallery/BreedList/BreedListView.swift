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
    @Published var selectedBreed: Breed? = nil

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

    var body: some View {
        NavigationView {
            content
                .navigationTitle("BreedList")
                .navigationBarItems(trailing: Button("Reload") {
                    WidgetCenter.shared.reloadAllTimelines()
                })
        }
        .onAppear {
            model.loadBreeds(
                breedListLoader: container.loaders.breedListLoader)
        }
    }

    private var content: some View {
        Group {
            if model.error != nil {
                Image(systemName: "xmark.octagon.fill")
            } else {
                lazyList
            }
        }
    }

    private var lazyList: some View {
        ScrollView {
            VStack {
                ForEach(model.breeds) {
                    navigationLinkToDogImages(for: $0)
                        .padding()
                }
                Spacer()
            }.onOpenURL { url in
                let name = url.lastPathComponent
                let breed = Breed(name: name)
                self.model.selectedBreed = breed
            }
        }
    }

    private func navigationLinkToDogImages(for breed: Breed) -> some View {
        NavigationLink(
            destination: DogImageGridView(
                breed: breed,
                dogImageListLoader: container.loaders.dogImageListLoader,
                imageDataLoader: container.loaders.imageDataLoader),
            tag: breed, selection: $model.selectedBreed
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
                BreedListView()
                    .previewDevice(PreviewDevice(rawValue: name))
                    .previewDisplayName(name)
                    .colorScheme(.light)
            }
        }
    }
}
