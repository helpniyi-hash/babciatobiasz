//
//  BabciaAppShortcuts.swift
//  BabciaTobiasz
//
//  AppIntents shortcuts for quick access.
//

import AppIntents
import Foundation

enum AppIntentRoute: String {
    case none
    case home
    case areas
    case babcia
    case gallery
    case settings
    case startScan

    static let storageKey = "appIntentRoute"

    static func store(_ route: AppIntentRoute) {
        UserDefaults.standard.set(route.rawValue, forKey: storageKey)
    }
}

struct StartScanIntent: AppIntent {
    static let title: LocalizedStringResource = "shortcut_start_scan_title"
    static let description = IntentDescription("shortcut_start_scan_description")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        AppIntentRoute.store(.startScan)
        return .result()
    }
}

struct OpenAreasIntent: AppIntent {
    static let title: LocalizedStringResource = "shortcut_open_areas_title"
    static let description = IntentDescription("shortcut_open_areas_description")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        AppIntentRoute.store(.areas)
        return .result()
    }
}

struct BabciaAppShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartScanIntent(),
            phrases: [
                "Start a scan in \(.applicationName)",
                "Open a scan in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("shortcut_start_scan_title"),
            systemImageName: "camera.fill"
        )
        AppShortcut(
            intent: OpenAreasIntent(),
            phrases: [
                "Open areas in \(.applicationName)",
                "Show areas in \(.applicationName)"
            ],
            shortTitle: LocalizedStringResource("shortcut_open_areas_title"),
            systemImageName: "square.grid.2x2.fill"
        )
    }
}
