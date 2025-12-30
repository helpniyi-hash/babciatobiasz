// WeatherViewModel.swift
// WeatherHabitTracker

import Foundation
import SwiftUI
import SwiftData

/// Manages weather data fetching and state
@MainActor
@Observable
final class WeatherViewModel {
    
    // MARK: - State
    
    var currentWeather: WeatherData?
    var forecast: [WeatherForecast] = []
    var isLoading: Bool = false
    var isForecastLoading: Bool = false
    var errorMessage: String?
    var showError: Bool = false
    var lastRefresh: Date?
    
    // MARK: - Dependencies
    
    private var weatherService: (any WeatherServiceProtocol)?
    private var persistenceService: PersistenceService?
    
    init(weatherService: (any WeatherServiceProtocol)? = nil, persistenceService: PersistenceService? = nil) {
        self.weatherService = weatherService
        self.persistenceService = persistenceService
    }
    
    func configure(weatherService: any WeatherServiceProtocol, persistenceService: PersistenceService) {
        self.weatherService = weatherService
        self.persistenceService = persistenceService
    }
    
    // MARK: - Data Loading
    
    /// Fetches current weather from API
    func fetchWeather() async {
        guard let weatherService = weatherService else {
            errorMessage = "Weather service not configured"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let weatherDTO = try await weatherService.fetchCurrentWeather()
            
            let weather = WeatherData(
                locationName: weatherDTO.name,
                latitude: weatherDTO.coord.lat,
                longitude: weatherDTO.coord.lon,
                temperature: weatherDTO.main.temp,
                feelsLike: weatherDTO.main.feelsLike,
                temperatureMin: weatherDTO.main.tempMin,
                temperatureMax: weatherDTO.main.tempMax,
                humidity: weatherDTO.main.humidity,
                windSpeed: weatherDTO.wind.speed,
                windDirection: weatherDTO.wind.deg,
                conditionCode: weatherDTO.weather.first?.icon ?? "01d",
                conditionDescription: weatherDTO.weather.first?.description.capitalized ?? "Unknown",
                conditionIconName: WeatherData.iconName(for: weatherDTO.weather.first?.icon ?? "01d"),
                uvIndex: 0,
                visibility: 10.0,
                pressure: weatherDTO.main.pressure,
                sunrise: Date(timeIntervalSince1970: weatherDTO.sys.sunrise),
                sunset: Date(timeIntervalSince1970: weatherDTO.sys.sunset)
            )
            
            self.currentWeather = weather
            self.lastRefresh = Date()
            
            if let persistenceService = persistenceService {
                try? persistenceService.cacheWeather(weather)
            }
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    /// Fetches 7-day forecast
    func fetchForecast() async {
        guard let weatherService = weatherService else { return }
        
        isForecastLoading = true
        
        do {
            let forecastDTO = try await weatherService.fetchForecast()
            let calendar = Calendar.current
            var dailyForecasts: [Date: ForecastItemDTO] = [:]
            
            for item in forecastDTO.list {
                let date = Date(timeIntervalSince1970: item.dt)
                let startOfDay = calendar.startOfDay(for: date)
                
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
                    temperatureMin: item.main.tempMin,
                    temperatureMax: item.main.tempMax,
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
            
            if let persistenceService = persistenceService {
                try? persistenceService.cacheForecast(forecastData)
            }
        } catch {
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
        guard let persistenceService = persistenceService, let currentWeather = currentWeather else { return }
        
        if let cached = try? persistenceService.fetchCachedForecast(
            latitude: currentWeather.latitude,
            longitude: currentWeather.longitude
        ), !cached.isEmpty {
            self.forecast = cached
        }
    }
    
    // MARK: - Error Handling
    
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
    
    func dismissError() {
        showError = false
        errorMessage = nil
    }
    
    // MARK: - Computed Properties
    
    var hasData: Bool { currentWeather != nil }
    
    var lastRefreshFormatted: String? {
        guard let lastRefresh = lastRefresh else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "Updated \(formatter.localizedString(for: lastRefresh, relativeTo: Date()))"
    }
    
    var needsRefresh: Bool {
        guard let lastRefresh = lastRefresh else { return true }
        return Date().timeIntervalSince(lastRefresh) > 1800
    }
}

// MARK: - Display Helpers

extension WeatherViewModel {
    var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }
    
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
        
        switch weather.conditionCode {
        case "01d": return [Color.blue.opacity(0.4), Color.cyan.opacity(0.3), Color.yellow.opacity(0.1)]
        case "02d", "03d": return [Color.blue.opacity(0.3), Color.gray.opacity(0.2), Color.cyan.opacity(0.2)]
        case "04d": return [Color.gray.opacity(0.4), Color.gray.opacity(0.3)]
        case "09d", "10d": return [Color.gray.opacity(0.5), Color.blue.opacity(0.3), Color.gray.opacity(0.4)]
        case "11d": return [Color.gray.opacity(0.6), Color.purple.opacity(0.3), Color.gray.opacity(0.5)]
        case "13d": return [Color.white.opacity(0.3), Color.blue.opacity(0.2), Color.gray.opacity(0.2)]
        default: return [Color.blue.opacity(0.3), Color.cyan.opacity(0.3)]
        }
    }
}
