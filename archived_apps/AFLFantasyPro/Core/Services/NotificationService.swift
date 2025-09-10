//
//  NotificationService.swift
//  AFL Fantasy Pro - Push Notifications
//
//  Service for managing local and remote push notifications including
//  live match updates, player alerts, captain recommendations, and injury updates.
//

import UserNotifications
import UIKit
import Combine
import Foundation

// MARK: - Notification Categories and Actions

enum NotificationCategory: String, CaseIterable {
    case liveMatch = "LIVE_MATCH"
    case playerAlert = "PLAYER_ALERT"
    case captainRecommendation = "CAPTAIN_RECOMMENDATION"
    case injuryUpdate = "INJURY_UPDATE"
    case tradingDeadline = "TRADING_DEADLINE"
    case gameReminder = "GAME_REMINDER"
    
    var identifier: String { rawValue }
    
    var actions: [UNNotificationAction] {
        switch self {
        case .liveMatch:
            return [
                UNNotificationAction(identifier: "VIEW_SCORES", title: "View Scores", options: [.foreground]),
                UNNotificationAction(identifier: "VIEW_TEAM", title: "View Team", options: [.foreground])
            ]
        case .playerAlert:
            return [
                UNNotificationAction(identifier: "VIEW_PLAYER", title: "View Player", options: [.foreground]),
                UNNotificationAction(identifier: "VIEW_TRADES", title: "Trading", options: [.foreground])
            ]
        case .captainRecommendation:
            return [
                UNNotificationAction(identifier: "SET_CAPTAIN", title: "Set Captain", options: [.foreground]),
                UNNotificationAction(identifier: "VIEW_OPTIONS", title: "View Options", options: [.foreground])
            ]
        case .injuryUpdate:
            return [
                UNNotificationAction(identifier: "VIEW_PLAYER", title: "View Player", options: [.foreground]),
                UNNotificationAction(identifier: "FIND_REPLACEMENT", title: "Find Replacement", options: [.foreground])
            ]
        case .tradingDeadline:
            return [
                UNNotificationAction(identifier: "MAKE_TRADES", title: "Make Trades", options: [.foreground])
            ]
        case .gameReminder:
            return [
                UNNotificationAction(identifier: "VIEW_FIXTURE", title: "View Fixture", options: [.foreground])
            ]
        }
    }
}

// MARK: - Notification Content Models

struct NotificationContent {
    let title: String
    let body: String
    let userInfo: [AnyHashable: Any]
    let category: NotificationCategory
    let sound: UNNotificationSound
    let badge: NSNumber?
    let threadIdentifier: String?
    
    init(title: String, 
         body: String, 
         userInfo: [AnyHashable: Any] = [:], 
         category: NotificationCategory,
         sound: UNNotificationSound = .default,
         badge: NSNumber? = nil,
         threadIdentifier: String? = nil) {
        self.title = title
        self.body = body
        self.userInfo = userInfo
        self.category = category
        self.sound = sound
        self.badge = badge
        self.threadIdentifier = threadIdentifier
    }
}

// MARK: - Notification Service

