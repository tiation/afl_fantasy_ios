//
//  AFLFantasyScraperService.swift
//  AFL Fantasy Intelligence Platform
//
//  Real-time data scraper integrating with AFL Fantasy API
//  Based on AflFantasyManager scraper architecture
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import os.log

// MARK: - AFLFantasyScraperServiceProtocol

protocol AFLFantasyScraperServiceProtocol {
    func fetchTeamData() async throws -> TeamData
    func fetchPlayerStats() async throws -> [PlayerStats]
    func fetchLiveScores() async throws -> LiveScores
    func refreshAllData() async throws -> ScraperResult
}

// MARK: - TeamData

struct TeamData: Codable {
    let teamValue: Double
    let remainingSalary: Double
    let teamScore: Int
    let overallRank: Int
    let captainName: String
    let captainScore: Int
    let rankChange: Int
    let lastUpdated: Date
}

// MARK: - PlayerStats

struct PlayerStats: Codable, Identifiable {
    let id: String
    let name: String
    let position: String
    let team: String
    let price: Int
    let currentScore: Int
    let averageScore: Double
    let breakeven: Int
    let last3Games: [Int]
    let projectedScore: Double?
    let ownership: Double
    let priceChange: Int
    let isInjured: Bool
    let isDoubtful: Bool
}

// MARK: - LiveScores

struct LiveScores: Codable {
    let currentRound: Int
    let matchesInProgress: [LiveMatch]
    let playerScores: [String: Int] // playerId -> current score
    let lastUpdated: Date
}

// MARK: - LiveMatch

struct LiveMatch: Codable, Identifiable {
    let id: String
    let homeTeam: String
    let awayTeam: String
    let quarter: String
    let timeRemaining: String?
    let homeScore: Int
    let awayScore: Int
}

// MARK: - ScraperResult

struct ScraperResult: Codable {
    let success: Bool
    let teamData: TeamData?
    let playerStats: [PlayerStats]
    let liveScores: LiveScores?
    let error: String?
    let timestamp: Date
}

// MARK: - AFLFantasyScraperService

@MainActor
final class AFLFantasyScraperService: AFLFantasyScraperServiceProtocol {
    static let shared = AFLFantasyScraperService()

    private let networkClient: NetworkClientProtocol
    private let keychain: KeychainService
    private let logger = Logger(subsystem: "AFLFantasy", category: "ScraperService")
    private let requestBuilder = APIRequestBuilder()

    // Cache to avoid excessive API calls
    private var cache: ScraperCache = .init()

    private init(
        networkClient: NetworkClientProtocol = NetworkClient.shared,
        keychain: KeychainService = KeychainService.shared
    ) {
        self.networkClient = networkClient
        self.keychain = keychain
    }

    // MARK: - Public API

    func fetchTeamData() async throws -> TeamData {
        logger.info("Fetching team data")

        guard let teamId = try? await keychain.retrieveTeamId() else {
            throw ScraperError.missingCredentials
        }

        let endpoints = [
            "/api/teams/\(teamId)",
            "/api/teams/\(teamId)/summary",
            "/api/user/teams/\(teamId)"
        ]

        for endpoint in endpoints {
            do {
                let request = try await requestBuilder.buildRequest(
                    endpoint: endpoint,
                    headers: getAuthHeaders()
                )

                let response = try await networkClient.fetch(AFLTeamResponse.self, from: request)

                if let teamData = extractTeamData(from: response) {
                    cache.teamData = teamData
                    cache.lastTeamUpdate = Date()
                    return teamData
                }
            } catch {
                logger.error("Failed to fetch from \(endpoint): \(error.localizedDescription)")
                continue
            }
        }

        throw ScraperError.noDataAvailable
    }

