//
//  AFLFantasyApp.swift
//  AFL Fantasy Intelligence Platform
//
//  Simple working version with enhanced data
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI
import UserNotifications

// MARK: - AFLFantasyApp

@main
struct AFLFantasyApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var dataService = AFLFantasyDataService()
    @StateObject private var toolsClient = AFLFantasyToolsClient()

    var body: some Scene {
        WindowGroup {
            SimpleContentView()
                .environmentObject(appState)
                .environmentObject(dataService)
                .environmentObject(toolsClient)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - AppState

@MainActor
class AppState: ObservableObject {
    @Published var selectedTab: TabItem = .dashboard
    @Published var teamScore: Int = 1987
    @Published var teamRank: Int = 5432
    @Published var players: [EnhancedPlayer] = []
    @Published var captainSuggestions: [CaptainSuggestion] = []
    @Published var cashCows: [EnhancedPlayer] = []

    // Trade management
    @Published var tradesUsed: Int = 2
    @Published var tradesRemaining: Int = 8
    @Published var tradeHistory: [TradeRecord] = []

    // Team financials
    @Published var teamValue: Int = 12_000_000
    @Published var bankBalance: Int = 300_000

    // Connection and sync
    @Published var isRefreshing: Bool = false
    @Published var lastUpdateTime: Date? = Date()
    @Published var errorMessage: String?

    init() {
        loadEnhancedData()
        generateCaptainSuggestions()
    }

    private func loadEnhancedData() {
        players = createSamplePlayers()
        cashCows = players.filter(\.isCashCow)
    }

    private func createSamplePlayers() -> [EnhancedPlayer] {
        let samplePlayers = [
            createPremiumMidfielder(),
            createPremiumRuck(),
            createConsistentMidfielder(),
            createCashCowDefender(),
            createContractYearMidfielder()
        ]
        return samplePlayers
    }

    private func createPremiumMidfielder() -> EnhancedPlayer {
        EnhancedPlayer(
            name: "Marcus Bontempelli",
            position: .midfielder,
            currentPrice: 850_000,
            currentScore: 125,
            averageScore: 118.5,
            breakeven: 85,
            consistency: 92.0,
            injuryRiskScore: 15.0,
            priceChange: 25000,
            cashGenerated: 0,
            isCashCow: false,
            teamAbbreviation: "WBD",
            projectedScore: 130.0,
            opponent: "Richmond",
            venue: "Marvel Stadium",
            rainProbability: 0.2,
            venueBias: 3.5,
            isDoubtful: false,
            contractYear: false,
            gamesPlayed: 10
        )
    }

    private func createPremiumRuck() -> EnhancedPlayer {
        EnhancedPlayer(
            name: "Max Gawn",
            position: .ruck,
            currentPrice: 780_000,
            currentScore: 98,
            averageScore: 105.2,
            breakeven: 90,
            consistency: 88.0,
            injuryRiskScore: 35.0,
            priceChange: -15000,
            cashGenerated: 0,
            isCashCow: false,
            teamAbbreviation: "MEL",
            projectedScore: 105.0,
            opponent: "Collingwood",
            venue: "MCG",
            rainProbability: 0.1,
            venueBias: 2.0,
            isDoubtful: true,
            contractYear: false,
            gamesPlayed: 9
        )
    }

    private func createConsistentMidfielder() -> EnhancedPlayer {
        EnhancedPlayer(
            name: "Touk Miller",
            position: .midfielder,
            currentPrice: 720_000,
            currentScore: 110,
            averageScore: 108.8,
            breakeven: 75,
            consistency: 89.0,
            injuryRiskScore: 12.0,
            priceChange: 20000,
            cashGenerated: 0,
            isCashCow: false,
            teamAbbreviation: "GCS",
            projectedScore: 115.0,
            opponent: "Geelong",
            venue: "GMHBA Stadium",
            rainProbability: 0.4,
            venueBias: -1.5,
            isDoubtful: false,
            contractYear: true,
            gamesPlayed: 10
        )
    }

    private func createCashCowDefender() -> EnhancedPlayer {
        EnhancedPlayer(
            name: "Hayden Young",
            position: .defender,
            currentPrice: 550_000,
            currentScore: 78,
            averageScore: 85.2,
            breakeven: 45,
            consistency: 76.0,
            injuryRiskScore: 14.0,
            priceChange: 35000,
            cashGenerated: 120_000,
            isCashCow: true,
            teamAbbreviation: "FRE",
            projectedScore: 88.0,
            opponent: "Sydney",
            venue: "Optus Stadium",
            rainProbability: 0.0,
            venueBias: 4.2,
            isDoubtful: false,
            contractYear: false,
            gamesPlayed: 8
        )
    }

    private func createContractYearMidfielder() -> EnhancedPlayer {
        EnhancedPlayer(
            name: "Sam Walsh",
            position: .midfielder,
            currentPrice: 750_000,
            currentScore: 115,
            averageScore: 112.4,
            breakeven: 80,
            consistency: 87.0,
            injuryRiskScore: 18.0,
            priceChange: 30000,
            cashGenerated: 0,
            isCashCow: false,
            teamAbbreviation: "CAR",
            projectedScore: 118.0,
            opponent: "Hawthorn",
            venue: "MCG",
            rainProbability: 0.3,
            venueBias: 1.8,
            isDoubtful: false,
            contractYear: true,
            gamesPlayed: 10
        )
    }

    private func generateCaptainSuggestions() {
        let topPlayers = players.sorted { $0.averageScore > $1.averageScore }.prefix(3)

        captainSuggestions = topPlayers.enumerated().map { index, player in
            let confidence = Int(90 - Double(index) * 5 + player.consistency * 0.1)
            let projectedPoints = Int(player.projectedScore * 2 + Double.random(in: -10 ... 10))

            return CaptainSuggestion(
                player: player,
                confidence: confidence,
                projectedPoints: projectedPoints
            )
        }
    }

    // MARK: - Public Methods

    func refreshData() {
        Task {
            await MainActor.run {
                isRefreshing = true
                errorMessage = nil
            }

            // Simulate API call
            try? await Task.sleep(nanoseconds: 2_000_000_000)

            await MainActor.run {
                isRefreshing = false
                lastUpdateTime = Date()

                // Update some sample data
                teamScore = Int.random(in: 1800 ... 2200)
                teamRank = Int.random(in: 1000 ... 15000)
            }
        }
    }

    func simulateError(_ message: String) {
        errorMessage = message
    }

    func clearError() {
        errorMessage = nil
    }
}

// MARK: - EnhancedPlayer

struct EnhancedPlayer: Identifiable, Codable {
    let id = UUID()
    let name: String
    let position: Position
    let currentPrice: Int
    let currentScore: Int
    let averageScore: Double
    let breakeven: Int
    let consistency: Double
    let injuryRiskScore: Double
    let priceChange: Int
    let cashGenerated: Int
    let isCashCow: Bool
    let teamAbbreviation: String
    let projectedScore: Double
    let opponent: String
    let venue: String
    let rainProbability: Double
    let venueBias: Double
    let isDoubtful: Bool
    let contractYear: Bool
    let gamesPlayed: Int

    var formattedPrice: String {
        "$\(currentPrice / 1000)k"
    }

    var priceChangeText: String {
        let prefix = priceChange >= 0 ? "+" : ""
        return "\(prefix)\(priceChange / 1000)k"
    }

    var consistencyGrade: String {
        switch consistency {
        case 90...: "A+"
        case 80 ..< 90: "A"
        case 70 ..< 80: "B"
        case 60 ..< 70: "C"
        default: "D"
        }
    }

    var injuryRiskLevel: String {
        switch injuryRiskScore {
        case 0 ..< 15: "Low"
        case 15 ..< 30: "Moderate"
        case 30 ..< 60: "High"
        default: "Extreme"
        }
    }

    var injuryRiskColor: Color {
        switch injuryRiskScore {
        case 0 ..< 15: .green
        case 15 ..< 30: .yellow
        case 30 ..< 60: .orange
        default: .red
        }
    }
}

// MARK: - CaptainSuggestion

struct CaptainSuggestion: Identifiable {
    let id = UUID()
    let player: EnhancedPlayer
    let confidence: Int
    let projectedPoints: Int
}

// MARK: - Position

enum Position: String, CaseIterable, Codable {
    case defender = "DEF"
    case midfielder = "MID"
    case ruck = "RUC"
    case forward = "FWD"

    var color: Color {
        switch self {
        case .defender: .blue
        case .midfielder: .green
        case .ruck: .purple
        case .forward: .red
        }
    }
}

// MARK: - TabItem

enum TabItem: String, CaseIterable {
    case dashboard = "Dashboard"
    case captain = "Captain"
    case trades = "Trades"
    case cashCow = "Cash Cow"
    case settings = "Settings"

    var systemImage: String {
        switch self {
        case .dashboard: "chart.line.uptrend.xyaxis"
        case .captain: "star.fill"
        case .trades: "arrow.triangle.2.circlepath"
        case .cashCow: "dollarsign.circle.fill"
        case .settings: "gearshape.fill"
        }
    }
}

// MARK: - TradeRecord

struct TradeRecord: Identifiable, Codable {
    let id = UUID()
    let playerOut: EnhancedPlayer
    let playerIn: EnhancedPlayer
    let executedAt: Date
    let netCost: Int
    let projectedImpact: Double
}

// MARK: - AFLFantasyDataService

@MainActor
class AFLFantasyDataService: ObservableObject {
    @Published var authenticated: Bool = false
    @Published var loading: Bool = false
    @Published var isLoading: Bool = false
    @Published var hasError: Bool = false
    @Published var errorMessage: String?
    @Published var currentDashboardData: DashboardData?
    @Published var currentCaptain: CaptainData.Captain?
    @Published var isCacheFresh: Bool = true
    @Published var lastUpdateDisplayString: String = "Just now"

    init() {
        setupMockData()
    }

    private func setupMockData() {
        currentCaptain = CaptainData.Captain(
            name: "Marcus Bontempelli",
            team: "WBD",
            position: "MID"
        )

        currentDashboardData = DashboardData(
            teamValue: DashboardData.TeamValue(teamValue: 12_000_000),
            teamScore: DashboardData.TeamScore(totalScore: 1987),
            rank: DashboardData.Rank(rank: 5432),
            captain: DashboardData.Captain(captain: currentCaptain)
        )
    }

    func authenticate(teamId: String, sessionCookie: String, apiToken: String?) async -> Result<Void, Error> {
        loading = true
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        authenticated = true
        loading = false
        return .success(())
    }

    func logout() {
        authenticated = false
    }

    func refreshDashboardData() async -> Bool {
        loading = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        loading = false
        lastUpdateDisplayString = "Just now"
        return true
    }

    func clearError() {
        hasError = false
        errorMessage = nil
    }
}

// MARK: - AFLFantasyToolsClient

@MainActor
class AFLFantasyToolsClient: ObservableObject {
    @Published var isExecutingTool: Bool = false

    func getAIRecommendations(category: String?) async -> Result<[AIRecommendation], Error> {
        isExecutingTool = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isExecutingTool = false

        let mockRecommendations = [
            AIRecommendation(
                id: "1",
                title: "Consider Trading Max Gawn",
                description: "High injury risk and declining scores make this a good time to trade out",
                type: "Trade",
                priority: "High",
                confidence: 0.85,
                actionRequired: true,
                reasoning: "Max Gawn has shown declining performance and increased injury risk",
                data: ["Risk Score": "8.5", "Break Even": "90"]
            ),
            AIRecommendation(
                id: "2",
                title: "Captain Bontempelli This Round",
                description: "Excellent fixture and recent form suggests strong captain potential",
                type: "Captain",
                priority: "Medium",
                confidence: 0.92,
                actionRequired: false,
                reasoning: "Favorable matchup against Richmond with high scoring potential",
                data: ["Projected Score": "130", "Venue": "Marvel Stadium"]
            )
        ]

        return .success(mockRecommendations)
    }

    func getWeeklyInsights() async -> Result<[AIRecommendation], Error> {
        await getAIRecommendations(category: "Weekly")
    }

    func getCaptainSuggestions(round: Int?) async -> Result<[CaptainSuggestionAnalysis], Error> {
        isExecutingTool = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isExecutingTool = false

        let mockSuggestions = [
            CaptainSuggestionAnalysis(
                id: "1",
                player: "Marcus Bontempelli",
                team: "WBD",
                position: "MID",
                projectedScore: 130.0,
                floor: 95.0,
                ceiling: 165.0,
                confidence: 0.92,
                confidenceLevel: "High",
                reasoning: "Excellent recent form and favorable fixture against Richmond",
                fixture: FixtureAnalysis(
                    opponent: "Richmond",
                    venue: "Marvel Stadium",
                    difficulty: "Easy",
                    defensiveVulnerability: 7.8,
                    weatherImpact: "Minimal"
                )
            )
        ]

        return .success(mockSuggestions)
    }

    func getCashGenerationTargets(weeks: Int) async -> Result<[CashGenerationTarget], Error> {
        isExecutingTool = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isExecutingTool = false

        let mockTargets = [
            CashGenerationTarget(
                id: "1",
                player: "Hayden Young",
                currentPrice: 550_000,
                targetPrice: 670_000,
                cashGenerated: 120_000,
                breakeven: 45,
                expectedWeeks: weeks,
                confidence: 0.78,
                riskLevel: "Low"
            )
        ]

        return .success(mockTargets)
    }

    func getTradeRecommendations(budget: Int, position: String?) async -> Result<[TradeAnalysis], Error> {
        isExecutingTool = true
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        isExecutingTool = false

        let mockTrades = [
            TradeAnalysis(
                id: "1",
                playerOut: "Max Gawn",
                playerIn: "Tim English",
                netCost: -50000,
                netCostFormatted: "-$50k",
                impactGrade: "A",
                confidence: 0.85,
                reasoning: "Gawn's injury concerns and English's strong form make this an excellent trade",
                warnings: ["Consider Gawn's captaincy potential"]
            )
        ]

        return .success(mockTrades)
    }

    func analyzeTradeOpportunity(
        playerOut: String,
        playerIn: String,
        budget: Int
    ) async -> Result<TradeAnalysis, Error> {
        isExecutingTool = true
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        isExecutingTool = false

        let analysis = TradeAnalysis(
            id: UUID().uuidString,
            playerOut: playerOut,
            playerIn: playerIn,
            netCost: Int.random(in: -100_000 ... 200_000),
            netCostFormatted: "$\(Int.random(in: -100 ... 200))k",
            impactGrade: ["A+", "A", "B", "C"].randomElement() ?? "B",
            confidence: Double.random(in: 0.6 ... 0.95),
            reasoning: "Analysis shows this trade could improve your team structure and scoring potential.",
            warnings: budget < 100_000 ? ["Limited budget may restrict future trades"] : nil
        )

        return .success(analysis)
    }
}

// MARK: - DashboardData

struct DashboardData {
    let teamValue: TeamValue
    let teamScore: TeamScore
    let rank: Rank
    let captain: Captain

    struct TeamValue {
        let teamValue: Double
    }

    struct TeamScore {
        let totalScore: Int
    }

    struct Rank {
        let rank: Int
    }

    struct Captain {
        let captain: CaptainData.Captain?
    }
}

// MARK: - CaptainData

enum CaptainData {
    struct Captain {
        let name: String
        let team: String?
        let position: String?
    }
}

// MARK: - AIRecommendation

struct AIRecommendation: Identifiable {
    let id: String
    let title: String
    let description: String
    let type: String
    let priority: String
    let confidence: Double
    let actionRequired: Bool
    let reasoning: String
    let data: [String: String]?
}

// MARK: - CaptainSuggestionAnalysis

struct CaptainSuggestionAnalysis: Identifiable {
    let id: String
    let player: String
    let team: String
    let position: String
    let projectedScore: Double
    let floor: Double
    let ceiling: Double
    let confidence: Double
    let confidenceLevel: String
    let reasoning: String
    let fixture: FixtureAnalysis?
}

// MARK: - FixtureAnalysis

struct FixtureAnalysis {
    let opponent: String
    let venue: String
    let difficulty: String
    let defensiveVulnerability: Double?
    let weatherImpact: String?
}

// MARK: - CashGenerationTarget

struct CashGenerationTarget: Identifiable {
    let id: String
    let player: String
    let currentPrice: Int
    let targetPrice: Int
    let cashGenerated: Int
    let breakeven: Int
    let expectedWeeks: Int
    let confidence: Double
    let riskLevel: String
}

// MARK: - TradeAnalysis

struct TradeAnalysis: Identifiable {
    let id: String
    let playerOut: String
    let playerIn: String
    let netCost: Int
    let netCostFormatted: String
    let impactGrade: String
    let confidence: Double
    let reasoning: String
    let warnings: [String]?
}
