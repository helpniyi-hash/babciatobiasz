//
//  HabitViewModel.swift
//  WeatherHabitTracker
//
//  ViewModel for habit management, handling CRUD operations and statistics.
//  Coordinates between persistence and UI for habit tracking functionality.
//

import Foundation
import SwiftUI
import SwiftData

/// ViewModel that manages habit data and operations.
/// Provides reactive updates for habit list and individual habit actions.
@MainActor
@Observable
final class HabitViewModel {
    
    // MARK: - State
    
    /// All habits loaded from persistence
    var habits: [Habit] = []
    
    /// Currently selected habit for detail view
    var selectedHabit: Habit?
    
    /// Whether habits are being loaded
    var isLoading: Bool = false
    
    /// Error message to display
    var errorMessage: String?
    
    /// Whether to show error alert
    var showError: Bool = false
    
    /// Whether to show the add/edit habit form
    var showHabitForm: Bool = false
    
    /// The habit being edited (nil for new habit)
    var editingHabit: Habit?
    
    /// Search text for filtering habits
    var searchText: String = ""
    
    /// Selected filter option
    var filterOption: FilterOption = .all
    
    // MARK: - Filter Options
    
    /// Options for filtering the habit list
    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All"
        case completed = "Completed Today"
        case incomplete = "Not Completed"
        
