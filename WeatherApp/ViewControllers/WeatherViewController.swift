//
//  WeatherViewController.swift
//  InterviewProject
//
//  Created by Stephen Murphy on 1/24/16.
//  Copyright © 2016 Stephen Murphy. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionsLabel: UILabel!
    @IBOutlet weak var conditionsIcon: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var forecastStackView: UIStackView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var changeLocationButton: UIButton!
    @IBOutlet weak var unitsSwitch: UISegmentedControl!

    var dateFormatter: DateFormatter

    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()

    required init?(coder aDecoder: NSCoder) {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h a" // Hour only

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(WeatherViewController.updateConditions), name: Notification.Name("WeatherConditionsChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WeatherViewController.updateForecast), name: Notification.Name("WeatherForecastChanged"), object: nil)
    }

    func presentError() {
        //Present error and head back to menu after user response
        let alertController = UIAlertController(title: "Error", message: "Error getting weather. Please try again", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
            })
        present(alertController, animated: true, completion: nil)
    }

    @objc func updateConditions() {
        if let weather = WeatherManager.sharedInstance.weatherConditions {
            conditionsLabel.text = weather.conditions
            temperatureLabel.text = "\(weather.temperature)\(WeatherManager.sharedInstance.units.displayString)"
            locationLabel.text = weather.cityName

            updateConditionsIcon()
        }
    }

    func updateConditionsIcon() {
        conditionsIcon.isHidden = false
        switch WeatherManager.sharedInstance.weatherConditions?.conditionCode ?? 0 {
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

    @objc func updateForecast() {
        guard let forecast = WeatherManager.sharedInstance.weatherForecast else {
            return
        }

        //Clear old views
        for view in forecastStackView.arrangedSubviews {
            forecastStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let count = forecast.forecast.count > 3 ? 3 : forecast.forecast.count
        for i in 0..<count {
            if let forecastView = ForecastView.instantiateFromNib() {
                forecastView.conditionsLabel.text = forecast.forecast[i].conditions
                forecastView.tempLabel.text = "\(forecast.forecast[i].temperature)\(WeatherManager.sharedInstance.units.displayString)"

                if let date = forecast.forecast[i].date {
                    forecastView.timeLabel.text = dateFormatter.string(from: date)
                }

                forecastStackView.addArrangedSubview(forecastView)
            }
        }

        forecastStackView.distribution = .fillEqually
    }

    @IBAction func infoButtonTapped(_ sender: Any) {
        let controller = UIAlertController(title: "About", message: "Weather icons courtesy of Icons8 under CC-BY ND 3.0 license.\nhttps://icons8.com/", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(controller, sender: nil)
    }

    @IBAction func changeLocationTapped(_ sender: Any) {
        //TODO: Placeholder
        locationManager.requestLocation()
    }

    @IBAction func unitsChanged(_ sender: Any) {
        if unitsSwitch.selectedSegmentIndex == 0 {
            WeatherManager.sharedInstance.units = .fahrenheit
        } else {
            WeatherManager.sharedInstance.units = .celcius
        }
    }

}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        geocoder.reverseGeocodeLocation(location) { (placemark, _) in
            if let placemark = placemark?.last,
                let postalCode = placemark.postalCode {
                WeatherManager.sharedInstance.zip = postalCode
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error)")
    }
}
