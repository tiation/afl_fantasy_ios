import Foundation

// MARK: - LiveScores

public struct LiveScores: Codable, Identifiable, Hashable {
    public let id = UUID()
    public let matches: [Match]
    public let lastUpdated: Date

    public init(matches: [Match], lastUpdated: Date) {
        self.matches = matches
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Match

public struct Match: Codable, Identifiable, Hashable {
    public let id = UUID()
    public let homeTeam: AFLTeam
    public let awayTeam: AFLTeam
    public let homeScore: Int
    public let awayScore: Int
    public let quarter: String
    public let timeRemaining: String

    public init(
        homeTeam: AFLTeam,
        awayTeam: AFLTeam,
        homeScore: Int,
        awayScore: Int,
        quarter: String,
        timeRemaining: String
    ) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.quarter = quarter
        self.timeRemaining = timeRemaining
    }
}

// MARK: - PlayerStats

public struct PlayerStats: Codable, Identifiable, Hashable {
    public let id = UUID()
    public let playerId: String
    public let kicks: Int
    public let handballs: Int
    public let marks: Int
    public let tackles: Int
    public let goals: Int
    public let behinds: Int
    public let fantasyPoints: Int

    public init(
        playerId: String,
        kicks: Int,
        handballs: Int,
        marks: Int,
        tackles: Int,
        goals: Int,
        behinds: Int,
        fantasyPoints: Int
    ) {
        self.playerId = playerId
        self.kicks = kicks
        self.handballs = handballs
        self.marks = marks
        self.tackles = tackles
        self.goals = goals
        self.behinds = behinds
        self.fantasyPoints = fantasyPoints
    }
}

// MARK: - TeamData

public struct TeamData: Codable, Identifiable, Hashable {
    public let id = UUID()
    public let team: AFLTeam
    public let players: [Player]
    public let stats: TeamStats

    public init(team: AFLTeam, players: [Player], stats: TeamStats) {
        self.team = team
        self.players = players
        self.stats = stats
    }
}

// MARK: - TeamStats

public struct TeamStats: Codable, Hashable {
    public let averageScore: Double
    public let totalValue: Int
    public let benchStrength: Double

    public init(averageScore: Double, totalValue: Int, benchStrength: Double) {
        self.averageScore = averageScore
        self.totalValue = totalValue
        self.benchStrength = benchStrength
    }
}

// MARK: - CaptainSuggestionAnalysis

public struct CaptainSuggestionAnalysis: Codable, Identifiable, Hashable {
    public let id = UUID()
    public let topSuggestions: [CaptainSuggestion]
    public let riskAnalysis: RiskAnalysis
    public let confidenceLevel: Double

    public init(topSuggestions: [CaptainSuggestion], riskAnalysis: RiskAnalysis, confidenceLevel: Double) {
        self.topSuggestions = topSuggestions
        self.riskAnalysis = riskAnalysis
        self.confidenceLevel = confidenceLevel
    }
}

// MARK: - RiskAnalysis

public struct RiskAnalysis: Codable, Hashable {
    public let overallRisk: String
    public let factors: [String]
    public let mitigationStrategies: [String]

    public init(overallRisk: String, factors: [String], mitigationStrategies: [String]) {
        self.overallRisk = overallRisk
        self.factors = factors
        self.mitigationStrategies = mitigationStrategies
    }
}
