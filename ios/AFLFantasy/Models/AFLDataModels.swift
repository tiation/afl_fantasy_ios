//
//  AFLDataModels.swift
//  AFL Fantasy Intelligence Platform
//
//  Comprehensive data models for advanced AFL Fantasy analytics
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import SwiftUI

// MARK: - Player

struct Player: Identifiable, Codable {
    let id = UUID()
    let name: String
    let position: Position
    let teamId: Int
    let teamName: String
    let teamAbbreviation: String

    // Pricing & Economics
    let currentPrice: Int
    let startingPrice: Int
    let priceChange: Int
    let breakeven: Int
    let priceChangeProbability: Double
    let cashGenerated: Int
    let valueGain: Int

    // Performance Metrics
    let currentScore: Int
    let averageScore: Double
    let totalScore: Int
    let gamesPlayed: Int
    let consistency: Double // 0-100 score for reliability
    let ceiling: Int // highest score this season
    let floor: Int // lowest score this season
    let volatility: Double // standard deviation of scores

    // Advanced Analytics
    let venuePerformance: [VenuePerformance]
    let opponentPerformance: [OpponentPerformance]
    let injuryRisk: InjuryRisk
    let contractStatus: ContractStatus
    let seasonalTrend: SeasonalTrend

    // Future Projections
    let nextRoundProjection: RoundProjection
    let threeRoundProjection: [RoundProjection]
    let seasonProjection: SeasonProjection

    // Flags & Alerts
    let isInjured: Bool
    let isDoubtful: Bool
    let isCaptainRecommended: Bool
    let isTradeTarget: Bool
    let isCashCow: Bool
    let alertFlags: [AlertFlag]

    var formattedPrice: String {
        "$\(Double(currentPrice) / 1000, specifier: "%.1f")k"
    }

    var priceChangeText: String {
        let prefix = priceChange >= 0 ? "+" : ""
        return "\(prefix)\(priceChange)"
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
}

// MARK: - VenuePerformance

struct VenuePerformance: Identifiable, Codable {
    let id = UUID()
    let venueName: String
    let venueId: Int
    let gamesPlayed: Int
    let averageScore: Double
    let bias: Double // -10 to +10, negative = underperforms
    let significance: BiasSignificance
}

// MARK: - BiasSignificance

enum BiasSignificance: String, CaseIterable, Codable {
    case extreme = "Extreme"
    case strong = "Strong"
    case moderate = "Moderate"
    case weak = "Weak"
    case none = "None"

    var color: Color {
        switch self {
        case .extreme: .red
        case .strong: .orange
        case .moderate: .yellow
        case .weak: .blue
        case .none: .gray
        }
    }
}

// MARK: - OpponentPerformance

struct OpponentPerformance: Identifiable, Codable {
    let id = UUID()
    let opponentTeam: String
    let opponentId: Int
    let gamesPlayed: Int
    let averageScore: Double
    let conceded: Double // points this opponent typically gives up to this position
    let dvpRanking: Int // 1-18 ranking for Defense vs Position
}

// MARK: - InjuryRisk

struct InjuryRisk: Codable {
    let riskLevel: RiskLevel
    let riskScore: Double // 0-100
    let injuryHistory: [InjuryRecord]
    let recoveryTime: Int? // weeks if currently injured
    let reinjuryProbability: Double
}

// MARK: - RiskLevel

enum RiskLevel: String, CaseIterable, Codable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case extreme = "Extreme"

    var color: Color {
        switch self {
        case .low: .green
        case .moderate: .yellow
        case .high: .orange
        case .extreme: .red
        }
    }
}

// MARK: - InjuryRecord

struct InjuryRecord: Identifiable, Codable {
    let id = UUID()
    let injuryType: String
    let weeksOut: Int
    let season: Int
    let round: Int
}

// MARK: - ContractStatus

struct ContractStatus: Codable {
    let contractYear: Bool
    let yearsRemaining: Int
    let motivationBonus: Double // performance boost factor
    let tradeable: Bool
}

// MARK: - SeasonalTrend

struct SeasonalTrend: Codable {
    let earlySeasonAvg: Double // rounds 1-6
    let midSeasonAvg: Double // rounds 7-15
    let lateSeasonAvg: Double // rounds 16-23
    let finalsAvg: Double // finals only
    let trendDirection: TrendDirection
    let fadeRisk: Double // probability of late season fade
}

// MARK: - TrendDirection

