//
//  AFLDataModels.swift
//  AFL Fantasy Intelligence Platform
//
//  Comprehensive data models for advanced AFL Fantasy analytics
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import SwiftUI

// MARK: - Enhanced Player Model

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
        return "$\(Double(currentPrice) / 1000, specifier: "%.1f")k"
    }
    
    var priceChangeText: String {
        let prefix = priceChange >= 0 ? "+" : ""
        return "\(prefix)\(priceChange)"
    }
    
    var consistencyGrade: String {
        switch consistency {
        case 90...: return "A+"
        case 80..<90: return "A"
        case 70..<80: return "B"
        case 60..<70: return "C"
        default: return "D"
        }
    }
}

// MARK: - Venue Performance Analysis

struct VenuePerformance: Identifiable, Codable {
    let id = UUID()
    let venueName: String
    let venueId: Int
    let gamesPlayed: Int
    let averageScore: Double
    let bias: Double // -10 to +10, negative = underperforms
    let significance: BiasSignificance
}

enum BiasSignificance: String, CaseIterable, Codable {
    case extreme = "Extreme"
    case strong = "Strong"
    case moderate = "Moderate"
    case weak = "Weak"
    case none = "None"
    
    var color: Color {
        switch self {
        case .extreme: return .red
        case .strong: return .orange
        case .moderate: return .yellow
        case .weak: return .blue
        case .none: return .gray
        }
    }
}

// MARK: - Opponent Performance Analysis

struct OpponentPerformance: Identifiable, Codable {
    let id = UUID()
    let opponentTeam: String
    let opponentId: Int
    let gamesPlayed: Int
    let averageScore: Double
    let conceded: Double // points this opponent typically gives up to this position
    let dvpRanking: Int // 1-18 ranking for Defense vs Position
}

// MARK: - Injury Risk Assessment

struct InjuryRisk: Codable {
    let riskLevel: RiskLevel
    let riskScore: Double // 0-100
    let injuryHistory: [InjuryRecord]
    let recoveryTime: Int? // weeks if currently injured
    let reinjuryProbability: Double
}

enum RiskLevel: String, CaseIterable, Codable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case extreme = "Extreme"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .moderate: return .yellow
        case .high: return .orange
        case .extreme: return .red
        }
    }
}

struct InjuryRecord: Identifiable, Codable {
    let id = UUID()
    let injuryType: String
    let weeksOut: Int
    let season: Int
    let round: Int
}

// MARK: - Contract Status

struct ContractStatus: Codable {
    let contractYear: Bool
    let yearsRemaining: Int
    let motivationBonus: Double // performance boost factor
    let tradeable: Bool
}

// MARK: - Seasonal Performance Trends

struct SeasonalTrend: Codable {
    let earlySeasonAvg: Double // rounds 1-6
    let midSeasonAvg: Double // rounds 7-15
    let lateSeasonAvg: Double // rounds 16-23
    let finalsAvg: Double // finals only
    let trendDirection: TrendDirection
    let fadeRisk: Double // probability of late season fade
}

enum TrendDirection: String, CaseIterable, Codable {
    case improving = "Improving"
    case stable = "Stable"
    case declining = "Declining"
    case volatile = "Volatile"
}

// MARK: - Round Projections

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

struct MatchConditions: Codable {
    let temperature: Int
    let windSpeed: Int
    let rainProbability: Double
    let travelDistance: Int // km traveled
    let daysRest: Int
}

// MARK: - Season Projection

struct SeasonProjection: Codable {
    let totalProjectedScore: Int
    let averageProjectedScore: Double
    let finalPrice: Int
    let totalPriceRise: Int
    let breakEvenRounds: Int
    let premiumPotential: Double // 0-100 probability of becoming premium
}

// MARK: - Alert System

struct AlertFlag: Identifiable, Codable {
    let id = UUID()
    let type: AlertType
    let priority: AlertPriority
    let title: String
    let message: String
    let timestamp: Date
    let actionRequired: Bool
}

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

enum AlertPriority: String, CaseIterable, Codable {
    case critical = "Critical"
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    var color: Color {
        switch self {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        }
    }
}

// MARK: - Team Structure Analysis

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

enum StructureGrade: String, CaseIterable, Codable {
    case excellent = "A+"
    case veryGood = "A"
    case good = "B"
    case average = "C"
    case poor = "D"
    case veryPoor = "F"
    
