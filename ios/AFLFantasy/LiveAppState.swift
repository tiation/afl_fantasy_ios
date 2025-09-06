//
//  LiveAppState.swift
//  AFL Fantasy Intelligence Platform
//
//  Comprehensive app state management with live data integration
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Live App State

@MainActor
final class LiveAppState: ObservableObject {
    
    // MARK: - Published Properties
    
    // Tab Navigation
    @Published var selectedTab: TabItem = .dashboard
    
    // Connection & Loading States
    @Published var isConnected: Bool = true
    @Published var isRefreshing: Bool = false
    @Published var lastUpdateTime: Date?
    @Published var errorMessage: String?
    
    // Team Data
    @Published var teamScore: Int = 0
    @Published var teamRank: Int = 0
    @Published var teamValue: Int = 0
    @Published var bankBalance: Int = 0
    @Published var tradesRemaining: Int = 2
    
    // Player Data
    @Published var players: [EnhancedPlayer] = []
    @Published var selectedPlayers: Set<UUID> = []
    @Published var playerSearchText: String = ""
    @Published var selectedPosition: PlayerPosition? = nil
    @Published var sortOption: PlayerSortOption = .averageScore
    
    // Trade Calculator
    @Published var playersToTradeOut: [EnhancedPlayer] = []
    @Published var playersToTradeIn: [EnhancedPlayer] = []
    @Published var currentTradeScenario: TradeScenario?
    @Published var tradeAnalysisResult: TradeAnalysisResult?
    
    // Captain Data
    @Published var captainSuggestions: [CaptainSuggestion] = []
    @Published var selectedCaptain: CaptainSuggestion?
    
    // Cash Cow Data
    @Published var cashCows: [CashCowRecommendation] = []
    @Published var totalCashGenerated: Int = 0
    
    // Analytics Data
    @Published var venuePerformanceData: [VenuePerformance] = []
    @Published var priceProjections: [Int: PriceProjection] = [:]
    @Published var consistencyData: [Int: ConsistencyData] = [:]
    @Published var teamAnalytics: [TeamAnalytics] = []
    
    // Live Updates
    @Published var liveUpdates: [LiveUpdate] = []
    @Published var isLiveDataEnabled: Bool = true
    
    // User Preferences
    @Published var preferredUpdateInterval: TimeInterval = 30
    @Published var notificationsEnabled: Bool = true
    @Published var darkModeEnabled: Bool = true
    
    // MARK: - Private Properties
    
    private let networkService = EnhancedNetworkService.shared
    private let mockDataService = MockDataService.shared
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: Timer?
    private var liveUpdatesSubscription: AnyCancellable?

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
    
    // MARK: - New Enhanced Methods
    
    private func setupSubscriptions() {
        // Monitor network connection
        networkService.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.isConnected = isConnected
                if !isConnected {
                    self?.errorMessage = "No internet connection. Using cached data."
                }
            }
            .store(in: &cancellables)
        
