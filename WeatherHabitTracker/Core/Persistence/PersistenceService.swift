// PersistenceService.swift
// WeatherHabitTracker

import Foundation
import SwiftData

@MainActor
final class PersistenceService {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - CRUD
    
    func save() throws {
        try modelContext.save()
    }
    
    func insert<T: PersistentModel>(_ model: T) {
        modelContext.insert(model)
    }
    
    func delete<T: PersistentModel>(_ model: T) {
        modelContext.delete(model)
    }
    
    func fetchAll<T: PersistentModel>() throws -> [T] {
        let descriptor = FetchDescriptor<T>()
        return try modelContext.fetch(descriptor)
    }
    
    func fetch<T: PersistentModel>(predicate: Predicate<T>) throws -> [T] {
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - Habits
    
    func fetchHabits() throws -> [Habit] {
        var descriptor = FetchDescriptor<Habit>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = 100
        return try modelContext.fetch(descriptor)
    }
    
    func createHabit(_ habit: Habit) throws {
        modelContext.insert(habit)
        try modelContext.save()
    }
    
    func updateHabit(_ habit: Habit) throws {
        try modelContext.save()
    }
    
    func deleteHabit(_ habit: Habit) throws {
        modelContext.delete(habit)
        try modelContext.save()
    }
    
    func completeHabit(_ habit: Habit, note: String? = nil) throws {
        let completion = HabitCompletion(completedAt: Date(), note: note)
        completion.habit = habit
        
        if habit.completions == nil {
            habit.completions = []
        }
        habit.completions?.append(completion)
        
        try modelContext.save()
    }
    
    func uncompleteHabitForToday(_ habit: Habit) throws {
        guard let completions = habit.completions else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let todayCompletions = completions.filter {
            calendar.startOfDay(for: $0.completedAt) == today
        }
        
        if let lastCompletion = todayCompletions.last {
            modelContext.delete(lastCompletion)
            habit.completions?.removeAll { $0.id == lastCompletion.id }
            try modelContext.save()
        }
    }
    
    // MARK: - Weather
    
    func fetchCachedWeather(latitude: Double, longitude: Double) throws -> WeatherData? {
        let tolerance = 0.01
        
        let predicate = #Predicate<WeatherData> { weather in
            weather.latitude > latitude - tolerance &&
            weather.latitude < latitude + tolerance &&
            weather.longitude > longitude - tolerance &&
            weather.longitude < longitude + tolerance
        }
        
        let descriptor = FetchDescriptor<WeatherData>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.fetchedAt, order: .reverse)]
        )
        
        let results = try modelContext.fetch(descriptor)
        
        if let cached = results.first, !cached.isExpired {
            return cached
        }
        
        return nil
    }
    
    func cacheWeather(_ weather: WeatherData) throws {
        let tolerance = 0.01
        let targetLat = weather.latitude
        let targetLon = weather.longitude
        
        let predicate = #Predicate<WeatherData> { weather in
            weather.latitude > targetLat - tolerance &&
            weather.latitude < targetLat + tolerance &&
            weather.longitude > targetLon - tolerance &&
            weather.longitude < targetLon + tolerance
        }
        
        let descriptor = FetchDescriptor<WeatherData>(predicate: predicate)
        let oldData = try modelContext.fetch(descriptor)
        
        for old in oldData {
            modelContext.delete(old)
        }
        
        modelContext.insert(weather)
        try modelContext.save()
    }
    
    func fetchCachedForecast(latitude: Double, longitude: Double) throws -> [WeatherForecast] {
        let tolerance = 0.01
        let today = Calendar.current.startOfDay(for: Date())
        
        let predicate = #Predicate<WeatherForecast> { forecast in
            forecast.latitude > latitude - tolerance &&
            forecast.latitude < latitude + tolerance &&
            forecast.longitude > longitude - tolerance &&
            forecast.longitude < longitude + tolerance &&
            forecast.date >= today
        }
        
        let descriptor = FetchDescriptor<WeatherForecast>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    func cacheForecast(_ forecasts: [WeatherForecast]) throws {
        guard let first = forecasts.first else { return }
        
        let tolerance = 0.01
        let latitude = first.latitude
        let longitude = first.longitude
        
        let predicate = #Predicate<WeatherForecast> { forecast in
            forecast.latitude > latitude - tolerance &&
            forecast.latitude < latitude + tolerance &&
            forecast.longitude > longitude - tolerance &&
            forecast.longitude < longitude + tolerance
        }
        
        let descriptor = FetchDescriptor<WeatherForecast>(predicate: predicate)
        let oldData = try modelContext.fetch(descriptor)
        
        for old in oldData {
            modelContext.delete(old)
        }
        
        for forecast in forecasts {
            modelContext.insert(forecast)
        }
        
        try modelContext.save()
    }
    
    // MARK: - Cleanup Operations
    
    /// Removes expired weather data
    /// - Throws: Error if operation fails
    func cleanupExpiredWeatherData() throws {
        let now = Date()
        
        // Clean up expired current weather
        let weatherPredicate = #Predicate<WeatherData> { weather in
            weather.expiresAt < now
        }
        let weatherDescriptor = FetchDescriptor<WeatherData>(predicate: weatherPredicate)
        let expiredWeather = try modelContext.fetch(weatherDescriptor)
        
        for weather in expiredWeather {
            modelContext.delete(weather)
        }
        
        // Clean up old forecasts
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let forecastPredicate = #Predicate<WeatherForecast> { forecast in
            forecast.date < yesterday
        }
        let forecastDescriptor = FetchDescriptor<WeatherForecast>(predicate: forecastPredicate)
        let oldForecasts = try modelContext.fetch(forecastDescriptor)
        
        for forecast in oldForecasts {
            modelContext.delete(forecast)
        }
        
        try modelContext.save()
    }
}
