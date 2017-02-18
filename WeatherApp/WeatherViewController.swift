//
//  WeatherViewController.swift
//  InterviewProject
//
//  Created by Stephen Murphy on 1/24/16.
//  Copyright © 2016 Stephen Murphy. All rights reserved.
//

import UIKit
import Alamofire

class WeatherViewController: UIViewController {
    fileprivate let weatherAPIKey = "b4608d4fcb4accac0a8cc2ea6949eeb5"
    fileprivate let weatherAPIURL = "http://api.openweathermap.org/data/2.5/weather"
    fileprivate let unitIdentifier = "imperial"

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionsLabel: UILabel!

    var cityName: String? {
        didSet {
            if let cityName = cityName {
                loadWeatherConditions(cityName)
            }
        }
    }

    func loadWeatherConditions(_ cityName: String) {
        let parameterDictionary = ["appid" : weatherAPIKey, "q" : cityName, "units": unitIdentifier]

        //Get the weather conditions
        Alamofire.request(weatherAPIURL, method: .get, parameters: parameterDictionary)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .success(let JSON):

                    guard let jsonResponse = JSON as? [AnyHashable: Any] else {
                        print("Error parsing JSON")
                        return
                    }

                    //Check for successful response
                    if let returnCode = jsonResponse["cod"] as? Int, returnCode == 200 {
                        let weather = Weather(dictionary: jsonResponse)

                        self.conditionsLabel.text = weather.conditions
                        self.temperatureLabel.text = "\(Int(weather.temperature))°"
                        self.navigationItem.title = weather.cityName
                    } else {
                        self.presentError()
                    }

                case .failure(let error):
                    print("Request failed with error: \(error)")

                    self.presentError()
                }
        }
    }

    func presentError() {
        //Present error and head back to menu after user response
        let alertController = UIAlertController(title: "Error", message: "Error getting weather. Please try again", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { action in
            self.navigationController?.popViewController(animated: true)
            })
        present(alertController, animated: true, completion: nil)
    }

}
