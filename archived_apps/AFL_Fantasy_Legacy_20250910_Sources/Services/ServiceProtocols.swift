import Foundation
import Combine

// MARK: - Settings Service Protocol

protocol SettingsServiceProtocol {
    func getSettings() async throws -> Settings
    func updateSettings(_ settings: Settings) async throws -> Settings
    func isAIEnabled() async throws -> Bool
    func setAIEnabled(_ enabled: Bool) async throws
    func getAppVersion() async -> String
    func updateLeaguePrivacy(_ privacy: String) async throws
    func openSupport() async throws
}

// MARK: - Captain AI Service Protocol

protocol CaptainAIServiceProtocol {
    func getRecommendations() async throws -> [AIRecommendation]
    func getPlayerGames(_ playerId: String) async throws -> [GameStats]
}

// MARK: - Cash Cow Service Protocol

protocol CashCowServiceProtocol {
    func getCashStats() async throws -> CashGenStats
    func analyzeCashCows() async throws -> [CashCowAnalysis]
    func getSellRecommendations() async throws -> [SellRecommendation]
    func getHoldRecommendations() async throws -> [HoldRecommendation]
    func getWatchlistPlayers() async throws -> [WatchlistPlayer]
}

// MARK: - Price Service Protocol

protocol PriceServiceProtocol {
    func getPriceProjections(for playerId: String) async throws -> [PriceProjection]
    func trackPriceChanges() -> AnyPublisher<[Player], Error>
    func getBreakEvenTargets() async throws -> [BreakEvenTarget]
}

// MARK: - Notification Service Protocol

protocol NotificationServiceProtocol {
    func scheduleNotification(title: String, body: String, at date: Date)
    func cancelNotification(withId id: String)
    func requestPermissions() async -> Bool
    func getUnreadCount() async throws -> Int
    func getLatestType() async throws -> NotificationType?
}

// MARK: - Trade Analyzer Protocol

protocol TradeAnalyzerProtocol {
    func analyzeTeam() async throws -> TeamAnalysis
    func simulateTrade(out: Player, in: Player) async throws -> TradeResult
    func getSuggestions() async throws -> [TradeSuggestion]
}

// MARK: - Player Service Protocol

protocol PlayerServiceProtocol {
    func getTeamPlayers() async throws -> [PlayerOption]
    func getPlayerGames(_ playerId: String) async throws -> [GameStats]
    func getProjectedScore(_ playerId: String) async throws -> Double
    func getCurrentCaptain() async throws -> String?
    func getCurrentViceCaptain() async throws -> String?
}

// MARK: - Stats Service Protocol

protocol StatsServiceProtocol {
    func fetchLiveGames() async throws -> [GameInfo]
    func fetchLiveStats() async throws -> LiveStats
    func fetchTeamStructure() async throws -> TeamStructure
    func fetchWeeklyStats() async throws -> WeeklyStats
    func fetchCashGenStats() async throws -> CashGenStats
}

// MARK: - User Service Protocol

protocol UserServiceProtocol {
    func getUserProfile() async throws -> UserProfile
    func updateUsername(_ username: String) async throws
    func updateTeamName(_ name: String) async throws
    // Enhanced personalization methods
    func uploadAvatar(data: Data) async throws -> String // Returns avatar URL
    func updateBio(_ bio: String) async throws
    func updateFavoriteTeam(_ teamId: String) async throws
    func updateNotificationPreferences(_ preferences: DetailedNotificationPreferences) async throws
    func updateThemePreference(_ preference: ThemePreference) async throws
    func updateAIPersonalizationSettings(_ settings: AIPersonalizationSettings) async throws
    func getEnhancedProfile() async throws -> UserProfile // Returns full profile with all personalization data
}

// MARK: - Auth Service Protocol

protocol AuthServiceProtocol {
    func signOut() async throws
}

// MARK: - Data Service Protocol

protocol DataServiceProtocol {
    func getCacheSize() async throws -> String
    func clearCache() async throws
    func exportUserData() async throws
}

// MARK: - Team Service Protocol

protocol TeamServiceProtocol {
    func getCurrentLineup() async throws -> [FieldPlayer]
    func getSalaryInfo() async throws -> SalaryInfo
}

// MARK: - Line Service Protocol

protocol LineServiceProtocol {
    func getSavedLines() async throws -> [SavedLine]
    func saveLine(id: String, name: String, lineup: [FieldPlayer]) async throws
}

// MARK: - Trade Service Protocol

protocol TradeServiceProtocol {
    func getSuggestedTrades() async throws -> [SuggestedTrade]
}

// MARK: - Optimization Service Protocol

protocol OptimizationServiceProtocol {
    func optimizeLineup(_ lineup: [FieldPlayer], availableSalary: Int) async throws -> [FieldPlayer]
}

// MARK: - Notification Data Service Protocol

protocol NotificationDataServiceProtocol {
    func getNotifications() async throws -> [AlertNotification]
    func refreshNotifications() async throws -> [AlertNotification]
    func markAsRead(_ id: String) async throws
    func markAllAsRead() async throws
    func clearHistory() async throws
}
