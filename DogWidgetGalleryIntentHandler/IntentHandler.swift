//
//  IntentHandler.swift
//  DogWidgetGalleryIntentHandler
//
//  Created by Shinzan Takata on 2020/07/05.
//

import Intents

private let randomIntent = DogBreed(identifier: "random", display: "random")

class IntentHandler: INExtension, DynamicDogBreedSelectionIntentHandling {
    private let client: HTTPClient = URLSessionHTTPClient(session: .shared)

    func provideDogBreedOptionsCollection(for intent: DynamicDogBreedSelectionIntent,
                                          with completion: @escaping (INObjectCollection<DogBreed>?, Error?) -> Void) {
        loadDogBreedList {
            completion(INObjectCollection(items: $0), nil)
        }
    }

    private func loadDogBreedList(completion: @escaping ([DogBreed]) -> Void) {
        DogBreedListLoader(client: client)
            .load { completion(self.makeDogBreed(from: $0)) }
    }

    private func makeDogBreed(from result: Result<[Breed], Error>) -> [DogBreed] {
        switch result {
        case .success(let breeds):
            let ordered = breeds.sorted(by: { $0.name < $1.name })
                .map { DogBreed(identifier: $0.id, display: $0.name.firstLetterCapitalized) }
            return [randomIntent] + ordered
        case .failure:
            return [randomIntent]
        }
    }

    func defaultDogBreed(for intent: DynamicDogBreedSelectionIntent) -> DogBreed? {
        randomIntent
    }

    override func handler(for intent: INIntent) -> Any {
        return self
    }
    
}
