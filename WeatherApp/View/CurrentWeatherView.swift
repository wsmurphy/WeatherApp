//
//  CurrentWeatherView.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/31/26.
//

import UIKit

class CurrentWeatherView: UIView {

    // MARK: - Subviews

    private let tempLabel = UILabel()
    private let conditionLabel = UILabel()

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

        tempLabel.font = .systemFont(ofSize: 50, weight: .bold)
        tempLabel.textAlignment = .center
        tempLabel.adjustsFontSizeToFitWidth = true
        tempLabel.minimumScaleFactor = 0.6

        conditionLabel.font = .systemFont(ofSize: 24, weight: .bold)
        conditionLabel.textAlignment = .center
        conditionLabel.adjustsFontSizeToFitWidth = true
        conditionLabel.minimumScaleFactor = 0.7

        let stack = UIStackView(arrangedSubviews: [tempLabel, conditionLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            stack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Public

    var temperature: String? {
        get { tempLabel.text }
        set { tempLabel.text = newValue }
    }

    var condition: String? {
        get { conditionLabel.text }
        set { conditionLabel.text = newValue }
    }
}
