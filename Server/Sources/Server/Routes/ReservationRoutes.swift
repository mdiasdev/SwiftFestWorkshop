
import PerfectHTTP
import StORM
import PostgresStORM

struct ReservationRoutes {

    

    

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
