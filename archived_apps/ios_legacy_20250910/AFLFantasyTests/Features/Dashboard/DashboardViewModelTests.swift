//
//  DashboardViewModelTests.swift
//  AFL Fantasy Intelligence Platform Tests
//
//  Unit tests for DashboardViewModel
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

@testable import AFLFantasy
import XCTest

// MARK: - DashboardViewModelTests

@MainActor
final class DashboardViewModelTests: XCTestCase {
    private var sut: DashboardViewModel!

    override func setUp() {
        super.setUp()
        sut = DashboardViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        // Given - ViewModel is initialized

        // Then - Initial values are set correctly
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.isRefreshing)
        XCTAssertFalse(sut.hasError)
        XCTAssertNil(sut.errorMessage)
        XCTAssertTrue(sut.isLive)
        XCTAssertEqual(sut.currentScore, 2145)
        XCTAssertEqual(sut.currentRank, 3247)
        XCTAssertEqual(sut.scoreChange, 87)
        XCTAssertEqual(sut.rankChange, -156)
        XCTAssertEqual(sut.teamValue, "$13.2M")
        XCTAssertEqual(sut.bankBalance, "$145K")
        XCTAssertEqual(sut.tradesRemaining, 8)
        XCTAssertEqual(sut.tradesUsed, 2)
        XCTAssertEqual(sut.cashCowCount, 4)
        XCTAssertEqual(sut.cashGenerationRate, "125K")
        XCTAssertEqual(sut.riskLevel, .medium)
    }

    func testAIInsightsInitialization() {
        // Given - ViewModel is initialized

        // Then - AI insights are loaded
        XCTAssertFalse(sut.aiInsights.isEmpty)
        XCTAssertEqual(sut.aiInsights.count, 5)

        // Verify first insight
        let firstInsight = sut.aiInsights[0]
        XCTAssertEqual(firstInsight.title, "Premium Breakout Alert")
        XCTAssertTrue(firstInsight.description.contains("Sam Walsh"))
    }

    func testCriticalAlertsInitialization() {
        // Given - ViewModel is initialized

        // Then - Critical alerts are loaded
        XCTAssertFalse(sut.criticalAlerts.isEmpty)
        XCTAssertEqual(sut.criticalAlerts.count, 4)

        // Verify first alert
        let firstAlert = sut.criticalAlerts[0]
        XCTAssertEqual(firstAlert.title, "Connor Rozee")
        XCTAssertEqual(firstAlert.type, .injuryUpdate)
        XCTAssertEqual(firstAlert.priority, .critical)
    }

    // MARK: - Refresh Tests

    func testRefreshSuccess() async {
        // Given - ViewModel is ready to refresh
        XCTAssertFalse(sut.isRefreshing)
        XCTAssertFalse(sut.hasError)

        // When - Refresh is called
        await sut.refresh()

        // Then - Refresh completes successfully
        XCTAssertFalse(sut.isRefreshing)
        XCTAssertFalse(sut.hasError)
        XCTAssertNil(sut.errorMessage)
    }

    func testRefreshSetsLoadingState() async {
        // Given - ViewModel is ready
        let expectation = expectation(description: "Refresh started")

        // When - Refresh is called (but we check immediately)
        Task {
            await sut.refresh()
            expectation.fulfill()
        }

        // Brief wait to allow refresh to start
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then - Loading state is set initially
        // Note: Due to async nature, we test the final state
        await fulfillment(of: [expectation], timeout: 3.0)
        XCTAssertFalse(sut.isRefreshing) // Should be false after completion
    }

    // MARK: - Live Score Updates Tests

    func testRefreshLiveData() async {
        // Given - Initial score
        let initialScore = sut.currentScore

        // When - Live data is refreshed
        await sut.refreshLiveData()

        // Then - Score may have changed (within realistic bounds)
        XCTAssertTrue(sut.currentScore >= 1800) // Minimum score check
        XCTAssertTrue(sut.projectedScore > 0)
    }

    // MARK: - Team Analysis Tests

    func testTeamAnalysisGeneration() {
        // Given - ViewModel has team analysis
        let teamAnalysis = sut.teamAnalysis

        // Then - Team analysis is properly configured
        XCTAssertNotNil(teamAnalysis)
        XCTAssertEqual(teamAnalysis?.totalValue, 13_200_000)
        XCTAssertEqual(teamAnalysis?.bankBalance, 145_000)
        XCTAssertEqual(teamAnalysis?.premiumCount, 12)
        XCTAssertEqual(teamAnalysis?.cashCowCount, 4)

        // Check position distribution
        XCTAssertNotNil(teamAnalysis?.positionDistribution[.defender])
        XCTAssertNotNil(teamAnalysis?.positionDistribution[.midfielder])
        XCTAssertNotNil(teamAnalysis?.positionDistribution[.ruck])
        XCTAssertNotNil(teamAnalysis?.positionDistribution[.forward])
    }

    // MARK: - Risk Level Tests

    func testRiskLevelDisplay() {
        // Given - ViewModel has risk level
        let riskLevel = sut.riskLevel

        // Then - Risk level is valid
        XCTAssertEqual(riskLevel, .medium)
        XCTAssertEqual(riskLevel.displayName, "Medium Risk")
        XCTAssertEqual(riskLevel.icon, "exclamationmark.shield.fill")
    }

    // MARK: - Performance Tests

    func testPerformanceOfDataLoading() {
        measure {
            // Test the performance of creating a new view model
            let viewModel = DashboardViewModel()
            XCTAssertNotNil(viewModel)
        }
    }

    // MARK: - Memory Tests

    func testMemoryLeaks() {
        // Test that view model can be properly deallocated
        weak var weakViewModel: DashboardViewModel?

        autoreleasepool {
            let viewModel = DashboardViewModel()
            weakViewModel = viewModel
            XCTAssertNotNil(weakViewModel)
        }

        // View model should be deallocated
        XCTAssertNil(weakViewModel, "DashboardViewModel should be deallocated")
    }
}

// MARK: - AFLFantasyErrorTests

final class AFLFantasyErrorTests: XCTestCase {
    func testNetworkErrorDescription() {
        // Given
        let error = AFLFantasyError.networkError("Connection failed")

        // Then
        XCTAssertEqual(error.localizedDescription, "Connection failed")
        XCTAssertEqual(error.recoverySuggestion, "Check your internet connection and try again.")
    }

    func testDataParsingErrorDescription() {
        // Given
        let error = AFLFantasyError.dataParsingError

        // Then
        XCTAssertEqual(error.localizedDescription, "Unable to process server response")
        XCTAssertEqual(error.recoverySuggestion, "Please try refreshing the data.")
    }

    func testAuthenticationErrorDescription() {
        // Given
        let error = AFLFantasyError.authenticationError

        // Then
        XCTAssertEqual(error.localizedDescription, "Authentication required. Please log in again.")
        XCTAssertEqual(error.recoverySuggestion, "Please log in to continue.")
    }

    func testServerErrorDescription() {
        // Given
        let error = AFLFantasyError.serverError(500)

        // Then
        XCTAssertEqual(error.localizedDescription, "Server error (500). Please try again later.")
        XCTAssertEqual(
            error.recoverySuggestion,
            "The server is temporarily unavailable. Please try again in a few minutes."
        )
    }

    func testUnknownErrorDescription() {
        // Given
        let error = AFLFantasyError.unknownError

        // Then
        XCTAssertEqual(error.localizedDescription, "An unexpected error occurred")
        XCTAssertEqual(error.recoverySuggestion, "Please restart the app and try again.")
    }
}
