//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Stephen Murphy on 3/26/26.
//

import Foundation
import CoreLocation
import Combine

class WeatherViewModel {
    @Published var weather: WeatherResponse?
    @Published var forecast: Forecast?
    @Published var cityName: String?
    @Published var locationDenied: Bool = false

    private let locationManager: LocationManaging
    private var cancellables = Set<AnyCancellable>()
    private let service: WeatherServicing

    init(service: WeatherServicing = WeatherService.shared, locationManager: LocationManaging = LocationManager()) {
        self.service = service
        self.locationManager = locationManager

        locationManager.locationDenied
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] denied in
                self?.locationDenied = denied
            }
            .store(in: &cancellables)

        locationManager.location
            .compactMap { $0 }
            .first()
            .sink { [weak self] location in
                guard let self else { return }
                Task {
                    await self.loadCityName(for: location.coordinate)
                    await self.loadConditions(for: location.coordinate)
                    await self.loadForecast(for: location.coordinate)
                }
            }
            .store(in: &cancellables)
    }

    internal func loadCityName(for coordinate: CLLocationCoordinate2D) async {
        do {
            let name = try await service.loadCityName(for: coordinate)
            await MainActor.run { cityName = name }
        } catch {
            print("Geocoding error:", error.localizedDescription)
        }
    }

    internal func loadConditions(for coordinate: CLLocationCoordinate2D) async {
        do {
            let response = try await service.loadWeather(for: coordinate)
            await MainActor.run { weather = response }
        } catch {
            print("Weather load error:", error.localizedDescription)
        }
    }

    internal func loadForecast(for coordinate: CLLocationCoordinate2D) async {
        do {
            let response = try await service.loadForecast(for: coordinate)
            await MainActor.run { forecast = response }
        } catch {
            print("Forecast load error:", error.localizedDescription)
        }
    }
}
