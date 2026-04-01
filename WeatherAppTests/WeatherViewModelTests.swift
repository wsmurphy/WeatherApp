//
//  WeatherViewModelTests.swift
//  WeatherAppTests
//
//  Created by Stephen Murphy on 3/30/26.
//

import XCTest
import CoreLocation
import Combine
@testable import WeatherApp

class MockWeatherService: WeatherServicing {
    var loadWeatherResult: Result<WeatherResponse, Error>?
    var loadForecastResult: Result<Forecast, Error>?
    
    func loadWeather(for coordinate: CLLocationCoordinate2D) async throws -> WeatherResponse {
        if let result = loadWeatherResult {
            switch result {
            case .success(let response):
                return response
            case .failure(let error):
                throw error
            }
        }
        fatalError("Mock not set up")
    }
    
    func loadForecast(for coordinate: CLLocationCoordinate2D) async throws -> Forecast {
        if let result = loadForecastResult {
            switch result {
            case .success(let forecast):
                return forecast
            case .failure(let error):
                throw error
            }
        }
        fatalError("Mock not set up")
    }
}

class MockLocationManager: LocationManaging {
    @Published var locationValue: CLLocation?
    @Published var locationDeniedValue: Bool = false

    var location: Published<CLLocation?>.Publisher { $locationValue }
    var locationDenied: Published<Bool>.Publisher { $locationDeniedValue }
}

class WeatherViewModelTests: XCTestCase {
    var viewModel: WeatherViewModel!
    var mockService: MockWeatherService!
    var mockLocationManager: MockLocationManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockWeatherService()
        mockLocationManager = MockLocationManager()
        viewModel = WeatherViewModel(service: mockService, locationManager: mockLocationManager)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        mockLocationManager = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInit_SetsUpLocationManagerSubscription() {
        // Test that locationDenied is set when location manager denies
        let expectation = XCTestExpectation(description: "Location denied should be set")
        
        viewModel.$locationDenied
            .dropFirst() // Skip initial value
            .sink { denied in
                XCTAssertTrue(denied)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Simulate location denied
        mockLocationManager.locationDeniedValue = true
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testLoadConditions_Success() async {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let mockWeather = WeatherResponse(
            coord: Coordinates(longitude: -122.4194, latitude: 37.7749),
            weather: [Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
            base: "stations",
            main: Main(temp: 72.0, pressure: 1013.0, humidity: 60.0, tempMin: 68.0, tempMax: 75.0, seaLevel: nil, grndLevel: nil),
            visibility: 10000.0,
            wind: Wind(speed: 5.0, degrees: 180.0),
            clouds: Clouds(all: 0),
            dt: 1640995200.0,
            timezone: -28800.0,
            id: 5391959.0,
            name: "San Francisco"
        )
        
        mockService.loadWeatherResult = .success(mockWeather)
        
        await viewModel.loadConditions(for: coordinate)
        
        XCTAssertEqual(viewModel.weather?.name, "San Francisco")
        XCTAssertEqual(viewModel.weather?.main.temp, 72.0)
    }
    
    func testLoadConditions_Failure() async {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        mockService.loadWeatherResult = .failure(NetworkError.networkError)
        
        await viewModel.loadConditions(for: coordinate)
        
        XCTAssertNil(viewModel.weather)
    }
    
    func testLoadForecast_Success() async {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let mockForecast = Forecast(
            list: [
                ForecastDay(
                    temperature: Temp(max: 75.0, min: 65.0),
                    date: 1640995200.0,
                    pressure: 1013.0,
                    humidity: 60.0,
                    precipChance: 0.0,
                    weather: [Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")]
                )
            ]
        )
        
        mockService.loadForecastResult = .success(mockForecast)
        
        await viewModel.loadForecast(for: coordinate)
        
        XCTAssertEqual(viewModel.forecast?.list.count, 1)
        XCTAssertEqual(viewModel.forecast?.list.first?.temperature.max, 75.0)
    }
    
    func testInit_LoadsWeatherAndForecast_WhenLocationProvided() {
        let expectation = XCTestExpectation(description: "Weather and forecast should be loaded")
        expectation.expectedFulfillmentCount = 2
        
        let mockWeather = WeatherResponse(
            coord: Coordinates(longitude: -122.4194, latitude: 37.7749),
            weather: [Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
            base: "stations",
            main: Main(temp: 72.0, pressure: 1013.0, humidity: 60.0, tempMin: 68.0, tempMax: 75.0, seaLevel: nil, grndLevel: nil),
            visibility: 10000.0,
            wind: Wind(speed: 5.0, degrees: 180.0),
            clouds: Clouds(all: 0),
            dt: 1640995200.0,
            timezone: -28800.0,
            id: 5391959.0,
            name: "San Francisco"
        )
        
        let mockForecast = Forecast(
            list: [
                ForecastDay(
                    temperature: Temp(max: 75.0, min: 65.0),
                    date: 1640995200.0,
                    pressure: 1013.0,
                    humidity: 60.0,
                    precipChance: 0.0,
                    weather: [Weather(id: 800, main: "Clear", description: "clear sky", icon: "01d")]
                )
            ]
        )
        
        mockService.loadWeatherResult = .success(mockWeather)
        mockService.loadForecastResult = .success(mockForecast)
        
        viewModel.$weather
            .dropFirst()
            .sink { weather in
                XCTAssertNotNil(weather)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.$forecast
            .dropFirst()
            .sink { forecast in
                XCTAssertNotNil(forecast)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Simulate location update
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        mockLocationManager.locationValue = location
        
        wait(for: [expectation], timeout: 0.5)
    }
}
