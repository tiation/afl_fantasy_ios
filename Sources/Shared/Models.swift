import Foundation
import Combine

// MARK: - AI Models

struct AIRecommendation: Identifiable, Codable {
    let id: String
    let type: RecommendationType
    let confidence: Double
    let reasoning: String
    let impact: String
    let timestamp: Date
    
    enum RecommendationType: String, Codable {
        case trade = "TRADE"
        case captain = "CAPTAIN"
        case hold = "HOLD"
        case sell = "SELL"
    }
}

struct AIPrediction: Identifiable, Codable {
    let id: String
    let playerId: String
    let predictedScore: Double
    let confidence: Double
    let factors: [PredictionFactor]
    let timestamp: Date
}

struct PredictionFactor: Codable {
    let name: String
    let impact: Double
    let description: String
}

// MARK: - Dashboard Models

struct CashGenStats: Codable {
    let totalGenerated: Int
    let activeCashCows: Int
    let sellRecommendations: Int
    let holdCount: Int
    let recentHistory: [CashHistory]
    
    init() {
        self.totalGenerated = 0
        self.activeCashCows = 0
        self.sellRecommendations = 0
        self.holdCount = 0
        self.recentHistory = []
    }
    
    init(totalGenerated: Int, activeCashCows: Int, sellRecommendations: Int, holdCount: Int, recentHistory: [CashHistory]) {
        self.totalGenerated = totalGenerated
        self.activeCashCows = activeCashCows
        self.sellRecommendations = sellRecommendations
        self.holdCount = holdCount
        self.recentHistory = recentHistory
    }
}

struct CashHistory: Codable, Identifiable {
    let id: String
    let playerId: String
    let playerName: String
    let generated: Double
    let date: Date
    let action: CashAction
    
    init(id: String = UUID().uuidString, playerId: String, playerName: String, generated: Double, date: Date, action: CashAction) {
        self.id = id
        self.playerId = playerId
        self.playerName = playerName
        self.generated = generated
        self.date = date
        self.action = action
    }
}

enum CashAction: String, Codable {
    case buy = "BUY"
    case sell = "SELL"
    case hold = "HOLD"
}

struct FieldPlayer: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let position: Position
    let price: Int
    let isOnField: Bool
    let isCaptain: Bool
    let isViceCaptain: Bool
}

// MARK: - Alert Models

enum AlertType: String, Codable, Equatable, CaseIterable {
    case priceChange = "PRICE_CHANGE"
    case injuryUpdate = "INJURY_UPDATE"
    case lateOut = "LATE_OUT"
    case roleChange = "ROLE_CHANGE"
    case breakingNews = "BREAKING_NEWS"
    case tradeDeadline = "TRADE_DEADLINE"
    case captainReminder = "CAPTAIN_REMINDER"
    case injury = "INJURY"
    case selection = "SELECTION"
    case milestone = "MILESTONE"
    case system = "SYSTEM"
    
    var displayName: String {
        switch self {
        case .priceChange:
            return "Price Change"
        case .injuryUpdate, .injury:
            return "Injury Update"
        case .lateOut:
            return "Late Out"
        case .roleChange:
            return "Role Change"
        case .breakingNews:
            return "Breaking News"
        case .tradeDeadline:
            return "Trade Deadline"
        case .captainReminder:
            return "Captain Reminder"
        case .selection:
            return "Selection Alert"
        case .milestone:
            return "Milestone"
        case .system:
            return "System Alert"
        }
    }
}

struct AlertUpdate: Codable {
    let id: String
    let type: AlertType
    let title: String
    let message: String
    let timestamp: Date
    let playerId: String?
    let data: [String: String]?
}

struct AlertNotification: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let message: String
    let type: AlertType
    let timestamp: Date
    var isRead: Bool
    let playerId: String?
    let data: [String: String]?
    
    static func == (lhs: AlertNotification, rhs: AlertNotification) -> Bool {
        return lhs.id == rhs.id
    }
}

// Player models are now defined in AFLModels.swift

struct GameStats: Codable {
    let playerId: String
    let score: Int
    let position: Position
}

// MARK: - Team Models

struct Team: Codable {
    let players: [Player]
    let structure: TeamStructure
    let trades: TradeInfo
}

struct TeamStructure: Codable {
    let totalValue: Int
    let bankBalance: Int
    let positionBalance: [Position: Int]
    let premiumCount: Int
    let midPriceCount: Int
    let rookieCount: Int
    
    init() {
        self.totalValue = 0
        self.bankBalance = 0
        self.positionBalance = [:]
        self.premiumCount = 0
        self.midPriceCount = 0
        self.rookieCount = 0
    }
    
