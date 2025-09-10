import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var isLoading = false
    @Published private(set) var hasLiveGames = false
    @Published private(set) var liveStats = LiveStats()
    @Published private(set) var teamStructure = TeamStructure()
    @Published private(set) var weeklyStats = WeeklyStats()
    @Published private(set) var cashGenStats = CashGenStats()
    @Published private(set) var tradeSuggestions: [TradeSuggestion] = []
    @Published private(set) var recommendations: [AIRecommendation] = []
    @Published private(set) var unreadNotifications = 0
    @Published private(set) var latestNotificationType: NotificationType?
    @Published var showError = false
    @Published var errorMessage = ""
    
    // MARK: - Dependencies
    
    private let statsService: StatsServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let tradeAnalyzer: TradeAnalyzerProtocol
    private let captainAIService: CaptainAIServiceProtocol
    
    // MARK: - Init
    
    init(
        statsService: StatsServiceProtocol = StatsService(),
        notificationService: NotificationServiceProtocol = NotificationService(),
        tradeAnalyzer: TradeAnalyzerProtocol = TradeAnalyzer(),
        captainAIService: CaptainAIServiceProtocol = CaptainAIService()
    ) {
        self.statsService = statsService
        self.notificationService = notificationService
        self.tradeAnalyzer = tradeAnalyzer
        self.captainAIService = captainAIService
    }
    
    // MARK: - Public Methods
    
    func loadData() {
        Task {
            await loadDataAsync()
        }
    }
    
    func refresh() async {
        await loadDataAsync()
    }
    
    private func loadDataAsync() async {
        do {
            isLoading = true
            defer { isLoading = false }
            
            // Fetch live game status
            let liveGames = try await statsService.fetchLiveGames()
            hasLiveGames = !liveGames.isEmpty
            
            if hasLiveGames {
                // Update live stats if games are in progress
                async let liveStatsTask = statsService.fetchLiveStats()
                liveStats = try await liveStatsTask
            }
            
            // Fetch other dashboard data in parallel
            async let teamStructureTask = statsService.fetchTeamStructure()
            async let weeklyStatsTask = statsService.fetchWeeklyStats()
            async let cashGenTask = statsService.fetchCashGenStats()
            async let tradeTask = tradeAnalyzer.getSuggestions()
            async let notificationsTask = notificationService.getUnreadCount()
            async let aiRecommendationsTask = captainAIService.getRecommendations()
            
            // Wait for all fetches to complete
            (
                teamStructure,
                weeklyStats,
                cashGenStats,
                tradeSuggestions,
                unreadNotifications,
                recommendations
            ) = try await (
                teamStructureTask,
                weeklyStatsTask,
                cashGenTask,
                tradeTask,
                notificationsTask,
                aiRecommendationsTask
            )
            
            // Get latest notification type for badge
            latestNotificationType = try? await notificationService.getLatestType()
            
        } catch {
            handleError(error)
        }
    }
    
    func openMenu() {
        // TODO: Handle menu navigation
    }
    
    func openNotifications() {
        // TODO: Handle notifications navigation
    }
    
    // MARK: - Private Methods
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

// Using LiveStats, WeeklyStats, TeamStructure and CashGenStats from Models.swift

struct TradeSuggestion: Identifiable {
    let id = UUID()
    let outPlayer: String
    let inPlayer: String
    let reasonCode: ReasonCode
    let projectedGain: Int
    let confidenceScore: Double
    
    enum ReasonCode {
        case value
        case scoring
        case fixtures
        case injury
        case role
    }
}

enum NotificationType {
    case critical
    case important
    case normal
}

// MARK: - Note
// Service protocols are defined in Services/ServiceProtocols.swift
// GameStats and other models are defined in Models/Models.swift