        var id: String { rawValue }
    }
    
    // MARK: - Dependencies
    
    /// Persistence service for data operations
    private var persistenceService: PersistenceService?
    
    /// Notification service for reminders
    private var notificationService: NotificationService?
    
    // MARK: - Computed Properties
    
    /// Filtered habits based on search and filter
    var filteredHabits: [Habit] {
        var result = habits
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { habit in
                habit.name.localizedCaseInsensitiveContains(searchText) ||
                (habit.habitDescription?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Apply completion filter
        switch filterOption {
        case .all:
            break
        case .completed:
            result = result.filter { $0.isCompletedToday }
        case .incomplete:
            result = result.filter { !$0.isCompletedToday }
        }
        
        return result
    }
    
    /// Number of habits completed today
    var completedTodayCount: Int {
        habits.filter { $0.isCompletedToday }.count
    }
    
    /// Total number of habits
    var totalHabitsCount: Int {
        habits.count
    }
    
    /// Completion percentage for today
    var todayCompletionPercentage: Double {
        guard !habits.isEmpty else { return 0 }
        return Double(completedTodayCount) / Double(totalHabitsCount)
    }
    
    /// Best current streak among all habits
    var bestStreak: Int {
        habits.map { $0.currentStreak }.max() ?? 0
    }
    
    /// Total completions across all habits
    var totalCompletions: Int {
        habits.reduce(0) { $0 + $1.totalCompletions }
    }
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with optional dependencies
    /// - Parameters:
    ///   - persistenceService: The persistence service for data operations
    ///   - notificationService: The notification service for reminders
    init(
        persistenceService: PersistenceService? = nil,
        notificationService: NotificationService? = nil
    ) {
        self.persistenceService = persistenceService
        self.notificationService = notificationService
    }
    
    // MARK: - Configuration
    
    /// Configures the ViewModel with dependencies
    /// - Parameters:
    ///   - persistenceService: The persistence service
    ///   - notificationService: The notification service
    func configure(
        persistenceService: PersistenceService,
        notificationService: NotificationService
    ) {
        self.persistenceService = persistenceService
        self.notificationService = notificationService
    }
    
    // MARK: - Data Loading
    
    /// Loads all habits from persistence
    func loadHabits() {
        guard let persistenceService = persistenceService else { return }
        
        isLoading = true
        
        do {
            habits = try persistenceService.fetchHabits()
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - CRUD Operations
    
    /// Creates a new habit
    /// - Parameters:
    ///   - name: The habit name
    ///   - description: Optional description
    ///   - iconName: SF Symbol icon name
    ///   - colorHex: Hex color string
    ///   - reminderTime: Optional reminder time
    ///   - notificationsEnabled: Whether to enable notifications
    ///   - targetFrequency: Daily target count
    func createHabit(
        name: String,
        description: String?,
        iconName: String,
        colorHex: String,
        reminderTime: Date?,
        notificationsEnabled: Bool,
        targetFrequency: Int
    ) async {
        guard let persistenceService = persistenceService else { return }
        
        let habit = Habit(
            name: name,
            description: description,
            iconName: iconName,
            colorHex: colorHex,
            reminderTime: reminderTime,
            notificationsEnabled: notificationsEnabled,
            targetFrequency: targetFrequency
        )
        
        do {
            try persistenceService.createHabit(habit)
            habits.insert(habit, at: 0)
            
            // Schedule notification if enabled
            if notificationsEnabled, let notificationService = notificationService {
                try? await notificationService.scheduleHabitReminder(for: habit)
            }
        } catch {
            handleError(error)
        }
    }
    
    /// Updates an existing habit
    /// - Parameter habit: The habit to update
    func updateHabit(_ habit: Habit) async {
        guard let persistenceService = persistenceService else { return }
        
        do {
            try persistenceService.updateHabit(habit)
            
            // Update notification
            if let notificationService = notificationService {
                try? await notificationService.updateHabitReminder(for: habit)
            }
        } catch {
            handleError(error)
        }
    }
    
    /// Deletes a habit
    /// - Parameter habit: The habit to delete
    func deleteHabit(_ habit: Habit) {
        guard let persistenceService = persistenceService else { return }
        
        do {
            // Cancel notifications
            notificationService?.cancelHabitReminder(for: habit)
            
            try persistenceService.deleteHabit(habit)
            habits.removeAll { $0.id == habit.id }
        } catch {
            handleError(error)
        }
    }
    
    /// Deletes habits at specified indices
    /// - Parameter offsets: Index set of habits to delete
    func deleteHabits(at offsets: IndexSet) {
        for index in offsets {
            let habit = filteredHabits[index]
            deleteHabit(habit)
        }
    }
    
    // MARK: - Completion Operations
    
    /// Toggles completion status for a habit
    /// - Parameter habit: The habit to toggle
    func toggleCompletion(for habit: Habit) {
        guard let persistenceService = persistenceService else { return }
        
        do {
            if habit.isCompletedToday && habit.todayCompletionCount >= habit.targetFrequency {
                // Uncomplete
                try persistenceService.uncompleteHabitForToday(habit)
            } else {
                // Complete
                try persistenceService.completeHabit(habit)
            }
        } catch {
            handleError(error)
        }
    }
    
    /// Marks a habit as complete
    /// - Parameters:
    ///   - habit: The habit to complete
    ///   - note: Optional note about the completion
    func completeHabit(_ habit: Habit, note: String? = nil) {
        guard let persistenceService = persistenceService else { return }
        
        do {
            try persistenceService.completeHabit(habit, note: note)
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Form Management
    
    /// Opens the form to add a new habit
    func addNewHabit() {
        editingHabit = nil
        showHabitForm = true
    }
    
    /// Opens the form to edit an existing habit
    /// - Parameter habit: The habit to edit
    func editHabit(_ habit: Habit) {
        editingHabit = habit
        showHabitForm = true
    }
    
    /// Closes the habit form
    func closeForm() {
        showHabitForm = false
        editingHabit = nil
    }
    
    // MARK: - Error Handling
    
    /// Handles errors from operations
    /// - Parameter error: The error that occurred
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
    
    /// Dismisses the error message
    func dismissError() {
        showError = false
        errorMessage = nil
    }
}

// MARK: - Statistics

extension HabitViewModel {
    /// Statistics for the habits overview
    struct HabitStatistics {
        let totalHabits: Int
        let completedToday: Int
        let bestStreak: Int
        let totalCompletions: Int
        let completionRate: Double
    }
    
    /// Gets current statistics
    var statistics: HabitStatistics {
        HabitStatistics(
            totalHabits: totalHabitsCount,
            completedToday: completedTodayCount,
            bestStreak: bestStreak,
            totalCompletions: totalCompletions,
            completionRate: todayCompletionPercentage
        )
    }
    
    /// Gets completion data for the past week
    /// - Returns: Array of (date, completion count) tuples
    func weeklyCompletionData() -> [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<7).reversed().map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            
            let count = habits.reduce(0) { total, habit in
                let completions = habit.completions?.filter {
                    calendar.startOfDay(for: $0.completedAt) == date
                }.count ?? 0
                return total + completions
            }
            
            return (date, count)
        }
    }
}
