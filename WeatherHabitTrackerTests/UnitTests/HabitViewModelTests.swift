//
//  HabitViewModelTests.swift
//  WeatherHabitTrackerTests
//
//  Unit tests for HabitViewModel, testing habit CRUD operations and state management.
//

import XCTest
import SwiftData
@testable import WeatherHabitTracker

/// Unit tests for HabitViewModel functionality
@MainActor
final class HabitViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    var viewModel: HabitViewModel!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create in-memory model container for testing
        let schema = Schema([Habit.self, HabitCompletion.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: config)
        modelContext = modelContainer.mainContext
        
        // Create view model with persistence service
        viewModel = HabitViewModel()
        let persistenceService = PersistenceService(modelContext: modelContext)
        viewModel.configure(persistenceService: persistenceService, notificationService: NotificationService())
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        modelContext = nil
        modelContainer = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Habit Model Tests
    
    /// Tests habit initialization with default values
    func testHabitInitialization() {
        // When
        let habit = Habit(name: "Test Habit")
        
        // Then
        XCTAssertEqual(habit.name, "Test Habit")
        XCTAssertEqual(habit.iconName, "star.fill")
        XCTAssertEqual(habit.targetFrequency, 1)
        XCTAssertFalse(habit.notificationsEnabled)
        XCTAssertNotNil(habit.id)
        XCTAssertNotNil(habit.createdAt)
    }
    
    /// Tests habit initialization with custom values
    func testHabitInitializationWithCustomValues() {
        // When
        let habit = Habit(
            name: "Morning Run",
            description: "30 minute jog",
            iconName: "figure.run",
            colorHex: "#FF6B6B",
            notificationsEnabled: true,
            targetFrequency: 1
        )
        
        // Then
        XCTAssertEqual(habit.name, "Morning Run")
        XCTAssertEqual(habit.habitDescription, "30 minute jog")
        XCTAssertEqual(habit.iconName, "figure.run")
        XCTAssertEqual(habit.colorHex, "#FF6B6B")
        XCTAssertTrue(habit.notificationsEnabled)
    }
    
    /// Tests habit color conversion from hex
    func testHabitColorConversion() {
        // Given
        let habit = Habit(name: "Test", colorHex: "#007AFF")
        
        // When
        let color = habit.color
        
        // Then
        XCTAssertNotNil(color)
    }
    
    // MARK: - Streak Calculation Tests
    
    /// Tests streak calculation with no completions
    func testStreakWithNoCompletions() {
        // Given
        let habit = Habit(name: "Test")
        habit.completions = []
        
        // Then
        XCTAssertEqual(habit.currentStreak, 0)
    }
    
    /// Tests streak calculation with one completion today
    func testStreakWithTodayCompletion() {
        // Given
        let habit = Habit(name: "Test")
        let completion = HabitCompletion(completedAt: Date())
        habit.completions = [completion]
        
        // Then
        XCTAssertEqual(habit.currentStreak, 1)
    }
    
    /// Tests total completions count
    func testTotalCompletions() {
        // Given
        let habit = Habit(name: "Test")
        let completions = [
            HabitCompletion(completedAt: Date()),
            HabitCompletion(completedAt: Date().addingTimeInterval(-86400)),
            HabitCompletion(completedAt: Date().addingTimeInterval(-172800))
        ]
        habit.completions = completions
        
        // Then
        XCTAssertEqual(habit.totalCompletions, 3)
    }
    
    /// Tests isCompletedToday property
    func testIsCompletedToday() {
        // Given
        let habit = Habit(name: "Test")
        
        // Initially not completed
        XCTAssertFalse(habit.isCompletedToday)
        
        // After adding today's completion
        let completion = HabitCompletion(completedAt: Date())
        habit.completions = [completion]
        
        XCTAssertTrue(habit.isCompletedToday)
    }
    
    /// Tests todayCompletionCount for multi-target habits
    func testTodayCompletionCount() {
        // Given
        let habit = Habit(name: "Drink Water", targetFrequency: 8)
        habit.completions = [
            HabitCompletion(completedAt: Date()),
            HabitCompletion(completedAt: Date()),
            HabitCompletion(completedAt: Date())
        ]
        
        // Then
        XCTAssertEqual(habit.todayCompletionCount, 3)
    }
    
    // MARK: - ViewModel State Tests
    
    /// Tests initial view model state
    func testInitialViewModelState() {
        // Then
        XCTAssertTrue(viewModel.habits.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.showHabitForm)
        XCTAssertEqual(viewModel.filterOption, .all)
    }
    
    /// Tests computed statistics with no habits
    func testStatisticsWithNoHabits() {
        // Then
        XCTAssertEqual(viewModel.totalHabitsCount, 0)
        XCTAssertEqual(viewModel.completedTodayCount, 0)
        XCTAssertEqual(viewModel.todayCompletionPercentage, 0)
        XCTAssertEqual(viewModel.bestStreak, 0)
    }
    
    /// Tests form management
    func testAddNewHabitOpensForm() {
        // When
        viewModel.addNewHabit()
        
        // Then
        XCTAssertTrue(viewModel.showHabitForm)
        XCTAssertNil(viewModel.editingHabit)
    }
    
    /// Tests edit habit opens form with habit
    func testEditHabitOpensFormWithHabit() {
        // Given
        let habit = Habit(name: "Test Habit")
        
        // When
        viewModel.editHabit(habit)
        
        // Then
        XCTAssertTrue(viewModel.showHabitForm)
        XCTAssertNotNil(viewModel.editingHabit)
        XCTAssertEqual(viewModel.editingHabit?.name, "Test Habit")
    }
    
    /// Tests close form
    func testCloseForm() {
        // Given
        viewModel.showHabitForm = true
        viewModel.editingHabit = Habit(name: "Test")
        
        // When
        viewModel.closeForm()
        
        // Then
        XCTAssertFalse(viewModel.showHabitForm)
        XCTAssertNil(viewModel.editingHabit)
    }
    
    // MARK: - Filter Tests
    
    /// Tests filter all option
    func testFilterAllOption() {
        // Given
        let completed = Habit(name: "Completed")
        let completionToday = HabitCompletion(completedAt: Date())
        completed.completions = [completionToday]
        
        let incomplete = Habit(name: "Incomplete")
        incomplete.completions = []
        
        viewModel.habits = [completed, incomplete]
        viewModel.filterOption = .all
        
        // Then
        XCTAssertEqual(viewModel.filteredHabits.count, 2)
    }
    
    /// Tests filter completed option
    func testFilterCompletedOption() {
        // Given
        let completed = Habit(name: "Completed")
        let completionToday = HabitCompletion(completedAt: Date())
        completed.completions = [completionToday]
        
        let incomplete = Habit(name: "Incomplete")
        incomplete.completions = []
        
        viewModel.habits = [completed, incomplete]
        viewModel.filterOption = .completed
        
        // Then
        XCTAssertEqual(viewModel.filteredHabits.count, 1)
        XCTAssertEqual(viewModel.filteredHabits.first?.name, "Completed")
    }
    
    /// Tests filter incomplete option
    func testFilterIncompleteOption() {
        // Given
        let completed = Habit(name: "Completed")
        let completionToday = HabitCompletion(completedAt: Date())
        completed.completions = [completionToday]
        
        let incomplete = Habit(name: "Incomplete")
        incomplete.completions = []
        
        viewModel.habits = [completed, incomplete]
        viewModel.filterOption = .incomplete
        
        // Then
        XCTAssertEqual(viewModel.filteredHabits.count, 1)
        XCTAssertEqual(viewModel.filteredHabits.first?.name, "Incomplete")
    }
    
    /// Tests search filtering
    func testSearchFiltering() {
        // Given
        viewModel.habits = [
            Habit(name: "Morning Run"),
            Habit(name: "Evening Meditation"),
            Habit(name: "Read Books")
        ]
        
        // When
        viewModel.searchText = "run"
        
        // Then
        XCTAssertEqual(viewModel.filteredHabits.count, 1)
        XCTAssertEqual(viewModel.filteredHabits.first?.name, "Morning Run")
    }
    
    // MARK: - Error Handling Tests
    
    /// Tests dismiss error
    func testDismissError() {
        // Given
        viewModel.showError = true
        viewModel.errorMessage = "Test error"
        
        // When
        viewModel.dismissError()
        
        // Then
        XCTAssertFalse(viewModel.showError)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Sample Data Tests
    
    /// Tests sample habits generation
    func testSampleHabitsGeneration() {
        // When
        let samples = Habit.sampleHabits
        
        // Then
        XCTAssertEqual(samples.count, 4)
        XCTAssertTrue(samples.allSatisfy { !$0.name.isEmpty })
        XCTAssertTrue(samples.allSatisfy { !$0.iconName.isEmpty })
    }
}
