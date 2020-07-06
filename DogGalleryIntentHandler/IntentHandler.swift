//
//  IntentHandler.swift
//  DogGalleryIntentHandler
//
//  Created by Shinzan Takata on 2020/07/05.
//

import Intents

private let randomIntent = IntentBreed(identifier: "random", display: "random")

class IntentHandler: INExtension, DynamicBreedSelectionIntentHandling {
    func provideIntentBreedOptionsCollection(for intent: DynamicBreedSelectionIntent, with completion: @escaping (INObjectCollection<IntentBreed>?, Error?) -> Void) {
        BreedListLoader.load { result in
            switch result {
            case .success(let breeds):
                let ordered = breeds.sorted(by: { $0.displayString < $1.displayString })
                let collection = INObjectCollection(
                    items: [randomIntent] + ordered)
                completion(collection, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    func defaultIntentBreed(for intent: DynamicBreedSelectionIntent) -> IntentBreed? {
        randomIntent
    }

    override func handler(for intent: INIntent) -> Any {
        return self
    }
    
}
