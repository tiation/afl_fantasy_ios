import Foundation
import SwiftUI

// MARK: - EnhancedPlayer

/// Enhanced version of Player with additional computed properties and convenience methods
public struct EnhancedPlayer: Identifiable, Codable, Hashable {
    public let id: String
    public let player: Player

    // Additional enhanced properties
    public let premiumPotential: Double
    public let tradeInScore: Double
    public let tradeOutScore: Double
    public let captainScore: Double
    public let riskScore: Double
    public let valueScore: Double

    public init(
        player: Player,
        premiumPotential: Double = 0.5,
        tradeInScore: Double = 0.5,
        tradeOutScore: Double = 0.5,
        captainScore: Double = 0.5,
        riskScore: Double = 0.5,
        valueScore: Double = 0.5
    ) {
        id = player.id
        self.player = player
        self.premiumPotential = premiumPotential
        self.tradeInScore = tradeInScore
        self.tradeOutScore = tradeOutScore
        self.captainScore = captainScore
        self.riskScore = riskScore
        self.valueScore = valueScore
    }

    // Convenience accessors to Player properties
    public var name: String { player.name }
    public var position: Position { player.position }
    public var teamId: Int { player.teamId }
    public var teamName: String { player.teamName }
    public var currentPrice: Int { player.currentPrice }
    public var averageScore: Double { player.averageScore }
    public var consistency: Double { player.consistency }
    public var isActive: Bool { player.isActive }
    public var formattedPrice: String { player.formattedPrice }
    public var consistencyGrade: String { player.consistencyGrade }
}

// MARK: - CaptainSuggestion

public struct CaptainSuggestion: Identifiable, Codable, Hashable {
    public let id: UUID
    public let player: Player
    public let projectedScore: Double
    public let confidence: Double
    public let captaincy: Double
    public let reasoning: [String]
    public let riskFactors: [String]
    public let upside: String
    public let matchup: String
    public let venue: String
    public let weather: String?

    public init(
        player: Player,
        projectedScore: Double,
        confidence: Double,
        captaincy: Double,
        reasoning: [String] = [],
        riskFactors: [String] = [],
        upside: String = "",
        matchup: String = "",
        venue: String = "",
        weather: String? = nil
    ) {
        id = UUID()
        self.player = player
        self.projectedScore = projectedScore
        self.confidence = confidence
        self.captaincy = captaincy
        self.reasoning = reasoning
        self.riskFactors = riskFactors
        self.upside = upside
        self.matchup = matchup
        self.venue = venue
        self.weather = weather
    }
}

// MARK: - TradeAnalysis

public struct TradeAnalysis: Identifiable, Codable, Hashable {
    public let id: UUID
    public let tradeIn: Player
    public let tradeOut: Player
    public let scoreImprovement: Double
    public let priceChange: Int
    public let roi: Double
    public let confidence: Double
    public let recommendation: String
    public let reasoning: [String]
    public let risks: [String]
    public let opportunities: [String]
    public let timeframe: String

    // Additional properties for TradeAnalysisView
    public let netCost: Int
    public let warnings: [String]?

    public init(
        tradeIn: Player,
        tradeOut: Player,
        scoreImprovement: Double,
        priceChange: Int,
        roi: Double,
        confidence: Double,
        recommendation: String,
        reasoning: [String] = [],
        risks: [String] = [],
        opportunities: [String] = [],
        timeframe: String = "This round",
        netCost: Int = 0,
        warnings: [String]? = nil
    ) {
        id = UUID()
        self.tradeIn = tradeIn
        self.tradeOut = tradeOut
        self.scoreImprovement = scoreImprovement
        self.priceChange = priceChange
        self.roi = roi
        self.confidence = confidence
        self.recommendation = recommendation
        self.reasoning = reasoning
        self.risks = risks
        self.opportunities = opportunities
        self.timeframe = timeframe
        self.netCost = netCost
        self.warnings = warnings
    }

