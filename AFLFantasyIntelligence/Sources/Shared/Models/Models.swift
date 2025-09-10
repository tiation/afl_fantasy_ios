import Foundation

// MARK: - Player

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

// MARK: - Position

enum Position: String, Codable, CaseIterable, Sendable {
    case defender = "DEF"
    case midfielder = "MID"
    case ruck = "RUC"
    case forward = "FWD"

    var displayName: String {
        switch self {
        case .defender: "Defender"
        case .midfielder: "Midfielder"
        case .ruck: "Ruck"
        case .forward: "Forward"
        }
    }

    var shortName: String { rawValue }
}

// MARK: - CaptainSuggestion

struct CaptainSuggestion: Codable, Identifiable, Sendable {
    let playerId: String
    let playerName: String
    let projectedPoints: Double
    let confidence: Double
    let reasoning: String

    var id: String { playerId }
}

// MARK: - CashCowAnalysis

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

// MARK: - TradeRecommendation

struct TradeRecommendation: Codable, Identifiable, Sendable {
    let id: String
    let playerOut: Player
    let playerIn: Player
    let cashDifference: Int
    let projectedPointsGain: Double
    let confidence: Double
    let reasoning: String

    init(
        id: String = UUID().uuidString,
        playerOut: Player,
        playerIn: Player,
        cashDifference: Int,
        projectedPointsGain: Double,
        confidence: Double,
        reasoning: String
    ) {
        self.id = id
        self.playerOut = playerOut
        self.playerIn = playerIn
        self.cashDifference = cashDifference
        self.projectedPointsGain = projectedPointsGain
        self.confidence = confidence
        self.reasoning = reasoning
    }
}

// MARK: - DashboardData

struct DashboardData: Codable, Sendable {
    let liveStats: LiveStats
    let weeklyStats: WeeklyStats
    let teamStructure: TeamStructure
    let upcomingFixtures: [GameInfo]
    let topPerformers: [Player]
    let alerts: [AlertNotification]
}

// MARK: - LiveStats

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

// MARK: - WeeklyStats

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

// MARK: - TeamStructure

struct TeamStructure: Codable, Sendable {
    let totalValue: Int
    let bankBalance: Int
    let positionBalance: [Position: Int]
    let premiumCount: Int
    let midPriceCount: Int
    let rookieCount: Int

    static let mock = TeamStructure(
        totalValue: 12_800_000,
        bankBalance: 156_000,
        positionBalance: [.defender: 6, .midfielder: 8, .ruck: 2, .forward: 6],
        premiumCount: 8,
        midPriceCount: 9,
        rookieCount: 5
    )
}

// MARK: - AlertNotification

struct AlertNotification: Codable, Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let message: String
    let type: AlertType
    let timestamp: Date
    var isRead: Bool
    let playerId: String?

    init(
        id: String = UUID().uuidString,
        title: String,
        message: String,
        type: AlertType,
        timestamp: Date = Date(),
        isRead: Bool = false,
        playerId: String? = nil
    ) {
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

// MARK: - AlertType

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
        case .priceChange: "Price Change"
        case .injury: "Injury Update"
        case .lateOut: "Late Out"
        case .roleChange: "Role Change"
        case .tradeDeadline: "Trade Deadline"
        case .captainReminder: "Captain Reminder"
        case .system: "System Alert"
        }
    }

    var systemImageName: String {
        switch self {
        case .priceChange: "dollarsign.circle"
        case .injury: "cross.circle"
        case .lateOut: "exclamationmark.triangle"
        case .roleChange: "arrow.triangle.swap"
        case .tradeDeadline: "clock"
        case .captainReminder: "star.circle"
        case .system: "info.circle"
        }
    }
}

// MARK: - GameInfo

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
    let timestamp: String?
    let playersLoaded: Int?
}

struct APIStatsResponse: Codable, Sendable {
    let totalPlayers: Int
    let playersWithData: Int
    let cashCowsIdentified: Int
    let lastUpdated: String?
    let cacheAgeMinutes: Int
}

// MARK: - AppSettings

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

// MARK: - ThemeOption

enum ThemeOption: String, CaseIterable, Codable, Sendable {
    case system
    case light
    case dark

    var displayName: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}

// MARK: - AI Models

// MARK: - AIRecommendation

struct AIRecommendation: Codable, Identifiable, Sendable {
    let id: UUID
    let type: AIRecommendationType
    let content: String
    let confidence: Double
    let insights: [String]
    let suggestedActions: [String]
    let timestamp: Date
    let round: Int?
    let playerIds: [String]
    
    init(
        id: UUID = UUID(),
        type: AIRecommendationType,
        content: String,
        confidence: Double,
        insights: [String] = [],
        suggestedActions: [String] = [],
        timestamp: Date = Date(),
        round: Int? = nil,
        playerIds: [String] = []
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.confidence = confidence
        self.insights = insights
        self.suggestedActions = suggestedActions
        self.timestamp = timestamp
        self.round = round
        self.playerIds = playerIds
    }
    
    // Simplified initializer for OpenAIService compatibility
    init(
        type: AIRecommendationType,
        content: String,
        confidence: Double,
        timestamp: Date
    ) {
        self.id = UUID()
        self.type = type
        self.content = content
        self.confidence = confidence
        self.insights = []
        self.suggestedActions = []
        self.timestamp = timestamp
        self.round = nil
        self.playerIds = []
    }
}

// MARK: - AIRecommendationType

enum AIRecommendationType: String, Codable, CaseIterable, Sendable {
    case captainAdvice = "Captain Advice"
    case tradeAdvice = "Trade Advice"
    case priceAnalysis = "Price Analysis"
    case teamStructure = "Team Structure"
}

// MARK: - OpenAIError

enum OpenAIError: Error, LocalizedError, Sendable {
    case invalidAPIKey
    case noAPIKey
    case networkError(String)
    case apiError(String)
    case invalidResponse
    case quotaExceeded
    case unauthorized
    case httpError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid OpenAI API key"
        case .noAPIKey:
            return "No OpenAI API key configured. Please add your API key in settings."
        case .networkError(let message):
            return "Network error: \(message)"
        case .apiError(let message):
            return "API error: \(message)"
        case .invalidResponse:
            return "Invalid response from OpenAI"
        case .quotaExceeded:
            return "OpenAI quota exceeded"
        case .unauthorized:
            return "Unauthorized access to OpenAI API"
        case .httpError(let code):
            return "HTTP error: \(code)"
        }
    }
}

// MARK: - AFLFantasyError

enum AFLFantasyError: Error, LocalizedError, Sendable {
    case networkError(String)
    case dataError(String)
    case apiError(String)
    case unauthorized
    case serverError

    var errorDescription: String? {
        switch self {
        case let .networkError(message):
            "Network Error: \(message)"
        case let .dataError(message):
            "Data Error: \(message)"
        case let .apiError(message):
            "API Error: \(message)"
        case .unauthorized:
            "Unauthorized access"
        case .serverError:
            "Server error occurred"
        }
    }
}
