//
//  MainTabViewModel.swift
//  WeatherHabitTracker
//
//  ViewModel for the main tab view, managing tab selection and app-wide state.
//

import Foundation
import SwiftUI

/// ViewModel that manages the main tab view state.
/// Handles tab selection and coordinates between weather and habit tabs.
@MainActor
@Observable
final class MainTabViewModel {
    
    // MARK: - Tab Definition
    
    /// Available tabs in the app
    enum Tab: Int, CaseIterable, Identifiable {
        case weather = 0
        case habits = 1
        
        var id: Int { rawValue }
        
        /// The display title for each tab
        var title: String {
            switch self {
            case .weather: return "Weather"
            case .habits: return "Habits"
            }
        }
        
        /// The SF Symbol icon name for each tab
        var iconName: String {
            switch self {
            case .weather: return "cloud.sun.fill"
            case .habits: return "checklist"
            }
        }
        
        /// The filled SF Symbol icon name for selected state
        var selectedIconName: String {
            switch self {
            case .weather: return "cloud.sun.fill"
            case .habits: return "checklist"
            }
        }
    }
    
    // MARK: - Properties
    
    /// Currently selected tab
    var selectedTab: Tab = .weather
    
    /// Whether to show the onboarding flow
    var showOnboarding: Bool = false
    
    /// Whether the app has completed initial setup
    var isSetupComplete: Bool {
        get { UserDefaults.standard.bool(forKey: "isSetupComplete") }
        set { UserDefaults.standard.set(newValue, forKey: "isSetupComplete") }
    }
    
    // MARK: - Methods
    
    /// Switches to a specific tab
    /// - Parameter tab: The tab to switch to
    func switchTo(_ tab: Tab) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedTab = tab
        }
    }
    
    /// Completes the onboarding process
    func completeOnboarding() {
        isSetupComplete = true
        showOnboarding = false
    }
    
    /// Checks if onboarding should be shown
    func checkOnboarding() {
        if !isSetupComplete {
            showOnboarding = true
        }
    }
}
