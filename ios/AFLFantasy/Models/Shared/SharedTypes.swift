import Foundation
import SwiftUI

// MARK: - TabItem

public enum TabItem: String, CaseIterable, Identifiable {
    case dashboard
    case trades
    case captain
    case cashCow
    case settings

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .trades: "Trades"
        case .captain: "Captain AI"
        case .cashCow: "Cash Cows"
        case .settings: "Settings"
        }
    }

    public var systemImage: String {
        switch self {
        case .dashboard: "square.grid.2x2"
        case .trades: "arrow.2.squarepath"
        case .captain: "crown.fill"
        case .cashCow: "dollarsign.circle.fill"
        case .settings: "gearshape.fill"
        }
    }
}

// MARK: - PlayerSortOption

public enum PlayerSortOption: String, CaseIterable {
    case averageScore = "Average Score"
    case currentPrice = "Current Price"
    case name = "Name"
    case position = "Position"
    case ownership = "Ownership"

    public var id: String { rawValue }
}

// MARK: - RecommendationPriority

public enum RecommendationPriority: String, Codable, CaseIterable {
    case low
    case medium
    case high
    case critical

    public var color: Color {
        switch self {
        case .low: .green
        case .medium: .yellow
        case .high: .orange
        case .critical: .red
        }
    }
}

// MARK: - InjuryRisk

public struct InjuryRisk: Codable, Hashable {
    public let riskScore: Double
    public let severity: InjuryRiskLevel
    public let details: String?

    public init(riskScore: Double, severity: InjuryRiskLevel, details: String? = nil) {
        self.riskScore = riskScore
        self.severity = severity
        self.details = details
    }
}

// MARK: - InjuryRiskLevel

public enum InjuryRiskLevel: String, Codable, CaseIterable {
    case low
    case medium
    case high
    case critical
    
    public var color: Color {
        switch self {
        case .low: .green
        case .medium: .yellow
        case .high: .orange
        case .critical: .red
        }
    }
}

// MARK: - RoundProjection

public struct RoundProjection: Codable, Hashable {
    public let predictedScore: Double
    public let confidence: Double
    public let upside: Double
    public let downside: Double
    public let venue: String?
    public let opponent: String?

    public init(
        predictedScore: Double,
        confidence: Double,
        upside: Double,
        downside: Double,
        venue: String? = nil,
        opponent: String? = nil
    ) {
        self.predictedScore = predictedScore
        self.confidence = confidence
        self.upside = upside
        self.downside = downside
        self.venue = venue
        self.opponent = opponent
    }
}

// MARK: - SeasonProjection

public struct SeasonProjection: Codable, Hashable {
    public let projectedAverage: Double
    public let projectedTotal: Double
    public let breakEvenRounds: Int
    public let peakRounds: [Int]

    public init(projectedAverage: Double, projectedTotal: Double, breakEvenRounds: Int, peakRounds: [Int]) {
        self.projectedAverage = projectedAverage
        self.projectedTotal = projectedTotal
        self.breakEvenRounds = breakEvenRounds
        self.peakRounds = peakRounds
    }
}

// MARK: - VenuePerformance

public struct VenuePerformance: Codable, Hashable {
    public let venue: String
    public let averageScore: Double
    public let gamesPlayed: Int
    public let lastPlayedRound: Int?

    public init(venue: String, averageScore: Double, gamesPlayed: Int, lastPlayedRound: Int? = nil) {
        self.venue = venue
        self.averageScore = averageScore
        self.gamesPlayed = gamesPlayed
        self.lastPlayedRound = lastPlayedRound
    }
}

// MARK: - AlertFlag

public struct AlertFlag: Codable, Hashable {
    public let type: AlertType
    public let priority: RecommendationPriority
    public let message: String
    public let triggeredAt: Date

    public init(type: AlertType, priority: RecommendationPriority, message: String, triggeredAt: Date = Date()) {
        self.type = type
        self.priority = priority
        self.message = message
        self.triggeredAt = triggeredAt
    }
}

// MARK: - AlertType

public enum AlertType: String, Codable, CaseIterable {
    case priceRise
    case priceFall
    case injuryUpdate
    case teamNews
    case premiumBreakout
    case cashCowPeak
    case form
    case fixture
}

// MARK: - WeatherConditions

public struct WeatherConditions: Codable, Hashable {
    public let temperature: Double
    public let humidity: Double
    public let windSpeed: Double
    public let precipitation: Double
    public let conditions: String

    public init(temperature: Double, humidity: Double, windSpeed: Double, precipitation: Double, conditions: String) {
        self.temperature = temperature
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.precipitation = precipitation
        self.conditions = conditions
    }
}

// MARK: - FixtureAnalysis

public struct FixtureAnalysis: Codable, Hashable {
    public let difficulty: Double
    public let venue: String
    public let opponent: String
    public let historicalPerformance: Double
    public let weatherImpact: Double?

    public init(
        difficulty: Double,
        venue: String,
        opponent: String,
        historicalPerformance: Double,
        weatherImpact: Double? = nil
    ) {
        self.difficulty = difficulty
        self.venue = venue
        self.opponent = opponent
        self.historicalPerformance = historicalPerformance
        self.weatherImpact = weatherImpact
    }
}

// MARK: - TradeAnalysisResult

public struct TradeAnalysisResult: Codable, Hashable {
    public let playerIn: String
    public let playerOut: String
    public let netGain: Double
    public let riskLevel: RecommendationPriority
    public let confidence: Double
    public let reasoning: String

