//
//  Forecast.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/28/26.
//

struct ForecastDay: Codable {
    let temperature: Temp
    let date: Double
    let pressure: Double
    let humidity: Double
    let precipChance: Double
    let weather: [Weather]
    
    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case date = "dt"
        case pressure
        case humidity
        case precipChance = "pop"
        case weather
    }
}

struct Temp: Codable {
    let max: Double
    let min: Double
}

struct Forecast: Codable {
    let list: [ForecastDay]
}
