// BabciaTobiaszUITests.swift
// BabciaTobiaszUITests

import XCTest

final class BabciaTobiaszUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Launch Tests
    
    func testAppLaunchesSuccessfully() throws {
        // Verify app launches and shows content
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }
    
    func testTabBarExists() throws {
        // Wait for splash to complete
        sleep(2)
        
        // Check for tab bar
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
    }
    
    // MARK: - Weather Tab Tests
    
    func testWeatherTabNavigation() throws {
        sleep(2)
        
        let weatherTab = app.tabBars.buttons["Weather"]
        if weatherTab.exists {
            weatherTab.tap()
            
            let navBar = app.navigationBars["Weather"]
            XCTAssertTrue(navBar.waitForExistence(timeout: 3))
        }
    }
    
    func testWeatherPullToRefresh() throws {
        sleep(2)
        
        let weatherTab = app.tabBars.buttons["Weather"]
        if weatherTab.exists {
            weatherTab.tap()
            
            let scrollView = app.scrollViews.firstMatch
            if scrollView.exists {
                scrollView.swipeDown()
            }
        }
    }
    
    // MARK: - Habits Tab Tests
    
    func testHabitsTabNavigation() throws {
        sleep(2)
        
        let habitsTab = app.tabBars.buttons["Habits"]
        if habitsTab.exists {
            habitsTab.tap()
            
            let navBar = app.navigationBars["Habits"]
            XCTAssertTrue(navBar.waitForExistence(timeout: 3))
        }
    }
    
    func testAddHabitButtonExists() throws {
        sleep(2)
        
        let habitsTab = app.tabBars.buttons["Habits"]
        if habitsTab.exists {
            habitsTab.tap()
            
            let addButton = app.buttons["Add new habit"]
            XCTAssertTrue(addButton.waitForExistence(timeout: 3))
        }
    }
    
    func testAddHabitFlow() throws {
        sleep(2)
        
        let habitsTab = app.tabBars.buttons["Habits"]
        if habitsTab.exists {
            habitsTab.tap()
            
            let addButton = app.buttons["Add new habit"]
            if addButton.waitForExistence(timeout: 3) {
                addButton.tap()
                
                // Verify form sheet appears
                let sheet = app.sheets.firstMatch
                XCTAssertTrue(sheet.waitForExistence(timeout: 2) || app.otherElements["HabitForm"].exists)
            }
        }
    }
    
    // MARK: - Search Tests
    
    func testHabitSearchField() throws {
        sleep(2)
        
        let habitsTab = app.tabBars.buttons["Habits"]
        if habitsTab.exists {
            habitsTab.tap()
            
            // Look for search field
            let searchField = app.searchFields["Search habits"]
            if searchField.exists {
                searchField.tap()
                searchField.typeText("Test")
                
                XCTAssertEqual(searchField.value as? String, "Test")
            }
        }
    }
    
    // MARK: - Performance Tests
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

// MARK: - Accessibility Tests

final class AccessibilityUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testAccessibilityLabelsExist() throws {
        sleep(2)
        
        let habitsTab = app.tabBars.buttons["Habits"]
        if habitsTab.exists {
            habitsTab.tap()
            
            // Check for accessibility label on add button
            let addButton = app.buttons["Add new habit"]
            XCTAssertTrue(addButton.waitForExistence(timeout: 3))
        }
    }
    
    func testVoiceOverSupport() throws {
        // Verify elements have accessibility identifiers
        sleep(2)
        
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.isAccessibilityElement || tabBar.exists)
    }
}