        // Clear error when connection restored
        networkService.$isConnected
            .filter { $0 }
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.errorMessage?.contains("internet") == true {
                    self?.errorMessage = nil
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupPeriodicRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: preferredUpdateInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.refreshData()
            }
        }
    }
    
    private func subscribeToLiveUpdates() {
        guard isLiveDataEnabled else { return }
        
        liveUpdatesSubscription = networkService.subscribeToLiveUpdates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                self?.handleLiveUpdate(update)
            }
    }
    
    // MARK: - Data Loading Methods
    
    func loadInitialData() async {
        isRefreshing = true
        errorMessage = nil
        
        do {
            // Load all data concurrently
            async let playersTask = loadPlayers()
            async let captainTask = loadCaptainSuggestions()
            async let cashCowTask = loadCashCowRecommendations()
            async let analyticsTask = loadAnalyticsData()
            
            let (players, captains, cashCows, _) = await (
                playersTask,
                captainTask,
                cashCowTask,
                analyticsTask
            )
            
            // Update team stats from players
            updateTeamStats(from: players)
            
            lastUpdateTime = Date()
            
        } catch {
            handleError(error)
        }
        
        isRefreshing = false
    }
    
    private func loadPlayers() async -> [EnhancedPlayer] {
        do {
            if isConnected {
                let fetchedPlayers = try await networkService.fetchPlayers()
                players = fetchedPlayers
                return fetchedPlayers
            } else {
                // Use mock data when offline
                let mockPlayers = mockDataService.players
                players = mockPlayers
                return mockPlayers
            }
        } catch {
            // Fallback to mock data on error
            let mockPlayers = mockDataService.players
            players = mockPlayers
            return mockPlayers
        }
    }
    
    private func loadCaptainSuggestions() async -> [CaptainSuggestion] {
        do {
            if isConnected {
                let suggestions = try await networkService.fetchCaptainSuggestions(
                    teamId: "user_team_id",
                    round: getCurrentRound()
                )
                captainSuggestions = suggestions
                return suggestions
            } else {
                let mockSuggestions = mockDataService.captainSuggestions
                captainSuggestions = mockSuggestions
                return mockSuggestions
            }
        } catch {
            let mockSuggestions = mockDataService.captainSuggestions
            captainSuggestions = mockSuggestions
            return mockSuggestions
        }
    }
    
    private func loadCashCowRecommendations() async -> [CashCowRecommendation] {
        do {
            if isConnected {
                let recommendations = try await networkService.fetchCashCowRecommendations(
                    teamId: "user_team_id"
                )
                cashCows = recommendations
                totalCashGenerated = recommendations.reduce(0) { $0 + $1.cashGenerated }
                return recommendations
            } else {
                let mockRecommendations = mockDataService.cashCows
                cashCows = mockRecommendations
                totalCashGenerated = mockRecommendations.reduce(0) { $0 + $1.cashGenerated }
                return mockRecommendations
            }
        } catch {
            let mockRecommendations = mockDataService.cashCows
            cashCows = mockRecommendations
            totalCashGenerated = mockRecommendations.reduce(0) { $0 + $1.cashGenerated }
            return mockRecommendations
        }
    }
    
    private func loadAnalyticsData() async {
        do {
            if isConnected {
                async let venueTask = networkService.fetchVenuePerformanceData()
                async let teamTask = networkService.fetchTeamAnalytics()
                
                let (venueData, teamData) = try await (venueTask, teamTask)
                
                venuePerformanceData = venueData
                teamAnalytics = teamData
            } else {
                // Use mock analytics data
                venuePerformanceData = mockDataService.venuePerformanceData
                teamAnalytics = mockDataService.teamAnalytics
            }
        } catch {
            // Fallback to mock data
            venuePerformanceData = mockDataService.venuePerformanceData
            teamAnalytics = mockDataService.teamAnalytics
        }
    }
    
    // MARK: - Trade Calculator Methods
    
    func addPlayerToTradeOut(_ player: EnhancedPlayer) {
        if !playersToTradeOut.contains(where: { $0.id == player.id }) {
            playersToTradeOut.append(player)
            updateTradeScenario()
        }
    }
    
    func removePlayerFromTradeOut(_ player: EnhancedPlayer) {
        playersToTradeOut.removeAll { $0.id == player.id }
        updateTradeScenario()
    }
    
    func addPlayerToTradeIn(_ player: EnhancedPlayer) {
        if !playersToTradeIn.contains(where: { $0.id == player.id }) {
            playersToTradeIn.append(player)
            updateTradeScenario()
        }
    }
    
    func removePlayerFromTradeIn(_ player: EnhancedPlayer) {
        playersToTradeIn.removeAll { $0.id == player.id }
        updateTradeScenario()
    }
    
    func clearTrade() {
        playersToTradeOut.removeAll()
        playersToTradeIn.removeAll()
        currentTradeScenario = nil
        tradeAnalysisResult = nil
    }
    
    private func updateTradeScenario() {
        guard !playersToTradeOut.isEmpty && !playersToTradeIn.isEmpty else {
            currentTradeScenario = nil
            tradeAnalysisResult = nil
            return
        }
        
        let scenario = TradeScenario(
            playersOut: playersToTradeOut,
            playersIn: playersToTradeIn
        )
        
        currentTradeScenario = scenario
        
        // Analyze trade scenario
        Task {
            await analyzeCurrentTrade(scenario)
        }
    }
    
    private func analyzeCurrentTrade(_ scenario: TradeScenario) async {
        do {
            if isConnected {
                let analysis = try await networkService.analyzeTradeScenario(scenario)
                tradeAnalysisResult = analysis
            } else {
                // Mock analysis when offline
                tradeAnalysisResult = mockTradeAnalysis(scenario)
            }
        } catch {
            // Fallback to mock analysis
            tradeAnalysisResult = mockTradeAnalysis(scenario)
        }
    }
    
    private func mockTradeAnalysis(_ scenario: TradeScenario) -> TradeAnalysisResult {
        let costDiff = scenario.playersIn.reduce(0) { $0 + $1.price } -
                      scenario.playersOut.reduce(0) { $0 + $1.price }
        
        let scoreGain = scenario.playersIn.reduce(0.0) { $0 + $1.projectedScore } -
                       scenario.playersOut.reduce(0.0) { $0 + $1.projectedScore }
        
        return TradeAnalysisResult(
            costDifference: costDiff,
            projectedScoreGain: scoreGain,
            confidence: 0.75,
            aiRecommendation: scoreGain > 0 ? "Recommended trade with good upside potential" : "Consider alternative options",
            riskLevel: abs(costDiff) > 500000 ? "high" : "medium"
        )
    }
    
    // MARK: - Player Search & Filtering
    
    var filteredPlayers: [EnhancedPlayer] {
        var filtered = players
        
        // Apply search filter
        if !playerSearchText.isEmpty {
            filtered = filtered.filter { player in
                player.name.localizedCaseInsensitiveContains(playerSearchText) ||
                player.team.displayName.localizedCaseInsensitiveContains(playerSearchText)
            }
        }
        
        // Apply position filter
        if let position = selectedPosition {
            filtered = filtered.filter { $0.position == position }
        }
        
        // Apply sorting
        filtered.sort { player1, player2 in
            switch sortOption {
            case .name:
                return player1.name < player2.name
            case .price:
                return player1.price > player2.price
            case .averageScore:
                return player1.averageScore > player2.averageScore
            case .form:
                return player1.formAverage > player2.formAverage
            case .projectedScore:
                return player1.projectedScore > player2.projectedScore
            }
        }
        
        return filtered
    }
    
    // MARK: - Live Updates Handling
    
    private func handleLiveUpdate(_ update: LiveUpdate) {
        liveUpdates.append(update)
        
        // Keep only recent updates (last 50)
        if liveUpdates.count > 50 {
            liveUpdates.removeFirst(liveUpdates.count - 50)
        }
        
        // Process specific update types
        switch update.data {
        case .score(let scoreUpdate):
            updatePlayerScore(playerId: scoreUpdate.playerId, newScore: scoreUpdate.currentScore)
            
        case .priceChange(let priceUpdate):
            updatePlayerPrice(playerId: priceUpdate.playerId, newPrice: priceUpdate.newPrice)
            
        case .injury(let injuryUpdate):
            updatePlayerInjury(playerId: injuryUpdate.playerId, severity: injuryUpdate.severity)
            
        case .teamChange:
            // Handle team changes if needed
            break
        }
    }
    
    private func updatePlayerScore(playerId: Int, newScore: Int) {
        if let index = players.firstIndex(where: { $0.aflPlayerId == playerId }) {
            // Create updated player with new score - would need mutable properties
            Task {
                await refreshData()
            }
        }
    }
    
    private func updatePlayerPrice(playerId: Int, newPrice: Int) {
        if let index = players.firstIndex(where: { $0.aflPlayerId == playerId }) {
            // Update player price - would need mutable properties
            Task {
                await refreshData()
            }
        }
    }
    
    private func updatePlayerInjury(playerId: Int, severity: InjuryRisk) {
        if let index = players.firstIndex(where: { $0.aflPlayerId == playerId }) {
            // Update injury status - would need mutable properties
        }
    }
    
    // MARK: - Utility Methods
    
    private func updateTeamStats(from players: [EnhancedPlayer]) {
        teamValue = players.reduce(0) { $0 + $1.price }
        teamScore = Int(players.reduce(0.0) { $0 + $1.averageScore })
        
        // Mock team rank calculation
        teamRank = max(1, 100000 - (teamScore * 10))
        
        // Mock bank balance calculation
        let salaryCapBase = 13000000 // $13M salary cap
        bankBalance = max(0, salaryCapBase - teamValue)
    }
    
    private func getCurrentRound() -> Int {
        // Mock current round - in production, this would come from API
        return 15
    }
    
    // MARK: - Settings Methods
    
    func updateRefreshInterval(_ interval: TimeInterval) {
        preferredUpdateInterval = interval
        refreshTimer?.invalidate()
        setupPeriodicRefresh()
    }
    
    func toggleLiveUpdates(_ enabled: Bool) {
        isLiveDataEnabled = enabled
        if enabled {
            subscribeToLiveUpdates()
        } else {
            liveUpdatesSubscription?.cancel()
        }
    }
    
    func toggleNotifications(_ enabled: Bool) {
        notificationsEnabled = enabled
        // Handle notification permission requests if needed
    }
}

