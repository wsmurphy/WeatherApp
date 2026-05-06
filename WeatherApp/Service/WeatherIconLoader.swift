//
//  WeatherIconLoader.swift
//  WeatherApp
//
//  Created by Codex on 4/6/26.
//

import UIKit

protocol WeatherIconDataLoading {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: WeatherIconDataLoading {}

final class WeatherIconLoader {
    static let shared = WeatherIconLoader()

    private let dataLoader: WeatherIconDataLoading
    private let imageCache = NSCache<NSString, UIImage>()
    let placeholderImage: UIImage

    init(
        dataLoader: WeatherIconDataLoading = URLSession.shared,
        placeholderImage: UIImage = WeatherIconLoader.makeDefaultPlaceholder()
    ) {
        self.dataLoader = dataLoader
        self.placeholderImage = placeholderImage
    }

    func icon(for iconCode: String?) async -> UIImage {
        guard let iconCode = Self.normalizedIconCode(from: iconCode),
              let primaryURL = Self.iconURL(for: iconCode) else {
            return placeholderImage
        }

        if let cachedImage = imageCache.object(forKey: iconCode as NSString) {
            return cachedImage
        }

        let iconURLs = [primaryURL, Self.legacyIconURL(for: iconCode)].compactMap { $0 }
        for url in iconURLs {
            do {
                let (data, response) = try await dataLoader.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let image = UIImage(data: data) else {
                    continue
                }

                imageCache.setObject(image, forKey: iconCode as NSString)
                return image
            } catch {
                continue
            }
        }

        return placeholderImage
    }

    static func iconURL(for iconCode: String?) -> URL? {
        guard let iconCode = normalizedIconCode(from: iconCode) else {
            return nil
        }

        return URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")
    }

    private static func normalizedIconCode(from iconCode: String?) -> String? {
        guard let trimmed = iconCode?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.range(of: #"^\d{2}[dn]$"#, options: .regularExpression) != nil else {
            return nil
        }

        return trimmed
    }

    private static func makeDefaultPlaceholder() -> UIImage {
        UIImage(systemName: "questionmark.square.dashed") ?? UIImage()
    }

    private static func legacyIconURL(for iconCode: String) -> URL? {
        URL(string: "https://openweathermap.org/img/w/\(iconCode).png")
    }
}
