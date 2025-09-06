//
//  AFLFantasyAPIClient.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Combine
import Foundation

// MARK: - AFLFantasyAPIClient

/// Client for interfacing with the official AFL Fantasy API
/// Handles authentication, data fetching, and response parsing
class AFLFantasyAPIClient: ObservableObject {
    // MARK: - Properties

    let baseURL: URL
    private let session: URLSession
    private let keychain: KeychainManager

    // Published properties for real-time updates
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var lastError: AFLAPIError?

    // MARK: - Initialization

    init(baseURL: URL = URL(string: "https://fantasy.afl.com.au")!, keychain: KeychainManager = KeychainManager()) {
        self.baseURL = baseURL
        self.keychain = keychain

        // Configure URLSession with custom configuration
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = true

        session = URLSession(configuration: configuration)

        // Check if we have stored credentials
        checkAuthenticationStatus()
    }

    // MARK: - Authentication

    /// Check if user is authenticated based on stored credentials
    private func checkAuthenticationStatus() {
        isAuthenticated = keychain.hasAFLCredentials()
    }

    /// Store AFL Fantasy credentials securely
    func storeCredentials(teamId: String, sessionCookie: String, apiToken: String? = nil) {
        keychain.storeAFLCredentials(
            teamId: teamId,
            sessionCookie: sessionCookie,
            apiToken: apiToken
        )
        isAuthenticated = true
    }

    /// Update credentials (alias for storeCredentials for compatibility)
    func updateCredentials(teamId: String, sessionCookie: String, apiToken: String?) {
        storeCredentials(teamId: teamId, sessionCookie: sessionCookie, apiToken: apiToken)
    }

    /// Clear stored credentials
    func clearCredentials() {
        keychain.clearAFLCredentials()
        isAuthenticated = false
    }

    // MARK: - API Request Methods

    /// Get dashboard data including team value, score, rank, and captain info
    func getDashboardData() async throws -> DashboardData {
        guard isAuthenticated else {
            throw AFLAPIError.notAuthenticated
        }

        isLoading = true
        lastError = nil

        defer { isLoading = false }

        do {
            // Fetch data from multiple endpoints concurrently
            async let teamValueTask = getTeamValue()
            async let teamScoreTask = getTeamScore()
            async let rankTask = getOverallRank()
            async let captainTask = getCaptainData()

            let (teamValue, teamScore, rank, captain) = try await (
                teamValueTask, teamScoreTask, rankTask, captainTask
            )

            let dashboardData = DashboardData(
                teamValue: teamValue,
                teamScore: teamScore,
                overallRank: rank,
                captain: captain,
                lastUpdated: Date()
            )

            return dashboardData

        } catch let error as AFLAPIError {
            lastError = error
            throw error
        } catch {
            let aflError = AFLAPIError.networkError(error)
            lastError = aflError
            throw aflError
        }
    }

    /// Get team value data
    private func getTeamValue() async throws -> TeamValueData {
        guard let teamId = keychain.getAFLTeamId() else {
            throw AFLAPIError.missingCredentials
        }

        let endpoints = [
            "/api/teams/\(teamId)",
            "/api/teams/\(teamId)/players",
            "/api/user/teams/\(teamId)",
            "/api/teams/\(teamId)/squad"
        ]

        for endpoint in endpoints {
            do {
                let url = baseURL.appendingPathComponent(endpoint)
                let request = buildRequest(for: url)
                let (data, _) = try await session.data(for: request)

                if let teamValue = try parseTeamValue(from: data) {
                    return teamValue
                }
            } catch {
                // Continue to next endpoint if this one fails
                continue
            }
        }

        throw AFLAPIError.dataParsingError("Unable to fetch team value from any endpoint")
    }

