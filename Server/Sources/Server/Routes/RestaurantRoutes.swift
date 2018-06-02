//
//  RestaurantRoutes.swift
//  Server
//
//  Created by Matthew Dias on 6/2/18.
//

import PerfectHTTP
import StORM
import PostgresStORM

struct RestaurantRoutes {
    static func allRoutes() -> Routes {
        var routes = Routes()
        routes.add(method: .get, uri: "/restaurants", handler: getAll)
        routes.add(method: .post, uri: "/restaurants", handler: create)
        routes.add(method: .delete, uri: "/restaurants/{id}", handler: delete)

        return routes
    }

    /// Returns a list of all restaurants in the database
    ///
    /// - Parameters:
    ///   - request: HTTP Request made by the consumer
    ///   - response: HTTP Response made of the Restaurants in the Database
    static func getAll(request: HTTPRequest, response: HTTPResponse) {
        do {
            let objectQuery = Restaurant()
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


    /// Creates one or many Restaurant objects in the database if all parameters are present
    ///
    /// - Parameters:
    ///   - request: HTTP Request made by the consumer
    ///   - response: The created Restaurant
    static func create(request: HTTPRequest, response: HTTPResponse) {
        do {
            guard let requestJson = try request.postBodyString?.jsonDecode() as? [[String: Any]] else {

                response.setBody(string: "Missing or Bad Parameter")
                    .completed(status: .badRequest)
                return
            }

            for json in requestJson {
                guard let name = json["name"] as? String,
                    let phoneNumber = json["phoneNumber"] as? String,
                    let latitude = json["latitude"] as? Float,
                    let longitude = json["longitude"] as? Float,
                    let website = json["website"] as? String else {

                        response.setBody(string: "Missing or Bad Parameter")
                            .completed(status: .badRequest)
                        return
                }

                let restaurant = Restaurant()
                restaurant.name = name
                restaurant.phoneNumber = phoneNumber
                restaurant.latitude = Float(latitude)
                restaurant.longitude = Float(longitude)
                restaurant.website = website

                try restaurant.save { id in
                    restaurant.id = id as! Int
                }
            }

            response.completed(status: .created)

        } catch let error {
            print(error)
        }
    }


    /// Delete a given Restaurant from the database
    ///
    /// - Parameters:
    ///   - request: HTTP Request made by the consumer
    ///   - response: HTTP Response success or failure
    static func delete(request: HTTPRequest, response: HTTPResponse) {
        guard let id = Int(request.urlVariables["id"] ?? "0"), id > 0 else {
            response.completed(status: .badRequest)
            return
        }

        let restaurant = Restaurant()

        do {
            try restaurant.get(id)

            if restaurant.id != 0 {
                try restaurant.delete()
            } else {
                response.setBody(string: "Restaurant Not Found").completed(status: .notFound)
                return
            }
        } catch let error {
            print(error)
        }

        response.completed(status: .accepted)
    }
}

