//
//  Habit.swift
//  WeatherHabitTracker
//
//  SwiftData model representing a habit that the user wants to track.
//  Supports daily completion tracking, streaks, and notification reminders.
//

import Foundation
import SwiftData
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Represents a habit that the user wants to track over time.
/// Uses SwiftData's @Model macro for automatic persistence.
/// Designed to be CloudKit-ready for future sync capabilities.
@Model
final class Habit {
    
    // MARK: - Properties
    
    /// Unique identifier for the habit
    var id: UUID
    
    /// The name/title of the habit (e.g., "Morning Run", "Read 30 minutes")
    var name: String
    
    /// Optional detailed description of the habit
    var habitDescription: String?
    
    /// The icon name from SF Symbols to represent this habit
    var iconName: String
    
    /// The color associated with this habit (stored as hex string)
    var colorHex: String
    
    /// The date when this habit was created
    var createdAt: Date
    
    /// The time of day when the user should be reminded (optional)
    var reminderTime: Date?
    
    /// Whether notifications are enabled for this habit
    var notificationsEnabled: Bool
    
    /// Target number of times to complete per day (default is 1)
    var targetFrequency: Int
    
    /// The habit's completion records
    @Relationship(deleteRule: .cascade)
    var completions: [HabitCompletion]?
    
    // MARK: - Computed Properties
    
    /// Returns the current streak count (consecutive days completed)
    var currentStreak: Int {
        guard let completions = completions, !completions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedDates = completions
            .map { calendar.startOfDay(for: $0.completedAt) }
            .sorted(by: >)
        
        guard let mostRecentDate = sortedDates.first else { return 0 }
        
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Check if the most recent completion is today or yesterday
        guard mostRecentDate >= yesterday else { return 0 }
        
        var streak = 1
        var currentDate = mostRecentDate
        
        for date in sortedDates.dropFirst() {
            let expectedPreviousDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            if date == expectedPreviousDate {
                streak += 1
                currentDate = date
            } else if date < expectedPreviousDate {
                break
            }
        }
        
        return streak
    }
    
    /// Returns the total number of completions
    var totalCompletions: Int {
        completions?.count ?? 0
    }
    
    /// Checks if the habit is completed for today
    var isCompletedToday: Bool {
        guard let completions = completions else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return completions.contains { calendar.startOfDay(for: $0.completedAt) == today }
    }
    
    /// Returns today's completion count
    var todayCompletionCount: Int {
        guard let completions = completions else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return completions.filter { calendar.startOfDay(for: $0.completedAt) == today }.count
    }
    
    // MARK: - Initialization
    
    /// Creates a new Habit instance
    /// - Parameters:
    ///   - name: The name of the habit
    ///   - description: Optional description
    ///   - iconName: SF Symbol name for the icon
    ///   - colorHex: Hex color string
    ///   - reminderTime: Optional reminder time
    ///   - notificationsEnabled: Whether to enable notifications
    ///   - targetFrequency: Daily target count
    init(
        name: String,
        description: String? = nil,
        iconName: String = "star.fill",
        colorHex: String = "#007AFF",
        reminderTime: Date? = nil,
        notificationsEnabled: Bool = false,
        targetFrequency: Int = 1
    ) {
        self.id = UUID()
        self.name = name
        self.habitDescription = description
        self.iconName = iconName
        self.colorHex = colorHex
        self.createdAt = Date()
        self.reminderTime = reminderTime
        self.notificationsEnabled = notificationsEnabled
        self.targetFrequency = targetFrequency
        self.completions = []
    }
}

// MARK: - HabitCompletion Model

/// Represents a single completion record for a habit.
/// Stored as a separate model to track individual completions with timestamps.
@Model
final class HabitCompletion {
    
    // MARK: - Properties
    
    /// Unique identifier for this completion record
    var id: UUID
    
    /// The date and time when the habit was completed
    var completedAt: Date
    
    /// Optional note about this completion
    var note: String?
    
    /// Reference back to the parent habit
    var habit: Habit?
    
    // MARK: - Initialization
    
    /// Creates a new HabitCompletion instance
    /// - Parameters:
    ///   - completedAt: When the habit was completed (defaults to now)
    ///   - note: Optional note about the completion
    init(completedAt: Date = Date(), note: String? = nil) {
        self.id = UUID()
        self.completedAt = completedAt
        self.note = note
    }
}

// MARK: - Color Extension

import SwiftUI

extension Habit {
    /// Converts the stored hex color string to a SwiftUI Color
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

extension Color {
    /// Initialize a Color from a hex string
    /// - Parameter hex: Hex color string (with or without #)
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    /// Converts the Color to a hex string
    var hexString: String {
        #if canImport(UIKit)
        guard let components = UIColor(self).cgColor.components else { return "#007AFF" }
        #elseif canImport(AppKit)
        guard let components = NSColor(self).cgColor.components else { return "#007AFF" }
        #else
        return "#007AFF"
        #endif
        
        let red = Int(components[0] * 255)
        let green = Int(components[1] * 255)
        let blue = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

// MARK: - Sample Data

extension Habit {
    /// Creates sample habits for previews and testing
    static var sampleHabits: [Habit] {
        [
            Habit(
                name: "Morning Exercise",
                description: "30 minutes of cardio or strength training",
                iconName: "figure.run",
                colorHex: "#FF6B6B",
                notificationsEnabled: true,
                targetFrequency: 1
            ),
            Habit(
                name: "Read Books",
                description: "Read at least 20 pages",
                iconName: "book.fill",
                colorHex: "#4ECDC4",
                notificationsEnabled: true,
                targetFrequency: 1
            ),
            Habit(
                name: "Drink Water",
                description: "Stay hydrated throughout the day",
                iconName: "drop.fill",
                colorHex: "#45B7D1",
                notificationsEnabled: false,
                targetFrequency: 8
            ),
            Habit(
                name: "Meditate",
                description: "10 minutes of mindfulness",
                iconName: "brain.head.profile",
                colorHex: "#96CEB4",
                notificationsEnabled: true,
                targetFrequency: 1
            )
        ]
    }
}
