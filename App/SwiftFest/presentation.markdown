# Front to Back to Left Wrist

Basic hello example:
```
func getHello(request: HTTPRequest, response: HTTPResponse) {
  
}
```

Add model objects:
```
let restaurant = Restaurant()
try? restaurant.setup()

let reservation = Reservation()
try? reservation.setup()
```

These are some comments between the snippets,
which Snippetty ignores.

Add routes:
```
routes.add(RestaurantRoutes.allRoutes())
routes.add(ReservationRoutes.allRoutes())
```
