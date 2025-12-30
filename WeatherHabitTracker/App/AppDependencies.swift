//
//  AppDependencies.swift
//  WeatherHabitTracker
//

import Foundation
import SwiftUI

/// Dependency injection container for app services
@Observable @MainActor
final class AppDependencies {
    
    // MARK: - Services
    
    let weatherService: WeatherService
    let notificationService: NotificationService
    let locationService: LocationService
    
    // MARK: - Init
    
    init(
        weatherService: WeatherService? = nil,
        notificationService: NotificationService? = nil,
        locationService: LocationService? = nil
    ) {
        let location = locationService ?? LocationService()
        self.locationService = location
        self.weatherService = weatherService ?? WeatherService(locationService: location)
        self.notificationService = notificationService ?? NotificationService()
    }
}

// MARK: - Environment Key

private struct AppDependenciesKey: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue = AppDependencies()
}

extension EnvironmentValues {
    var appDependencies: AppDependencies {
        get { self[AppDependenciesKey.self] }
        set { self[AppDependenciesKey.self] = newValue }
    }
}
