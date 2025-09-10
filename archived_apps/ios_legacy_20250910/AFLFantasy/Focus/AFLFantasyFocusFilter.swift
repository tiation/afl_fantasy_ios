import Foundation
import AppIntents

// MARK: - Fantasy Focus Filter
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct AFLFantasyFocusFilter: SetFocusFilterIntent {
    static var title: LocalizedStringResource = "AFL Fantasy Focus"
    static var description = IntentDescription("Filter notifications to show only AFL Fantasy updates during game time")
    
    @Parameter(title: "Game Day Mode", description: "Enable game day notifications only")
    var gameDayMode: Bool
    
    @Parameter(title: "Team Updates Only", description: "Show only updates for your fantasy team")
    var teamUpdatesOnly: Bool
    
    @Parameter(title: "Trade Window", description: "Show trade-related notifications")
    var tradeWindow: Bool
    
    static var parameterSummary: some ParameterSummary {
        Switch(\.$gameDayMode) {
            Case(true) {
                Summary("Enable AFL Fantasy game day focus")
            }
            Case(false) {
                Summary("Disable AFL Fantasy focus") {
                    \.$teamUpdatesOnly
                    \.$tradeWindow
                }
            }
        }
    }
    
    func perform() async throws -> some IntentResult {
        // Configure focus filter based on parameters
        var filterConfig = FocusFilterConfig()
        
        if gameDayMode {
            filterConfig.allowedNotifications = [
                .fantasyScoreUpdates,
                .captainPerformance,
                .emergencyUpdates,
                .roundResults
            ]
            filterConfig.disallowedNotifications = [
                .socialMedia,
                .generalNews,
                .nonFantasyPush
            ]
        }
        
        if teamUpdatesOnly {
            filterConfig.allowedNotifications.append(.teamSpecificUpdates)
            filterConfig.restrictToUserTeam = true
        }
        
        if tradeWindow {
            filterConfig.allowedNotifications.append(contentsOf: [
                .tradeDeadlineReminders,
                .priceChanges,
                .injuryUpdates
            ])
        }
        
        // Apply focus filter configuration
        await applyFocusFilter(config: filterConfig)
        
        let statusMessage = gameDayMode ? 
            "AFL Fantasy game day focus enabled" : 
            "AFL Fantasy focus configured"
            
        return .result(dialog: IntentDialog(statusMessage))
    }
    
    private func applyFocusFilter(config: FocusFilterConfig) async {
        // In a real implementation, this would configure the Focus Filter
        // through iOS Focus system APIs
        print("Applying focus filter with config: \(config)")
    }
}

// MARK: - Focus Filter Configuration
struct FocusFilterConfig {
    var allowedNotifications: [NotificationType] = []
    var disallowedNotifications: [NotificationType] = []
    var restrictToUserTeam: Bool = false
    var quietHours: DateInterval? = nil
}

enum NotificationType {
    case fantasyScoreUpdates
    case captainPerformance
    case emergencyUpdates
    case roundResults
    case teamSpecificUpdates
    case tradeDeadlineReminders
    case priceChanges
    case injuryUpdates
    case socialMedia
    case generalNews
    case nonFantasyPush
}

// MARK: - Game Day Detection Intent
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct DetectGameDayIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Game Day Status"
    static var description = IntentDescription("Check if today is an AFL game day and automatically enable fantasy focus")
    
    @Parameter(title: "Auto Enable Focus", description: "Automatically enable focus if game day detected", default: true)
    var autoEnableFocus: Bool
    
    func perform() async throws -> some IntentResult {
        let isGameDay = await checkIfGameDay()
        let gamesInfo = await getTodaysGames()
        
        if isGameDay && autoEnableFocus {
            // Enable fantasy focus automatically
            let focusFilter = AFLFantasyFocusFilter()
            focusFilter.gameDayMode = true
            focusFilter.teamUpdatesOnly = true
            focusFilter.tradeWindow = false
            
            try await focusFilter.perform()
            
            return .result(dialog: IntentDialog("Game day detected! Fantasy focus enabled. \(gamesInfo.count) games today"))
        } else if isGameDay {
            return .result(dialog: IntentDialog("Game day detected with \(gamesInfo.count) games today"))
        } else {
            return .result(dialog: IntentDialog("No AFL games today"))
        }
    }
    
    private func checkIfGameDay() async -> Bool {
        // Check AFL fixture for today's games
        // This would integrate with AFL API or MasterDataService
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        
        // AFL games are typically Thursday-Monday
        return weekday >= 2 && weekday <= 6 // Mon-Fri approximation
    }
    
    private func getTodaysGames() async -> [AFLGame] {
        // Fetch today's AFL games from fixture
        return [
            AFLGame(homeTeam: "Richmond", awayTeam: "Collingwood", startTime: Date()),
            AFLGame(homeTeam: "Carlton", awayTeam: "Essendon", startTime: Date())
        ]
    }
}

