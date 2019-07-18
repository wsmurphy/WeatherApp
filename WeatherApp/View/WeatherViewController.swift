//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Murphy, Stephen - William S on 7/18/19.
//  Copyright © 2019 Murphy. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {

    var viewModel = WeatherViewModel()
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var currentConditionsLabel: UILabel!
    @IBOutlet weak var currentCityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        viewModel.getLatestWeather()
    }

    override func viewWillAppear(_ animated: Bool) {
        updateWeatherLabels()
    }

    func updateWeatherLabels() {
        currentTempLabel.text = viewModel.currentTempText
        currentConditionsLabel.text = viewModel.currentConditionsText
        currentCityLabel.text = viewModel.currentCityText
    }


}

extension WeatherViewController: WeatherViewModelDelegate {
    func weatherDidUpdate() {
        updateWeatherLabels()
    }
}
