//
//  Weather.swift
//  WeatherApp
//
//  Created by Murphy, Stephen - William S on 7/18/19.
//  Copyright © 2019 Murphy. All rights reserved.
//

import Foundation

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

// TODO: Figure out if we'll get these in the response ever and bring them in as optional
//
//struct Rain: Codable {
//    var oneHour: Double
//    var threeHour: Double
//
//    enum CodingKeys: String, CodingKey {
//        case oneHour = "1h"
//        case threeHour = "3h"
//    }
//}
//
//struct Snow: Codable {
//    var oneHour: Double
//    var threeHour: Double
//
//    enum CodingKeys: String, CodingKey {
//        case oneHour = "1h"
//        case threeHour = "3h"
//    }
//}

struct WeatherResponse: Codable {
    var coord: Coord
    var weather: [Weather]
    var base: String
    var main: Main
    var visibility: Double
    var wind: Wind
    var clouds: Clouds
//    var rain: Rain?
//    var snow: Snow?
    var dt: Double
    var timezone: Double
    var id: Double
    var name: String
    var cod: Int
}
