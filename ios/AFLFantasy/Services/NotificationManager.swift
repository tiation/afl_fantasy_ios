//
//  NotificationManager.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation
import UserNotifications
import SwiftUI

// MARK: - NotificationManager

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isNotificationsEnabled = false
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization Management
    
    func requestAuthorization() async {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound, .provisional])
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
        isNotificationsEnabled = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
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
            if let error = error {
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
            if let error = error {
                print("❌ Failed to send test notification: \(error)")
            }
        }
    }
    
    // MARK: - Alert Cancellation
    
    func cancelAlerts(of type: AlertType) {
        notificationCenter.getPendingNotificationRequests { requests in
            let identifiersToCancel = requests.compactMap { request in
                if let alertType = request.content.userInfo["alertType"] as? String,
                   AlertType(rawValue: alertType) == type {
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
            return .defaultCritical
        case .high:
            return .default
        case .medium, .low:
            return .default
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
        return await notificationCenter.pendingNotificationRequests()
    }
    
    func getDeliveredNotifications() async -> [UNNotification] {
        return await notificationCenter.deliveredNotifications()
    }
}

// MARK: - AlertType Extensions

extension AlertType {
    var notificationCategory: String {
        return "ALERT_\(self.rawValue.uppercased())"
    }
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
    
    init(playerId: String, playerName: String, type: AlertType, priority: AlertPriority, title: String, message: String) {
        self.playerId = playerId
        self.playerName = playerName
        self.type = type
        self.priority = priority
        self.title = title
        self.message = message
        self.timestamp = Date()
    }
}
