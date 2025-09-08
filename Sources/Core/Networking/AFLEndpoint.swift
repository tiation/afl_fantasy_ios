import Foundation

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - AFL API Endpoints

enum AFLEndpoint {
    case health
    case players
    case player(id: String)
    case cashCows
    case captainSuggestions([String: Any])
    case summary
    case refresh
    
    var path: String {
        switch self {
        case .health:
            return "/health"
        case .players:
            return "/players"
        case .player(let id):
            return "/players/\(id)"
        case .cashCows:
            return "/stats/cash-cows"
        case .captainSuggestions:
            return "/captain/suggestions"
        case .summary:
            return "/stats/summary"
        case .refresh:
            return "/refresh"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .health, .players, .player, .cashCows, .summary:
            return .get
        case .captainSuggestions, .refresh:
            return .post
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        default:
            return nil
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .captainSuggestions(let parameters):
            return parameters
        default:
            return nil
        }
    }
}

// MARK: - API Response Models

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
    let timestamp: Date
}

struct PlayersResponse: Codable {
    let players: [AFLPlayer]
    let total: Int
}

struct CashCowsResponse: Codable {
    let cashCows: [CashCow]
    let criteria: CashCowCriteria
}

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
}

struct CashCowCriteria: Codable {
    let maxPrice: Double
    let minGames: Int
    let minBreakeven: Int
    let maxOwnership: Double
}

struct CaptainSuggestionsResponse: Codable {
    let suggestions: [CaptainSuggestion]
    let criteria: CaptainCriteria
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
}

struct CaptainCriteria: Codable {
    let round: Int
    let venue: String?
    let opponent: String?
    let conditions: [String]
}

struct SummaryResponse: Codable {
    let totalPlayers: Int
    let totalTeams: Int
    let averagePrice: Double
    let highestPrice: Double
    let lowestPrice: Double
    let lastUpdated: Date
}