enum TrendDirection: String, CaseIterable, Codable {
    case improving = "Improving"
    case stable = "Stable"
    case declining = "Declining"
    case volatile = "Volatile"
}

// MARK: - RoundProjection

struct RoundProjection: Identifiable, Codable {
    let id = UUID()
    let round: Int
    let projectedScore: Double
    let confidence: Double // 0-100
    let priceChange: Int
    let breakeven: Int
    let opponent: String
    let venue: String
    let conditions: MatchConditions
}

// MARK: - MatchConditions

struct MatchConditions: Codable {
    let temperature: Int
    let windSpeed: Int
    let rainProbability: Double
    let travelDistance: Int // km traveled
    let daysRest: Int
}

// MARK: - SeasonProjection

struct SeasonProjection: Codable {
    let totalProjectedScore: Int
    let averageProjectedScore: Double
    let finalPrice: Int
    let totalPriceRise: Int
    let breakEvenRounds: Int
    let premiumPotential: Double // 0-100 probability of becoming premium
}

// MARK: - AlertFlag

struct AlertFlag: Identifiable, Codable {
    let id = UUID()
    let type: AlertType
    let priority: AlertPriority
    let title: String
    let message: String
    let timestamp: Date
    let actionRequired: Bool
}

// MARK: - AlertType

enum AlertType: String, CaseIterable, Codable {
    case priceRise = "Price Rise"
    case priceDrop = "Price Drop"
    case injuryRisk = "Injury Risk"
    case breakEvenCliff = "Breakeven Cliff"
    case cashCowSell = "Cash Cow Sell"
    case tradeOpportunity = "Trade Opportunity"
    case captainRecommendation = "Captain Recommendation"
    case byeRoundWarning = "Bye Round Warning"
    case roleChange = "Role Change"
    case weatherRisk = "Weather Risk"
}

// MARK: - AlertPriority

enum AlertPriority: String, CaseIterable, Codable {
    case critical = "Critical"
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var color: Color {
        switch self {
        case .critical: .red
        case .high: .orange
        case .medium: .yellow
        case .low: .blue
        }
    }
}

// MARK: - TeamStructure

struct TeamStructure: Identifiable, Codable {
    let id = UUID()
    let totalSalaryCap: Int
    let usedSalaryCap: Int
    let remainingCap: Int
    let capUtilization: Double

    let defenderAllocation: PositionAllocation
    let midfielderAllocation: PositionAllocation
    let ruckAllocation: PositionAllocation
    let forwardAllocation: PositionAllocation

    let structureGrade: StructureGrade
    let weaknesses: [StructureWeakness]
    let recommendations: [StructureRecommendation]
}

// MARK: - PositionAllocation

struct PositionAllocation: Codable {
    let position: Position
    let playersCount: Int
    let totalValue: Int
    let averageValue: Int
    let allocation: Double // percentage of cap
    let benchStrength: Double
    let upgradeTargets: [String]
    let downgradeTargets: [String]
}

// MARK: - StructureGrade

enum StructureGrade: String, CaseIterable, Codable {
    case excellent = "A+"
    case veryGood = "A"
    case good = "B"
    case average = "C"
    case poor = "D"
    case veryPoor = "F"

    var color: Color {
        switch self {
        case .excellent: .green
        case .veryGood: .mint
        case .good: .blue
        case .average: .yellow
        case .poor: .orange
        case .veryPoor: .red
        }
    }
}

// MARK: - StructureWeakness

struct StructureWeakness: Identifiable, Codable {
    let id = UUID()
    let issue: String
    let severity: WeaknessSeverity
    let impact: String
}

// MARK: - WeaknessSeverity

enum WeaknessSeverity: String, CaseIterable, Codable {
    case critical = "Critical"
    case major = "Major"
    case minor = "Minor"

    var color: Color {
        switch self {
        case .critical: .red
        case .major: .orange
        case .minor: .yellow
        }
    }
}

// MARK: - StructureRecommendation

struct StructureRecommendation: Identifiable, Codable {
    let id = UUID()
    let action: String
    let priority: RecommendationPriority
    let expectedImprovement: String
    let cost: Int?
}

// MARK: - RecommendationPriority

enum RecommendationPriority: String, CaseIterable, Codable {
    case urgent = "Urgent"
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}

// MARK: - FixtureDifficulty

struct FixtureDifficulty: Identifiable, Codable {
    let id = UUID()
    let teamName: String
    let teamId: Int
    let nextFiveRounds: [FixtureRound]
    let difficultyRating: DifficultyRating
    let averageDVP: Double
    let travelLoad: TravelLoad
}

