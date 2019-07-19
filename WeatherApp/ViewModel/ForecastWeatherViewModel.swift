//
//  ForecastWeatherViewModel.swift
//  WeatherApp
//
//  Created by Murphy, Stephen - William S on 7/19/19.
//  Copyright © 2019 Murphy. All rights reserved.
//

import Foundation

protocol ForecastWeatherViewModelDelegate {
    func forecastDidUpdate()
}


class ForecastWeatherViewModel {
    var delegate: ForecastWeatherViewModelDelegate?
    var forecast: Forecast?
    var formatter: DateFormatter

    init() {
        formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
    }

    //Presentation variables
    var numberOfForecastRows: Int {
        return forecast?.list.count ?? 0
    }

    func getLatestForecast() {
        //Get latest Weather
        WeatherConnections.loadForecast(zip: "28146") { [weak self] (newForecast) in
            guard let strongSelf = self else { return }
            strongSelf.forecast = newForecast

            //Indicate successful completion
            strongSelf.delegate?.forecastDidUpdate()
        }
    }

    func configureCellForRow(row: Int, cell: ForecastWeatherTableViewCell) -> ForecastWeatherTableViewCell {
        guard let weather = forecast?.list[row], let date = weather.date else {
            return cell
        }
        cell.dayLabel.text = formatter.string(from: date)
        cell.highTempLabel.text = "\(weather.highTemp)"
        cell.lowTempLabel.text = "\(weather.lowTemp)"

        return cell
    }
}
