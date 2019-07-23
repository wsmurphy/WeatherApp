//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Murphy, Stephen - William S on 7/18/19.
//  Copyright © 2019 Murphy. All rights reserved.
//

protocol CurrentWeatherViewModelDelegate {
    func weatherDidUpdate()
}

class CurrentWeatherViewModel {
    var delegate: CurrentWeatherViewModelDelegate?
    var weather: WeatherResponse?

    //Presentation variables
    var currentTempText: String {
        if let temp = self.weather?.main.temp {
            return "\(temp)°"
        } else {
            return "- -°"
        }
    }
    var currentConditionsText: String { return self.weather?.weather[0].description ?? "Unknown" }
    var currentCityText: String { return self.weather?.name ?? "Locating..." }

    func getLatestWeather() {
        //Get latest Weather
        WeatherConnections.loadWeather(zip: "28146") { [weak self] (newWeather) in
            guard let strongSelf = self else { return }
            strongSelf.weather = newWeather

            //Indicate successful completion
            strongSelf.delegate?.weatherDidUpdate()
        }
    }
}
