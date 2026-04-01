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

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        axis = .horizontal
        spacing = 10
        distribution = .fillEqually
        tempLabel.textAlignment = .right
        conditionsLabel.textAlignment = .center
        addArrangedSubview(dateLabel)
        addArrangedSubview(conditionsLabel)
        addArrangedSubview(tempLabel)
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
        dateLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        tempLabel.text = "H: \(Int(day.temperature.max))° L: \(Int(day.temperature.min))°"

        guard let conditions = day.weather.first?.main else {
            conditionsLabel.text = ""
            return
        }
        
        if day.precipChance > 0 && conditions == "Rain" {
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 0
            numberFormatter.multiplier = 100
            let precipChance = numberFormatter.string(from: day.precipChance as NSNumber) ?? ""
            conditionsLabel.text = "\(conditions) \(precipChance)%"
        } else {
            conditionsLabel.text = "\(conditions)"
        }


        
    }
}
