//
//  CoreTests.swift
//  AFL Fantasy Intelligence Platform Tests
//
//  Comprehensive unit tests for Core modules
//  Created by AI Assistant on 6/9/2025.
//

import XCTest
import Combine
@testable import AFLFantasy

// MARK: - Network Client Tests

final class NetworkClientTests: XCTestCase {
    
    var mockClient: MockNetworkClient!
    
    override func setUp() {
        super.setUp()
        mockClient = MockNetworkClient()
    }
    
    override func tearDown() {
        mockClient = nil
        super.tearDown()
    }
    
    func testSuccessfulFetch() async throws {
        // Given
        let expectedData = TestData.samplePlayerStats
        mockClient.mockData = try JSONEncoder().encode(expectedData)
        mockClient.shouldFail = false
        
        let request = try APIRequestBuilder().buildRequest(endpoint: "/test")
        
        // When
        let result = try await mockClient.fetch([PlayerStats].self, from: request)
        
        // Then
        XCTAssertEqual(result.count, expectedData.count)
        XCTAssertEqual(result.first?.name, expectedData.first?.name)
    }
    
    func testNetworkError() async {
        // Given
        mockClient.shouldFail = true
        mockClient.mockError = NetworkError.noData
        
        let request = try! APIRequestBuilder().buildRequest(endpoint: "/test")
        
        // When/Then
        do {
            _ = try await mockClient.fetch([PlayerStats].self, from: request)
            XCTFail("Should have thrown error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.noData)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testRequestBuilderValidURL() throws {
        // Given
        let builder = APIRequestBuilder(baseURL: "https://fantasy.afl.com.au")
        
        // When
        let request = try builder.buildRequest(
            endpoint: "/api/teams/123456",
            method: .GET,
            headers: ["Authorization": "Bearer token123"]
        )
        
        // Then
        XCTAssertEqual(request.url?.absoluteString, "https://fantasy.afl.com.au/api/teams/123456")
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token123")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
    }
}

// MARK: - Keychain Service Tests

final class KeychainServiceTests: XCTestCase {
    
    var keychainService: KeychainService!
    private let testTeamId = "123456"
    private let testSessionCookie = "session_id=abc123def456"
    
    override func setUp() {
        super.setUp()
        keychainService = KeychainService.shared
    }
    
    override func tearDown() {
        // Clean up test data
        Task {
            try? await keychainService.clearAllCredentials()
        }
        super.tearDown()
    }
    
    func testStoreAndRetrieveTeamId() async throws {
        // Given/When
        try await keychainService.storeTeamId(testTeamId)
        let retrievedTeamId = try await keychainService.retrieveTeamId()
        
        // Then
        XCTAssertEqual(retrievedTeamId, testTeamId)
    }
    
    func testStoreAndRetrieveSessionCookie() async throws {
        // Given/When
        try await keychainService.storeSessionCookie(testSessionCookie)
        let retrievedCookie = try await keychainService.retrieveSessionCookie()
        
        // Then
        XCTAssertEqual(retrievedCookie, testSessionCookie)
    }
    
    func testRetrieveNonExistentKey() async {
        // When/Then
        do {
            _ = try await keychainService.retrieveTeamId()
            XCTFail("Should have thrown itemNotFound error")
        } catch KeychainError.itemNotFound {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testClearAllCredentials() async throws {
        // Given
        try await keychainService.storeTeamId(testTeamId)
        try await keychainService.storeSessionCookie(testSessionCookie)
        
        // When
        try await keychainService.clearAllCredentials()
        
        // Then
        do {
            _ = try await keychainService.retrieveTeamId()
            XCTFail("Team ID should have been cleared")
        } catch KeychainError.itemNotFound {
            // Expected
        }
        
        do {
            _ = try await keychainService.retrieveSessionCookie()
            XCTFail("Session cookie should have been cleared")
        } catch KeychainError.itemNotFound {
            // Expected
        }
    }
    
    func testValidateStoredCredentials() async throws {
        // Given
        try await keychainService.storeTeamId(testTeamId)
        
        // When
        let isValid = await keychainService.validateStoredCredentials()
        
        // Then
        XCTAssertTrue(isValid)
    }
}

// MARK: - AFL Logger Tests

final class AFLLoggerTests: XCTestCase {
    
    func testTokenRedaction() {
        // Given
        let sensitiveMessage = "API key: sk_live_abc123def456, team_id: 123456, bearer token: bearer_xyz789"
        
        // When
        let redacted = AFLLogger.redactSensitiveData(sensitiveMessage)
        
        // Then
        XCTAssertFalse(redacted.contains("sk_live_abc123def456"))
        XCTAssertFalse(redacted.contains("123456"))
        XCTAssertFalse(redacted.contains("bearer_xyz789"))
        XCTAssertTrue(redacted.contains("[REDACTED]"))
    }
    
    func testEmailRedaction() {
        // Given
        let emailMessage = "User email: user@example.com contacted support"
        
        // When
        let redacted = AFLLogger.redactSensitiveData(emailMessage)
        
        // Then
        XCTAssertFalse(redacted.contains("user@"))
        XCTAssertTrue(redacted.contains("***@example.com"))
    }
    
    func testPerformanceLogging() {
        // Given
        let expectation = XCTestExpectation(description: "Performance logging")
        var loggedOperation: String?
        
        // When
        let result = AFLLogger.logPerformance(operation: "TestOperation") {
            loggedOperation = "TestOperation"
            return "Success"
        }
        
        // Then
        XCTAssertEqual(result, "Success")
        XCTAssertEqual(loggedOperation, "TestOperation")
        expectation.fulfill()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testAsyncPerformanceLogging() async {
        // Given/When
        let result = await AFLLogger.logAsyncPerformance(operation: "AsyncTestOperation") {
            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
            return "AsyncSuccess"
        }
        
        // Then
        XCTAssertEqual(result, "AsyncSuccess")
    }
}

// MARK: - Persistence Manager Tests

final class PersistenceManagerTests: XCTestCase {
    
    var persistenceManager: PersistenceManager!
    
    override func setUp() {
        super.setUp()
        persistenceManager = PersistenceManager.shared
    }
    
    override func tearDown() {
        // Clean up test data
        Task {
            try? await persistenceManager.clearExpiredCache()
        }
        super.tearDown()
    }
    
    func testCacheAndRetrieve() async throws {
        // Given
        let testData = TestData.samplePlayerStats
        let key = "test_players"
        let policy = CachePolicy.playerStats()
        
        // When
        try await persistenceManager.cache(testData, for: key, policy: policy)
        let retrieved = try await persistenceManager.retrieve([PlayerStats].self, for: key, policy: policy)
        
        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.count, testData.count)
        XCTAssertEqual(retrieved?.first?.name, testData.first?.name)
    }
    
    func testCacheExpiry() async throws {
        // Given
        let testData = TestData.sampleTeamData
        let key = "test_team"
        let shortPolicy = CachePolicy.liveData(maxAge: 0.1) // 100ms
        
        // When
        try await persistenceManager.cache(testData, for: key, policy: shortPolicy)
        
        // Wait for expiry
        try await Task.sleep(nanoseconds: 150_000_000) // 150ms
        
        let retrieved = try await persistenceManager.retrieve(TeamData.self, for: key, policy: shortPolicy)
        
        // Then - should still return data (stale-while-revalidate)
        XCTAssertNotNil(retrieved)
    }
    
    func testInvalidateCache() async throws {
        // Given
        let testData = TestData.sampleTeamData
        let key = "test_invalidate"
        let policy = CachePolicy.staticData()
        
        try await persistenceManager.cache(testData, for: key, policy: policy)
        
        // When
        try await persistenceManager.invalidateCache(for: key)
        let retrieved = try await persistenceManager.retrieve(TeamData.self, for: key, policy: policy)
        
        // Then
        XCTAssertNil(retrieved)
    }
    
    func testCacheStatistics() async throws {
        // Given
        let testData1 = TestData.samplePlayerStats
        let testData2 = TestData.sampleTeamData
        
        try await persistenceManager.cache(testData1, for: "players", policy: .playerStats())
        try await persistenceManager.cache(testData2, for: "team", policy: .liveData())
        
        // When
        let stats = try await persistenceManager.getCacheStatistics()
        
        // Then
        XCTAssertGreaterThan(stats.totalEntries, 0)
        XCTAssertGreaterThan(stats.totalSizeBytes, 0)
        XCTAssertFalse(stats.formattedSize.isEmpty)
    }
}

// MARK: - AFL Fantasy Repository Tests

final class AFLFantasyRepositoryTests: XCTestCase {
    
    var mockRepository: MockAFLFantasyRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockAFLFantasyRepository()
    }
    
    override func tearDown() {
        mockRepository = nil
        super.tearDown()
    }
    
    func testFetchTeamDataSuccess() async throws {
        // Given
        mockRepository.shouldThrowError = false
        
        // When
        let teamData = try await mockRepository.fetchTeamData()
        
        // Then
        XCTAssertGreaterThan(teamData.teamValue, 0)
        XCTAssertGreaterThan(teamData.overallRank, 0)
        XCTAssertFalse(teamData.captainName.isEmpty)
    }
    
    func testFetchPlayerStatsSuccess() async throws {
        // Given
        mockRepository.shouldThrowError = false
        
        // When
        let playerStats = try await mockRepository.fetchPlayerStats()
        
        // Then
        XCTAssertFalse(playerStats.isEmpty)
        XCTAssertTrue(playerStats.contains { $0.name == "Marcus Bontempelli" })
    }
    
    func testRepositoryError() async {
        // Given
        mockRepository.shouldThrowError = true
        
        // When/Then
        do {
            _ = try await mockRepository.fetchTeamData()
            XCTFail("Should have thrown error")
        } catch AFLRepositoryError.mockError {
            // Expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }
    
    func testRefreshAllDataSuccess() async throws {
        // Given
        mockRepository.shouldThrowError = false
        
        // When
        let result = try await mockRepository.refreshAllData()
        
        // Then
        XCTAssertTrue(result.success)
        XCTAssertNotNil(result.teamData)
        XCTAssertFalse(result.playerStats.isEmpty)
        XCTAssertNil(result.error)
    }
}

// MARK: - Test Data

enum TestData {
    static let samplePlayerStats: [PlayerStats] = [
        PlayerStats(
            id: "1",
            name: "Marcus Bontempelli",
            position: "MID",
            team: "WBD",
            price: 850000,
            currentScore: 125,
            averageScore: 118.5,
            breakeven: 85,
            last3Games: [125, 110, 135],
            projectedScore: 130.0,
            ownership: 45.2,
            priceChange: 25000,
            isInjured: false,
            isDoubtful: false
        ),
        PlayerStats(
            id: "2",
            name: "Max Gawn",
            position: "RUC",
            team: "MEL",
            price: 780000,
            currentScore: 98,
            averageScore: 105.2,
            breakeven: 90,
            last3Games: [98, 112, 95],
            projectedScore: 105.0,
            ownership: 38.7,
            priceChange: -15000,
            isInjured: false,
            isDoubtful: true
        )
    ]
    
    static let sampleTeamData = TeamData(
        teamValue: 12500000,
        remainingSalary: 500000,
        teamScore: 1987,
        overallRank: 5432,
        captainName: "Marcus Bontempelli",
        captainScore: 125,
        rankChange: -15,
        lastUpdated: Date()
    )
    
    static let sampleLiveScores = LiveScores(
        currentRound: 15,
        matchesInProgress: [
            LiveMatch(
                id: "1",
                homeTeam: "Richmond",
                awayTeam: "Melbourne",
                quarter: "Q2",
                timeRemaining: "12:34",
                homeScore: 45,
                awayScore: 38
            )
        ],
        playerScores: ["1": 125, "2": 98],
        lastUpdated: Date()
    )
}

// MARK: - Helper Extensions

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noData, .noData),
             (.unauthorized, .unauthorized),
             (.requestTimeout, .requestTimeout),
             (.noInternetConnection, .noInternetConnection):
            return true
        case (.rateLimited(let lhsTime), .rateLimited(let rhsTime)):
            return lhsTime == rhsTime
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        default:
            return false
        }
    }
}

// MARK: - Performance Tests

final class PerformanceTests: XCTestCase {
    
    func testNetworkClientPerformance() {
        let mockClient = MockNetworkClient()
        mockClient.mockData = try! JSONEncoder().encode(TestData.samplePlayerStats)
        
        measure {
            let expectation = XCTestExpectation(description: "Network performance")
            
            Task {
                do {
                    let request = try APIRequestBuilder().buildRequest(endpoint: "/test")
                    _ = try await mockClient.fetch([PlayerStats].self, from: request)
                    expectation.fulfill()
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
    }
    
    func testPersistencePerformance() {
        let persistence = PersistenceManager.shared
        let testData = TestData.samplePlayerStats
        
        measure {
            let expectation = XCTestExpectation(description: "Persistence performance")
            
            Task {
                do {
                    try await persistence.cache(testData, for: "perf_test", policy: .playerStats())
                    _ = try await persistence.retrieve([PlayerStats].self, for: "perf_test", policy: .playerStats())
                    expectation.fulfill()
                } catch {
                    XCTFail("Performance test failed: \(error)")
                }
            }
            
            wait(for: [expectation], timeout: 2.0)
        }
    }
}
