import Foundation

// MARK: - Team Import Models

struct ImportedTeamData: Codable {
    let totalPlayers: Int
    let teamValue: Int
    let currentScore: Int
    let overallRank: Int
    let players: [ImportedPlayer]
    let lastUpdated: Date
    
    init() {
        self.totalPlayers = 22
        self.teamValue = 12500000 // $12.5M
        self.currentScore = 2134
        self.overallRank = 47291
        self.players = []
        self.lastUpdated = Date()
    }
    
    init(totalPlayers: Int, teamValue: Int, currentScore: Int, overallRank: Int, players: [ImportedPlayer], lastUpdated: Date) {
        self.totalPlayers = totalPlayers
        self.teamValue = teamValue
        self.currentScore = currentScore
        self.overallRank = overallRank
        self.players = players
        self.lastUpdated = lastUpdated
    }
}

struct ImportedPlayer: Codable {
    let id: String
    let name: String
    let position: String
    let price: Int
    let score: Int
    let isOnField: Bool
    let isCaptain: Bool
    let isViceCaptain: Bool
}

// MARK: - Player Models

struct Player: Codable, Identifiable {
    let id: String
    let name: String
    let team: String
    let position: Position
    let price: Int
    let average: Double
    let projected: Double
    let breakeven: Int
}

enum Position: String, Codable {
    case defender = "DEF"
    case midfielder = "MID"
    case ruck = "RUC"
    case forward = "FWD"
    
    var shortName: String {
        return self.rawValue
    }
}

// MARK: - Error Models

enum AFLFantasyError: Error, LocalizedError {
    case networkError(String)
    case dataParsingError(String)
    case authenticationError(String)
    case notFound(String)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .dataParsingError(let message):
            return "Data Error: \(message)"
        case .authenticationError(let message):
            return "Authentication Error: \(message)"
        case .notFound(let message):
            return "Not Found: \(message)"
        case .serverError(let message):
            return "Server Error: \(message)"
        }
    }
}