    /// Get team score data
    private func getTeamScore() async throws -> TeamScoreData {
        guard let teamId = keychain.getAFLTeamId() else {
            throw AFLAPIError.missingCredentials
        }

        let endpoints = [
            "/api/teams/\(teamId)/scores/current",
            "/api/teams/\(teamId)/performance/latest",
            "/api/teams/\(teamId)/round/current"
        ]

        for endpoint in endpoints {
            do {
                let url = baseURL.appendingPathComponent(endpoint)
                let request = buildRequest(for: url)
                let (data, _) = try await session.data(for: request)

                if let teamScore = try parseTeamScore(from: data) {
                    return teamScore
                }
            } catch {
                continue
            }
        }

        throw AFLAPIError.dataParsingError("Unable to fetch team score from any endpoint")
    }

    /// Get overall rank data
    private func getOverallRank() async throws -> RankData {
        guard let teamId = keychain.getAFLTeamId() else {
            throw AFLAPIError.missingCredentials
        }

        let endpoints = [
            "/api/teams/\(teamId)/rank",
            "/api/rankings/team/\(teamId)",
            "/api/leaderboard/position/\(teamId)"
        ]

        for endpoint in endpoints {
            do {
                let url = baseURL.appendingPathComponent(endpoint)
                let request = buildRequest(for: url)
                let (data, _) = try await session.data(for: request)

                if let rank = try parseRank(from: data) {
                    return rank
                }
            } catch {
                continue
            }
        }

        throw AFLAPIError.dataParsingError("Unable to fetch rank from any endpoint")
    }

    /// Get captain data
    private func getCaptainData() async throws -> CaptainData {
        guard let teamId = keychain.getAFLTeamId() else {
            throw AFLAPIError.missingCredentials
        }

        let endpoints = [
            "/api/teams/\(teamId)/captain",
            "/api/teams/\(teamId)/selection/captain",
            "/api/captains/ownership"
        ]

        for endpoint in endpoints {
            do {
                let url = baseURL.appendingPathComponent(endpoint)
                let request = buildRequest(for: url)
                let (data, _) = try await session.data(for: request)

                if let captain = try parseCaptain(from: data) {
                    return captain
                }
            } catch {
                continue
            }
        }

        throw AFLAPIError.dataParsingError("Unable to fetch captain data from any endpoint")
    }

    // MARK: - Helper Methods

