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
    fileprivate let baseAPIURL = "http://api.openweathermap.org/data/2.5/"
    fileprivate let weatherAPIPart = "weather"
    fileprivate let forecastAPIPart = "forecast"
    fileprivate let unitIdentifier = "imperial"

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionsLabel: UILabel!
    @IBOutlet weak var conditionsIcon: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var forecastStackView: UIStackView!

    var weather: WeatherConditions?
    var forecast: WeatherForecast?

    var weatherConditionsLoaded = false

    var dateFormatter: DateFormatter

    var zip: String? {
        didSet {
            if zip != nil {
                loadWeatherConditions()
                loadWeatherForecast()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h a" // Hour only

        super.init(coder: aDecoder)
    }

    func loadWeatherConditions() {
        let parameterDictionary = ["appid": weatherAPIKey, "zip": zip ?? "" + ",US", "units": unitIdentifier]

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
                        self.weather = WeatherConditions(dictionary: jsonResponse)
                        self.updateConditions()
                    } else {
                        self.presentError()
                    }

                case .failure(let error):
                    print("Request failed with error: \(error)")

                    self.presentError()
                }
        }
    }

    func loadWeatherForecast() {
        let parameterDictionary = ["appid" : weatherAPIKey, "zip" : zip ?? "" + ",US", "units": unitIdentifier]

        let url = baseAPIURL + "/" + forecastAPIPart

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
                    self.forecast = WeatherForecast(dictionary: jsonResponse)
                    self.updateForecast()

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

    func updateConditions() {
        if let weather = weather {
            conditionsLabel.text = weather.conditions
            temperatureLabel.text = "\(weather.temperature)° F"
            locationLabel.text = weather.cityName

            updateConditionsIcon()
        }
    }

    func updateConditionsIcon() {
        conditionsIcon.isHidden = false
        switch weather?.conditionCode ?? 0 {
        case 200...299:
            conditionsIcon.image = #imageLiteral(resourceName: "icons8storm")
        case 300...599:
            conditionsIcon.image = #imageLiteral(resourceName: "icons8rain")
        case 600...699:
            conditionsIcon.image = #imageLiteral(resourceName: "icons8snow")
        case 700...799:
            conditionsIcon.image = #imageLiteral(resourceName: "icons8haze")
        case 800:
            conditionsIcon.image = #imageLiteral(resourceName: "icons8sun")
        case 801...899:
            conditionsIcon.image = #imageLiteral(resourceName: "icons8clouds")
        case 900...999:
            //Severe, no icons for this
            conditionsIcon.isHidden = true
        default:
            conditionsIcon.isHidden = true
        }
    }

    func updateForecast() {
        guard let forecast = forecast else {
            return
        }

        let count = forecast.forecast.count > 3 ? 3 : forecast.forecast.count

        for i in 0..<count {
            if let forecastView = ForecastView.instantiateFromNib() {
                forecastView.conditionsLabel.text = forecast.forecast[i].conditions
                forecastView.tempLabel.text = "\(forecast.forecast[i].temperature)° F"

                if let date = forecast.forecast[i].date {
                    forecastView.timeLabel.text = dateFormatter.string(from: date)
                }

                forecastStackView.addArrangedSubview(forecastView)
            }
        }

        forecastStackView.distribution = .fillEqually
    }

}
