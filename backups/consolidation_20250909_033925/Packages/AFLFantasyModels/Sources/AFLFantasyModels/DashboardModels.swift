import Foundation
import SwiftUI

// MARK: - DashboardData

public struct DashboardData: Codable {
    // MARK: - Properties

    public let lastUpdated: Date
    public let captain: Captain
    public let viceCaptain: Captain
    public let ranking: Int
    public let teamValue: Double
    public let seasonPoints: Int
    public let roundPoints: Int
    public let trades: Int
    public let salary: Int

    // MARK: - Initialization

    public init(
        lastUpdated: Date = Date(),
        captain: Captain,
        viceCaptain: Captain,
        ranking: Int,
        teamValue: Double,
        seasonPoints: Int,
        roundPoints: Int,
        trades: Int = 0,
        salary: Int = 0
    ) {
        self.lastUpdated = lastUpdated
        self.captain = captain
        self.viceCaptain = viceCaptain
        self.ranking = ranking
        self.teamValue = teamValue
        self.seasonPoints = seasonPoints
        self.roundPoints = roundPoints
        self.trades = trades
        self.salary = salary
    }

    // MARK: - Captain

    public struct Captain: Codable {
        public let player: EnhancedPlayer
        public let points: Int
        public let projectedPoints: Int

        public init(player: EnhancedPlayer, points: Int = 0, projectedPoints: Int = 0) {
            self.player = player
            self.points = points
            self.projectedPoints = projectedPoints
        }
    }
}

// MARK: - CaptainData

public struct CaptainData: Codable {
    public struct Captain: Codable {
        public let name: String
        public let team: String?
        public let position: String?

        public init(name: String, team: String? = nil, position: String? = nil) {
            self.name = name
            self.team = team
            self.position = position
        }
    }

    public let captain: Captain
    public let lastUpdated: Date
    public let score: Int
    public let projectedScore: Int

    public init(
        captain: Captain,
        lastUpdated: Date = Date(),
        score: Int = 0,
        projectedScore: Int = 0
    ) {
        self.captain = captain
        self.lastUpdated = lastUpdated
        self.score = score
        self.projectedScore = projectedScore
    }
}

// MARK: - AFLFantasyScraperServiceProtocol

public protocol AFLFantasyScraperServiceProtocol {
    var isProcessing: Bool { get }
    var currentCaptain: EnhancedPlayer? { get }
    var fantasyPoints: Int { get }

    func fetchTeamData() async throws -> TeamData
    func refreshGameState() async throws -> Bool
    func makeCaptain(player: EnhancedPlayer) async throws -> Bool
    func makeTrade(in: EnhancedPlayer, out: EnhancedPlayer) async throws -> Bool
}

// MARK: - TeamData

public struct TeamData: Codable {
    public let teamValue: Int
    public let teamScore: Int
    public let overallRank: Int
    public let captainName: String
    public let lastUpdated: Date

    public init(
        teamValue: Int,
        teamScore: Int,
        overallRank: Int,
        captainName: String,
        lastUpdated: Date = Date()
    ) {
        self.teamValue = teamValue
        self.teamScore = teamScore
        self.overallRank = overallRank
        self.captainName = captainName
        self.lastUpdated = lastUpdated
    }
}

// MARK: - ScraperError

public enum ScraperError: Error {
    case missingCredentials
    case authenticationFailed
    case networkError
    case responseParsingError
}
