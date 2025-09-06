//
//  AFLFantasyUITestsLaunchTests.swift
//  AFL Fantasy Intelligence Platform UI Launch Tests
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import XCTest

final class AFLFantasyUITestsLaunchTests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot
        // For example, logging into a test account or navigating to a specific screen

        // Take a screenshot of the app at launch
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)

        // Verify that key UI elements are present on launch
        let tabBar = app.tabBars.element
        XCTAssertTrue(tabBar.exists, "Tab bar should be visible on launch")

        // Verify dashboard is the default selected tab
        let dashboardTab = app.tabBars.buttons["Dashboard"]
        XCTAssertTrue(dashboardTab.exists, "Dashboard tab should exist")
        XCTAssertTrue(dashboardTab.isSelected, "Dashboard should be selected on launch")

        // Verify navigation bar is present
        let navigationBar = app.navigationBars.element
        XCTAssertTrue(navigationBar.exists, "Navigation bar should be visible")
    }
}
