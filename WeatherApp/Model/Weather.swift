//
//  Weather.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/26/26.
//

struct Coordinates: Codable {
    let longitude: Double
    let latitude: Double
    
    enum CodingKeys: String, CodingKey {
        case longitude = "lon"
        case latitude = "lat"
    }
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Wind: Codable {
    let speed: Double
    let degrees: Double
    
    enum CodingKeys: String, CodingKey {
        case speed
        case degrees = "deg"
    }
}

struct Clouds: Codable {
    let all: Int
}

struct Main: Codable {
    let temp: Double
    let pressure: Double
    let humidity: Double
    let tempMin: Double
    let tempMax: Double
    let seaLevel: Double?
    let grndLevel: Double?
}

struct SunCycle: Codable {
    let sunrise: Double
    let sunset: Double
}

struct WeatherResponse: Codable {
    let coord: Coordinates
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Double
    let wind: Wind
    let clouds: Clouds
    let dt: Double
    let timezone: Double
    let id: Double
    let name: String
    let sys: SunCycle?
}
