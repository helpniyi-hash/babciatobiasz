//
//  WeatherViewModel.swift
//  WeatherHabitTracker
//
//  ViewModel for the Weather view, handling weather data fetching and state management.
//  Uses async/await for network operations and provides reactive updates to the UI.
//

import Foundation
import SwiftUI
import SwiftData

/// ViewModel that manages weather data fetching and display state.
/// Coordinates between WeatherService and the Weather view.
@MainActor
@Observable
final class WeatherViewModel {
    
    // MARK: - State
    
    /// Current weather data
    var currentWeather: WeatherData?
    
    /// 7-day forecast data
    var forecast: [WeatherForecast] = []
    
    /// Whether weather data is currently being loaded
    var isLoading: Bool = false
    
    /// Whether forecast is being loaded
    var isForecastLoading: Bool = false
    
    /// Error message to display
    var errorMessage: String?
    
    /// Whether to show the error alert
    var showError: Bool = false
    
    /// Last refresh timestamp
    var lastRefresh: Date?
    
    // MARK: - Dependencies
    
    /// Weather service for API calls
    private var weatherService: WeatherService?
    
    /// Persistence service for caching
    private var persistenceService: PersistenceService?
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with optional dependencies for testing
    /// - Parameters:
    ///   - weatherService: The weather service to use
    ///   - persistenceService: The persistence service for caching
    init(
        weatherService: WeatherService? = nil,
        persistenceService: PersistenceService? = nil
    ) {
        self.weatherService = weatherService
        self.persistenceService = persistenceService
    }
    
    // MARK: - Configuration
    
    /// Configures the ViewModel with dependencies
    /// - Parameters:
    ///   - weatherService: The weather service to use
    ///   - persistenceService: The persistence service for caching
    func configure(
        weatherService: WeatherService,
        persistenceService: PersistenceService
    ) {
        self.weatherService = weatherService
        self.persistenceService = persistenceService
    }
    
    // MARK: - Data Loading
    
