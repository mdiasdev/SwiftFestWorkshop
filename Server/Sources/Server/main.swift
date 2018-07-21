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

let reservation = Reservation()
try? reservation.setup()

let server = HTTPServer()
server.serverPort = 8080

var routes = Routes()
routes.add(RestaurantRoutes.allRoutes())
routes.add(ReservationRoutes.allRoutes())
routes.add(AuthRoutes.allRoutes())

server.addRoutes(routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
