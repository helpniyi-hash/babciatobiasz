//
//  AppDependencies.swift
//  WeatherHabitTracker
//
//  Centralized dependency injection container for all app services.
//  This follows the Dependency Injection pattern for better testability and modularity.
//

import Foundation
import SwiftUI

/// A container class that holds all app-wide dependencies and services.
/// Uses the @Observable macro for automatic SwiftUI updates when services change state.
/// Injected into the environment for access throughout the app.
@Observable
final class AppDependencies {
    
    // MARK: - Services
    
    /// Service responsible for fetching weather data from WeatherKit or fallback API
    let weatherService: WeatherService
    
    /// Service responsible for managing local notifications for habit reminders
    let notificationService: NotificationService
    
    /// Service responsible for handling user location permissions and updates
    let locationService: LocationService
    
    // MARK: - Initialization
    
    /// Initializes all app dependencies with default implementations.
    /// For testing, you can inject mock services instead.
    /// - Parameters:
    ///   - weatherService: Custom weather service implementation (defaults to production service)
    ///   - notificationService: Custom notification service (defaults to production service)
    ///   - locationService: Custom location service (defaults to production service)
    @MainActor
    init(
        weatherService: WeatherService? = nil,
        notificationService: NotificationService? = nil,
        locationService: LocationService? = nil
    ) {
        let location = locationService ?? LocationService()
        self.locationService = location
        self.weatherService = weatherService ?? WeatherService(locationService: location)
        
        if let notificationService = notificationService {
            self.notificationService = notificationService
        } else {
            // Initialize on main actor if needed, but here we just create it
            // NotificationService is @MainActor, so we must be careful.
            // Since init is non-isolated, we can't call @MainActor init synchronously easily if we are not on main actor.
            // However, AppDependencies is usually created at app launch (MainActor).
            // Let's assume this init is called from MainActor.
            self.notificationService = NotificationService()
        }
    }
}

// MARK: - Environment Key

/// Custom environment key for accessing AppDependencies throughout the view hierarchy
@MainActor
private struct AppDependenciesKey: @MainActor EnvironmentKey {
    static let defaultValue = AppDependencies()
}

extension EnvironmentValues {
    /// Accessor for AppDependencies in the SwiftUI environment
    @MainActor
    var appDependencies: AppDependencies {
        get { self[AppDependenciesKey.self] }
        set { self[AppDependenciesKey.self] = newValue }
    }
}
