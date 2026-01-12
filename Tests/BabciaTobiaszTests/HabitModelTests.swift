// HabitModelTests.swift
// BabciaTobiaszTests

import XCTest
import SwiftData
@testable import BabciaTobiasz

final class HabitModelTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testHabitInitialization() {
        let habit = Habit(
            name: "Exercise",
            description: "Daily workout",
            iconName: "figure.run",
            colorHex: "#FF5733"
        )
        
        XCTAssertEqual(habit.name, "Exercise")
        XCTAssertEqual(habit.habitDescription, "Daily workout")
        XCTAssertEqual(habit.iconName, "figure.run")
        XCTAssertEqual(habit.colorHex, "#FF5733")
        XCTAssertEqual(habit.targetFrequency, 1)
        XCTAssertFalse(habit.notificationsEnabled)
    }
    
    func testHabitInitializationWithAllParameters() {
        let reminderTime = Date()
        let habit = Habit(
            name: "Meditation",
            description: "Morning meditation",
            iconName: "brain.head.profile",
            colorHex: "#4A90D9",
            reminderTime: reminderTime,
            notificationsEnabled: true,
            targetFrequency: 2
        )
        
        XCTAssertEqual(habit.targetFrequency, 2)
        XCTAssertTrue(habit.notificationsEnabled)
        XCTAssertEqual(habit.reminderTime, reminderTime)
    }
    
    // MARK: - Completion Tests
    
    func testIsCompletedTodayInitiallyFalse() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#000000")
        
        XCTAssertFalse(habit.isCompletedToday)
    }
    
    func testTodayCompletionCountInitiallyZero() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#000000")
        
        XCTAssertEqual(habit.todayCompletionCount, 0)
    }
    
    func testCurrentStreakInitiallyZero() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#000000")
        
        XCTAssertEqual(habit.currentStreak, 0)
    }
    
    func testTotalCompletionsInitiallyZero() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#000000")
        
        XCTAssertEqual(habit.totalCompletions, 0)
    }
    
    // MARK: - Color Tests
    
    func testColorFromHex() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#FF5733")
        let color = habit.color
        
        XCTAssertNotNil(color)
    }
    
    // MARK: - Reminder Tests
    
    func testReminderTimeSet() {
        let components = DateComponents(hour: 9, minute: 30)
        let reminderTime = Calendar.current.date(from: components)!
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#000000", reminderTime: reminderTime)
        
        XCTAssertNotNil(habit.reminderTime)
    }
    
    func testReminderTimeNil() {
        let habit = Habit(name: "Test", iconName: "star", colorHex: "#000000", reminderTime: nil)
        
        XCTAssertNil(habit.reminderTime)
    }
}

// MARK: - WeatherForecast Tests

final class WeatherForecastTests: XCTestCase {
    
    func testForecastInitialization() {
        let date = Date()
        let forecast = WeatherForecast(
            date: date,
            latitude: 37.7749,
            longitude: -122.4194,
            temperatureMin: 15.0,
            temperatureMax: 22.0,
            humidity: 60,
            windSpeed: 5.0,
            conditionCode: "01d",
            conditionDescription: "Clear",
            conditionIconName: "sun.max.fill",
            precipitationProbability: 10,
            uvIndex: 5
        )
        
        XCTAssertEqual(forecast.temperatureMin, 15.0)
        XCTAssertEqual(forecast.temperatureMax, 22.0)
        XCTAssertEqual(forecast.precipitationProbability, 10)
    }
    
    func testShortDayName() {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: 1, to: Date())!
        let forecast = createTestForecast(date: date)
        
        XCTAssertFalse(forecast.shortDayName.isEmpty)
    }
    
    func testPrecipitationFormatted() {
        let forecast = createTestForecast(precipProbability: 45)
        
        XCTAssertEqual(forecast.precipitationFormatted, "45%")
    }
    
    func testHighLowFormatted() {
        let forecast = createTestForecast(tempMin: 15, tempMax: 25)
        
        XCTAssertEqual(forecast.lowFormatted, "15°")
        XCTAssertEqual(forecast.highFormatted, "25°")
    }
    
    private func createTestForecast(
        date: Date = Date(),
        tempMin: Double = 15,
        tempMax: Double = 25,
        precipProbability: Int = 0
    ) -> WeatherForecast {
        WeatherForecast(
            date: date,
            latitude: 0,
            longitude: 0,
            temperatureMin: tempMin,
            temperatureMax: tempMax,
            humidity: 50,
            windSpeed: 5,
            conditionCode: "01d",
            conditionDescription: "Clear",
            conditionIconName: "sun.max.fill",
            precipitationProbability: precipProbability,
            uvIndex: 5
        )
    }
}