// MARK: - FixtureRound

struct FixtureRound: Identifiable, Codable {
    let id = UUID()
    let round: Int
    let opponent: String
    let venue: String
    let difficulty: Int // 1-5 scale
    let dvpRanking: Int
    let isHome: Bool
    let travelDistance: Int
}

// MARK: - DifficultyRating

enum DifficultyRating: String, CaseIterable, Codable {
    case veryEasy = "Very Easy"
    case easy = "Easy"
    case moderate = "Moderate"
    case hard = "Hard"
    case veryHard = "Very Hard"

    var color: Color {
        switch self {
        case .veryEasy: .green
        case .easy: .mint
        case .moderate: .yellow
        case .hard: .orange
        case .veryHard: .red
        }
    }
}

// MARK: - TravelLoad

enum TravelLoad: String, CaseIterable, Codable {
    case light = "Light"
    case moderate = "Moderate"
    case heavy = "Heavy"
    case extreme = "Extreme"
}

// MARK: - TradeAnalysis

struct TradeAnalysis: Identifiable, Codable {
    let id = UUID()
    let playerOut: Player
    let playerIn: Player
    let costDifference: Int
    let tradeScore: Double // 0-100 overall trade rating

    let nextRoundImpact: TradeImpact
    let threeRoundImpact: TradeImpact
    let seasonImpact: TradeImpact

    let risks: [TradeRisk]
    let opportunities: [TradeOpportunity]
    let recommendation: TradeRecommendation
}

// MARK: - TradeImpact

struct TradeImpact: Codable {
    let pointsGained: Double
    let priceGained: Int
    let riskAdjustedValue: Double
}

// MARK: - TradeRisk

struct TradeRisk: Identifiable, Codable {
    let id = UUID()
    let risk: String
    let probability: Double
    let impact: RiskImpact
}

// MARK: - RiskImpact

enum RiskImpact: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case severe = "Severe"
}

// MARK: - TradeOpportunity

struct TradeOpportunity: Identifiable, Codable {
    let id = UUID()
    let opportunity: String
    let likelihood: Double
    let benefit: String
}

// MARK: - TradeRecommendation

enum TradeRecommendation: String, CaseIterable, Codable {
    case strongBuy = "Strong Buy"
    case buy = "Buy"
    case hold = "Hold"
    case sell = "Sell"
    case strongSell = "Strong Sell"

    var color: Color {
        switch self {
        case .strongBuy: .green
        case .buy: .mint
        case .hold: .yellow
        case .sell: .orange
        case .strongSell: .red
        }
    }
}

// MARK: - ByeRoundAnalysis

struct ByeRoundAnalysis: Codable {
    let round: Int
    let playersOnBye: [String]
    let emergencyPlayers: [String]
    let projectedScore: Int
    let coverageRating: CoverageRating
    let recommendations: [ByeRecommendation]
}

// MARK: - CoverageRating

enum CoverageRating: String, CaseIterable, Codable {
    case excellent = "Excellent"
    case good = "Good"
    case adequate = "Adequate"
    case poor = "Poor"
    case critical = "Critical"

    var color: Color {
        switch self {
        case .excellent: .green
        case .good: .mint
        case .adequate: .yellow
        case .poor: .orange
        case .critical: .red
        }
    }
}

// MARK: - ByeRecommendation

struct ByeRecommendation: Identifiable, Codable {
    let id = UUID()
    let action: String
    let urgency: RecommendationPriority
    let impact: String
}

// MARK: - CashCowAnalysis

struct CashCowAnalysis: Identifiable, Codable {
    let id = UUID()
    let player: Player
    let cashGenerated: Int
    let projectedFinalPrice: Int
    let totalGainPotential: Int
    let sellWindow: SellWindow
    let holdRisk: Double
    let sellRecommendation: CashCowRecommendation
}

// MARK: - SellWindow

struct SellWindow: Codable {
    let optimalRound: Int
    let earliestRound: Int
    let latestRound: Int
    let confidence: Double
}

// MARK: - CashCowRecommendation

enum CashCowRecommendation: String, CaseIterable, Codable {
    case sellNow = "Sell Now"
    case sellSoon = "Sell Soon"
    case hold = "Hold"
    case keepLongTerm = "Keep Long-term"

    var color: Color {
        switch self {
        case .sellNow: .red
        case .sellSoon: .orange
        case .hold: .yellow
        case .keepLongTerm: .green
        }
    }
}
