// AreaViewModel.swift
// BabciaTobiasz

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class AreaViewModel {
    
    // MARK: - State
    
    var areas: [Area] = []
    var selectedArea: Area?
    var isLoading: Bool = false
    var errorMessage: String?
    var showError: Bool = false
    var showAreaForm: Bool = false
    var editingArea: Area?
    var searchText: String = ""
    var filterOption: FilterOption = .all
    var dailyBowlTarget: Int = 1
    
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
    
    var filteredAreas: [Area] {
        var result = areas
        
        if !searchText.isEmpty {
            result = result.filter { area in
                area.name.localizedCaseInsensitiveContains(searchText) ||
                (area.areaDescription?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        switch filterOption {
        case .all:
            break
        case .completed:
            result = result.filter { isAreaCompletedToday($0) }
        case .incomplete:
            result = result.filter { !isAreaCompletedToday($0) }
        }
        
        return result
    }
    
    var completedTodayCount: Int { areas.filter { isAreaCompletedToday($0) }.count }
    var totalAreasCount: Int { areas.count }
    
    var todayCompletionPercentage: Double {
        guard dailyBowlTarget > 0 else { return 0 }
        return min(1, Double(completedTodayCount) / Double(dailyBowlTarget))
    }
    
    var bestStreak: Int { computeStreak() }
    var totalCompletions: Int {
        areas.reduce(0) { total, area in
            let taskCount = area.bowls?.flatMap { $0.tasks ?? [] }.filter { $0.isCompleted }.count ?? 0
            return total + taskCount
        }
    }
    
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
    
    func loadAreas() {
        guard let persistenceService = persistenceService else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            areas = try persistenceService.fetchAreas()
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - CRUD Operations
    
    func createArea(
        name: String,
        description: String?,
        iconName: String,
        colorHex: String,
        dreamImageName: String? = nil
    ) async {
        guard let persistenceService = persistenceService else { return }
        
        let area = Area(
            name: name,
            description: description,
            iconName: iconName,
            colorHex: colorHex,
            dreamImageName: dreamImageName
        )
        
        do {
            try persistenceService.createArea(area)
            areas.insert(area, at: 0)
            try createBowl(for: area)
        } catch {
            handleError(error)
        }
    }
    
    func updateArea(_ area: Area) async {
        guard let persistenceService = persistenceService else { return }
        
        do {
            try persistenceService.updateArea(area)
        } catch {
            handleError(error)
        }
    }
    
    func deleteArea(_ area: Area) {
        guard let persistenceService = persistenceService else { return }
        
        do {
            try persistenceService.deleteArea(area)
            areas.removeAll { $0.id == area.id }
        } catch {
            handleError(error)
        }
    }
    
    func deleteAreas(at offsets: IndexSet) {
        for index in offsets {
            deleteArea(filteredAreas[index])
        }
    }
    
    // MARK: - Bowl + Task Operations
    
    func createBowl(for area: Area) throws {
        guard let persistenceService = persistenceService else { return }
        let tasks = genericTaskTemplates().map { CleaningTask(title: $0) }
        try persistenceService.createBowl(for: area, tasks: tasks)
    }
    
    func toggleTaskCompletion(_ task: CleaningTask) {
        guard let persistenceService = persistenceService else { return }
        do {
            if task.isCompleted {
                try persistenceService.uncompleteTask(task)
            } else {
                try persistenceService.completeTask(task)
            }
        } catch {
            handleError(error)
        }
    }
    
    func verifyBowl(_ bowl: AreaBowl, superVerified: Bool = false) {
        guard let persistenceService = persistenceService else { return }
        do {
            try persistenceService.verifyBowl(bowl, superVerified: superVerified)
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Form Management
    
    func addNewArea() {
        editingArea = nil
        showAreaForm = true
    }
    
    func editArea(_ area: Area) {
        editingArea = area
        showAreaForm = true
    }
    
    func closeForm() {
        showAreaForm = false
        editingArea = nil
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

extension AreaViewModel {
    struct AreaStatistics {
        let totalAreas: Int
        let completedToday: Int
        let bestStreak: Int
        let totalCompletions: Int
        let completionRate: Double
    }
    
    var statistics: AreaStatistics {
        AreaStatistics(
            totalAreas: totalAreasCount,
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
            let count = areas.reduce(0) { total, area in
                let tasks = area.bowls?.flatMap { $0.tasks ?? [] } ?? []
                let completions = tasks.filter {
                    guard let completedAt = $0.completedAt else { return false }
                    return calendar.startOfDay(for: completedAt) == date
                }.count
                return total + completions
            }
            return (date, count)
        }
    }

    // MARK: - Helpers

    private func isAreaCompletedToday(_ area: Area) -> Bool {
        guard let bowl = area.latestBowl else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let bowlDay = calendar.startOfDay(for: bowl.createdAt)
        return bowlDay == today && bowl.isCompleted
    }

    private func computeStreak() -> Int {
        let calendar = Calendar.current
        let daysWithBowls = areas
            .compactMap { $0.bowls }
            .flatMap { $0 }
            .map { calendar.startOfDay(for: $0.createdAt) }

        let uniqueDays = Set(daysWithBowls)
        guard !uniqueDays.isEmpty else { return 0 }

        let sorted = uniqueDays.sorted(by: >)
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        guard let mostRecent = sorted.first, mostRecent >= yesterday else { return 0 }

        var streak = 1
        var currentDate = mostRecent

        for date in sorted.dropFirst() {
            let expected = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            if date == expected {
                streak += 1
                currentDate = date
            } else if date < expected {
                break
            }
        }

        return streak
    }

    private func genericTaskTemplates() -> [String] {
        [
            "Clear visible surfaces",
            "Put loose items away",
            "Wipe one surface",
            "Collect trash",
            "Reset the area"
        ]
    }
}
