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
    private let backgroundGradientLayer = CAGradientLayer()
    private var lastValidTimeOfDay: TimeOfDay?

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
    private static let staleWeatherThreshold: TimeInterval = 6 * 60 * 60

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        setupBackgroundGradient()

        setupLocationDeniedLabel()
        setupScrollView()
        setupLocationHeader()
        setupCurrentWeather()
        setupForecastView()
        setupDetailGrid()

        bindView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }

    // MARK: - Layout Setup

    private func setupBackgroundGradient() {
        backgroundGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        backgroundGradientLayer.frame = view.bounds
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)

        let timezoneOffset = TimeInterval(TimeZone.current.secondsFromGMT())
        let initialTimeOfDay = TimeOfDayResolver.inferFromLocalHour(now: Date(), timezoneOffset: timezoneOffset)
        applyGradient(for: initialTimeOfDay, animated: false)
    }

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
        scrollView.backgroundColor = .clear
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

                self.updateBackgroundTheme(using: response)
                self.currentWeatherView.temperature = "\(response.main.temp)°F"
                self.currentWeatherView.condition = response.weather.first?.main ?? "Unknown"

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

    private func updateBackgroundTheme(using response: WeatherResponse) {
        let now = Date()
        if isWeatherPayloadStale(response, now: now) {
            if let lastValidTimeOfDay {
                applyGradient(for: lastValidTimeOfDay, animated: false)
            }
            return
        }

        let sunrise = response.sys.map { Date(timeIntervalSince1970: $0.sunrise) }
        let sunset = response.sys.map { Date(timeIntervalSince1970: $0.sunset) }

        if let sunrise, let sunset, sunrise >= sunset {
            if let lastValidTimeOfDay {
                applyGradient(for: lastValidTimeOfDay, animated: false)
            }
            return
        }

        let resolved = TimeOfDayResolver.resolve(
            now: now,
            sunrise: sunrise,
            sunset: sunset,
            timezoneOffset: TimeInterval(response.timezone)
        )
        applyGradient(for: resolved, animated: true)
    }

    private func isWeatherPayloadStale(_ response: WeatherResponse, now: Date) -> Bool {
        guard response.dt.isFinite, response.dt > 0 else {
            return true
        }

        let payloadDate = Date(timeIntervalSince1970: response.dt)
        return abs(now.timeIntervalSince(payloadDate)) > Self.staleWeatherThreshold
    }

    private func applyGradient(for timeOfDay: TimeOfDay, animated: Bool) {
        guard lastValidTimeOfDay != timeOfDay || backgroundGradientLayer.colors == nil else {
            return
        }

        let gradientColors = colors(for: timeOfDay).map(\.cgColor)
        if animated, let previousColors = backgroundGradientLayer.colors {
            let animation = CABasicAnimation(keyPath: "colors")
            animation.fromValue = previousColors
            animation.toValue = gradientColors
            animation.duration = 0.45
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            backgroundGradientLayer.add(animation, forKey: "backgroundGradient")
        }

        backgroundGradientLayer.colors = gradientColors
        lastValidTimeOfDay = timeOfDay
    }

    private func colors(for timeOfDay: TimeOfDay) -> [UIColor] {
        switch timeOfDay {
        case .day:
            return [
                UIColor(red: 0.56, green: 0.84, blue: 1.00, alpha: 1.0),
                UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.0),
                UIColor(red: 1.00, green: 0.96, blue: 0.77, alpha: 1.0)
            ]
        case .twilight:
            return [
                UIColor(red: 0.95, green: 0.43, blue: 0.67, alpha: 1.0),
                UIColor(red: 1.00, green: 0.58, blue: 0.27, alpha: 1.0),
                UIColor(red: 1.00, green: 0.84, blue: 0.42, alpha: 1.0)
            ]
        case .night:
            return [
                UIColor(red: 0.04, green: 0.12, blue: 0.31, alpha: 1.0),
                UIColor(red: 0.10, green: 0.27, blue: 0.56, alpha: 1.0)
            ]
        }
    }

    private static func compassDirection(from degrees: Double) -> String {
        let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                          "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((degrees + 11.25) / 22.5) % 16
        return directions[index]
    }
}