    /// Build authenticated request with proper headers
    private func buildRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Set standard headers
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
            forHTTPHeaderField: "User-Agent"
        )
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")

        // Add authentication headers
        if let sessionCookie = keychain.getAFLSessionCookie() {
            request.setValue(sessionCookie, forHTTPHeaderField: "Cookie")
        }

        if let apiToken = keychain.getAFLAPIToken() {
            request.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    // MARK: - Data Parsing Methods

    private func parseTeamValue(from data: Data) throws -> TeamValueData? {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let json else { return nil }

        // Try to extract team value from various possible response structures
        if let directValue = json["team_value"] as? Int ?? json["total_value"] as? Int ?? json["value"] as? Int {
            if (10_000_000 ... 15_000_000).contains(directValue) {
                return TeamValueData(
                    totalValue: directValue,
                    remainingSalary: max(0, 13_000_000 - directValue),
                    playerCount: json["player_count"] as? Int ?? 0
                )
            }
        }

        // Try to calculate from players array
        if let players = json["players"] as? [[String: Any]] {
            let totalValue = players.compactMap { $0["price"] as? Int }.reduce(0, +)
            if totalValue > 0 {
                return TeamValueData(
                    totalValue: totalValue,
                    remainingSalary: max(0, 13_000_000 - totalValue),
                    playerCount: players.count
                )
            }
        }

        return nil
    }

    private func parseTeamScore(from data: Data) throws -> TeamScoreData? {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let json else { return nil }

        // Try to extract score from direct fields
        if let directScore = json["team_score"] as? Int ?? json["total_score"] as? Int ?? json["score"] as? Int {
            if (500 ... 4000).contains(directScore) {
                return TeamScoreData(
                    totalScore: directScore,
                    captainScore: json["captain_score"] as? Int ?? 0,
                    changeFromLastRound: json["score_change"] as? Int ?? 0
                )
            }
        }

        // Try to calculate from player scores
        if let players = json["players"] as? [[String: Any]] {
            var totalScore = 0
            var captainScore = 0

            for player in players {
                guard let score = player["score"] as? Int else { continue }

                let isBench = player["is_bench"] as? Bool ?? true
                guard !isBench else { continue }

                totalScore += score

                if let isCaptain = player["is_captain"] as? Bool, isCaptain {
                    captainScore = score
                    totalScore += score // Captain score counts double
                }
            }

            if totalScore > 0 {
                return TeamScoreData(
                    totalScore: totalScore,
                    captainScore: captainScore,
                    changeFromLastRound: 0
                )
            }
        }

        return nil
    }

    private func parseRank(from data: Data) throws -> RankData? {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let json else { return nil }

        if let rank = json["rank"] as? Int ?? json["overall_rank"] as? Int ?? json["position"] as? Int {
            if (1 ... 1_000_000).contains(rank) {
                return RankData(
                    currentRank: rank,
                    changeFromLastRound: json["rank_change"] as? Int ?? 0
                )
            }
        }

        return nil
    }

    private func parseCaptain(from data: Data) throws -> CaptainData? {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let json else { return nil }

        var captainData = CaptainData()

        if let captainInfo = json["captain"] as? [String: Any] {
            captainData.playerName = captainInfo["name"] as? String ?? "Unknown"
            captainData.score = captainInfo["score"] as? Int ?? 0
            captainData.ownershipPercentage = captainInfo["ownership_percentage"] as? Double ?? 0.0
        } else {
            // Try direct fields
            captainData.score = json["captain_score"] as? Int ?? json["score"] as? Int ?? 0
            captainData
                .ownershipPercentage = json["ownership_percentage"] as? Double ?? json["ownership"] as? Double ?? 0.0
        }

        return captainData
    }
}

// MARK: - DashboardData

struct DashboardData {
    let teamValue: TeamValueData
    let teamScore: TeamScoreData
    let overallRank: RankData
    var captain: CaptainData
    let lastUpdated: Date
}

// MARK: - TeamValueData

struct TeamValueData {
    let totalValue: Int
    let remainingSalary: Int
    let playerCount: Int

    var formattedValue: String {
        "$\(String(format: "%.1f", Double(totalValue) / 1_000_000))M"
    }

    var formattedRemaining: String {
        "$\(remainingSalary / 1000)K"
    }
}

// MARK: - TeamScoreData

struct TeamScoreData {
    let totalScore: Int
    let captainScore: Int
    let changeFromLastRound: Int
}

// MARK: - RankData

struct RankData {
    let currentRank: Int
    let changeFromLastRound: Int

    var formattedRank: String {
        NumberFormatter.localizedString(from: NSNumber(value: currentRank), number: .decimal)
    }
}

// MARK: - CaptainData

struct CaptainData {
    var playerName: String = "Unknown"
    var score: Int = 0
    var ownershipPercentage: Double = 0.0

    var formattedOwnership: String {
        "\(String(format: "%.1f", ownershipPercentage))% of teams"
    }
}

// MARK: - AFLFantasyAPIClient.AFLAPIError

extension AFLFantasyAPIClient {
    enum AFLAPIError: Error, LocalizedError {
        case notAuthenticated
        case missingCredentials
        case networkError(Error)
        case dataParsingError(String)
        case invalidResponse
        case rateLimited

        var errorDescription: String? {
            switch self {
            case .notAuthenticated:
                "Not authenticated with AFL Fantasy"
            case .missingCredentials:
                "AFL Fantasy credentials are missing"
            case let .networkError(error):
                "Network error: \(error.localizedDescription)"
            case let .dataParsingError(message):
                "Data parsing error: \(message)"
            case .invalidResponse:
                "Invalid response from AFL Fantasy API"
            case .rateLimited:
                "Rate limited by AFL Fantasy API"
            }
        }
    }
}
