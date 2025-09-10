import Combine
import Foundation

// MARK: - FantasyAPIServiceProtocol

protocol FantasyAPIServiceProtocol {
    // Dashboard
    func getDashboardData(teamId: String) async throws -> DashboardData
    func getTeamStats(teamId: String) async throws -> TeamStats

    // Players
    func getPlayers() async throws -> [Player]
    func getPlayerDetails(id: Int) async throws -> PlayerDetails
    func getPlayerStats(id: Int) async throws -> PlayerStats
    func getPlayerHistory(id: Int) async throws -> PlayerHistory

    // Trading
    func getTradeRecommendations(teamId: String) async throws -> [TradeRecommendation]
    func analyzeTradeScenario(teamId: String, playersOut: [Int], playersIn: [Int]) async throws -> TradeAnalysisResult
    func validateTrade(teamId: String, playersOut: [Int], playersIn: [Int]) async throws -> Bool

    // Captain
    func getCaptainRecommendations(teamId: String, round: Int) async throws -> [CaptainSuggestion]
    func analyzeCaptainChoice(teamId: String, playerId: Int, round: Int) async throws -> CaptainSuggestionAnalysis

    // Cash Cows
    func analyzeCashCows(teamId: String) async throws -> [CashCowAnalysis]
    func getPriceProjections(playerIds: [Int]) async throws -> [PriceProjection]

    // Analytics
    func getVenuePerformance(playerId: Int) async throws -> [VenuePerformance]
    func getTeamAnalytics() async throws -> [TeamAnalytics]
    func getLeagueStats(leagueId: String) async throws -> LeagueStats

    // Live data streams
    var playerUpdates: AnyPublisher<[Player], Never> { get }
    var priceChanges: AnyPublisher<[Player], Never> { get }
}

// MARK: - FantasyAPIService

final class FantasyAPIService: FantasyAPIServiceProtocol {
    static let shared = FantasyAPIService()

    private let networkService: NetworkServiceProtocol
    private let updateInterval: TimeInterval = 300 // 5 minutes

    private var playerUpdateSubject = PassthroughSubject<[Player], Never>()
    private var priceChangeSubject = PassthroughSubject<[Player], Never>()
    private var updateTimer: Timer?

    private init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
        setupPeriodicUpdates()
    }

    // MARK: - Dashboard

    func getDashboardData(teamId: String) async throws -> DashboardData {
        try await networkService.request(FantasyEndpoints.dashboard(teamId: teamId))
    }

    func getTeamStats(teamId: String) async throws -> TeamStats {
        try await networkService.request(FantasyEndpoints.teamStats(teamId: teamId))
    }

    // MARK: - Players

    func getPlayers() async throws -> [Player] {
        try await networkService.request(FantasyEndpoints.players)
    }

    func getPlayerDetails(id: Int) async throws -> PlayerDetails {
        try await networkService.request(FantasyEndpoints.playerDetails(id: id))
    }

    func getPlayerStats(id: Int) async throws -> PlayerStats {
        try await networkService.request(FantasyEndpoints.playerStats(id: id))
    }

    func getPlayerHistory(id: Int) async throws -> PlayerHistory {
        try await networkService.request(FantasyEndpoints.playerHistory(id: id))
    }

    // MARK: - Trading

    func getTradeRecommendations(teamId: String) async throws -> [TradeRecommendation] {
        try await networkService.request(FantasyEndpoints.tradeRecommendations(teamId: teamId))
    }

    func analyzeTradeScenario(teamId: String, playersOut: [Int], playersIn: [Int]) async throws -> TradeAnalysisResult {
        try await networkService.request(FantasyEndpoints.tradeAnalysis(
            teamId: teamId,
            playersOut: playersOut,
            playersIn: playersIn
        ))
    }

    func validateTrade(teamId: String, playersOut: [Int], playersIn: [Int]) async throws -> Bool {
        try await networkService.request(FantasyEndpoints.validateTrade(
            teamId: teamId,
            playersOut: playersOut,
            playersIn: playersIn
        ))
    }

    // MARK: - Captain

    func getCaptainRecommendations(teamId: String, round: Int) async throws -> [CaptainSuggestion] {
        try await networkService.request(FantasyEndpoints.captainRecommendations(teamId: teamId, round: round))
    }

    func analyzeCaptainChoice(teamId: String, playerId: Int, round: Int) async throws -> CaptainSuggestionAnalysis {
        try await networkService.request(FantasyEndpoints.captainAnalysis(
            teamId: teamId,
            playerId: playerId,
            round: round
        ))
    }

    // MARK: - Cash Cows

    func analyzeCashCows(teamId: String) async throws -> [CashCowAnalysis] {
        try await networkService.request(FantasyEndpoints.cashCowAnalysis(teamId: teamId))
    }

    func getPriceProjections(playerIds: [Int]) async throws -> [PriceProjection] {
        try await networkService.request(FantasyEndpoints.priceProjections(playerIds: playerIds))
    }

    // MARK: - Analytics

    func getVenuePerformance(playerId: Int) async throws -> [VenuePerformance] {
        try await networkService.request(FantasyEndpoints.venuePerformance(playerId: playerId))
    }

    func getTeamAnalytics() async throws -> [TeamAnalytics] {
        try await networkService.request(FantasyEndpoints.teamAnalytics)
    }

    func getLeagueStats(leagueId: String) async throws -> LeagueStats {
        try await networkService.request(FantasyEndpoints.leagueStats(leagueId: leagueId))
    }

    // MARK: - Live Data Streams

    var playerUpdates: AnyPublisher<[Player], Never> {
        playerUpdateSubject.eraseToAnyPublisher()
    }

    var priceChanges: AnyPublisher<[Player], Never> {
        priceChangeSubject.eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func setupPeriodicUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.refreshData()
            }
        }
    }

    private func refreshData() async {
        do {
            let players: [Player] = try await getPlayers()
            playerUpdateSubject.send(players)
            priceChangeSubject.send(players) // For now just send players

        } catch {
            print("Failed to refresh data: \(error)")
        }
    }
}

// MARK: - PlayerDetails

struct PlayerDetails: Codable {
    let id: Int
    let name: String
    let team: String
    let position: String
    let status: String
}

// MARK: - PlayerHistory

struct PlayerHistory: Codable {
    let games: [GameStats]

    struct GameStats: Codable {
        let round: Int
        let opponent: String
        let score: Int
        let price: Int
    }
}

// MARK: - LeagueStats

struct LeagueStats: Codable {
    let leagueId: String
    let rank: Int
    let totalTeams: Int
    let averageScore: Double
}
