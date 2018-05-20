//
//  ReservationDetailsInterfaceController.swift
//  SwiftFestWatch Extension
//
//  Created by Matthew Dias on 5/13/18.
//  Copyright © 2018 Matt Dias. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class ReservationDetailsInterfaceController: WKInterfaceController {
    @IBOutlet var restaurantNameLabel: WKInterfaceLabel!
    @IBOutlet var reservationTimeLabel: WKInterfaceLabel!

    var reservation: Reservation?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        retrieveReservation()

        if let reservation = reservation {
            restaurantNameLabel.setText(reservation.restaurant.name)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyy, HH:mm"
            let reservationDate = dateFormatter.date(from: reservation.date)!
            let components = Calendar.current.dateComponents([.hour, .minute], from: reservationDate)
            reservationTimeLabel.setText("at: \(components.hour!):\(components.minute!)")
        }
    }

    func retrieveReservation() {
        self.reservation = nil

        guard let message = UserDefaults.standard.object(forKey: "reservation") as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: message, options: .prettyPrinted),
              let reservation = try? JSONDecoder().decode(Reservation.self, from: data) else { return }

        self.reservation = reservation
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        guard let reservation = reservation else { return nil }
        return reservation
    }
}

extension ReservationDetailsInterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message)

        UserDefaults.standard.set(message, forKey: "reservation")
    }
}
