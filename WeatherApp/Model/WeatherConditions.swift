//
//  WeatherConditions.swift
//  WeatherApp
//
//  Created by Murphy, Stephen - William S on 1/25/16.
//  Copyright © 2016 Stephen Murphy. All rights reserved.
//

import UIKit

class WeatherConditions: NSObject {
    var temperature: Double = 0
    var conditions: String = "Unknown"
    var cityName: String = "Unknown"
    var conditionCode: Int = 0
    var date: Date?

    init(dictionary: [AnyHashable: Any]) {

        if let rawDate = dictionary["dt"] as? Double {
            date = Date(timeIntervalSince1970: rawDate)
        }

        if let name = dictionary["name"] as? String {
            cityName = name
        } else {
            cityName = "Unknown"
        }

        if let mainDetails = dictionary["main"] as? [AnyHashable: Any], let temp = mainDetails["temp"] as? Double {
            temperature = temp
        } else {
            temperature = 0
        }

        if let weather = dictionary["weather"] as? [[AnyHashable: Any]] {
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
}
