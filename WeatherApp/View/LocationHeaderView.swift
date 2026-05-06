//
//  LocationHeaderView.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/31/26.
//

import UIKit

class LocationHeaderView: UIView {

    // MARK: - Subviews
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    private let tintView = UIView()
    private let iconView = UIImageView()
    private let cityLabel = UILabel()

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

        iconView.image = UIImage(systemName: "location.fill")
        iconView.tintColor = .secondaryLabel
        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.setContentCompressionResistancePriority(.required, for: .horizontal)

        cityLabel.font = .systemFont(ofSize: 20, weight: .bold)
        cityLabel.textAlignment = .center
        cityLabel.adjustsFontSizeToFitWidth = true
        cityLabel.minimumScaleFactor = 0.7

        let stack = UIStackView(arrangedSubviews: [iconView, cityLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            stack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 12),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
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

    var cityName: String? {
        get { cityLabel.text }
        set { cityLabel.text = newValue }
    }
}
