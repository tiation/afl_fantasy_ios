//
//  GetDashboardDataUseCase.swift
//  AFL Fantasy Intelligence Platform
//
//  Use case for coordinating dashboard data from multiple sources
//  Created by AI Assistant on 6/9/2025.
//

import Foundation

// MARK: - GetDashboardDataUseCaseProtocol

protocol GetDashboardDataUseCaseProtocol {
    func execute() async throws -> DashboardData
}

// MARK: - GetDashboardDataUseCase

@MainActor
final class GetDashboardDataUseCase: GetDashboardDataUseCaseProtocol {
    private let scraperRepository: AFLFantasyRepositoryProtocol
    private let persistenceManager: PersistenceManager
    private let logger = AFLLogger.Category.general.logger

    init(
        scraperRepository: AFLFantasyRepositoryProtocol = AFLFantasyRepository.shared,
        persistenceManager: PersistenceManager = PersistenceManager.shared
    ) {
        self.scraperRepository = scraperRepository
        self.persistenceManager = persistenceManager
    }

    func execute() async throws -> DashboardData {
        let measurement = PerformanceMeasurement("GetDashboardData UseCase")
        defer { measurement.finish() }

        AFLLogger.info("Executing dashboard data use case", category: .general)

        async let teamDataTask = getTeamData()
        async let playerStatsTask = getPlayerStats()
        async let liveScoresTask = getLiveScores()

        let (teamData, playerStats, liveScores) = try await (
            teamDataTask,
            playerStatsTask,
            liveScoresTask
        )

        let dashboardData = DashboardData(
            teamData: teamData,
            playerStats: playerStats,
            liveScores: liveScores,
            lastUpdated: Date()
        )

        AFLLogger.info("Dashboard data use case completed successfully", category: .general)
        return dashboardData
    }

    // MARK: - Private Methods

    private func getTeamData() async throws -> TeamData {
        // Try cache first (stale-while-revalidate)
        if let cached = try await persistenceManager.getCachedTeamData() {
            AFLLogger.debug("Using cached team data", category: .general)

            // Refresh in background if needed
            Task {
                do {
                    let fresh = try await scraperRepository.fetchTeamData()
                    try await persistenceManager.cacheTeamData(fresh)
                    AFLLogger.debug("Background refresh of team data completed", category: .general)
                } catch {
                    AFLLogger.warning(
                        "Background team data refresh failed: \(error.localizedDescription)",
                        category: .general
                    )
                }
            }

            return cached
        }

        // No cache, fetch fresh
        AFLLogger.info("Fetching fresh team data", category: .general)
        let teamData = try await scraperRepository.fetchTeamData()
        try await persistenceManager.cacheTeamData(teamData)
        return teamData
    }

    private func getPlayerStats() async throws -> [PlayerStats] {
        // Try cache first
        if let cached = try await persistenceManager.getCachedPlayerStats() {
            AFLLogger.debug("Using cached player stats", category: .general)

            // Background refresh
            Task {
                do {
                    let fresh = try await scraperRepository.fetchPlayerStats()
                    try await persistenceManager.cachePlayerStats(fresh)
                    AFLLogger.debug("Background refresh of player stats completed", category: .general)
                } catch {
                    AFLLogger.warning(
                        "Background player stats refresh failed: \(error.localizedDescription)",
                        category: .general
                    )
                }
            }

            return cached
        }

        // No cache, fetch fresh
        AFLLogger.info("Fetching fresh player stats", category: .general)
        let playerStats = try await scraperRepository.fetchPlayerStats()
        try await persistenceManager.cachePlayerStats(playerStats)
        return playerStats
    }

    private func getLiveScores() async throws -> LiveScores? {
        // Live scores are optional and always fresh
        do {
            let liveScores = try await scraperRepository.fetchLiveScores()
            try await persistenceManager.cacheLiveScores(liveScores)
            return liveScores
        } catch {
            AFLLogger.warning("Failed to fetch live scores: \(error.localizedDescription)", category: .general)
            // Return cached if available
            return try? await persistenceManager.getCachedLiveScores()
        }
    }
}

// MARK: - DashboardData

struct DashboardData {
    let teamData: TeamData
    let playerStats: [PlayerStats]
    let liveScores: LiveScores?
    let lastUpdated: Date

    // Computed properties for UI
    var isLiveDataAvailable: Bool {
        liveScores?.matchesInProgress.isEmpty == false
    }

    var topPerformers: [PlayerStats] {
        playerStats
            .filter { $0.currentScore > 0 }
            .sorted { $0.currentScore > $1.currentScore }
            .prefix(5)
            .compactMap { $0 }
    }

    var captainCandidates: [PlayerStats] {
        playerStats
            .filter { $0.projectedScore ?? 0 > 100 }
            .sorted { ($0.projectedScore ?? 0) > ($1.projectedScore ?? 0) }
            .prefix(3)
            .compactMap { $0 }
    }
}

// MARK: - DashboardError

enum DashboardError: LocalizedError {
    case noTeamDataAvailable
    case partialDataFailure([Error])

    var errorDescription: String? {
        switch self {
        case .noTeamDataAvailable:
            return "No team data available - check your AFL Fantasy login"
        case let .partialDataFailure(errors):
            let errorMessages = errors.map(\.localizedDescription).joined(separator: ", ")
            return "Some data failed to load: \(errorMessages)"
        }
    }
}
