//
//  ForecastDayView.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/29/26.
//

import UIKit

class ForecastDayView: UIStackView {
    let dateLabel = UILabel()
    let tempLabel = UILabel()
    let conditionsLabel = UILabel()
    let precipitationLabel = UILabel()
    
    let topRow = UIStackView()
    let bottomRow = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
        spacing = 10
        
        topRow.axis = .horizontal
        topRow.spacing = 20
        tempLabel.textAlignment = .right
        topRow.addArrangedSubview(dateLabel)
        topRow.addArrangedSubview(tempLabel)
        
        bottomRow.axis = .horizontal
        bottomRow.spacing = 20
        precipitationLabel.textAlignment = .right
        bottomRow.addArrangedSubview(conditionsLabel)
        bottomRow.addArrangedSubview(precipitationLabel)
        
        addArrangedSubview(topRow)
        addArrangedSubview(bottomRow)
    }

    required init(coder: NSCoder) { fatalError() }

    var day: ForecastDay? {
        didSet { configure() }
    }

    private func configure() {
        guard let day = day else { return }
        let date = Date(timeIntervalSince1970: day.date)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        dateLabel.text = formatter.string(from: date)
        tempLabel.text = "H: \(Int(day.temperature.max))° L: \(Int(day.temperature.min))°"
        conditionsLabel.text = "\(day.weather.first?.main ?? "Unknown")"

        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.multiplier = 100
        let precipChance = numberFormatter.string(from: day.precipChance as NSNumber) ?? ""
        precipitationLabel.text = "Chance of rain: \(precipChance)%"
    }
}
