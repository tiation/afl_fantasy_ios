import Foundation

struct Alert: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let message: String
    let type: AlertType
    let priority: Priority
    let timestamp: Date
    var isRead: Bool
    
    // Optional contextual information
    let playerId: String?
    let playerName: String?
    let teamCode: String?
    let matchId: String?
    let round: Int?
    
    init(
        id: String = UUID().uuidString,
        title: String,
        message: String,
        type: AlertType,
        priority: Priority,
        timestamp: Date = Date(),
        isRead: Bool = false,
        playerId: String? = nil,
        playerName: String? = nil,
        teamCode: String? = nil,
        matchId: String? = nil,
        round: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.type = type
        self.priority = priority
        self.timestamp = timestamp
        self.isRead = isRead
        self.playerId = playerId
        self.playerName = playerName
        self.teamCode = teamCode
        self.matchId = matchId
        self.round = round
    }
    
    enum AlertType: String, CaseIterable, Codable {
        case priceChange = "price_change"
        case injury = "injury"
        case teamNews = "team_news"
        case matchup = "matchup"
        case trade = "trade"
        case general = "general"
        case performance = "performance"
        case suspension = "suspension"
        
        var displayName: String {
            switch self {
            case .priceChange: return "Price Change"
            case .injury: return "Injury"
            case .teamNews: return "Team News"
            case .matchup: return "Matchup"
            case .trade: return "Trade"
            case .general: return "General"
            case .performance: return "Performance"
            case .suspension: return "Suspension"
            }
        }
        
        var iconName: String {
            switch self {
            case .priceChange: return "chart.line.uptrend.xyaxis"
            case .injury: return "cross.fill"
            case .teamNews: return "newspaper.fill"
            case .matchup: return "sportscourt.fill"
            case .trade: return "arrow.triangle.swap"
            case .general: return "info.circle.fill"
            case .performance: return "star.fill"
            case .suspension: return "exclamationmark.triangle.fill"
            }
        }
    }
    
    enum Priority: String, CaseIterable, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case critical = "critical"
        
        var displayName: String {
            switch self {
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
            case .critical: return "Critical"
            }
        }
        
        var sortOrder: Int {
            switch self {
            case .low: return 0
            case .medium: return 1
            case .high: return 2
            case .critical: return 3
            }
        }
    }
    
    // Helper computed properties
    var isHighPriority: Bool {
        priority == .high || priority == .critical
    }
    
    var ageInMinutes: Int {
        Int(Date().timeIntervalSince(timestamp) / 60)
    }
    
    var isRecent: Bool {
        ageInMinutes < 60 // Less than 1 hour old
    }
    
    var formattedTimestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

// MARK: - Sample Data

extension Alert {
    static let sampleAlerts: [Alert] = [
        Alert(
            title: "Price Rise Alert",
            message: "Marcus Bontempelli has risen $15k to $645k",
            type: .priceChange,
            priority: .medium,
            timestamp: Date().addingTimeInterval(-300), // 5 minutes ago
            playerId: "CD_I291434",
            playerName: "Marcus Bontempelli",
            teamCode: "WB"
        ),
        Alert(
            title: "Injury Update",
            message: "Patrick Dangerfield ruled out for Round 15 with hamstring injury",
            type: .injury,
            priority: .critical,
            timestamp: Date().addingTimeInterval(-1800), // 30 minutes ago
            playerId: "CD_I240803",
            playerName: "Patrick Dangerfield",
            teamCode: "GEEL"
        ),
        Alert(
            title: "Team Selection",
            message: "Tim English named in the squad for this weekend",
            type: .teamNews,
            priority: .medium,
            timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
            playerId: "CD_I295467",
            playerName: "Tim English",
            teamCode: "WB"
        ),
        Alert(
            title: "Favorable Matchup",
            message: "Clayton Oliver faces a depleted Richmond midfield",
            type: .matchup,
            priority: .high,
            timestamp: Date().addingTimeInterval(-7200), // 2 hours ago
            playerId: "CD_I295354",
            playerName: "Clayton Oliver",
            teamCode: "MELB",
            matchId: "CD_M20240001"
        ),
        Alert(
            title: "Trade Recommendation",
            message: "Consider trading out injured premium defender",
            type: .trade,
            priority: .high,
            timestamp: Date().addingTimeInterval(-10800) // 3 hours ago
        )
    ]
}
