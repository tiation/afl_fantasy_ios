//
//  NotificationManager.swift
//  AFL Fantasy Intelligence Platform
//
//  Enhanced push notification management system
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Combine
import CoreLocation
import Foundation
import SwiftUI
import UIKit
import UserNotifications

// MARK: - NotificationManager

@MainActor
class NotificationManager: NSObject, ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var isEnabled: Bool = false
    @Published private(set) var pendingNotifications: [PendingNotification] = []
    @Published var isNotificationsEnabled = false

    // MARK: - Private Properties

    private let notificationCenter = UNUserNotificationCenter.current()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Singleton

    static let shared = NotificationManager()

    override private init() {
        super.init()
        setupNotificationCenter()
        Task {
            await updateAuthorizationStatus()
        }
    }

    // MARK: - Authorization Management

    func requestAuthorization() async {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [
                .alert,
                .badge,
                .sound,
                .provisional
            ])
            await updateAuthorizationStatus()

            if granted {
                print("✅ Notification authorization granted")
            } else {
                print("❌ Notification authorization denied")
            }
        } catch {
            print("❌ Failed to request notification authorization: \(error)")
        }
    }

    func checkAuthorizationStatus() {
        Task {
            await updateAuthorizationStatus()
        }
    }

    private func updateAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isNotificationsEnabled = settings.authorizationStatus == .authorized || settings
            .authorizationStatus == .provisional
    }

    func openNotificationSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    // MARK: - Alert Scheduling

    func scheduleAlert(_ alert: PlayerAlert) {
        guard isNotificationsEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = alert.title
        content.body = alert.message
        content.sound = alertSound(for: alert.priority)
        content.badge = 1
        content.categoryIdentifier = alert.type.notificationCategory

        // Add custom data
        content.userInfo = [
            "alertId": alert.id.uuidString,
            "playerId": alert.playerId,
            "alertType": alert.type.rawValue,
            "priority": alert.priority.rawValue
        ]

        // Schedule immediately for active alerts
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: alert.id.uuidString, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error {
                print("❌ Failed to schedule notification: \(error)")
            } else {
                print("✅ Scheduled notification for \(alert.playerName)")
            }
        }
    }

    func scheduleTestNotification() {
        guard isNotificationsEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "🧪 Test Notification"
        content.body = "AFL Fantasy notifications are working correctly!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "test-notification", content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error {
                print("❌ Failed to send test notification: \(error)")
            }
        }
    }

    // MARK: - Alert Cancellation

    func cancelAlerts(of type: AlertType) {
        notificationCenter.getPendingNotificationRequests { requests in
            let identifiersToCancel = requests.compactMap { request in
                if let alertType = request.content.userInfo["alertType"] as? String,
                   AlertType(rawValue: alertType) == type
                {
                    return request.identifier
                }
                return nil
            }

            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
            self.notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiersToCancel)

            print("🗑️ Cancelled \(identifiersToCancel.count) notifications of type \(type.rawValue)")
        }
    }

    func cancelAlert(with id: UUID) {
        let identifier = id.uuidString
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    func cancelAllAlerts() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        print("🗑️ Cancelled all notifications")
    }

    // MARK: - Notification Categories & Actions

    func setupNotificationCategories() {
        let categories = AlertType.allCases.map { alertType in
            createNotificationCategory(for: alertType)
        }

        notificationCenter.setNotificationCategories(Set(categories))
    }

    private func createNotificationCategory(for alertType: AlertType) -> UNNotificationCategory {
        var actions: [UNNotificationAction] = []

        // Common actions
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Dismiss",
            options: []
        )

        let viewAction = UNNotificationAction(
            identifier: "VIEW",
            title: "View Details",
            options: [.foreground]
        )

        // Type-specific actions
        switch alertType {
        case .priceDrop, .breakEvenCliff:
            let tradeAction = UNNotificationAction(
                identifier: "TRADE",
                title: "Consider Trade",
                options: [.foreground]
            )
            actions = [tradeAction, viewAction, dismissAction]

        case .injuryRisk:
            let checkTeamAction = UNNotificationAction(
                identifier: "CHECK_TEAM",
                title: "Check Team News",
                options: [.foreground]
            )
            actions = [checkTeamAction, viewAction, dismissAction]

        case .cashCowSell:
            let sellAction = UNNotificationAction(
                identifier: "SELL",
                title: "Sell Player",
                options: [.foreground]
            )
            actions = [sellAction, viewAction, dismissAction]

        default:
            actions = [viewAction, dismissAction]
        }

        return UNNotificationCategory(
            identifier: alertType.notificationCategory,
            actions: actions,
            intentIdentifiers: [],
            options: []
        )
    }

    // MARK: - Notification Sounds & Styling

    private func alertSound(for priority: AlertPriority) -> UNNotificationSound {
        switch priority {
        case .critical:
            .defaultCritical
        case .high:
            .default
        case .medium, .low:
            .default
        }
    }

    // MARK: - Badge Management

    func updateBadgeCount(_ count: Int) {
        Task {
            try? await UNUserNotificationCenter.current().setBadgeCount(count)
        }
    }

    func clearBadge() {
        updateBadgeCount(0)
    }

    // MARK: - Notification History

    func getPendingNotifications() async -> [UNNotificationRequest] {
        await notificationCenter.pendingNotificationRequests()
    }

    func getDeliveredNotifications() async -> [UNNotification] {
        await notificationCenter.deliveredNotifications()
    }
}

