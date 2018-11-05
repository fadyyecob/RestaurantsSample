//
//  TakeawayTests.swift
//  TakeawayTests
//
//  Created by Fady Yecob on 21/10/2018.
//  Copyright © 2018 Fady Yecob. All rights reserved.
//

import XCTest
@testable import Takeaway

class TakeawayTests: XCTestCase {

    var restaurantViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "restaurantViewController") as? RestaurantsTableViewController
    
    override func setUp() {
        restaurantViewController?.loadData()
        restaurantViewController?.sortData()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFavourites() {
        guard let restaurants = restaurantViewController?.restaurants else { XCTFail("No restaurants"); return }
        guard let favouriteRestaurants = restaurantViewController?.favouriteRestaurants else { return }
        guard favouriteRestaurants.count > 0 else { return }
        
        for (index, restaurant) in restaurants.enumerated() {
            if index == 0 {
                XCTAssert(favouriteRestaurants.contains(restaurant.name), "First restaurant is not a favourite")
            } else if favouriteRestaurants.contains(restaurant.name) {
                XCTAssert(favouriteRestaurants.contains(restaurants[index-1].name), "First restaurant is not a favourite")
            }
        }
    }
    
    func testFavouritesSortedByStatus() {
        guard let restaurants = restaurantViewController?.restaurants else { XCTFail("No restaurants"); return }
        guard let favouriteRestaurants = restaurantViewController?.favouriteRestaurants else { return }
        guard favouriteRestaurants.count > 0 else { return }
        
        for (index, restaurant) in restaurants.enumerated() {
            guard favouriteRestaurants.contains(restaurant.name) else { continue }
            guard index != 0 else { continue }
            
            let previousRestaurant = restaurants[index-1]
            
            if restaurant.status == "open" {
                XCTAssert(previousRestaurant.status == "open", "Favourites incorrectly sorted by status")
            } else if restaurant.status == "order ahead" {
                XCTAssert(previousRestaurant.status == "order ahead" || previousRestaurant.status == "open", "Favourites incorrectly sorted by status")
            } else if restaurant.status == "closed" {
                XCTAssert(previousRestaurant.status == "closed" || previousRestaurant.status == "order ahead", "Favourites incorrectly sorted by status")
            }
            
        }
        
    }

}
