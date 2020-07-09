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
        var intents = [randomIntent]
        switch type {
        case .dog:
            loadDogBreedList { result in
                if let fetched = try? result.get() {
                    intents += fetched
                }
                completion(intents)
            }
        case .cat:
            loadCatBreedList { result in
                if let fetched = try? result.get() {
                    intents += fetched
                }
                completion(intents)
            }
        case .unknown:
            completion(intents)
        }
    }

    private func loadDogBreedList(completion: @escaping (Result<[IntentBreed], Error>) -> Void) {
        DogWebAPI(client: client)
            .load { result in
            switch result {
            case .success(let breeds):
                let ordered = breeds.sorted(by: { $0.name < $1.name })
                    .map { IntentBreed(identifier: $0.id, display: $0.name) }
                completion(.success(ordered))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func loadCatBreedList(completion: @escaping (Result<[IntentBreed], Error>) -> Void) {
        CatWebAPI(client: client)
            .load { result in
            switch result {
            case .success(let breeds):
                let ordered = breeds.sorted(by: { $0.name < $1.name })
                    .map { IntentBreed(identifier: $0.id, display: $0.name) }
                completion(.success(ordered))
            case .failure(let error):
                completion(.failure(error))
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
