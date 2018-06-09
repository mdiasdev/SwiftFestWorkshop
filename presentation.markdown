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

Next we're going to build an endpoint to create Restaurants:
```
static func create(request: HTTPRequest, response: HTTPResponse) {
    do {

    } catch let error {
        response.completed(status: .internalServerError)
        print(error)
    }
}
```

To save time, we're going to create multiple Restaurants at once:
```
guard let requestJson = try request.postBodyString?.jsonDecode() as? [[String: Any]] else {
    response.setBody(string: "Missing or Bad Parameter")
            .completed(status: .badRequest)

    return
}
```

Next, we want to loop through the POST body to pull out the JSON representing our Restaurants:
```
for json in requestJson {

}
```

Again, we'll guard to make sure the JSON is formatted in the way we expect:
```
guard let name = json["name"] as? String,
    let phoneNumber = json["phoneNumber"] as? String,
    let latitude = json["latitude"] as? Float,
    let longitude = json["longitude"] as? Float,
    let website = json["website"] as? String else {

    response.setBody(string: "Missing or Bad Parameter")
            .completed(status: .badRequest)
    return
}
```

We'll construct a Restaurant object from the values we pulled out of the JSON:
```
let restaurant = Restaurant()
restaurant.name = name
restaurant.phoneNumber = phoneNumber
restaurant.latitude = Float(latitude)
restaurant.longitude = Float(longitude)
restaurant.website = website
```

Next we'll want to save that object to our database:
```
try restaurant.save { id in
    restaurant.id = id as! Int
}
```

Finally, we'll have the server tell our users that everything went ok:
```
response.completed(status: .created)
```

Since we'll have many endpoints, We'll create a function that returns all the routes for this structure and add our new route:
```
static func allRoutes() -> Routes {
    var routes = Routes()

    routes.add(method: .post, uri: "/restaurants", handler: create)

    return routes
}
```

If we've done everything correctly, we should be able to add the route to our server and enter in our seed data using Postman:
```
routes.add(RestaurantRoutes.allRoutes())
```

Now that we have data in our database, let's retrieve it:
```
static func getAll(request: HTTPRequest, response: HTTPResponse) {
    do {

    } catch let error as StORMError {
        response.setBody(string: error.string())
                .completed(status: .internalServerError)
    } catch let error {
        response.setBody(string: "\(error)")
                .completed(status: .internalServerError)
    }
}
```

We'll create a reference to the object we're looking for and ask StORM to find all of them:
```
let objectQuery = Restaurant()
try objectQuery.findAll()
```

Then we'll loop through everything that was found and build our response JSON:
```
var responseJson: [[String: Any]] = []

for row in objectQuery.rows() {
    responseJson.append(row.asDictionary())
}
```

Finally, we'll ask Perfect to return a response containing all of our Restaurants:
```
try response.setBody(json: responseJson)
            .completed(status: .ok)
```

Again we'll add the route. And if everything went right, we should be able to get our data back using Postman:
```
routes.add(method: .get, uri: "/restaurants", handler: getAll)
```

We should also be able to see the list of Restaurants populating in our app now:
```
```

Next in the UI is to create a Reservation. To do so, we'll follow pretty much the same steps as we did with Restaurants:
```
var id: Int = 0
var restaurantId: Int = 0
var _restaurant: Restaurant = Restaurant()
var date: String = ""
var partySize: Int = 0
```

We'll need another table. This time for Reservations:
```
override open func table() -> String { return "reservations" }
```

We'll create our "to" function, again allowing us to convert a table row to our object:
```
override func to(_ this: StORMRow) {
    guard let restaurantId = this.data["restaurantid"] as? Int else { return }

    self.id = this.data["id"] as? Int ?? 0
    self.restaurantId = restaurantId
    self.date = this.data["date"] as? String ?? ""
    self.partySize = this.data["partysize"] as? Int ?? 0
}
```

We'll also make the rows function in case we need to get all Reservations:
```
func rows() -> [Reservation] {
    var rows = [Reservation]()
    for i in 0..<self.results.rows.count {
        let row = Reservation()
        row.to(self.results.rows[i])
        rows.append(row)
    }

    return rows
}
```

And we'll make a function that returns a Reservation as a dictionary for use in JSON:
```
func asDictionary() -> [String: Any] {
    let restaurant = Restaurant()
    try? restaurant.get(self.restaurantId)

    guard restaurant.id > 0 else { return [:] }

    return [
        "id": self.id,
        "restaurant": restaurant.asDictionary(),
        "date": self.date,
        "partySize": self.partySize,
    ]
}
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
routes.add(ReservationRoutes.allRoutes())
```
