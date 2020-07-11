//
//  BreedRow.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct BreedRow: View {
    @Environment(\.colorScheme) var colorScheme

    let breed: Breed
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(self.breed.name.firstLetterCapitalized)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            Divider()
        }
        .contentShape(ContainerRelativeShape())
    }
}

struct BreedRow_Previews: PreviewProvider {
    static var previews: some View {
        BreedRow(breed: Breed.anyBreed)
    }
}
