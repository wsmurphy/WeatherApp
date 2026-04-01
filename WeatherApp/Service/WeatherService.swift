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
    func loadCityName(for coordinate: CLLocationCoordinate2D) async throws -> String
}

enum NetworkError: LocalizedError {
    case invalidURL
    case networkError
    case decodingError
    case emptyResponse
}

class WeatherService: WeatherServicing {
    static let shared = WeatherService()
    
    fileprivate static let baseAPIURL = "https://api.openweathermap.org/data/2.5/"
    fileprivate static let geoAPIURL = "https://api.openweathermap.org/geo/1.0/"
    fileprivate static let weatherAPIPart = "weather"
    fileprivate static let forecastAPIPart = "forecast/daily"
    fileprivate static let reverseGeoAPIPart = "reverse"

    func loadWeather(for coordinate: CLLocationCoordinate2D) async throws -> WeatherResponse {
        guard var url = URL(string: WeatherService.baseAPIURL.appending(WeatherService.weatherAPIPart)) else {
            throw NetworkError.invalidURL
        }
        
        url.append(queryItems: [
            URLQueryItem(name: "lat", value: String(coordinate.latitude)),
            URLQueryItem(name: "lon", value: String(coordinate.longitude)),
            URLQueryItem(name: "appid", value: getAPIKey()),
            URLQueryItem(name: "units", value: "imperial")
        ])
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.networkError
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    func loadForecast(for coordinate: CLLocationCoordinate2D) async throws -> Forecast {
        guard var url = URL(string: WeatherService.baseAPIURL.appending(WeatherService.forecastAPIPart)) else {
            throw NetworkError.invalidURL
        }
        
        url.append(queryItems: [
            URLQueryItem(name: "lat", value: String(coordinate.latitude)),
            URLQueryItem(name: "lon", value: String(coordinate.longitude)),
            URLQueryItem(name: "appid", value: getAPIKey()),
            URLQueryItem(name: "units", value: "imperial"),
            URLQueryItem(name: "cnt", value: "7")
        ])
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.networkError
        }
        do {
            return try JSONDecoder().decode(Forecast.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    func loadCityName(for coordinate: CLLocationCoordinate2D) async throws -> String {
        guard var url = URL(string: WeatherService.geoAPIURL.appending(WeatherService.reverseGeoAPIPart)) else {
            throw NetworkError.invalidURL
        }
        
        url.append(queryItems: [
            URLQueryItem(name: "lat", value: String(coordinate.latitude)),
            URLQueryItem(name: "lon", value: String(coordinate.longitude)),
            URLQueryItem(name: "limit", value: "1"),
            URLQueryItem(name: "appid", value: getAPIKey())
        ])
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.networkError
        }
        do {
            let results = try JSONDecoder().decode([GeocodingResult].self, from: data)
            guard let first = results.first else { throw NetworkError.emptyResponse }
            return first.name
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    private func getAPIKey() -> String {
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
            let apiKey = dict["OpenWeatherMapAPIKey"] as? String else {
            return ""
        }
        
        return apiKey
    }
}
