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
    case decodingError(Error?)
    case emptyResponse
    case unauthorized
    case forbidden
    case rateLimited
    case serverError(Int)
    case httpError(Int)
    case missingAPIKey

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .networkError:
            return "Network connection failed"
        case .decodingError(let underlying):
            if let error = underlying {
                return "Failed to decode response: \(error.localizedDescription)"
            }
            return "Failed to decode response"
        case .emptyResponse:
            return "No data received"
        case .unauthorized:
            return "Invalid API key"
        case .forbidden:
            return "Access forbidden"
        case .rateLimited:
            return "API rate limit exceeded"
        case .serverError(let code):
            return "Server error (\(code))"
        case .httpError(let code):
            return "HTTP error (\(code))"
        case .missingAPIKey:
            return "API key is missing or empty"
        }
    }
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
            URLQueryItem(name: "appid", value: try getAPIKey()),
            URLQueryItem(name: "units", value: "imperial")
        ])
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        try handleStatusCode(response)
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    func loadForecast(for coordinate: CLLocationCoordinate2D) async throws -> Forecast {
        guard var url = URL(string: WeatherService.baseAPIURL.appending(WeatherService.forecastAPIPart)) else {
            throw NetworkError.invalidURL
        }
        
        url.append(queryItems: [
            URLQueryItem(name: "lat", value: String(coordinate.latitude)),
            URLQueryItem(name: "lon", value: String(coordinate.longitude)),
            URLQueryItem(name: "appid", value: try getAPIKey()),
            URLQueryItem(name: "units", value: "imperial"),
            URLQueryItem(name: "cnt", value: "7")
        ])
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        try handleStatusCode(response)
        do {
            return try JSONDecoder().decode(Forecast.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
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
            URLQueryItem(name: "appid", value: try getAPIKey())
        ])
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        try handleStatusCode(response)
        do {
            let results = try JSONDecoder().decode([GeocodingResult].self, from: data)
            guard let first = results.first else { throw NetworkError.emptyResponse }
            return first.name
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    private func getAPIKey() throws -> String {
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let apiKey = dict["OpenWeatherMapAPIKey"] as? String,
              !apiKey.isEmpty else {
            throw NetworkError.missingAPIKey
        }
        return apiKey
    }
    
    private func handleStatusCode(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.networkError
        }
        switch httpResponse.statusCode {
        case 200:
            return
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 429:
            throw NetworkError.rateLimited
        case 500...:
            throw NetworkError.serverError(httpResponse.statusCode)
        default:
            throw NetworkError.httpError(httpResponse.statusCode)
        }
    }
}