// MARK: - AlertType Extensions

extension AlertType {
    var notificationCategory: String {
        "ALERT_\(rawValue.uppercased())"
    }
}

// MARK: - Enhanced Notification Features

extension NotificationManager {
    // MARK: - Setup

    private func setupNotificationCenter() {
        notificationCenter.delegate = self
        setupEnhancedNotificationCategories()
    }

    private func setupEnhancedNotificationCategories() {
        // Define notification actions
        let viewAction = UNNotificationAction(
            identifier: "VIEW_ACTION",
            title: "View",
            options: [.foreground]
        )

        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: []
        )

        let setCaptainAction = UNNotificationAction(
            identifier: "SET_CAPTAIN_ACTION",
            title: "Set Captain",
            options: [.foreground]
        )

        let makeTradeAction = UNNotificationAction(
            identifier: "MAKE_TRADE_ACTION",
            title: "Make Trade",
            options: [.foreground]
        )

        // Define notification categories
        let captainCategory = UNNotificationCategory(
            identifier: AFLNotificationType.captainSuggestion.rawValue,
            actions: [setCaptainAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        let tradeCategory = UNNotificationCategory(
            identifier: AFLNotificationType.tradeRecommendation.rawValue,
            actions: [makeTradeAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        let priceChangeCategory = UNNotificationCategory(
            identifier: AFLNotificationType.priceChange.rawValue,
            actions: [viewAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        let injuryAlertCategory = UNNotificationCategory(
            identifier: AFLNotificationType.injuryAlert.rawValue,
            actions: [viewAction, dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        // Register categories
        notificationCenter.setNotificationCategories([
            captainCategory,
            tradeCategory,
            priceChangeCategory,
            injuryAlertCategory
        ])
    }

    // MARK: - Enhanced Authorization

    func requestEnhancedAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                authorizationStatus = granted ? .authorized : .denied
                isEnabled = granted
                isNotificationsEnabled = granted
            }

            if granted {
                await registerForRemoteNotifications()
            }

            return granted
        } catch {
            print("❌ Failed to request notification authorization: \(error)")
            return false
        }
    }

    private func registerForRemoteNotifications() async {
        await UIApplication.shared.registerForRemoteNotifications()
    }

    // MARK: - Enhanced Local Notifications

    func scheduleNotification(_ notification: AFLNotification) async -> Bool {
        guard isEnabled else {
            print("⚠️ Notifications not enabled")
            return false
        }

        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = notification.soundEnabled ? .default : nil
        content.badge = await NSNumber(value: getNextBadgeCount())
        content.categoryIdentifier = notification.type.rawValue
        content.userInfo = notification.userInfo

        // Add custom data
        content.userInfo["notificationId"] = notification.id
        content.userInfo["type"] = notification.type.rawValue

        let trigger: UNNotificationTrigger = switch notification.trigger {
        case .immediate:
            UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        case let .timeInterval(interval):
            UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        case let .dateComponents(dateComponents):
            UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        }

        let request = UNNotificationRequest(
            identifier: notification.id,
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)

            // Track pending notification
            let pending = PendingNotification(
                id: notification.id,
                type: notification.type,
                scheduledDate: Date(),
                deliveryDate: notification.deliveryDate
            )
            pendingNotifications.append(pending)

            print("✅ Scheduled notification: \(notification.title)")
            return true
        } catch {
            print("❌ Failed to schedule notification: \(error)")
            return false
        }
    }

    func cancelNotification(withId id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        pendingNotifications.removeAll { $0.id == id }
        print("🗑️ Cancelled notification: \(id)")
    }

    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        pendingNotifications.removeAll()
        setBadgeCount(0)
        print("🗑️ Cancelled all notifications")
    }

    // MARK: - Enhanced Badge Management

    private func getNextBadgeCount() async -> Int {
        let delivered = await notificationCenter.deliveredNotifications()
        return delivered.count + 1
    }

    func setBadgeCount(_ count: Int) {
        UIApplication.shared.applicationIconBadgeNumber = count
    }

    func clearBadge() {
        setBadgeCount(0)
    }

    // MARK: - Fantasy-Specific Notifications

    func scheduleBreakevenAlert(for player: EnhancedPlayer) async {
        let notification = AFLNotification(
            id: "breakeven_\(player.id)",
            type: .breakevenAlert,
            title: "Breakeven Alert",
            body: "\(player.name) is approaching breakeven (\(player.breakeven))",
            trigger: .immediate,
            userInfo: ["playerId": player.id, "playerName": player.name]
        )

        _ = await scheduleNotification(notification)
    }

    func scheduleInjuryAlert(for player: EnhancedPlayer, severity: String) async {
        let notification = AFLNotification(
            id: "injury_\(player.id)",
            type: .injuryAlert,
            title: "Injury Alert",
            body: "\(player.name) has a \(severity) injury concern",
            trigger: .immediate,
            userInfo: ["playerId": player.id, "playerName": player.name, "severity": severity]
        )

        _ = await scheduleNotification(notification)
    }

    func schedulePriceChangeAlert(for player: EnhancedPlayer, change: Int) async {
        let changeText = change > 0 ? "+$\(change / 1000)k" : "-$\(abs(change) / 1000)k"
        let emoji = change > 0 ? "📈" : "📉"

        let notification = AFLNotification(
            id: "price_\(player.id)",
            type: .priceChange,
            title: "\(emoji) Price Change",
            body: "\(player.name) \(changeText) (\(player.formattedPrice))",
            trigger: .immediate,
            userInfo: ["playerId": player.id, "playerName": player.name, "change": change]
        )

        _ = await scheduleNotification(notification)
    }

    func scheduleCaptainSuggestion(_ suggestion: CaptainSuggestion) async {
        let notification = AFLNotification(
            id: "captain_\(suggestion.id)",
            type: .captainSuggestion,
            title: "⭐ Captain Suggestion",
            body: "\(suggestion.player.name) projected for \(suggestion.projectedPoints) points (\(suggestion.confidence)% confidence)",
            trigger: .immediate,
            userInfo: [
                "playerId": suggestion.player.id,
                "playerName": suggestion.player.name,
                "projectedPoints": suggestion.projectedPoints
            ]
        )

        _ = await scheduleNotification(notification)
    }

    func scheduleWeeklyReminders() async {
        // Clear existing weekly reminders
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [
            "weekly_team_review",
            "weekly_captain_reminder"
        ])

        // Schedule team review reminder (Sunday 6 PM)
        var teamReviewComponents = DateComponents()
        teamReviewComponents.weekday = 1 // Sunday
        teamReviewComponents.hour = 18 // 6 PM

        let teamReviewNotification = AFLNotification(
            id: "weekly_team_review",
            type: .teamReview,
            title: "🏆 Weekly Team Review",
            body: "Review your team performance and plan trades for the upcoming round",
            trigger: .dateComponents(teamReviewComponents)
        )

        _ = await scheduleNotification(teamReviewNotification)

        // Schedule captain reminder (Thursday 6 PM - typical team announcement day)
        var captainReminderComponents = DateComponents()
        captainReminderComponents.weekday = 5 // Thursday
        captainReminderComponents.hour = 18 // 6 PM

        let captainReminderNotification = AFLNotification(
            id: "weekly_captain_reminder",
            type: .captainReminder,
            title: "⭐ Captain Selection",
            body: "Team lists are out! Time to finalize your captain choice",
            trigger: .dateComponents(captainReminderComponents)
        )

        _ = await scheduleNotification(captainReminderNotification)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier

        print("📱 Notification action: \(actionIdentifier)")

        // Handle different actions
        switch actionIdentifier {
        case "VIEW_ACTION":
            handleViewAction(userInfo: userInfo)
        case "SET_CAPTAIN_ACTION":
            handleSetCaptainAction(userInfo: userInfo)
        case "MAKE_TRADE_ACTION":
            handleMakeTradeAction(userInfo: userInfo)
        case UNNotificationDefaultActionIdentifier:
            handleDefaultAction(userInfo: userInfo)
        default:
            break
        }

        completionHandler()
    }

    private func handleViewAction(userInfo: [AnyHashable: Any]) {
        // Navigate to appropriate view
        NotificationCenter.default.post(name: .navigateToView, object: userInfo)
    }

    private func handleSetCaptainAction(userInfo: [AnyHashable: Any]) {
        // Quick captain setting
        if let playerName = userInfo["playerName"] as? String {
            NotificationCenter.default.post(
                name: .setCaptainFromNotification,
                object: playerName
            )
        }
    }

    private func handleMakeTradeAction(userInfo: [AnyHashable: Any]) {
        // Navigate to trade view with pre-selected players
        NotificationCenter.default.post(name: .navigateToTrade, object: userInfo)
    }

    private func handleDefaultAction(userInfo: [AnyHashable: Any]) {
        // Default tap action - navigate to relevant screen
        handleViewAction(userInfo: userInfo)
    }
}

// MARK: - Supporting Types

struct AFLNotification {
    let id: String
    let type: AFLNotificationType
    let title: String
    let body: String
    let trigger: AFLNotificationTrigger
    let soundEnabled: Bool
    let userInfo: [String: Any]
    let deliveryDate: Date?

