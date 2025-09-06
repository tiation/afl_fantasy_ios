//
//  NetworkService.swift
//  AFL Fantasy Intelligence Platform
//
//  Network service for live API data integration
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import Combine

// MARK: - Network Service

@MainActor
class NetworkService: ObservableObject {
    static let shared = NetworkService()
    
    // MARK: - Properties
    
    private let session = URLSession.shared
    private let baseURL = "http://localhost:5001"  // Backend API URL
    private let timeout: TimeInterval = 10.0
    
    @Published var isLoading = false
    @Published var lastError: NetworkError?
    
    // MARK: - Cache Management
    
    private var cache: [String: CachedResponse] = [:]
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    
    private struct CachedResponse {
        let data: Data
        let timestamp: Date
        
        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > 300
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        // Configure URL session
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.waitsForConnectivity = true
    }
    
    // MARK: - API Methods
    
    /// Get dashboard data from backend
    func getDashboardData() async throws -> DashboardData {
        let endpoint = "/api/afl-fantasy/dashboard-data"
        let data = try await performRequest(endpoint: endpoint)
        return try JSONDecoder().decode(DashboardData.self, from: data)
    }
    
    /// Get team value data
    func getTeamValue() async throws -> TeamValueData {
        let endpoint = "/api/afl-fantasy/team-value"
        let data = try await performRequest(endpoint: endpoint)
        return try JSONDecoder().decode(TeamValueData.self, from: data)
    }
    
    /// Get team score data
    func getTeamScore() async throws -> TeamScoreData {
        let endpoint = "/api/afl-fantasy/team-score"
        let data = try await performRequest(endpoint: endpoint)
        return try JSONDecoder().decode(TeamScoreData.self, from: data)
    }
    
    /// Get overall rank data
    func getRankData() async throws -> RankData {
        let endpoint = "/api/afl-fantasy/rank"
        let data = try await performRequest(endpoint: endpoint)
        return try JSONDecoder().decode(RankData.self, from: data)
    }
    
    /// Get captain recommendations
    func getCaptainData() async throws -> CaptainData {
        let endpoint = "/api/afl-fantasy/captain"
        let data = try await performRequest(endpoint: endpoint)
        return try JSONDecoder().decode(CaptainData.self, from: data)
    }
    
    /// Get player stats data
    func getPlayerStats() async throws -> [PlayerData] {
        let endpoint = "/api/stats/combined-stats"
        let data = try await performRequest(endpoint: endpoint)
        return try JSONDecoder().decode([PlayerData].self, from: data)
    }
    
    /// Get cash cow analysis
    func getCashCowData() async throws -> CashCowAnalysis {
        let endpoint = "/api/cash/generation-analysis"
        let data = try await performRequest(endpoint: endpoint)
        return try JSONDecoder().decode(CashCowAnalysis.self, from: data)
    }
    
    /// Get trade recommendations
    func getTradeRecommendations() async throws -> TradeRecommendations {
        let endpoint = "/api/ai/trade-suggestions"
        let data = try await performRequest(endpoint: endpoint)
        return try JSONDecoder().decode(TradeRecommendations.self, from: data)
    }
    
    /// Refresh all data
    func refreshAllData() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Clear cache for fresh data
            cache.removeAll()
            
            // Fetch all data concurrently
            async let dashboardTask = getDashboardData()
            async let playersTask = getPlayerStats()
            async let cashCowTask = getCashCowData()
            async let captainTask = getCaptainData()
            
            let (dashboard, players, cashCow, captain) = try await (
                dashboardTask,
                playersTask, 
                cashCowTask,
                captainTask
            )
            
