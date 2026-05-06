//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/29/26.
//

import CoreLocation
import Combine

protocol LocationManaging {
    var location: Published<CLLocation?>.Publisher { get }
    var locationDenied: Published<Bool>.Publisher { get }
}

class LocationManager: NSObject, CLLocationManagerDelegate, LocationManaging {
    @Published private(set) var locationValue: CLLocation?
    @Published private(set) var locationDeniedValue: Bool = false

    var location: Published<CLLocation?>.Publisher { $locationValue }
    var locationDenied: Published<Bool>.Publisher { $locationDeniedValue }

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.requestWhenInUseAuthorization()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            locationDeniedValue = true
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationValue = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error.localizedDescription)
    }
}
