//
//  ForecastView.swift
//  WeatherApp
//
//  Created by Murphy, Stephen - William S on 11/13/17.
//  Copyright © 2017 Stephen Murphy. All rights reserved.
//

import UIKit

class ForecastView: UIView {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var conditionsLabel: UILabel!

    class func instantiateFromNib() -> ForecastView? {
        if let nibs = Bundle.main.loadNibNamed("ForecastView", owner: self, options: nil) as? [UIView],
            let forecastView = nibs[0] as? ForecastView {
            return forecastView
        } else {
            return nil
        }
    }

}
