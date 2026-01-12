// HabitViewModel.swift
// BabciaTobiasz

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class HabitViewModel {
    
    // MARK: - State
    
    var habits: [Habit] = []
    var selectedHabit: Habit?
    var isLoading: Bool = false
    var errorMessage: String?
    var showError: Bool = false
    var showHabitForm: Bool = false
    var editingHabit: Habit?
    var searchText: String = ""
    var filterOption: FilterOption = .all
    
    // MARK: - Filter Options
    
    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All"
        case completed = "Completed Today"
        case incomplete = "Not Completed"
        
        var id: String { rawValue }
    }
    
    // MARK: - Dependencies
    
    private var persistenceService: PersistenceService?
    private var notificationService: NotificationService?
    
    // MARK: - Computed Properties
    
    var filteredHabits: [Habit] {
        var result = habits
        
        if !searchText.isEmpty {
            result = result.filter { habit in
                habit.name.localizedCaseInsensitiveContains(searchText) ||
                (habit.habitDescription?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        switch filterOption {
        case .all: break
        case .completed: result = result.filter { $0.isCompletedToday }
        case .incomplete: result = result.filter { !$0.isCompletedToday }
        }
        
        return result
    }
    
    var completedTodayCount: Int { habits.filter { $0.isCompletedToday }.count }
    var totalHabitsCount: Int { habits.count }
    
    var todayCompletionPercentage: Double {
        guard !habits.isEmpty else { return 0 }
        return Double(completedTodayCount) / Double(totalHabitsCount)
    }
    
    var bestStreak: Int { habits.map { $0.currentStreak }.max() ?? 0 }
    var totalCompletions: Int { habits.reduce(0) { $0 + $1.totalCompletions } }
    
    // MARK: - Initialization
    
    init(persistenceService: PersistenceService? = nil, notificationService: NotificationService? = nil) {
        self.persistenceService = persistenceService
        self.notificationService = notificationService
    }
    
    // MARK: - Configuration
    
    func configure(persistenceService: PersistenceService, notificationService: NotificationService) {
        self.persistenceService = persistenceService
        self.notificationService = notificationService
    }
    
    // MARK: - Data Loading
    
    func loadHabits() {
        guard let persistenceService = persistenceService else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            habits = try persistenceService.fetchHabits()
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - CRUD Operations
    
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
            
            if notificationsEnabled, let notificationService = notificationService {
                try? await notificationService.scheduleHabitReminder(for: habit)
            }
        } catch {
            handleError(error)
        }
    }
    
    func updateHabit(_ habit: Habit) async {
        guard let persistenceService = persistenceService else { return }
        
        do {
            try persistenceService.updateHabit(habit)
            
            if let notificationService = notificationService {
                try? await notificationService.updateHabitReminder(for: habit)
            }
        } catch {
            handleError(error)
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        guard let persistenceService = persistenceService else { return }
        
        do {
            notificationService?.cancelHabitReminder(for: habit)
            try persistenceService.deleteHabit(habit)
            habits.removeAll { $0.id == habit.id }
        } catch {
            handleError(error)
        }
    }
    
    func deleteHabits(at offsets: IndexSet) {
        for index in offsets {
            deleteHabit(filteredHabits[index])
        }
    }
    
    // MARK: - Completion Operations
    
    func toggleCompletion(for habit: Habit) {
        guard let persistenceService = persistenceService else { return }
        
        do {
            if habit.isCompletedToday && habit.todayCompletionCount >= habit.targetFrequency {
                try persistenceService.uncompleteHabitForToday(habit)
            } else {
                try persistenceService.completeHabit(habit)
            }
        } catch {
            handleError(error)
        }
    }
    
    func completeHabit(_ habit: Habit, note: String? = nil) {
        guard let persistenceService = persistenceService else { return }
        
        do {
            try persistenceService.completeHabit(habit, note: note)
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Form Management
    
    func addNewHabit() {
        editingHabit = nil
        showHabitForm = true
    }
    
    func editHabit(_ habit: Habit) {
        editingHabit = habit
        showHabitForm = true
    }
    
    func closeForm() {
        showHabitForm = false
        editingHabit = nil
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
    
    func dismissError() {
        showError = false
        errorMessage = nil
    }
}

// MARK: - Statistics

extension HabitViewModel {
    struct HabitStatistics {
        let totalHabits: Int
        let completedToday: Int
        let bestStreak: Int
        let totalCompletions: Int
        let completionRate: Double
    }
    
    var statistics: HabitStatistics {
        HabitStatistics(
            totalHabits: totalHabitsCount,
            completedToday: completedTodayCount,
            bestStreak: bestStreak,
            totalCompletions: totalCompletions,
            completionRate: todayCompletionPercentage
        )
    }
    
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
