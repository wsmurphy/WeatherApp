//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/26/26.
//

import Foundation
import CoreLocation

protocol WeatherServicing {
    func loadWeather(for coordinate: CLLocationCoordinate2D) async throws -> WeatherResponse
    func loadForecast(for coordinate: CLLocationCoordinate2D) async throws -> Forecast
}

enum NetworkError: LocalizedError {
    case invalidURL
    case networkError
    case decodingError
}

class WeatherService: WeatherServicing {
    static let shared = WeatherService()
    
    fileprivate static let weatherAPIKey = "b4608d4fcb4accac0a8cc2ea6949eeb5"
    fileprivate static let baseAPIURL = "https://api.openweathermap.org/data/2.5/"
    fileprivate static let weatherAPIPart = "weather"
    fileprivate static let forecastAPIPart = "forecast/daily"
    
    func loadWeather(for coordinate: CLLocationCoordinate2D) async throws -> WeatherResponse {
        guard var url = URL(string: WeatherService.baseAPIURL.appending(WeatherService.weatherAPIPart)) else {
            throw NetworkError.invalidURL
        }
        url.append(queryItems: [URLQueryItem(name: "lat", value: String(coordinate.latitude)),
                                URLQueryItem(name: "lon", value: String(coordinate.longitude)),
                                URLQueryItem(name: "appid", value: WeatherService.weatherAPIKey),
                                URLQueryItem(name: "units", value: "imperial")])
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.networkError
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
            return weatherResponse
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func loadForecast(for coordinate: CLLocationCoordinate2D) async throws -> Forecast {
        guard var url = URL(string: WeatherService.baseAPIURL.appending(WeatherService.forecastAPIPart)) else {
            throw NetworkError.invalidURL
        }
        url.append(queryItems: [URLQueryItem(name: "lat", value: String(coordinate.latitude)),
                                URLQueryItem(name: "lon", value: String(coordinate.longitude)),
                                URLQueryItem(name: "appid", value: WeatherService.weatherAPIKey),
                                URLQueryItem(name: "units", value: "imperial"),
                                URLQueryItem(name: "cnt", value: "7")])
        
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.networkError
        }
        
        do {
            let forecast = try JSONDecoder().decode(Forecast.self, from: data)
            return forecast
        } catch {
            throw NetworkError.decodingError
        }
    }
}
