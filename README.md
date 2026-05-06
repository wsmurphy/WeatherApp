# WeatherApp

A native iOS weather app built in Swift that displays current conditions, a 7-day forecast, and contextual detail tiles for the user's current location.

## Features

- **Current conditions** — temperature, weather description, and condition icon fetched from the OpenWeatherMap API
- **7-day forecast** — daily high/low, conditions, and precipitation chance
- **Detail tiles** — humidity and wind speed/direction displayed as glassy cards
- **Dynamic background** — animated `CAGradientLayer` transitions between day, twilight, and night palettes based on real sunrise/sunset data from the API (with a local-clock fallback)
- **Reverse geocoding** — city name resolved via the OpenWeatherMap Geocoding API
- **Location permission handling** — graceful UI state when the user denies location access

## Architecture

The app follows standard **MVVM** arcitecture.

## Tech & Patterns

- **Language:** Swift
- **UI:** UIKit — programmatic Auto Layout using `NSLayoutConstraint`, `UIStackView`, `UIScrollView`, `UIVisualEffectView` (glassmorphism cards)
- **Concurrency:** Swift `async/await` for network calls; `Task` management with cancellation in views
- **Reactive bindings:** Combine — `@Published` properties piped to the view layer via `sink` subscriptions
- **Networking:** `URLSession` with `async/await`; custom `NetworkError` enum with localized descriptions; HTTP status code handling
- **Location:** `CoreLocation` via a `CLLocationManagerDelegate` wrapper that publishes location and denial state
- **Image caching:** `NSCache`-backed `WeatherIconLoader` with a fallback URL strategy and `UIImage` placeholder
- **Time-of-day logic:** `TimeOfDayResolver` — pure enum with sunrise/sunset window detection and a local-clock fallback
- **Dependency injection:** Protocol-based (`WeatherServicing`, `LocationManaging`, `WeatherIconDataLoading`) enabling full mock substitution in tests
- **Testing:** XCTest with mock service and location manager; covers ViewModel, Service JSON decoding, LocationManager delegate callbacks, TimeOfDayResolver boundary conditions, WeatherIconLoader cache/network behavior, and ForecastDayView rendering logic