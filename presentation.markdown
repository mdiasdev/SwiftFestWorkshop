# Front to Back to Left Wrist

Basic hello example:
```
func getHello(request: HTTPRequest, response: HTTPResponse) {

}
```

Add desired properties to `Restaurant` model:
```
var id: Int = 0
var name: String = ""
var phoneNumber: String = ""
var latitude: Float = 0.0
var longitude: Float = 0.0
var website: String = ""
```

Tell `StORM` the name of our table:
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

Finally, we're going to add a function that lets us represent our object as a `Dictionary` for use in JSON:
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

Next we're going to build an endpoint to create `Restaurants`:
```
static func create(request: HTTPRequest, response: HTTPResponse) {
    do {

    } catch let error {
        response.completed(status: .internalServerError)
        print(error)
    }
}
```

To save time, we're going to create multiple `Restaurants` at once:
```
guard let requestJson = try request.postBodyString?.jsonDecode() as? [[String: Any]] else {
    response.setBody(string: "Missing or Bad Parameter")
            .completed(status: .badRequest)

    return
}
```

Next, we want to loop through the POST body to pull out the JSON representing our `Restaurants`:
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

We'll construct a `Restaurant` object from the values we pulled out of the JSON:
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

We'll create a reference to the object we're looking for and ask `StORM` to find all of them:
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

Finally, we'll ask `Perfect` to return a response containing all of our `Restaurants`:
```
try response.setBody(json: responseJson)
            .completed(status: .ok)
```

Again we'll add the route. And if everything went right, we should be able to get our data back using Postman:
```
routes.add(method: .get, uri: "/restaurants", handler: getAll)
```

We should also be able to see the list of `Restaurants` populating in our app now:
```
```

Next in the UI is to create a `Reservation`. To do so, we'll follow pretty much the same steps as we did with `Restaurants`:
```
var id: Int = 0
var restaurantId: Int = 0
var _restaurant: Restaurant = Restaurant()
var date: String = ""
var partySize: Int = 0
```

We'll need another table. This time for `Reservations`:
```
override open func table() -> String { return "reservations" }
```

We'll create our `to` function, again allowing us to convert a table row to our object:
```
override func to(_ this: StORMRow) {
    guard let restaurantId = this.data["restaurantid"] as? Int else { return }

    self.id = this.data["id"] as? Int ?? 0
    self.restaurantId = restaurantId
    self.date = this.data["date"] as? String ?? ""
    self.partySize = this.data["partysize"] as? Int ?? 0
}
```

We'll also make the rows function in case we need to get all `Reservations`:
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

And we'll make a function that returns a `Reservation` as a `Dictionary` for use in JSON:
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

Like with `Restaurant` we'll want to make sure Reservation gets setup on server launch:
```
let reservation = Reservation()
try? reservation.setup()
```

Now that we have the object setup, we need to make the endpoint that will create a `Reservation` for our users:
```
static func createReservation(request: HTTPRequest, response: HTTPResponse) {
    do {

    } catch let error {
        print(error)
    }
}
```

Just as before, any time we receive data, we want to make sure it's as expected:
```
guard let json = try request.postBodyString?.jsonDecode() as? [String: Any],
    let restaurantId = json["restaurantId"] as? Int,
    let date = json["date"] as? String,
    let partySize = json["partySize"] as? Int else {

    response.setBody(string: "Missing or Bad Parameter")
            .completed(status: .badRequest)
    return
}
```

As important as checking the JSON, we also want to make sure we have the `Restaurant` in our database:
```
let restaurant = Restaurant()
try restaurant.get(restaurantId)

guard restaurant.id != 0 else {
    response.setBody(string: "Restaurant Not Found").completed(status: .notFound)
    return
}
```

We'll construct our `Reservation` object from the data passed in:
```
let reservation = Reservation()
reservation.restaurantId = restaurant.id
reservation.date = date
reservation.partySize = partySize
```

Save it to the database:
```
try reservation.save { id in
    reservation.id = id as! Int
}
```

And return it the successfully created `Reservation` in our server's response:
```
try response.setBody(json: reservation.asDictionary())
            .completed(status: .ok)
```

Again, because we'll have many routes, we'll create a function that returns all routes for this handler:
```
static func allRoutes() -> Routes {
    var routes = Routes()

    return routes
}
```

And we'll add the `createReservation` endpoint we just coded:
```
routes.add(method: .post, uri: "/reservation", handler: createReservation)
```

