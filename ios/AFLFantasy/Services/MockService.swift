import Combine
import Foundation

/// Used for UI development and testing
final class MockService: FantasyAPIServiceProtocol {
    static let shared = MockService()

    // MARK: - Mocked Data

    private let mockPlayers: [EnhancedPlayer] = [
        EnhancedPlayer(
            id: "1",
            name: "Marcus Bontempelli",
            position: .midfielder,
            price: 850_000,
            currentScore: 108,
            averageScore: 105.5,
            breakeven: 85,
            consistency: 85.0,
            highScore: 145,
            lowScore: 85,
            priceChange: 25000,
            isCashCow: false,
            isDoubtful: false,
            isSuspended: false,
            cashGenerated: 150_000,
            projectedPeakPrice: 900_000,
            nextRoundProjection: RoundProjection(
                round: 1,
                opponent: "GWS",
                venue: "Marvel Stadium",
                projectedScore: 110.0,
                confidence: 0.85,
                conditions: WeatherConditions(
                    temperature: 20.0,
                    rainProbability: 0.1,
                    windSpeed: 15.0,
                    humidity: 65.0
                )
            ),
            seasonProjection: SeasonProjection(
                projectedTotalScore: 2310.0,
                projectedAverage: 105.0,
                premiumPotential: 0.95
            ),
            injuryRisk: InjuryRisk(
                riskLevel: .low,
                riskScore: 0.15,
                riskFactors: []
            ),
            venuePerformance: [
                VenuePerformance(
                    venue: "Marvel Stadium",
                    gamesPlayed: 12,
                    averageScore: 108.5,
                    bias: 1.05
                )
            ],
            alertFlags: []
        )
        // Add more mock players...
    ]

    private let mockDashboard = DashboardData(
        teamValue: DashboardData.TeamValue(teamValue: 15_500_000),
        teamScore: DashboardData.TeamScore(totalScore: 2150),
        rank: DashboardData.Rank(rank: 1500),
        captain: DashboardData.Captain(captain: CaptainData.Captain(
            name: "Marcus Bontempelli",
            team: "Western Bulldogs",
            position: "MID"
        ))
    )

    private let mockTeamStats = TeamStats(
        totalScore: 2150,
        rank: 1500,
        teamValue: 15_500_000,
        tradesRemaining: 2
    )

    // MARK: - API Methods

    func getDashboardData(teamId: String) async throws -> DashboardData {
        simulateNetworkDelay()
        return mockDashboard
    }

    func getTeamStats(teamId: String) async throws -> TeamStats {
        simulateNetworkDelay()
        return mockTeamStats
    }

    func getPlayers() async throws -> [EnhancedPlayer] {
        simulateNetworkDelay()
        return mockPlayers
    }

    func getPlayerDetails(id: Int) async throws -> PlayerDetails {
        simulateNetworkDelay()
        return PlayerDetails(
            id: id,
            name: "Marcus Bontempelli",
            team: "Western Bulldogs",
            position: "MID",
            status: "Available"
        )
    }

    func getPlayerStats(id: Int) async throws -> PlayerStats {
        simulateNetworkDelay()
        return PlayerStats(
            gamesPlayed: 22,
            averageScore: 105.5,
            totalScore: 2310,
            priceChange: 25000
        )
    }

    func getPlayerHistory(id: Int) async throws -> PlayerHistory {
        simulateNetworkDelay()
        return PlayerHistory(games: [
            .init(round: 1, opponent: "GWS", score: 108, price: 850_000),
            .init(round: 2, opponent: "HAW", score: 115, price: 865_000)
            // Add more mock history...
        ])
    }

    func getTradeRecommendations(teamId: String) async throws -> [TradeRecommendation] {
        simulateNetworkDelay()
        return [
            TradeRecommendation(
                playerOut: "Tim English",
                playerIn: "Max Gawn",
                reasoning: "Better fixture run and higher ceiling"
            )
            // Add more recommendations...
        ]
    }

    func analyzeTradeScenario(teamId: String, playersOut: [Int], playersIn: [Int]) async throws -> TradeAnalysisResult {
        simulateNetworkDelay()
        return TradeAnalysisResult(
            feasible: true,
            salaryChange: -50000,
            projectedScoreChange: 15.5,
            riskFactors: ["Injury risk moderate"],
            recommendations: ["Consider waiting one week"]
        )
    }

