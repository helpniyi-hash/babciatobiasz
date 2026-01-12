// HabitViewModelTests.swift
// BabciaTobiaszTests

import XCTest
@testable import BabciaTobiasz

@MainActor
final class HabitViewModelTests: XCTestCase {
    var sut: HabitViewModel!
    
    override func setUp() async throws {
        sut = HabitViewModel()
    }
    
    override func tearDown() async throws {
        sut = nil
    }
    
    // MARK: - Filter Tests
    
    func testFilterBySearchEmptyHabits() {
        sut.searchText = "Exercise"
        XCTAssertTrue(sut.filteredHabits.isEmpty)
    }
    
    func testFilterCompletedEmptyHabits() {
        sut.filterOption = .completed
        XCTAssertTrue(sut.filteredHabits.isEmpty)
    }
    
    func testFilterIncompleteEmptyHabits() {
        sut.filterOption = .incomplete
        XCTAssertTrue(sut.filteredHabits.isEmpty)
    }
    
    // MARK: - Statistics Tests
    
    func testCompletedTodayCountEmpty() {
        XCTAssertEqual(sut.completedTodayCount, 0)
    }
    
    func testTotalHabitsCountEmpty() {
        XCTAssertEqual(sut.totalHabitsCount, 0)
    }
    
    func testCompletionPercentageEmpty() {
        XCTAssertEqual(sut.todayCompletionPercentage, 0)
    }
    
    func testBestStreakEmpty() {
        XCTAssertEqual(sut.bestStreak, 0)
    }
    
    func testTotalCompletionsEmpty() {
        XCTAssertEqual(sut.totalCompletions, 0)
    }
    
    // MARK: - Form Management Tests
    
    func testAddNewHabit() {
        sut.addNewHabit()
        
        XCTAssertTrue(sut.showHabitForm)
        XCTAssertNil(sut.editingHabit)
    }
    
    func testCloseForm() {
        sut.showHabitForm = true
        sut.closeForm()
        
        XCTAssertFalse(sut.showHabitForm)
        XCTAssertNil(sut.editingHabit)
    }
    
    // MARK: - Error Handling Tests
    
    func testDismissError() {
        sut.showError = true
        sut.errorMessage = "Test Error"
        
        sut.dismissError()
        
        XCTAssertFalse(sut.showError)
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Statistics Struct Tests
    
    func testStatisticsStructure() {
        let stats = sut.statistics
        
        XCTAssertEqual(stats.totalHabits, 0)
        XCTAssertEqual(stats.completedToday, 0)
        XCTAssertEqual(stats.bestStreak, 0)
        XCTAssertEqual(stats.totalCompletions, 0)
        XCTAssertEqual(stats.completionRate, 0)
    }
    
    func testWeeklyCompletionDataEmpty() {
        let data = sut.weeklyCompletionData()
        XCTAssertEqual(data.count, 7)
        XCTAssertTrue(data.allSatisfy { $0.count == 0 })
    }
    
    // MARK: - Filter Option Tests
    
    func testFilterOptionCases() {
        XCTAssertEqual(HabitViewModel.FilterOption.allCases.count, 3)
        XCTAssertEqual(HabitViewModel.FilterOption.all.rawValue, "All")
        XCTAssertEqual(HabitViewModel.FilterOption.completed.rawValue, "Completed Today")
        XCTAssertEqual(HabitViewModel.FilterOption.incomplete.rawValue, "Not Completed")
    }
    
    func testFilterOptionIdentifiable() {
        let option = HabitViewModel.FilterOption.all
        XCTAssertEqual(option.id, option.rawValue)
    }
}
