import Combine
import Foundation
import os.log

// MARK: - DataSyncManager

@MainActor
final class DataSyncManager: ObservableObject {
    // MARK: - Published State

    @Published private(set) var lastSyncTime: Date?
    @Published private(set) var isRefreshing = false
    @Published private(set) var error: Error?

    // MARK: - Dependencies

    private let scraper: AFLFantasyScraperServiceProtocol
    private let appState: AppState
    private let logger = Logger(subsystem: "AFLFantasy", category: "DataSyncManager")

    // MARK: - Private State

    private var autoRefreshTimer: Timer?
    private var autoRefreshInterval: TimeInterval = 300 // 5 minutes default

    // MARK: - Initialization

    init(
        scraper: AFLFantasyScraperServiceProtocol = AFLFantasyScraperService.shared,
        appState: AppState
    ) {
        self.scraper = scraper
        self.appState = appState
    }

    deinit {
        stopAutoRefresh()
    }

    // MARK: - Public Methods

    func startAutoRefresh(interval: TimeInterval = 300) {
        autoRefreshInterval = interval
        stopAutoRefresh() // Clear any existing timer

        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.refreshAllData()
            }
        }

        logger.info("Started auto-refresh with interval \(interval) seconds")
    }

    func stopAutoRefresh() {
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil
        logger.info("Stopped auto-refresh")
    }

    func setRefreshInterval(_ interval: TimeInterval) {
        if interval != autoRefreshInterval {
            autoRefreshInterval = interval
            if autoRefreshTimer != nil {
                startAutoRefresh(interval: interval) // Restart with new interval
            }
        }
    }

    func refreshAllData() async {
        guard !isRefreshing else {
            logger.info("Refresh already in progress")
            return
        }

        isRefreshing = true
        error = nil

        do {
            logger.info("Starting full data refresh")
            let result = try await scraper.refreshAllData()

            if result.success {
                updateAppState(with: result)
                lastSyncTime = result.timestamp
                logger.info("Data refresh succeeded")
            } else {
                error = AFLDataError.refreshFailed(result.error ?? "Unknown error")
                logger.error("Data refresh failed: \(result.error ?? "Unknown error")")
            }
        } catch {
            self.error = error
            logger.error("Data refresh threw error: \(error.localizedDescription)")
        }

        isRefreshing = false
    }

    // MARK: - Private Methods

    private func updateAppState(with result: ScraperResult) {
        if let teamData = result.teamData {
            appState.teamScore = teamData.teamScore
            appState.teamRank = teamData.overallRank
            appState.teamValue = Int(teamData.teamValue)
            appState.bankBalance = Int(teamData.remainingSalary)
        }

        if !result.playerStats.isEmpty {
            // Convert player stats to enhanced players
            let enhancedPlayers = result.playerStats.map { stats -> EnhancedPlayer in
                EnhancedPlayer(
                    name: stats.name,
                    position: Position(rawValue: stats.position) ?? .midfielder,
                    currentPrice: stats.price,
                    currentScore: stats.currentScore,
                    averageScore: stats.averageScore,
                    breakeven: stats.breakeven,
                    consistency: calculateConsistency(from: stats.last3Games),
                    injuryRiskScore: calculateInjuryRisk(isInjured: stats.isInjured, isDoubtful: stats.isDoubtful),
                    priceChange: stats.priceChange,
                    cashGenerated: calculateCashGenerated(currentPrice: stats.price, priceChange: stats.priceChange),
                    isCashCow: isCashCow(price: stats.price, priceChange: stats.priceChange),
                    teamAbbreviation: stats.team,
                    projectedScore: stats.projectedScore ?? stats.averageScore,
                    opponent: "TBD", // Would need to match with fixture data
                    venue: "TBD", // Would need to match with fixture data
                    rainProbability: 0.0, // Weather data not yet available
                    venueBias: 0.0, // Not calculated yet
                    isDoubtful: stats.isDoubtful,
                    contractYear: false, // Not available in stats yet
                    gamesPlayed: stats.last3Games.count
                )
            }

            appState.players = enhancedPlayers
            appState.cashCows = enhancedPlayers.filter(\.isCashCow)
        }

        if let liveScores = result.liveScores {
            // Update live scores if games are in progress
            updateLiveScores(liveScores)
        }
    }

    private func calculateConsistency(from last3Games: [Int]) -> Double {
        guard !last3Games.isEmpty else { return 0.0 }

        let average = Double(last3Games.reduce(0, +)) / Double(last3Games.count)
        let deviations = last3Games.map { abs(Double($0) - average) }
        let averageDeviation = deviations.reduce(0, +) / Double(deviations.count)

        // High consistency = low deviation from average
        let maxDeviation = 40.0 // Arbitrary threshold
        let consistency = 100.0 * (1.0 - min(averageDeviation / maxDeviation, 1.0))
        return consistency
    }

    private func calculateInjuryRisk(isInjured: Bool, isDoubtful: Bool) -> Double {
        switch (isInjured, isDoubtful) {
        case (true, _): 80.0
        case (_, true): 40.0
        default: 10.0
        }
    }

    private func calculateCashGenerated(currentPrice: Int, priceChange: Int) -> Int {
        max(0, priceChange) // Simplified - would need historical price tracking
    }

    private func isCashCow(price: Int, priceChange: Int) -> Bool {
        // Simple heuristic - low price with positive change
        price < 400_000 && priceChange > 20000
    }

    private func updateLiveScores(_ scores: LiveScores) {
        // Update player scores from live data
        var updatedPlayers = appState.players
        for (playerId, score) in scores.playerScores {
            if let index = updatedPlayers.firstIndex(where: { String($0.id.uuidString.prefix(8)) == playerId }) {
                updatedPlayers[index].currentScore = score
            }
        }
        appState.players = updatedPlayers

        // Could update match info if needed
        logger.info("Updated live scores for \(scores.playerScores.count) players")
    }
}

// MARK: - AFLDataError

enum AFLDataError: LocalizedError {
    case refreshFailed(String)
    case invalidData(String)

    var errorDescription: String? {
        switch self {
        case let .refreshFailed(reason):
            "Data refresh failed: \(reason)"
        case let .invalidData(details):
            "Invalid data: \(details)"
        }
    }
}
