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
        case home
        case areas
        case babcia
        case gallery
        case settings
        
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .home: return "Home"
            case .areas: return "Areas"
            case .babcia: return "Babcia"
            case .gallery: return "Gallery"
            case .settings: return "Settings"
            }
        }
        
        var iconName: String {
            switch self {
            case .home: return "house.fill"
            case .areas: return "square.grid.2x2.fill"
            case .babcia: return "camera.fill"
            case .gallery: return "photo.on.rectangle"
            case .settings: return "gear"
            }
        }
    }
    
    // MARK: - State
    
    /// Currently selected tab
    var selectedTab: Tab = .home
    
    // MARK: - Initialization
    
    init(selectedTab: Tab = .home) {
        self.selectedTab = selectedTab
    }
}