// MARK: - Supporting Enums

enum PlayerSortOption: String, CaseIterable, Identifiable {
    case name = "name"
    case price = "price"
    case averageScore = "average_score"
    case form = "form"
    case projectedScore = "projected_score"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .name: return "Name"
        case .price: return "Price"
        case .averageScore: return "Average Score"
        case .form: return "Form"
        case .projectedScore: return "Projected Score"
        }
    }
}

// MARK: - Mock Data Service

final class MockDataService {
    static let shared = MockDataService()
    
    private init() {}
    
    lazy var players: [EnhancedPlayer] = [
        EnhancedPlayer(
            aflPlayerId: 1,
            name: "Clayton Oliver",
            position: .midfielder,
            team: .melbourne,
            price: 750000,
            averageScore: 118.5,
            lastScore: 142,
            priceChange: 15000,
            ownership: 45.2,
            form: [142, 98, 134, 125, 101],
            projectedScore: 120.0,
            injuryRisk: .low,
            venueAdvantage: 8.5,
            consistency: 82.3,
            isCashCow: false,
            breakEvenPrice: 742000,
            cashGenerated: 0
        ),
        EnhancedPlayer(
            aflPlayerId: 2,
            name: "Sam Walsh",
            position: .midfielder,
            team: .carlton,
            price: 680000,
            averageScore: 112.8,
            lastScore: 95,
            priceChange: -8000,
            ownership: 38.7,
            form: [95, 128, 104, 119, 132],
            projectedScore: 115.0,
            injuryRisk: .low,
            isCashCow: false,
            breakEvenPrice: 688000
        ),
        EnhancedPlayer(
            aflPlayerId: 3,
            name: "Nick Daicos",
            position: .midfielder,
            team: .collingwood,
            price: 620000,
            averageScore: 95.2,
            lastScore: 118,
            priceChange: 25000,
            ownership: 67.4,
            form: [118, 87, 102, 94, 75],
            projectedScore: 98.0,
            injuryRisk: .low,
            isCashCow: true,
            breakEvenPrice: 595000,
            cashGenerated: 85000,
            alertFlags: [.breakoutCandidate]
        )
    ]
    
