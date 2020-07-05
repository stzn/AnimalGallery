//
//  BreedRow.swift
//  DogGallery
//
//  Created by Shinzan Takata on 2020/02/23.
//  Copyright © 2020 shiz. All rights reserved.
//

import SwiftUI

struct BreedRow: View {
    let breed: Breed
    var body: some View {
        VStack(alignment: .leading) {
            Text(self.breed.name.firstLetterCapitalized)
                .font(.headline)
            Divider()
        }
        .contentShape(Rectangle())
    }
}

struct BreedRow_Previews: PreviewProvider {
    static var previews: some View {
        BreedRow(breed: Breed.anyBreed)
    }
}
