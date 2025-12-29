//
//  WeatherForecast.swift
//  WeatherHabitTracker
//
//  SwiftData model representing a daily weather forecast.
//  Used to display the 7-day forecast in the Weather tab.
//

import Foundation
import SwiftData

/// Represents a single day's weather forecast.
/// Part of the 7-day forecast displayed in the Weather view.
@Model
final class WeatherForecast {
    
    // MARK: - Properties
    
    /// Unique identifier for this forecast record
    var id: UUID
    
    /// The date this forecast is for
    var date: Date
    
    /// Latitude coordinate (to link forecast to location)
    var latitude: Double
    
    /// Longitude coordinate
    var longitude: Double
    
    /// Minimum temperature for the day in Celsius
    var temperatureMin: Double
    
    /// Maximum temperature for the day in Celsius
    var temperatureMax: Double
    
    /// Average humidity percentage
    var humidity: Int
    
    /// Wind speed in meters per second
    var windSpeed: Double
    
    /// Weather condition code
    var conditionCode: String
    
    /// Human-readable weather description
    var conditionDescription: String
    
    /// SF Symbol name for the weather condition
    var conditionIconName: String
    
    /// Probability of precipitation (0-100)
    var precipitationProbability: Int
    
    /// UV index value
    var uvIndex: Int
    
    /// Sunrise time for this day
    var sunrise: Date?
    
    /// Sunset time for this day
    var sunset: Date?
    
    /// When this forecast data was fetched
    var fetchedAt: Date
    
    // MARK: - Computed Properties
    
    /// Returns the day name (e.g., "Monday", "Today", "Tomorrow")
    var dayName: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }
    }
    
    /// Returns short day name (e.g., "Mon", "Tue")
    var shortDayName: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return formatter.string(from: date)
        }
    }
    
    /// Returns formatted date string
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    /// Returns high temperature formatted
    var highFormatted: String {
        String(format: "%.0f°", temperatureMax)
    }
    
    /// Returns low temperature formatted
    var lowFormatted: String {
        String(format: "%.0f°", temperatureMin)
    }
    
    /// Returns precipitation probability formatted
    var precipitationFormatted: String {
        "\(precipitationProbability)%"
    }
    
    // MARK: - Initialization
    
    /// Creates a new WeatherForecast instance
    /// - Parameters:
    ///   - date: The forecast date
    ///   - latitude: Latitude coordinate
    ///   - longitude: Longitude coordinate
    ///   - temperatureMin: Minimum temperature
    ///   - temperatureMax: Maximum temperature
    ///   - humidity: Humidity percentage
    ///   - windSpeed: Wind speed in m/s
    ///   - conditionCode: Weather condition code
    ///   - conditionDescription: Human-readable description
    ///   - conditionIconName: SF Symbol icon name
    ///   - precipitationProbability: Chance of precipitation
    ///   - uvIndex: UV index value
    ///   - sunrise: Sunrise time
    ///   - sunset: Sunset time
    init(
        date: Date,
        latitude: Double,
        longitude: Double,
        temperatureMin: Double,
        temperatureMax: Double,
        humidity: Int,
        windSpeed: Double,
        conditionCode: String,
        conditionDescription: String,
        conditionIconName: String,
        precipitationProbability: Int = 0,
        uvIndex: Int = 0,
        sunrise: Date? = nil,
        sunset: Date? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
        self.temperatureMin = temperatureMin
        self.temperatureMax = temperatureMax
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.conditionCode = conditionCode
        self.conditionDescription = conditionDescription
        self.conditionIconName = conditionIconName
        self.precipitationProbability = precipitationProbability
        self.uvIndex = uvIndex
        self.sunrise = sunrise
        self.sunset = sunset
        self.fetchedAt = Date()
    }
}

// MARK: - Sample Data

extension WeatherForecast {
    /// Creates sample forecast data for previews and testing
    static var sampleForecast: [WeatherForecast] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
            
            // Simulate varying weather conditions
            let conditions: [(code: String, description: String, icon: String)] = [
                ("01d", "Clear", "sun.max.fill"),
                ("02d", "Partly Cloudy", "cloud.sun.fill"),
                ("03d", "Cloudy", "cloud.fill"),
                ("10d", "Light Rain", "cloud.sun.rain.fill"),
                ("01d", "Sunny", "sun.max.fill"),
                ("02d", "Mostly Sunny", "cloud.sun.fill"),
                ("04d", "Overcast", "smoke.fill")
            ]
            
            let condition = conditions[dayOffset]
            let baseTemp = 18.0 + Double.random(in: -5...5)
            
            return WeatherForecast(
                date: date,
                latitude: 37.7749,
                longitude: -122.4194,
                temperatureMin: baseTemp - Double.random(in: 3...6),
                temperatureMax: baseTemp + Double.random(in: 3...6),
                humidity: Int.random(in: 40...80),
                windSpeed: Double.random(in: 1...8),
                conditionCode: condition.code,
                conditionDescription: condition.description,
                conditionIconName: condition.icon,
                precipitationProbability: dayOffset == 3 ? 60 : Int.random(in: 0...30),
                uvIndex: Int.random(in: 1...10),
                sunrise: calendar.date(bySettingHour: 6, minute: 45 + dayOffset, second: 0, of: date),
                sunset: calendar.date(bySettingHour: 17, minute: 30 - dayOffset, second: 0, of: date)
            )
        }
    }
}
