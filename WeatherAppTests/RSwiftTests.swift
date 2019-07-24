//
//  RSwiftTests.swift
//  WeatherAppTests
//
//  Created by Murphy, Stephen - William S on 7/24/19.
//  Copyright © 2019 Murphy. All rights reserved.
//

import XCTest

class RSwiftTests: XCTestCase {
    func testRswift() {
        do {
            try R.validate()
        } catch {
            XCTFail("R.swfit validation failed")
        }
    }
}
