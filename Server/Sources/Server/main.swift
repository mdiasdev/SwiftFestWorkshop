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

let server = HTTPServer()
server.serverPort = 8080

var routes = Routes()

func getRestaurants(request: HTTPRequest, response: HTTPResponse) {
}

func createRestaurants(request: HTTPRequest, response: HTTPResponse) {
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

