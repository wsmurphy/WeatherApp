//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/26/26.
//

import Foundation
import Combine

class WeatherViewModel {
    @Published var weather: WeatherResponse?
    var location: String = "location"
    
    func loadWeather() {
        WeatherService.shared.loadWeather(for: location) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    self.weather = weather
                case .failure:
                    break
                }
            }
        }
    }
}
