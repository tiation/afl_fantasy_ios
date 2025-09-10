//
//  APIClient.swift
//  AFL Fantasy Intelligence Platform
//
//  API Client wrapper around NetworkClient for compatibility
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import Combine

// MARK: - APIClient

public class APIClient {
    public static let shared = APIClient()
    
    private let networkClient: NetworkClient
    
    private init() {
        self.networkClient = NetworkClient()
    }
    
    // MARK: - Public Interface
    
    public func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        return try await networkClient.request(endpoint)
    }
    
    public func requestWithProgress<T: Decodable>(_ endpoint: APIEndpoint) -> AnyPublisher<Result<T, NetworkError>, Never> {
        return networkClient.requestWithProgress(endpoint)
    }
    
    // MARK: - Dashboard Methods
    
    public func fetchDashboardData() async throws -> DashboardData {
        let endpoint = DashboardEndpoint.overview
        return try await request(endpoint)
    }
    
    public func fetchPlayerStats() async throws -> [PlayerStats] {
        let endpoint = DashboardEndpoint.playerStats
        return try await request(endpoint)
    }
    
    public func fetchTeamAnalysis() async throws -> TeamAnalysisData {
        let endpoint = DashboardEndpoint.teamAnalysis
        return try await request(endpoint)
    }
}

// MARK: - Dashboard Endpoints

private enum DashboardEndpoint: APIEndpoint {
    case overview
    case playerStats
    case teamAnalysis
    
    var baseURL: URL {
        return URL(string: "https://api.aflfantasy.com")!
    }
    
    var path: String {
        switch self {
        case .overview:
            return "/dashboard/overview"
        case .playerStats:
            return "/dashboard/players"
        case .teamAnalysis:
            return "/dashboard/team"
        }
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? {
        return nil
    }
}

// MARK: - Response Models

public struct DashboardData: Codable {
    public let currentRound: Int
    public let teamScore: Int
    public let teamRank: Int
    public let projectedScore: Double
    public let bankBalance: Int
    public let tradesRemaining: Int
}

public struct PlayerStats: Codable {
    public let playerId: String
    public let name: String
    public let position: String
    public let currentScore: Int
    public let averageScore: Double
    public let priceChange: Int
}

public struct TeamAnalysisData: Codable {
    public let teamValue: Int
    public let efficiency: Double
    public let consistency: Double
    public let premiumCount: Int
    public let rookieCount: Int
}
