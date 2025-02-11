//
//  QRModel.swift
//  Vinishko
//
//  Created by mttm on 18.05.2023.
//

import Foundation

struct QRModel: Decodable {
    let verification: String
    let imageURL: String
    let name: String
    let wineColor: Int
    let wineSugar: Int
    let wineType: Int
    let wineSort: String
    let wineCountry: String
    let wineRegion: String
    let placeOfPurchase: String
    let bottleDescription: String
    let rating: Int
    let price: String
}
