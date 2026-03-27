//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/26/26.
//

import Foundation

protocol WeatherServicing {
    func loadWeather(for location: String) async throws -> WeatherResponse
}

enum NetworkError: LocalizedError {
    case invalidURL
    case networkError
    case decodingError
}

@MainActor
class WeatherService: WeatherServicing {
    static let shared = WeatherService()
    
    fileprivate static let weatherAPIKey = "b4608d4fcb4accac0a8cc2ea6949eeb5"
    fileprivate static let baseAPIURL = "https://api.openweathermap.org/data/2.5/"
    fileprivate static let weatherAPIPart = "weather"
    fileprivate static let forecastAPIPart = "forecast"
    
    func loadWeather(for location: String) async throws -> WeatherResponse{
        guard var url = URL(string: WeatherService.baseAPIURL.appending(WeatherService.weatherAPIPart)) else {
            throw NetworkError.invalidURL
        }
        url.append(queryItems: [URLQueryItem(name: "q", value: location),
                                   URLQueryItem(name: "appid", value: WeatherService.weatherAPIKey),
                               URLQueryItem(name: "units", value: "imperial")])
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.networkError
        }
        
        do {
            let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
            return response
        } catch {
            throw NetworkError.decodingError
        }
    }
}
