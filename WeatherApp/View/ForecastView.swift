//
//  ForecastView.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/31/26.
//

import UIKit

class ForecastView: UIView {

    // MARK: - Subviews

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    private let tintView = UIView()
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
        setupGlassBackground()
        layer.cornerRadius = 12
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.24).cgColor

        headerLabel.text = "7-DAY FORECAST"
        headerLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        headerLabel.textColor = .secondaryLabel

        divider.backgroundColor = UIColor.white.withAlphaComponent(0.35)

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

    private func setupGlassBackground() {
        backgroundColor = .clear
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.isUserInteractionEnabled = false
        addSubview(blurView)

        tintView.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        tintView.translatesAutoresizingMaskIntoConstraints = false
        tintView.isUserInteractionEnabled = false
        blurView.contentView.addSubview(tintView)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            tintView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            tintView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
            tintView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor)
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
