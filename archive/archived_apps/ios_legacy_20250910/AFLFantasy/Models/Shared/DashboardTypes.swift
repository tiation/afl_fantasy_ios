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

// Note: RiskAssessment, AIRecommendation, CashGenerationTarget, and PriceMovementPrediction
// are defined in EnhancedModels.swift to avoid duplicates

// TradeAnalysis model moved to EnhancedModels.swift to avoid duplicate definition
