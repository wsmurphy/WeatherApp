//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Murphy, Stephen - William S on 11/14/17.
//  Copyright © 2017 Stephen Murphy. All rights reserved.
//

import Alamofire

enum Units: String {
    case fahrenheit = "imperial"
    case celcius = "metric"

    var displayString: String {
        switch self {
        case .fahrenheit:
            return "° F"
        case .celcius:
            return "° C"
        }
    }
}

class WeatherManager {
    static let sharedInstance = WeatherManager()

    fileprivate let weatherAPIKey = "b4608d4fcb4accac0a8cc2ea6949eeb5"
    fileprivate let baseAPIURL = "http://api.openweathermap.org/data/2.5/"
    fileprivate let weatherAPIPart = "weather"
    fileprivate let forecastAPIPart = "forecast"

    public var weatherConditions: WeatherConditions?
    public var weatherForecast: WeatherForecast?

    var weatherConditionsLoaded = false

    public var units = Units.fahrenheit {
        didSet {
            reloadWeather()
        }
    }

    public var zip = "" {
        didSet {
            reloadWeather()
        }
    }

    func reloadWeather() {
        loadWeatherForecast()
        loadWeatherConditions()
    }

    func loadWeatherConditions() {
        let parameterDictionary = ["appid": weatherAPIKey, "zip": zip + ",US", "units": units.rawValue]
        let url = baseAPIURL + "/" + weatherAPIPart

        //Get the weather conditions
        Alamofire.request(url, method: .get, parameters: parameterDictionary)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                self.weatherConditionsLoaded = true

                switch response.result {
                case .success(let JSON):

                    guard let jsonResponse = JSON as? [AnyHashable: Any] else {
                        print("Error parsing JSON")
                        return
                    }

                    //Check for successful response
                    if let returnCode = jsonResponse["cod"] as? Int, returnCode == 200 {
                        self.weatherConditions = WeatherConditions(dictionary: jsonResponse)
                        NotificationCenter.default.post(name: Notification.Name("WeatherConditionsChanged"), object: nil)
                    } else {
                        // self.presentError()
                    }

                case .failure(let error):
                    print("Request failed with error: \(error)")
                    // self.presentError() //TODO: Restore errors
                }
        }
    }

    func loadWeatherForecast() {
        let parameterDictionary = ["appid": weatherAPIKey, "zip": zip + ",US", "units": units.rawValue]
        let url = baseAPIURL + "/" + forecastAPIPart

        //Get the weather conditions
        Alamofire.request(url, method: .get, parameters: parameterDictionary)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):

                    guard let jsonResponse = JSON as? [AnyHashable: Any] else {
                        print("Error parsing JSON")
                        return
                    }

                    //Check for successful response
                    self.weatherForecast = WeatherForecast(dictionary: jsonResponse)
                    NotificationCenter.default.post(name: Notification.Name("WeatherForecastChanged"), object: nil)
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    //                    self.presentError()
                }
        }
    }
}
