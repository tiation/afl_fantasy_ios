//
//  AFLFantasyRepository.swift
//  AFL Fantasy Intelligence Platform
//
//  Repository coordinating NetworkClient + PersistenceManager
//  Created by AI Assistant on 6/9/2025.
//

import Foundation

// MARK: - AFLFantasyRepositoryProtocol

protocol AFLFantasyRepositoryProtocol {
    func fetchTeamData() async throws -> TeamData
    func fetchPlayerStats() async throws -> [PlayerStats]
    func fetchLiveScores() async throws -> LiveScores
    func refreshAllData() async throws -> ScraperResult
}

// MARK: - AFLFantasyRepository

@MainActor
final class AFLFantasyRepository: AFLFantasyRepositoryProtocol {
    static let shared = AFLFantasyRepository()

    private let scraperService: AFLFantasyScraperServiceProtocol
    private let persistenceManager: PersistenceManager
    private let logger = AFLLogger.Category.scraper.logger

    internal init(
        scraperService: AFLFantasyScraperServiceProtocol = AFLFantasyScraperService.shared,
        persistenceManager: PersistenceManager = PersistenceManager.shared
    ) {
        self.scraperService = scraperService
        self.persistenceManager = persistenceManager
    }

    // MARK: - Repository Methods

    func fetchTeamData() async throws -> TeamData {
        AFLLogger.info("Repository: Fetching team data", category: .scraper)

        return try await AFLLogger.logAsyncPerformance(operation: "Repository.fetchTeamData") {
            try await scraperService.fetchTeamData()
        }
    }

    func fetchPlayerStats() async throws -> [PlayerStats] {
        AFLLogger.info("Repository: Fetching player stats", category: .scraper)

        return try await AFLLogger.logAsyncPerformance(operation: "Repository.fetchPlayerStats") {
            try await scraperService.fetchPlayerStats()
        }
    }

    func fetchLiveScores() async throws -> LiveScores {
        AFLLogger.info("Repository: Fetching live scores", category: .scraper)

        return try await AFLLogger.logAsyncPerformance(operation: "Repository.fetchLiveScores") {
            try await scraperService.fetchLiveScores()
        }
    }

    func refreshAllData() async throws -> ScraperResult {
        AFLLogger.info("Repository: Refreshing all data", category: .scraper)

        let result = try await AFLLogger.logAsyncPerformance(operation: "Repository.refreshAllData") {
            try await scraperService.refreshAllData()
        }

        // Cache successful results
        if result.success {
            await cacheResults(result)
        }

        return result
    }

    // MARK: - Private Methods

    private func cacheResults(_ result: ScraperResult) async {
        do {
            // Cache team data if available
            if let teamData = result.teamData {
                try await persistenceManager.cacheTeamData(teamData)
                AFLLogger.debug("Cached team data", category: .scraper)
            }

            // Cache player stats if available
            if !result.playerStats.isEmpty {
                try await persistenceManager.cachePlayerStats(result.playerStats)
                AFLLogger.debug("Cached \(result.playerStats.count) player stats", category: .scraper)
            }

            // Cache live scores if available
            if let liveScores = result.liveScores {
                try await persistenceManager.cacheLiveScores(liveScores)
                AFLLogger.debug("Cached live scores", category: .scraper)
            }
        } catch {
            AFLLogger.error("Failed to cache scraper results: \(error.localizedDescription)", category: .scraper)
        }
    }
}

// MARK: - MockAFLFantasyRepository

final class MockAFLFantasyRepository: AFLFantasyRepositoryProtocol {
    var shouldThrowError = false
    var mockTeamData: TeamData?
    var mockPlayerStats: [PlayerStats] = []
    var mockLiveScores: LiveScores?
    var mockScraperResult: ScraperResult?

    func fetchTeamData() async throws -> TeamData {
        if shouldThrowError {
            throw AFLRepositoryError.mockError
        }

        // Return a mock using TeamData initializer
        return mockTeamData ?? TeamData(
            team: AFLTeam.hawthorn,
            players: [],
            stats: TeamStats(averageScore: 1987.0, totalValue: 12500000, benchStrength: 0.8)
        )
    }

    func fetchPlayerStats() async throws -> [PlayerStats] {
        if shouldThrowError {
            throw AFLRepositoryError.mockError
        }

        return mockPlayerStats.isEmpty ? generateMockPlayerStats() : mockPlayerStats
    }

    func fetchLiveScores() async throws -> LiveScores {
        if shouldThrowError {
            throw AFLRepositoryError.mockError
        }

        return mockLiveScores ?? LiveScores(
            matches: [],
            lastUpdated: Date()
        )
    }

    func refreshAllData() async throws -> ScraperResult {
        if shouldThrowError {
            throw AFLRepositoryError.mockError
        }

        return try await mockScraperResult ?? ScraperResult(
            success: true,
            teamData: fetchTeamData(),
            playerStats: fetchPlayerStats(),
            liveScores: try? fetchLiveScores(),
            error: nil,
            timestamp: Date()
        )
    }

    // MARK: - Mock Data Generation

    private func generateMockPlayerStats() -> [PlayerStats] {
        [
            PlayerStats(
                playerId: "1",
                kicks: 25,
                handballs: 12,
                marks: 8,
                tackles: 4,
                goals: 2,
                behinds: 1,
                fantasyPoints: 125
            ),
            PlayerStats(
                playerId: "2",
                kicks: 15,
                handballs: 8,
                marks: 10,
                tackles: 2,
                goals: 0,
                behinds: 0,
                fantasyPoints: 98
            ),
            PlayerStats(
                playerId: "3",
                kicks: 22,
                handballs: 18,
                marks: 6,
                tackles: 5,
                goals: 1,
                behinds: 2,
                fantasyPoints: 115
            )
        ]
    }
}

// MARK: - AFLRepositoryError

enum AFLRepositoryError: LocalizedError {
    case mockError
    case networkUnavailable
    case dataParsingFailed

    var errorDescription: String? {
        switch self {
        case .mockError:
            "Mock repository error for testing"
        case .networkUnavailable:
            "Network is unavailable"
        case .dataParsingFailed:
            "Failed to parse response data"
        }
    }
}
