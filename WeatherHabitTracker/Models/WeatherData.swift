//
//  WeatherData.swift
//  WeatherHabitTracker
//
//  SwiftData model representing current weather data for a location.
//  Cached locally for offline access and to reduce API calls.
//

import Foundation
import SwiftData

/// Represents the current weather conditions for a specific location.
/// Persisted using SwiftData for offline caching and quick access.
@Model
final class WeatherData {
    
    // MARK: - Properties
    
    /// Unique identifier for this weather data record
    var id: UUID
    
    /// The name of the location (city, region)
    var locationName: String
    
    /// Latitude coordinate
    var latitude: Double
    
    /// Longitude coordinate
    var longitude: Double
    
    /// Current temperature in Celsius
    var temperature: Double
    
    /// Feels like temperature in Celsius
    var feelsLike: Double
    
    /// Minimum temperature for the day in Celsius
    var temperatureMin: Double
    
    /// Maximum temperature for the day in Celsius
    var temperatureMax: Double
    
    /// Humidity percentage (0-100)
    var humidity: Int
    
    /// Wind speed in meters per second
    var windSpeed: Double
    
    /// Wind direction in degrees
    var windDirection: Int
    
    /// Weather condition code (maps to icons)
    var conditionCode: String
    
    /// Human-readable weather description
    var conditionDescription: String
    
    /// SF Symbol name for the weather condition
    var conditionIconName: String
    
    /// UV index value
    var uvIndex: Int
    
    /// Visibility in kilometers
    var visibility: Double
    
    /// Atmospheric pressure in hPa
    var pressure: Int
    
    /// Sunrise time
    var sunrise: Date?
    
    /// Sunset time
    var sunset: Date?
    
    /// When this data was fetched from the API
    var fetchedAt: Date
    
    /// When this data expires and should be refreshed
    var expiresAt: Date
    
    // MARK: - Computed Properties
    
    /// Checks if this cached data is still valid
    var isExpired: Bool {
        Date() > expiresAt
    }
    
    /// Returns temperature formatted with unit
    var temperatureFormatted: String {
        String(format: "%.0f°", temperature)
    }
    
    /// Returns feels like temperature formatted
    var feelsLikeFormatted: String {
        String(format: "%.0f°", feelsLike)
    }
    
    /// Returns high/low temperature formatted
    var highLowFormatted: String {
        String(format: "H:%.0f° L:%.0f°", temperatureMax, temperatureMin)
    }
    
    /// Returns wind speed formatted
    var windSpeedFormatted: String {
        String(format: "%.1f m/s", windSpeed)
    }
    
    // MARK: - Initialization
    
    /// Creates a new WeatherData instance
    /// - Parameters:
    ///   - locationName: Name of the location
    ///   - latitude: Latitude coordinate
    ///   - longitude: Longitude coordinate
    ///   - temperature: Current temperature in Celsius
    ///   - feelsLike: Feels like temperature
    ///   - temperatureMin: Daily minimum temperature
    ///   - temperatureMax: Daily maximum temperature
    ///   - humidity: Humidity percentage
    ///   - windSpeed: Wind speed in m/s
    ///   - windDirection: Wind direction in degrees
    ///   - conditionCode: Weather condition code
    ///   - conditionDescription: Human-readable description
    ///   - conditionIconName: SF Symbol icon name
    ///   - uvIndex: UV index value
    ///   - visibility: Visibility in km
    ///   - pressure: Atmospheric pressure
    ///   - sunrise: Sunrise time
    ///   - sunset: Sunset time
    ///   - cacheMinutes: How long to cache this data (default 30 minutes)
    init(
        locationName: String,
        latitude: Double,
        longitude: Double,
        temperature: Double,
        feelsLike: Double,
        temperatureMin: Double,
        temperatureMax: Double,
        humidity: Int,
        windSpeed: Double,
        windDirection: Int,
        conditionCode: String,
        conditionDescription: String,
        conditionIconName: String,
        uvIndex: Int = 0,
        visibility: Double = 10.0,
        pressure: Int = 1013,
        sunrise: Date? = nil,
        sunset: Date? = nil,
        cacheMinutes: Int = 30
    ) {
        self.id = UUID()
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.temperatureMin = temperatureMin
        self.temperatureMax = temperatureMax
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.windDirection = windDirection
        self.conditionCode = conditionCode
        self.conditionDescription = conditionDescription
        self.conditionIconName = conditionIconName
        self.uvIndex = uvIndex
        self.visibility = visibility
        self.pressure = pressure
        self.sunrise = sunrise
        self.sunset = sunset
        self.fetchedAt = Date()
        self.expiresAt = Date().addingTimeInterval(TimeInterval(cacheMinutes * 60))
    }
}

// MARK: - Weather Condition Mapping

extension WeatherData {
    /// Maps weather condition codes to SF Symbols
    /// Supports OpenWeatherMap condition codes
    static func iconName(for conditionCode: String, isDay: Bool = true) -> String {
        switch conditionCode {
        // Thunderstorm
        case "11d", "11n":
            return "cloud.bolt.rain.fill"
        // Drizzle
        case "09d", "09n":
            return "cloud.drizzle.fill"
        // Rain
        case "10d":
            return "cloud.sun.rain.fill"
        case "10n":
            return "cloud.moon.rain.fill"
        // Snow
        case "13d", "13n":
            return "cloud.snow.fill"
        // Atmosphere (fog, mist, etc.)
        case "50d", "50n":
            return "cloud.fog.fill"
        // Clear
        case "01d":
            return "sun.max.fill"
        case "01n":
            return "moon.fill"
        // Few clouds
        case "02d":
            return "cloud.sun.fill"
        case "02n":
            return "cloud.moon.fill"
        // Scattered clouds
        case "03d", "03n":
            return "cloud.fill"
        // Broken clouds / overcast
        case "04d", "04n":
            return "smoke.fill"
        default:
            return isDay ? "sun.max.fill" : "moon.fill"
        }
    }
}

// MARK: - Sample Data

extension WeatherData {
    /// Creates sample weather data for previews and testing
    static var sampleData: WeatherData {
        WeatherData(
            locationName: "San Francisco, CA",
            latitude: 37.7749,
            longitude: -122.4194,
            temperature: 18.5,
            feelsLike: 17.2,
            temperatureMin: 14.0,
            temperatureMax: 22.0,
            humidity: 65,
            windSpeed: 3.5,
            windDirection: 270,
            conditionCode: "02d",
            conditionDescription: "Partly Cloudy",
            conditionIconName: "cloud.sun.fill",
            uvIndex: 5,
            visibility: 10.0,
            pressure: 1015,
            sunrise: Calendar.current.date(bySettingHour: 6, minute: 45, second: 0, of: Date()),
            sunset: Calendar.current.date(bySettingHour: 17, minute: 30, second: 0, of: Date())
        )
    }
}
