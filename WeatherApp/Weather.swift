//
//  Weather.swift
//  WeatherApp
//
//  Created by Murphy, Stephen - William S on 1/25/16.
//  Copyright © 2016 Stephen Murphy. All rights reserved.
//

import UIKit

class Weather: NSObject {
    var temperature: Double = 0
    var conditions: String = "Unknown"
    var cityName: String = "Unknown"

    init(dictionary: [AnyHashable: Any]) {
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

        if let weather = dictionary["weather"] as? [[AnyHashable: Any]], let description = weather[0]["description"] as? String {
                conditions = description
        } else {
            conditions = "Unknown"
        }
    }

}
