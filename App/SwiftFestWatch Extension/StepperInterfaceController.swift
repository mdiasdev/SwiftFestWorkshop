//
//  StepperInterfaceController.swift
//  SwiftFestWatch Extension
//
//  Created by Matt Dias on 5/20/18.
//  Copyright © 2018 Matt Dias. All rights reserved.
//

import WatchKit
import Foundation

typealias EditObject = (usage: String, reservation: Reservation)

class StepperInterfaceController: WKInterfaceController {

    @IBOutlet var valueLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        guard let editContext = context as? EditObject else { return }

        if editContext.usage == "party" {
            valueLabel.setText("\(editContext.reservation.partySize)")
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func plusTapped() {
    }
    @IBAction func minusTapped() {
    }
}
