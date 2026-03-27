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
    var location: String = "Granite Quarry,NC,USA"
    
    init () {
        Task {
            await loadWeather()
        }
    }
    
    func loadWeather() async {
        do {
            let response = try await WeatherService.shared.loadWeather(for: location)
            weather = response
        } catch {
            print(error.localizedDescription)
        }
    }
}
