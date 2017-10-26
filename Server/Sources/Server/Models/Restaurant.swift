//
//  Restaurant.swift
//  Server
//
//  Created by Matt Dias on 10/24/17.
//

import StORM
import PostgresStORM

class Restaurant: PostgresStORM {
    var id: Int = 0
    var name: String = ""
    var phoneNumber: String = ""
    var latitude: Float = 0.0
    var longitude: Float = 0.0
    var website: String = ""


    override open func table() -> String { return "restaurants" }

    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        name = this.data["name"] as? String ?? ""
        phoneNumber = this.data["phonenumber"] as? String ?? ""
        latitude = this.data["latitude"] as? Float ?? 0.0
        longitude = this.data["longitude"] as? Float ?? 0.0
        website = this.data["website"] as? String ?? ""
    }

    func rows() -> [Restaurant] {
        var rows = [Restaurant]()
        for i in 0..<self.results.rows.count {
            let row = Restaurant()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }

    func asDictionary() -> [String: Any] {
        return [
            "id": self.id,
            "name": self.name,
            "phoneNumber": self.phoneNumber,
            "latitude": self.latitude,
            "longitude": self.longitude,
            "website": self.website,
        ]
    }
}