    init(totalValue: Int, bankBalance: Int, positionBalance: [Position: Int], premiumCount: Int, midPriceCount: Int, rookieCount: Int) {
        self.totalValue = totalValue
        self.bankBalance = bankBalance
        self.positionBalance = positionBalance
        self.premiumCount = premiumCount
        self.midPriceCount = midPriceCount
        self.rookieCount = rookieCount
    }
}

struct TradeInfo: Codable {
    let remaining: Int
    let used: Int
}

struct TradeResult: Codable {
    let success: Bool
    let newBalance: Int
    let structureImpact: TeamStructure
    let projectedPointsChange: Double
}

struct SavedLine: Codable, Identifiable {
    let id: String
    let name: String
    let lineup: [FieldPlayer]
    let createdDate: Date
    let totalValue: Int
    let totalScore: Int
    let defCount: Int
    let midCount: Int
    let rucCount: Int
    let fwdCount: Int
}

struct SalaryInfo: Codable {
    let totalSalary: Int
    let availableSalary: Int
    let averagePlayerPrice: Int
    let premiumPercentage: Double
    let rookiePercentage: Double
}

struct SuggestedTrade: Codable, Identifiable {
    let id: String
    let playerOut: Player
    let playerIn: Player
    let cashDifference: Int
    let projectedPointsGain: Double
    let confidence: Double
    let reasoning: String
}

// MARK: - Analysis Models

// CaptainSuggestion is now defined in AFLModels.swift

struct PriceProjection: Codable {
    let round: Int
    let price: Int
    let confidence: Double
}

struct CashCowAnalysis: Codable {
    let player: Player
    let generated: Int
    let projectedGeneration: Int
    let sellRecommendation: Bool
    let holdRecommendation: Bool
}

// MARK: - Additional Models

struct GameInfo: Codable, Identifiable {
    let id: String
    let homeTeam: String
    let awayTeam: String
    let status: GameStatus
    let round: Int
    let venue: String
    
    enum GameStatus: String, Codable {
        case scheduled = "SCHEDULED"
        case inProgress = "IN_PROGRESS"
        case finished = "FINISHED"
        case cancelled = "CANCELLED"
    }
}

struct UserProfile: Codable {
    let id: String
    let username: String
    let teamName: String
    let email: String
    let joinDate: Date
    let preferences: UserPreferences
}

struct UserPreferences: Codable {
    let notifications: Bool
    let theme: String
    let autoSave: Bool
}

struct PlayerOption: Codable, Identifiable {
    let id: String
    let name: String
    let position: Position
    let price: Int
    let projectedScore: Double
    let isSelected: Bool
}

struct LiveStats: Codable {
    let currentScore: Int
    let rank: Int
    let playersPlaying: Int
    let playersRemaining: Int
    let averageScore: Double
    
    init() {
        self.currentScore = 0
        self.rank = 0
        self.playersPlaying = 0
        self.playersRemaining = 0
        self.averageScore = 0.0
    }
    
    init(currentScore: Int, rank: Int, playersPlaying: Int, playersRemaining: Int, averageScore: Double) {
        self.currentScore = currentScore
        self.rank = rank
        self.playersPlaying = playersPlaying
        self.playersRemaining = playersRemaining
        self.averageScore = averageScore
    }
}

struct WeeklyStats: Codable {
    let round: Int
    let projectedScore: Int
    let actualScore: Int?
    let rank: Int?
    let improvement: Double
    
    init() {
        self.round = 0
        self.projectedScore = 0
        self.actualScore = nil
        self.rank = nil
        self.improvement = 0.0
    }
    
    init(round: Int, projectedScore: Int, actualScore: Int?, rank: Int?, improvement: Double) {
        self.round = round
        self.projectedScore = projectedScore
        self.actualScore = actualScore
        self.rank = rank
        self.improvement = improvement
    }
}

struct TeamAnalysis: Codable {
    let structure: TeamStructure
    let weaknesses: [String]
    let upgradePathways: [String]
    let overallRating: Double
}

struct BreakEvenTarget: Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let currentPrice: Int
    let targetPrice: Int
    let weeksToTarget: Int
    let probability: Double
    
    enum TimeFrame: String, CaseIterable {
        case oneWeek = "1_WEEK"
        case twoWeeks = "2_WEEKS"
        case threeWeeks = "3_WEEKS"
        case fourWeeks = "4_WEEKS"
        case month = "1_MONTH"
    }
}

struct SellRecommendation: Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let currentPrice: Int
    let reason: String
    let confidence: Double
    let urgency: UrgencyLevel
    
    enum UrgencyLevel: String, Codable {
        case low = "LOW"
        case medium = "MEDIUM"
        case high = "HIGH"
    }
}

struct HoldRecommendation: Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let reason: String
    let weeksToHold: Int
    let expectedGain: Int
}

