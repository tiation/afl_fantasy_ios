//
//  NotificationSettingsView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI
import UserNotifications

// MARK: - NotificationSettingsView

struct NotificationSettingsView: View {
    @Binding var enableBreakevenAlerts: Bool
    @Binding var enableInjuryAlerts: Bool
    @Binding var enableLateOutAlerts: Bool
    @Binding var enablePriceAlerts: Bool
    @Binding var enableCaptainAlerts: Bool
    @Binding var enableTradeAlerts: Bool
    @Binding var enableCashCowAlerts: Bool
    @Binding var enableWeatherAlerts: Bool
    @Binding var enableRoleChangeAlerts: Bool

    @State private var notificationsEnabled = false
    @State private var showingPermissionAlert = false

    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        Form {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("System Notifications")
                            .font(.headline)
                        Text(notificationsEnabled ? "Enabled" : "Disabled")
                            .font(.caption)
                            .foregroundColor(notificationsEnabled ? .green : .red)
                    }

                    Spacer()

                    Button(notificationsEnabled ? "Manage" : "Enable") {
                        if notificationsEnabled {
                            openSystemSettings()
                        } else {
                            requestNotificationPermission()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
            } footer: {
                Text("System notification permission is required to receive alerts outside the app.")
            }

            Section("🏈 Player Alerts") {
                NotificationToggle(
                    isOn: $enableBreakevenAlerts,
                    icon: "chart.line.uptrend.xyaxis",
                    iconColor: .blue,
                    title: "Breakeven Alerts",
                    subtitle: "Player approaching breakeven cliff or safe zone"
                )

                NotificationToggle(
                    isOn: $enableInjuryAlerts,
                    icon: "cross.case",
                    iconColor: .red,
                    title: "Injury Risk Alerts",
                    subtitle: "Elevated injury risk or fitness concerns"
                )

                NotificationToggle(
                    isOn: $enableLateOutAlerts,
                    icon: "clock.badge.exclamationmark",
                    iconColor: .orange,
                    title: "Late Out Alerts",
                    subtitle: "Last-minute player withdrawals before lockout"
                )

                NotificationToggle(
                    isOn: $enablePriceAlerts,
                    icon: "dollarsign.circle",
                    iconColor: .green,
                    title: "Price Change Alerts",
                    subtitle: "Significant price rises or drops"
                )
            }

            Section("🧠 AI Intelligence") {
                NotificationToggle(
                    isOn: $enableCaptainAlerts,
                    icon: "crown",
                    iconColor: .yellow,
                    title: "Captain Suggestions",
                    subtitle: "High-confidence AI captain recommendations"
                )

                NotificationToggle(
                    isOn: $enableTradeAlerts,
                    icon: "arrow.triangle.2.circlepath",
                    iconColor: .blue,
                    title: "Trade Opportunities",
                    subtitle: "Optimal trade suggestions and player movements"
                )

                NotificationToggle(
                    isOn: $enableCashCowAlerts,
                    icon: "banknote",
                    iconColor: .green,
                    title: "Cash Cow Signals",
                    subtitle: "Rookie sell signals and cash generation milestones"
                )
            }

            Section("🌦️ Advanced Alerts") {
                NotificationToggle(
                    isOn: $enableWeatherAlerts,
                    icon: "cloud.rain",
                    iconColor: .gray,
                    title: "Weather Alerts",
                    subtitle: "Adverse weather conditions affecting performance"
                )

                NotificationToggle(
                    isOn: $enableRoleChangeAlerts,
                    icon: "person.2.crop.square.stack",
                    iconColor: .purple,
                    title: "Role Change Alerts",
                    subtitle: "Position changes and tactical shifts"
                )
            } footer: {
                Text("Advanced alerts may be more frequent and are recommended for experienced users.")
            }

            Section("⚙️ Alert Behavior") {
                HStack {
                    Text("Alert Frequency")
                    Spacer()
                    Text("Balanced")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Quiet Hours")
                    Spacer()
                    Text("10 PM - 7 AM")
                        .foregroundColor(.secondary)
                }

                Button("Test Notification") {
                    impactFeedback.impactOccurred()
                    sendTestNotification()
                }
                .foregroundColor(.blue)
            }
        }
        .navigationTitle("🔔 Notifications")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            checkNotificationStatus()
        }
        .alert("Notifications Disabled", isPresented: $showingPermissionAlert) {
            Button("Settings") { openSystemSettings() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enable notifications in Settings to receive AFL Fantasy alerts.")
        }
    }

    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    notificationsEnabled = true
                } else {
                    showingPermissionAlert = true
                }
            }
        }
    }

    private func openSystemSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    private func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🏈 AFL Fantasy Test"
        content.body = "This is a test notification from your AFL Fantasy Intelligence app!"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "test_notification",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )

        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - NotificationToggle

struct NotificationToggle: View {
    @Binding var isOn: Bool
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .onChange(of: isOn) { _, _ in
            impactFeedback.impactOccurred()
        }
    }
}

#Preview {
    NavigationView {
        NotificationSettingsView(
            enableBreakevenAlerts: .constant(true),
            enableInjuryAlerts: .constant(true),
            enableLateOutAlerts: .constant(false),
            enablePriceAlerts: .constant(true),
            enableCaptainAlerts: .constant(true),
            enableTradeAlerts: .constant(false),
            enableCashCowAlerts: .constant(true),
            enableWeatherAlerts: .constant(false),
            enableRoleChangeAlerts: .constant(false)
        )
    }
}
