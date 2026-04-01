//
//  ForecastView.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/31/26.
//

import UIKit

class ForecastView: UIView {

    // MARK: - Subviews

    private let headerLabel = UILabel()
    private let divider = UIView()
    private let forecastStack = UIStackView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12
        layer.masksToBounds = true

        headerLabel.text = "7-DAY FORECAST"
        headerLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        headerLabel.textColor = .secondaryLabel

        divider.backgroundColor = .separator

        forecastStack.axis = .vertical
        forecastStack.spacing = 20

        let container = UIStackView(arrangedSubviews: [headerLabel, divider, forecastStack])
        container.axis = .vertical
        container.spacing = 12
        container.translatesAutoresizingMaskIntoConstraints = false

        addSubview(container)
        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: 0.5),

            container.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Public

    func setForecast(_ days: [ForecastDay]) {
        forecastStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for day in days {
            let dayView = ForecastDayView()
            dayView.day = day
            forecastStack.addArrangedSubview(dayView)
        }
    }
}
