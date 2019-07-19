//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Murphy, Stephen - William S on 7/18/19.
//  Copyright © 2019 Murphy. All rights reserved.
//

import UIKit

class CurrentWeatherViewController: UIViewController {

    var viewModel = CurrentWeatherViewModel()
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var currentConditionsLabel: UILabel!
    
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

        navigationController?.navigationBar.topItem?.title = viewModel.currentCityText
    }


}

extension CurrentWeatherViewController: CurrentWeatherViewModelDelegate {
    func weatherDidUpdate() {
        updateWeatherLabels()
    }
}
