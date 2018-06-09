# Front to Back to Left Wrist

Basic hello example:
```
func getHello(request: HTTPRequest, response: HTTPResponse) {

}
```

Add desired properties to Restaurant model:
```
var id: Int = 0
var name: String = ""
var phoneNumber: String = ""
var latitude: Float = 0.0
var longitude: Float = 0.0
var website: String = ""
```

Tell StORM the name of our table:
```
override open func table() -> String { return "restaurants" }
```

Next we need to tell the server how to convert a table row to our object:
```
override func to(_ this: StORMRow) {
    id = this.data["id"] as? Int ?? 0
    name = this.data["name"] as? String ?? ""
    phoneNumber = this.data["phonenumber"] as? String ?? ""
    website = this.data["website"] as? String ?? ""

    let latString = this.data["latitude"] as? String ?? ""
    latitude = Float(latString) ?? 0.0

    let lonString = this.data["longitude"] as? String ?? ""
    longitude = Float(lonString) ?? 0.0
}
```

While unnecessary, we can create a simple function to give us all the rows:
```
func rows() -> [Restaurant] {
    var rows = [Restaurant]()
    for i in 0..<self.results.rows.count {
        let row = Restaurant()
        row.to(self.results.rows[i])
        rows.append(row)
    }
    return rows
}
```

Finally, we're going to add a function that lets us represent our object as a dictionary for use in JSON:
```
func asDictionary() -> [String: Any] {
    return [
        "id": self.id,
        "name": self.name,
        "phoneNumber": self.phoneNumber,
        "latitude": self.latitude,
        "longitude": self.longitude,
        "website": self.website,
    ]
}
```

Adding our model object to main makes sure the database adds it on launch:
```
let restaurant = Restaurant()
try? restaurant.setup()
```

Like with Restaurant we'll want to make sure Reservation gets setup on server launch:
```
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
