// 🏈 AFL Fantasy Models - Player Domain
// Player-specific models, positions, venue stats, analysis

import Foundation

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
    let consistency: ConsistencyGrade
    let priceChange: Int
    let ownership: Double?
    let injuryStatus: InjuryStatus?
    let venueStats: VenueStats?
    let formFactor: Double?
    let dvpImpact: Double?
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

enum ConsistencyGrade: String, Codable {
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
}

enum InjuryStatus: String, Codable {
    case healthy = "HEALTHY"
    case questionable = "QUESTIONABLE"
    case out = "OUT"
}

struct VenueStats: Codable {
    let id: String
    let name: String
    let averageScore: Double
    let weatherImpact: Double
    let positionBias: [Position: Double]
}

struct FieldPlayer: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let position: Position
    let price: Int
    let isOnField: Bool
    let isCaptain: Bool
    let isViceCaptain: Bool
}

struct PlayerOption: Codable, Identifiable {
    let id: String
    let name: String
    let position: Position
    let price: Int
    let projectedScore: Double
    let isSelected: Bool
}

struct CaptainSuggestion: Codable, Identifiable {
    var id: String { player.id }
    let player: Player
    let confidence: Double
    let reasoning: [String]
    let projectedPoints: Double
    let formFactor: Double
    let venueBias: Double
    let weatherImpact: Double
}

struct GameStats: Codable {
    let playerId: String
    let score: Int
    let position: Position
}

// MARK: - API Models

struct APIPlayerSummary: Codable {
    let id: String
    let name: String
    let team: String
    let position: String
    let price: Int
    let average: Double
    let projected: Double
    let breakeven: Int
}

struct CaptainSuggestionResponse: Codable {
    let playerId: String
    let playerName: String
    let projectedPoints: Double
    let confidence: Double
    let reasoning: String
}
