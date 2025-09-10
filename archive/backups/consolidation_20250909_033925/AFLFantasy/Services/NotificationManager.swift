//
//  NotificationManager.swift
//  AFL Fantasy Intelligence Platform
//
//  Notification handling and scheduling
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import UIKit
import UserNotifications

// MARK: - NotificationManager

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    func scheduleCaptainSuggestion(_ suggestion: CaptainSuggestion) async {
        let content = UNMutableNotificationContent()
        content.title = "Captain Suggestion"
        content.body = "Consider \(suggestion.player.name) for captain - \(suggestion.confidence)% confidence"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "captain-\(suggestion.player.id)",
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    func scheduleRoundLockoutReminder(round: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Round Lockout Soon!"
        content.body = "Round \(round) locks out in 1 hour. Check your team!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "lockout-\(round)", content: content, trigger: trigger)

        try? await UNUserNotificationCenter.current().add(request)
    }

    func schedulePlayerAlert(_ alert: AlertFlag, for player: EnhancedPlayer) async {
        let content = UNMutableNotificationContent()
        content.title = "Player Alert"
        content.body = "\(player.name): \(alert.message)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)
        let request = UNNotificationRequest(
            identifier: "alert-\(player.id)-\(alert.type.rawValue)",
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    func scheduleInjuryAlert(for player: EnhancedPlayer) async {
        let content = UNMutableNotificationContent()
        content.title = "Injury Risk Alert"
        content.body = "\(player.name) has \(player.injuryRisk.riskLevel.rawValue.lowercased()) injury risk"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)
        let request = UNNotificationRequest(identifier: "injury-\(player.id)", content: content, trigger: trigger)

        try? await UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - NotificationDelegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func setupWithApp(_ app: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("Notification tapped: \(response.notification.request.identifier)")
        completionHandler()
    }
}
