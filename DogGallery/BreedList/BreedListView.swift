//
//  BreedListView.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/07/04.
//

import Combine
import SwiftUI

final class BreedListViewModel: ObservableObject {
    @Published var breeds: [Breed] = []
    @Published var error: Error? = nil
    private var cancellables = Set<AnyCancellable>()

    func loadBreeds(breedListLoader: BreedListLoader) {
        breedListLoader.load { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let breeds):
                    self?.breeds = breeds
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
}

struct BreedListView: View {
    @Environment(\.injected) var container: DIContainer
    @ObservedObject var model = BreedListViewModel()
    @State private var selection: Breed?

    var body: some View {
        NavigationView {
            content
                .navigationTitle("BreedList")
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
            LazyVStack {
                ForEach(model.breeds) {
                    navigationLinkToDogImages(for: $0)
                        .padding()
                }
                Spacer()
            }.onOpenURL { url in
                let name = url.lastPathComponent
                self.selection = Breed(name: name)
            }
        }
    }

    private func navigationLinkToDogImages(for breed: Breed) -> some View {
        NavigationLink(
            destination: DogImageGridView(
                breed: breed,
                dogImageListLoader: container.loaders.dogImageListLoader,
                imageDataLoader: container.loaders.imageDataLoader),
            tag: breed, selection: $selection
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
