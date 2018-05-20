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

    var usage: String?
    var reservation: Reservation?

    @IBOutlet var valueLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        guard let editContext = context as? EditObject else { return }

        usage = editContext.usage
        reservation = editContext.reservation
        crownSequencer.delegate = self

        guard reservation != nil else { return }

        if usage == "party" {
            valueLabel.setText("\(reservation!.partySize)")
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        crownSequencer.focus()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func plusTapped() {
        guard reservation != nil else { return }

        if usage == "party" {
            reservation?.partySize += 1
            valueLabel.setText("\(reservation!.partySize)")
        }
    }

    @IBAction func minusTapped() {
        guard reservation != nil, reservation!.partySize >= 1 else { return }

        if usage == "party" {
            reservation?.partySize -= 1
            valueLabel.setText("\(reservation!.partySize)")
        }
    }

    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        return reservation!
    }
}

extension StepperInterfaceController: WKCrownDelegate {
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        if rotationalDelta > 0 {
            plusTapped()
        } else {
            minusTapped()
        }
    }
}
