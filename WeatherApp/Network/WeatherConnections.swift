//
//  WeatherConnections.swift
//  WeatherApp
//
//  Created by Murphy, Stephen - William S on 7/18/19.
//  Copyright © 2019 Murphy. All rights reserved.
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

class WeatherConnections {
    fileprivate static let weatherAPIKey = "b4608d4fcb4accac0a8cc2ea6949eeb5"
    fileprivate static let baseAPIURL = "https://api.openweathermap.org/data/2.5/"
    fileprivate static let weatherAPIPart = "weather"
    fileprivate static let forecastAPIPart = "forecast"

    static func loadWeather(zip: String, units: Units = Units.fahrenheit, completion: @escaping (WeatherResponse?) -> Void)  {
        let parameterDictionary = ["appid": weatherAPIKey, "zip": zip + ",US", "units": units.rawValue]
        let url = baseAPIURL + "/" + weatherAPIPart

        //Get the weather conditions
        Alamofire.request(url, method: .get, parameters: parameterDictionary)
            .validate(contentType: ["application/json"])
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success(let data):
                    do {
                        let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)

                        //Check for successful response
                        if weather.cod == 200 {
                            completion(weather)
                        } else {
                            completion(nil)
                        }
                    } catch {
                        completion(nil)
                    }

                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completion(nil)
            }
        })
    }

    static func loadForecast(zip: String, units: Units = Units.fahrenheit, completion: @escaping (Forecast?) -> Void) {
        //TODO: Correct this to the Forecast API call
        let parameterDictionary = ["appid": weatherAPIKey, "zip": zip + ",US", "units": units.rawValue]
        let url = "\(baseAPIURL)/forecast/daily"

        //Get the weather conditions
        Alamofire.request(url, method: .get, parameters: parameterDictionary)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):

                    guard let jsonResponse = JSON as? [String: Any] else {
                        print("Error parsing JSON")
                        completion(nil)
                        return
                    }

                    //Check for successful response
                    if let returnCode = jsonResponse["cod"] as? String, returnCode == "200" {
                        completion(Forecast(dictionary: jsonResponse))
                    } else {
                        completion(nil)
                    }

                case .failure(let error):
                    print("Request failed with error: \(error)")
                    completion(nil)
                }
        }
    }
}
