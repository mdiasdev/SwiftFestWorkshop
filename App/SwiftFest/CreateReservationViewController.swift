//
//  CreateReservationViewController.swift
//  SwiftFest
//
//  Created by Matthew Dias on 4/15/18.
//  Copyright © 2018 Matt Dias. All rights reserved.
//

import UIKit

class CreateReservationViewController: UIViewController {

    var restaurantId = -1

    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var partySizeTextField: UITextField!
    @IBOutlet var dateTextField: UITextField!

    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dateFormatter.dateFormat = "MM/dd/yyy, HH:mm"
    }

    func togglePicker() {
        self.datePicker.isHidden = !datePicker.isHidden

        dateTextField.text = dateFormatter.string(from: datePicker.date)
    }

    @IBAction func tappedReserve(_ sender: Any) {
        dateTextField.resignFirstResponder()
        partySizeTextField.resignFirstResponder()

        var request = URLRequest(url: URL(string: "http://localhost:8080/reservation")!)
        request.httpMethod = "POST"
        request.httpBody = getPayload()
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else { return }

            guard let httpResponse = response as? HTTPURLResponse else { return }

            if httpResponse.statusCode > 200 {
                print("\(httpResponse.statusCode): \(String(data: data!, encoding: .utf8)!)")
            }
        }

        task.resume()
    }

    func getPayload() -> Data {
        var payload = [String: Any]()
        payload["restaurantId"] = -1//restaurantId
        payload["partySize"] = Int(partySizeTextField.text!)!
        payload["date"] = dateTextField.text

        return try! JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
    }
}

extension CreateReservationViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        if textField == dateTextField {
            partySizeTextField.resignFirstResponder()
            togglePicker()
            return false
        }
        
        return true
    }
}