    // Computed properties for UI
    public var impactGrade: String {
        if scoreImprovement >= 15 { return "A+" }
        if scoreImprovement >= 10 { return "A" }
        if scoreImprovement >= 5 { return "B" }
        if scoreImprovement >= 0 { return "C" }
        return "D"
    }

    public var netCostFormatted: String {
        let absValue = abs(netCost)
        if absValue >= 1000 {
            return netCost < 0 ? "+$\(absValue / 1000)k" : "-$\(absValue / 1000)k"
        } else {
            return netCost < 0 ? "+$\(absValue)" : "-$\(absValue)"
        }
    }

    // Join reasoning array into single string for UI display
    public var reasoningText: String {
        reasoning.joined(separator: " ")
    }
}

// MARK: - TradeRecommendation

public struct TradeRecommendation: Identifiable, Codable, Hashable {
    public let id: UUID
    public let type: RecommendationType
    public let player: Player
    public let priority: RecommendationPriority
    public let reasoning: String
    public let expectedBenefit: String
    public let confidence: Double
    public let timeframe: String
    public let alternatives: [Player]

    public enum RecommendationType: String, Codable, CaseIterable {
        case buy = "Buy"
        case sell = "Sell"
        case hold = "Hold"
        case captain = "Captain"
        case avoid = "Avoid"
    }

    public init(
        type: RecommendationType,
        player: Player,
        priority: RecommendationPriority,
        reasoning: String,
        expectedBenefit: String,
        confidence: Double,
        timeframe: String = "This round",
        alternatives: [Player] = []
    ) {
        id = UUID()
        self.type = type
        self.player = player
        self.priority = priority
        self.reasoning = reasoning
        self.expectedBenefit = expectedBenefit
        self.confidence = confidence
        self.timeframe = timeframe
        self.alternatives = alternatives
    }
}

// MARK: - CashGenerationTarget

public struct CashGenerationTarget: Identifiable, Codable, Hashable {
    public let id: UUID
    public let player: Player
    public let currentValue: Int
    public let targetValue: Int
    public let projectedGain: Int
    public let weeksToTarget: Int
    public let confidence: Double
    public let riskLevel: RiskLevel
    public let strategy: String
    public let milestones: [Milestone]

    public struct Milestone: Codable, Hashable {
        public let week: Int
        public let expectedPrice: Int
        public let expectedScore: Double
        public let confidence: Double

        public init(week: Int, expectedPrice: Int, expectedScore: Double, confidence: Double) {
            self.week = week
            self.expectedPrice = expectedPrice
            self.expectedScore = expectedScore
            self.confidence = confidence
        }
    }

    public init(
        player: Player,
        currentValue: Int,
        targetValue: Int,
        projectedGain: Int,
        weeksToTarget: Int,
        confidence: Double,
        riskLevel: RiskLevel,
        strategy: String,
        milestones: [Milestone] = []
    ) {
        id = UUID()
        self.player = player
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.projectedGain = projectedGain
        self.weeksToTarget = weeksToTarget
        self.confidence = confidence
        self.riskLevel = riskLevel
        self.strategy = strategy
        self.milestones = milestones
    }
}

// MARK: - RiskAssessment

public struct RiskAssessment: Identifiable, Codable, Hashable {
    public let id: UUID
    public let player: Player
    public let overallRisk: RiskLevel
    public let injuryRisk: Double
    public let formRisk: Double
    public let priceRisk: Double
    public let fixtureRisk: Double
    public let factors: [String]
    public let mitigation: [String]
    public let lastUpdated: Date

    public init(
        player: Player,
        overallRisk: RiskLevel,
        injuryRisk: Double = 0.0,
        formRisk: Double = 0.0,
        priceRisk: Double = 0.0,
        fixtureRisk: Double = 0.0,
        factors: [String] = [],
        mitigation: [String] = []
    ) {
        id = UUID()
        self.player = player
        self.overallRisk = overallRisk
        self.injuryRisk = injuryRisk
        self.formRisk = formRisk
        self.priceRisk = priceRisk
        self.fixtureRisk = fixtureRisk
        self.factors = factors
        self.mitigation = mitigation
        lastUpdated = Date()
    }
}

