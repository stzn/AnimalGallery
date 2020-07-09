//
//  RootView.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/07/09.
//

import SwiftUI

struct RootView: View {
    @Environment(\.injected) var container: DIContainer
    @SceneStorage("SelectedAnimal") var selection: AnimalType = .dog
    @State var selectedBreed: BreedType? = nil

    var body: some View {
        TabView(selection: $selection) {
            BreedListView(animalType: .dog, selectedBreed: $selectedBreed)
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("🐶")
                }
                .tag(AnimalType.dog)
                .environment(\.injected, container)
            BreedListView(animalType: .cat, selectedBreed: $selectedBreed)
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("🐱")
                }
                .tag(AnimalType.cat)
                .environment(\.injected, container)
        }.onOpenURL { url in
            guard let scheme = url.scheme,
                  let animalType = AnimalType(from: scheme) else {
                return
            }
            self.selection = animalType

            let breedName = url.lastPathComponent
            self.selectedBreed = breedName
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
