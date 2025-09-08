import Foundation

// MARK: - Core Player Models

@frozen
struct Player: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let team: String
    let position: Position
    let price: Int
    let average: Double
    let projected: Double
    let breakeven: Int
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@frozen
enum Position: String, Codable, CaseIterable, Sendable {
    case defender = "DEF"
    case midfielder = "MID"
    case ruck = "RUC"
    case forward = "FWD"
    
    var displayName: String {
        switch self {
        case .defender: return "Defender"
        case .midfielder: return "Midfielder"
        case .ruck: return "Ruck"
        case .forward: return "Forward"
        }
    }
    
    var shortName: String { rawValue }
}

// MARK: - AI & Analysis Models

struct CaptainSuggestion: Codable, Identifiable, Sendable {
    let playerId: String
    let playerName: String
    let projectedPoints: Double
    let confidence: Double
    let reasoning: String
    
    var id: String { playerId }
}

struct CashCowAnalysis: Codable, Identifiable, Sendable {
    let playerId: String
    let playerName: String
    let currentPrice: Int
    let projectedPrice: Int
    let cashGenerated: Int
    let recommendation: String
    let confidence: Double
    let fpAverage: Double
    let gamesPlayed: Int
    
    var id: String { playerId }
    
    var isGoodCashCow: Bool {
        recommendation == "HOLD" && confidence > 0.6
    }
}

struct TradeRecommendation: Codable, Identifiable, Sendable {
    let id: String
    let playerOut: Player
    let playerIn: Player
    let cashDifference: Int
    let projectedPointsGain: Double
    let confidence: Double
    let reasoning: String
    
    init(id: String = UUID().uuidString, playerOut: Player, playerIn: Player, cashDifference: Int, projectedPointsGain: Double, confidence: Double, reasoning: String) {
        self.id = id
        self.playerOut = playerOut
        self.playerIn = playerIn
        self.cashDifference = cashDifference
        self.projectedPointsGain = projectedPointsGain
        self.confidence = confidence
        self.reasoning = reasoning
    }
}

// MARK: - Dashboard Models

struct DashboardData: Codable, Sendable {
    let liveStats: LiveStats
    let weeklyStats: WeeklyStats
    let teamStructure: TeamStructure
    let upcomingFixtures: [GameInfo]
    let topPerformers: [Player]
    let alerts: [AlertNotification]
}

struct LiveStats: Codable, Sendable {
    let currentScore: Int
    let rank: Int
    let playersPlaying: Int
    let playersRemaining: Int
    let averageScore: Double
    
    static let mock = LiveStats(
        currentScore: 1247,
        rank: 12543,
        playersPlaying: 15,
        playersRemaining: 7,
        averageScore: 1156.8
    )
}

struct WeeklyStats: Codable, Sendable {
    let round: Int
    let projectedScore: Int
    let actualScore: Int?
    let rank: Int?
    let improvement: Double
    
    static let mock = WeeklyStats(
        round: 15,
        projectedScore: 2145,
        actualScore: nil,
        rank: nil,
        improvement: 0.0
    )
}

struct TeamStructure: Codable, Sendable {
    let totalValue: Int
    let bankBalance: Int
    let positionBalance: [Position: Int]
    let premiumCount: Int
    let midPriceCount: Int
    let rookieCount: Int
    
    static let mock = TeamStructure(
        totalValue: 12800000,
        bankBalance: 156000,
        positionBalance: [.defender: 6, .midfielder: 8, .ruck: 2, .forward: 6],
        premiumCount: 8,
        midPriceCount: 9,
        rookieCount: 5
    )
}

// MARK: - Alert Models

struct AlertNotification: Codable, Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let message: String
    let type: AlertType
    let timestamp: Date
    var isRead: Bool
    let playerId: String?
    
    init(id: String = UUID().uuidString, title: String, message: String, type: AlertType, timestamp: Date = Date(), isRead: Bool = false, playerId: String? = nil) {
        self.id = id
        self.title = title
        self.message = message
        self.type = type
        self.timestamp = timestamp
        self.isRead = isRead
        self.playerId = playerId
    }
    
    static func == (lhs: AlertNotification, rhs: AlertNotification) -> Bool {
        lhs.id == rhs.id
    }
}

