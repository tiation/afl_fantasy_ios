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

    private init(
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

        return mockTeamData ?? TeamData(
            teamValue: 12_500_000,
            remainingSalary: 500_000,
            teamScore: 1987,
            overallRank: 5432,
            captainName: "Marcus Bontempelli",
            captainScore: 125,
            rankChange: -15,
            lastUpdated: Date()
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
            currentRound: 15,
            matchesInProgress: [],
            playerScores: [:],
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
                id: "1",
                name: "Marcus Bontempelli",
                position: "MID",
                team: "WBD",
                price: 850_000,
                currentScore: 125,
                averageScore: 118.5,
                breakeven: 85,
                last3Games: [125, 110, 135],
                projectedScore: 130.0,
                ownership: 45.2,
                priceChange: 25000,
                isInjured: false,
                isDoubtful: false
            ),
            PlayerStats(
                id: "2",
                name: "Max Gawn",
                position: "RUC",
                team: "MEL",
                price: 780_000,
                currentScore: 98,
                averageScore: 105.2,
                breakeven: 90,
                last3Games: [98, 112, 95],
                projectedScore: 105.0,
                ownership: 38.7,
                priceChange: -15000,
                isInjured: false,
                isDoubtful: true
            ),
            PlayerStats(
                id: "3",
                name: "Sam Walsh",
                position: "MID",
                team: "CAR",
                price: 750_000,
                currentScore: 115,
                averageScore: 112.4,
                breakeven: 80,
                last3Games: [115, 118, 105],
                projectedScore: 118.0,
                ownership: 42.1,
                priceChange: 30000,
                isInjured: false,
                isDoubtful: false
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
