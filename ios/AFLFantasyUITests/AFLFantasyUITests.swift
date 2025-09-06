//
//  AFLFantasyUITests.swift
//  AFL Fantasy Intelligence Platform UI Tests
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import XCTest

final class AFLFantasyUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Teardown code here
    }

    func testAppLaunchAndTabNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // Test that the app launches with dashboard tab selected
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        XCTAssertTrue(dashboardTab.exists)
        XCTAssertTrue(dashboardTab.isSelected)

        // Test navigation to Captain tab
        let captainTab = app.tabBars.buttons["Captain"]
        XCTAssertTrue(captainTab.exists)
        captainTab.tap()
        XCTAssertTrue(captainTab.isSelected)

        // Test navigation to Trades tab
        let tradesTab = app.tabBars.buttons["Trades"]
        XCTAssertTrue(tradesTab.exists)
        tradesTab.tap()
        XCTAssertTrue(tradesTab.isSelected)

        // Test navigation to Cash Cow tab
        let cashCowTab = app.tabBars.buttons["Cash Cow"]
        XCTAssertTrue(cashCowTab.exists)
        cashCowTab.tap()
        XCTAssertTrue(cashCowTab.isSelected)

        // Test navigation to Settings tab
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.exists)
        settingsTab.tap()
        XCTAssertTrue(settingsTab.isSelected)
    }

    func testDashboardElements() throws {
        let app = XCUIApplication()
        app.launch()

        // Ensure we're on the dashboard
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        dashboardTab.tap()

        // Check for dashboard title
        let dashboardTitle = app.navigationBars["🏆 Dashboard"]
        XCTAssertTrue(dashboardTitle.exists)

        // Check for team score elements (they might be dynamic)
        let teamScoreText = app.staticTexts["TEAM SCORE"]
        XCTAssertTrue(teamScoreText.exists)

        let rankText = app.staticTexts["RANK"]
        XCTAssertTrue(rankText.exists)

        // Check for salary cap information
        let salaryCapText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Salary Cap'"))
        XCTAssertTrue(salaryCapText.element.exists)
    }

    func testCaptainAdvisorElements() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to Captain tab
        let captainTab = app.tabBars.buttons["Captain"]
        captainTab.tap()

        // Check for captain advisor title
        let captainTitle = app.navigationBars["⭐ Captain AI"]
        XCTAssertTrue(captainTitle.exists)

        // Check for AI advisor header text
        let aiAdvisorText = app.staticTexts["AI Captain Advisor"]
        XCTAssertTrue(aiAdvisorText.exists)

        // Check for venue analysis description
        let venueText = app.staticTexts["Based on venue, form, and opponent analysis"]
        XCTAssertTrue(venueText.exists)
    }

    func testSettingsToggle() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to Settings tab
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()

        // Check for settings title
        let settingsTitle = app.navigationBars["⚙️ Settings"]
        XCTAssertTrue(settingsTitle.exists)

        // Test notification toggles
        let breakevenToggle = app.switches["Breakeven Alerts"]
        XCTAssertTrue(breakevenToggle.exists)

        let injuryToggle = app.switches["Injury Alerts"]
        XCTAssertTrue(injuryToggle.exists)

        let lateOutToggle = app.switches["Late Out Alerts"]
        XCTAssertTrue(lateOutToggle.exists)

        // Test toggling breakeven alerts
        let initialState = breakevenToggle.value as? String
        breakevenToggle.tap()
        let newState = breakevenToggle.value as? String
        XCTAssertNotEqual(initialState, newState)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
