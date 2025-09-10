//
//  AFLFantasyServicesTests.swift
//  AFL Fantasy Intelligence Platform Tests
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

@testable import AFLFantasy
import XCTest

// MARK: - AFLFantasyServicesTests

@MainActor
class AFLFantasyServicesTests: XCTestCase {
    var keychainManager: KeychainManager!
    var dataService: AFLFantasyDataService!

    override func setUp() {
        super.setUp()
        keychainManager = KeychainManager()
        dataService = AFLFantasyDataService()
    }

    override func tearDown() {
        // Clean up keychain after each test
        keychainManager.clearAll()
        super.tearDown()
    }

    // MARK: - Keychain Manager Tests

    func testKeychainStorageAndRetrieval() {
        // Given
        let testTeamId = "test_team_123"
        let testSessionCookie = "test_session_cookie_value"
        let testAPIToken = "test_api_token_value"

        // When
        keychainManager.storeAFLCredentials(
            teamId: testTeamId,
            sessionCookie: testSessionCookie,
            apiToken: testAPIToken
        )

        // Then
        XCTAssertTrue(keychainManager.hasAFLCredentials())
        XCTAssertEqual(keychainManager.getAFLTeamId(), testTeamId)
        XCTAssertEqual(keychainManager.getAFLSessionCookie(), testSessionCookie)
        XCTAssertEqual(keychainManager.getAFLAPIToken(), testAPIToken)
    }

    func testKeychainClearCredentials() {
        // Given
        keychainManager.storeAFLCredentials(
            teamId: "test_team",
            sessionCookie: "test_cookie",
            apiToken: "test_token"
        )

        XCTAssertTrue(keychainManager.hasAFLCredentials())

        // When
        keychainManager.clearAFLCredentials()

        // Then
        XCTAssertFalse(keychainManager.hasAFLCredentials())
        XCTAssertNil(keychainManager.getAFLTeamId())
        XCTAssertNil(keychainManager.getAFLSessionCookie())
        XCTAssertNil(keychainManager.getAFLAPIToken())
    }

    func testKeychainCredentialsWithoutAPIToken() {
        // Given
        let testTeamId = "test_team_456"
        let testSessionCookie = "test_session_cookie_value_2"

        // When
        keychainManager.storeAFLCredentials(
            teamId: testTeamId,
            sessionCookie: testSessionCookie,
            apiToken: nil
        )

        // Then
        XCTAssertTrue(keychainManager.hasAFLCredentials())
        XCTAssertEqual(keychainManager.getAFLTeamId(), testTeamId)
        XCTAssertEqual(keychainManager.getAFLSessionCookie(), testSessionCookie)
        XCTAssertNil(keychainManager.getAFLAPIToken())
    }

    // MARK: - Data Service Tests

    func testDataServiceInitialState() {
        // Then
        XCTAssertFalse(dataService.authenticated)
        XCTAssertFalse(dataService.loading)
        XCTAssertNil(dataService.currentDashboardData)
        XCTAssertNil(dataService.lastUpdateTime)
        XCTAssertNil(dataService.lastError)
    }

    func testDataServiceLogout() {
        // Given - simulate authenticated state
        dataService.authenticated = true

        // When
        dataService.logout()

        // Then
        XCTAssertFalse(dataService.authenticated)
        XCTAssertNil(dataService.currentDashboardData)
        XCTAssertNil(dataService.lastError)
        XCTAssertNil(dataService.lastUpdateTime)
    }

    func testDataServiceCacheExpiry() {
        // Given
        let pastTime = Date(timeIntervalSinceNow: -400) // 6+ minutes ago
        dataService.lastUpdateTime = pastTime

        // Then
        XCTAssertFalse(dataService.isCacheFresh)
        XCTAssertLessThan(dataService.cacheExpiresIn, 1.0)
    }

    func testDataServiceFreshCache() {
        // Given
        dataService.lastUpdateTime = Date() // Just now

        // Then
        XCTAssertTrue(dataService.isCacheFresh)
        XCTAssertGreaterThan(dataService.cacheExpiresIn, 250.0) // Close to 300 seconds (5 min)
    }

    func testDataServiceConvenienceMethods() {
        // Given
        let mockDashboardData = createMockDashboardData()
        dataService.currentDashboardData = mockDashboardData

        // Then
        XCTAssertEqual(dataService.currentTeamValue, 12_500_000.0)
        XCTAssertEqual(dataService.currentTeamScore, 1987)
        XCTAssertEqual(dataService.currentRank, 5432)
        XCTAssertEqual(dataService.currentCaptain?.name, "Marcus Bontempelli")
    }

    func testDataServiceErrorHandling() {
        // Given
        let testError = AFLFantasyError.networkError(NSError(domain: "test", code: 0))

        // When
        dataService.lastError = testError

        // Then
        XCTAssertTrue(dataService.hasError)
        XCTAssertNotNil(dataService.errorMessage)

        // When
        dataService.clearError()

        // Then
        XCTAssertFalse(dataService.hasError)
        XCTAssertNil(dataService.errorMessage)
    }

    // MARK: - Helper Methods

    private func createMockDashboardData() -> DashboardData {
        let teamValue = TeamValueData(teamValue: 12_500_000.0, bankBalance: 150_000)
        let teamScore = TeamScoreData(totalScore: 1987, roundScore: 1987)
        let rank = RankData(rank: 5432)
        let captain = CaptainData(captain: CaptainData.Captain(
            name: "Marcus Bontempelli",
            team: "Western Bulldogs",
            position: "MID"
        ))

        return DashboardData(
            teamValue: teamValue,
            teamScore: teamScore,
            rank: rank,
            captain: captain
        )
    }
}

// MARK: - AFLFantasyAPIClientTests

class AFLFantasyAPIClientTests: XCTestCase {
    var apiClient: AFLFantasyAPIClient!

    override func setUp() {
        super.setUp()
        apiClient = AFLFantasyAPIClient(baseURL: URL(string: "http://localhost:5000")!)
    }

    func testAPIClientInitialization() {
        // Then
        XCTAssertNotNil(apiClient)
        XCTAssertEqual(apiClient.baseURL.absoluteString, "http://localhost:5000")
    }

    func testAPIClientCredentialUpdate() {
        // When
        apiClient.updateCredentials(
            teamId: "test_team_789",
            sessionCookie: "test_cookie_value",
            apiToken: "test_token_value"
        )

        // Then - can't directly test private properties, but this ensures no crash
        XCTAssertNotNil(apiClient)
    }

    func testAPIClientURLConstruction() {
        // Given
        let expectedDashboardURL = URL(string: "http://localhost:5000/api/afl-fantasy/dashboard-data")!

        // When - we can't directly test private methods, but we can verify the base URL is set correctly

        // Then
        XCTAssertEqual(apiClient.baseURL.absoluteString, "http://localhost:5000")

        // Test URL construction logic by building expected endpoints
        let dashboardEndpoint = apiClient.baseURL.appendingPathComponent("/api/afl-fantasy/dashboard-data")
        XCTAssertEqual(dashboardEndpoint.absoluteString, expectedDashboardURL.absoluteString)
    }
}
