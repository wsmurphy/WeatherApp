//
//  Forecast.swift
//  WeatherApp
//
//  Created by Murphy, Stephen - William S on 7/19/19.
//  Copyright © 2019 Murphy. All rights reserved.
//

import Foundation

class Forecast {
    var list: [ForecastDay] = []
    
    //Custom JSON parsing logic
    init(dictionary: [String: Any]) {
        if let weatherList = dictionary["list"] as? [[String: Any]] {
            for item in weatherList {
                let fd = ForecastDay(dictionary: item)
                list.append(fd)
            }
        }
    }
}


class ForecastDay {
    var highTemp: Double = 0
    var lowTemp: Double = 0
    var date: Date?
    var pressure: Double?
    var humidity: Double?

    //Custom JSON parsing logic
    init(dictionary: [String: Any]) {
        if let rawDate = dictionary["dt"] as? Double {
            date = Date(timeIntervalSince1970: rawDate)
        }

        if let tempArray = dictionary["temp"] as? [String: Any] {
            highTemp = tempArray["max"] as? Double ?? 0.0
            lowTemp = tempArray["min"] as? Double ?? 0.0
        }

        pressure = dictionary["pressure"] as? Double ?? 0
        humidity = dictionary["humidity"] as? Double ?? 0
    }
}
