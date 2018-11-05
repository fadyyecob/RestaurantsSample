//
//  Restaurant.swift
//  Takeaway
//
//  Created by Fady Yecob on 22/10/2018.
//  Copyright © 2018 Fady Yecob. All rights reserved.
//

import UIKit

struct Restaurant: Codable {
    let name: String
    let status: String?
    let sortingValues: SortingValue
    
    struct SortingValue: Codable {
        let bestMatch: Double
        let newest: Double
        let ratingAverage: Double
        let distance: Int
        let popularity: Double
        let averageProductPrice: Int
        let deliveryCosts: Int
        let minCost: Int
    }
}
