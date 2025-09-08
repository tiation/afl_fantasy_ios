import Foundation

// MARK: - DashboardData

public struct DashboardData: Codable, Identifiable, Hashable {
    public let id = UUID()
    public let team: TeamData
    public let summary: DashboardSummary
    public let playerStats: [PlayerStats]
    public let captainChoice: CaptainChoice?
    public let matches: [Match]
    public let lastUpdated: Date

    public init(
        team: TeamData,
        summary: DashboardSummary,
        playerStats: [PlayerStats],
        captainChoice: CaptainChoice? = nil,
        matches: [Match],
        lastUpdated: Date
    ) {
        self.team = team
        self.summary = summary
        self.playerStats = playerStats
        self.captainChoice = captainChoice
        self.matches = matches
        self.lastUpdated = lastUpdated
    }

    public struct DashboardSummary: Codable, Hashable {
        public let totalPoints: Int
        public let rank: Int
        public let lastRoundPoints: Int
        public let valueChange: Int

        public init(totalPoints: Int, rank: Int, lastRoundPoints: Int, valueChange: Int) {
            self.totalPoints = totalPoints
            self.rank = rank
            self.lastRoundPoints = lastRoundPoints
            self.valueChange = valueChange
        }
    }

    public struct CaptainChoice: Codable, Hashable {
        public let captain: Player
        public var viceCaptain: Player

        public init(captain: Player, viceCaptain: Player) {
            self.captain = captain
            self.viceCaptain = viceCaptain
        }
    }

    public struct Captain: Codable, Hashable {
        public let playerId: String
        public let role: CaptainRole
        public let points: Int
        public let projectedPoints: Int

        public init(playerId: String, role: CaptainRole, points: Int, projectedPoints: Int) {
            self.playerId = playerId
            self.role = role
            self.points = points
            self.projectedPoints = projectedPoints
        }

        public enum CaptainRole: String, Codable, Hashable {
            case captain
            case viceCaptain
        }
    }
}

// MARK: - RiskAssessment

public struct RiskAssessment: Codable, Identifiable, Hashable {
    public let id = UUID()
    public let risk: RiskLevel
    public let confidence: Double
    public let factors: [RiskFactor]
    public let recommendations: [String]

    public init(risk: RiskLevel, confidence: Double, factors: [RiskFactor], recommendations: [String]) {
        self.risk = risk
        self.confidence = confidence
        self.factors = factors
        self.recommendations = recommendations
    }

    public enum RiskLevel: String, Codable, Hashable {
        case low
        case medium
        case high
        case extreme
    }

    public struct RiskFactor: Codable, Hashable {
        public let description: String
        public let weight: Double

        public init(description: String, weight: Double) {
            self.description = description
            self.weight = weight
        }
    }
}

// MARK: - AIRecommendation

public struct AIRecommendation: Codable, Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let confidence: Double
    public let category: RecommendationType
    public let priority: Priority
    public let actionSteps: [String]
    public let projectedImpact: Impact

    public init(
        title: String,
        description: String,
        confidence: Double,
        category: RecommendationType,
        priority: Priority,
        actionSteps: [String],
        projectedImpact: Impact
    ) {
        self.title = title
        self.description = description
        self.confidence = confidence
        self.category = category
        self.priority = priority
        self.actionSteps = actionSteps
        self.projectedImpact = projectedImpact
    }

    public enum RecommendationType: String, Codable, Hashable {
        case trade
        case captain
        case strategy
        case riskManagement
        case teamStructure
    }

    public enum Priority: String, Codable, Hashable {
        case high
        case medium
        case low
    }

    public struct Impact: Codable, Hashable {
        public let points: Int
        public let value: Int
        public let risk: RiskLevel

        public init(points: Int, value: Int, risk: RiskLevel) {
            self.points = points
            self.value = value
            self.risk = risk
        }
    }
}

// MARK: - CashGenerationTarget

public struct CashGenerationTarget: Codable, Identifiable, Hashable {
    public let id = UUID()
    public let player: Player
    public let targetValue: Int
    public let currentValue: Int
    public let projectedTimeframe: Int
    public let confidenceLevel: Double
    public let riskFactors: [String]

    public init(
        player: Player,
        targetValue: Int,
        currentValue: Int,
        projectedTimeframe: Int,
        confidenceLevel: Double,
        riskFactors: [String]
    ) {
        self.player = player
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.projectedTimeframe = projectedTimeframe
        self.confidenceLevel = confidenceLevel
        self.riskFactors = riskFactors
    }
}

// MARK: - PriceMovementPrediction

public struct PriceMovementPrediction: Codable, Identifiable, Hashable {
    public let id = UUID()
    public let playerId: String
    public let currentPrice: Int
    public let predictedPrice: Int
    public let confidence: Double
    public let factors: [String]
    public let timeframe: String

    public init(
        playerId: String,
        currentPrice: Int,
        predictedPrice: Int,
        confidence: Double,
        factors: [String],
        timeframe: String
    ) {
        self.playerId = playerId
        self.currentPrice = currentPrice
        self.predictedPrice = predictedPrice
        self.confidence = confidence
        self.factors = factors
        self.timeframe = timeframe
    }
}

// TradeAnalysis model moved to EnhancedModels.swift to avoid duplicate definition