    /// Fetches current weather data
    /// Attempts to load from cache first, then fetches fresh data if needed
    func fetchWeather() async {
        guard let weatherService = weatherService else {
            errorMessage = "Weather service not configured"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch fresh weather data
            let weatherDTO = try await weatherService.fetchCurrentWeather()
            
            // Convert DTO to Model
            let weather = WeatherData(
                locationName: weatherDTO.name,
                latitude: weatherDTO.coord.lat,
                longitude: weatherDTO.coord.lon,
                temperature: weatherDTO.main.temp,
                feelsLike: weatherDTO.main.feels_like,
                temperatureMin: weatherDTO.main.temp_min,
                temperatureMax: weatherDTO.main.temp_max,
                humidity: weatherDTO.main.humidity,
                windSpeed: weatherDTO.wind.speed,
                windDirection: weatherDTO.wind.deg,
                conditionCode: weatherDTO.weather.first?.icon ?? "01d",
                conditionDescription: weatherDTO.weather.first?.description.capitalized ?? "Unknown",
                conditionIconName: WeatherData.iconName(for: weatherDTO.weather.first?.icon ?? "01d"),
                uvIndex: 0, // Not available in basic API
                visibility: 10.0, // Default visibility
                pressure: weatherDTO.main.pressure,
                sunrise: Date(timeIntervalSince1970: weatherDTO.sys.sunrise),
                sunset: Date(timeIntervalSince1970: weatherDTO.sys.sunset)
            )
            
            self.currentWeather = weather
            self.lastRefresh = Date()
            
            // Cache the weather data
            if let persistenceService = persistenceService {
                try? persistenceService.cacheWeather(weather)
            }
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Fetches the 7-day forecast
    func fetchForecast() async {
        guard let weatherService = weatherService else {
            return
        }
        
        isForecastLoading = true
        
        do {
            let forecastDTO = try await weatherService.fetchForecast()
            
            // Process forecast DTO to Models
            let calendar = Calendar.current
            var dailyForecasts: [Date: ForecastItemDTO] = [:]
            
            for item in forecastDTO.list {
                let date = Date(timeIntervalSince1970: item.dt)
                let startOfDay = calendar.startOfDay(for: date)
                
                // Prefer noon forecasts for daily representation
                let hour = calendar.component(.hour, from: date)
                if dailyForecasts[startOfDay] == nil || (hour >= 11 && hour <= 14) {
                    dailyForecasts[startOfDay] = item
                }
            }
            
            let forecastData = dailyForecasts.keys.sorted().prefix(7).compactMap { date -> WeatherForecast? in
                guard let item = dailyForecasts[date] else { return nil }
                
                return WeatherForecast(
                    date: date,
                    latitude: forecastDTO.city.coord.lat,
                    longitude: forecastDTO.city.coord.lon,
                    temperatureMin: item.main.temp_min,
                    temperatureMax: item.main.temp_max,
                    humidity: item.main.humidity,
                    windSpeed: item.wind.speed,
                    conditionCode: item.weather.first?.icon ?? "01d",
                    conditionDescription: item.weather.first?.description.capitalized ?? "Unknown",
                    conditionIconName: WeatherData.iconName(for: item.weather.first?.icon ?? "01d"),
                    precipitationProbability: Int(item.pop * 100),
                    uvIndex: 0
                )
            }
            
            self.forecast = forecastData
            
            // Cache the forecast
            if let persistenceService = persistenceService {
                try? persistenceService.cacheForecast(forecastData)
            }
            
        } catch {
            // Don't show error for forecast, just log it
            print("Forecast error: \(error.localizedDescription)")
        }
        
        isForecastLoading = false
    }
    
    /// Refreshes all weather data
    func refresh() async {
        await fetchWeather()
        await fetchForecast()
    }
    
    /// Loads cached data if available
    func loadCachedData() {
        guard let persistenceService = persistenceService,
              let currentWeather = currentWeather else {
            return
        }
        
        // Try to load cached forecast
        if let cached = try? persistenceService.fetchCachedForecast(
            latitude: currentWeather.latitude,
            longitude: currentWeather.longitude
        ), !cached.isEmpty {
            self.forecast = cached
        }
    }
    
    // MARK: - Error Handling
    
    /// Handles errors from weather fetching
    /// - Parameter error: The error that occurred
    private func handleError(_ error: Error) {
        if let weatherError = error as? WeatherError {
            errorMessage = weatherError.errorDescription
        } else if let locationError = error as? LocationError {
            errorMessage = locationError.errorDescription
        } else {
            errorMessage = error.localizedDescription
        }
        showError = true
    }
    
    /// Dismisses the error message
    func dismissError() {
        showError = false
        errorMessage = nil
    }
    
    // MARK: - Computed Properties
    
    /// Whether data is available
    var hasData: Bool {
        currentWeather != nil
    }
    
    /// Formatted last refresh time
    var lastRefreshFormatted: String? {
        guard let lastRefresh = lastRefresh else { return nil }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "Updated \(formatter.localizedString(for: lastRefresh, relativeTo: Date()))"
    }
    
    /// Whether a refresh is needed (data older than 30 minutes)
    var needsRefresh: Bool {
        guard let lastRefresh = lastRefresh else { return true }
        return Date().timeIntervalSince(lastRefresh) > 1800 // 30 minutes
    }
}

// MARK: - Weather Display Helpers

extension WeatherViewModel {
    /// Returns a greeting based on time of day
    var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<21:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
    
    /// Returns appropriate background gradient colors based on weather and time
    var backgroundColors: [Color] {
        let hour = Calendar.current.component(.hour, from: Date())
        let isNight = hour < 6 || hour > 20
        
        if isNight {
            return [
                Color(red: 0.1, green: 0.1, blue: 0.3),
                Color(red: 0.2, green: 0.2, blue: 0.4),
                Color(red: 0.15, green: 0.15, blue: 0.35)
            ]
        }
        
        guard let weather = currentWeather else {
            return [Color.blue.opacity(0.3), Color.cyan.opacity(0.3)]
        }
        
        // Colors based on weather condition
        switch weather.conditionCode {
        case "01d": // Clear
            return [Color.blue.opacity(0.4), Color.cyan.opacity(0.3), Color.yellow.opacity(0.1)]
        case "02d", "03d": // Partly cloudy
            return [Color.blue.opacity(0.3), Color.gray.opacity(0.2), Color.cyan.opacity(0.2)]
        case "04d": // Overcast
            return [Color.gray.opacity(0.4), Color.gray.opacity(0.3)]
        case "09d", "10d": // Rain
            return [Color.gray.opacity(0.5), Color.blue.opacity(0.3), Color.gray.opacity(0.4)]
        case "11d": // Thunderstorm
            return [Color.gray.opacity(0.6), Color.purple.opacity(0.3), Color.gray.opacity(0.5)]
        case "13d": // Snow
            return [Color.white.opacity(0.3), Color.blue.opacity(0.2), Color.gray.opacity(0.2)]
        default:
            return [Color.blue.opacity(0.3), Color.cyan.opacity(0.3)]
        }
    }
}
