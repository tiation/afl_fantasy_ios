//
//  DataModels.swift
//  AFL Fantasy Intelligence Platform
//
//  Complete data models for the ultimate coaching advantage
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - AFLPlayer

struct AFLPlayer: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let displayName: String
    let team: AFLTeam
    let position: PlayerPosition
    let price: Int
    let currentScore: Int
    let averageScore: Double
    let breakeven: Int
    let ownership: Double
    let projected: PlayerProjection
    let analytics: PlayerAnalytics
    let alerts: [PlayerAlert]
    let updated: Date

    // Computed properties
    var formattedPrice: String {
        String(format: "$%.1fk", Double(price) / 1000)
    }

    var formattedOwnership: String {
        String(format: "%.1f%%", ownership)
    }

    var consistencyGrade: String {
        let score = analytics.consistency
        switch score {
        case 95 ... 100: return "A+"
        case 90 ..< 95: return "A"
        case 85 ..< 90: return "A-"
        case 80 ..< 85: return "B+"
        case 75 ..< 80: return "B"
        case 70 ..< 75: return "B-"
        case 65 ..< 70: return "C+"
        case 60 ..< 65: return "C"
        default: return "D"
        }
    }

    var priceChangeText: String {
        let change = analytics.priceChange
        let changeK = Double(change) / 1000
        if change > 0 {
            return "+$\(String(format: "%.1f", changeK))k"
        } else if change < 0 {
            return "-$\(String(format: "%.1f", abs(changeK)))k"
        } else {
            return "$0.0k"
        }
    }

    var riskLevel: RiskLevel {
        let riskScore = analytics.injuryRisk + analytics.suspensionRisk
        switch riskScore {
        case 0 ... 0.2: return .low
        case 0.2 ... 0.5: return .medium
        case 0.5 ... 0.8: return .high
        default: return .critical
        }
    }
}

// MARK: - PlayerPosition

enum PlayerPosition: String, CaseIterable, Codable {
    case defender = "DEF"
    case midfielder = "MID"
    case ruck = "RUC"
    case forward = "FWD"

    var displayName: String {
        switch self {
        case .defender: "Defender"
        case .midfielder: "Midfielder"
        case .ruck: "Ruck"
        case .forward: "Forward"
        }
    }

    var color: Color {
        switch self {
        case .defender: .blue
        case .midfielder: .green
        case .ruck: .purple
        case .forward: .red
        }
    }

    var icon: String {
        switch self {
        case .defender: "shield.fill"
        case .midfielder: "arrow.triangle.2.circlepath"
        case .ruck: "circles.hexagongrid.fill"
        case .forward: "target"
        }
    }
}

// MARK: - PlayerProjection

struct PlayerProjection: Codable, Hashable {
    let nextRound: RoundProjection
    let next3Rounds: [RoundProjection]
    let restOfSeason: SeasonProjection
    let priceProjection: PriceProjection
    let captainScore: Double

    struct RoundProjection: Codable, Hashable {
        let round: Int
        let opponent: AFLTeam
        let venue: String
        let homeGame: Bool
        let projectedScore: Double
        let confidence: Double
        let ceiling: Double
        let floor: Double
        let conditions: MatchConditions
    }

    struct SeasonProjection: Codable, Hashable {
        let totalPoints: Double
        let averagePoints: Double
        let gamesRemaining: Int
        let premiumPotential: Double
        let breakoutRisk: Double
    }

    struct PriceProjection: Codable, Hashable {
        let nextPrice: Int
        let peakPrice: Int
        let peakDate: Date?
        let sellWindow: ClosedRange<Date>?
        let priceVolatility: Double
    }

    struct MatchConditions: Codable, Hashable {
        let temperature: Double
        let rainProbability: Double
        let windSpeed: Double
        let humidity: Double
        let surfaceQuality: Double
    }
}

// MARK: - PlayerAnalytics

struct PlayerAnalytics: Codable, Hashable {
    let consistency: Double
    let volatility: Double
    let injuryRisk: Double
    let suspensionRisk: Double
    let priceChange: Int
    let cashGenerated: Int
    let venuePerformance: [VenueStats]
    let opponentPerformance: [OpponentStats]
    let formTrend: FormTrend
    let contractStatus: ContractStatus

    struct VenueStats: Codable, Hashable {
        let venue: String
        let games: Int
        let average: Double
        let bias: Double
    }

    struct OpponentStats: Codable, Hashable {
        let opponent: AFLTeam
        let games: Int
        let average: Double
        let advantage: Double
    }

    struct FormTrend: Codable, Hashable {
        let last5Games: [Int]
        let trend: TrendDirection
        let momentum: Double
    }

    enum TrendDirection: String, Codable {
        case improving = "up"
        case declining = "down"
        case stable

