//
//  Weather.swift
//  WeatherApp
//
//  Created by Murphy, Stephen - William S on 7/18/19.
//  Copyright © 2019 Murphy. All rights reserved.
//

import Foundation

class Weather {
    var temperature: Double = 0
    var conditions: String = "Unknown"
    var cityName: String = "Unknown"
    var conditionCode: Int = 0
    var date: Date?

    //Custom JSON parsing logic
    init(dictionary: [String: Any]) {
        if let rawDate = dictionary["dt"] as? Double {
            date = Date(timeIntervalSince1970: rawDate)
        }

        if let name = dictionary["name"] as? String {
            cityName = name
        } else {
            cityName = "Unknown"
        }

        if let mainDetails = dictionary["main"] as? [String: Any], let temp = mainDetails["temp"] as? Double {
            temperature = temp
        } else {
            temperature = 0
        }

        if let weather = dictionary["weather"] as? [[String: Any]] {
            if let description = weather[0]["main"] as? String {
                conditions = description
            }

            if let code = weather[0]["id"] as? Int {
                conditionCode = code
            }
        } else {
            conditions = "Unknown"
        }
    }

    init() {
        temperature = 50
        conditions = "Clear"
        cityName = "Any Town"
        conditionCode = 100
        date = Date()
    }
}
