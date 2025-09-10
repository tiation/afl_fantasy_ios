import XCTest
@testable import AFL_Fantasy_Intelligence

@MainActor
final class PlayersViewModelTests: XCTestCase {
    
    func testInitialState() {
        let viewModel = PlayersViewModel()
        
        XCTAssertTrue(viewModel.players.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadingState() async {
        let viewModel = PlayersViewModel()
        let apiService = APIService(baseURL: "http://invalid-url-for-test")
        
        // Start loading
        let task = Task {
            await viewModel.loadPlayers(apiService: apiService)
        }
        
        // Give it a moment to start
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Should show loading state initially
        XCTAssertTrue(viewModel.isLoading || viewModel.errorMessage != nil)
        
        // Cancel the task to clean up
        task.cancel()
    }
    
    func testFallbackToMockData() async {
        let viewModel = PlayersViewModel()
        let apiService = APIService(baseURL: "http://invalid-url-that-will-fail")
        
        await viewModel.loadPlayers(apiService: apiService)
        
        // Should have fallen back to mock data
        XCTAssertFalse(viewModel.players.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
}

// MARK: - UserPreferencesService Tests

@MainActor
final class UserPreferencesServiceTests: XCTestCase {
    
    func testWatchlistOperations() {
        let prefs = UserPreferencesService.shared
        
        // Clear watchlist
        prefs.watchlist = Set<String>()
        
        // Test adding to watchlist
        prefs.toggleWatchlist("player1")
        XCTAssertTrue(prefs.isInWatchlist("player1"))
        
        // Test removing from watchlist
        prefs.toggleWatchlist("player1")
        XCTAssertFalse(prefs.isInWatchlist("player1"))
    }
    
    func testPositionFilter() {
        let prefs = UserPreferencesService.shared
        
        // Test setting position
        prefs.selectedPosition = .midfielder
        XCTAssertEqual(prefs.selectedPosition, .midfielder)
        
        // Test clearing position
        prefs.selectedPosition = nil
        XCTAssertNil(prefs.selectedPosition)
    }
}
