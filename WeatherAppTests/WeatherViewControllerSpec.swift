//
//  WeatherViewControllerSpec.swift
//  WeatherApp
//
//  Created by Murphy, Stephen - William S on 2/18/17.
//  Copyright © 2017 Stephen Murphy. All rights reserved.
//

import UIKit
import Quick
import Nimble
@testable import WeatherApp

class WeatherViewControllerSpec: QuickSpec {
    
    override func spec() {
        var weatherVC: WeatherViewController!

        beforeEach {
            let storyboard = UIStoryboard(name: "Main",
                                          bundle: Bundle(for: self.classForCoder))
            weatherVC = storyboard.instantiateViewController(withIdentifier: "WeatherViewController") as! WeatherViewController

            UIApplication.shared.keyWindow!.rootViewController = weatherVC
            let _ = weatherVC.view
        }

        describe(".loadWeatherConditions") {
            context("Weather is successfully loaded") {
                it("Displays weather content for Charlotte") {
                    weatherVC.zip = "28227"

                    expect(weatherVC.weatherConditionsLoaded).toEventually(beTrue(), timeout: 5.0, pollInterval: 1.0, description: "Loaded conditions")

                    expect(weatherVC.weather).toEventually(beAnInstanceOf(WeatherConditions.self), timeout: 5.0, pollInterval: 1.0, description: "Weather object")

                    expect(weatherVC.weather?.cityName).toEventually(match("Charlotte"), timeout: 5.0, pollInterval: 1.0, description: "City Name")
                }

                it("Displays weather content for Salisbury") {
                    weatherVC.zip = "28146"

                    expect(weatherVC.weatherConditionsLoaded).toEventually(beTrue(), timeout: 5.0, pollInterval: 1.0, description: "Loaded conditions")

                    expect(weatherVC.weather).toEventually(beAnInstanceOf(WeatherConditions.self), timeout: 5.0, pollInterval: 1.0, description: "Weather object")

                    expect(weatherVC.weather?.cityName).toEventually(match("Salisbury"), timeout: 5.0, pollInterval: 1.0, description: "City Name")
                }
            }
        }
    }
}
