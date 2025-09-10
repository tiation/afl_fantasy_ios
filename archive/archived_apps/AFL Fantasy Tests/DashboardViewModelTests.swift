import XCTest
import Combine
@testable import AFL_Fantasy

/// Comprehensive unit tests for DashboardViewModel
/// Following iOS testing best practices with proper mocking and async handling
@MainActor
final class DashboardViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var viewModel: DashboardViewModel!
    private var mockStatsService: MockStatsService!
    private var mockNotificationService: MockNotificationService!
    private var mockTradeAnalyzer: MockTradeAnalyzer!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        // Create mocks
        mockStatsService = MockStatsService()
        mockNotificationService = MockNotificationService()
        mockTradeAnalyzer = MockTradeAnalyzer()
        cancellables = Set<AnyCancellable>()
        
        // Create view model with mocked dependencies
        viewModel = DashboardViewModel(
            statsService: mockStatsService,
            notificationService: mockNotificationService,
            tradeAnalyzer: mockTradeAnalyzer
        )
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockTradeAnalyzer = nil
        mockNotificationService = nil
        mockStatsService = nil
        
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        // Given: Fresh view model
        
        // Then: Initial state is correct
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.hasLiveGames)
        XCTAssertFalse(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "")
        XCTAssertEqual(viewModel.unreadNotifications, 0)
        XCTAssertEqual(viewModel.liveStats.currentScore, 0)
        XCTAssertEqual(viewModel.liveStats.rank, 0)
        XCTAssertEqual(viewModel.liveStats.playersPlaying, 0)
        XCTAssertEqual(viewModel.liveStats.playersRemaining, 0)
        XCTAssertEqual(viewModel.teamStructure.totalValue, 0)
        XCTAssertEqual(viewModel.teamStructure.bankBalance, 0)
        XCTAssertEqual(viewModel.cashGenStats.totalGenerated, 0)
        XCTAssertEqual(viewModel.cashGenStats.activeCashCows, 0)
        XCTAssertEqual(viewModel.cashGenStats.sellRecommendations, 0)
        XCTAssertTrue(viewModel.recommendations.isEmpty)
    }
    
    // MARK: - Loading Data Tests
    
    func testLoadDataSuccess() async {
        // Given: Mock services return successful data
        let expectedLiveStats = LiveStats(
            currentScore: 1850,
            rank: 123456,
            playersPlaying: 15,
            playersRemaining: 7
        )
        
        let expectedTeamStructure = TeamStructure(
            totalValue: 12500000,
            bankBalance: 250000
        )
        
        let expectedCashGenStats = CashGenStats(
            totalGenerated: 180000,
            activeCashCows: 4,
            sellRecommendations: 2
        )
        
        mockStatsService.mockLiveGames = [LiveGame(id: "1", status: .live)]
        mockStatsService.mockLiveStats = expectedLiveStats
        mockStatsService.mockTeamStructure = expectedTeamStructure
        mockStatsService.mockCashGenStats = expectedCashGenStats
        mockNotificationService.mockUnreadCount = 3
        
        // When: Loading data
        await viewModel.refresh()
        
        // Then: State is updated correctly
        XCTAssertTrue(viewModel.hasLiveGames)
        XCTAssertEqual(viewModel.liveStats.currentScore, expectedLiveStats.currentScore)
        XCTAssertEqual(viewModel.liveStats.rank, expectedLiveStats.rank)
        XCTAssertEqual(viewModel.liveStats.playersPlaying, expectedLiveStats.playersPlaying)
        XCTAssertEqual(viewModel.liveStats.playersRemaining, expectedLiveStats.playersRemaining)
        XCTAssertEqual(viewModel.teamStructure.totalValue, expectedTeamStructure.totalValue)
        XCTAssertEqual(viewModel.teamStructure.bankBalance, expectedTeamStructure.bankBalance)
        XCTAssertEqual(viewModel.cashGenStats.totalGenerated, expectedCashGenStats.totalGenerated)
        XCTAssertEqual(viewModel.cashGenStats.activeCashCows, expectedCashGenStats.activeCashCows)
        XCTAssertEqual(viewModel.cashGenStats.sellRecommendations, expectedCashGenStats.sellRecommendations)
        XCTAssertEqual(viewModel.unreadNotifications, 3)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
    }
    
    func testLoadDataFailure() async {
        // Given: Mock service throws error
        mockStatsService.shouldThrowError = true
        mockStatsService.errorToThrow = AFLFantasyError.networkError("Network unavailable")
        
        // When: Loading data
        await viewModel.refresh()
        
        // Then: Error state is set
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "Network unavailable")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadingState() async {
        // Given: Mock service with delay
        mockStatsService.simulateDelay = true
        
        // When: Loading data (async)
        let loadingTask = Task {
            await viewModel.refresh()
        }
        
        // Then: Loading state is true during load
        XCTAssertTrue(viewModel.isLoading)
        
        // Wait for completion
        await loadingTask.value
        
        // Then: Loading state is false after completion
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Live Games Tests
    
    func testHasLiveGamesWhenGamesActive() async {
        // Given: Live games exist
        mockStatsService.mockLiveGames = [
            LiveGame(id: "1", status: .live),
            LiveGame(id: "2", status: .live)
        ]
        
        // When: Loading data
        await viewModel.refresh()
        
        // Then: Has live games is true
        XCTAssertTrue(viewModel.hasLiveGames)
    }
    
    func testNoLiveGamesWhenNoActiveGames() async {
        // Given: No live games
        mockStatsService.mockLiveGames = []
        
        // When: Loading data
        await viewModel.refresh()
        
        // Then: Has live games is false
        XCTAssertFalse(viewModel.hasLiveGames)
    }
    
    // MARK: - Recommendations Tests
    
    func testLoadRecommendationsSuccess() async {
        // Given: Mock trade analyzer returns recommendations
        let expectedRecommendations = [
            AIRecommendation(id: "1", title: "Trade Suggestion", description: "Consider trading X for Y", confidence: 0.85),
            AIRecommendation(id: "2", title: "Captain Pick", description: "Captain Z this week", confidence: 0.92)
        ]
        mockTradeAnalyzer.mockSuggestions = expectedRecommendations.map { rec in
            TradeSuggestion(id: rec.id, outPlayer: "Out", inPlayer: "In", reasonCode: .scoring, projectedGain: 25, confidenceScore: rec.confidence)
        }
        
        // When: Loading data
        await viewModel.refresh()
        
        // Then: Recommendations are loaded
        XCTAssertEqual(viewModel.recommendations.count, 2)
        XCTAssertFalse(viewModel.recommendations.isEmpty)
    }
    
    // MARK: - Error Handling Tests
    
    func testMultipleErrorScenarios() async {
        // Test different error types
        let errorScenarios: [(AFLFantasyError, String)] = [
            (.networkError("Connection timeout"), "Connection timeout"),
            (.parseError("Invalid JSON"), "Invalid JSON"),
            (.unknownError, "An unknown error occurred")
        ]
        
        for (error, expectedMessage) in errorScenarios {
            // Given: Service throws specific error
            mockStatsService.shouldThrowError = true
            mockStatsService.errorToThrow = error
            
            // When: Loading data
            await viewModel.refresh()
            
            // Then: Correct error message is shown
            XCTAssertTrue(viewModel.showError, "Should show error for \\(error)")
            XCTAssertEqual(viewModel.errorMessage, expectedMessage, "Error message should match for \\(error)")
            
            // Reset for next iteration
            mockStatsService.shouldThrowError = false
            viewModel = DashboardViewModel(
                statsService: mockStatsService,
                notificationService: mockNotificationService,
                tradeAnalyzer: mockTradeAnalyzer
            )
        }
    }
    
    // MARK: - Navigation Tests
    
    func testOpenNotifications() {
        // Given: View model is initialized
        
        // When: Opening notifications
        viewModel.openNotifications()
        
        // Then: Navigation is handled (would typically check navigation state)
        // In a real app, this might update a navigation state or send an event
        XCTAssertTrue(true) // Placeholder - actual navigation testing would depend on navigation system
    }
    
    // MARK: - Performance Tests
    
    func testLoadDataPerformance() {
        measure {
            Task {
                await viewModel.refresh()
            }
        }
    }
    
    func testConcurrentDataLoading() async {
        // Given: Multiple concurrent load requests
        
        // When: Loading data concurrently
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    await self.viewModel.refresh()
                }
            }
        }
        
        // Then: State is consistent (no race conditions)
        XCTAssertFalse(viewModel.isLoading)
        // Additional consistency checks could be added here
    }
}

