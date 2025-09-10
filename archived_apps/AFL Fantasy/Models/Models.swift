import Foundation
import Combine

// MARK: - Error Models

enum AFLFantasyError: Error, LocalizedError {
    case networkError(String)
    case dataParsingError(String)
    case authenticationError(String)
    case notFound(String)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .dataParsingError(let message):
            return "Data Error: \(message)"
        case .authenticationError(let message):
            return "Authentication Error: \(message)"
        case .notFound(let message):
            return "Not Found: \(message)"
        case .serverError(let message):
            return "Server Error: \(message)"
        }
    }
}

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

// MARK: - Player Models

struct Player: Codable, Identifiable {
    let id: String
    let name: String
    let team: String
    let position: Position
    let price: Int
    let average: Double
    let projected: Double
    let breakeven: Int
    let consistency: ConsistencyGrade
    let priceChange: Int
    let ownership: Double?
    let injuryStatus: InjuryStatus?
    let venueStats: VenueStats?
    let formFactor: Double?
    let dvpImpact: Double?
}

enum Position: String, Codable {
    case defender = "DEF"
    case midfielder = "MID"
    case ruck = "RUC"
    case forward = "FWD"
    
    var shortName: String {
        return self.rawValue
    }
}

enum ConsistencyGrade: String, Codable {
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
}

enum InjuryStatus: String, Codable {
    case healthy = "HEALTHY"
    case questionable = "QUESTIONABLE"
    case out = "OUT"
}

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

struct CaptainSuggestion: Codable, Identifiable {
    var id: String { player.id }
    let player: Player
    let confidence: Double
    let reasoning: [String]
    let projectedPoints: Double
    let formFactor: Double
    let venueBias: Double
    let weatherImpact: Double
}

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
    let avatarURL: String?
    let bio: String?
    let favoriteTeam: AFLTeam?
    let notificationPrefs: DetailedNotificationPreferences?
    let themePreference: ThemePreference?
    
    // Convenience initializer for backward compatibility
    init(id: String, username: String, teamName: String, email: String, joinDate: Date, preferences: UserPreferences) {
        self.id = id
        self.username = username
        self.teamName = teamName
        self.email = email
        self.joinDate = joinDate
        self.preferences = preferences
        self.avatarURL = nil
        self.bio = nil
        self.favoriteTeam = nil
        self.notificationPrefs = nil
        self.themePreference = nil
    }
    
    // Full initializer
    init(id: String, username: String, teamName: String, email: String, joinDate: Date, preferences: UserPreferences, avatarURL: String?, bio: String?, favoriteTeam: AFLTeam?, notificationPrefs: DetailedNotificationPreferences?, themePreference: ThemePreference?) {
        self.id = id
        self.username = username
        self.teamName = teamName
        self.email = email
        self.joinDate = joinDate
        self.preferences = preferences
        self.avatarURL = avatarURL
        self.bio = bio
        self.favoriteTeam = favoriteTeam
        self.notificationPrefs = notificationPrefs
        self.themePreference = themePreference
    }
}

struct UserPreferences: Codable {
    let notifications: Bool
    let theme: String
    let autoSave: Bool
}

// MARK: - Enhanced Personalization Models

