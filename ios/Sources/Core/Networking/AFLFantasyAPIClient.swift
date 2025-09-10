//
//  AFLFantasyAPIClient.swift
//
//  Network client for AFL Fantasy API integration
//

import Foundation

@available(iOS 16.0, *)
@MainActor
final class AFLFantasyAPIClient: ObservableObject {
    static let shared = AFLFantasyAPIClient()
    
    private let baseURL = "http://localhost:4000"
    private let session = URLSession.shared
    
    // MARK: - Health Check
    
    func healthCheck() async throws -> APIHealthResponse {
        let url = URL(string: "\(baseURL)/health")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(APIHealthResponse.self, from: data)
    }
    
    // MARK: - Players
    
    func getAllPlayers() async throws -> [Player] {
        let url = URL(string: "\(baseURL)/api/players")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode([Player].self, from: data)
    }
    
    func getPlayer(id: String) async throws -> PlayerDetail {
        guard let encodedId = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw AFLFantasyError.networkError("Invalid player ID")
        }
        let url = URL(string: "\(baseURL)/api/players/\(encodedId)")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(PlayerDetail.self, from: data)
    }
    
    // MARK: - Team Import (Mock Implementation)
    
    func importTeam(username: String, password: String) async throws -> ImportedTeamData {
        // Simulate API call delay
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // For demo, fetch some real players and create a mock team
        let players = try await getAllPlayers()
        let selectedPlayers = Array(players.prefix(22)).map { player in
            ImportedPlayer(
                id: player.id,
                name: player.name,
                position: player.position.rawValue,
                price: player.price,
                score: Int(player.average),
                isOnField: true,
                isCaptain: false,
                isViceCaptain: false
            )
        }
        
        let totalValue = selectedPlayers.reduce(0) { $0 + $1.price }
        let totalScore = selectedPlayers.reduce(0) { $0 + $1.score }
        
        return ImportedTeamData(
            totalPlayers: selectedPlayers.count,
            teamValue: totalValue,
            currentScore: totalScore,
            overallRank: Int.random(in: 10000...100000),
            players: selectedPlayers,
            lastUpdated: Date()
        )
    }
    
    func importTeamByUrl(_ teamUrl: String) async throws -> ImportedTeamData {
        // Extract team ID from URL and use it for mock team generation
        return try await importTeam(username: "demo", password: "demo")
    }
    
    // MARK: - Cash Cow Analysis
    
    func getCashCowAnalysis() async throws -> [CashCowData] {
        let url = URL(string: "\(baseURL)/api/stats/cash-cows")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode([CashCowData].self, from: data)
    }
    
    // MARK: - Captain Suggestions  
    
    func getCaptainSuggestions() async throws -> [CaptainSuggestionResponse] {
        let url = URL(string: "\(baseURL)/api/stats/captain-suggestions")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode([CaptainSuggestionResponse].self, from: data)
    }
    
    // MARK: - Statistics
    
    func getDataSummary() async throws -> APIStatsResponse {
        let url = URL(string: "\(baseURL)/api/stats/summary")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(APIStatsResponse.self, from: data)
    }
    
    // MARK: - Refresh Cache
    
    func refreshCache() async throws {
        let url = URL(string: "\(baseURL)/api/refresh")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AFLFantasyError.serverError("Failed to refresh cache")
        }
    }
    
    // MARK: - Error Handling
    
    private func handleAPIError(_ error: Error) -> AFLFantasyError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return .networkError("No internet connection")
            case .timedOut:
                return .networkError("Request timed out")
            case .cannotConnectToHost:
                return .networkError("Cannot connect to AFL Fantasy API server")
            default:
                return .networkError("Network error: \(urlError.localizedDescription)")
            }
        }
        
        if let decodingError = error as? DecodingError {
            return .dataParsingError("Failed to parse server response")
        }
        
        return .serverError("Unknown server error")
    }
}

// MARK: - Response Models

struct APIHealthResponse: Codable {
    let status: String
    let timestamp: String
    let playersCache: Int?
    let lastCacheUpdate: String?
    
    private enum CodingKeys: String, CodingKey {
        case status
        case timestamp
        case playersCache = "players_cached"
        case lastCacheUpdate = "last_cache_update"
    }
}

struct APIStatsResponse: Codable {
    let totalPlayers: Int
    let totalDataRows: Int
    let successfulPlayers: Int
    let failedPlayers: Int
    
    private enum CodingKeys: String, CodingKey {
        case totalPlayers = "total_players"
        case totalDataRows = "total_data_rows"
        case successfulPlayers = "successful_players"
        case failedPlayers = "failed_players"
    }
}

struct CashCowData: Codable, Identifiable {
    var id: String { playerId }
    let playerId: String
    let playerName: String
    let cashGenerated: Int
    let recommendation: String
    let confidence: Double?
    
    private enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case playerName = "player_name"
        case cashGenerated = "cash_generated"
        case recommendation
        case confidence
    }
}

struct CaptainSuggestionResponse: Codable, Identifiable {
    var id: String { playerId }
    let playerId: String
    let playerName: String
    let recommendation: String
    let confidence: Double
    let reasoning: String
    
    private enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case playerName = "player_name"
        case recommendation
        case confidence
        case reasoning
    }
}

struct PlayerDetail: Codable {
    let playerId: String
    let fileName: String
    let careerStats: [[String: AnyCodable]]?
    let opponentSplits: [[String: AnyCodable]]?
    let recentForm: [[String: AnyCodable]]?
    let gameHistory: [[String: AnyCodable]]?
    let venueStats: [[String: AnyCodable]]?
    let headToHead: [[String: AnyCodable]]?
    
    private enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case fileName = "file_name"
        case careerStats = "career_stats"
        case opponentSplits = "opponent_splits"
        case recentForm = "recent_form"
        case gameHistory = "game_history"
        case venueStats = "venue_stats"
        case headToHead = "head_to_head"
    }
}

// MARK: - Helper Types

struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(String.self) {
            self.value = value
        } else if let value = try? container.decode(Int.self) {
            self.value = value
        } else if let value = try? container.decode(Double.self) {
            self.value = value
        } else if let value = try? container.decode(Bool.self) {
            self.value = value
        } else if let value = try? container.decode([String: AnyCodable].self) {
            self.value = value
        } else if let value = try? container.decode([AnyCodable].self) {
            self.value = value
        } else {
            self.value = ""
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let value as String:
            try container.encode(value)
        case let value as Int:
            try container.encode(value)
        case let value as Double:
            try container.encode(value)
        case let value as Bool:
            try container.encode(value)
        case let value as [String: AnyCodable]:
            try container.encode(value)
        case let value as [AnyCodable]:
            try container.encode(value)
        default:
            try container.encodeNil()
        }
    }
}
