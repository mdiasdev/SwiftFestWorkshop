//
//  ReservationRoutes.swift
//  Server
//
//  Created by Matthew Dias on 6/2/18.
//

import PerfectHTTP
import StORM
import PostgresStORM

struct ReservationRoutes {

    static func allRoutes() -> Routes {
        var routes = Routes()
        routes.add(method: .post, uri: "/reservation", handler: createReservation)
        routes.add(method: .get, uri: "/reservation/{id}", handler: getReservation)
        routes.add(method: .get, uri: "/reservation", handler: getReservations)
        routes.add(method: .delete, uri: "/reservation/{id}", handler: deleteReservation)
        routes.add(method: .put, uri: "/reservation/{id}", handler: updateReservation)

        return routes
    }

    /// Creates a Restaurant in the Database
    ///
    /// - Parameters:
    ///   - request: HTTP Request made by the consumer
    ///   - response: The created Reservation
    static func createReservation(request: HTTPRequest, response: HTTPResponse) {
        do {
            guard let json = try request.postBodyString?.jsonDecode() as? [String: Any],
                let restaurantId = json["restaurantId"] as? Int,
                let date = json["date"] as? String,
                let partySize = json["partySize"] as? Int else {

                    response.setBody(string: "Missing or Bad Parameter")
                        .completed(status: .badRequest)
                    return
            }

            let restaurant = Restaurant()
            try restaurant.get(restaurantId)

            guard restaurant.id != 0 else {
                response.setBody(string: "Restaurant Not Found").completed(status: .notFound)
                return
            }

            let reservation = Reservation()
            reservation.restaurantId = restaurant.id
            reservation.date = date
            reservation.partySize = partySize

            try reservation.save { id in
                reservation.id = id as! Int
            }

            try response.setBody(json: reservation.asDictionary())
                .completed(status: .ok)

        } catch let error {
            print(error)
        }
    }


    /// Get a single Reservation by ID
    ///
    /// - Parameters:
    ///   - request: HTTP Request made by the consumer
    ///   - response: The Reservation
    static func getReservation(request: HTTPRequest, response: HTTPResponse) {
        guard let id = Int(request.urlVariables["id"] ?? "0"), id > 0 else {
            response.completed(status: .badRequest)
            return
        }

        let reservation = Reservation()

        do {
            try reservation.get(id)

            if reservation.id != 0 {
                try response.setBody(json: reservation.asDictionary())
                    .completed(status: .ok)
            } else {
                response.setBody(string: "Reservation Not Found")
                    .completed(status: .notFound)
                return
            }
        } catch let error {
            print(error)
        }

        response.completed(status: .internalServerError)
    }


    /// Get all Reservations
    ///
    /// - Parameters:
    ///   - request: HTTP Request made by the consumer
    ///   - response: The Reservations
    static func getReservations(request: HTTPRequest, response: HTTPResponse) {
        do {
            let objectQuery = Reservation()
            try objectQuery.findAll()
            var responseJson: [[String: Any]] = []

            for row in objectQuery.rows() {
                responseJson.append(row.asDictionary())
            }

            try response.setBody(json: responseJson)
                .completed(status: .ok)
        } catch let error as StORMError {
            response.setBody(string: error.string())
                .completed(status: .internalServerError)
        } catch let error {
            response.setBody(string: "\(error)")
                .completed(status: .internalServerError)
        }
    }


    /// Delete a given Reservation from the database
    ///
    /// - Parameters:
    ///   - request: HTTP Request made by the consumer
    ///   - response: HTTP Response success or failure
    static func deleteReservation(request: HTTPRequest, response: HTTPResponse) {
        guard let id = Int(request.urlVariables["id"] ?? "0"), id > 0 else {
            response.completed(status: .badRequest)
            return
        }

        let reservation = Reservation()

        do {
            try reservation.get(id)

            if reservation.id != 0 {
                try reservation.delete()
                response.completed(status: .accepted)
            } else {
                response.setBody(string: "Reservation Not Found").completed(status: .notFound)
                return
            }
        } catch let error {
            print(error)
            response.completed(status: .badGateway)
        }
    }

    static func updateReservation(request: HTTPRequest, response: HTTPResponse) {
        guard let id = Int(request.urlVariables["id"] ?? "0"), id > 0 else {
            response.completed(status: .badRequest)
            return
        }

        do {
            guard let json = try request.postBodyString?.jsonDecode() as? [String: Any]  else {
                response.setBody(string: "Missing or Bad Parameter")
                    .completed(status: .badRequest)
                return
            }

            let reservation = Reservation()
            try reservation.get(id)

            guard reservation.id != 0 else { response.setBody(string: "Reservation does not exist").completed(status: .notFound); return }

            if let newPartySize = json["partySize"] as? Int {
                reservation.partySize = newPartySize
            }

            if let newDate = json["date"] as? String {
                reservation.date = newDate
            }

            try reservation.save()
            try response.setBody(json: reservation.asDictionary())
                .completed(status: .ok)

        } catch {
            print(error)
            response.completed(status: .badGateway)
        }
    }
}
