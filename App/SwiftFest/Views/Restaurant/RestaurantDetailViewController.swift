//
//  RestaurantDetailViewController.swift
//  SwiftFest
//
//  Created by Matthew Dias on 10/30/17.
//  Copyright © 2017 Matt Dias. All rights reserved.
//

import UIKit
import MapKit

protocol CreateReservationDelegate: class {
    func pop()
}

class RestaurantDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet var favoriteButton: UIBarButtonItem!
    
    var restaurant: Restaurant?
    var locationManager = CLLocationManager()

    // This should come from the server, but for demo purposes,
    // we just mark it as a favorite locally
    private var isFavorite = false

    override func viewDidLoad() {
        super.viewDidLoad()

        favoriteButton.accessibilityLabel = "favorite"
        mapView.accessibilityElementsHidden = true


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

        if let restaurant = restaurant {
            titleLabel.text = restaurant.name
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let controller = segue.destination as? CreateReservationViewController {
            controller.restaurantId = restaurant?.id ?? -1
            controller.delegate = self
        }
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
  
    @IBAction func websiteTapped(_ sender: Any) {
        let url = URL(string: restaurant!.website)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func phoneTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Phone Ringing", message: "For this demo, we didn't want to call the restaurants...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didTapHeart(_ sender: UIBarButtonItem) {
        isFavorite.toggle()
        if isFavorite {
            sender.image = #imageLiteral(resourceName: "favorited")
            favoriteButton.accessibilityLabel = "favorited"
            favoriteButton.accessibilityHint = "double tap to unfavorite"
        } else {
            sender.image = #imageLiteral(resourceName: "favoritable")
            favoriteButton.accessibilityLabel = "favorite"
            favoriteButton.accessibilityHint = ""
        }
    }
}

extension RestaurantDetailViewController: CreateReservationDelegate {
    func pop() {
        self.navigationController?.popToRootViewController(animated: false)
    }
}

extension RestaurantDetailViewController: CLLocationManagerDelegate { }

extension RestaurantDetailViewController: MKMapViewDelegate { }
