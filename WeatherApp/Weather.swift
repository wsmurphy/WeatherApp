//
//  Weather.swift
//  WeatherApp
//
//  Created by Murphy, Stephen - William S on 1/25/16.
//  Copyright © 2016 Stephen Murphy. All rights reserved.
//

import UIKit

class Weather: NSObject {
    var temperature: Double
    var conditions: String

    override init() {
        temperature = 0
        conditions = "Unknown"
    }

    init(dictionary: [NSObject : AnyObject]) {
        if let mainDetails = dictionary["main"] as? [NSObject : AnyObject], temp = mainDetails["temp"] as? Double {
            temperature = temp
        } else {
            temperature = 0
        }

        if let weather = dictionary["weather"]![0] as? [NSObject : AnyObject], description = weather["description"] as? String {
                conditions = description
        } else {
            conditions = "Unknown"
        }
    }

}
