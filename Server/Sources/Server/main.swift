import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import StORM
import PostgresStORM

PostgresConnector.host = "localhost"
PostgresConnector.username = "perfect"
PostgresConnector.password = "perfect"
PostgresConnector.database = "swiftfest"
PostgresConnector.port = 5432

let restaurant = Restaurant()
try? restaurant.setup()

let server = HTTPServer()
server.serverPort = 8080

var routes = Routes()


/// Returns a list of all restaurants in the database
///
/// - Parameters:
///   - request: HTTP Request made by the consumer
///   - response: HTTP Response made of the Restaurants in the Database
func getRestaurants(request: HTTPRequest, response: HTTPResponse) {
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


/// Creates a Reservation object in the database if all parameters are present
///
/// - Parameters:
///   - request: HTTP Request made by the consumer
///   - response: HTTP Response made of the Restaurants in the Database
func createRestaurants(request: HTTPRequest, response: HTTPResponse) {
    do {
        guard let json = try request.postParams[0].0.jsonDecode() as? [String: Any],
              let name = json["name"] as? String,
              let phoneNumber = json["phoneNumber"] as? String,
              let latitude = json["latitude"] as? Float,
              let longitude = json["longitude"] as? Float,
              let website = json["website"] as? String else {

            response.setBody(string: "Missing Parameter")
                    .completed(status: .badRequest)
            return
        }

        let restaurant = Restaurant()
        restaurant.name = name
        restaurant.phoneNumber = phoneNumber
        restaurant.latitude = latitude
        restaurant.longitude = longitude
        restaurant.website = website

        try restaurant.save { id in
            restaurant.id = id as! Int
        }

        response.completed(status: .created)

    } catch let error {
        print(error)
    }
}

func createReservation(request: HTTPRequest, response: HTTPResponse) {
}

func getReservations(request: HTTPRequest, response: HTTPResponse) {
}


routes.add(method: .get, uri: "/restaurants", handler: getRestaurants)
routes.add(method: .post, uri: "/restaurants", handler: createRestaurants)
routes.add(method: .post, uri: "/reservation", handler: createReservation)
routes.add(method: .get, uri: "/reservation", handler: getReservations)

server.addRoutes(routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}

