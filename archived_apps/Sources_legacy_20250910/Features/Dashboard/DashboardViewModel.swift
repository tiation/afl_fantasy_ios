import Foundation
import Combine
import SwiftUI

@available(iOS 15.0, *)
@MainActor
final class DashboardViewModel: ViewModel {
    // MARK: - Published Properties
    @Published var playersState: LoadingState<[AFLPlayer]> = .idle
    @Published var cashCowsState: LoadingState<[CashCow]> = .idle
    @Published var summaryState: LoadingState<SummaryResponse> = .idle
    @Published var captainSuggestionsState: LoadingState<[CaptainSuggestion]> = .idle
    
    @Published var searchText = ""
    @Published var selectedPosition: Position?
    @Published var selectedTeam: String?
    
    // MARK: - Computed Properties
    var isLoading: Bool {
        playersState.isLoading || 
        cashCowsState.isLoading || 
        summaryState.isLoading || 
        captainSuggestionsState.isLoading
    }
    
    var errorMessage: String? {
        playersState.error?.localizedDescription ??
        cashCowsState.error?.localizedDescription ??
        summaryState.error?.localizedDescription ??
        captainSuggestionsState.error?.localizedDescription
    }
    
    var filteredPlayers: [AFLPlayer] {
        guard let players = playersState.data else { return [] }
        
        return players.filter { player in
            let matchesSearch = searchText.isEmpty || 
                player.name.localizedCaseInsensitiveContains(searchText) ||
                player.team.localizedCaseInsensitiveContains(searchText)
            
            let matchesPosition = selectedPosition == nil || player.position == selectedPosition?.rawValue
            let matchesTeam = selectedTeam == nil || player.team == selectedTeam
            
            return matchesSearch && matchesPosition && matchesTeam
        }
    }
    
    var topPerformers: [AFLPlayer] {
        guard let players = playersState.data else { return [] }
        return Array(players.sorted { $0.averageScore > $1.averageScore }.prefix(5))
    }
    
    var highestOwnedPlayers: [AFLPlayer] {
        guard let players = playersState.data else { return [] }
        return Array(players.sorted { $0.ownership > $1.ownership }.prefix(5))
    }
    
    // MARK: - Private Properties
    private let fetchPlayersUseCase: FetchPlayersUseCase
    private let fetchCashCowsUseCase: FetchCashCowsUseCase
    private let fetchSummaryUseCase: FetchSummaryUseCase
    private let fetchCaptainSuggestionsUseCase: FetchCaptainSuggestionsUseCase
    private let liveStatsUseCase: LiveStatsUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(
        fetchPlayersUseCase: FetchPlayersUseCase,
        fetchCashCowsUseCase: FetchCashCowsUseCase,
        fetchSummaryUseCase: FetchSummaryUseCase,
        fetchCaptainSuggestionsUseCase: FetchCaptainSuggestionsUseCase,
        liveStatsUseCase: LiveStatsUseCase
    ) {
        self.fetchPlayersUseCase = fetchPlayersUseCase
        self.fetchCashCowsUseCase = fetchCashCowsUseCase
        self.fetchSummaryUseCase = fetchSummaryUseCase
        self.fetchCaptainSuggestionsUseCase = fetchCaptainSuggestionsUseCase
        self.liveStatsUseCase = liveStatsUseCase
        
        // Setup complete - live updates can be added later
    }
    
    // MARK: - Public Methods
    func refresh() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadPlayers() }
            group.addTask { await self.loadCashCows() }
            group.addTask { await self.loadSummary() }
            group.addTask { await self.loadCaptainSuggestions() }
        }
    }
    
    func loadPlayers() async {
        playersState = .loading
        
        do {
            let players = try await fetchPlayersUseCase.execute(())
            playersState = .loaded(players)
        } catch {
            playersState = .error(error)
        }
    }
    
    func loadCashCows() async {
        cashCowsState = .loading
        
        do {
            let cashCows = try await fetchCashCowsUseCase.execute(())
            cashCowsState = .loaded(cashCows)
        } catch {
            cashCowsState = .error(error)
        }
    }
    
    func loadSummary() async {
        summaryState = .loading
        
        do {
            let summary = try await fetchSummaryUseCase.execute(())
            summaryState = .loaded(summary)
        } catch {
            summaryState = .error(error)
        }
    }
    
    func loadCaptainSuggestions(round: Int = 1) async {
        captainSuggestionsState = .loading
        
        do {
            let input = CaptainRequestInput(
                round: round,
                venue: nil,
                opponent: nil,
                conditions: ["home", "dry"]
            )
            let suggestions = try await fetchCaptainSuggestionsUseCase.execute(input)
            captainSuggestionsState = .loaded(suggestions)
        } catch {
            captainSuggestionsState = .error(error)
        }
    }
    
    func clearFilters() {
        searchText = ""
        selectedPosition = nil
        selectedTeam = nil
    }
    
    deinit {
        cancellables.removeAll()
    }
}

// MARK: - Convenience Extensions

extension DashboardViewModel {
    var availableTeams: [String] {
        guard let players = playersState.data else { return [] }
        return Array(Set(players.map(\.team))).sorted()
    }
    
    var availablePositions: [Position] {
        return Position.allCases
    }
}
