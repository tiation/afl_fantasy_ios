//
//  LiveAppState.swift
//  AFL Fantasy Intelligence Platform
//
//  AppState with live API data integration
//  Created by AI Assistant on 6/9/2025.
//

import Combine
import SwiftUI

// MARK: - LiveAppState

@MainActor
class LiveAppState: ObservableObject {
    // MARK: - Published Properties

    @Published var selectedTab: TabItem = .dashboard
    @Published var teamScore: Int = 0
    @Published var teamRank: Int = 0
    @Published var teamValue: Int = 0
    @Published var remainingSalary: Int = 0
    @Published var bankBalance: Int = 0

    // Player data
    @Published var players: [EnhancedPlayer] = []
    @Published var captainSuggestions: [CaptainSuggestion] = []
    @Published var cashCows: [CashCowRecommendation] = []
    @Published var tradeRecommendations: [TradeRecommendation] = []

    // Trade management
    @Published var tradesUsed: Int = 0
    @Published var tradesRemaining: Int = 30
    @Published var tradeHistory: [TradeRecord] = []

    // UI State
    @Published var isRefreshing: Bool = false
    @Published var lastUpdateTime: Date?
    @Published var errorMessage: String?
    @Published var isConnected: Bool = false

    // MARK: - Services

    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        setupObservers()
        loadInitialData()
    }

    // MARK: - Setup

    private func setupObservers() {
        // Observe network service loading state
        networkService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.isRefreshing, on: self)
            .store(in: &cancellables)

        // Observe network errors
        networkService.$lastError
            .receive(on: DispatchQueue.main)
            .compactMap { $0?.localizedDescription }
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)

        // Listen for data updates
        NotificationCenter.default.publisher(for: .dataDidUpdate)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.handleDataUpdate(notification.userInfo)
            }
            .store(in: &cancellables)

        // Auto-refresh every 5 minutes
        Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.refreshData()
                }
            }
            .store(in: &cancellables)
    }

    private func loadInitialData() {
        Task {
            await refreshData()
        }
    }

    // MARK: - Public Methods

    func refreshData() async {
        do {
            try await networkService.refreshAllData()
            isConnected = true
            lastUpdateTime = Date()
            errorMessage = nil
        } catch {
            isConnected = false
            handleError(error)
        }
    }

    func refreshDashboard() async {
        do {
            let dashboard = try await networkService.getDashboardData()
            updateDashboardData(dashboard)
        } catch {
            handleError(error)
        }
    }

    func refreshPlayers() async {
        do {
            let playerData = try await networkService.getPlayerStats()
            updatePlayerData(playerData)
        } catch {
            handleError(error)
        }
    }

    func refreshCaptains() async {
        do {
            let captainData = try await networkService.getCaptainData()
            updateCaptainData(captainData)
        } catch {
            handleError(error)
        }
    }

    func refreshCashCows() async {
        do {
            let cashCowData = try await networkService.getCashCowData()
            updateCashCowData(cashCowData)
        } catch {
            handleError(error)
        }
    }

    func refreshTrades() async {
        do {
            let tradeData = try await networkService.getTradeRecommendations()
            updateTradeData(tradeData)
        } catch {
            handleError(error)
        }
    }

    func clearError() {
        errorMessage = nil
    }

    // MARK: - Private Methods

    private func handleDataUpdate(_ userInfo: [AnyHashable: Any]?) {
        guard let userInfo else { return }

        if let dashboard = userInfo["dashboard"] as? DashboardData {
            updateDashboardData(dashboard)
        }

        if let players = userInfo["players"] as? [PlayerData] {
            updatePlayerData(players)
        }

        if let cashCow = userInfo["cashCow"] as? CashCowAnalysis {
            updateCashCowData(cashCow)
        }

        if let captain = userInfo["captain"] as? CaptainData {
            updateCaptainData(captain)
        }
    }

    private func updateDashboardData(_ data: DashboardData) {
        teamScore = data.teamScore.total
        teamRank = data.overallRank.current
        teamValue = data.teamValue.total
        remainingSalary = data.teamValue.remainingSalary
        bankBalance = remainingSalary // Assuming bank = remaining salary

        lastUpdateTime = Date()
        isConnected = true
    }

    private func updatePlayerData(_ data: [PlayerData]) {
        players = data.map { playerData in
            convertToEnhancedPlayer(playerData)
        }.sorted { $0.averageScore > $1.averageScore }

        print("📊 Updated player data: \\(players.count) players")
    }

    private func updateCaptainData(_ data: CaptainData) {
        // Create captain suggestions from API data
        if let topPlayer = players.first {
            captainSuggestions = [
                CaptainSuggestion(
                    player: topPlayer,
                    confidence: Int(min(95, max(70, data.ownershipPercentage))),
                    projectedPoints: data.captainScore
                )
            ]
        }

        print("⭐ Updated captain data: \\(data.captainName)")
    }

    private func updateCashCowData(_ data: CashCowAnalysis) {
        cashCows = data.recommendations

        print("💰 Updated cash cow data: \\(cashCows.count) recommendations")
    }

    private func updateTradeData(_ data: TradeRecommendations) {
        tradeRecommendations = data.suggestions

        print("🔄 Updated trade data: \\(tradeRecommendations.count) recommendations")
    }

    private func convertToEnhancedPlayer(_ data: PlayerData) -> EnhancedPlayer {
        // Convert API PlayerData to EnhancedPlayer model
        EnhancedPlayer(
            id: UUID().uuidString,
            name: data.name,
            position: Position(rawValue: data.position) ?? .midfielder,
            price: data.price,
            currentScore: Int(data.projScore),
            averageScore: data.averagePoints,
            breakeven: data.breakEven,
            consistency: calculateConsistency(data),
            highScore: Int(data.averagePoints * 1.4),
            lowScore: Int(data.averagePoints * 0.6),
            priceChange: calculatePriceChange(data),
            isCashCow: data.price < 500_000 && data.breakEven < 40,
            isDoubtful: false,
            isSuspended: false,
            cashGenerated: max(0, 500_000 - data.price),
            projectedPeakPrice: Int(Double(data.price) * 1.2),
            nextRoundProjection: createRoundProjection(data),
            seasonProjection: createSeasonProjection(data),
            injuryRisk: createInjuryRisk(),
            venuePerformance: createVenuePerformance(),
            alertFlags: createAlertFlags(data)
        )
    }

    private func calculateConsistency(_ data: PlayerData) -> Double {
        // Calculate consistency based on recent form
        guard let l3Avg = data.l3Average else { return 75.0 }

        let variance = abs(l3Avg - data.averagePoints) / data.averagePoints
        return max(60, min(95, 90 - (variance * 100)))
    }

    private func calculatePriceChange(_ data: PlayerData) -> Int {
        // Estimate price change based on AFL Fantasy algorithm
        let scoreDiff = data.projScore - Double(data.breakEven)
        return Int(scoreDiff * 150) // Simplified AFL Fantasy price change formula
    }

    private func createRoundProjection(_ data: PlayerData) -> RoundProjection {
        RoundProjection(
            round: 1,
            opponent: "TBD",
            venue: "TBD",
            projectedScore: data.projScore,
            confidence: 0.8,
            conditions: WeatherConditions(
                temperature: 18.0,
                rainProbability: 0.2,
                windSpeed: 12.0,
                humidity: 65.0
            )
        )
    }

    private func createSeasonProjection(_ data: PlayerData) -> SeasonProjection {
        SeasonProjection(
            projectedTotalScore: data.averagePoints * 22, // 22 rounds
            projectedAverage: data.averagePoints,
            premiumPotential: data.price > 600_000 ? 0.9 : 0.7
        )
    }

    private func createInjuryRisk() -> InjuryRisk {
        InjuryRisk(
            riskLevel: .low,
            riskScore: 0.15,
            riskFactors: []
        )
    }

    private func createVenuePerformance() -> [VenuePerformance] {
        [
            VenuePerformance(
                venue: "MCG",
                gamesPlayed: 5,
                averageScore: 95.0,
                bias: 2.0
            )
        ]
    }

    private func createAlertFlags(_ data: PlayerData) -> [AlertFlag] {
        var flags: [AlertFlag] = []

        if data.price < 500_000, data.breakEven < 40 {
            flags.append(AlertFlag(
                type: .cashCowSell,
                priority: .medium,
                message: "Cash cow approaching optimal sell window"
            ))
        }

        if data.averagePoints > 110, data.price > 800_000 {
            flags.append(AlertFlag(
                type: .premiumBreakout,
                priority: .high,
                message: "Premium player in excellent form"
            ))
        }

        return flags
    }

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        isConnected = false

        print("❌ AppState error: \\(error.localizedDescription)")

        // Post error notification
        NotificationCenter.default.post(
            name: .networkError,
            object: error
        )
    }
}

// MARK: - TabItem

enum TabItem: String, CaseIterable {
    case dashboard = "Dashboard"
    case captain = "Captain"
    case trades = "Trades"
    case cashCow = "Cash Cow"
    case settings = "Settings"
}
