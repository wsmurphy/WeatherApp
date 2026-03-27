//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/26/26.
//

import UIKit
import Combine

class WeatherViewController: UIViewController {
    var viewModel = WeatherViewModel()
    
    var tempLabel = UILabel()
    var conditionLabel = UILabel()
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView()
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
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tempLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            conditionLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor)])
        
        view.addSubview(stackView)
        
        bindView()
    }
    
    func bindView() {
        viewModel.$weather
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                guard let self else { return }
                if let response = response {
                    self.tempLabel.text = "\(response.main.temp)°F"
                    self.conditionLabel.text = response.weather.first?.main
                }
            }.store(in: &cancellables)
    }
    
}