            // Post notification that data was updated
            NotificationCenter.default.post(
                name: .dataDidUpdate,
                object: nil,
                userInfo: [
                    "dashboard": dashboard,
                    "players": players,
                    "cashCow": cashCow,
                    "captain": captain
                ]
            )
            
        } catch {
            lastError = error as? NetworkError ?? .unknown(error.localizedDescription)
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    private func performRequest(endpoint: String) async throws -> Data {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        // Check cache first
        if let cachedResponse = cache[endpoint], !cachedResponse.isExpired {
            print("🔄 Using cached data for \(endpoint)")
            return cachedResponse.data
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("AFL Fantasy iOS/1.0", forHTTPHeaderField: "User-Agent")
        
        print("🌐 Making API request: \(endpoint)")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                // Cache successful response
                cache[endpoint] = CachedResponse(data: data, timestamp: Date())
                print("✅ API request successful: \(endpoint)")
                return data
                
            case 304:
                // Not modified - use cached version
                if let cachedResponse = cache[endpoint] {
                    return cachedResponse.data
                }
                throw NetworkError.noData
                
            case 401:
                throw NetworkError.unauthorized
                
            case 404:
                throw NetworkError.notFound
                
            case 500...599:
                throw NetworkError.serverError(httpResponse.statusCode)
                
            default:
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
        } catch let error as NetworkError {
            print("❌ Network error: \(error.localizedDescription)")
            throw error
        } catch {
            print("❌ Unknown error: \(error.localizedDescription)")
            throw NetworkError.unknown(error.localizedDescription)
        }
    }
}

// MARK: - Network Error Types

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case unauthorized
    case notFound
    case serverError(Int)
    case httpError(Int)
    case decodingError(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .invalidResponse:
            return "Invalid response"
        case .unauthorized:
            return "Authentication required"
        case .notFound:
            return "Resource not found"
        case .serverError(let code):
            return "Server error (\(code))"
        case .httpError(let code):
            return "HTTP error (\(code))"
        case .decodingError(let message):
            return "Data parsing error: \(message)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}

// MARK: - Response Data Models

struct DashboardData: Codable {
    let teamValue: TeamValueResponse
    let teamScore: TeamScoreResponse
    let overallRank: RankResponse
    let captain: CaptainResponse
    let lastUpdated: String?
}

struct TeamValueData: Codable {
    let totalValue: Int
    let remainingSalary: Int
    let formattedValue: String
    let formattedRemaining: String
    let playerCount: Int
}

struct TeamValueResponse: Codable {
    let total: Int
    let playerCount: Int
    let remainingSalary: Int
    let formatted: String
}

struct TeamScoreData: Codable {
    let totalScore: Int
    let captainScore: Int
    let scoreChange: Int
}

struct TeamScoreResponse: Codable {
    let total: Int
    let captainScore: Int
    let changeFromLastRound: Int
}

struct RankData: Codable {
    let overallRank: Int
    let formattedRank: String
    let rankChange: Int
}

struct RankResponse: Codable {
    let current: Int
    let formatted: String
    let changeFromLastRound: Int
}

struct CaptainData: Codable {
    let captainScore: Int
    let captainName: String
    let ownershipPercentage: Double
    let formattedOwnership: String
}

struct CaptainResponse: Codable {
    let score: Int
    let ownershipPercentage: Double
    let playerName: String
}

struct PlayerData: Codable {
    let name: String
    let team: String
    let position: String
    let price: Int
    let averagePoints: Double
    let breakEven: Int
    let projScore: Double
    let last1: Int?
    let last2: Int?
    let last3: Int?
    let l3Average: Double?
}

struct CashCowAnalysis: Codable {
    let recommendations: [CashCowRecommendation]
    let totalCashGenerated: Int
    let sellSignals: [SellSignal]
}

struct CashCowRecommendation: Codable {
    let playerName: String
    let team: String
    let currentPrice: Int
    let projectedPrice: Int
    let cashGenerated: Int
    let sellUrgency: String
    let confidence: Double
}

struct SellSignal: Codable {
    let playerName: String
    let signal: String // "SELL NOW", "HOLD", "MONITOR"
    let reason: String
}

struct TradeRecommendations: Codable {
    let suggestions: [TradeRecommendation]
    let generatedAt: String
}

struct TradeRecommendation: Codable {
    let tradeIn: String
    let tradeOut: String
    let netCost: Int
    let projectedImpact: Double
    let confidence: Double
    let reasoning: String
}

// MARK: - Notification Names

extension Notification.Name {
    static let dataDidUpdate = Notification.Name("DataDidUpdate")
    static let networkError = Notification.Name("NetworkError")
}
