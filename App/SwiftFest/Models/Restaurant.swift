//
//  Restaurant.swift
//  SwiftFest
//
//  Created by Matthew Dias on 10/28/17.
//  Copyright © 2017 Matt Dias. All rights reserved.
//

import Foundation

struct Restaurant {
    var id: Int
    var name: String
    var website: String
    var phoneNumber: String
    var latitude: Double
    var longitude: Double

    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int,
              let name = json["name"] as? String,
              let website = json["website"] as? String,
              let phoneNumber = json["phoneNumber"] as? String,
              let latitude = json["latitude"] as? Double,
              let longitude = json["longitude"] as? Double else {
                return nil
        }

        self.id = id
        self.name = name
        self.website = website
        self.phoneNumber = phoneNumber
        self.latitude = latitude
        self.longitude = longitude
    }
}
