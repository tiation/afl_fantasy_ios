//
//  NotificationManager.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

// MARK: - NotificationManager

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isAuthorized = false

    private let center = UNUserNotificationCenter.current()

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await updateAuthorizationStatus()
            return granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isAuthorized = settings.authorizationStatus == .authorized
    }

    private func updateAuthorizationStatus() async {
        await checkAuthorizationStatus()
    }

    // MARK: - Player Alert Notifications

    func schedulePlayerAlert(_ alert: AlertFlag, for player: EnhancedPlayer) async {
        guard isAuthorized else {
            print("Notifications not authorized")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "🏈 AFL Fantasy Alert"
        content.body = createAlertMessage(for: alert, player: player)
        content.sound = .default
        content.badge = 1

        // Add custom data
        content.userInfo = [
            "type": "player_alert",
            "playerId": player.id,
            "playerName": player.name,
            "alertType": alert.type.rawValue,
            "priority": alert.priority.rawValue
        ]

        // Set category for action buttons
        content.categoryIdentifier = NotificationCategory.playerAlert.rawValue

        let identifier = "player_alert_\(player.id)_\(alert.type.rawValue)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)

        do {
            try await center.add(request)
            print("Scheduled notification for \(player.name): \(alert.type.rawValue)")
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }

    func scheduleBreakevenAlert(for player: EnhancedPlayer) async {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "📊 Breakeven Alert"
        content.body = "\(player.name) has reached breakeven target! Current BE: \(player.breakeven)"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = NotificationCategory.breakevenAlert.rawValue

        content.userInfo = [
            "type": "breakeven_alert",
            "playerId": player.id,
            "playerName": player.name,
            "breakeven": player.breakeven
        ]

        let identifier = "breakeven_\(player.id)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule breakeven notification: \(error)")
        }
    }

    func schedulePriceChangeAlert(for player: EnhancedPlayer) async {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "💰 Price Change Alert"

        let changeText = player.priceChange >= 0 ? "increased" : "decreased"
        content.body = "\(player.name) price has \(changeText) by \(abs(player.priceChange / 1000))k to \(player.formattedPrice)"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = NotificationCategory.priceAlert.rawValue

        content.userInfo = [
            "type": "price_change",
            "playerId": player.id,
            "playerName": player.name,
            "priceChange": player.priceChange,
            "currentPrice": player.price
        ]

        let identifier = "price_change_\(player.id)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule price change notification: \(error)")
        }
    }

    func scheduleInjuryAlert(for player: EnhancedPlayer) async {
        guard isAuthorized, player.injuryRisk.riskLevel != .low else { return }

        let content = UNMutableNotificationContent()
        content.title = "🏥 Injury Risk Alert"
        content.body = "\(player.name) has \(player.injuryRisk.riskLevel.rawValue) injury risk - monitor closely!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = NotificationCategory.injuryAlert.rawValue

        content.userInfo = [
            "type": "injury_risk",
            "playerId": player.id,
            "playerName": player.name,
            "riskLevel": player.injuryRisk.riskLevel.rawValue,
            "riskScore": player.injuryRisk.riskScore
        ]

        let identifier = "injury_risk_\(player.id)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule injury notification: \(error)")
        }
    }

    // MARK: - Captain Suggestions

    func scheduleCaptainSuggestion(_ suggestion: CaptainSuggestion) async {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "🏆 Captain Suggestion"
        content.body = "AI recommends \(suggestion.player.name) as captain with \(suggestion.confidence)% confidence!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = NotificationCategory.captainSuggestion.rawValue

        content.userInfo = [
            "type": "captain_suggestion",
            "playerId": suggestion.player.id,
            "playerName": suggestion.player.name,
            "confidence": suggestion.confidence,
            "projectedPoints": suggestion.projectedPoints
        ]

        let identifier = "captain_suggestion_\(suggestion.player.id)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule captain suggestion: \(error)")
        }
    }

    // MARK: - Round Reminders

    func scheduleRoundLockoutReminder(round: Int) async {
        guard isAuthorized else { return }

        // Schedule for 1 hour before typical AFL lockout (Thursday 7:20 PM AEST)
        var components = DateComponents()
        components.weekday = 5 // Thursday
        components.hour = 18
        components.minute = 20

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = "⏰ Round \(round) Lockout Reminder"
        content.body = "Teams lock in 1 hour! Final chance to make changes to your lineup."
        content.sound = UNNotificationSound(named: UNNotificationSoundName("alert_sound.wav"))
        content.badge = 1
        content.categoryIdentifier = NotificationCategory.lockoutReminder.rawValue

        content.userInfo = [
            "type": "lockout_reminder",
            "round": round
        ]

        let identifier = "lockout_reminder_\(round)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule lockout reminder: \(error)")
        }
    }

    // MARK: - Trade Suggestions

    func scheduleTradeSuggestion(playerOut: EnhancedPlayer, playerIn: EnhancedPlayer, score: Int) async {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "🔄 Trade Suggestion"
        content.body = "Consider trading \(playerOut.name) ➔ \(playerIn.name) (Score: \(score)%)"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = NotificationCategory.tradeSuggestion.rawValue

        content.userInfo = [
            "type": "trade_suggestion",
            "playerOutId": playerOut.id,
            "playerOutName": playerOut.name,
            "playerInId": playerIn.id,
            "playerInName": playerIn.name,
            "tradeScore": score
        ]

        let identifier = "trade_suggestion_\(playerOut.id)_\(playerIn.id)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule trade suggestion: \(error)")
        }
    }

    // MARK: - Notification Management

    func cancelAllNotifications() async {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        try? await center.setBadgeCount(0)
    }

    func cancelPlayerNotifications(for playerId: String) async {
        let pendingRequests = await center.pendingNotificationRequests()
        let identifiersToCancel = pendingRequests
            .filter { request in
                if let userInfo = request.content.userInfo,
                   let requestPlayerId = userInfo["playerId"] as? String
                {
                    return requestPlayerId == playerId
                }
                return false
            }
            .map(\.identifier)

        center.removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
    }

    // MARK: - Helpers

    private func createAlertMessage(for alert: AlertFlag, player: EnhancedPlayer) -> String {
        switch alert.type {
        case .priceDrop:
            "\(player.name) price has dropped \(abs(player.priceChange / 1000))k! Consider buying."
        case .breakEvenCliff:
            "\(player.name) is approaching breakeven cliff at \(player.breakeven)!"
        case .cashCowSell:
            "Cash cow \(player.name) has generated \(player.cashGenerated / 1000)k - consider selling!"
        case .injuryRisk:
            "\(player.name) has elevated injury risk - monitor closely."
        case .roleChange:
            "\(player.name) role change detected - review team impact."
        case .weatherRisk:
            "Weather alert for \(player.name)'s match - potential scoring impact."
        case .contractYear:
            "\(player.name) in contract year - motivation boost expected!"
        case .premiumBreakout:
            "\(player.name) showing premium breakout potential!"
        }
    }
}