// MARK: - AIRecommendation

public struct AIRecommendation: Identifiable, Codable, Hashable {
    public let id: UUID
    public let category: Category
    public let title: String
    public let description: String
    public let confidence: Double
    public let priority: RecommendationPriority
    public let actionItems: [String]
    public let relatedPlayers: [Player]
    public let createdAt: Date

    public enum Category: String, Codable, CaseIterable {
        case trade = "Trade"
        case captain = "Captain"
        case structure = "Structure"
        case risk = "Risk"
        case opportunity = "Opportunity"
        case general = "General"
    }

    public init(
        category: Category,
        title: String,
        description: String,
        confidence: Double,
        priority: RecommendationPriority,
        actionItems: [String] = [],
        relatedPlayers: [Player] = []
    ) {
        id = UUID()
        self.category = category
        self.title = title
        self.description = description
        self.confidence = confidence
        self.priority = priority
        self.actionItems = actionItems
        self.relatedPlayers = relatedPlayers
        createdAt = Date()
    }
}

// MARK: - PriceMovementPrediction

public struct PriceMovementPrediction: Identifiable, Codable, Hashable {
    public let id: UUID
    public let player: Player
    public let currentPrice: Int
    public let predictedPrice: Int
    public let priceChange: Int
    public let confidence: Double
    public let timeframe: String
    public let factors: [String]
    public let lastUpdated: Date

    public init(
        player: Player,
        currentPrice: Int,
        predictedPrice: Int,
        confidence: Double,
        timeframe: String = "Next round",
        factors: [String] = []
    ) {
        id = UUID()
        self.player = player
        self.currentPrice = currentPrice
        self.predictedPrice = predictedPrice
        priceChange = predictedPrice - currentPrice
        self.confidence = confidence
        self.timeframe = timeframe
        self.factors = factors
        lastUpdated = Date()
    }
}

// MARK: - TeamStructure

public struct TeamStructure: Codable, Hashable {
    public let overallGrade: StructureGrade
    public let positionGrades: [Position: StructureGrade]
    public let strengths: [String]
    public let weaknesses: [StructureWeakness]
    public let recommendations: [StructureRecommendation]
    public let budgetUtilization: Double
    public let riskProfile: RiskLevel

    public init(
        overallGrade: StructureGrade,
        positionGrades: [Position: StructureGrade],
        strengths: [String] = [],
        weaknesses: [StructureWeakness] = [],
        recommendations: [StructureRecommendation] = [],
        budgetUtilization: Double = 0.0,
        riskProfile: RiskLevel = .medium
    ) {
        self.overallGrade = overallGrade
        self.positionGrades = positionGrades
        self.strengths = strengths
        self.weaknesses = weaknesses
        self.recommendations = recommendations
        self.budgetUtilization = budgetUtilization
        self.riskProfile = riskProfile
    }
}

// MARK: - StructureGrade

public enum StructureGrade: String, Codable, CaseIterable {
    case excellent = "A+"
    case good = "A"
    case average = "B"
    case poor = "C"
    case terrible = "D"
}

// MARK: - PositionAllocation

public struct PositionAllocation: Codable, Hashable {
    public let position: Position
    public let playersCount: Int
    public let totalValue: Int
    public let averageScore: Double
    public let grade: StructureGrade
    public let isBalanced: Bool

    public init(
        position: Position,
        playersCount: Int,
        totalValue: Int,
        averageScore: Double,
        grade: StructureGrade,
        isBalanced: Bool
    ) {
        self.position = position
        self.playersCount = playersCount
        self.totalValue = totalValue
        self.averageScore = averageScore
        self.grade = grade
        self.isBalanced = isBalanced
    }
}

