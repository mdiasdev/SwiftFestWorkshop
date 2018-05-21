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
    let dateFormatter = DateFormatter()

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
        } else if usage == "time" {

            dateFormatter.dateFormat = "MM/dd/yyyy, HH:mm"
            let reservationDate = dateFormatter.date(from: reservation!.date)!
            let components = Calendar.current.dateComponents([.hour, .minute], from: reservationDate)
            let time = String(format: "%02i:%02i", components.hour!, components.minute!)

            valueLabel.setText(time)
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

        var request = URLRequest(url: URL(string: "http://\(baseURL):8080/reservation/\(reservation!.id)")!)
        request.httpMethod = "PUT"

        let payload: [String: Any] = ["partySize": reservation!.partySize,
                                      "date": reservation!.date]
        request.httpBody = try! JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil, data != nil else { print(error.debugDescription); return}
            guard let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? [String: Any] else { return }

            UserDefaults.standard.set(json, forKey: "reservation")
        }
        task.resume()
    }

    @IBAction func plusTapped() {
        guard reservation != nil else { return }

        if usage == "party" {
            reservation?.partySize += 1
            valueLabel.setText("\(reservation!.partySize)")
        } else if usage == "time" {
            let reservationDate = dateFormatter.date(from: reservation!.date)!
            var components = Calendar.current.dateComponents([.month, .day, .year, .hour, .minute], from: reservationDate)
            if components.minute! + 1 % 60 <= 59 {
                components.minute! += 1
            } else {
                components.minute! = 0
                components.hour! += 1
            }
            reservation?.date = "\(components.month!)/\(components.day!)/\(components.year!), \(components.hour!):\(components.minute!)"
            valueLabel.setText("\(components.hour!):\(components.minute!)")
        }
    }

    @IBAction func minusTapped() {
        guard reservation != nil, reservation!.partySize >= 1 else { return }

        if usage == "party" {
            reservation?.partySize -= 1
            valueLabel.setText("\(reservation!.partySize)")
        } else if usage == "time" {
            let reservationDate = dateFormatter.date(from: reservation!.date)!
            var components = Calendar.current.dateComponents([.month, .day, .year, .hour, .minute], from: reservationDate)
            if components.minute! - 1 % 60 >= 1 {
                components.minute! -= 1
            } else if components.hour! - 1 % 24 >= 1 {
                components.minute! = 0
                components.hour! -= 1
            }
            reservation?.date = "\(components.month!)/\(components.day!)/\(components.year!), \(components.hour!):\(components.minute!)"
            valueLabel.setText("\(components.hour!):\(components.minute!)")
        }
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
