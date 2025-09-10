// 🏈 AFL Fantasy Models - Core Domain
// AI recommendations, alerts, settings, user preferences, utilities

import Foundation

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

// MARK: - User Models

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
