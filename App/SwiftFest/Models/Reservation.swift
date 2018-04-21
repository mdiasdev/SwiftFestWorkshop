//
//  Reservation.swift
//  SwiftFest
//
//  Created by Matthew Dias on 4/21/18.
//  Copyright © 2018 Matt Dias. All rights reserved.
//

import Foundation

struct Reservation {
    var id: Int
    var restaurant: Restaurant
    var date: String
    var partySize: Int

    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let partySize = json["partySize"] as? Int,
            let date = json["date"] as? String,
            let restaurantJson = json["restaurant"] as? [String: Any],
            let restaurant = Restaurant(json: restaurantJson) else {
                return nil
        }

        self.id = id
        self.restaurant = restaurant
        self.date = date
        self.partySize = partySize
    }
}
