import Foundation

// MARK: - Dashboard Data Models

/// Live statistics for the current round
struct LiveStats: Codable, Sendable {
    let currentScore: Int
    let rank: Int
    let averageScore: Double
    let playersPlaying: Int
    let playersRemaining: Int
    
    static let mock = LiveStats(
        currentScore: 1847,
        rank: 23456,
        averageScore: 1632.5,
        playersPlaying: 18,
        playersRemaining: 4
    )
}

/// Weekly projection statistics
struct WeeklyStats: Codable, Sendable {
    let round: Int
    let projectedScore: Int
    let confidence: Double
    let bestCaptain: String
    let captainScore: Double
    let riskLevel: String
    
    static let mock = WeeklyStats(
        round: 24,
        projectedScore: 2134,
        confidence: 0.85,
        bestCaptain: "Max Gawn",
        captainScore: 127.3,
        riskLevel: "Medium"
    )
}

/// Team structure and financial information
struct TeamStructure: Codable, Sendable {
    let totalValue: Int
    let bankBalance: Int
    let positionBalance: [Position: Int]
    let premiumPlayers: Int
    let rookiePlayers: Int
    
    static let mock = TeamStructure(
        totalValue: 13450000,
        bankBalance: 350000,
        positionBalance: [
            .defender: 6,
            .midfielder: 8,
            .ruck: 2,
            .forward: 6
        ],
        premiumPlayers: 12,
        rookiePlayers: 10
    )
}

/// API Health Response
struct APIHealthResponse: Codable, Sendable {
    let status: String
    let timestamp: String
    let playersLoaded: Int
    let websocketEnabled: Bool
    let liveSimulation: Bool
}

/// API Stats Response  
struct APIStatsResponse: Codable, Sendable {
    let totalPlayers: Int
    let playersWithData: Int
    let cashCowsIdentified: Int
    let lastUpdated: String
    let cacheAgeMinutes: Int
}

// MARK: - API Request/Response Models

struct LoginRequest: Codable, Sendable {
    let email: String
    let password: String
}

struct AuthResponse: Codable, Sendable {
    let token: String
    let refreshToken: String
    let user: User
}

struct RefreshTokenRequest: Codable, Sendable {
    let refreshToken: String
}

struct CaptainRequest: Codable, Sendable {
    let venue: String?
    let opponent: String?
}

struct AddTeamRequest: Codable, Sendable {
    let teamCode: String
}

struct FantasyTeamResponse: Codable, Sendable {
    let id: String
    let teamCode: String
    let teamName: String
    let totalValue: Int
    let players: [Player]
}

// MARK: - Extension for APIService Mock

extension APIService {
    static let mock: APIService = {
        let service = APIService(baseURL: "http://localhost:8080")
        return service
    }()
}
