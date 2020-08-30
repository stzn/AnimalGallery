//
//  IntentHandler.swift
//  CatGalleryWidgetIntentHandler
//
//  Created by Shinzan Takata on 2020/07/10.
//

import Intents

private let randomIntent = CatBreed(identifier: "random", display: "random")

class IntentHandler: INExtension, DynamicCatBreedSelectionIntentHandling {
    private let client: HTTPClient = URLSessionHTTPClient(session: .shared)

    func provideCatBreedOptionsCollection(for intent: DynamicCatBreedSelectionIntent,
                                          with completion: @escaping (INObjectCollection<CatBreed>?, Error?) -> Void) {
        loadCatBreedList {
            completion(INObjectCollection(items: $0), nil)
        }
    }

    private func loadCatBreedList(completion: @escaping ([CatBreed]) -> Void) {
        RemoteListLoader(request: CatAPIURLRequestFactory.makeURLRequest(from: catBreedListAPIbaseURL),
                         client: client, mapper: CatListMapper.map)
            .load { completion(self.makeCatBreed(from: $0)) }
    }

    private func makeCatBreed(from result: Result<[Breed], Error>) -> [CatBreed] {
        switch result {
        case .success(let breeds):
            let ordered = breeds.sorted(by: { $0.name < $1.name })
                .map { CatBreed(identifier: $0.id, display: $0.name.firstLetterCapitalized) }
            return [randomIntent] + ordered
        case .failure:
            return [randomIntent]
        }
    }

    func makeURLRequest(from url: URL,
                        queryItems: [URLQueryItem] = []) -> URLRequest? {
        var component = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false)
        component?.queryItems = queryItems

        guard let url = component?.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue(catAPIKey, forHTTPHeaderField: "x-api-key")
        return request
    }

    func defaultCatBreed(for intent: DynamicCatBreedSelectionIntent) -> CatBreed? {
        randomIntent
    }

    override func handler(for intent: INIntent) -> Any {
        return self
    }
}
