//
//  AFLFantasyApp.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI
import UserNotifications

// MARK: - Position

// Position enum
enum Position: String, CaseIterable, Codable {
    case defender = "DEF"
    case midfielder = "MID"
    case ruck = "RUC"
    case forward = "FWD"
}

// MARK: - RoundProjection

// Supporting types for EnhancedPlayer
struct RoundProjection: Identifiable, Codable {
    let id = UUID()
    let round: Int
    let opponent: String
    let venue: String
    let projectedScore: Double
    let confidence: Double
    let conditions: WeatherConditions

    init(
        round: Int,
        opponent: String,
        venue: String,
        projectedScore: Double,
        confidence: Double,
        conditions: WeatherConditions
    ) {
        self.round = round
        self.opponent = opponent
        self.venue = venue
        self.projectedScore = projectedScore
        self.confidence = confidence
        self.conditions = conditions
    }
}

// MARK: - WeatherConditions

struct WeatherConditions: Codable {
    let temperature: Double
    let rainProbability: Double
    let windSpeed: Double
    let humidity: Double
}

// MARK: - SeasonProjection

struct SeasonProjection: Codable {
    let projectedTotalScore: Double
    let projectedAverage: Double
    let premiumPotential: Double
}

// MARK: - InjuryRisk

struct InjuryRisk: Codable {
    let riskLevel: InjuryRiskLevel
    let riskScore: Double
    let riskFactors: [String]
}

// MARK: - InjuryRiskLevel

enum InjuryRiskLevel: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

// MARK: - VenuePerformance

struct VenuePerformance: Identifiable, Codable {
    let id = UUID()
    let venue: String
    let gamesPlayed: Int
    let averageScore: Double
    let bias: Double

    init(venue: String, gamesPlayed: Int, averageScore: Double, bias: Double) {
        self.venue = venue
        self.gamesPlayed = gamesPlayed
        self.averageScore = averageScore
        self.bias = bias
    }
}

// MARK: - AlertFlag

struct AlertFlag: Identifiable, Codable {
    let id = UUID()
    let type: AlertType
    let priority: AlertPriority
    let message: String

    init(type: AlertType, priority: AlertPriority, message: String) {
        self.type = type
        self.priority = priority
        self.message = message
    }
}

// MARK: - AlertType

enum AlertType: String, CaseIterable, Codable {
    case priceDrop
    case breakEvenCliff
    case cashCowSell
    case injuryRisk
    case roleChange
    case weatherRisk
    case contractYear
    case premiumBreakout
}

// MARK: - AlertPriority

enum AlertPriority: String, CaseIterable, Codable {
    case critical
    case high
    case medium
    case low
}

// MARK: - EnhancedPlayer

// EnhancedPlayer model
struct EnhancedPlayer: Identifiable, Codable {
    let id: String
    let name: String
    let position: Position
    let price: Int
    let currentScore: Int
    let averageScore: Double
    let breakeven: Int
    let consistency: Double
    let highScore: Int
    let lowScore: Int
    let priceChange: Int
    let isCashCow: Bool
    let isDoubtful: Bool
    let isSuspended: Bool
    let cashGenerated: Int
    let projectedPeakPrice: Int
    let nextRoundProjection: RoundProjection
    let seasonProjection: SeasonProjection
    let injuryRisk: InjuryRisk
    let venuePerformance: [VenuePerformance]
    let alertFlags: [AlertFlag]

    // Computed property for projected score
    var projectedScore: Double {
        nextRoundProjection.projectedScore
    }
}

// MARK: - CaptainSuggestion

// CaptainSuggestion model
struct CaptainSuggestion: Identifiable, Codable {
    let id = UUID()
    let player: EnhancedPlayer
    let confidence: Int
    let projectedPoints: Int

    init(player: EnhancedPlayer, confidence: Int, projectedPoints: Int) {
        self.player = player
        self.confidence = confidence
        self.projectedPoints = projectedPoints
    }
}

// MARK: - TradeRecord

// TradeRecord model
struct TradeRecord: Identifiable, Codable {
    let id: UUID
    let playerOut: EnhancedPlayer
    let playerIn: EnhancedPlayer
    let executedAt: Date
    let netCost: Int
    let projectedImpact: Double