        var icon: String {
            switch self {
            case .improving: "arrow.up.right"
            case .declining: "arrow.down.right"
            case .stable: "arrow.right"
            }
        }

        var color: Color {
            switch self {
            case .improving: .green
            case .declining: .red
            case .stable: .orange
            }
        }
    }

    struct ContractStatus: Codable, Hashable {
        let yearRemaining: Int
        let contractYear: Bool
        let motivationBonus: Double
    }
}

// MARK: - PlayerAlert

struct PlayerAlert: Identifiable, Codable, Hashable {
    let id = UUID()
    let type: AlertType
    let priority: AlertPriority
    let title: String
    let message: String
    let actionable: Bool
    let created: Date
    let expires: Date?

    enum AlertType: String, CaseIterable, Codable {
        case priceRise = "price_rise"
        case priceDrop = "price_drop"
        case injuryUpdate = "injury"
        case suspension
        case roleChange = "role_change"
        case breakeven
        case cashCow = "cash_cow"
        case captain
        case trade
        case weather
        case contractYear = "contract"
        case fixture

        var icon: String {
            switch self {
            case .priceRise: "arrow.up.circle.fill"
            case .priceDrop: "arrow.down.circle.fill"
            case .injuryUpdate: "cross.circle.fill"
            case .suspension: "exclamationmark.triangle.fill"
            case .roleChange: "arrow.triangle.2.circlepath"
            case .breakeven: "equal.circle.fill"
            case .cashCow: "dollarsign.circle.fill"
            case .captain: "star.circle.fill"
            case .trade: "repeat.circle.fill"
            case .weather: "cloud.rain.fill"
            case .contractYear: "doc.text.fill"
            case .fixture: "calendar.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .priceRise, .captain: .green
            case .priceDrop, .injuryUpdate, .suspension: .red
            case .breakeven, .weather, .fixture: .orange
            case .cashCow, .trade: .blue
            case .roleChange, .contractYear: .purple
            }
        }
    }

    enum AlertPriority: String, CaseIterable, Codable {
        case critical
        case high
        case medium
        case low

        var color: Color {
            switch self {
            case .critical: .red
            case .high: .orange
            case .medium: .yellow
            case .low: .green
            }
        }

        var weight: Int {
            switch self {
            case .critical: 4
            case .high: 3
            case .medium: 2
            case .low: 1
            }
        }
    }
}

// MARK: - AFLTeam

enum AFLTeam: String, CaseIterable, Codable, Hashable {
    case adelaide = "ADE"
    case brisbane = "BRI"
    case carlton = "CAR"
    case collingwood = "COL"
    case essendon = "ESS"
    case fremantle = "FRE"
    case geelong = "GEE"
    case goldCoast = "GCS"
    case gws = "GWS"
    case hawthorn = "HAW"
    case melbourne = "MEL"
    case northMelbourne = "NTH"
    case portAdelaide = "POR"
    case richmond = "RIC"
    case stKilda = "STK"
    case sydney = "SYD"
    case westCoast = "WCE"
    case westernBulldogs = "WBD"

    var displayName: String {
        switch self {
        case .adelaide: "Adelaide"
        case .brisbane: "Brisbane"
        case .carlton: "Carlton"
        case .collingwood: "Collingwood"
        case .essendon: "Essendon"
        case .fremantle: "Fremantle"
        case .geelong: "Geelong"
        case .goldCoast: "Gold Coast"
        case .gws: "GWS Giants"
        case .hawthorn: "Hawthorn"
        case .melbourne: "Melbourne"
        case .northMelbourne: "North Melbourne"
        case .portAdelaide: "Port Adelaide"
        case .richmond: "Richmond"
        case .stKilda: "St Kilda"
        case .sydney: "Sydney"
        case .westCoast: "West Coast"
        case .westernBulldogs: "Western Bulldogs"
        }
    }

    var primaryColor: Color {
        switch self {
        case .adelaide: Color(.systemRed)
        case .brisbane: Color(.systemOrange)
        case .carlton: Color(.systemBlue)
        case .collingwood: Color(.label)
        case .essendon: Color(.systemRed)
        case .fremantle: Color(.systemPurple)
        case .geelong: Color(.systemBlue)
        case .goldCoast: Color(.systemYellow)
        case .gws: Color(.systemOrange)
        case .hawthorn: Color(.systemBrown)
        case .melbourne: Color(.systemRed)
        case .northMelbourne: Color(.systemBlue)
        case .portAdelaide: Color(.systemTeal)
        case .richmond: Color(.systemYellow)
        case .stKilda: Color(.systemRed)
        case .sydney: Color(.systemRed)
        case .westCoast: Color(.systemBlue)
        case .westernBulldogs: Color(.systemRed)
        }
    }

