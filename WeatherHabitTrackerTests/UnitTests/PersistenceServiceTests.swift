//
//  PersistenceServiceTests.swift
//  WeatherHabitTrackerTests
//
//  Unit tests for PersistenceService, testing SwiftData operations.
//

import XCTest
import SwiftData
@testable import WeatherHabitTracker

/// Unit tests for PersistenceService functionality
@MainActor
final class PersistenceServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var persistenceService: PersistenceService!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create in-memory model container for testing
        let schema = Schema([
            Habit.self,
            HabitCompletion.self,
            WeatherData.self,
            WeatherForecast.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: config)
        modelContext = modelContainer.mainContext
        persistenceService = PersistenceService(modelContext: modelContext)
    }
    
    override func tearDownWithError() throws {
        persistenceService = nil
        modelContext = nil
        modelContainer = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Habit CRUD Tests
    
    /// Tests creating a habit
    func testCreateHabit() throws {
        // Given
        let habit = Habit(name: "Test Habit")
        
        // When
        try persistenceService.createHabit(habit)
        let habits = try persistenceService.fetchHabits()
        
        // Then
        XCTAssertEqual(habits.count, 1)
        XCTAssertEqual(habits.first?.name, "Test Habit")
    }
    
    /// Tests fetching habits returns sorted results
    func testFetchHabitsSorted() throws {
        // Given
        let habit1 = Habit(name: "First Habit")
        let habit2 = Habit(name: "Second Habit")
        
        try persistenceService.createHabit(habit1)
        // Add small delay to ensure different timestamps
        try persistenceService.createHabit(habit2)
        
        // When
        let habits = try persistenceService.fetchHabits()
        
        // Then
        XCTAssertEqual(habits.count, 2)
        // Most recent first
        XCTAssertEqual(habits.first?.name, "Second Habit")
    }
    
    /// Tests updating a habit
    func testUpdateHabit() throws {
        // Given
        let habit = Habit(name: "Original Name")
        try persistenceService.createHabit(habit)
        
        // When
        habit.name = "Updated Name"
        try persistenceService.updateHabit(habit)
        let habits = try persistenceService.fetchHabits()
        
        // Then
        XCTAssertEqual(habits.first?.name, "Updated Name")
    }
    
    /// Tests deleting a habit
    func testDeleteHabit() throws {
        // Given
        let habit = Habit(name: "To Delete")
        try persistenceService.createHabit(habit)
        
        // Verify it was created
        var habits = try persistenceService.fetchHabits()
        XCTAssertEqual(habits.count, 1)
        
        // When
        try persistenceService.deleteHabit(habit)
        habits = try persistenceService.fetchHabits()
        
        // Then
        XCTAssertEqual(habits.count, 0)
    }
    
    // MARK: - Habit Completion Tests
    
    /// Tests completing a habit
    func testCompleteHabit() throws {
        // Given
        let habit = Habit(name: "Test Habit")
        try persistenceService.createHabit(habit)
        
        // When
        try persistenceService.completeHabit(habit)
        
        // Then
        XCTAssertEqual(habit.completions?.count, 1)
        XCTAssertTrue(habit.isCompletedToday)
    }
    
    /// Tests completing a habit with note
    func testCompleteHabitWithNote() throws {
        // Given
        let habit = Habit(name: "Test Habit")
        try persistenceService.createHabit(habit)
        
        // When
        try persistenceService.completeHabit(habit, note: "Felt great!")
        
        // Then
        XCTAssertEqual(habit.completions?.first?.note, "Felt great!")
    }
    
    /// Tests uncompleting a habit
    func testUncompleteHabit() throws {
        // Given
        let habit = Habit(name: "Test Habit")
        try persistenceService.createHabit(habit)
        try persistenceService.completeHabit(habit)
        
        // Verify completion
        XCTAssertTrue(habit.isCompletedToday)
        
        // When
        try persistenceService.uncompleteHabitForToday(habit)
        
        // Then
        XCTAssertFalse(habit.isCompletedToday)
    }
    
    /// Tests multiple completions for multi-target habit
    func testMultipleCompletions() throws {
        // Given
        let habit = Habit(name: "Drink Water", targetFrequency: 8)
        try persistenceService.createHabit(habit)
        
        // When
        for _ in 1...3 {
            try persistenceService.completeHabit(habit)
        }
        
        // Then
        XCTAssertEqual(habit.todayCompletionCount, 3)
    }
    
    // MARK: - Weather Caching Tests
    
    /// Tests caching weather data
    func testCacheWeather() throws {
        // Given
        let weather = WeatherData.sampleData
        
        // When
        try persistenceService.cacheWeather(weather)
        let cached = try persistenceService.fetchCachedWeather(
            latitude: weather.latitude,
            longitude: weather.longitude
        )
        
        // Then
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.locationName, weather.locationName)
    }
    
    /// Tests weather cache returns nil for expired data
    func testExpiredWeatherCacheReturnsNil() throws {
        // Given - Create expired weather data
        let weather = WeatherData(
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
            cacheMinutes: -1 // Already expired
        )
        
        modelContext.insert(weather)
        try modelContext.save()
        
        // When
        let cached = try persistenceService.fetchCachedWeather(
            latitude: weather.latitude,
            longitude: weather.longitude
        )
        
        // Then
        XCTAssertNil(cached) // Should return nil because expired
    }
    
    /// Tests caching forecast data
    func testCacheForecast() throws {
        // Given
        let forecasts = WeatherForecast.sampleForecast
        
        // When
        try persistenceService.cacheForecast(forecasts)
        let cached = try persistenceService.fetchCachedForecast(
            latitude: forecasts.first!.latitude,
            longitude: forecasts.first!.longitude
        )
        
        // Then
        XCTAssertFalse(cached.isEmpty)
    }
    
    /// Tests caching replaces old data for same location
    func testCacheReplacesOldData() throws {
        // Given
        let weather1 = WeatherData(
            locationName: "Test Location",
            latitude: 37.0,
            longitude: -122.0,
            temperature: 20,
            feelsLike: 20,
            temperatureMin: 18,
            temperatureMax: 22,
            humidity: 50,
            windSpeed: 2,
            windDirection: 0,
            conditionCode: "01d",
            conditionDescription: "Clear",
            conditionIconName: "sun.max.fill"
        )
        
        try persistenceService.cacheWeather(weather1)
        
        // When - Cache new data for same location
        let weather2 = WeatherData(
            locationName: "Test Location Updated",
            latitude: 37.0,
            longitude: -122.0,
            temperature: 25,
            feelsLike: 25,
            temperatureMin: 22,
            temperatureMax: 28,
            humidity: 60,
            windSpeed: 3,
            windDirection: 90,
            conditionCode: "02d",
            conditionDescription: "Partly Cloudy",
            conditionIconName: "cloud.sun.fill"
        )
        
        try persistenceService.cacheWeather(weather2)
        
        let cached = try persistenceService.fetchCachedWeather(latitude: 37.0, longitude: -122.0)
        
        // Then - Should have new data
        XCTAssertEqual(cached?.temperature, 25)
        XCTAssertEqual(cached?.conditionDescription, "Partly Cloudy")
    }
    
    // MARK: - Generic Operations Tests
    
    /// Tests insert operation
    func testInsert() throws {
        // Given
        let habit = Habit(name: "Insert Test")
        
        // When
        persistenceService.insert(habit)
        try persistenceService.save()
        
        // Then
        let habits = try persistenceService.fetchHabits()
        XCTAssertTrue(habits.contains { $0.name == "Insert Test" })
    }
    
    /// Tests delete operation
    func testDelete() throws {
        // Given
        let habit = Habit(name: "Delete Test")
        persistenceService.insert(habit)
        try persistenceService.save()
        
        // When
        persistenceService.delete(habit)
        try persistenceService.save()
        
        // Then
        let habits = try persistenceService.fetchHabits()
        XCTAssertFalse(habits.contains { $0.name == "Delete Test" })
    }
}
