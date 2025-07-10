//
//  LocationManager.swift
//  GoogleMapSwiftUI
//
//  Created by Arjunan on 09/07/25.
//

import Foundation
import CoreLocation
//import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    @Published var status: CLAuthorizationStatus?
    private var lastRecordedLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        if let last = lastRecordedLocation,
           newLocation.distance(from: last) < 20 {
            return
        }

        lastRecordedLocation = newLocation
        DispatchQueue.main.async {
            self.location = newLocation.coordinate
        }

        print("📍 Got location: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}