    func validateTrade(teamId: String, playersOut: [Int], playersIn: [Int]) async throws -> Bool {
        simulateNetworkDelay()
        return true
    }

    func getCaptainRecommendations(teamId: String, round: Int) async throws -> [CaptainSuggestion] {
        simulateNetworkDelay()
        return [
            CaptainSuggestion(
                player: mockPlayers[0],
                confidence: 85,
                projectedPoints: 110.0
            )
            // Add more suggestions...
        ]
    }

    func analyzeCaptainChoice(teamId: String, playerId: Int, round: Int) async throws -> CaptainSuggestionAnalysis {
        simulateNetworkDelay()
        return CaptainSuggestionAnalysis(
            id: UUID(),
            player: "Marcus Bontempelli",
            team: "Western Bulldogs",
            position: "MID",
            projectedScore: 110.0,
            confidence: 0.85,
            ceiling: 140.0,
            floor: 85.0,
            confidenceLevel: "High",
            reasoning: "Strong form and favorable matchup",
            fixture: FixtureAnalysis(
                opponent: "GWS",
                venue: "Marvel Stadium",
                difficulty: "Medium",
                defensiveVulnerability: 0.65,
                weatherImpact: "Good conditions"
            )
        )
    }

    func analyzeCashCows(teamId: String) async throws -> [CashCowAnalysis] {
        simulateNetworkDelay()
        return mockPlayers
            .filter(\.isCashCow)
            .map { player in
                CashCowAnalysis(
                    id: UUID(),
                    player: player,
                    cashGenerated: player.cashGenerated,
                    projectedCash: 150_000,
                    sellRecommendation: .hold,
                    confidenceLevel: 0.85,
                    optimalSellWeek: 4,
                    priceTrajectory: [],
                    riskFactors: [],
                    opportunities: []
                )
            }
    }

    func getPriceProjections(playerIds: [Int]) async throws -> [PriceProjection] {
        simulateNetworkDelay()
        return playerIds.map { _ in
            PriceProjection(
                currentPrice: 850_000,
                projectedWeeks: [
                    PricePoint(week: 1, projectedPrice: 865_000),
                    PricePoint(week: 2, projectedPrice: 880_000)
                ],
                confidence: 0.85
            )
        }
    }

    func getVenuePerformance(playerId: Int) async throws -> [VenuePerformance] {
        simulateNetworkDelay()
        return [
            VenuePerformance(
                venue: "Marvel Stadium",
                gamesPlayed: 12,
                averageScore: 108.5,
                bias: 1.05
            ),
            VenuePerformance(
                venue: "MCG",
                gamesPlayed: 8,
                averageScore: 102.5,
                bias: 0.98
            )
        ]
    }

    func getTeamAnalytics() async throws -> [TeamAnalytics] {
        simulateNetworkDelay()
        return [
            TeamAnalytics(
                team: "Western Bulldogs",
                averagePointsAgainst: 85.5,
                difficultyRating: 0.65,
                defenseStrength: 0.75,
                offenseStrength: 0.85
            )
            // Add more teams...
        ]
    }

    func getLeagueStats(leagueId: String) async throws -> LeagueStats {
        simulateNetworkDelay()
        return LeagueStats(
            leagueId: leagueId,
            rank: 15,
            totalTeams: 100,
            averageScore: 1850.5
        )
    }

    // MARK: - Live Data Streams

    var playerUpdates: AnyPublisher<[EnhancedPlayer], Never> {
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .map { [weak self] _ in self?.mockPlayers ?? [] }
            .eraseToAnyPublisher()
    }

    var priceChanges: AnyPublisher<[PriceChange], Never> {
        Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .map { [weak self] _ in
                self?.mockPlayers.map {
                    PriceChange(
                        playerId: Int($0.id) ?? 0,
                        oldPrice: $0.price,
                        newPrice: $0.price + Int.random(in: -10000 ... 10000)
                    )
                } ?? []
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    private func simulateNetworkDelay() {
        let delay = UInt32(0.5 * 1_000_000) // 0.5 seconds
        usleep(delay)
    }
}
