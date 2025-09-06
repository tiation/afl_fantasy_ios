//
//  RealTimeDataServiceTests.swift
//  AFL Fantasy Pro Tests - Real-Time Data Service Tests
//
//  Unit tests for RealTimeDataService with mock API client and
//  comprehensive timing and state management scenarios.
//

import XCTest
import Combine
@testable import AFLFantasyPro

final class RealTimeDataServiceTests: XCTestCase {
    
    var realTimeService: RealTimeDataService!
    var mockAPIClient: MockAFLFantasyAPIClient!
    var mockReachabilityService: MockReachabilityService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAFLFantasyAPIClient()
        mockReachabilityService = MockReachabilityService()
        realTimeService = RealTimeDataService(
            apiClient: mockAPIClient,
            reachabilityService: mockReachabilityService
        )
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        realTimeService.stop()
        realTimeService = nil
        mockAPIClient = nil
        mockReachabilityService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertFalse(realTimeService.isPolling)
        XCTAssertEqual(realTimeService.pollingInterval, 30.0)
        XCTAssertTrue(realTimeService.liveMatches.isEmpty)
        XCTAssertTrue(realTimeService.playerUpdates.isEmpty)
    }
    
    // MARK: - Start/Stop Polling Tests
    
    func testStartPollingWhenOnline() async {
        // Given
        mockReachabilityService.setConnectionStatus(isConnected: true)
        mockAPIClient.setupMockLiveMatches([
            createMockLiveMatch(id: "1", homeTeam: "Richmond", awayTeam: "Carlton", isLive: true)
        ])
        
        // When
        await realTimeService.start()
        
        // Then
        XCTAssertTrue(realTimeService.isPolling)
        
        // Wait for initial data fetch
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        XCTAssertEqual(realTimeService.liveMatches.count, 1)
        XCTAssertEqual(mockAPIClient.fetchLiveMatchesCallCount, 1)
    }
    
    func testStartPollingWhenOffline() async {
        // Given
        mockReachabilityService.setConnectionStatus(isConnected: false)
        
        // When
        await realTimeService.start()
        
        // Then
        XCTAssertFalse(realTimeService.isPolling)
        XCTAssertEqual(mockAPIClient.fetchLiveMatchesCallCount, 0)
    }
    
    func testStopPolling() async {
        // Given
        mockReachabilityService.setConnectionStatus(isConnected: true)
        await realTimeService.start()
        XCTAssertTrue(realTimeService.isPolling)
        
        // When
        realTimeService.stop()
        
        // Then
        XCTAssertFalse(realTimeService.isPolling)
    }
    
    // MARK: - Connectivity Change Tests
    
    func testPollingStartsWhenConnectivityRestored() async {
        // Given
        mockReachabilityService.setConnectionStatus(isConnected: false)
        await realTimeService.start()
        XCTAssertFalse(realTimeService.isPolling)
        
        // When
        mockReachabilityService.setConnectionStatus(isConnected: true)
        
        // Wait for connectivity change to be processed
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Then
        XCTAssertTrue(realTimeService.isPolling)
    }
    
    func testPollingStopsWhenConnectivityLost() async {
        // Given
        mockReachabilityService.setConnectionStatus(isConnected: true)
        await realTimeService.start()
        XCTAssertTrue(realTimeService.isPolling)
        
        // When
        mockReachabilityService.setConnectionStatus(isConnected: false)
        
        // Wait for connectivity change to be processed
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Then
        XCTAssertFalse(realTimeService.isPolling)
    }
    
    // MARK: - Data Fetching Tests
    
    func testFetchLiveMatchesSuccess() async {
        // Given
        let mockMatches = [
            createMockLiveMatch(id: "1", homeTeam: "Richmond", awayTeam: "Carlton", isLive: true),
            createMockLiveMatch(id: "2", homeTeam: "Collingwood", awayTeam: "Essendon", isLive: false)
        ]
        mockAPIClient.setupMockLiveMatches(mockMatches)
        
        // When
        await realTimeService.refreshLiveMatches()
        
        // Then
        XCTAssertEqual(realTimeService.liveMatches.count, 2)
        XCTAssertEqual(realTimeService.liveMatches[0].homeTeamName, "Richmond")
        XCTAssertEqual(realTimeService.liveMatches[1].homeTeamName, "Collingwood")
        XCTAssertEqual(mockAPIClient.fetchLiveMatchesCallCount, 1)
    }
    
    func testFetchLiveMatchesError() async {
        // Given
        mockAPIClient.setupMockError(.networkError(URLError(.timedOut)))
        
        // When
        await realTimeService.refreshLiveMatches()
        
        // Then
        XCTAssertTrue(realTimeService.liveMatches.isEmpty)
        XCTAssertEqual(mockAPIClient.fetchLiveMatchesCallCount, 1)
    }
    
    func testFetchPlayerUpdatesSuccess() async {
        // Given
        let mockPlayers = [
            createMockPlayer(id: "1", name: "Marcus Bontempelli", currentScore: 85),
            createMockPlayer(id: "2", name: "Clayton Oliver", currentScore: 92)
        ]
        mockAPIClient.setupMockPlayers(mockPlayers)
        
        // When
        await realTimeService.refreshPlayerData(for: 1)
        
        // Then
        XCTAssertEqual(realTimeService.playerUpdates.count, 2)
        XCTAssertEqual(realTimeService.playerUpdates[0].displayName, "Marcus Bontempelli")
        XCTAssertEqual(realTimeService.playerUpdates[0].liveScore, 85)
        XCTAssertEqual(mockAPIClient.fetchPlayersCallCount, 1)
    }
    
    // MARK: - Adaptive Polling Tests
    
    func testAdaptivePollingWithLiveMatches() async {
        // Given
        let liveMatch = createMockLiveMatch(id: "1", homeTeam: "Richmond", awayTeam: "Carlton", isLive: true)
        mockAPIClient.setupMockLiveMatches([liveMatch])
        mockReachabilityService.setConnectionStatus(isConnected: true)
        
        // When
        await realTimeService.start()
        
        // Wait for adaptive polling to adjust
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Then
        // Polling interval should be faster for live matches (10 seconds)
        XCTAssertEqual(realTimeService.pollingInterval, 10.0)
    }
    
    func testAdaptivePollingWithoutLiveMatches() async {
        // Given
        let finishedMatch = createMockLiveMatch(id: "1", homeTeam: "Richmond", awayTeam: "Carlton", isLive: false)
        mockAPIClient.setupMockLiveMatches([finishedMatch])
        mockReachabilityService.setConnectionStatus(isConnected: true)
        
        // When
        await realTimeService.start()
        
        // Wait for adaptive polling to adjust
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Then
        // Polling interval should be slower for no live matches (60 seconds)
        XCTAssertEqual(realTimeService.pollingInterval, 60.0)
    }
    
    // MARK: - Publisher Tests
    
    func testLiveMatchesPublisher() async {
        // Given
        let expectation = XCTestExpectation(description: "Live matches updated")
        var receivedMatches: [LiveMatch] = []
        
        realTimeService.$liveMatches
            .dropFirst() // Skip initial empty array
            .sink { matches in
                receivedMatches = matches
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let mockMatches = [
            createMockLiveMatch(id: "1", homeTeam: "Richmond", awayTeam: "Carlton", isLive: true)
        ]
        mockAPIClient.setupMockLiveMatches(mockMatches)
        
        // When
        await realTimeService.refreshLiveMatches()
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedMatches.count, 1)
        XCTAssertEqual(receivedMatches[0].homeTeamName, "Richmond")
    }
    
    func testPlayerUpdatesPublisher() async {
        // Given
        let expectation = XCTestExpectation(description: "Player updates received")
        var receivedPlayers: [Player] = []
        
        realTimeService.$playerUpdates
            .dropFirst() // Skip initial empty array
            .sink { players in
                receivedPlayers = players
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let mockPlayers = [
            createMockPlayer(id: "1", name: "Marcus Bontempelli", currentScore: 85)
        ]
        mockAPIClient.setupMockPlayers(mockPlayers)
        
        // When
        await realTimeService.refreshPlayerData(for: 1)
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedPlayers.count, 1)
        XCTAssertEqual(receivedPlayers[0].displayName, "Marcus Bontempelli")
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandlingDoesNotStopPolling() async {
        // Given
        mockReachabilityService.setConnectionStatus(isConnected: true)
        mockAPIClient.setupMockError(.serverError(500))
        
        // When
        await realTimeService.start()
        
        // Wait for error to occur
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Then
        // Service should still be polling despite the error
        XCTAssertTrue(realTimeService.isPolling)
        XCTAssertTrue(realTimeService.liveMatches.isEmpty)
    }
    
    func testMultipleConsecutiveErrors() async {
        // Given
        mockReachabilityService.setConnectionStatus(isConnected: true)
        mockAPIClient.setupMockError(.networkError(URLError(.timedOut)))
        
        // When
        await realTimeService.start()
        await realTimeService.refreshLiveMatches()
        await realTimeService.refreshLiveMatches()
        
        // Then
        XCTAssertTrue(realTimeService.isPolling)
        XCTAssertEqual(mockAPIClient.fetchLiveMatchesCallCount, 3) // start + 2 manual refreshes
    }
    
    // MARK: - Performance Tests
    
    func testConcurrentRefreshOperations() async {
        // Given
        mockAPIClient.setupMockLiveMatches([
            createMockLiveMatch(id: "1", homeTeam: "Richmond", awayTeam: "Carlton", isLive: true)
        ])
        mockAPIClient.setupMockPlayers([
            createMockPlayer(id: "1", name: "Test Player", currentScore: 100)
        ])
        
        // When - Start multiple refresh operations concurrently
        async let matchRefresh1 = realTimeService.refreshLiveMatches()
        async let matchRefresh2 = realTimeService.refreshLiveMatches()
        async let playerRefresh = realTimeService.refreshPlayerData(for: 1)
        
        // Wait for all to complete
        await matchRefresh1
        await matchRefresh2
        await playerRefresh
        
        // Then - Should handle concurrent operations without crashing
        XCTAssertEqual(realTimeService.liveMatches.count, 1)
        XCTAssertEqual(realTimeService.playerUpdates.count, 1)
    }
    
    // MARK: - Helper Methods
    
    private func createMockLiveMatch(id: String, homeTeam: String, awayTeam: String, isLive: Bool) -> LiveMatch {
        return LiveMatch(
            id: id,
            homeTeamName: homeTeam,
            awayTeamName: awayTeam,
            homeTeamID: "home-\(id)",
            awayTeamID: "away-\(id)",
            homeScore: 85,
            awayScore: 72,
            startTime: Date(),
            status: isLive ? "Live" : "Final",
            quarter: isLive ? "Q3" : "Q4",
            timeRemaining: isLive ? "12:45" : nil,
            venue: "Test Stadium",
            round: 1,
            isLive: isLive
        )
    }
    
    private func createMockPlayer(id: String, name: String, currentScore: Int) -> Player {
        return Player(
            id: id,
            firstName: name.components(separatedBy: " ").first ?? "",
            lastName: name.components(separatedBy: " ").dropFirst().joined(separator: " "),
            displayName: name,
            position: .midfielder,
            currentPrice: 500000,
            averageScore: 85.0,
            liveScore: currentScore,
            totalScore: 850,
            captainScore: 0,
            projectedScore: 90.0,
            priceChange: 5000,
            playingStatus: .confirmed,
            injuryStatus: .healthy,
            isAvailable: true,
            isCaptain: false,
            isViceCaptain: false,
            isEmergency: false,
            photoURL: nil
        )
    }
}

