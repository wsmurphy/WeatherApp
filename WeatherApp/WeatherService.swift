//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/26/26.
//

import Foundation

protocol WeatherServicing {
    func loadWeather(for location: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void)
}

enum NetworkError: LocalizedError {
    case invalidURL
    case noDataReceived
    case decodingError
}

@MainActor
class WeatherService: WeatherServicing {
    static let shared = WeatherService()
    
    fileprivate static let weatherAPIKey = "b4608d4fcb4accac0a8cc2ea6949eeb5"
    fileprivate static let baseAPIURL = "https://api.openweathermap.org/data/2.5/"
    fileprivate static let weatherAPIPart = "weather"
    fileprivate static let forecastAPIPart = "forecast"
    
    func loadWeather(for location: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        guard let url = URL(string: WeatherService.baseAPIURL.appending(WeatherService.weatherAPIPart)) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(NetworkError.decodingError))
                }
            }
        }
    }
}
