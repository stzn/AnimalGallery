//
//  RootView.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/07/09.
//

import SwiftUI

struct RootView: View {
    @Environment(\.injected) var container: DIContainer
    @SceneStorage("SelectedAnimal") var selection: AnimalType = .dog

    var body: some View {
        TabView(selection: $selection) {
            BreedListView(animalType: .dog)
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("🐶")
                }
                .tag(AnimalType.dog)
                .environment(\.injected, container)
            BreedListView(animalType: .cat)
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("🐱")
                }
                .tag(AnimalType.cat)
                .environment(\.injected, container)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
