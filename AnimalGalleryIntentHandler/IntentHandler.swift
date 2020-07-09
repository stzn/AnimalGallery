//
//  IntentHandler.swift
//  AnimalGalleryIntentHandler
//
//  Created by Shinzan Takata on 2020/07/05.
//

import Intents

private let randomIntent = IntentBreed(identifier: "random", display: "random")

class IntentHandler: INExtension, DynamicBreedSelectionIntentHandling {
    private let client: HTTPClient = URLSessionHTTPClient(session: .shared)

    func provideIntentBreedOptionsCollection(for intent: DynamicBreedSelectionIntent, with completion: @escaping (INObjectCollection<IntentBreed>?, Error?) -> Void) {
        loadBreedList(type: intent.animalType) {
            completion(INObjectCollection(items: $0), nil)
        }
    }

    private func loadBreedList(type: Animal,
                      completion: @escaping ([IntentBreed]) -> Void) {
        switch type {
        case .dog:
            loadDogBreedList(completion: completion)
        case .cat:
            loadCatBreedList(completion: completion)
        case .unknown:
            completion([randomIntent])
        }
    }

    private func loadDogBreedList(completion: @escaping ([IntentBreed]) -> Void) {
        DogWebAPI(client: client)
            .load { completion(self.makeIntentBreed(from: $0)) }
    }

    private func loadCatBreedList(completion: @escaping ([IntentBreed]) -> Void) {
        CatWebAPI(client: client)
            .load { completion(self.makeIntentBreed(from: $0)) }
    }

    private func makeIntentBreed(from result: Result<[Breed], Error>) -> [IntentBreed] {
        switch result {
        case .success(let breeds):
            let ordered = breeds.sorted(by: { $0.name < $1.name })
                .map { IntentBreed(identifier: $0.id, display: $0.name.firstLetterCapitalized) }
            return [randomIntent] + ordered
        case .failure:
            return [randomIntent]
        }
    }

    func defaultIntentBreed(for intent: DynamicBreedSelectionIntent) -> IntentBreed? {
        randomIntent
    }

    override func handler(for intent: INIntent) -> Any {
        return self
    }
    
}