    var color: Color {
        switch self {
        case .excellent: return .green
        case .veryGood: return .mint
        case .good: return .blue
        case .average: return .yellow
        case .poor: return .orange
        case .veryPoor: return .red
        }
    }
}

struct StructureWeakness: Identifiable, Codable {
    let id = UUID()
    let issue: String
    let severity: WeaknessSeverity
    let impact: String
}

enum WeaknessSeverity: String, CaseIterable, Codable {
    case critical = "Critical"
    case major = "Major"
    case minor = "Minor"
    
    var color: Color {
        switch self {
        case .critical: return .red
        case .major: return .orange
        case .minor: return .yellow
        }
    }
}

struct StructureRecommendation: Identifiable, Codable {
    let id = UUID()
    let action: String
    let priority: RecommendationPriority
    let expectedImprovement: String
    let cost: Int?
}

enum RecommendationPriority: String, CaseIterable, Codable {
    case urgent = "Urgent"
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}

// MARK: - Fixture Analysis

struct FixtureDifficulty: Identifiable, Codable {
    let id = UUID()
    let teamName: String
    let teamId: Int
    let nextFiveRounds: [FixtureRound]
    let difficultyRating: DifficultyRating
    let averageDVP: Double
    let travelLoad: TravelLoad
}

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

enum DifficultyRating: String, CaseIterable, Codable {
    case veryEasy = "Very Easy"
    case easy = "Easy"
    case moderate = "Moderate"
    case hard = "Hard"
    case veryHard = "Very Hard"
    
    var color: Color {
        switch self {
        case .veryEasy: return .green
        case .easy: return .mint
        case .moderate: return .yellow
        case .hard: return .orange
        case .veryHard: return .red
        }
    }
}

enum TravelLoad: String, CaseIterable, Codable {
    case light = "Light"
    case moderate = "Moderate"
    case heavy = "Heavy"
    case extreme = "Extreme"
}

// MARK: - Trade Analysis

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

struct TradeImpact: Codable {
    let pointsGained: Double
    let priceGained: Int
    let riskAdjustedValue: Double
}

struct TradeRisk: Identifiable, Codable {
    let id = UUID()
    let risk: String
    let probability: Double
    let impact: RiskImpact
}

enum RiskImpact: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case severe = "Severe"
}

struct TradeOpportunity: Identifiable, Codable {
    let id = UUID()
    let opportunity: String
    let likelihood: Double
    let benefit: String
}

enum TradeRecommendation: String, CaseIterable, Codable {
    case strongBuy = "Strong Buy"
    case buy = "Buy"
    case hold = "Hold"
    case sell = "Sell"
    case strongSell = "Strong Sell"
    
    var color: Color {
        switch self {
        case .strongBuy: return .green
        case .buy: return .mint
        case .hold: return .yellow
        case .sell: return .orange
        case .strongSell: return .red
        }
    }
}

// MARK: - Bye Round Analysis

struct ByeRoundAnalysis: Codable {
    let round: Int
    let playersOnBye: [String]
    let emergencyPlayers: [String]
    let projectedScore: Int
    let coverageRating: CoverageRating
    let recommendations: [ByeRecommendation]
}

enum CoverageRating: String, CaseIterable, Codable {
    case excellent = "Excellent"
    case good = "Good"
    case adequate = "Adequate"
    case poor = "Poor"
    case critical = "Critical"
    
    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .mint
        case .adequate: return .yellow
        case .poor: return .orange
        case .critical: return .red
        }
    }
}

struct ByeRecommendation: Identifiable, Codable {
    let id = UUID()
    let action: String
    let urgency: RecommendationPriority
    let impact: String
}

// MARK: - Cash Cow Analysis

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

struct SellWindow: Codable {
    let optimalRound: Int
    let earliestRound: Int
    let latestRound: Int
    let confidence: Double
}

enum CashCowRecommendation: String, CaseIterable, Codable {
    case sellNow = "Sell Now"
    case sellSoon = "Sell Soon"
    case hold = "Hold"
    case keepLongTerm = "Keep Long-term"
    
    var color: Color {
        switch self {
        case .sellNow: return .red
        case .sellSoon: return .orange
        case .hold: return .yellow
        case .keepLongTerm: return .green
        }
    }
}
