//
//  ForecastWeatherViewController.swift
//  WeatherApp
//
//  Created by Murphy, Stephen - William S on 7/19/19.
//  Copyright © 2019 Murphy. All rights reserved.
//

import UIKit

class ForecastWeatherTableViewController: UITableViewController {
    var viewModel = ForecastWeatherViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        viewModel.getLatestForecast()

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.forecastCell, for: indexPath) else {
            return UITableViewCell()
        }

        return viewModel.configureCellForRow(row: indexPath.row, cell: cell)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfForecastRows
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension ForecastWeatherTableViewController: ForecastWeatherViewModelDelegate {
    func forecastDidUpdate() {
        tableView.reloadData()
    }
}
