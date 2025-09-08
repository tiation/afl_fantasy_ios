import Foundation
import Combine

// MARK: - Settings Service Protocol

protocol SettingsServiceProtocol {
    func getSettings() async throws -> Settings
    func updateSettings(_ settings: Settings) async throws -> Settings
    func isAIEnabled() async throws -> Bool
    func setAIEnabled(_ enabled: Bool) async throws
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
