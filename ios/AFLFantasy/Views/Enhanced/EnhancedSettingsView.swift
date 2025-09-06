//
//  EnhancedSettingsView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI
import UserNotifications

// MARK: - EnhancedSettingsView

struct EnhancedSettingsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var alertService = AlertService()
    @StateObject private var notificationManager = NotificationManager.shared

    // Settings State
    @AppStorage("enableBreakevenAlerts") private var enableBreakevenAlerts = true
    @AppStorage("enableInjuryAlerts") private var enableInjuryAlerts = true
    @AppStorage("enableLateOutAlerts") private var enableLateOutAlerts = true
    @AppStorage("enablePriceAlerts") private var enablePriceAlerts = true
    @AppStorage("enableCaptainAlerts") private var enableCaptainAlerts = true
    @AppStorage("enableTradeAlerts") private var enableTradeAlerts = true
    @AppStorage("enableCashCowAlerts") private var enableCashCowAlerts = true
    @AppStorage("enableWeatherAlerts") private var enableWeatherAlerts = false
    @AppStorage("enableRoleChangeAlerts") private var enableRoleChangeAlerts = false

    // AI & Analysis Settings
    @AppStorage("captainConfidenceThreshold") private var captainConfidenceThreshold = 70.0
    @AppStorage("tradeScoreThreshold") private var tradeScoreThreshold = 75.0
    @AppStorage("priceChangeThreshold") private var priceChangeThreshold = 10000.0
    @AppStorage("enableAIRecommendations") private var enableAIRecommendations = true
    @AppStorage("enableAdvancedAnalytics") private var enableAdvancedAnalytics = true

    // UI Preferences
    @AppStorage("refreshInterval") private var refreshInterval = 30.0
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("compactMode") private var compactMode = false

    // Modal States
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfUse = false
    @State private var showingNotificationSettings = false
    @State private var showingDataManagement = false
    @State private var showingAISettings = false
    @State private var showingAdvancedSettings = false
    @State private var showingAbout = false

    // Data States
    @State private var cacheSize = "12.4 MB"
    @State private var lastDataUpdate = Date()
    @State private var monitoredPlayersCount = 5
    @State private var totalActiveAlerts = 3

    // Haptic feedback
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    private let successFeedback = UINotificationFeedbackGenerator()

    var body: some View {
        NavigationView {
            Form {
                // Quick Status Section
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("System Status")
                                .font(.headline)
                            Text("All systems operational")
                                .font(.caption)
                                .foregroundColor(.green)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(totalActiveAlerts)")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.orange)
                            Text("Active Alerts")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Notifications & Alerts
                Section("🔔 Smart Alerts") {
                    NavigationLink(destination: NotificationSettingsView(
                        enableBreakevenAlerts: $enableBreakevenAlerts,
                        enableInjuryAlerts: $enableInjuryAlerts,
                        enableLateOutAlerts: $enableLateOutAlerts,
                        enablePriceAlerts: $enablePriceAlerts,
                        enableCaptainAlerts: $enableCaptainAlerts,
                        enableTradeAlerts: $enableTradeAlerts,
                        enableCashCowAlerts: $enableCashCowAlerts,
                        enableWeatherAlerts: $enableWeatherAlerts,
                        enableRoleChangeAlerts: $enableRoleChangeAlerts
                    )) {
                        SettingsRow(
                            icon: "bell.fill",
                            iconColor: .blue,
                            title: "Notification Preferences",
                            subtitle: alertSummary,
                            showChevron: true
                        )
                    }

                    HStack {
                        SettingsRow(
                            icon: "list.bullet.circle",
                            iconColor: .orange,
                            title: "Active Alerts",
                            subtitle: "\(totalActiveAlerts) requiring attention",
                            showChevron: false
                        )

                        Spacer()

                        Button("View All") {
                            impactFeedback.impactOccurred()
                            // Navigate to alerts view
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }

                    HStack {
                        SettingsRow(
                            icon: "eye.circle",
                            iconColor: .purple,
                            title: "Monitored Players",
                            subtitle: "\(monitoredPlayersCount) players tracked",
                            showChevron: false
                        )

                        Spacer()

                        Button("Manage") {
                            impactFeedback.impactOccurred()
                            // Navigate to watchlist
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }

                // AI & Intelligence
                Section("🧠 AI Intelligence") {
                    NavigationLink(destination: AISettingsView(
                        captainConfidenceThreshold: $captainConfidenceThreshold,
                        tradeScoreThreshold: $tradeScoreThreshold,
                        enableAIRecommendations: $enableAIRecommendations,
                        enableAdvancedAnalytics: $enableAdvancedAnalytics
                    )) {
                        SettingsRow(
                            icon: "brain.head.profile",
                            iconColor: .orange,
                            title: "AI Recommendations",
                            subtitle: enableAIRecommendations ? "Enhanced analysis enabled" : "Basic mode",
                            showChevron: true
                        )
                    }

                    HStack {
                        SettingsRow(
                            icon: "target",
                            iconColor: .green,
                            title: "Captain AI Confidence",
                            subtitle: "Minimum \(Int(captainConfidenceThreshold))%",
                            showChevron: false
                        )

                        Spacer()

                        Text("\(Int(captainConfidenceThreshold))%")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        SettingsRow(
                            icon: "arrow.triangle.2.circlepath.circle",
                            iconColor: .blue,
                            title: "Trade Score Threshold",
                            subtitle: "Minimum \(Int(tradeScoreThreshold))% to suggest",
                            showChevron: false
                        )

                        Spacer()

                        Text("\(Int(tradeScoreThreshold))%")
                            .foregroundColor(.secondary)
                    }
                }

                // Data Management
                Section("📊 Data & Performance") {
                    NavigationLink(destination: DataManagementView(
                        cacheSize: $cacheSize,
                        lastDataUpdate: $lastDataUpdate,
                        refreshInterval: $refreshInterval
                    )) {
                        SettingsRow(
                            icon: "externaldrive.fill",
                            iconColor: .gray,
                            title: "Data Management",
                            subtitle: "Cache: \(cacheSize) • Last update: \(timeAgoString(from: lastDataUpdate))",
                            showChevron: true
                        )
                    }

                    HStack {
                        SettingsRow(
                            icon: "arrow.clockwise.circle",
                            iconColor: .blue,
                            title: "Auto Refresh",
                            subtitle: refreshIntervalText,
                            showChevron: false
                        )

                        Spacer()

                        Button("Refresh Now") {
                            impactFeedback.impactOccurred()
                            performManualRefresh()
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }

                    Button("Clear All Data") {
                        impactFeedback.impactOccurred()
                        clearAllData()
                    }
                    .foregroundColor(.red)
                }

                // Experience & Interface
                Section("🎨 Experience") {
                    Toggle(isOn: $animationsEnabled) {
                        SettingsRow(
                            icon: "sparkles",
                            iconColor: .yellow,
                            title: "Smooth Animations",
                            subtitle: "Enhanced visual feedback",
                            showChevron: false
                        )
                    }
                    .onChange(of: animationsEnabled) { _, _ in
                        impactFeedback.impactOccurred()
                    }

                    Toggle(isOn: $hapticFeedbackEnabled) {
                        SettingsRow(
                            icon: "hand.point.up.braille",
                            iconColor: .purple,
                            title: "Haptic Feedback",
                            subtitle: "Tactile response to interactions",
                            showChevron: false
                        )
                    }
                    .onChange(of: hapticFeedbackEnabled) { _, _ in
                        if hapticFeedbackEnabled {
                            impactFeedback.impactOccurred()
                        }
                    }

                    Toggle(isOn: $compactMode) {
                        SettingsRow(
                            icon: "rectangle.compress.vertical",
                            iconColor: .indigo,
                            title: "Compact Mode",
                            subtitle: "Denser information display",
                            showChevron: false
                        )
                    }
                    .onChange(of: compactMode) { _, _ in
                        if hapticFeedbackEnabled {
                            impactFeedback.impactOccurred()
                        }
                    }
                }

                // Advanced Features
                Section("⚙️ Advanced") {
                    NavigationLink(destination: AdvancedSettingsView(
                        priceChangeThreshold: $priceChangeThreshold
                    )) {
                        SettingsRow(
                            icon: "gearshape.2",
                            iconColor: .gray,
                            title: "Advanced Settings",
                            subtitle: "Expert configuration options",
                            showChevron: true
                        )
                    }

                    Button("Reset to Defaults") {
                        impactFeedback.impactOccurred()
                        resetToDefaults()
                    }
                    .foregroundColor(.orange)

                    Button("Export Settings") {
                        impactFeedback.impactOccurred()
                        exportSettings()
                    }
                    .foregroundColor(.blue)
                }

                // About & Legal
                Section("ℹ️ About AFL Fantasy Intelligence") {
                    HStack {
                        SettingsRow(
                            icon: "info.circle",
                            iconColor: .blue,
                            title: "Version",
                            subtitle: "1.0.0 (MVP)",
                            showChevron: false
                        )

                        Spacer()

                        Text("Build 2025.09.06")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Native legal document modals
                    Button("Privacy Policy") {
                        if hapticFeedbackEnabled {
                            impactFeedback.impactOccurred()
                        }
                        showingPrivacyPolicy = true
                    }
                    .foregroundColor(.primary)

                    Button("Terms of Service") {
                        if hapticFeedbackEnabled {
                            impactFeedback.impactOccurred()
                        }
                        showingTermsOfUse = true
                    }
                    .foregroundColor(.primary)

                    Button("Send Feedback") {
                        if hapticFeedbackEnabled {
                            impactFeedback.impactOccurred()
                        }
                        sendFeedback()
                    }
                    .foregroundColor(.blue)

                    Button("Rate This App") {
                        if hapticFeedbackEnabled {
                            impactFeedback.impactOccurred()
                        }
                        rateApp()
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("⚙️ Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showingTermsOfUse) {
            TermsOfUseView()
        }
        .onAppear {
            updateDataStats()
        }
    }

    // MARK: - Helper Views and Computed Properties

    private var alertSummary: String {
        let enabledCount = [
            enableBreakevenAlerts,
            enableInjuryAlerts,
            enableLateOutAlerts,
            enablePriceAlerts,
            enableCaptainAlerts,
            enableTradeAlerts,
            enableCashCowAlerts,
            enableWeatherAlerts,
            enableRoleChangeAlerts
        ]
        .filter { $0 }.count
        return "\(enabledCount)/9 alert types enabled"
    }

    private var refreshIntervalText: String {
        switch refreshInterval {
        case 0 ..< 60: "Every \(Int(refreshInterval))s"
        case 60 ..< 3600: "Every \(Int(refreshInterval / 60))m"
        default: "Every \(Int(refreshInterval / 3600))h"
        }
    }

    // MARK: - Helper Methods

    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func updateDataStats() {
        // In a real app, this would fetch actual stats
        cacheSize = "12.4 MB"
        lastDataUpdate = Date().addingTimeInterval(-Double.random(in: 300 ... 3600))
        monitoredPlayersCount = Int.random(in: 3 ... 8)
        totalActiveAlerts = Int.random(in: 1 ... 5)
    }

    private func performManualRefresh() {
        lastDataUpdate = Date()
        if hapticFeedbackEnabled {
            successFeedback.notificationOccurred(.success)
        }
        // In real app: trigger data refresh
    }

    private func clearAllData() {
        cacheSize = "0 MB"
        if hapticFeedbackEnabled {
            successFeedback.notificationOccurred(.success)
        }
        // In real app: clear actual cache
    }

    private func resetToDefaults() {
        enableBreakevenAlerts = true
        enableInjuryAlerts = true
        enableLateOutAlerts = true
        enablePriceAlerts = true
        enableCaptainAlerts = true
        enableTradeAlerts = true
        enableCashCowAlerts = true
        enableWeatherAlerts = false
        enableRoleChangeAlerts = false
        captainConfidenceThreshold = 70.0
        tradeScoreThreshold = 75.0
        priceChangeThreshold = 10000.0
        refreshInterval = 30.0
        animationsEnabled = true
        hapticFeedbackEnabled = true
        compactMode = false

        if hapticFeedbackEnabled {
            successFeedback.notificationOccurred(.success)
        }
    }

    private func exportSettings() {
        // In real app: create settings export file
        if hapticFeedbackEnabled {
            successFeedback.notificationOccurred(.success)
        }
    }

    private func sendFeedback() {
        if let url = URL(string: "mailto:feedback@afl.ai?subject=AFL Fantasy iOS Feedback") {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id123456789") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - SettingsRow

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let showChevron: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            if showChevron {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Preview

#Preview {
    EnhancedSettingsView()
        .environmentObject(AppState())
}
