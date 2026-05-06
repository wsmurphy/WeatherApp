//
//  CurrentWeatherView.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/31/26.
//

import UIKit

class CurrentWeatherView: UIView {

    // MARK: - Subviews

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    private let tintView = UIView()
    private let conditionIconView = UIImageView()
    private let tempLabel = UILabel()
    private let conditionLabel = UILabel()
    private let iconLoader: WeatherIconLoader
    private var iconTask: Task<Void, Never>?
    private var latestRequestedIconCode: String?

    // MARK: - Init

    override init(frame: CGRect) {
        self.iconLoader = .shared
        super.init(frame: frame)
        setup()
    }

    init(frame: CGRect = .zero, iconLoader: WeatherIconLoader) {
        self.iconLoader = iconLoader
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

        conditionIconView.image = iconLoader.placeholderImage
        conditionIconView.contentMode = .scaleAspectFit

        tempLabel.font = .systemFont(ofSize: 50, weight: .bold)
        tempLabel.textAlignment = .left
        tempLabel.adjustsFontSizeToFitWidth = true
        tempLabel.minimumScaleFactor = 0.6

        conditionLabel.font = .systemFont(ofSize: 24, weight: .bold)
        conditionLabel.textAlignment = .left
        conditionLabel.adjustsFontSizeToFitWidth = true
        conditionLabel.minimumScaleFactor = 0.7

        let textStack = UIStackView(arrangedSubviews: [tempLabel, conditionLabel])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.alignment = .leading

        let contentStack = UIStackView(arrangedSubviews: [conditionIconView, textStack])
        contentStack.axis = .horizontal
        contentStack.spacing = 14
        contentStack.alignment = .center
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentStack)
        NSLayoutConstraint.activate([
            conditionIconView.widthAnchor.constraint(equalToConstant: 80),
            conditionIconView.heightAnchor.constraint(equalToConstant: 80),

            contentStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            contentStack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16)
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

    var temperature: String? {
        get { tempLabel.text }
        set { tempLabel.text = newValue }
    }

    var condition: String? {
        get { conditionLabel.text }
        set { conditionLabel.text = newValue }
    }

    var conditionIconCode: String? {
        didSet { loadConditionIcon(using: conditionIconCode) }
    }

    var conditionIconImage: UIImage? {
        conditionIconView.image
    }

    private func loadConditionIcon(using iconCode: String?) {
        guard latestRequestedIconCode != iconCode else { return }
        latestRequestedIconCode = iconCode
        conditionIconView.image = iconLoader.placeholderImage
        iconTask?.cancel()
        iconTask = Task { [weak self] in
            guard let self = self else { return }
            let image = await iconLoader.icon(for: iconCode)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard self.latestRequestedIconCode == iconCode else { return }
                self.conditionIconView.image = image
            }
        }
    }

    deinit {
        iconTask?.cancel()
    }
}