    func fetchPlayerStats() async throws -> [PlayerStats] {
        logger.info("Fetching player stats")

        // Check cache first
        if let cached = cache.playerStats,
           let lastUpdate = cache.lastPlayerUpdate,
           Date().timeIntervalSince(lastUpdate) < 300
        { // 5 minutes
            logger.info("Returning cached player stats")
            return cached
        }

        let endpoints = [
            "/api/players/stats/current",
            "/api/fantasy/players/all",
            "/api/stats/combined-stats"
        ]

        for endpoint in endpoints {
            do {
                let request = try await requestBuilder.buildRequest(
                    endpoint: endpoint,
                    headers: getAuthHeaders()
                )

                let response = try await networkClient.fetch(AFLPlayersResponse.self, from: request)

                let playerStats = extractPlayerStats(from: response)
                if !playerStats.isEmpty {
                    cache.playerStats = playerStats
                    cache.lastPlayerUpdate = Date()
                    return playerStats
                }
            } catch {
                logger.error("Failed to fetch from \(endpoint): \(error.localizedDescription)")
                continue
            }
        }

        // Fallback to community API
        return try await fetchFromCommunityAPI()
    }

    func fetchLiveScores() async throws -> LiveScores {
        logger.info("Fetching live scores")

        let endpoint = "/api/matches/live"
        let request = try await requestBuilder.buildRequest(
            endpoint: endpoint,
            headers: getAuthHeaders()
        )

        let response = try await networkClient.fetch(AFLLiveResponse.self, from: request)
        return extractLiveScores(from: response)
    }

    func refreshAllData() async throws -> ScraperResult {
        logger.info("Refreshing all data")

        var result = ScraperResult(
            success: false,
            teamData: nil,
            playerStats: [],
            liveScores: nil,
            error: nil,
            timestamp: Date()
        )

        // Fetch team data
        do {
            result.teamData = try await fetchTeamData()
        } catch {
            logger.error("Failed to fetch team data: \(error.localizedDescription)")
            result.error = error.localizedDescription
        }

        // Fetch player stats
        do {
            result.playerStats = try await fetchPlayerStats()
        } catch {
            logger.error("Failed to fetch player stats: \(error.localizedDescription)")
            if result.error == nil {
                result.error = error.localizedDescription
            }
        }

        // Fetch live scores
        do {
            result.liveScores = try await fetchLiveScores()
        } catch {
            logger.error("Failed to fetch live scores: \(error.localizedDescription)")
            // Live scores are optional, don't fail the entire operation
        }

        result.success = result.teamData != nil || !result.playerStats.isEmpty
        return result
    }

    // MARK: - Private Methods

    private func getAuthHeaders() async -> [String: String] {
        var headers: [String: String] = [:]

        // Add session cookie if available
        if let sessionCookie = try? await keychain.retrieveSessionCookie() {
            headers["Cookie"] = sessionCookie
        }

        // Add API token if available
        if let apiToken = try? await keychain.retrieveAPIToken() {
            headers["Authorization"] = "Bearer \(apiToken)"
        }

        // Add CSRF token if available
        if let csrfToken = try? await keychain.retrieveCSRFToken() {
            headers["X-CSRF-Token"] = csrfToken
        }

        return headers
    }

    private func extractTeamData(from response: AFLTeamResponse) -> TeamData? {
        // Extract team data from various possible response formats
        // Implementation based on AflFantasyManager patterns

        guard let teamValue = response.teamValue ?? response.squad?.totalValue else {
            return nil
        }

        return TeamData(
            teamValue: teamValue,
            remainingSalary: max(0, 13_000_000 - teamValue), // AFL Fantasy salary cap
            teamScore: response.totalScore ?? 0,
            overallRank: response.overallRank ?? 0,
            captainName: response.captain?.name ?? "Unknown",
            captainScore: response.captain?.score ?? 0,
            rankChange: response.rankChange ?? 0,
            lastUpdated: Date()
        )
    }

    private func extractPlayerStats(from response: AFLPlayersResponse) -> [PlayerStats] {
        (response.players ?? []).compactMap { player in
            PlayerStats(
                id: player.id,
                name: player.name,
                position: player.position,
                team: player.team,
                price: player.price,
                currentScore: player.currentScore ?? 0,
                averageScore: player.averageScore ?? 0.0,
                breakeven: player.breakeven ?? 0,
                last3Games: player.last3 ?? [],
                projectedScore: player.projectedScore,
                ownership: player.ownership ?? 0.0,
                priceChange: player.priceChange ?? 0,
                isInjured: player.isInjured ?? false,
                isDoubtful: player.isDoubtful ?? false
            )
        }
    }

