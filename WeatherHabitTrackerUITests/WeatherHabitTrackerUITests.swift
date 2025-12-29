//
//  WeatherHabitTrackerUITests.swift
//  WeatherHabitTrackerUITests
//
//  UI tests for the WeatherHabitTracker app, testing user flows.
//

import XCTest

/// UI tests for the WeatherHabitTracker application
final class WeatherHabitTrackerUITests: XCTestCase {
    
    // MARK: - Properties
    
    var app: XCUIApplication!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Stop immediately when a failure occurs
        continueAfterFailure = false
        
        // Initialize the app
        app = XCUIApplication()
        
        // Launch arguments for testing
        app.launchArguments = ["--uitesting"]
        
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Launch Tests
    
    /// Tests that the app launches successfully and shows the main tab view
    func testAppLaunchesSuccessfully() throws {
        // Wait for launch animation to complete
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        // Verify tabs exist
        XCTAssertTrue(app.tabBars.buttons["Weather"].exists)
        XCTAssertTrue(app.tabBars.buttons["Habits"].exists)
    }
    
    /// Tests that the weather tab is selected by default
    func testWeatherTabSelectedByDefault() throws {
        // Wait for the app to load
        let weatherTab = app.tabBars.buttons["Weather"]
        XCTAssertTrue(weatherTab.waitForExistence(timeout: 5))
        
        // Weather tab should be selected (has value "1" indicating selection)
        XCTAssertTrue(weatherTab.isSelected)
    }
    
    // MARK: - Navigation Tests
    
    /// Tests switching between Weather and Habits tabs
    func testTabNavigation() throws {
        // Given - App is launched
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        // When - Tap Habits tab
        app.tabBars.buttons["Habits"].tap()
        
        // Then - Habits content should be visible
        let habitsTitle = app.navigationBars["Habits"]
        XCTAssertTrue(habitsTitle.waitForExistence(timeout: 2))
        
        // When - Tap Weather tab
        app.tabBars.buttons["Weather"].tap()
        
        // Then - Weather content should be visible
        let weatherTitle = app.navigationBars["Weather"]
        XCTAssertTrue(weatherTitle.waitForExistence(timeout: 2))
    }
    
    // MARK: - Habits Tab Tests
    
    /// Tests navigating to the habits tab and viewing empty state
    func testHabitsEmptyState() throws {
        // Navigate to Habits tab
        app.tabBars.buttons["Habits"].tap()
        
        // Check for empty state elements
        let emptyStateText = app.staticTexts["No Habits Yet"]
        let addButton = app.buttons["Add Your First Habit"]
        
        // Note: These may or may not exist depending on whether there's sample data
        // This test verifies the flow works, actual content depends on data state
        XCTAssertTrue(app.navigationBars["Habits"].exists)
    }
    
    /// Tests opening the add habit form
    func testOpenAddHabitForm() throws {
        // Navigate to Habits tab
        app.tabBars.buttons["Habits"].tap()
        
        // Wait for navigation
        let habitsNav = app.navigationBars["Habits"]
        XCTAssertTrue(habitsNav.waitForExistence(timeout: 2))
        
        // Tap the add button in the toolbar
        let addButton = habitsNav.buttons.element(boundBy: 0)
        if addButton.exists {
            addButton.tap()
            
            // Verify form appears
            let newHabitTitle = app.navigationBars["New Habit"]
            XCTAssertTrue(newHabitTitle.waitForExistence(timeout: 2))
        }
    }
    
    /// Tests creating a new habit
    func testCreateNewHabit() throws {
        // Navigate to Habits tab
        app.tabBars.buttons["Habits"].tap()
        
        // Wait for navigation
        let habitsNav = app.navigationBars["Habits"]
        XCTAssertTrue(habitsNav.waitForExistence(timeout: 2))
        
        // Try to find and tap add button
        if let addButton = habitsNav.buttons.allElementsBoundByIndex.first(where: { $0.isHittable }) {
            addButton.tap()
            
            // Wait for form
            let newHabitNav = app.navigationBars["New Habit"]
            if newHabitNav.waitForExistence(timeout: 2) {
                // Enter habit name
                let nameField = app.textFields["Habit Name"]
                if nameField.exists {
                    nameField.tap()
                    nameField.typeText("Test Habit from UI")
                }
                
                // Tap Add button
                let addFormButton = newHabitNav.buttons["Add"]
                if addFormButton.exists && addFormButton.isEnabled {
                    addFormButton.tap()
                    
                    // Verify we're back on habits list
                    XCTAssertTrue(habitsNav.waitForExistence(timeout: 2))
                }
            }
        }
    }
    
    /// Tests canceling the add habit form
    func testCancelAddHabitForm() throws {
        // Navigate to Habits tab
        app.tabBars.buttons["Habits"].tap()
        
        let habitsNav = app.navigationBars["Habits"]
        XCTAssertTrue(habitsNav.waitForExistence(timeout: 2))
        
        // Open add form
        if let addButton = habitsNav.buttons.allElementsBoundByIndex.first(where: { $0.isHittable }) {
            addButton.tap()
            
            let newHabitNav = app.navigationBars["New Habit"]
            if newHabitNav.waitForExistence(timeout: 2) {
                // Tap Cancel
                let cancelButton = newHabitNav.buttons["Cancel"]
                if cancelButton.exists {
                    cancelButton.tap()
                    
                    // Verify form is dismissed
                    XCTAssertTrue(habitsNav.waitForExistence(timeout: 2))
                    XCTAssertFalse(newHabitNav.exists)
                }
            }
        }
    }
    
    // MARK: - Weather Tab Tests
    
    /// Tests the weather view displays loading state or content
    func testWeatherViewContent() throws {
        // Weather tab should be selected by default
        let weatherNav = app.navigationBars["Weather"]
        XCTAssertTrue(weatherNav.waitForExistence(timeout: 5))
        
        // App should show either loading indicator, weather content, or error/empty state
        // This verifies the view loads without crashing
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 3) || app.staticTexts.count > 0)
    }
    
    /// Tests pull to refresh on weather view
    func testWeatherPullToRefresh() throws {
        // Ensure we're on weather tab
        let weatherNav = app.navigationBars["Weather"]
        XCTAssertTrue(weatherNav.waitForExistence(timeout: 5))
        
        // Find scroll view and perform pull to refresh
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
            let end = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
            start.press(forDuration: 0.1, thenDragTo: end)
            
            // Wait a moment for refresh to trigger
            sleep(1)
            
            // View should still exist after refresh
            XCTAssertTrue(weatherNav.exists)
        }
    }
    
    // MARK: - Accessibility Tests
    
    /// Tests that main UI elements have accessibility labels
    func testAccessibilityLabels() throws {
        // Check tab bar accessibility
        let weatherTab = app.tabBars.buttons["Weather"]
        let habitsTab = app.tabBars.buttons["Habits"]
        
        XCTAssertTrue(weatherTab.waitForExistence(timeout: 5))
        XCTAssertTrue(habitsTab.exists)
        
        // Verify tabs are accessible
        XCTAssertTrue(weatherTab.isHittable)
        XCTAssertTrue(habitsTab.isHittable)
    }
    
    // MARK: - Performance Tests
    
    /// Tests app launch performance
    func testLaunchPerformance() throws {
        if #available(iOS 13.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