    init(
        id: String,
        type: AFLNotificationType,
        title: String,
        body: String,
        trigger: AFLNotificationTrigger,
        soundEnabled: Bool = true,
        userInfo: [String: Any] = [:],
        deliveryDate: Date? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.body = body
        self.trigger = trigger
        self.soundEnabled = soundEnabled
        self.userInfo = userInfo
        self.deliveryDate = deliveryDate ?? Date()
    }
}

enum AFLNotificationType: String, CaseIterable {
    case priceChange = "PRICE_CHANGE"
    case injuryAlert = "INJURY_ALERT"
    case breakevenAlert = "BREAKEVEN_ALERT"
    case captainSuggestion = "CAPTAIN_SUGGESTION"
    case tradeRecommendation = "TRADE_RECOMMENDATION"
    case cashCowAlert = "CASH_COW_ALERT"
    case teamReview = "TEAM_REVIEW"
    case captainReminder = "CAPTAIN_REMINDER"
    case lateOut = "LATE_OUT"
    case emergencyTrade = "EMERGENCY_TRADE"
}

enum AFLNotificationTrigger {
    case immediate
    case timeInterval(TimeInterval)
    case dateComponents(DateComponents)
}

struct PendingNotification: Identifiable {
    let id: String
    let type: AFLNotificationType
    let scheduledDate: Date
    let deliveryDate: Date?
}

// MARK: - Notification Names

extension Notification.Name {
    static let navigateToView = Notification.Name("navigateToView")
    static let setCaptainFromNotification = Notification.Name("setCaptainFromNotification")
    static let navigateToTrade = Notification.Name("navigateToTrade")
}

// MARK: - PlayerAlert Model (if not already defined elsewhere)

struct PlayerAlert: Identifiable, Codable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let type: AlertType
    let priority: AlertPriority
    let title: String
    let message: String
    let timestamp: Date
    var isRead = false

    init(
        playerId: String,
        playerName: String,
        type: AlertType,
        priority: AlertPriority,
        title: String,
        message: String
    ) {
        self.playerId = playerId
        self.playerName = playerName
        self.type = type
        self.priority = priority
        self.title = title
        self.message = message
        timestamp = Date()
    }
}
