// PersistenceServiceTests.swift
// WeatherHabitTrackerTests

import XCTest
@testable import WeatherHabitTracker

final class PersistenceServiceTests: XCTestCase {

    // MARK: - Model Tests

    func testHabitCreation() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#FF0000")

        XCTAssertEqual(habit.name, "Test")
        XCTAssertEqual(habit.iconName, "star")
        XCTAssertEqual(habit.colorHex, "#FF0000")
    }

    func testHabitWithDescription() {
        let habit = Habit(
            name: "Exercise",
            description: "Daily workout",
            iconName: "figure.run",
            colorHex: "#00FF00"
        )

        XCTAssertEqual(habit.habitDescription, "Daily workout")
    }

    func testHabitCompletionStatus() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#FF0000")

        XCTAssertFalse(habit.isCompletedToday)
        XCTAssertEqual(habit.todayCompletionCount, 0)
    }

    func testHabitStreakInitial() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#FF0000")

        XCTAssertEqual(habit.currentStreak, 0)
        XCTAssertEqual(habit.totalCompletions, 0)
    }

    // MARK: - Weather Data Tests
    
    func testWeatherDataCreation() {
        let weather = createTestWeatherData()
        
        XCTAssertEqual(weather.locationName, "Test City")
        XCTAssertEqual(weather.temperature, 20)
        XCTAssertEqual(weather.humidity, 50)
    }
    
    func testWeatherDataFormatting() {
        let weather = createTestWeatherData()
        
        XCTAssertEqual(weather.temperatureFormatted, "20°")
        XCTAssertFalse(weather.conditionIconName.isEmpty)
    }
    
    func testWeatherDataCoordinates() {
        let weather = createTestWeatherData()
        
        XCTAssertEqual(weather.latitude, 37.77, accuracy: 0.01)
        XCTAssertEqual(weather.longitude, -122.42, accuracy: 0.01)
    }
    
    // MARK: - Weather Forecast Tests
    
    func testForecastCreation() {
        let forecast = createTestForecast()
        
        XCTAssertEqual(forecast.temperatureMin, 15)
        XCTAssertEqual(forecast.temperatureMax, 25)
        XCTAssertEqual(forecast.precipitationProbability, 10)
    }
    
    func testForecastFormatting() {
        let forecast = createTestForecast()
        
        XCTAssertEqual(forecast.lowFormatted, "15°")
        XCTAssertEqual(forecast.highFormatted, "25°")
        XCTAssertEqual(forecast.precipitationFormatted, "10%")
    }
    
    // MARK: - Helpers
    
    private func createTestWeatherData() -> WeatherData {
        WeatherData(
            locationName: "Test City",
            latitude: 37.77,
            longitude: -122.42,
            temperature: 20,
            feelsLike: 19,
            temperatureMin: 18,
            temperatureMax: 22,
            humidity: 50,
            windSpeed: 5,
            windDirection: 180,
            conditionCode: "01d",
            conditionDescription: "Clear",
            conditionIconName: "sun.max.fill",
            uvIndex: 5,
            visibility: 10,
            pressure: 1013,
            sunrise: Date(),
            sunset: Date().addingTimeInterval(43200)
        )
    }
    
    private func createTestForecast() -> WeatherForecast {
        WeatherForecast(
            date: Date(),
            latitude: 37.77,
            longitude: -122.42,
            temperatureMin: 15,
            temperatureMax: 25,
            humidity: 50,
            windSpeed: 5,
            conditionCode: "01d",
            conditionDescription: "Clear",
            conditionIconName: "sun.max.fill",
            precipitationProbability: 10,
            uvIndex: 5
        )
    }
}
