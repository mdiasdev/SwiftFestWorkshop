//
//  InterfaceController.swift
//  SwiftFestWatch Extension
//
//  Created by Matthew Dias on 5/13/18.
//  Copyright © 2018 Matt Dias. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var testLabel: WKInterfaceLabel!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message)
        testLabel.setText("json")
        guard let data = try? JSONSerialization.data(withJSONObject: message, options: .prettyPrinted) else { return }
        guard let reservation = try? JSONDecoder().decode(Reservation.self, from: data) else { return }
        print(reservation)
    }
}
