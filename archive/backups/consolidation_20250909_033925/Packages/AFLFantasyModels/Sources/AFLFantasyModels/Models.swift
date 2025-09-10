import Foundation
import SwiftUI

// MARK: - PlayerPosition

/// Player positions in AFL Fantasy
public enum PlayerPosition: String, CaseIterable, Codable, Hashable {
    case defender = "DEF"
    case midfielder = "MID"
    case ruck = "RUC"
    case forward = "FWD"

    public var color: Color {
        switch self {
        case .defender: .blue
        case .midfielder: .green
        case .ruck: .purple
        case .forward: .red
        }
    }

    public var displayName: String {
        switch self {
        case .defender: "Defender"
        case .midfielder: "Midfielder"
        case .ruck: "Ruck"
        case .forward: "Forward"
        }
    }
}

// MARK: - AFLTeam

/// AFL Teams
public enum AFLTeam: String, CaseIterable, Codable {
    case adelaide = "ADE"
    case brisbane = "BL"
    case carlton = "CAR"
    case collingwood = "COL"
    case essendon = "ESS"
    case fremantle = "FRE"
    case geelong = "GEE"
    case goldCoast = "GC"
    case gws = "GWS"
    case hawthorn = "HAW"
    case melbourne = "MEL"
    case northMelbourne = "NM"
    case portAdelaide = "PA"
    case richmond = "RIC"
    case stKilda = "STK"
    case sydney = "SYD"
    case westCoast = "WC"
    case westernBulldogs = "WB"
}

// MARK: - EnhancedPlayer

/// Enhanced player data model
public struct EnhancedPlayer: Identifiable, Codable, Hashable {
    public let id: UUID
    public let aflPlayerId: Int
    public let name: String
    public let position: PlayerPosition
    public let team: AFLTeam
    public let price: Int
    public let averageScore: Double
    public let currentScore: Int
    public let priceChange: Int
    public let ownership: Double
    public let form: [Int] // Last 5 scores
    public let projectedScore: Double
    public let injuryRisk: InjuryRisk
    public let venueAdvantage: Double
    public let consistency: Double
    public let isDoubtful: Bool
    public let isCashCow: Bool
    public let breakEvenPrice: Int
    public let cashGenerated: Int
    public let alertFlags: [AlertFlag]
    public let fixtureRating: Double
    public let opponentStrength: Double
    public let opponent: String
    public let venue: String

    public var formattedPrice: String {
        "$\(price / 1000)K"
    }

    public var priceChangeText: String {
        let change = priceChange / 1000
        return change > 0 ? "+$\(change)K" : "-$\(abs(change))K"
    }
}

// MARK: - InjuryRisk

public enum InjuryRisk: String, Codable, CaseIterable {
    case none
    case low
    case medium
    case high
    case injured
}

// MARK: - AlertFlag

public enum AlertFlag: String, Codable, CaseIterable {
    case priceRise = "price_rise"
    case priceDrop = "price_drop"
    case injuryWatch = "injury_watch"
    case formDrop = "form_drop"
    case breakoutCandidate = "breakout"
    case sellSignal = "sell_signal"
    case bargainBuy = "bargain_buy"

    public var displayText: String {
        switch self {
        case .priceRise: "Price Rising"
        case .priceDrop: "Price Dropping"
        case .injuryWatch: "Injury Watch"
        case .formDrop: "Form Drop"
        case .breakoutCandidate: "Breakout Candidate"
        case .sellSignal: "Sell Signal"
        case .bargainBuy: "Bargain Buy"
        }
    }

    public var color: Color {
        switch self {
        case .priceRise, .breakoutCandidate, .bargainBuy: .green
        case .priceDrop, .formDrop, .sellSignal: .red
        case .injuryWatch: .orange
        }
    }
}

// MARK: - CaptainSuggestion

public struct CaptainSuggestion: Identifiable, Codable {
    public let id: UUID
    public let player: EnhancedPlayer
    public let confidence: Int
    public let projectedPoints: Int
    public let formRating: Double
    public let fixtureRating: Double
    public let opponent: String
    public let venue: String
    public let reasoning: String
    public let riskFactors: [String]
}

// MARK: - TabItem

public enum TabItem: String, CaseIterable {
    case dashboard
    case trades
    case captain
    case cashCow = "cash_cow"
    case settings
}

// MARK: - AppState

@MainActor
public final class AppState: ObservableObject {
    @Published public var selectedTab: TabItem = .dashboard

    // Team Data
    @Published public var players: [EnhancedPlayer] = []
    @Published public var captainSuggestions: [CaptainSuggestion] = []
    @Published public var cashCows: [EnhancedPlayer] = []
    @Published public var dashboardData: DashboardData? = nil
    @Published public var priceMovements: [PriceMovementPrediction] = []
    @Published public var riskAssessments: [RiskAssessment] = []
    @Published public var recommendations: [AIRecommendation] = []

    public init() {}
}

// MARK: - DashboardData

public struct DashboardData: Codable {
    public let lastUpdated: Date
    public let captain: Captain
    public let viceCaptain: Captain
    public let ranking: Int
    public let teamValue: Double
    public let seasonPoints: Int
    public let roundPoints: Int
    public let trades: Int
    public let salary: Int

    public struct Captain: Codable {
        public let player: EnhancedPlayer
        public let points: Int
        public let projectedPoints: Int
    }
}

// MARK: - CaptainSuggestionAnalysis

public struct CaptainSuggestionAnalysis: Codable {
    public let player: EnhancedPlayer
    public let confidence: Int
    public let projectedPoints: Int
    public let formAnalysis: String
    public let matchupAnalysis: String
    public let riskFactors: [String]
}

// MARK: - TradeAnalysis

public struct TradeAnalysis: Codable {
    public let inPlayer: EnhancedPlayer
    public let outPlayer: EnhancedPlayer
    public let score: Int
    public let pros: [String]
    public let cons: [String]
    public let verdict: String
}

// MARK: - CashGenerationTarget

public struct CashGenerationTarget: Codable, Identifiable {
    public var id: UUID { player.id }
    public let player: EnhancedPlayer
    public let targetPrice: Int
    public let weeksToTarget: Int
    public let probability: Double
    public let bestSellRound: Int
    public let expectedProfit: Int
}

// MARK: - RiskAssessment

public struct RiskAssessment: Codable, Identifiable {
    public var id: UUID { player.id }
    public let player: EnhancedPlayer
    public let riskLevel: RiskLevel
    public let factors: [RiskFactor]
    public let mitigationStrategies: [String]

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
}

// MARK: - AIRecommendation

public struct AIRecommendation: Codable, Identifiable {
    public let id: UUID
    public let title: String
    public let category: Category
    public let priority: Priority
    public let details: String
    public let actions: [String]

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