// MARK: - Mock Services

final class MockStatsService: StatsServiceProtocol {
    var shouldThrowError = false
    var errorToThrow: Error = AFLFantasyError.unknownError
    var simulateDelay = false
    
    var mockLiveGames: [LiveGame] = []
    var mockLiveStats = LiveStats()
    var mockTeamStructure = TeamStructure()
    var mockWeeklyStats = WeeklyStats()
    var mockCashGenStats = CashGenStats()
    
    func fetchLiveGames() async throws -> [LiveGame] {
        if simulateDelay {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockLiveGames
    }
    
    func fetchLiveStats() async throws -> LiveStats {
        if shouldThrowError {
            throw errorToThrow
        }
        return mockLiveStats
    }
    
    func fetchTeamStructure() async throws -> TeamStructure {
        if shouldThrowError {
            throw errorToThrow
        }
        return mockTeamStructure
    }
    
    func fetchWeeklyStats() async throws -> WeeklyStats {
        if shouldThrowError {
            throw errorToThrow
        }
        return mockWeeklyStats
    }
    
    func fetchCashGenStats() async throws -> CashGenStats {
        if shouldThrowError {
            throw errorToThrow
        }
        return mockCashGenStats
    }
}

final class MockNotificationService: NotificationServiceProtocol {
    var mockUnreadCount = 0
    var mockLatestType: NotificationType?
    
    func getUnreadCount() async throws -> Int {
        return mockUnreadCount
    }
    
    func getLatestType() async throws -> NotificationType? {
        return mockLatestType
    }
}

final class MockTradeAnalyzer: TradeAnalyzerProtocol {
    var mockSuggestions: [TradeSuggestion] = []
    
    func getSuggestions() async throws -> [TradeSuggestion] {
        return mockSuggestions
    }
}

// MARK: - Test Models

struct LiveGame: Identifiable {
    let id: String
    let status: GameStatus
    
    enum GameStatus {
        case upcoming
        case live
        case completed
    }
}

struct AIRecommendation: Identifiable {
    let id: String
    let title: String
    let description: String
    let confidence: Double
}
