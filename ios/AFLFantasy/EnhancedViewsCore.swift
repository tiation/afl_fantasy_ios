//
//  EnhancedViewsCore.swift
//  AFL Fantasy Intelligence Platform
//
//  Enhanced views integration into main target - key components
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI
import UserNotifications

// MARK: - AlertService

@MainActor
class AlertService: ObservableObject {
    @Published var activeAlerts: [AlertFlag] = []

    static let shared = AlertService()

    private init() {
        // Initialize with some demo alerts
        activeAlerts = [
            AlertFlag(type: .injuryRisk, priority: .high, message: "Max Gawn knee soreness reported"),
            AlertFlag(type: .cashCowSell, priority: .medium, message: "Hayden Young approaching breakeven"),
            AlertFlag(type: .priceChange, priority: .low, message: "Bontempelli price rise expected")
        ]
    }

    func addAlert(_ alert: AlertFlag) {
        activeAlerts.append(alert)
    }

    func removeAlert(_ alert: AlertFlag) {
        activeAlerts.removeAll { $0.type == alert.type }
    }

    func clearAllAlerts() {
        activeAlerts.removeAll()
    }
}

// MARK: - NotificationManager Extension

extension NotificationManager {
    static var shared: NotificationManager = .init()
}

// MARK: - Enhanced Settings Support Types

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
                .font(.system(size: 16))
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Simplified Enhanced Views Placeholder

// TODO: Replace with full implementations from Enhanced directory

struct SimpleEnhancedSettingsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var alertService = AlertService.shared

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
    @AppStorage("enableAIRecommendations") private var enableAIRecommendations = true
    @AppStorage("enableAdvancedAnalytics") private var enableAdvancedAnalytics = true

    // UI Preferences
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true

    // Modal States
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfUse = false
    @State private var showingAbout = false

    // Data States
    @State private var cacheSize = "12.4 MB"
    @State private var monitoredPlayersCount = 5

    var totalActiveAlerts: Int {
        alertService.activeAlerts.count
    }

    var alertSummary: String {
        let enabledCount = [
            enableBreakevenAlerts, enableInjuryAlerts, enableLateOutAlerts,
            enablePriceAlerts, enableCaptainAlerts, enableTradeAlerts,
            enableCashCowAlerts, enableWeatherAlerts, enableRoleChangeAlerts
        ].filter { $0 }.count

        return "\\(enabledCount) of 9 alert types enabled"
    }

    // Haptic feedback
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

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
                            Text("\\(totalActiveAlerts)")
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
                    SettingsRow(
                        icon: "bell.fill",
                        iconColor: .blue,
                        title: "Notification Preferences",
                        subtitle: alertSummary,
                        showChevron: true
                    )

                    HStack {
                        SettingsRow(
                            icon: "list.bullet.circle",
                            iconColor: .orange,
                            title: "Active Alerts",
                            subtitle: "\\(totalActiveAlerts) requiring attention",
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
                            subtitle: "\\(monitoredPlayersCount) players tracked",
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
                    SettingsRow(
                        icon: "brain.head.profile",
                        iconColor: .orange,
                        title: "AI Recommendations",
                        subtitle: enableAIRecommendations ? "Enhanced analysis enabled" : "Basic mode",
                        showChevron: true
                    )

                    HStack {
                        SettingsRow(
                            icon: "target",
                            iconColor: .green,
                            title: "Captain AI Confidence",
                            subtitle: "Minimum \\(Int(captainConfidenceThreshold))%",
                            showChevron: false
                        )

                        Spacer()

                        Text("\\(Int(captainConfidenceThreshold))%")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        SettingsRow(
                            icon: "arrow.triangle.2.circlepath.circle",
                            iconColor: .blue,
                            title: "Trade Score Threshold",
                            subtitle: "Minimum \\(Int(tradeScoreThreshold))% to suggest",
                            showChevron: false
                        )

                        Spacer()

                        Text("\\(Int(tradeScoreThreshold))%")
                            .foregroundColor(.secondary)
                    }
                }

                // Quick Toggles
                Section("⚙️ Quick Settings") {
                    Toggle("AI Recommendations", isOn: $enableAIRecommendations)
                    Toggle("Advanced Analytics", isOn: $enableAdvancedAnalytics)
                    Toggle("Haptic Feedback", isOn: $hapticFeedbackEnabled)
                    Toggle("Animations", isOn: $animationsEnabled)
                }

                // Data Management
                Section("📊 Data") {
                    HStack {
                        Text("Cache Size")
                        Spacer()
                        Text(cacheSize)
                            .foregroundColor(.secondary)
                    }

                    Button("Clear Cache") {
                        impactFeedback.impactOccurred()
                        // TODO: Implement cache clearing
                    }
                    .foregroundColor(.red)

                    Button("Export Data") {
                        impactFeedback.impactOccurred()
                        // TODO: Implement data export
                    }
                    .foregroundColor(.blue)
                }

                // About & Legal
                Section("ℹ️ About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Enhanced)")
                            .foregroundColor(.secondary)
                    }

                    Button("Privacy Policy") {
                        impactFeedback.impactOccurred()
                        showingPrivacyPolicy = true
                    }
                    .foregroundColor(.primary)

                    Button("Terms of Service") {
                        impactFeedback.impactOccurred()
                        showingTermsOfUse = true
                    }
                    .foregroundColor(.primary)

                    Button("About AFL Fantasy AI") {
                        impactFeedback.impactOccurred()
                        showingAbout = true
                    }
                    .foregroundColor(.primary)
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
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon and Title
                    VStack(spacing: 16) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 80))
                            .foregroundColor(.orange)

                        VStack(spacing: 4) {
                            Text("AFL Fantasy AI")
                                .font(.title)
                                .bold()

                            Text("Intelligence Platform")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Features")
                            .font(.headline)

                        FeatureRow(
                            icon: "brain.head.profile",
                            title: "AI Captain Advisor",
                            description: "Get data-driven captain recommendations"
                        )
                        FeatureRow(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Smart Trade Analysis",
                            description: "Optimize your trades with advanced analytics"
                        )
                        FeatureRow(
                            icon: "dollarsign.circle.fill",
                            title: "Cash Cow Tracker",
                            description: "Maximize rookie cash generation"
                        )
                        FeatureRow(
                            icon: "bell.fill",
                            title: "Intelligent Alerts",
                            description: "Never miss important player updates"
                        )
                        FeatureRow(icon: "wifi", title: "Real-time Sync", description: "Stay updated with live data")
                    }

                    // Technical Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Technical Details")
                            .font(.headline)

                        Text("• Built with SwiftUI and modern iOS frameworks")
                        Text("• Optimized for performance and battery life")
                        Text("• Follows iOS Human Interface Guidelines")
                        Text("• Privacy-focused design with local data processing")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .font(.system(size: 20))
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .bold()
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}
