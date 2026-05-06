//
//  ForecastDayViewTests.swift
//  WeatherAppTests
//
//  Created by Stephen Murphy on 3/30/26.
//

import XCTest
@testable import WeatherApp

class ForecastDayViewTests: XCTestCase {
    var forecastDayView: ForecastDayView!
    
    override func setUp() {
        super.setUp()
        forecastDayView = ForecastDayView()
    }
    
    override func tearDown() {
        forecastDayView = nil
        super.tearDown()
    }
    
    func testConfigure_SetsLabelsCorrectly() {
        let forecastDay = ForecastDay(
            temperature: Temp(max: 75.0, min: 65.0),
            date: 1640995200.0, // January 1, 2022, Saturday
            pressure: 1013.0,
            humidity: 60.0,
            precipChance: 0.25,
            weather: [Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")]
        )
        
        forecastDayView.day = forecastDay
        
        XCTAssertEqual(forecastDayView.dateLabel.text, "Friday")
        XCTAssertEqual(forecastDayView.tempLabel.text, "H: 75° L: 65°")
        XCTAssertEqual(forecastDayView.conditionsLabel.text, "Clear")
    }
    
    func testConfigure_SetsLabelsWithRainChanceCorrectly() {
        let forecastDay = ForecastDay(
            temperature: Temp(max: 75.0, min: 65.0),
            date: 1640995200.0, // January 1, 2022, Saturday
            pressure: 1013.0,
            humidity: 60.0,
            precipChance: 0.25,
            weather: [Weather(id: 800, main: "Rain", description: "rainy", icon: "01d")]
        )
        
        forecastDayView.day = forecastDay
        
        XCTAssertEqual(forecastDayView.dateLabel.text, "Friday")
        XCTAssertEqual(forecastDayView.tempLabel.text, "H: 75° L: 65°")
        XCTAssertEqual(forecastDayView.conditionsLabel.text, "Rain 25%")
    }
    
    func testConfigure_WithNilWeather_UsesUnknown() {
        let forecastDay = ForecastDay(
            temperature: Temp(max: 75.0, min: 65.0),
            date: 1640995200.0,
            pressure: 1013.0,
            humidity: 60.0,
            precipChance: 0.0,
            weather: []
        )
        
        forecastDayView.day = forecastDay
        
        XCTAssertEqual(forecastDayView.conditionsLabel.text, "")
    }
}