    private func extractLiveScores(from response: AFLLiveResponse) -> LiveScores {
        let matches = (response.matches ?? []).map { match in
            LiveMatch(
                id: match.id,
                homeTeam: match.homeTeam,
                awayTeam: match.awayTeam,
                quarter: match.quarter ?? "",
                timeRemaining: match.timeRemaining,
                homeScore: match.homeScore ?? 0,
                awayScore: match.awayScore ?? 0
            )
        }

        return LiveScores(
            currentRound: response.currentRound ?? 1,
            matchesInProgress: matches,
            playerScores: response.playerScores ?? [:],
            lastUpdated: Date()
        )
    }

    private func fetchFromCommunityAPI() async throws -> [PlayerStats] {
        logger.info("Falling back to community API")

        // Fallback to DFS Australia or other community endpoints
        let communityBuilder = APIRequestBuilder(baseURL: "https://api.dfsaustralia.com")

        let request = try communityBuilder.buildRequest(
            endpoint: "/fantasy/players/afl",
            headers: ["X-API-Key": "community-key"] // Would be stored in keychain
        )

        let response = try await networkClient.fetch(CommunityPlayersResponse.self, from: request)

        return (response.data ?? []).map { player in
            PlayerStats(
                id: player.id,
                name: player.name,
                position: player.position,
                team: player.team,
                price: player.price,
                currentScore: 0, // Community API might not have live scores
                averageScore: player.average ?? 0.0,
                breakeven: player.breakeven ?? 0,
                last3Games: [],
                projectedScore: player.projected,
                ownership: player.ownership ?? 0.0,
                priceChange: 0,
                isInjured: false,
                isDoubtful: false
            )
        }
    }
}

// MARK: - AFLTeamResponse

private struct AFLTeamResponse: Codable {
    let teamValue: Double?
    let totalScore: Int?
    let overallRank: Int?
    let rankChange: Int?
    let captain: CaptainInfo?
    let squad: SquadInfo?
}

// MARK: - CaptainInfo

private struct CaptainInfo: Codable {
    let name: String
    let score: Int
}

// MARK: - SquadInfo

private struct SquadInfo: Codable {
    let totalValue: Double
    let playerCount: Int
}

// MARK: - AFLPlayersResponse

private struct AFLPlayersResponse: Codable {
    let players: [AFLPlayerInfo]?
}

// MARK: - AFLPlayerInfo

private struct AFLPlayerInfo: Codable {
    let id: String
    let name: String
    let position: String
    let team: String
    let price: Int
    let currentScore: Int?
    let averageScore: Double?
    let breakeven: Int?
    let last3: [Int]?
    let projectedScore: Double?
    let ownership: Double?
    let priceChange: Int?
    let isInjured: Bool?
    let isDoubtful: Bool?
}

// MARK: - AFLLiveResponse

private struct AFLLiveResponse: Codable {
    let currentRound: Int?
    let matches: [LiveMatchInfo]?
    let playerScores: [String: Int]?
}

// MARK: - LiveMatchInfo

private struct LiveMatchInfo: Codable {
    let id: String
    let homeTeam: String
    let awayTeam: String
    let quarter: String?
    let timeRemaining: String?
    let homeScore: Int?
    let awayScore: Int?
}

// MARK: - CommunityPlayersResponse

private struct CommunityPlayersResponse: Codable {
    let data: [CommunityPlayerInfo]?
}

// MARK: - CommunityPlayerInfo

private struct CommunityPlayerInfo: Codable {
    let id: String
    let name: String
    let position: String
    let team: String
    let price: Int
    let average: Double?
    let breakeven: Int?
    let projected: Double?
    let ownership: Double?
}

// MARK: - ScraperError

enum ScraperError: LocalizedError {
    case missingCredentials
    case noDataAvailable
    case authenticationFailed

    var errorDescription: String? {
        switch self {
        case .missingCredentials:
            "Missing AFL Fantasy credentials"
        case .noDataAvailable:
            "No data available from any source"
        case .authenticationFailed:
            "Failed to authenticate with AFL Fantasy"
        }
    }
}

// MARK: - ScraperCache

private struct ScraperCache {
    var teamData: TeamData?
    var playerStats: [PlayerStats]?
    var liveScores: LiveScores?
    var lastTeamUpdate: Date?
    var lastPlayerUpdate: Date?
    var lastLiveUpdate: Date?
}
