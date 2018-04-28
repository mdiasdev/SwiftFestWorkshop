//
//  ReservationDetailsViewController.swift
//  SwiftFest
//
//  Created by Matt Dias on 4/28/18.
//  Copyright © 2018 Matt Dias. All rights reserved.
//

import UIKit
import MapKit

class ReservationDetailsViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var partySizeLabel: UILabel!
    @IBOutlet var reservationTimeLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var websiteButton: UIButton!
    @IBOutlet var phoneButton: UIButton!
    
    var reservation: Reservation?
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        //Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        if let reservation = reservation {
            let restaurant = reservation.restaurant
            
            titleLabel.text = restaurant.name
            partySizeLabel.text = "Party of: \(reservation.partySize)"
            reservationTimeLabel.text = "Reserved for: \(reservation.date)"
            websiteButton.setTitle(restaurant.website, for: .normal)
            phoneButton.setTitle(restaurant.phoneNumber, for: .normal)
            getAdressName(location: CLLocation(latitude: restaurant.latitude, longitude: restaurant.longitude))
            
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)
            self.mapView.addAnnotation(pin)
            
            let viewRegion = MKCoordinateRegion(center: pin.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            self.mapView.setRegion(viewRegion, animated: true)
        }
    }

    @IBAction func cancelTapped(_ sender: Any) {
    }
    
    private func getAdressName(location: CLLocation) {
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            guard error == nil else {
                print("\(error!)")
                return
            }
            
            if let place = placemarks?[0] {
                
                guard let streetNumber = place.subThoroughfare,
                    let street = place.thoroughfare,
                    let city = place.locality else { return }
                
                self.addressLabel.text = "\(streetNumber) \(street), \(city)"
            }
        }
    }
    
}

extension ReservationDetailsViewController: CLLocationManagerDelegate { }

extension ReservationDetailsViewController: MKMapViewDelegate { }