// MARK: - StructureWeakness

public struct StructureWeakness: Identifiable, Codable, Hashable {
    public let id: UUID
    public let position: Position?
    public let issue: String
    public let severity: RiskLevel
    public let suggestion: String

    public init(position: Position?, issue: String, severity: RiskLevel, suggestion: String) {
        id = UUID()
        self.position = position
        self.issue = issue
        self.severity = severity
        self.suggestion = suggestion
    }
}

// MARK: - StructureRecommendation

public struct StructureRecommendation: Identifiable, Codable, Hashable {
    public let id: UUID
    public let type: RecommendationType
    public let priority: RecommendationPriority
    public let description: String
    public let expectedBenefit: String
    public let estimatedCost: Int?

    public enum RecommendationType: String, Codable, CaseIterable {
        case upgrade = "Upgrade"
        case downgrade = "Downgrade"
        case rebalance = "Rebalance"
        case diversify = "Diversify"
    }

    public init(
        type: RecommendationType,
        priority: RecommendationPriority,
        description: String,
        expectedBenefit: String,
        estimatedCost: Int? = nil
    ) {
        id = UUID()
        self.type = type
        self.priority = priority
        self.description = description
        self.expectedBenefit = expectedBenefit
        self.estimatedCost = estimatedCost
    }
}

// MARK: - AFLPlayer

public struct AFLPlayer: Identifiable, Codable, Hashable {
    public let id: UUID
    public let name: String
    public let team: AFLTeam
    public let position: Position
    public let jerseyNumber: Int?
    public let averageScore: Double
    public let totalScore: Int
    public let gamesPlayed: Int

    public init(
        name: String,
        team: AFLTeam,
        position: Position,
        jerseyNumber: Int? = nil,
        averageScore: Double = 0.0,
        totalScore: Int = 0,
        gamesPlayed: Int = 0
    ) {
        id = UUID()
        self.name = name
        self.team = team
        self.position = position
        self.jerseyNumber = jerseyNumber
        self.averageScore = averageScore
        self.totalScore = totalScore
        self.gamesPlayed = gamesPlayed
    }
}

// MARK: - PerformanceMetrics

// Add missing supporting types that may be referenced
public struct PerformanceMetrics: Codable, Hashable {
    public let averageScore: Double
    public let consistency: Double
    public let ceiling: Double
    public let floor: Double
    public let lastFiveGames: [Double]

    public init(
        averageScore: Double = 0.0,
        consistency: Double = 0.0,
        ceiling: Double = 0.0,
        floor: Double = 0.0,
        lastFiveGames: [Double] = []
    ) {
        self.averageScore = averageScore
        self.consistency = consistency
        self.ceiling = ceiling
        self.floor = floor
        self.lastFiveGames = lastFiveGames
    }
}

// MARK: - PlayerStats

public struct PlayerStats: Codable, Hashable {
    public let playerId: String
    public let round: Int
    public let score: Int
    public let disposals: Int?
    public let marks: Int?
    public let goals: Int?
    public let behinds: Int?

    public init(
        playerId: String,
        round: Int,
        score: Int,
        disposals: Int? = nil,
        marks: Int? = nil,
        goals: Int? = nil,
        behinds: Int? = nil
    ) {
        self.playerId = playerId
        self.round = round
        self.score = score
        self.disposals = disposals
        self.marks = marks
        self.goals = goals
        self.behinds = behinds
    }
}

// MARK: - RiskAnalysis

public struct RiskAnalysis: Codable, Hashable {
    public let overallRisk: RiskLevel
    public let factors: [String]
    public let mitigations: [String]
    public let confidence: Double

    public init(
        overallRisk: RiskLevel = .medium,
        factors: [String] = [],
        mitigations: [String] = [],
        confidence: Double = 0.5
    ) {
        self.overallRisk = overallRisk
        self.factors = factors
        self.mitigations = mitigations
        self.confidence = confidence
    }
}
