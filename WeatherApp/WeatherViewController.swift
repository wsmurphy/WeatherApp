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
    private let weatherAPIKey = "b4608d4fcb4accac0a8cc2ea6949eeb5"
    private let weatherAPIURL = "http://api.openweathermap.org/data/2.5/weather"
    private let unitIdentifier = "imperial"

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionsLabel: UILabel!
    
    var cityName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let cityName = cityName {
            //Set the city name
            self.navigationItem.title = cityName
            

        }

    }

    func loadWeatherConditions(cityName: String) {
        let parameterDictionary = ["appid" : weatherAPIKey, "q" : cityName, "units": unitIdentifier]

        //Get the weather conditions
        Alamofire.request(.GET, weatherAPIURL, parameters: parameterDictionary)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                switch response.result {
                case .Success(let JSON):

                    guard let jsonResponse = JSON as? [NSObject : AnyObject] else {
                        print("Error parsing JSON")
                        return
                    }

                    //Check for successful response
                    if let returnCode = jsonResponse["cod"] as? Int where returnCode == 200 {
                        let weather = Weather(dictionary: jsonResponse)

                        self.conditionsLabel.text = weather.conditions
                        self.temperatureLabel.text = "\(Int(weather.temperature))°"
                    } else {
                        self.presentError()
                    }

                case .Failure(let error):
                    print("Request failed with error: \(error)")

                    self.presentError()
                }
        }
    }

    func presentError() {
        //Present error and head back to menu after user response
        let alertController = UIAlertController(title: "Error", message: "Error getting weather. Please try again", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default) { action in
            self.navigationController?.popViewControllerAnimated(true)
            })
        presentViewController(alertController, animated: true, completion: nil)
    }

}