    var emoji: String {
        switch self {
        case .adelaide: "🔴"
        case .brisbane: "🦁"
        case .carlton: "🔵"
        case .collingwood: "⚫"
        case .essendon: "🔴"
        case .fremantle: "⚓"
        case .geelong: "🐱"
        case .goldCoast: "☀️"
        case .gws: "🧡"
        case .hawthorn: "🦅"
        case .melbourne: "😈"
        case .northMelbourne: "🦘"
        case .portAdelaide: "⚡"
        case .richmond: "🐅"
        case .stKilda: "👼"
        case .sydney: "🦢"
        case .westCoast: "🦅"
        case .westernBulldogs: "🐕"
        }
    }
}

// MARK: - RiskLevel

enum RiskLevel: String, CaseIterable, Codable {
    case low
    case medium
    case high
    case critical

    var color: Color {
        switch self {
        case .low: .green
        case .medium: .yellow
        case .high: .orange
        case .critical: .red
        }
    }

    var displayName: String {
        switch self {
        case .low: "Low Risk"
        case .medium: "Medium Risk"
        case .high: "High Risk"
        case .critical: "Critical Risk"
        }
    }

    var icon: String {
        switch self {
        case .low: "checkmark.shield.fill"
        case .medium: "exclamationmark.shield.fill"
        case .high: "xmark.shield.fill"
        case .critical: "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - CaptainSuggestion

struct CaptainSuggestion: Identifiable, Codable, Hashable {
    let id = UUID()
    let player: AFLPlayer
    let confidence: Int
    let projectedPoints: Int
    let reasoning: [String]
    let riskFactors: [String]
    let upside: String
    let ownership: Double
    let opponent: String?
    let venue: String?

    var confidenceColor: Color {
        switch confidence {
        case 90 ... 100: .green
        case 75 ..< 90: .blue
        case 60 ..< 75: .orange
        default: .red
        }
    }
}

// MARK: - TradeAnalysis

struct TradeAnalysis: Identifiable, Codable, Hashable {
    let id = UUID()
    let playerOut: AFLPlayer
    let playerIn: AFLPlayer
    let netCost: Int
    let projectedPointsGain: Double
    let next3RoundsGain: Double
    let restOfSeasonGain: Double
    let valueGainPotential: Double
    let riskScore: Double
    let priority: TradePriority
    let reasoning: String
    let bestExecutionTime: Date?

    enum TradePriority: String, CaseIterable, Codable {
        case urgent
        case recommended
        case consider
        case hold

        var color: Color {
            switch self {
            case .urgent: .red
            case .recommended: .green
            case .consider: .orange
            case .hold: .gray
            }
        }

        var displayName: String {
            switch self {
            case .urgent: "Urgent"
            case .recommended: "Recommended"
            case .consider: "Consider"
            case .hold: "Hold"
            }
        }
    }
}

// MARK: - CashCow

struct CashCow: Identifiable, Codable, Hashable {
    let id = UUID()
    let player: AFLPlayer
    let purchasePrice: Int
    let currentValue: Int
    let projectedPeakValue: Int
    let projectedPeakDate: Date
    let cashGenerated: Int
    let sellRecommendation: SellRecommendation
    let weeksHeld: Int

    var cashGenerationRate: Double {
        guard weeksHeld > 0 else { return 0 }
        return Double(cashGenerated) / Double(weeksHeld)
    }

    var totalGrowthPercent: Double {
        guard purchasePrice > 0 else { return 0 }
        return Double(currentValue - purchasePrice) / Double(purchasePrice) * 100
    }

    enum SellRecommendation: String, CaseIterable, Codable {
        case hold
        case consider
        case sellSoon = "sell_soon"
        case sellNow = "sell_now"

        var color: Color {
            switch self {
            case .hold: .green
            case .consider: .yellow
            case .sellSoon: .orange
            case .sellNow: .red
            }
        }

        var displayName: String {
            switch self {
            case .hold: "Hold"
            case .consider: "Consider Selling"
            case .sellSoon: "Sell Soon"
            case .sellNow: "Sell Now"
            }
        }
    }
}

// MARK: - TeamAnalysis

struct TeamAnalysis: Codable, Hashable {
    let totalValue: Int
    let bankBalance: Int
    let projectedScore: Double
    let projectedRank: Int
    let premiumCount: Int
    let cashCowCount: Int
    let positionDistribution: [PlayerPosition: PositionAnalysis]
    let byeRoundCoverage: [Int: Int] // Round -> Player count
    let weakestPositions: [PlayerPosition]
    let upgradeTargets: [AFLPlayer]
    let riskExposure: RiskExposure

    struct PositionAnalysis: Codable, Hashable {
        let playerCount: Int
        let totalValue: Int
        let averageValue: Int
        let leagueAverageValue: Int
        let strengthRating: Double
    }

    struct RiskExposure: Codable, Hashable {
        let injuryRisk: Double
        let suspensionRisk: Double
        let priceDropRisk: Double
        let overallRisk: RiskLevel
    }
}
