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
        breedListLoader.load()
            .receive(on: DispatchQueue.main)
            .sink { completed in
                if case .failure(let error) = completed {
                    self.error = error
                }
            } receiveValue: { value in
                self.breeds = value
            }
            .store(in: &cancellables)
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
    static var previews: some View {
        BreedListView()
    }
}
