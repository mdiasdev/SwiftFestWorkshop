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

    override open func table() -> String { return "restaurants" }

    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        name = this.data["name"] as? String ?? ""
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
            "short": self.name,
        ]
    }
}