    init(
        id: UUID = UUID(),
        playerOut: EnhancedPlayer,
        playerIn: EnhancedPlayer,
        executedAt: Date,
        netCost: Int,
        projectedImpact: Double
    ) {
        self.id = id
        self.playerOut = playerOut
        self.playerIn = playerIn
        self.executedAt = executedAt
        self.netCost = netCost
        self.projectedImpact = projectedImpact
    }
}

// MARK: - AFLFantasyApp

@main
struct AFLFantasyApp: App {
    // MARK: - State Objects

    @StateObject private var dataService = AFLFantasyDataService()
    @StateObject private var appState = AppState()

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataService)
                .environmentObject(appState)
                .preferredColorScheme(.dark)
                .onAppear {
                    setupApp()
                }
        }
    }

    // MARK: - Setup

    private func setupApp() {
        // Configure any app-level settings here
        print("🚀 AFL Fantasy Intelligence Platform started")

        // Debug information
        #if DEBUG
            print("📱 Running in DEBUG mode")
            if dataService.authenticated {
                print("✅ User is authenticated")
            } else {
                print("❌ User not authenticated")
            }
        #endif
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
            id: UUID().uuidString,
            name: "Marcus Bontempelli",
            position: .midfielder,
            price: 850_000,
            currentScore: 125,
            averageScore: 118.5,
            breakeven: 85,
            consistency: 92.0,
            highScore: 156,
            lowScore: 85,
            priceChange: 25000,
            isCashCow: false,
            isDoubtful: false,
            isSuspended: false,
            cashGenerated: 0,
            projectedPeakPrice: 900_000,
            nextRoundProjection: RoundProjection(
                round: 15,
                opponent: "Richmond",
                venue: "Marvel Stadium",
                projectedScore: 130.0,
                confidence: 0.85,
                conditions: WeatherConditions(temperature: 18.0, rainProbability: 0.2, windSpeed: 12.0, humidity: 65.0)
            ),
            seasonProjection: SeasonProjection(
                projectedTotalScore: 2368.0,
                projectedAverage: 118.4,
                premiumPotential: 0.92
            ),
            injuryRisk: InjuryRisk(
                riskLevel: .low,
                riskScore: 0.15,
                riskFactors: []
            ),
            venuePerformance: [
                VenuePerformance(venue: "Marvel Stadium", gamesPlayed: 8, averageScore: 122.3, bias: 3.5)
            ],
            alertFlags: []
        )
    }

    private func createPremiumRuck() -> EnhancedPlayer {
        EnhancedPlayer(
            id: UUID().uuidString,
            name: "Max Gawn",
            position: .ruck,
            price: 780_000,
            currentScore: 98,
            averageScore: 105.2,
            breakeven: 90,
            consistency: 88.0,
            highScore: 135,
            lowScore: 68,
            priceChange: -15000,
            isCashCow: false,
            isDoubtful: true,
            isSuspended: false,
            cashGenerated: 0,
            projectedPeakPrice: 800_000,
            nextRoundProjection: RoundProjection(
                round: 15,
                opponent: "Collingwood",
                venue: "MCG",
                projectedScore: 105.0,
                confidence: 0.78,
                conditions: WeatherConditions(temperature: 16.0, rainProbability: 0.1, windSpeed: 8.0, humidity: 58.0)
            ),
            seasonProjection: SeasonProjection(
                projectedTotalScore: 2104.0,
                projectedAverage: 105.2,
                premiumPotential: 0.88
            ),
            injuryRisk: InjuryRisk(
                riskLevel: .medium,
                riskScore: 0.35,
                riskFactors: ["Previous knee injury", "Heavy ruck load"]
            ),
            venuePerformance: [
                VenuePerformance(venue: "MCG", gamesPlayed: 12, averageScore: 107.3, bias: 2.0)
            ],
            alertFlags: [
                AlertFlag(type: .injuryRisk, priority: .medium, message: "Monitor knee condition")
            ]
        )
    }

    private func createConsistentMidfielder() -> EnhancedPlayer {
        EnhancedPlayer(
            id: UUID().uuidString,
            name: "Touk Miller",
            position: .midfielder,
            price: 720_000,
            currentScore: 110,
            averageScore: 108.8,
            breakeven: 75,
            consistency: 89.0,
            highScore: 132,
            lowScore: 88,
            priceChange: 20000,
            isCashCow: false,
            isDoubtful: false,
            isSuspended: false,
            cashGenerated: 0,
            projectedPeakPrice: 740_000,
            nextRoundProjection: RoundProjection(
                round: 15,
                opponent: "Geelong",
                venue: "GMHBA Stadium",
                projectedScore: 115.0,
                confidence: 0.82,
                conditions: WeatherConditions(temperature: 14.0, rainProbability: 0.4, windSpeed: 18.0, humidity: 75.0)
            ),
            seasonProjection: SeasonProjection(
                projectedTotalScore: 2176.0,
                projectedAverage: 108.8,
                premiumPotential: 0.89
            ),
            injuryRisk: InjuryRisk(
                riskLevel: .low,
                riskScore: 0.12,
                riskFactors: []
            ),
            venuePerformance: [
                VenuePerformance(venue: "GMHBA Stadium", gamesPlayed: 6, averageScore: 103.2, bias: -1.5)
            ],
            alertFlags: [
                AlertFlag(
                    type: .premiumBreakout,
                    priority: .high,
                    message: "Contract year motivation - monitor performance"
                )
            ]
        )
    }

    private func createCashCowDefender() -> EnhancedPlayer {
        EnhancedPlayer(
            id: UUID().uuidString,
            name: "Hayden Young",
            position: .defender,
            price: 550_000,
            currentScore: 78,
            averageScore: 85.2,
            breakeven: 45,
            consistency: 76.0,
            highScore: 98,
            lowScore: 62,
            priceChange: 35000,
            isCashCow: true,
            isDoubtful: false,
            isSuspended: false,
            cashGenerated: 120_000,
            projectedPeakPrice: 620_000,
            nextRoundProjection: RoundProjection(
                round: 15,
                opponent: "Sydney",
                venue: "Optus Stadium",
                projectedScore: 88.0,
                confidence: 0.74,
                conditions: WeatherConditions(temperature: 20.0, rainProbability: 0.0, windSpeed: 22.0, humidity: 45.0)
            ),
            seasonProjection: SeasonProjection(
                projectedTotalScore: 1704.0,
                projectedAverage: 85.2,
                premiumPotential: 0.76
            ),
            injuryRisk: InjuryRisk(
                riskLevel: .low,
                riskScore: 0.14,
                riskFactors: []
            ),
            venuePerformance: [
                VenuePerformance(venue: "Optus Stadium", gamesPlayed: 5, averageScore: 89.4, bias: 4.2)
            ],
            alertFlags: [
                AlertFlag(
                    type: .cashCowSell,
                    priority: .high,
                    message: "Cash cow approaching peak price - consider selling soon"
                )
            ]
        )
    }

    private func createContractYearMidfielder() -> EnhancedPlayer {
        EnhancedPlayer(
            id: UUID().uuidString,
            name: "Sam Walsh",
            position: .midfielder,
            price: 750_000,
            currentScore: 115,
            averageScore: 112.4,
            breakeven: 80,
            consistency: 87.0,
            highScore: 145,
            lowScore: 92,
            priceChange: 30000,
            isCashCow: false,
            isDoubtful: false,
            isSuspended: false,
            cashGenerated: 0,
            projectedPeakPrice: 780_000,
            nextRoundProjection: RoundProjection(
                round: 15,
                opponent: "Hawthorn",
                venue: "MCG",
                projectedScore: 118.0,
                confidence: 0.80,
                conditions: WeatherConditions(temperature: 15.0, rainProbability: 0.3, windSpeed: 15.0, humidity: 68.0)
            ),
            seasonProjection: SeasonProjection(
                projectedTotalScore: 2248.0,
                projectedAverage: 112.4,
                premiumPotential: 0.87
            ),
            injuryRisk: InjuryRisk(
                riskLevel: .low,
                riskScore: 0.18,
                riskFactors: ["Minor shoulder concern"]
            ),
            venuePerformance: [
                VenuePerformance(venue: "MCG", gamesPlayed: 9, averageScore: 115.1, bias: 1.8)
            ],
            alertFlags: [
                AlertFlag(type: .contractYear, priority: .high, message: "Contract year - motivated for strong finish")
            ]
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
