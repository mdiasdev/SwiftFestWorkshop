//
//  MapInterfaceController.swift
//  SwiftFestWatch Extension
//
//  Created by Matthew Dias on 5/13/18.
//  Copyright © 2018 Matt Dias. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class MapInterfaceController: WKInterfaceController {

    @IBOutlet var map: WKInterfaceMap!
    @IBOutlet var testLabel: WKInterfaceLabel!

    var restaurant: Restaurant?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // Configure interface objects here.
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        retrieveRestaurant()

        guard let restaurant = restaurant else { return }
        
        map.addAnnotation(CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude), with: .green)
        map.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude), span: MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20)))
    }
    
    func retrieveRestaurant() {
        self.restaurant = nil

        guard let message = UserDefaults.standard.object(forKey: "reservation") as? [String: Any],
            let data = try? JSONSerialization.data(withJSONObject: message, options: .prettyPrinted),
            let reservation = try? JSONDecoder().decode(Reservation.self, from: data) else { return }

        self.restaurant = reservation.restaurant
    }

}

extension MapInterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message)

        UserDefaults.standard.set(message, forKey: "reservation")
    }
}
