
import Foundation
import PerfectHTTP

struct AuthRoutes {

    static func allRoutes() -> Routes {
        var routes = Routes()
        routes.add(method: .post, uri: "/login", handler: auth)

        return routes
    }

    static func auth(request: HTTPRequest, response: HTTPResponse) {
        do {
            guard let json = try request.postBodyString?.jsonDecode() as? [String: Any] else {
                    response.setBody(string: "Malformed Request")
                            .completed(status: .badRequest)
                    return
            }

            guard let username = json["username"] as? String else {
                response.setBody(string: "Missing username")
                        .completed(status: .badRequest)
                return
            }

            guard let password = json["password"] as? String else {
                response.setBody(string: "Missing password")
                        .completed(status: .badRequest)
                return
            }

            if validate(email: username, password: password) {
                response.setBody(string: UUID().uuidString)
                        .completed(status: .ok)
            } else {
                response.setBody(string: "Bad username or password")
                        .completed(status: .unauthorized)
            }

        } catch {
            print("\(error)")
        }
    }

    private static func validate(email: String, password: String) -> Bool {
        return email.contains("@") &&
               email.contains(".") &&
               !email.contains(" ") &&
               password.count >= 8
    }
}
