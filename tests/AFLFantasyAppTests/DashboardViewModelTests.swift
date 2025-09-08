import XCTest
@testable import AFLFantasyApp

final class DashboardViewModelTests: XCTestCase {
    private var mockAPIClient: MockAFLAPIClient!
    private var viewModel: DashboardViewModel!
    
    @MainActor override func setUp() {
        super.setUp()
        mockAPIClient = MockAFLAPIClient()
        
        let fetchPlayersUseCase = FetchPlayersUseCase(apiClient: mockAPIClient)
        let fetchCashCowsUseCase = FetchCashCowsUseCase(apiClient: mockAPIClient)
        let fetchSummaryUseCase = FetchSummaryUseCase(apiClient: mockAPIClient)
        let fetchCaptainSuggestionsUseCase = FetchCaptainSuggestionsUseCase(apiClient: mockAPIClient)
        let liveStatsUseCase = LiveStatsUseCase(apiClient: mockAPIClient, refreshInterval: 1.0)
        
        viewModel = DashboardViewModel(
            fetchPlayersUseCase: fetchPlayersUseCase,
            fetchCashCowsUseCase: fetchCashCowsUseCase,
            fetchSummaryUseCase: fetchSummaryUseCase,
            fetchCaptainSuggestionsUseCase: fetchCaptainSuggestionsUseCase,
            liveStatsUseCase: liveStatsUseCase
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPIClient = nil
        super.tearDown()
    }
    
    @MainActor func testLoadPlayersSuccess() async {
        // Given
        let mockPlayers = [
            AFLPlayer(
                id: "1",
                name: "Test Player",
                team: "TEST",
                position: "MID",
                price: 500000,
                averageScore: 100,
                projectedScore: 110,
                ownership: 25.5,
                breakeven: 50
            )
        ]
        let mockResponse = PlayersResponse(players: mockPlayers, total: 1)
        mockAPIClient.setMockResponse(mockResponse, for: .players)
        
        // When
        await viewModel.loadPlayers()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.filteredPlayers.count, 1)
        XCTAssertEqual(viewModel.filteredPlayers.first?.name, "Test Player")
    }
    
    @MainActor func testLoadPlayersFailure() async {
        // Given
        mockAPIClient.setShouldFail(true, error: AppError.networkError(URLError(.notConnectedToInternet)))
        
        // When
        await viewModel.loadPlayers()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.filteredPlayers.count, 0)
    }
    
    @MainActor func testFilterPlayersBySearch() async {
        // Given
        let mockPlayers = [
            AFLPlayer(id: "1", name: "Marcus Bontempelli", team: "WBD", position: "MID", price: 700000, averageScore: 120, projectedScore: 125, ownership: 45.2, breakeven: 35),
            AFLPlayer(id: "2", name: "Patrick Cripps", team: "CAR", position: "MID", price: 680000, averageScore: 115, projectedScore: 120, ownership: 38.7, breakeven: 40)
        ]
        let mockResponse = PlayersResponse(players: mockPlayers, total: 2)
        mockAPIClient.setMockResponse(mockResponse, for: .players)
        
        await viewModel.loadPlayers()
        
        // When
        viewModel.searchText = "Marcus"
        
        // Then
        XCTAssertEqual(viewModel.filteredPlayers.count, 1)
        XCTAssertEqual(viewModel.filteredPlayers.first?.name, "Marcus Bontempelli")
    }
    
    @MainActor func testFilterPlayersByPosition() async {
        // Given
        let mockPlayers = [
            AFLPlayer(id: "1", name: "Defender Player", team: "TEST", position: "DEF", price: 500000, averageScore: 80, projectedScore: 85, ownership: 20.0, breakeven: 60),
            AFLPlayer(id: "2", name: "Midfielder Player", team: "TEST", position: "MID", price: 600000, averageScore: 100, projectedScore: 105, ownership: 30.0, breakeven: 50)
        ]
        let mockResponse = PlayersResponse(players: mockPlayers, total: 2)
        mockAPIClient.setMockResponse(mockResponse, for: .players)
        
        await viewModel.loadPlayers()
        
        // When
        viewModel.selectedPosition = .midfielder
        
        // Then
        XCTAssertEqual(viewModel.filteredPlayers.count, 1)
        XCTAssertEqual(viewModel.filteredPlayers.first?.position, "MID")
    }
    
    @MainActor func testClearFilters() async {
        // Given
        viewModel.searchText = "Test"
        viewModel.selectedPosition = .midfielder
        viewModel.selectedTeam = "TEST"
        
        // When
        viewModel.clearFilters()
        
        // Then
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertNil(viewModel.selectedPosition)
        XCTAssertNil(viewModel.selectedTeam)
    }
}