    public init(
        playerIn: String,
        playerOut: String,
        netGain: Double,
        riskLevel: RecommendationPriority,
        confidence: Double,
        reasoning: String
    ) {
        self.playerIn = playerIn
        self.playerOut = playerOut
        self.netGain = netGain
        self.riskLevel = riskLevel
        self.confidence = confidence
        self.reasoning = reasoning
    }
}

// MARK: - CashCowAnalysis

public struct CashCowAnalysis: Codable, Hashable {
    public let playerId: String
    public let currentValue: Double
    public let peakValue: Double
    public let sellWindow: SellWindow
    public let recommendation: String

    public init(
        playerId: String,
        currentValue: Double,
        peakValue: Double,
        sellWindow: SellWindow,
        recommendation: String
    ) {
        self.playerId = playerId
        self.currentValue = currentValue
        self.peakValue = peakValue
        self.sellWindow = sellWindow
        self.recommendation = recommendation
    }
}

// MARK: - SellWindow

public struct SellWindow: Codable, Hashable {
    public let startRound: Int
    public let endRound: Int
    public let optimalRound: Int

    public init(startRound: Int, endRound: Int, optimalRound: Int) {
        self.startRound = startRound
        self.endRound = endRound
        self.optimalRound = optimalRound
    }
}

// MARK: - CashCowRecommendation

public struct CashCowRecommendation: Codable, Hashable {
    public let player: String
    public let action: CashCowAction
    public let timing: SellWindow
    public let expectedReturn: Double
    public let confidence: Double

    public init(player: String, action: CashCowAction, timing: SellWindow, expectedReturn: Double, confidence: Double) {
        self.player = player
        self.action = action
        self.timing = timing
        self.expectedReturn = expectedReturn
        self.confidence = confidence
    }
}

// MARK: - CashCowAction

public enum CashCowAction: String, Codable, CaseIterable {
    case hold
    case sell
    case monitor
}

// MARK: - PriceProjection

public struct PriceProjection: Codable, Hashable {
    public let currentPrice: Double
    public let projectedPrice: Double
    public let priceChange: Double
    public let confidence: Double

    public init(currentPrice: Double, projectedPrice: Double, priceChange: Double, confidence: Double) {
        self.currentPrice = currentPrice
        self.projectedPrice = projectedPrice
        self.priceChange = priceChange
        self.confidence = confidence
    }
}

// MARK: - TeamAnalytics

public struct TeamAnalytics: Codable, Hashable {
    public let teamId: String
    public let averageScore: Double
    public let consistency: Double
    public let form: Double
    public let injuryCount: Int

    public init(teamId: String, averageScore: Double, consistency: Double, form: Double, injuryCount: Int) {
        self.teamId = teamId
        self.averageScore = averageScore
        self.consistency = consistency
        self.form = form
        self.injuryCount = injuryCount
    }
}

// MARK: - TradeImpact

public struct TradeImpact: Codable, Hashable {
    public let totalScoreChange: Double
    public let bankChange: Double
    public let structureImprovement: Double
    public let riskIncrease: Double

    public init(totalScoreChange: Double, bankChange: Double, structureImprovement: Double, riskIncrease: Double) {
        self.totalScoreChange = totalScoreChange
        self.bankChange = bankChange
        self.structureImprovement = structureImprovement
        self.riskIncrease = riskIncrease
    }
}

// MARK: - TradeRisk

public struct TradeRisk: Codable, Hashable {
    public let riskLevel: RecommendationPriority
    public let factors: [String]
    public let mitigation: String

    public init(riskLevel: RecommendationPriority, factors: [String], mitigation: String) {
        self.riskLevel = riskLevel
        self.factors = factors
        self.mitigation = mitigation
    }
}

// MARK: - TradeOpportunity

public struct TradeOpportunity: Codable, Hashable {
    public let playerIn: String
    public let playerOut: String
    public let expectedValue: Double
    public let timeFrame: String

    public init(playerIn: String, playerOut: String, expectedValue: Double, timeFrame: String) {
        self.playerIn = playerIn
        self.playerOut = playerOut
        self.expectedValue = expectedValue
        self.timeFrame = timeFrame
    }
}

// MARK: - CaptainData

public struct CaptainData: Codable, Hashable {
    public let player: String
    public let projectedScore: Double
    public let captaincy: Double
    public let form: Double
    public let fixture: Double

    public init(player: String, projectedScore: Double, captaincy: Double, form: Double, fixture: Double) {
        self.player = player
        self.projectedScore = projectedScore
        self.captaincy = captaincy
        self.form = form
        self.fixture = fixture
    }
}

// MARK: - TradeRecord

public struct TradeRecord: Codable, Hashable {
    public let playerIn: String
    public let playerOut: String
    public let round: Int
    public let value: Double
    public let success: Bool

    public init(playerIn: String, playerOut: String, round: Int, value: Double, success: Bool) {
        self.playerIn = playerIn
        self.playerOut = playerOut
        self.round = round
        self.value = value
        self.success = success
    }
}

// MARK: - CachedDataEntity

public struct CachedDataEntity: Codable, Hashable {
    public let id: String
    public let data: Data
    public let timestamp: Date
    public let expiryDate: Date

    public init(id: String, data: Data, timestamp: Date = Date(), expiryDate: Date) {
        self.id = id
        self.data = data
        self.timestamp = timestamp
        self.expiryDate = expiryDate
    }
}
