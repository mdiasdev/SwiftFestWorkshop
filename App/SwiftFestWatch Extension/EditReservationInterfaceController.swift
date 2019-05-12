//
//  EditReservationInterfaceController.swift
//  SwiftFestWatch Extension
//
//  Created by Matthew Dias on 5/13/18.
//  Copyright © 2018 Matt Dias. All rights reserved.
//

import WatchKit
import Foundation


class EditReservationInterfaceController: WKInterfaceController {

    var reservation: Reservation?
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        guard let reservation = context as? Reservation else { return }
        self.reservation = reservation
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        guard let reservation = self.reservation  else { return nil }
        
        return (segueIdentifier, reservation)
    }

}
