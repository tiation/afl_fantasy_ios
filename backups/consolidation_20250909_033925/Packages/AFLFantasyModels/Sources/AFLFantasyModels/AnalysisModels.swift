import Foundation
import SwiftUI

// MARK: - CashGenerationTarget

public struct CashGenerationTarget: Codable, Identifiable {
    public var id: UUID { player.id }
    public let player: EnhancedPlayer
    public let targetPrice: Int
    public let weeksToTarget: Int
    public let probability: Double
    public let bestSellRound: Int
    public let expectedProfit: Int

    public init(
        player: EnhancedPlayer,
        targetPrice: Int,
        weeksToTarget: Int,
        probability: Double,
        bestSellRound: Int,
        expectedProfit: Int
    ) {
        self.player = player
        self.targetPrice = targetPrice
        self.weeksToTarget = weeksToTarget
        self.probability = probability
        self.bestSellRound = bestSellRound
        self.expectedProfit = expectedProfit
    }
}

// MARK: - RiskAssessment

public struct RiskAssessment: Codable, Identifiable {
    public var id: UUID { player.id }
    public let player: EnhancedPlayer
    public let riskLevel: RiskLevel
    public let factors: [RiskFactor]
    public let mitigationStrategies: [String]

    public init(
        player: EnhancedPlayer,
        riskLevel: RiskLevel,
        factors: [RiskFactor],
        mitigationStrategies: [String]
    ) {
        self.player = player
        self.riskLevel = riskLevel
        self.factors = factors
        self.mitigationStrategies = mitigationStrategies
    }

    public enum RiskLevel: String, Codable {
        case low, medium, high

        public var color: Color {
            switch self {
            case .low: .green
            case .medium: .orange
            case .high: .red
            }
        }
    }

    public enum RiskFactor: String, Codable {
        case injury
        case suspension
        case form
        case rotation
        case fixture
    }
}

// MARK: - PriceMovementPrediction

public struct PriceMovementPrediction: Codable, Identifiable {
    public var id: UUID { player.id }
    public let player: EnhancedPlayer
    public let predictedChange: Int
    public let confidence: Double
    public let timeframe: String
    public let reasoning: [String]

    public init(
        player: EnhancedPlayer,
        predictedChange: Int,
        confidence: Double,
        timeframe: String,
        reasoning: [String]
    ) {
        self.player = player
        self.predictedChange = predictedChange
        self.confidence = confidence
        self.timeframe = timeframe
        self.reasoning = reasoning
    }
}

// MARK: - AIRecommendation

public struct AIRecommendation: Codable, Identifiable {
    public let id: UUID
    public let title: String
    public let category: Category
    public let priority: Priority
    public let details: String
    public let actions: [String]

    public init(
        id: UUID = UUID(),
        title: String,
        category: Category,
        priority: Priority,
        details: String,
        actions: [String]
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.priority = priority
        self.details = details
        self.actions = actions
    }

    public enum Category: String, Codable {
        case trade
        case captain
        case cashCow
        case strategy

        public var icon: String {
            switch self {
            case .trade: "arrow.2.squarepath"
            case .captain: "crown.fill"
            case .cashCow: "dollarsign.circle.fill"
            case .strategy: "chart.line.uptrend.xyaxis"
            }
        }
    }

    public enum Priority: String, Codable {
        case low, medium, high

        public var color: Color {
            switch self {
            case .low: .blue
            case .medium: .orange
            case .high: .red
            }
        }
    }
}
