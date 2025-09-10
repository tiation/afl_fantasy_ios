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


// MARK: - Service Implementations

final class CaptainAIService: CaptainAIServiceProtocol {
    func getRecommendations() async throws -> [AIRecommendation] {
        // Mock implementation
        return []
    }
    
    func getPlayerGames(_ playerId: String) async throws -> [GameStats] {
        // Mock implementation
        return []
    }
}

final class CashCowService: CashCowServiceProtocol {
    func getCashStats() async throws -> CashGenStats {
        return CashGenStats(
            totalGenerated: 0,
            activeCashCows: 0,
            sellRecommendations: 0,
            holdCount: 0,
            recentHistory: []
        )
    }
    
    func analyzeCashCows() async throws -> [CashCowAnalysis] {
        return []
    }
    
    func getSellRecommendations() async throws -> [SellRecommendation] {
        // Mock implementation - return sample sell recommendations
        return [
            SellRecommendation(
                playerId: "1",
                playerName: "Sample Player 1",
                currentPrice: 400000,
                reason: "Price peaked - good time to cash out",
                confidence: 0.85,
                urgency: .high
            ),
            SellRecommendation(
                playerId: "2",
                playerName: "Sample Player 2",
                currentPrice: 350000,
                reason: "Role reduced - sell before price drops",
                confidence: 0.75,
                urgency: .medium
            )
        ]
    }
    
    func getHoldRecommendations() async throws -> [HoldRecommendation] {
        // Mock implementation - return sample hold recommendations
        return [
            HoldRecommendation(
                playerId: "3",
                playerName: "Hold Player 1",
                reason: "Still rising - hold for 2 more weeks",
                weeksToHold: 2,
                expectedGain: 50000
            ),
            HoldRecommendation(
                playerId: "4",
                playerName: "Hold Player 2",
                reason: "Break even target not yet reached",
                weeksToHold: 3,
                expectedGain: 75000
            )
        ]
    }
    
    func getWatchlistPlayers() async throws -> [WatchlistPlayer] {
        // Mock implementation - return sample watchlist players
        return [
            WatchlistPlayer(
                playerId: "5",
                playerName: "Watch Player 1",
                currentPrice: 200000,
                targetPrice: 300000,
                breakEven: -10,
                timeframe: "3 weeks",
                sellWeek: 8,
                confidence: 0.90,
                priceTrajectory: [
                    PriceProjection(round: 1, price: 220000, confidence: 0.8),
                    PriceProjection(round: 2, price: 250000, confidence: 0.85),
                    PriceProjection(round: 3, price: 280000, confidence: 0.9)
                ]
            )
        ]
    }
}

final class PriceService: PriceServiceProtocol {
    func getPriceProjections(for playerId: String) async throws -> [PriceProjection] {
        return []
    }
    
    func trackPriceChanges() -> AnyPublisher<[Player], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getBreakEvenTargets() async throws -> [BreakEvenTarget] {
        return []
    }
}

final class NotificationService: NotificationServiceProtocol {
    func scheduleNotification(title: String, body: String, at date: Date) {
        // Implementation would use UserNotifications framework
    }
    
    func cancelNotification(withId id: String) {
        // Implementation would use UserNotifications framework
    }
    
    func requestPermissions() async -> Bool {
        return false
    }
    
    func getUnreadCount() async throws -> Int {
        // Mock implementation - would fetch from backend API
        return 0
    }
    
    func getLatestType() async throws -> NotificationType? {
        // Mock implementation - would fetch from backend API
        return nil
    }
}

final class TradeAnalyzer: TradeAnalyzerProtocol {
    func analyzeTeam() async throws -> TeamAnalysis {
        let mockStructure = TeamStructure(
            totalValue: 0,
            bankBalance: 0,
            positionBalance: [:],
            premiumCount: 0,
            midPriceCount: 0,
            rookieCount: 0
        )
        
        return TeamAnalysis(
            structure: mockStructure,
            weaknesses: [],
            upgradePathways: [],
            overallRating: 7.5
        )
    }
    
    func simulateTrade(out: Player, in: Player) async throws -> TradeResult {
        let mockStructure = TeamStructure(
            totalValue: 0,
            bankBalance: 0,
            positionBalance: [:],
            premiumCount: 0,
            midPriceCount: 0,
            rookieCount: 0
        )
        
        return TradeResult(
            success: true,
            newBalance: 0,
            structureImpact: mockStructure,
            projectedPointsChange: 0
        )
    }
    
    func getSuggestions() async throws -> [TradeSuggestion] {
        // Mock implementation - would connect to Docker python_ai service
        // for real suggestions via http://localhost:8080/suggestions
        return [
            TradeSuggestion(
                outPlayer: "Mock Player A",
                inPlayer: "Mock Player B", 
                reasonCode: .value,
                projectedGain: 25,
                confidenceScore: 0.85
            )
        ]
    }
}