struct WatchlistPlayer: Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let currentPrice: Int
    let targetPrice: Int
    let breakEven: Int
    let timeframe: String
    let sellWeek: Int
    let confidence: Double
    let priceTrajectory: [PriceProjection]
}

struct TeamWeakness: Codable {
    let type: WeaknessType
    let severity: Double
    let recommendation: String
}

enum WeaknessType: String, Codable {
    case positionImbalance = "POSITION_IMBALANCE"
    case premiumLight = "PREMIUM_LIGHT"
    case rookieHeavy = "ROOKIE_HEAVY"
    case injuryRisk = "INJURY_RISK"
    case byeRoundExposure = "BYE_ROUND_EXPOSURE"
}

struct UpgradePathway: Codable {
    let from: Player
    let to: Player
    let cost: Int
    let pointsImprovement: Double
    let confidence: Double
}

// MARK: - Venue Models

struct VenueStats: Codable {
    let id: String
    let name: String
    let averageScore: Double
    let weatherImpact: Double
    let positionBias: [Position: Double]
}

// MARK: - Settings Models

struct Settings: Codable {
    let aiEnabled: Bool
    let liveScoring: Bool
    let priceAlerts: Bool
    let theme: ThemeOption
    let scoreFormat: ScoreFormat
    let analyticsEnabled: Bool
    let leaguePrivacy: LeaguePrivacy
    let aiConfidenceThreshold: Double
    let analysisFactors: AnalysisFactors
    let notifications: NotificationPreferences
}

struct AnalysisFactors: Codable {
    let recentForm: Bool
    let opponentDVP: Bool
    let venueBias: Bool
    let weather: Bool
    let consistency: Bool
    let injuryRisk: Bool
    let ownership: Bool
    let ceilingFloor: Bool
}

struct NotificationPreferences: Codable {
    let priceAlerts: Bool
    let injuryNews: Bool
    let tradeDeadlines: Bool
    let captainReminders: Bool
}

enum ThemeOption: String, CaseIterable, Codable {
    case system
    case light
    case dark
    
    var name: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}

enum ScoreFormat: String, CaseIterable, Codable {
    case points
    case fantasy
    
    var name: String {
        switch self {
        case .points:
            return "Points"
        case .fantasy:
            return "Fantasy Score"
        }
    }
}

enum LeaguePrivacy: String, CaseIterable, Codable {
    case `public` = "Public"
    case friendsOnly = "Friends Only"
    case `private` = "Private"
}

// MARK: - Additional Alert Models

struct Alert: Identifiable {
    let id = UUID()
    let type: AlertType
    let severity: AlertSeverity
    let message: String
    let timestamp: String
    let playerId: String?
    let teamId: String?
    let data: [String: AnyCodable]?
}

enum AlertSeverity: String, Codable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    case critical = "CRITICAL"
}

// MARK: - API Response Models

struct CashCowData: Codable {
    let playerId: String
    let playerName: String
    let currentPrice: Int
    let projectedPrice: Int
    let cashGenerated: Int
    let recommendation: String
    let confidence: Double
    let fpAverage: Double
    let gamesPlayed: Int
}

struct CaptainSuggestionResponse: Codable {
    let playerId: String
    let playerName: String
    let projectedPoints: Double
    let confidence: Double
    let reasoning: String
}

struct APIPlayerSummary: Codable {
    let id: String
    let name: String
    let team: String
    let position: String
    let price: Int
    let average: Double
    let projected: Double
    let breakeven: Int
}

struct APIHealthResponse: Codable {
    let status: String
    let timestamp: String
    let playersCached: Int
    let lastCacheUpdate: String?
}

struct APIStatsResponse: Codable {
    let totalPlayers: Int
    let playersWithData: Int
    let cashCowsIdentified: Int
    let lastUpdated: String?
    let cacheAgeMinutes: Int
}

// MARK: - Helper Types

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(String.self) {
            self.value = value
        } else if let value = try? container.decode(Int.self) {
            self.value = value
        } else if let value = try? container.decode(Double.self) {
            self.value = value
        } else if let value = try? container.decode(Bool.self) {
            self.value = value
        } else if let value = try? container.decode([String: AnyCodable].self) {
            self.value = value
        } else if let value = try? container.decode([AnyCodable].self) {
            self.value = value
        } else {
            self.value = ""
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let value as String:
            try container.encode(value)
        case let value as Int:
            try container.encode(value)
        case let value as Double:
            try container.encode(value)
        case let value as Bool:
            try container.encode(value)
        case let value as [String: AnyCodable]:
            try container.encode(value)
        case let value as [AnyCodable]:
            try container.encode(value)
        default:
            try container.encodeNil()
        }
    }
}
