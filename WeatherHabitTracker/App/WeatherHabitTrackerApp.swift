//
//  WeatherHabitTrackerApp.swift
//  WeatherHabitTracker
//
//  Created on 2024-12-30.
//  A modern iOS app combining weather tracking with habit management.
//  Built with Swift 6+, SwiftUI, SwiftData, and Apple's Liquid Glass design.
//

import SwiftUI
import SwiftData

/// The main entry point for the WeatherHabitTracker application.
/// This struct conforms to the App protocol and sets up the app's main scene,
/// dependency injection, and SwiftData model container.
@main
struct WeatherHabitTrackerApp: App {
    
    // MARK: - Properties
    
    /// Shared app dependencies container for dependency injection
    @State private var dependencies = AppDependencies()
    
    /// SwiftData model container for persistent storage
    let modelContainer: ModelContainer
    
    // MARK: - Initialization
    
    /// Initializes the app and configures the SwiftData model container.
    /// Sets up persistence for Habit and WeatherData models.
    init() {
        do {
            // Configure the schema with all SwiftData models
            let schema = Schema([
                Habit.self,
                HabitCompletion.self,
                WeatherData.self,
                WeatherForecast.self
            ])
            
            // Create model configuration with CloudKit preparation
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none // Ready to switch to .automatic for CloudKit
            )
            
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Note: iOS 26+ automatically applies Liquid Glass to standard components.
            // No custom appearance configuration needed - system handles it.
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            LaunchView()
                .environment(dependencies)
                .modelContainer(modelContainer)
        }
        #if os(macOS)
        .windowStyle(.automatic)
        #endif
    }
}
