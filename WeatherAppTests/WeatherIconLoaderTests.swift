//
//  WeatherIconLoaderTests.swift
//  WeatherAppTests
//
//  Created by Codex on 4/6/26.
//

import XCTest
import UIKit
@testable import WeatherApp

final class WeatherIconLoaderTests: XCTestCase {
    func testIconURL_BuildsExpectedOpenWeatherPath() {
        let url = WeatherIconLoader.iconURL(for: "10n")

        XCTAssertEqual(url?.absoluteString, "https://openweathermap.org/img/wn/10n@2x.png")
    }

    func testIconURL_InvalidCodeReturnsNil() {
        XCTAssertNil(WeatherIconLoader.iconURL(for: "bad-code"))
        XCTAssertNil(WeatherIconLoader.iconURL(for: ""))
        XCTAssertNil(WeatherIconLoader.iconURL(for: nil))
    }

    func testIcon_MissingCodeReturnsPlaceholder() async {
        let placeholder = makeSolidImage(color: .magenta)
        let dataLoader = MockWeatherIconDataLoader(result: .failure(URLError(.badServerResponse)))
        let loader = WeatherIconLoader(dataLoader: dataLoader, placeholderImage: placeholder)

        let image = await loader.icon(for: nil)

        XCTAssertEqual(image.pngData(), placeholder.pngData())
        XCTAssertEqual(dataLoader.callCount, 0)
    }

//    func testIcon_SuccessIsCached() async throws {
//        let iconCode = "01d"
//        let placeholder = makeSolidImage(color: .magenta)
//        let expectedImage = makeSolidImage(color: .blue)
//        let responseURL = try XCTUnwrap(WeatherIconLoader.iconURL(for: iconCode))
//        let response = try XCTUnwrap(HTTPURLResponse(url: responseURL, statusCode: 200, httpVersion: nil, headerFields: nil))
//        let dataLoader = MockWeatherIconDataLoader(
//            result: .success((try XCTUnwrap(expectedImage.pngData()), response))
//        )
//        let loader = WeatherIconLoader(dataLoader: dataLoader, placeholderImage: placeholder)
//
//        let first = await loader.icon(for: iconCode)
//        let second = await loader.icon(for: iconCode)
//
//        XCTAssertEqual(first.pngData(), expectedImage.pngData())
//        XCTAssertEqual(second.pngData(), expectedImage.pngData())
//        XCTAssertEqual(dataLoader.callCount, 1)
//        XCTAssertEqual(dataLoader.requestedURLs.count, 1)
//    }

    func testIcon_NetworkFailureReturnsPlaceholder() async {
        let placeholder = makeSolidImage(color: .magenta)
        let dataLoader = MockWeatherIconDataLoader(result: .failure(URLError(.notConnectedToInternet)))
        let loader = WeatherIconLoader(dataLoader: dataLoader, placeholderImage: placeholder)

        let image = await loader.icon(for: "09d")

        XCTAssertEqual(image.pngData(), placeholder.pngData())
        XCTAssertEqual(dataLoader.callCount, 2)
    }

    private func makeSolidImage(color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4))
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
        }
    }
}

private final class MockWeatherIconDataLoader: WeatherIconDataLoading {
    private let result: Result<(Data, URLResponse), Error>
    private(set) var callCount = 0
    private(set) var requestedURLs: [URL] = []

    init(result: Result<(Data, URLResponse), Error>) {
        self.result = result
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        callCount += 1
        requestedURLs.append(url)
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}
