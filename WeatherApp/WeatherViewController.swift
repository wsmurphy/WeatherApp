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
            
            //Get the weather conditions
            Alamofire.request(.GET, weatherAPIURL, parameters: ["appid" : weatherAPIKey, "q" : cityName, "units": "imperial"])
                .validate(contentType: ["application/json"])
                .responseJSON { response in
                    switch response.result {
                    case .Success(let JSON):
                        
                        guard let jsonResponse = JSON as? [NSObject : AnyObject] else {
                            print("Error parsing JSON")
                            return
                        }
                        
                        if let weather = jsonResponse["weather"]![0] as? [NSObject : AnyObject] {
                            if let description = weather["description"] as? String {
                                self.conditionsLabel.text = description
                            }
                        }
                        
                        if let main = jsonResponse["main"] as? [NSObject : AnyObject] {
                            if let temp = main["temp"] as? Double {
                                self.temperatureLabel.text = "\(Int(temp))°"
                            }
                        }
                        
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                        
                        //Present error and head back to menu after user response
                        let alertController = UIAlertController(title: "Error", message: "Error getting weather. Please try again", preferredStyle: .Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .Default) { action in
                                self.navigationController?.popViewControllerAnimated(animated)
                            })
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
            }
        }

    }

}
