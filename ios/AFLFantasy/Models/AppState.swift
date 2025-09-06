//
//  AppState.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

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
    
    var shortName: String {
        switch self {
        case .defender: "DEF"
        case .midfielder: "MID"
        case .ruck: "RUC"
        case .forward: "FWD"
        }
    }
}

// MARK: - InjuryRisk

struct InjuryRisk: Codable {
    let riskScore: Double
}
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
    
    // Add missing properties that views expect
    var price: Int {
        currentPrice
    }
    
    var injuryRisk: InjuryRisk {
        InjuryRisk(riskScore: injuryRiskScore)
    }
    
    var highScore: Int {
        Int(averageScore * 1.3) // estimated 30% above average
    }
    
    var lowScore: Int {
        Int(averageScore * 0.6) // estimated 40% below average
    }
    
    var isSuspended: Bool {
        false // default to false for now
    }
    
    var nextRoundProjection: (opponent: String, venue: String) {
        (opponent: opponent, venue: venue)
    }

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
    var id = UUID()
    let player: EnhancedPlayer
    let confidence: Int
    let projectedPoints: Int
}

// MARK: - TradeRecord

struct TradeRecord: Identifiable, Codable {
    var id = UUID()
    let playerOut: EnhancedPlayer
    let playerIn: EnhancedPlayer
    let executedAt: Date
    let netCost: Int
    let projectedImpact: Double
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
