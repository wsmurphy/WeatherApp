//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/26/26.
//

import UIKit
import Combine

class WeatherViewController: UIViewController {
    private let viewModel = WeatherViewModel()

    private let locationDeniedLabel = UILabel()

    // MARK: - Scroll
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // MARK: - Cards
    private let locationHeaderView = LocationHeaderView()
    private let currentWeatherView = CurrentWeatherView()
    private let forecastView = ForecastView()
    private let detailGrid = UIStackView()
    private let humidityView = WeatherDetailView(title: "HUMIDITY")
    private let windView = WeatherDetailView(title: "WIND")

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        setupLocationDeniedLabel()
        setupScrollView()
        setupLocationHeader()
        setupCurrentWeather()
        setupForecastView()
        setupDetailGrid()

        bindView()
    }

    // MARK: - Layout Setup

    private func setupLocationDeniedLabel() {
        locationDeniedLabel.text = "Location access is required to show weather. Please enable it in Settings."
        locationDeniedLabel.font = .systemFont(ofSize: 16)
        locationDeniedLabel.textAlignment = .center
        locationDeniedLabel.numberOfLines = 0
        locationDeniedLabel.lineBreakMode = .byWordWrapping
        locationDeniedLabel.textColor = .secondaryLabel
        locationDeniedLabel.isHidden = true

        view.addSubview(locationDeniedLabel)
        locationDeniedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            locationDeniedLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            locationDeniedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            locationDeniedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupScrollView() {
        scrollView.alwaysBounceVertical = true

        contentStack.axis = .vertical
        contentStack.spacing = 16

        scrollView.addSubview(contentStack)
        view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),

            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
    }

    private func setupLocationHeader() {
        locationHeaderView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        contentStack.addArrangedSubview(locationHeaderView)
    }

    private func setupCurrentWeather() {
        currentWeatherView.temperature = "Loading..."
        currentWeatherView.condition = "Loading..."
        currentWeatherView.heightAnchor.constraint(equalToConstant: 140).isActive = true
        contentStack.addArrangedSubview(currentWeatherView)
    }

    private func setupForecastView() {
        contentStack.addArrangedSubview(forecastView)
    }

    private func setupDetailGrid() {
        detailGrid.axis = .horizontal
        detailGrid.spacing = 12
        detailGrid.distribution = .fillEqually

        for tile in [humidityView, windView] {
            tile.backgroundColor = .secondarySystemBackground
            tile.layer.cornerRadius = 12
            tile.layer.masksToBounds = true
            tile.heightAnchor.constraint(equalToConstant: 90).isActive = true
        }

        detailGrid.addArrangedSubview(humidityView)
        detailGrid.addArrangedSubview(windView)
        contentStack.addArrangedSubview(detailGrid)
    }

    // MARK: - Bind

    private func bindView() {
        viewModel.$cityName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.locationHeaderView.cityName = name
            }.store(in: &cancellables)

        viewModel.$weather
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                guard let self = self, let response = response else { return }

                self.currentWeatherView.temperature = "\(response.main.temp)°F"
                self.currentWeatherView.condition = response.weather.first?.main

                self.humidityView.value = "\(Int(response.main.humidity))%"

                let speed = Int(response.wind.speed)
                let direction = Self.compassDirection(from: response.wind.degrees)
                self.windView.value = "\(speed) mph \(direction)"
            }.store(in: &cancellables)

        viewModel.$locationDenied
            .receive(on: DispatchQueue.main)
            .sink { [weak self] denied in
                guard let self else { return }
                self.locationDeniedLabel.isHidden = !denied
                self.scrollView.isHidden = denied
            }.store(in: &cancellables)

        viewModel.$forecast
            .receive(on: DispatchQueue.main)
            .sink { [weak self] forecast in
                guard let self = self, let forecast = forecast else { return }
                self.forecastView.setForecast(forecast.list)
            }.store(in: &cancellables)
    }

    // MARK: - Helpers

    private static func compassDirection(from degrees: Double) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                          "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((degrees + 11.25) / 22.5) % 16
        return directions[index]
    }
}
