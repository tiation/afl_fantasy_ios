//
//  NotificationDelegate.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

// MARK: - Notification Delegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    // MARK: - Foreground Notifications
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notifications even when app is in foreground
        completionHandler([.alert, .sound, .badge])
    }
    
    // MARK: - Notification Response Handling
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier
        
        // Handle different notification actions
        switch actionIdentifier {
        case NotificationAction.viewPlayer.rawValue:
            handleViewPlayerAction(userInfo: userInfo)
        case NotificationAction.makeChange.rawValue:
            handleMakeChangeAction(userInfo: userInfo)
        case NotificationAction.remindLater.rawValue:
            handleRemindLaterAction(userInfo: userInfo)
        case NotificationAction.dismiss.rawValue:
            handleDismissAction(userInfo: userInfo)
        case UNNotificationDefaultActionIdentifier:
            handleDefaultAction(userInfo: userInfo)
        case UNNotificationDismissActionIdentifier:
            handleDismissAction(userInfo: userInfo)
        default:
            break
        }
        
        completionHandler()
    }
    
    // MARK: - Action Handlers
    
    private func handleViewPlayerAction(userInfo: [AnyHashable: Any]) {
        guard let playerId = userInfo["playerId"] as? String else { return }
        
        // Post notification to navigate to player details
        NotificationCenter.default.post(
            name: .navigateToPlayer,
            object: nil,
            userInfo: ["playerId": playerId]
        )
        
        // Track analytics
        trackNotificationAction("view_player", playerId: playerId)
    }
    
    private func handleMakeChangeAction(userInfo: [AnyHashable: Any]) {
        guard let notificationType = userInfo["type"] as? String else { return }
        
        switch notificationType {
        case "captain_suggestion":
            handleCaptainChangeAction(userInfo: userInfo)
        case "trade_suggestion":
            handleTradeChangeAction(userInfo: userInfo)
        case "breakeven_alert", "price_change":
            handlePlayerChangeAction(userInfo: userInfo)
        case "lockout_reminder":
            handleTeamReviewAction(userInfo: userInfo)
        default:
            break
        }
    }
    
    private func handleCaptainChangeAction(userInfo: [AnyHashable: Any]) {
        guard let playerId = userInfo["playerId"] as? String,
              let playerName = userInfo["playerName"] as? String else { return }
        
        // Post notification to set captain
        NotificationCenter.default.post(
            name: .setCaptain,
            object: nil,
            userInfo: [
                "playerId": playerId,
                "playerName": playerName
            ]
        )
        
        trackNotificationAction("set_captain", playerId: playerId)
    }
    
    private func handleTradeChangeAction(userInfo: [AnyHashable: Any]) {
        guard let playerOutId = userInfo["playerOutId"] as? String,
              let playerInId = userInfo["playerInId"] as? String else { return }
        
        // Post notification to initiate trade
        NotificationCenter.default.post(
            name: .initiateTrade,
            object: nil,
            userInfo: [
                "playerOutId": playerOutId,
                "playerInId": playerInId
            ]
        )
        
        trackNotificationAction("make_trade", playerId: playerOutId)
    }
    
    private func handlePlayerChangeAction(userInfo: [AnyHashable: Any]) {
        guard let playerId = userInfo["playerId"] as? String else { return }
        
        // Navigate to player details for manual review
        NotificationCenter.default.post(
            name: .navigateToPlayer,
            object: nil,
            userInfo: ["playerId": playerId]
        )
        
        trackNotificationAction("review_player", playerId: playerId)
    }
    
    private func handleTeamReviewAction(userInfo: [AnyHashable: Any]) {
        // Navigate to main dashboard for team review
        NotificationCenter.default.post(
            name: .navigateToTeamReview,
            object: nil,
            userInfo: userInfo
        )
        
        trackNotificationAction("team_review", playerId: nil)
    }
    
    private func handleRemindLaterAction(userInfo: [AnyHashable: Any]) {
        guard let notificationType = userInfo["type"] as? String else { return }
        
        // Schedule reminder for later (30 minutes)
        Task {
            await scheduleReminderLater(userInfo: userInfo, type: notificationType)
        }
        
        trackNotificationAction("remind_later", playerId: userInfo["playerId"] as? String)
    }
    
    private func handleDismissAction(userInfo: [AnyHashable: Any]) {
        // Clear badge if this was the last notification
        Task {
            let pendingCount = await UNUserNotificationCenter.current().pendingNotificationRequests().count
            if pendingCount == 0 {
                try? await UNUserNotificationCenter.current().setBadgeCount(0)
            }
        }
        
        trackNotificationAction("dismiss", playerId: userInfo["playerId"] as? String)
    }
    
    private func handleDefaultAction(userInfo: [AnyHashable: Any]) {
        // Default tap - open app to relevant section
        guard let notificationType = userInfo["type"] as? String else { return }
        
        switch notificationType {
        case "player_alert", "breakeven_alert", "price_change", "injury_risk":
            if let playerId = userInfo["playerId"] as? String {
                NotificationCenter.default.post(
                    name: .navigateToPlayer,
                    object: nil,
                    userInfo: ["playerId": playerId]
                )
            }
        case "captain_suggestion":
            NotificationCenter.default.post(name: .navigateToCaptain, object: nil)
        case "trade_suggestion":
            NotificationCenter.default.post(name: .navigateToTrades, object: nil)
        case "lockout_reminder":
            NotificationCenter.default.post(name: .navigateToTeamReview, object: nil)
        default:
            break
        }
        
        trackNotificationAction("default_open", playerId: userInfo["playerId"] as? String)
    }
    
    // MARK: - Reminder Scheduling
    
    private func scheduleReminderLater(userInfo: [AnyHashable: Any], type: String) async {
        let content = UNMutableNotificationContent()
        content.title = "⏰ Reminder"
        content.body = "Don't forget to check your AFL Fantasy team!"
        content.sound = .default
        content.badge = 1
        content.userInfo = userInfo
        
        // Schedule for 30 minutes later
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30 * 60, repeats: false)
        let identifier = "reminder_later_\\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule later reminder: \\(error)")
        }
    }
    
    // MARK: - Analytics
    
    private func trackNotificationAction(_ action: String, playerId: String?) {
        // Track notification interactions for analytics
        var properties: [String: Any] = [
            "action": action,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let playerId = playerId {
            properties["player_id"] = playerId
        }
        
        // Send to analytics service (mock implementation)
        print("📊 Notification Action: \\(action), Player: \\(playerId ?? "none")")
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let navigateToPlayer = Notification.Name("navigateToPlayer")
    static let setCaptain = Notification.Name("setCaptain")
    static let initiateTrade = Notification.Name("initiateTrade")
    static let navigateToCaptain = Notification.Name("navigateToCaptain")
    static let navigateToTrades = Notification.Name("navigateToTrades")
    static let navigateToTeamReview = Notification.Name("navigateToTeamReview")
}

// MARK: - App Integration

extension NotificationDelegate {
    func setupWithApp(_ app: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        
        // Request authorization on first launch
        Task {
            let notificationManager = NotificationManager.shared
            if await notificationManager.authorizationStatus == .notDetermined {
                _ = await notificationManager.requestAuthorization()
            }
            await notificationManager.setupNotificationCategories()
        }
    }
}
