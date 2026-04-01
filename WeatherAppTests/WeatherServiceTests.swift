//
//  WeatherServiceTests.swift
//  WeatherAppTests
//
//  Created by Stephen Murphy on 3/30/26.
//

import XCTest
import CoreLocation
@testable import WeatherApp

class WeatherServiceTests: XCTestCase {
    var service: WeatherService!
    
    override func setUp() {
        super.setUp()
        service = WeatherService()
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    // For better testing, we should refactor WeatherService to accept URLSessionProtocol
    // But for now, let's test the decoding with mock data
    
    func testWeatherResponseDecoding() throws {
        let json = """
        {
            "coord": {"lon": -122.4194, "lat": 37.7749},
            "weather": [{"id": 800, "main": "Clear", "description": "clear sky", "icon": "01d"}],
            "base": "stations",
            "main": {"temp": 72.0, "pressure": 1013.0, "humidity": 60.0, "temp_min": 68.0, "temp_max": 75.0},
            "visibility": 10000,
            "wind": {"speed": 5.0, "deg": 180.0},
            "clouds": {"all": 0},
            "dt": 1640995200,
            "timezone": -28800,
            "id": 5391959,
            "name": "San Francisco"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(WeatherResponse.self, from: json)
        
        XCTAssertEqual(response.name, "San Francisco")
        XCTAssertEqual(response.coord.latitude, 37.7749)
        XCTAssertEqual(response.coord.longitude, -122.4194)
        XCTAssertEqual(response.weather.first?.main, "Clear")
        XCTAssertEqual(response.main.temp, 72.0)
    }
    
    func testForecastDecoding() throws {
        let json = """
        {
            "list": [
                {
                    "temp": {"max": 75.0, "min": 65.0},
                    "dt": 1640995200,
                    "pressure": 1013.0,
                    "humidity": 60.0,
                    "pop": 0.0,
                    "weather": [{"id": 800, "main": "Clear", "description": "clear sky", "icon": "01d"}]
                }
            ]
        }
        """.data(using: .utf8)!
        
        let forecast = try JSONDecoder().decode(Forecast.self, from: json)
        
        XCTAssertEqual(forecast.list.count, 1)
        XCTAssertEqual(forecast.list.first?.temperature.max, 75.0)
        XCTAssertEqual(forecast.list.first?.temperature.min, 65.0)
        XCTAssertEqual(forecast.list.first?.weather.first?.main, "Clear")
    }
}
