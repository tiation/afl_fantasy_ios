import Foundation

// MARK: - Core AFL Models (matching API structure)

public struct AFLPlayer: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let team: String
    let position: String
    let price: Double
    let averageScore: Double
    let projectedScore: Double
    let ownership: Double
    let breakeven: Int
    
    // Computed properties for backward compatibility
    var positionEnum: Position {
        Position(rawValue: position) ?? .midfielder
    }
    
    var priceInt: Int {
        Int(price)
    }
    
    init(id: String, name: String, team: String, position: String, price: Double, averageScore: Double, projectedScore: Double, ownership: Double, breakeven: Int) {
        self.id = id
        self.name = name
        self.team = team
        self.position = position
        self.price = price
        self.averageScore = averageScore
        self.projectedScore = projectedScore
        self.ownership = ownership
        self.breakeven = breakeven
    }
    
    // Convenience initializer for backward compatibility
    init(id: String, name: String, team: String, position: Position, price: Int, average: Double, projected: Double, ownership: Double, breakeven: Int) {
        self.init(
            id: id,
            name: name,
            team: team,
            position: position.rawValue,
            price: Double(price),
            averageScore: average,
            projectedScore: projected,
            ownership: ownership,
            breakeven: breakeven
        )
    }
}

// MARK: - Supporting Types

enum Position: String, Codable, CaseIterable {
    case defender = "DEF"
    case midfielder = "MID"
    case ruck = "RUC"
    case forward = "FWD"
    
    var displayName: String {
        switch self {
        case .defender: return "Defenders"
        case .midfielder: return "Midfielders"
        case .ruck: return "Rucks"
        case .forward: return "Forwards"
        }
    }
    
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

// MARK: - Analysis Models

struct CashCow: Codable, Identifiable {
    let id: String
    let name: String
    let team: String
    let position: String
    let price: Double
    let projectedPrice: Double
    let potentialGain: Double
    let breakeven: Int
    let averageScore: Double
    let gamesPlayed: Int
    let ownership: Double
    
    // Convert to AFLPlayer for compatibility
    var asPlayer: AFLPlayer {
        AFLPlayer(
            id: id,
            name: name,
            team: team,
            position: position,
            price: price,
            averageScore: averageScore,
            projectedScore: averageScore, // Using average as fallback
            ownership: ownership,
            breakeven: breakeven
        )
    }
}

struct CaptainSuggestion: Codable, Identifiable {
    let id: String
    let name: String
    let team: String
    let projectedScore: Double
    let ceiling: Double
    let floor: Double
    let consistency: Double
    let ownership: Double
    let confidence: Double
    let reasons: [String]
    
    // Convert to AFLPlayer for compatibility
    var asPlayer: AFLPlayer {
        AFLPlayer(
            id: id,
            name: name,
            team: team,
            position: "MID", // Default position since not provided in API
            price: 500000, // Default price since not provided in API
            averageScore: projectedScore * 0.8, // Estimate average from projected
            projectedScore: projectedScore,
            ownership: ownership,
            breakeven: 0 // Default since not provided
        )
    }
}

// MARK: - API Response Helpers

// Typealias for backward compatibility
typealias Player = AFLPlayer