We'll need to again add the routes to our server:
```
routes.add(ReservationRoutes.allRoutes())
```

Now, if we've done everything right, we should be able to create a `Reservation` using Postman. But why don't we try it in the app:
```
```

Let's go ahead and create an endpoint that allows a user to cancel their `Reservation`:
```
static func deleteReservation(request: HTTPRequest, response: HTTPResponse) {

}
```

Before anything, we want to make sure that the user has passed us the ID of the `Reservation` they want to cancel:
```
guard let id = Int(request.urlVariables["id"] ?? "0"), id > 0 else {
    response.completed(status: .badRequest)
    return
}
```

We'll create a reference to our data object for `StORM` to query against -- returning an error if that fails:
```
let reservation = Reservation()

do {
    try reservation.get(id)

} catch let error {
    print(error)
    response.completed(status: .badGateway)
}
```

And if the Reservation is present in our database, we should be able to delete it. Or respond with an error if it's not:
```
if reservation.id != 0 {
    try reservation.delete()
    response.completed(status: .accepted)
} else {
    response.setBody(string: "Reservation Not Found").completed(status: .notFound)
    return
}
```

With that all coded up, we just need to add the route to our `allRoutes` function:
```
routes.add(method: .delete, uri: "/reservation/{id}", handler: deleteReservation)
```


/***********************/
      Watch Stuff
/************************/


Now we need a way to pass `Reservation` data from our to our Watch Extension.:
```
```

To do that, we'll create `WatchManager` and make it conform to `WCSessionDelegate`:
```
extension WatchManager: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("App: activationDidCompleteWith")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("App: sessionDidBecomeInactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("App: sessionDidDeactivate")
    }
}
```

To make sure we can send it to the watch, we'll have to check if the user has a watch:
```
func isSupported() -> Bool {
    if WCSession.isSupported() {
        WCSession.default.delegate = self
        WCSession.default.activate()
        return true
    }

    return false
}
```

And to make sure we're not unnecessarily checking, we'll add a check to see if we've already activated the session:
```
guard WCSession.default.activationState != .activated else { return true }
```

The last thing we want the `WatchManager` to do is send data to the watch:
```
func send(json: [String: Any]) {
    if WCSession.default.activationState == .activated && WCSession.default.isReachable {
        WCSession.default.sendMessage(json, replyHandler: nil)
    }
}
```

Next we'll want to make sure we send the `Reservation` to the watch when it's created:
```
```

To do this, we'll add some code to the `save` function in `CreateReservationViewController`:
```
if WatchManager.main.isSupported() {
    WatchManager.main.send(json: reservation)
}
```

And we'll want to add a similar block of code in the `cancelReservation` function in `ReservationDetailsViewController`:
```
if WatchManager.main.isSupported() {
    WatchManager.main.send(json: [:])
}
```









We need to make one last endpoint so our users can update their `Reservation`:
```
static func updateReservation(request: HTTPRequest, response: HTTPResponse) {

}
```

First we'll need to make sure that we're being passed a `Reservation.id` from the caller:
```
guard let id = Int(request.urlVariables["id"] ?? "0"), id > 0 else {
    response.completed(status: .badRequest)
    return
}
```

Next we're going to want to make sure we've been sent some JSON that holds the properties we need to update:
```
do {
    guard let json = try request.postBodyString?.jsonDecode() as? [String: Any]  else {
        response.setBody(string: "Missing or Bad Parameter")
                .completed(status: .badRequest)
        return
    }
} catch {
    print(error)
    response.completed(status: .badGateway)
}
```

Then we'll make a reference to our object, ask `StORM` to retrieve the specific `Reservation`, and check to see if it's real:
```
let reservation = Reservation()
try reservation.get(id)

guard reservation.id != 0 else {
    response.setBody(string: "Reservation does not exist").completed(status: .notFound)
    return
}
```

Now that we've retrieved the correct object, we can modify it with the properties passed in:
```
if let newPartySize = json["partySize"] as? Int {
    reservation.partySize = newPartySize
}

if let newDate = json["date"] as? String {
    reservation.date = newDate
}
```

We'll save our updated `Reservation` in place and return it to our users:
```
try reservation.save()
try response.setBody(json: reservation.asDictionary())
            .completed(status: .ok)
```

All that's left it to make sure we add our new route to `allRoutes`:
```
routes.add(method: .put, uri: "/reservation/{id}", handler: updateReservation)
```  
