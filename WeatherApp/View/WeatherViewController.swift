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
    
    private let stackView = UIStackView()
    private var tempLabel = UILabel()
    private var conditionLabel = UILabel()
    private var locationDeniedLabel = UILabel()
    private var forecastStack = UIStackView()
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        locationDeniedLabel.text = "Location access is required to show weather. Please enable it in Settings."
        locationDeniedLabel.font = .systemFont(ofSize: 16)
        locationDeniedLabel.textAlignment = .center
        locationDeniedLabel.numberOfLines = 0
        locationDeniedLabel.lineBreakMode = .byWordWrapping
        locationDeniedLabel.textColor = .secondaryLabel
        locationDeniedLabel.isHidden = true
        stackView.addArrangedSubview(locationDeniedLabel)

        tempLabel.text = "Loading..."
        tempLabel.font = .systemFont(ofSize: 50, weight: .bold)
        tempLabel.textAlignment = .center
        stackView.addArrangedSubview(tempLabel)
        
        conditionLabel.text = "Loading..."
        conditionLabel.font = .systemFont(ofSize: 24, weight: .bold)
        conditionLabel.textAlignment = .center
        stackView.addArrangedSubview(conditionLabel)
        stackView.axis = .vertical
        stackView.spacing = 20
        
        forecastStack.axis = .vertical
        forecastStack.spacing = 20
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tempLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            conditionLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor)])
        
        view.addSubview(forecastStack)
        forecastStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            forecastStack.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            forecastStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            forecastStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        bindView()
    }
    
    private func bindView() {
        viewModel.$weather
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                guard let self = self, let response = response else { return }
                
                self.tempLabel.text = "\(response.main.temp)°F"
                self.conditionLabel.text = response.weather.first?.main
            }.store(in: &cancellables)
        
        viewModel.$locationDenied
            .receive(on: DispatchQueue.main)
            .sink { [weak self] denied in
                guard let self else { return }
                self.locationDeniedLabel.isHidden = !denied
                self.conditionLabel.isHidden = denied
                self.tempLabel.isHidden = denied
                self.forecastStack.isHidden = denied
            }.store(in: &cancellables)

        viewModel.$forecast
            .receive(on: DispatchQueue.main)
            .sink { [weak self] forecast in
                guard let self = self, let forecast = forecast else { return }

                self.forecastStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

                for forecastDay in forecast.list {
                    let dayView = ForecastDayView()
                    dayView.day = forecastDay
                    self.forecastStack.addArrangedSubview(dayView)
                }
            }.store(in: &cancellables)
    }
}