// MARK: - Mock AFL Fantasy API Client

class MockAFLFantasyAPIClient: AFLFantasyAPIClientProtocol {
    
    // MARK: - Call Counters
    
    private(set) var fetchLiveMatchesCallCount = 0
    private(set) var fetchPlayersCallCount = 0
    private(set) var fetchTeamCallCount = 0
    
    // MARK: - Mock Data
    
    private var mockLiveMatches: [LiveMatch] = []
    private var mockPlayers: [Player] = []
    private var mockTeam: Team?
    private var mockError: AFLFantasyAPIError?
    
    // MARK: - Publishers
    
    let playerUpdatesPublisher = PassthroughSubject<[Player], Never>()
    let matchUpdatesPublisher = PassthroughSubject<[LiveMatch], Never>()
    
    // MARK: - Authentication Properties
    
    var isAuthenticated: Bool = true
    var currentUser: User? = User(id: "test", username: "testuser", email: "test@example.com")
    
    // MARK: - Setup Methods
    
    func setupMockLiveMatches(_ matches: [LiveMatch]) {
        mockLiveMatches = matches
        mockError = nil
    }
    
    func setupMockPlayers(_ players: [Player]) {
        mockPlayers = players
        mockError = nil
    }
    
    func setupMockTeam(_ team: Team) {
        mockTeam = team
        mockError = nil
    }
    
