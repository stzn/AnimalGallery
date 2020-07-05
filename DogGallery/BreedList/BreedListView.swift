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

    var body: some View {
        NavigationView {
            Group {
                if model.error != nil {
                    Text("error")
                } else {
                    list
                }
            }
            .navigationTitle("BreedList")
        }
        .onAppear {
            model.loadBreeds(
                breedListLoader: container.loaders.breedListLoader)
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack {
                ForEach(model.breeds) {
                    navigationLinkToDogImages(for: $0)
                        .padding()
                }
                Spacer()
            }
        }
    }

    private func navigationLinkToDogImages(for breed: Breed) -> some View {
        NavigationLink(
            destination: DogImageGridView(
                breed: breed,
                dogImageListLoader: container.loaders.dogImageListLoader,
                imageDataLoader: container.loaders.imageDataLoader)) {
            BreedRow(breed: breed)
        }
        .buttonStyle(PlainButtonStyle())
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
