//
//  WeatherForecast.swift
//  WeatherApp
//
//  Created by Murphy, Stephen - William S on 11/13/17.
//  Copyright © 2017 Stephen Murphy. All rights reserved.
//

import UIKit

class WeatherForecast: NSObject {
    var city: String
    var forecast = [WeatherConditions]()

    init(dictionary: [AnyHashable: Any]) {
        city = dictionary["city"] as? String ?? ""

        if let jsonArray = dictionary["list"] as? [[AnyHashable: Any]] {
            for i in 0..<jsonArray.count {
                let conditions = WeatherConditions(dictionary: jsonArray[i])
                forecast.append(conditions)
            }
        }
    }
}