    func setupMockError(_ error: AFLFantasyAPIError) {
        mockError = error
        mockLiveMatches = []
        mockPlayers = []
        mockTeam = nil
    }
    
    // MARK: - API Methods
    
    func signIn(username: String, password: String) async throws -> User {
        if let error = mockError {
            throw error
        }
        return User(id: "test", username: username, email: "test@example.com")
    }
    
    func signOut() {
        isAuthenticated = false
        currentUser = nil
    }
    
    func fetchLiveMatches() async throws -> [LiveMatch] {
        fetchLiveMatchesCallCount += 1
        
        if let error = mockError {
            throw error
        }
        
        return mockLiveMatches
    }
    
    func fetchPlayers(for round: Int) async throws -> [Player] {
        fetchPlayersCallCount += 1
        
        if let error = mockError {
            throw error
        }
        
        return mockPlayers
    }
    
    func fetchTeam(for userID: String, round: Int) async throws -> Team {
        fetchTeamCallCount += 1
        
        if let error = mockError {
            throw error
        }
        
        guard let team = mockTeam else {
            throw AFLFantasyAPIError.notFound
        }
        
        return team
    }
    
    func updateTeam(_ team: Team) async throws -> Team {
        return team
    }
    
    func fetchCaptainRecommendations(for userID: String) async throws -> [CaptainRecommendation] {
        return []
    }
    
    func setAuthenticationToken(_ token: String) {
        isAuthenticated = true
    }
    
    func notifyPlayerUpdates(_ players: [Player]) {
        playerUpdatesPublisher.send(players)
    }
    
    func notifyMatchUpdates(_ matches: [LiveMatch]) {
        matchUpdatesPublisher.send(matches)
    }
}

// MARK: - Mock Reachability Service

class MockReachabilityService: ObservableObject {
    
    @Published var isConnected: Bool = true
    @Published var connectionType: ReachabilityService.ConnectionType = .wifi
    @Published var offlineDuration: TimeInterval = 0
    
    func setConnectionStatus(isConnected: Bool) {
        self.isConnected = isConnected
        if !isConnected {
            offlineDuration = 30.0
        } else {
            offlineDuration = 0.0
        }
    }
    
    func startMonitoring() {}
    func stopMonitoring() {}
}
