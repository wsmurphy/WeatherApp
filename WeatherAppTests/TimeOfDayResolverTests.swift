//
//  TimeOfDayResolverTests.swift
//  WeatherAppTests
//
//  Created by Codex on 4/6/26.
//

import XCTest
@testable import WeatherApp

final class TimeOfDayResolverTests: XCTestCase {
    private let sunrise = Date(timeIntervalSince1970: 1_700_000_000)
    private let sunset = Date(timeIntervalSince1970: 1_700_043_200) // +12h

    func testResolve_ThirtyMinutesBeforeSunrise_IsTwilight() {
        let now = sunrise.addingTimeInterval(-(30 * 60))
        let result = TimeOfDayResolver.resolve(now: now, sunrise: sunrise, sunset: sunset, timezoneOffset: 0)

        XCTAssertEqual(result, .twilight)
    }

    func testResolve_ExactlyAtSunrise_IsDay() {
        let result = TimeOfDayResolver.resolve(now: sunrise, sunrise: sunrise, sunset: sunset, timezoneOffset: 0)

        XCTAssertEqual(result, .day)
    }

    func testResolve_DuringDayOutsideTwilight_IsDay() {
        let now = sunrise.addingTimeInterval(3 * 60 * 60)
        let result = TimeOfDayResolver.resolve(now: now, sunrise: sunrise, sunset: sunset, timezoneOffset: 0)

        XCTAssertEqual(result, .day)
    }

    func testResolve_ThirtyMinutesBeforeSunset_IsTwilight() {
        let now = sunset.addingTimeInterval(-(30 * 60))
        let result = TimeOfDayResolver.resolve(now: now, sunrise: sunrise, sunset: sunset, timezoneOffset: 0)

        XCTAssertEqual(result, .twilight)
    }

    func testResolve_AtSunsetAndAfter_IsNight() {
        let atSunset = TimeOfDayResolver.resolve(now: sunset, sunrise: sunrise, sunset: sunset, timezoneOffset: 0)
        let afterSunset = TimeOfDayResolver.resolve(now: sunset.addingTimeInterval(60), sunrise: sunrise, sunset: sunset, timezoneOffset: 0)

        XCTAssertEqual(atSunset, .night)
        XCTAssertEqual(afterSunset, .night)
    }

    func testResolve_MissingSunTimes_UsesLocalHourFallback() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let result = TimeOfDayResolver.resolve(now: now, sunrise: nil, sunset: nil, timezoneOffset: 0)

        XCTAssertEqual(result, .night)
    }
}
