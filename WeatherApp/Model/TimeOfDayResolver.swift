//
//  TimeOfDayResolver.swift
//  WeatherApp
//
//  Created by Codex on 4/6/26.
//

import Foundation

enum TimeOfDay: String {
    case day
    case twilight
    case night
}

enum TimeOfDayResolver {
    static let twilightLeadWindow: TimeInterval = 30 * 60

    static func resolve(
        now: Date = Date(),
        sunrise: Date?,
        sunset: Date?,
        timezoneOffset: TimeInterval
    ) -> TimeOfDay {
        guard let sunrise, let sunset else {
            return inferFromLocalHour(now: now, timezoneOffset: timezoneOffset)
        }

        guard sunrise < sunset else {
            return inferFromLocalHour(now: now, timezoneOffset: timezoneOffset)
        }

        let sunriseTwilightStart = sunrise.addingTimeInterval(-twilightLeadWindow)
        let sunsetTwilightStart = sunset.addingTimeInterval(-twilightLeadWindow)

        if now >= sunriseTwilightStart && now < sunrise {
            return .twilight
        }

        if now >= sunsetTwilightStart && now < sunset {
            return .twilight
        }

        if now >= sunrise && now < sunset {
            return .day
        }

        return .night
    }

    static func inferFromLocalHour(now: Date, timezoneOffset: TimeInterval) -> TimeOfDay {
        let localDate = now.addingTimeInterval(timezoneOffset)
        let localHour = Calendar(identifier: .gregorian).component(.hour, from: localDate)

        if localHour == 5 || localHour == 17 {
            return .twilight
        }

        if (6..<18).contains(localHour) {
            return .day
        }

        return .night
    }
}