enum AlertType: String, Codable, CaseIterable, Sendable {
    case priceChange = "PRICE_CHANGE"
    case injury = "INJURY"
    case lateOut = "LATE_OUT"
    case roleChange = "ROLE_CHANGE"
    case tradeDeadline = "TRADE_DEADLINE"
    case captainReminder = "CAPTAIN_REMINDER"
    case system = "SYSTEM"
    
    var displayName: String {
        switch self {
        case .priceChange: return "Price Change"
        case .injury: return "Injury Update"
        case .lateOut: return "Late Out"
        case .roleChange: return "Role Change"
        case .tradeDeadline: return "Trade Deadline"
        case .captainReminder: return "Captain Reminder"
        case .system: return "System Alert"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .priceChange: return "dollarsign.circle"
        case .injury: return "cross.circle"
        case .lateOut: return "exclamationmark.triangle"
        case .roleChange: return "arrow.triangle.swap"
        case .tradeDeadline: return "clock"
        case .captainReminder: return "star.circle"
        case .system: return "info.circle"
        }
    }
}

// MARK: - Game Models

struct GameInfo: Codable, Identifiable, Sendable {
    let id: String
    let homeTeam: String
    let awayTeam: String
    let status: GameStatus
    let round: Int
    let venue: String
    
    enum GameStatus: String, Codable, Sendable {
        case scheduled = "SCHEDULED"
        case inProgress = "IN_PROGRESS"
        case finished = "FINISHED"
        case cancelled = "CANCELLED"
    }
}

// MARK: - API Response Models

struct APIHealthResponse: Codable, Sendable {
    let status: String
    let timestamp: String
    let playersCached: Int
    let lastCacheUpdate: String?
}

struct APIStatsResponse: Codable, Sendable {
    let totalPlayers: Int
    let playersWithData: Int
    let cashCowsIdentified: Int
    let lastUpdated: String?
    let cacheAgeMinutes: Int
}

// MARK: - Settings Models

struct AppSettings: Codable, Sendable {
    let theme: ThemeOption
    let notificationsEnabled: Bool
    let priceAlertsEnabled: Bool
    let captainRemindersEnabled: Bool
    let aiConfidenceThreshold: Double
    
    static let `default` = AppSettings(
        theme: .system,
        notificationsEnabled: true,
        priceAlertsEnabled: true,
        captainRemindersEnabled: true,
        aiConfidenceThreshold: 0.7
    )
}

enum ThemeOption: String, CaseIterable, Codable, Sendable {
    case system
    case light
    case dark
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

// MARK: - Error Models

enum AFLFantasyError: Error, LocalizedError, Sendable {
    case networkError(String)
    case dataError(String)
    case apiError(String)
    case unauthorized
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .dataError(let message):
            return "Data Error: \(message)"
        case .apiError(let message):
            return "API Error: \(message)"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError:
            return "Server error occurred"
        }
    }
}

// MARK: - Mock Data Extensions

extension Player {
    static let mockPlayers = [
        Player(id: "1", name: "Marcus Bontempelli", team: "WB", position: .midfielder, price: 715000, average: 118.5, projected: 125.0, breakeven: -15),
        Player(id: "2", name: "Max Gawn", team: "MELB", position: .ruck, price: 652000, average: 105.2, projected: 108.0, breakeven: -12),
        Player(id: "3", name: "Nick Daicos", team: "COLL", position: .defender, price: 598000, average: 98.7, projected: 102.0, breakeven: 8),
        Player(id: "4", name: "Errol Gulden", team: "SYD", position: .midfielder, price: 587000, average: 96.4, projected: 99.0, breakeven: 5),
        Player(id: "5", name: "Zak Butters", team: "PA", position: .forward, price: 612000, average: 101.3, projected: 104.0, breakeven: -8)
    ]
}

extension CashCowAnalysis {
    static let mockCashCows = [
        CashCowAnalysis(playerId: "rookie1", playerName: "Rookie Rising", currentPrice: 278000, projectedPrice: 320000, cashGenerated: 42000, recommendation: "HOLD", confidence: 0.85, fpAverage: 67.2, gamesPlayed: 8),
        CashCowAnalysis(playerId: "rookie2", playerName: "Cash Generator", currentPrice: 312000, projectedPrice: 365000, cashGenerated: 53000, recommendation: "HOLD", confidence: 0.78, fpAverage: 71.8, gamesPlayed: 9)
    ]
}