    lazy var captainSuggestions: [CaptainSuggestion] = [
        CaptainSuggestion(
            player: players[0],
            confidence: 88,
            projectedPoints: 142,
            formRating: 0.85,
            fixtureRating: 0.78,
            opponent: "Richmond",
            venue: "MCG",
            reasoning: "Excellent form and favorable matchup against Richmond's weaker midfield.",
            riskFactors: ["High ownership risk"]
        ),
        CaptainSuggestion(
            player: players[1],
            confidence: 82,
            projectedPoints: 128,
            formRating: 0.82,
            fixtureRating: 0.72,
            opponent: "Essendon",
            venue: "Docklands",
            reasoning: "Strong recent form and historically performs well at Docklands.",
            riskFactors: ["Weather conditions uncertain"]
        )
    ]
    
    lazy var cashCows: [CashCowRecommendation] = [
        CashCowRecommendation(
            playerName: "Nick Daicos",
            currentPrice: 620000,
            targetPrice: 720000,
            cashGenerated: 100000,
            projectedWeeks: 3,
            confidence: 0.85,
            sellUrgency: "MONITOR",
            reasoning: "Strong breakout season, price still rising steadily."
        ),
        CashCowRecommendation(
            playerName: "Caleb Windsor",
            currentPrice: 350000,
            targetPrice: 450000,
            cashGenerated: 100000,
            projectedWeeks: 4,
            confidence: 0.72,
            sellUrgency: "HOLD",
            reasoning: "Rookie showing consistent improvement, more cash to be made."
        )
    ]
    
    lazy var venuePerformanceData: [VenuePerformance] = [
        VenuePerformance(
            venue: "MCG",
            team: .melbourne,
            averageScore: 1685,
            gamesPlayed: 12,
            winRate: 0.75,
            scoreVariance: 145.2
        ),
        VenuePerformance(
            venue: "Docklands",
            team: .carlton,
            averageScore: 1598,
            gamesPlayed: 11,
            winRate: 0.64,
            scoreVariance: 167.8
        )
    ]
    
    lazy var teamAnalytics: [TeamAnalytics] = [
        TeamAnalytics(
            team: .melbourne,
            averageScore: 1685,
            defensiveRating: 82.4,
            offensiveRating: 88.7,
            homeAdvantage: 12.3,
            recentForm: [105, 98, 112, 87, 95]
        ),
        TeamAnalytics(
            team: .carlton,
            averageScore: 1598,
            defensiveRating: 75.6,
            offensiveRating: 84.2,
            homeAdvantage: 8.9,
            recentForm: [88, 102, 76, 94, 109]
        )
    ]
}

