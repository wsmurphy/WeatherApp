//
//  Forecast.swift
//  WeatherApp
//
//  Created by Murphy, Stephen - William S on 7/19/19.
//  Copyright © 2019 Murphy. All rights reserved.
//

import Foundation

struct ForecastDay: Codable {
    var temp: Temp
    var dt: Double
    var pressure: Double
    var humidity: Double
}

struct Temp: Codable {
    var max: Double
    var min: Double
}

struct Forecast: Codable {
    var list: [ForecastDay]
    var cod: String
}