struct AFLTeam: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let shortName: String
    let primaryColor: String
    let secondaryColor: String
    let logoURL: String?
    
    static let allTeams: [AFLTeam] = [
        AFLTeam(id: "adelaidecrows", name: "Adelaide Crows", shortName: "ADEL", primaryColor: "#002B5C", secondaryColor: "#FFD100", logoURL: nil),
        AFLTeam(id: "brisbanelions", name: "Brisbane Lions", shortName: "BRIS", primaryColor: "#A6192E", secondaryColor: "#FFC72C", logoURL: nil),
        AFLTeam(id: "carltonblues", name: "Carlton Blues", shortName: "CARL", primaryColor: "#0E1E2E", secondaryColor: "#FFFFFF", logoURL: nil),
        AFLTeam(id: "collingwoodpies", name: "Collingwood Magpies", shortName: "COLL", primaryColor: "#000000", secondaryColor: "#FFFFFF", logoURL: nil),
        AFLTeam(id: "essendondons", name: "Essendon Bombers", shortName: "ESS", primaryColor: "#CC2031", secondaryColor: "#000000", logoURL: nil),
        AFLTeam(id: "fremantledockers", name: "Fremantle Dockers", shortName: "FREM", primaryColor: "#2E0F59", secondaryColor: "#00A6E6", logoURL: nil),
        AFLTeam(id: "geelongcats", name: "Geelong Cats", shortName: "GEEL", primaryColor: "#003A75", secondaryColor: "#FFFFFF", logoURL: nil),
        AFLTeam(id: "goldcoastsuns", name: "Gold Coast Suns", shortName: "GCS", primaryColor: "#FFD100", secondaryColor: "#CC2031", logoURL: nil),
        AFLTeam(id: "gwsgiants", name: "GWS Giants", shortName: "GWS", primaryColor: "#FF6900", secondaryColor: "#231F20", logoURL: nil),
        AFLTeam(id: "hawthornhawks", name: "Hawthorn Hawks", shortName: "HAW", primaryColor: "#4B2C20", secondaryColor: "#FFD100", logoURL: nil),
        AFLTeam(id: "melbournedemons", name: "Melbourne Demons", shortName: "MELB", primaryColor: "#CC2031", secondaryColor: "#002B5C", logoURL: nil),
        AFLTeam(id: "northmelbournekangaroos", name: "North Melbourne Kangaroos", shortName: "NMFC", primaryColor: "#003F7F", secondaryColor: "#FFFFFF", logoURL: nil),
        AFLTeam(id: "portadelaidepower", name: "Port Adelaide Power", shortName: "PORT", primaryColor: "#00B2A0", secondaryColor: "#000000", logoURL: nil),
        AFLTeam(id: "richmondtigers", name: "Richmond Tigers", shortName: "RICH", primaryColor: "#FFD100", secondaryColor: "#000000", logoURL: nil),
        AFLTeam(id: "stkildasaints", name: "St Kilda Saints", shortName: "STK", primaryColor: "#ED1C24", secondaryColor: "#000000", logoURL: nil),
        AFLTeam(id: "sydneyswans", name: "Sydney Swans", shortName: "SYD", primaryColor: "#ED1C24", secondaryColor: "#FFFFFF", logoURL: nil),
        AFLTeam(id: "westcoasteagles", name: "West Coast Eagles", shortName: "WCE", primaryColor: "#003F7F", secondaryColor: "#FFD100", logoURL: nil),
        AFLTeam(id: "westernbulldogs", name: "Western Bulldogs", shortName: "WB", primaryColor: "#CC2031", secondaryColor: "#003F7F", logoURL: nil)
    ]
    
    static func byId(_ id: String) -> AFLTeam? {
        return allTeams.first { $0.id == id }
    }
}

struct DetailedNotificationPreferences: Codable {
    let priceAlerts: Bool
    let injuryNews: Bool
    let tradeDeadlines: Bool
    let captainReminders: Bool
    let teamNews: Bool // News about user's favorite team
    let milestones: Bool
    let weeklyReports: Bool
    let aiRecommendations: Bool
    
    static let defaultPreferences = DetailedNotificationPreferences(
        priceAlerts: true,
        injuryNews: true,
        tradeDeadlines: true,
        captainReminders: false,
        teamNews: true,
        milestones: true,
        weeklyReports: true,
        aiRecommendations: true
    )
}

struct ThemePreference: Codable {
    let style: ThemeStyle
    let useTeamColors: Bool
    let accentColor: String?
    
    enum ThemeStyle: String, Codable, CaseIterable {
        case system = "system"
        case light = "light"
        case dark = "dark"
        
