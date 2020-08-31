//
//  SharedVariables.swift
//  AnimalGallery
//
//  Created by Shinzan Takata on 2020/07/05.
//

import Foundation

let dogAPIbaseURL = URL(string: "https://dog.ceo/api")!
let dogBreedListAPIURL = dogAPIbaseURL.appendingPathComponent("breeds/list/all")
let catAPIbaseURL = URL(string: "https://api.thecatapi.com/v1")!
let catBreedListAPIURL = catAPIbaseURL.appendingPathComponent("breeds")
let catImageListAPIURL = catAPIbaseURL.appendingPathComponent("/images/search")

// please get your own api key(https://thecatapi.com/)
let catAPIKey = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