// MARK: - Supporting Models
struct AFLGame {
    let homeTeam: String
    let awayTeam: String
    let startTime: Date
}

// MARK: - Trade Window Focus Intent
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct TradeWindowFocusIntent: AppIntent {
    static var title: LocalizedStringResource = "Trade Window Focus"
    static var description = IntentDescription("Enable focus mode during AFL Fantasy trade windows")
    
    @Parameter(title: "Hours Before Deadline", description: "Hours before trade deadline to enable focus", default: 2)
    var hoursBeforeDeadline: Int
    
    func perform() async throws -> some IntentResult {
        let tradeDeadline = await getNextTradeDeadline()
        let now = Date()
        
        let hoursUntilDeadline = Calendar.current.dateComponents([.hour], from: now, to: tradeDeadline).hour ?? 0
        
        if hoursUntilDeadline <= hoursBeforeDeadline {
            // Enable trade-focused filter
            let focusFilter = AFLFantasyFocusFilter()
            focusFilter.gameDayMode = false
            focusFilter.teamUpdatesOnly = false
            focusFilter.tradeWindow = true
            
            try await focusFilter.perform()
            
            return .result(dialog: IntentDialog("Trade window focus enabled. \(hoursUntilDeadline) hours until deadline"))
        } else {
            return .result(dialog: IntentDialog("Trade deadline is in \(hoursUntilDeadline) hours"))
        }
    }
    
    private func getNextTradeDeadline() async -> Date {
        // Calculate next trade deadline (typically Thursday night before next round)
        let calendar = Calendar.current
        let now = Date()
        
        // Find next Thursday at 7:30 PM AEST
        guard let nextThursday = calendar.nextDate(after: now, matching: DateComponents(weekday: 5), matchingPolicy: .nextTime) else {
            return now.addingTimeInterval(86400 * 7) // Fallback to next week
        }
        
        return calendar.date(bySettingHour: 19, minute: 30, second: 0, of: nextThursday) ?? nextThursday
    }
}

// MARK: - Fantasy Notification Categories
extension UNNotificationCategory {
    static let fantasyScoreUpdate = UNNotificationCategory(
        identifier: "FANTASY_SCORE_UPDATE",
        actions: [
            UNNotificationAction(identifier: "VIEW_TEAM", title: "View Team", options: .foreground),
            UNNotificationAction(identifier: "CHECK_CAPTAIN", title: "Captain Score", options: [])
        ],
        intentIdentifiers: [],
        options: []
    )
    
    static let tradeDeadlineReminder = UNNotificationCategory(
        identifier: "TRADE_DEADLINE_REMINDER",
        actions: [
            UNNotificationAction(identifier: "OPEN_TRADES", title: "View Trades", options: .foreground),
            UNNotificationAction(identifier: "SNOOZE_REMINDER", title: "Remind in 30 min", options: [])
        ],
        intentIdentifiers: [],
        options: []
    )
    
    static let injuryAlert = UNNotificationCategory(
        identifier: "INJURY_ALERT",
        actions: [
            UNNotificationAction(identifier: "VIEW_EMERGENCY", title: "Emergency Trades", options: .foreground),
            UNNotificationAction(identifier: "VIEW_PLAYER", title: "Player Details", options: [])
        ],
        intentIdentifiers: [],
        options: [.customDismissAction]
    )
}
