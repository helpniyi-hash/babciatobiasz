//
//  MainTabViewModel.swift
//  BabciaTobiasz
//
//  ViewModel for managing tab selection state.
//

import Foundation
import SwiftUI

/// Manages the selected tab state for the main navigation.
@Observable
final class MainTabViewModel {
    
    // MARK: - Tab Enum
    
    /// Available tabs in the app
    enum Tab: String, CaseIterable, Identifiable {
        case weather
        case habits
        case settings
        
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .weather: return "Weather"
            case .habits: return "Habits"
            case .settings: return "Settings"
            }
        }
        
        var iconName: String {
            switch self {
            case .weather: return "cloud.sun.fill"
            case .habits: return "checklist"
            case .settings: return "gear"
            }
        }
    }
    
    // MARK: - State
    
    /// Currently selected tab
    var selectedTab: Tab = .weather
    
    // MARK: - Initialization
    
    init(selectedTab: Tab = .weather) {
        self.selectedTab = selectedTab
    }
}