@MainActor
class NotificationService: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var deviceToken: String?
    @Published var lastNotificationError: Error?
    
    // MARK: - Private Properties
    
    private let center = UNUserNotificationCenter.current()
    private let userPreferencesService: UserPreferencesService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(userPreferencesService: UserPreferencesService) {
        self.userPreferencesService = userPreferencesService
        super.init()
        
        center.delegate = self
        setupNotificationCategories()
        checkAuthorizationStatus()
        setupObservers()
    }
    
    // MARK: - Authorization Methods
    
    func requestPermissions() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            
            if granted {
                print("✅ Notification permissions granted")
                await registerForRemoteNotifications()
            } else {
                print("❌ Notification permissions denied")
            }
            
            await checkAuthorizationStatus()
        } catch {
            print("❌ Failed to request notification permissions: \(error)")
            lastNotificationError = error
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        
        print("📱 Notification authorization status: \(authorizationStatus.description)")
    }
    
    private func registerForRemoteNotifications() async {
        await UIApplication.shared.registerForRemoteNotifications()
    }
    
    func setDeviceToken(_ tokenData: Data) {
        let token = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
        deviceToken = token
        print("📱 Device token registered: \(token.prefix(20))...")
        
        // Send token to backend
        Task {
            await sendTokenToBackend(token)
        }
    }
    
    func handleRemoteNotificationRegistrationError(_ error: Error) {
        print("❌ Remote notification registration failed: \(error)")
        lastNotificationError = error
    }
    
    // MARK: - Local Notification Methods
    
    func scheduleNotification(
        content: NotificationContent,
        trigger: UNNotificationTrigger,
        identifier: String = UUID().uuidString
    ) async throws {
        // Check if notifications are allowed for this type
        guard shouldShowNotification(category: content.category) else {
            print("🔕 Notification blocked by user preferences: \(content.category)")
            return
        }
        
        // Create notification content
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = content.title
        notificationContent.body = content.body
        notificationContent.userInfo = content.userInfo
        notificationContent.categoryIdentifier = content.category.identifier
        notificationContent.sound = content.sound
        
        if let badge = content.badge {
            notificationContent.badge = badge
        }
        
        if let threadId = content.threadIdentifier {
            notificationContent.threadIdentifier = threadId
        }
        
        // Create request
        let request = UNNotificationRequest(
            identifier: identifier,
            content: notificationContent,
            trigger: trigger
        )
        
        try await center.add(request)
        print("📅 Scheduled notification: \(content.title)")
    }
    
    func scheduleImmediateNotification(
        content: NotificationContent,
        identifier: String = UUID().uuidString
    ) async throws {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        try await scheduleNotification(content: content, trigger: trigger, identifier: identifier)
    }
    
    // MARK: - Specific Notification Types
    
    func sendLiveScoreUpdate(match: LiveMatch, players: [Player]) async {
        guard authorizationStatus == .authorized else { return }
        
        let title = "Live Match Update"
        let body = "\(match.homeTeamName) \(match.homeScore) - \(match.awayScore) \(match.awayTeamName)"
        
        let content = NotificationContent(
            title: title,
            body: body,
            userInfo: [
                "matchId": match.id,
                "homeTeam": match.homeTeamName,
                "awayTeam": match.awayTeamName,
                "homeScore": match.homeScore,
                "awayScore": match.awayScore
            ],
            category: .liveMatch,
            threadIdentifier: "live_match_\(match.id)"
        )
        
        do {
            try await scheduleImmediateNotification(
                content: content,
                identifier: "live_match_\(match.id)_\(Date().timeIntervalSince1970)"
            )
        } catch {
            print("❌ Failed to send live score notification: \(error)")
        }
    }
    
    func sendPlayerAlert(player: Player, alertType: String, message: String) async {
        guard authorizationStatus == .authorized else { return }
        
        let title = "\(player.displayName) - \(alertType)"
        let body = message
        
        let content = NotificationContent(
            title: title,
            body: body,
            userInfo: [
                "playerId": player.id,
                "playerName": player.displayName,
                "alertType": alertType
            ],
            category: .playerAlert,
            threadIdentifier: "player_\(player.id)"
        )
        
        do {
            try await scheduleImmediateNotification(
                content: content,
                identifier: "player_alert_\(player.id)_\(Date().timeIntervalSince1970)"
            )
        } catch {
            print("❌ Failed to send player alert: \(error)")
        }
    }
    
    func sendCaptainRecommendation(player: Player, reason: String) async {
        guard authorizationStatus == .authorized else { return }
        
        let title = "Captain Recommendation"
        let body = "\(player.displayName) is recommended as captain. \(reason)"
        
        let content = NotificationContent(
            title: title,
            body: body,
            userInfo: [
                "playerId": player.id,
                "playerName": player.displayName,
                "recommendation": "captain",
                "reason": reason
            ],
            category: .captainRecommendation,
            threadIdentifier: "captain_recommendation"
        )
        
        do {
            try await scheduleImmediateNotification(
                content: content,
                identifier: "captain_rec_\(Date().timeIntervalSince1970)"
            )
        } catch {
            print("❌ Failed to send captain recommendation: \(error)")
        }
    }
    
    func sendInjuryUpdate(player: Player, injuryStatus: Player.InjuryStatus) async {
        guard authorizationStatus == .authorized else { return }
        
        let title = "Injury Update"
        let body = "\(player.displayName) is now \(injuryStatus.displayName.lowercased())"
        
        let content = NotificationContent(
            title: title,
            body: body,
            userInfo: [
                "playerId": player.id,
                "playerName": player.displayName,
                "injuryStatus": injuryStatus.rawValue
            ],
            category: .injuryUpdate,
            sound: .default,
            threadIdentifier: "injury_\(player.id)"
        )
        
        do {
            try await scheduleImmediateNotification(
                content: content,
                identifier: "injury_\(player.id)_\(Date().timeIntervalSince1970)"
            )
        } catch {
            print("❌ Failed to send injury update: \(error)")
        }
    }
    
    func scheduleTradingDeadlineReminder(for round: Int, deadline: Date) async {
        guard authorizationStatus == .authorized else { return }
        
        let title = "Trading Deadline Reminder"
        let body = "Trading closes for Round \(round) in 1 hour"
        
        let content = NotificationContent(
            title: title,
            body: body,
            userInfo: [
                "round": round,
                "deadline": deadline.timeIntervalSince1970,
                "reminderType": "tradingDeadline"
            ],
            category: .tradingDeadline,
            threadIdentifier: "trading_deadline_\(round)"
        )
        
        // Schedule 1 hour before deadline
        let reminderDate = Calendar.current.date(byAdding: .hour, value: -1, to: deadline) ?? deadline
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate),
            repeats: false
        )
        
        do {
            try await scheduleNotification(
                content: content,
                trigger: trigger,
                identifier: "trading_deadline_\(round)"
            )
        } catch {
            print("❌ Failed to schedule trading deadline reminder: \(error)")
        }
    }
    
    func scheduleGameReminder(match: LiveMatch) async {
        guard authorizationStatus == .authorized else { return }
        
        let title = "Match Starting Soon"
        let body = "\(match.homeTeamName) vs \(match.awayTeamName) starts in 30 minutes"
        
        let content = NotificationContent(
            title: title,
            body: body,
            userInfo: [
                "matchId": match.id,
                "homeTeam": match.homeTeamName,
                "awayTeam": match.awayTeamName,
                "startTime": match.startTime.timeIntervalSince1970
            ],
            category: .gameReminder,
            threadIdentifier: "game_reminder_\(match.id)"
        )
        
        // Schedule 30 minutes before match start
        let reminderDate = Calendar.current.date(byAdding: .minute, value: -30, to: match.startTime) ?? match.startTime
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate),
            repeats: false
        )
        
        do {
            try await scheduleNotification(
                content: content,
                trigger: trigger,
                identifier: "game_reminder_\(match.id)"
            )
        } catch {
            print("❌ Failed to schedule game reminder: \(error)")
        }
    }
    
    // MARK: - Notification Management
    
    func cancelNotification(identifier: String) async {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("❌ Cancelled notification: \(identifier)")
    }
    
    func cancelAllNotifications() async {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        print("❌ Cancelled all notifications")
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await center.pendingNotificationRequests()
    }
    
    func getDeliveredNotifications() async -> [UNNotification] {
        return await center.deliveredNotifications()
    }
    
    func setBadgeNumber(_ number: Int) async {
        await UIApplication.shared.setApplicationIconBadgeNumber(number)
    }
    
    func clearBadge() async {
        await setBadgeNumber(0)
    }
    
    // MARK: - Private Methods
    
    private func setupNotificationCategories() {
        let categories = NotificationCategory.allCases.map { category in
            UNNotificationCategory(
                identifier: category.identifier,
                actions: category.actions,
                intentIdentifiers: [],
                options: [.customDismissAction]
            )
        }
        
        center.setNotificationCategories(Set(categories))
        print("📋 Notification categories configured: \(categories.count)")
    }
    
    private func setupObservers() {
        // Listen for preference changes
        NotificationCenter.default.publisher(for: .realTimePreferencesChanged)
            .sink { [weak self] _ in
                // Preferences updated - no immediate action needed
                print("🔄 Notification preferences updated")
            }
            .store(in: &cancellables)
    }
    
    private func shouldShowNotification(category: NotificationCategory) -> Bool {
        let preferences = userPreferencesService.preferences.notifications
        
        // Check global push notification setting
        guard preferences.enablePush else { return false }
        
        // Check specific notification type
        switch category {
        case .liveMatch:
            return preferences.liveScores
        case .playerAlert:
            return preferences.playerAlerts
        case .captainRecommendation:
            return preferences.captainRecommendations
        case .injuryUpdate:
            return preferences.injuryUpdates
        case .tradingDeadline:
            return preferences.tradingDeadlines
        case .gameReminder:
            return preferences.gameReminders
        }
    }
    
    private func sendTokenToBackend(_ token: String) async {
        // In a real app, send the device token to your backend server
        // for push notification targeting
        print("📤 Would send device token to backend: \(token.prefix(20))...")
        
        // Example implementation:
        /*
        let apiClient = AFLFantasyAPIClient.shared
        do {
            try await apiClient.registerDeviceToken(token)
            print("✅ Device token sent to backend")
        } catch {
            print("❌ Failed to send device token: \(error)")
        }
        */
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                               willPresent notification: UNNotification, 
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                               didReceive response: UNNotificationResponse, 
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier
        
        print("📱 Notification action received: \(actionIdentifier)")
        
        // Handle notification actions
        handleNotificationAction(actionIdentifier: actionIdentifier, userInfo: userInfo)
        
        completionHandler()
    }
    
    private func handleNotificationAction(actionIdentifier: String, userInfo: [AnyHashable: Any]) {
        // Handle different notification actions
        switch actionIdentifier {
        case "VIEW_SCORES":
            NotificationCenter.default.post(name: .navigateToLiveScores, object: userInfo)
        case "VIEW_TEAM":
            NotificationCenter.default.post(name: .navigateToTeam, object: userInfo)
        case "VIEW_PLAYER":
            if let playerId = userInfo["playerId"] as? String {
                NotificationCenter.default.post(name: .navigateToPlayer, object: playerId)
            }
        case "SET_CAPTAIN":
            if let playerId = userInfo["playerId"] as? String {
                NotificationCenter.default.post(name: .setCaptain, object: playerId)
            }
        case "MAKE_TRADES":
            NotificationCenter.default.post(name: .navigateToTrading, object: userInfo)
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification itself
            handleDefaultNotificationTap(userInfo: userInfo)
        default:
            break
        }
    }
    
    private func handleDefaultNotificationTap(userInfo: [AnyHashable: Any]) {
        // Navigate based on notification type
        if let matchId = userInfo["matchId"] as? String {
            NotificationCenter.default.post(name: .navigateToLiveMatch, object: matchId)
        } else if let playerId = userInfo["playerId"] as? String {
            NotificationCenter.default.post(name: .navigateToPlayer, object: playerId)
        }
    }
}

// MARK: - UNAuthorizationStatus Extension

extension UNAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        @unknown default: return "Unknown"
        }
    }
}

// MARK: - Notification Names for App Navigation

extension Notification.Name {
    static let navigateToLiveScores = Notification.Name("navigateToLiveScores")
    static let navigateToTeam = Notification.Name("navigateToTeam")
    static let navigateToPlayer = Notification.Name("navigateToPlayer")
    static let navigateToLiveMatch = Notification.Name("navigateToLiveMatch")
    static let navigateToTrading = Notification.Name("navigateToTrading")
    static let setCaptain = Notification.Name("setCaptain")
}
