//
//  Reservation.swift
//  Server
//
//  Created by Matthew Dias on 10/24/17.
//

import StORM
import PostgresStORM

class Reservation: PostgresStORM {
    var id: Int = 0
    var restaurantId: Int = 0
    var _restaurant: Restaurant = Restaurant()
    var date: String = ""
    var partySize: Int = 0

    override open func table() -> String { return "reservations" }

    override func to(_ this: StORMRow) {
        guard let restaurantId = this.data["restaurantid"] as? Int else { return }

        self.id = this.data["id"] as? Int ?? 0
        self.restaurantId = restaurantId
        self.date = this.data["date"] as? String ?? ""
        self.partySize = this.data["partysize"] as? Int ?? 0

    }

    func rows() -> [Reservation] {
        var rows = [Reservation]()
        for i in 0..<self.results.rows.count {
            let row = Reservation()
            row.to(self.results.rows[i])
            rows.append(row)
        }

        return rows
    }

    func asDictionary() -> [String: Any] {
        let restaurant = Restaurant()
        try? restaurant.get(self.restaurantId)

        guard restaurant.id > 0 else {
            return [:]
        }

        return [
            "id": self.id,
            "restaurant": restaurant.asDictionary(),
            "date": self.date,
            "partySize": self.partySize,
        ]
    }
}