        var displayName: String {
            switch self {
            case .system: return "System"
            case .light: return "Light"
            case .dark: return "Dark"
            }
        }
    }
    
    static let defaultPreference = ThemePreference(
        style: .system,
        useTeamColors: false,
        accentColor: nil
    )
}

struct AIPersonalizationSettings: Codable {
    let riskTolerance: RiskTolerance
    let tradeFrequency: TradeFrequency
    let focusAreas: [FocusArea]
    let confidenceThreshold: Double // 0.0 to 1.0
    
    enum RiskTolerance: String, Codable, CaseIterable {
        case conservative = "conservative"
        case balanced = "balanced"
        case aggressive = "aggressive"
        
        var displayName: String {
            switch self {
            case .conservative: return "Conservative"
            case .balanced: return "Balanced"
            case .aggressive: return "Aggressive"
            }
        }
    }
    
    enum TradeFrequency: String, Codable, CaseIterable {
        case minimal = "minimal" // 1-2 trades per round
        case moderate = "moderate" // 2-4 trades per round
        case active = "active" // 3+ trades per round
        
        var displayName: String {
            switch self {
            case .minimal: return "Minimal (1-2 per round)"
            case .moderate: return "Moderate (2-4 per round)"
            case .active: return "Active (3+ per round)"
            }
        }
    }
    
    enum FocusArea: String, Codable, CaseIterable {
        case captainOptimization = "captain"
        case cashGeneration = "cash"
        case pointsMaximization = "points"
        case riskMinimization = "risk"
        case breakEvenTargets = "breakeven"
        
        var displayName: String {
            switch self {
            case .captainOptimization: return "Captain Selection"
            case .cashGeneration: return "Cash Generation"
            case .pointsMaximization: return "Points Maximization"
            case .riskMinimization: return "Risk Management"
            case .breakEvenTargets: return "Break-even Targets"
            }
        }
    }
    
    static let defaultSettings = AIPersonalizationSettings(
        riskTolerance: .balanced,
        tradeFrequency: .moderate,
        focusAreas: [.pointsMaximization, .cashGeneration],
        confidenceThreshold: 0.7
    )
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

// MARK: - Additional API Response Models

struct APIHealthResponse: Codable {
    let status: String
    let timestamp: String
    let playersCache: Int?
    let lastCacheUpdate: String?
    
    private enum CodingKeys: String, CodingKey {
        case status
        case timestamp
        case playersCache = "players_cached"
        case lastCacheUpdate = "last_cache_update"
    }
}

struct APIStatsResponse: Codable {
    let totalPlayers: Int
    let totalDataRows: Int
    let successfulPlayers: Int
    let failedPlayers: Int
    
    private enum CodingKeys: String, CodingKey {
        case totalPlayers = "total_players"
        case totalDataRows = "total_data_rows"
        case successfulPlayers = "successful_players"
        case failedPlayers = "failed_players"
    }
}

struct APIPlayerSummary: Codable, Identifiable {
    var id: String { playerId }
    let playerId: String
    let name: String
    let team: String?
    let position: String?
    let hasData: Bool
    let fileName: String
    
    private enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case name
        case team
        case position
        case hasData = "has_data"
        case fileName = "file_name"
    }
}

struct CashCowData: Codable, Identifiable {
    var id: String { playerId }
    let playerId: String
    let playerName: String
    let cashGenerated: Int
    let recommendation: String
    let confidence: Double?
    
    private enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case playerName = "player_name"
        case cashGenerated = "cash_generated"
        case recommendation
        case confidence
    }
}

struct CaptainSuggestionResponse: Codable, Identifiable {
    var id: String { playerId }
    let playerId: String
    let playerName: String
    let recommendation: String
    let confidence: Double
    let reasoning: String
    
    private enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case playerName = "player_name"
        case recommendation
        case confidence
        case reasoning
    }
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
