//
//  Weather.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/26/26.
//

struct Coord: Codable {
    var lon: Double
    var lat: Double
}

struct Weather: Codable {
    var id: Int
    var main: String
    var description: String
    var icon: String
}

struct Wind: Codable {
    var speed: Double
    var deg: Double
}

struct Clouds: Codable {
    var all: Int
}

struct Main: Codable {
    var temp: Double
    var pressure: Double
    var humidity: Double
    var temp_min: Double
    var temp_max: Double
    var sea_level: Double?
    var grnd_level: Double?
}

struct WeatherResponse: Codable {
    var coord: Coord
    var weather: [Weather]
    var base: String
    var main: Main
    var visibility: Double
    var wind: Wind
    var clouds: Clouds
    var dt: Double
    var timezone: Double
    var id: Double
    var name: String
    var cod: Int
}
