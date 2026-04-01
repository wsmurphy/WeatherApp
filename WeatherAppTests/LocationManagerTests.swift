//
//  LocationManagerTests.swift
//  WeatherAppTests
//
//  Created by Stephen Murphy on 3/30/26.
//

import XCTest
import CoreLocation
@testable import WeatherApp

class LocationManagerTests: XCTestCase {
    var locationManager: LocationManager!
    
    override func setUp() {
        super.setUp()
        locationManager = LocationManager()
    }
    
    override func tearDown() {
        locationManager = nil
        super.tearDown()
    }

    func testLocationManagerDidUpdateLocations_SetsLocation() {
        let locations = [CLLocation(latitude: 37.7749, longitude: -122.4194)]

        let mockCLManager = CLLocationManager()
        locationManager.locationManager(mockCLManager, didUpdateLocations: locations)

        XCTAssertNotNil(locationManager.locationValue)
        XCTAssertEqual(locationManager.locationValue?.coordinate.latitude, 37.7749)
        XCTAssertEqual(locationManager.locationValue?.coordinate.longitude, -122.4194)
    }

    func testLocationManagerDidFailWithError_DoesNotSetLocationDenied() {
        let error = NSError(domain: kCLErrorDomain, code: CLError.locationUnknown.rawValue, userInfo: nil)
        let mockCLManager = CLLocationManager()

        locationManager.locationManager(mockCLManager, didFailWithError: error)

        XCTAssertFalse(locationManager.locationDeniedValue)
    }
}