// MARK: - NotificationCategory

enum NotificationCategory: String, CaseIterable {
    case playerAlert = "PLAYER_ALERT"
    case breakevenAlert = "BREAKEVEN_ALERT"
    case priceAlert = "PRICE_ALERT"
    case injuryAlert = "INJURY_ALERT"
    case captainSuggestion = "CAPTAIN_SUGGESTION"
    case lockoutReminder = "LOCKOUT_REMINDER"
    case tradeSuggestion = "TRADE_SUGGESTION"
}

// MARK: - NotificationAction

enum NotificationAction: String, CaseIterable {
    case viewPlayer = "VIEW_PLAYER"
    case dismiss = "DISMISS"
    case makeChange = "MAKE_CHANGE"
    case remindLater = "REMIND_LATER"

    var title: String {
        switch self {
        case .viewPlayer: "View Player"
        case .dismiss: "Dismiss"
        case .makeChange: "Make Change"
        case .remindLater: "Remind Later"
        }
    }
}

// MARK: - Notification Setup Extension

extension NotificationManager {
    func setupNotificationCategories() async {
        let categories = createNotificationCategories()
        await center.setNotificationCategories(Set(categories))
    }

    private func createNotificationCategories() -> [UNNotificationCategory] {
        var categories: [UNNotificationCategory] = []

        // Player Alert Category
        let playerAlertActions = [
            UNNotificationAction(
                identifier: NotificationAction.viewPlayer.rawValue,
                title: NotificationAction.viewPlayer.title,
                options: [.foreground]
            ),
            UNNotificationAction(
                identifier: NotificationAction.dismiss.rawValue,
                title: NotificationAction.dismiss.title,
                options: []
            )
        ]
        categories.append(UNNotificationCategory(
            identifier: NotificationCategory.playerAlert.rawValue,
            actions: playerAlertActions,
            intentIdentifiers: [],
            options: []
        ))

        // Breakeven Alert Category
        let breakevenActions = [
            UNNotificationAction(
                identifier: NotificationAction.viewPlayer.rawValue,
                title: NotificationAction.viewPlayer.title,
                options: [.foreground]
            ),
            UNNotificationAction(
                identifier: NotificationAction.makeChange.rawValue,
                title: NotificationAction.makeChange.title,
                options: [.foreground]
            )
        ]
        categories.append(UNNotificationCategory(
            identifier: NotificationCategory.breakevenAlert.rawValue,
            actions: breakevenActions,
            intentIdentifiers: [],
            options: []
        ))

        // Price Alert Category
        let priceActions = [
            UNNotificationAction(
                identifier: NotificationAction.viewPlayer.rawValue,
                title: NotificationAction.viewPlayer.title,
                options: [.foreground]
            ),
            UNNotificationAction(
                identifier: NotificationAction.dismiss.rawValue,
                title: NotificationAction.dismiss.title,
                options: []
            )
        ]
        categories.append(UNNotificationCategory(
            identifier: NotificationCategory.priceAlert.rawValue,
            actions: priceActions,
            intentIdentifiers: [],
            options: []
        ))

        // Captain Suggestion Category
        let captainActions = [
            UNNotificationAction(
                identifier: NotificationAction.makeChange.rawValue,
                title: "Set Captain",
                options: [.foreground]
            ),
            UNNotificationAction(
                identifier: NotificationAction.viewPlayer.rawValue,
                title: NotificationAction.viewPlayer.title,
                options: [.foreground]
            )
        ]
        categories.append(UNNotificationCategory(
            identifier: NotificationCategory.captainSuggestion.rawValue,
            actions: captainActions,
            intentIdentifiers: [],
            options: []
        ))

        // Lockout Reminder Category
        let lockoutActions = [
            UNNotificationAction(
                identifier: NotificationAction.makeChange.rawValue,
                title: "Review Team",
                options: [.foreground]
            ),
            UNNotificationAction(
                identifier: NotificationAction.remindLater.rawValue,
                title: NotificationAction.remindLater.title,
                options: []
            )
        ]
        categories.append(UNNotificationCategory(
            identifier: NotificationCategory.lockoutReminder.rawValue,
            actions: lockoutActions,
            intentIdentifiers: [],
            options: []
        ))

        // Trade Suggestion Category
        let tradeActions = [
            UNNotificationAction(
                identifier: NotificationAction.makeChange.rawValue,
                title: "Make Trade",
                options: [.foreground]
            ),
            UNNotificationAction(
                identifier: NotificationAction.viewPlayer.rawValue,
                title: "View Details",
                options: [.foreground]
            )
        ]
        categories.append(UNNotificationCategory(
            identifier: NotificationCategory.tradeSuggestion.rawValue,
            actions: tradeActions,
            intentIdentifiers: [],
            options: []
        ))

        return categories
    }
}
