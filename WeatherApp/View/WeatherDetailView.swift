//
//  WeatherDetailView.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/31/26.
//

import UIKit

class WeatherDetailView: UIView {

    // MARK: - Subviews

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    private let tintView = UIView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    // MARK: - Init

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
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

        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center

        valueLabel.font = .systemFont(ofSize: 22, weight: .bold)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8)
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

    var value: String? {
        get { valueLabel.text }
        set { valueLabel.text = newValue }
    }
}
