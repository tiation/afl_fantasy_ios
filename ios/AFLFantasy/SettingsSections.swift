//
//  SettingsSections.swift
//  AFL Fantasy Intelligence Platform
//
//  Settings View Section Components
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI
import UIKit
import UserNotifications

// MARK: - NotificationsSection

struct NotificationsSection: View {
    @Binding var enableBreakevenAlerts: Bool
    @Binding var enableInjuryAlerts: Bool
    @Binding var enableLateOutAlerts: Bool
    @Binding var enableTradeAlerts: Bool
    @Binding var enablePriceChangeAlerts: Bool
    @Binding var enableCaptainAlerts: Bool
    @Binding var notificationsSoundEnabled: Bool
    @Binding var notificationsBadgeEnabled: Bool
    @Binding var showingNotificationPermissions: Bool

    let handleNotificationToggle: (String, Bool) -> Void

    var body: some View {
        Section(header: Text("🔔 Notifications")) {
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Breakeven Alerts", isOn: $enableBreakevenAlerts)
                    .onChange(of: enableBreakevenAlerts) { _, newValue in
                        handleNotificationToggle("breakeven", newValue)
                    }

                Toggle("Injury Risk Alerts", isOn: $enableInjuryAlerts)
                    .onChange(of: enableInjuryAlerts) { _, newValue in
                        handleNotificationToggle("injury", newValue)
                    }

                Toggle("Late Team Changes", isOn: $enableLateOutAlerts)
                    .onChange(of: enableLateOutAlerts) { _, newValue in
                        handleNotificationToggle("lateOut", newValue)
                    }

                Toggle("Trade Recommendations", isOn: $enableTradeAlerts)
                    .onChange(of: enableTradeAlerts) { _, newValue in
                        handleNotificationToggle("trade", newValue)
                    }

                Toggle("Price Change Alerts", isOn: $enablePriceChangeAlerts)
                    .onChange(of: enablePriceChangeAlerts) { _, newValue in
                        handleNotificationToggle("priceChange", newValue)
                    }

                Toggle("Captain Suggestions", isOn: $enableCaptainAlerts)
                    .onChange(of: enableCaptainAlerts) { _, newValue in
                        handleNotificationToggle("captain", newValue)
                    }
            }

            // Notification preferences
            Toggle("Sound Effects", isOn: $notificationsSoundEnabled)
            Toggle("Badge Count", isOn: $notificationsBadgeEnabled)

            Button("Notification Permissions") {
                showingNotificationPermissions = true
            }
            .foregroundColor(.primary)
        }
    }
}

// MARK: - AIAnalysisSection

struct AIAnalysisSection: View {
    @Binding var aiConfidenceThreshold: Double
    @Binding var showLowConfidencePicks: Bool
    @Binding var enableAdvancedAnalytics: Bool
    @Binding var autoUpdateInterval: Double

    let formatUpdateInterval: (Double) -> String

    var body: some View {
        Section(header: Text("🧠 AI & Analysis")) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Confidence Threshold: \(Int(aiConfidenceThreshold))%")
                        .font(.subheadline)
                    Slider(value: $aiConfidenceThreshold, in: 60 ... 95, step: 5)
                        .tint(.orange)
                    Text("Only show picks with \(Int(aiConfidenceThreshold))%+ confidence")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Toggle("Show Low Confidence Picks", isOn: $showLowConfidencePicks)
                Toggle("Advanced Analytics", isOn: $enableAdvancedAnalytics)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Auto-Update: \(formatUpdateInterval(autoUpdateInterval))")
                        .font(.subheadline)
                    Slider(value: $autoUpdateInterval, in: 60 ... 1800, step: 60) // 1min to 30min
                        .tint(.blue)
                }
            }
        }
    }
}

// MARK: - DisplayPreferencesSection

struct DisplayPreferencesSection: View {
    @Binding var showPlayerOwnership: Bool
    @Binding var showVenueWeather: Bool
    @Binding var compactPlayerCards: Bool
    @Binding var darkModePreference: Int

    var body: some View {
        Section(header: Text("🎨 Display")) {
            Toggle("Show Player Ownership %", isOn: $showPlayerOwnership)
            Toggle("Show Venue & Weather", isOn: $showVenueWeather)
            Toggle("Compact Player Cards", isOn: $compactPlayerCards)

            Picker("Appearance", selection: $darkModePreference) {
                Text("System").tag(0)
                Text("Light").tag(1)
                Text("Dark").tag(2)
            }
        }
    }
}
