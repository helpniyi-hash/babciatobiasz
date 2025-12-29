//
//  WeatherServiceTests.swift
//  WeatherHabitTrackerTests
//
//  Unit tests for the WeatherService, testing API parsing, error handling, and caching.
//

import XCTest
@testable import WeatherHabitTracker

/// Unit tests for WeatherService functionality
final class WeatherServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    var locationService: LocationService!
    var weatherService: WeatherService!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        locationService = LocationService()
        weatherService = WeatherService(locationService: locationService)
    }
    
    override func tearDownWithError() throws {
        locationService = nil
        weatherService = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Weather Data Model Tests
    
    /// Tests that WeatherData can be initialized with valid values
    func testWeatherDataInitialization() {
        // Given
        let locationName = "San Francisco, CA"
        let temperature = 18.5
        let humidity = 65
        
        // When
        let weatherData = WeatherData(
            locationName: locationName,
            latitude: 37.7749,
            longitude: -122.4194,
            temperature: temperature,
            feelsLike: 17.2,
            temperatureMin: 14.0,
            temperatureMax: 22.0,
            humidity: humidity,
            windSpeed: 3.5,
            windDirection: 270,
            conditionCode: "02d",
            conditionDescription: "Partly Cloudy",
            conditionIconName: "cloud.sun.fill"
        )
        
        // Then
        XCTAssertEqual(weatherData.locationName, locationName)
        XCTAssertEqual(weatherData.temperature, temperature)
        XCTAssertEqual(weatherData.humidity, humidity)
        XCTAssertNotNil(weatherData.id)
    }
    
    /// Tests temperature formatting
    func testTemperatureFormatting() {
        // Given
        let weatherData = WeatherData.sampleData
        
        // When
        let formatted = weatherData.temperatureFormatted
        
        // Then
        XCTAssertTrue(formatted.contains("°"))
        XCTAssertFalse(formatted.isEmpty)
    }
    
    /// Tests high/low temperature formatting
    func testHighLowFormatting() {
        // Given
        let weatherData = WeatherData.sampleData
        
        // When
        let formatted = weatherData.highLowFormatted
        
        // Then
        XCTAssertTrue(formatted.contains("H:"))
        XCTAssertTrue(formatted.contains("L:"))
    }
    
    /// Tests cache expiration logic
    func testCacheExpiration() {
        // Given - Fresh data
        let freshWeather = WeatherData(
            locationName: "Test",
            latitude: 0,
            longitude: 0,
            temperature: 20,
            feelsLike: 20,
            temperatureMin: 18,
            temperatureMax: 22,
            humidity: 50,
            windSpeed: 2,
            windDirection: 0,
            conditionCode: "01d",
            conditionDescription: "Clear",
            conditionIconName: "sun.max.fill",
            cacheMinutes: 30
        )
        
        // Then
        XCTAssertFalse(freshWeather.isExpired)
    }
    
    // MARK: - Weather Condition Icon Mapping Tests
    
    /// Tests icon mapping for clear day
    func testClearDayIconMapping() {
        // When
        let icon = WeatherData.iconName(for: "01d")
        
        // Then
        XCTAssertEqual(icon, "sun.max.fill")
    }
    
    /// Tests icon mapping for clear night
    func testClearNightIconMapping() {
        // When
        let icon = WeatherData.iconName(for: "01n")
        
        // Then
        XCTAssertEqual(icon, "moon.fill")
    }
    
    /// Tests icon mapping for rain
    func testRainIconMapping() {
        // When
        let dayIcon = WeatherData.iconName(for: "10d")
        let nightIcon = WeatherData.iconName(for: "10n")
        
        // Then
        XCTAssertEqual(dayIcon, "cloud.sun.rain.fill")
        XCTAssertEqual(nightIcon, "cloud.moon.rain.fill")
    }
    
    /// Tests icon mapping for thunderstorm
    func testThunderstormIconMapping() {
        // When
        let icon = WeatherData.iconName(for: "11d")
        
        // Then
        XCTAssertEqual(icon, "cloud.bolt.rain.fill")
    }
    
    /// Tests icon mapping for snow
    func testSnowIconMapping() {
        // When
        let icon = WeatherData.iconName(for: "13d")
        
        // Then
        XCTAssertEqual(icon, "cloud.snow.fill")
    }
    
    // MARK: - Weather Forecast Tests
    
    /// Tests forecast initialization
    func testForecastInitialization() {
        // Given
        let date = Date()
        
        // When
        let forecast = WeatherForecast(
            date: date,
            latitude: 37.7749,
            longitude: -122.4194,
            temperatureMin: 14.0,
            temperatureMax: 22.0,
            humidity: 60,
            windSpeed: 3.0,
            conditionCode: "02d",
            conditionDescription: "Partly Cloudy",
            conditionIconName: "cloud.sun.fill"
        )
        
        // Then
        XCTAssertEqual(forecast.date, date)
        XCTAssertEqual(forecast.temperatureMin, 14.0)
        XCTAssertEqual(forecast.temperatureMax, 22.0)
    }
    
    /// Tests forecast day name for today
    func testForecastDayNameToday() {
        // Given
        let forecast = WeatherForecast(
            date: Date(),
            latitude: 0,
            longitude: 0,
            temperatureMin: 10,
            temperatureMax: 20,
            humidity: 50,
            windSpeed: 2,
            conditionCode: "01d",
            conditionDescription: "Clear",
            conditionIconName: "sun.max.fill"
        )
        
        // When
        let dayName = forecast.dayName
        
        // Then
        XCTAssertEqual(dayName, "Today")
    }
    
    /// Tests forecast day name for tomorrow
    func testForecastDayNameTomorrow() {
        // Given
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let forecast = WeatherForecast(
            date: tomorrow,
            latitude: 0,
            longitude: 0,
            temperatureMin: 10,
            temperatureMax: 20,
            humidity: 50,
            windSpeed: 2,
            conditionCode: "01d",
            conditionDescription: "Clear",
            conditionIconName: "sun.max.fill"
        )
        
        // When
        let dayName = forecast.dayName
        
        // Then
        XCTAssertEqual(dayName, "Tomorrow")
    }
    
    /// Tests sample forecast generation
    func testSampleForecastGeneration() {
        // When
        let forecasts = WeatherForecast.sampleForecast
        
        // Then
        XCTAssertEqual(forecasts.count, 7)
        XCTAssertTrue(forecasts.allSatisfy { !$0.conditionDescription.isEmpty })
    }
    
    // MARK: - Error Handling Tests
    
    /// Tests WeatherError descriptions
    func testWeatherErrorDescriptions() {
        // Given
        let errors: [WeatherError] = [
            .invalidURL,
            .invalidResponse,
            .httpError(statusCode: 401),
            .httpError(statusCode: 500),
            .noData,
            .apiKeyMissing
        ]
        
        // Then
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }
    
    /// Tests 401 error message mentions API key
    func testUnauthorizedErrorMessage() {
        // Given
        let error = WeatherError.httpError(statusCode: 401)
        
        // Then
        XCTAssertTrue(error.errorDescription!.lowercased().contains("api key"))
    }
}
