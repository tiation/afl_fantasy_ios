import SwiftUI
import UserNotifications

// MARK: - SettingsView

struct SettingsView: View {
    // Environment
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var toolsClient: AFLFantasyToolsClient

    // Notifications Settings
    @AppStorage("enableBreakevenAlerts") private var enableBreakevenAlerts = false
    @AppStorage("enableInjuryAlerts") private var enableInjuryAlerts = false
    @AppStorage("enableLateOutAlerts") private var enableLateOutAlerts = false
    @AppStorage("enableTradeAlerts") private var enableTradeAlerts = false
    @AppStorage("enablePriceChangeAlerts") private var enablePriceChangeAlerts = false
    @AppStorage("enableCaptainAlerts") private var enableCaptainAlerts = false
    @AppStorage("notificationsSoundEnabled") private var notificationsSoundEnabled = true
    @AppStorage("notificationsBadgeEnabled") private var notificationsBadgeEnabled = true

    // AI Analysis Settings
    @AppStorage("aiConfidenceThreshold") private var aiConfidenceThreshold = 75.0
    @AppStorage("showLowConfidencePicks") private var showLowConfidencePicks = false
    @AppStorage("enableAdvancedAnalytics") private var enableAdvancedAnalytics = false
    @AppStorage("autoUpdateInterval") private var autoUpdateInterval = 300.0

    // Display Settings
    @AppStorage("showPlayerOwnership") private var showPlayerOwnership = true
    @AppStorage("showVenueWeather") private var showVenueWeather = true
    @AppStorage("compactPlayerCards") private var compactPlayerCards = false
    @AppStorage("darkModePreference") private var darkModePreference = 0

    // UI State
    @State private var showingNotificationPermissions = false

    var body: some View {
        NavigationView {
            List {
                NotificationsSection(
                    enableBreakevenAlerts: $enableBreakevenAlerts,
                    enableInjuryAlerts: $enableInjuryAlerts,
                    enableLateOutAlerts: $enableLateOutAlerts,
                    enableTradeAlerts: $enableTradeAlerts,
                    enablePriceChangeAlerts: $enablePriceChangeAlerts,
                    enableCaptainAlerts: $enableCaptainAlerts,
                    notificationsSoundEnabled: $notificationsSoundEnabled,
                    notificationsBadgeEnabled: $notificationsBadgeEnabled,
                    showingNotificationPermissions: $showingNotificationPermissions,
                    handleNotificationToggle: handleNotificationToggle
                )

                AIAnalysisSection(
                    aiConfidenceThreshold: $aiConfidenceThreshold,
                    showLowConfidencePicks: $showLowConfidencePicks,
                    enableAdvancedAnalytics: $enableAdvancedAnalytics,
                    autoUpdateInterval: $autoUpdateInterval,
                    formatUpdateInterval: formatUpdateInterval
                )

                DisplayPreferencesSection(
                    showPlayerOwnership: $showPlayerOwnership,
                    showVenueWeather: $showVenueWeather,
                    compactPlayerCards: $compactPlayerCards,
                    darkModePreference: $darkModePreference
                )

                Section {
                    Button(action: {
                        // Trigger sync with backend if needed
                        appState.refreshData()
                    }) {
                        Label("Sync Settings", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .disabled(appState.isRefreshing)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .task {
                // Perform initial setup tasks
                await toolsClient.init()
            }
            .onAppear {
                // Refresh UI state
                appState.refreshData()
            }
            .sheet(isPresented: $showingNotificationPermissions) {
                NotificationPermissionsView(
                    enableBreakevenAlerts: $enableBreakevenAlerts,
                    enableInjuryAlerts: $enableInjuryAlerts,
                    enableLateOutAlerts: $enableLateOutAlerts,
                    enableTradeAlerts: $enableTradeAlerts,
                    enablePriceChangeAlerts: $enablePriceChangeAlerts,
                    enableCaptainAlerts: $enableCaptainAlerts
                )
            }
        }
    }

    // MARK: - Helper Methods

    private func formatUpdateInterval(_ interval: Double) -> String {
        let minutes = Int(interval) / 60
        if minutes == 1 {
            return "Every minute"
        } else {
            return "Every \(minutes) minutes"
        }
    }

    private func handleNotificationToggle(_ type: String, _ isEnabled: Bool) {
        guard isEnabled else { return }

        // Request permissions if not already granted
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let permissionStatus = settings.authorizationStatus

            DispatchQueue.main.async {
                if permissionStatus == .notDetermined {
                    showingNotificationPermissions = true
                } else if permissionStatus == .denied {
                    // Show alert that notifications are disabled
                    appState.simulateError("Please enable notifications in Settings")
                }
            }
        }
    }
}

// MARK: - NotificationPermissionsView

struct NotificationPermissionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var enableBreakevenAlerts: Bool
    @Binding var enableInjuryAlerts: Bool
    @Binding var enableLateOutAlerts: Bool
    @Binding var enableTradeAlerts: Bool
    @Binding var enablePriceChangeAlerts: Bool
    @Binding var enableCaptainAlerts: Bool

    var body: some View {
        NavigationView {
            List {
                Section {
                    Text(
                        "To keep you informed about critical events and opportunities, AFL Fantasy Intelligence would like to send you notifications."
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 8)
                }

                Section(header: Text("You'll receive alerts for:")) {
                    ForEach([
                        ("Breakeven", $enableBreakevenAlerts, "Players approaching breakeven scores"),
                        ("Injury Risk", $enableInjuryAlerts, "High injury risk alerts for your players"),
                        ("Late Changes", $enableLateOutAlerts, "Late team changes that affect your squad"),
                        ("Trade Opportunities", $enableTradeAlerts, "High-value trade recommendations"),
                        ("Price Changes", $enablePriceChangeAlerts, "Significant price movements"),
                        ("Captain Picks", $enableCaptainAlerts, "AI captain recommendations")
                    ], id: \.0) { title, binding, description in
                        VStack(alignment: .leading, spacing: 4) {
                            Toggle(title, isOn: binding)
                                .font(.headline)
                            Text(description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        requestPermissions()
                    }
                }
            }
        }
    }

    private func requestPermissions() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                if !granted {
                    // Reset all notification settings since permission was denied
                    DispatchQueue.main.async {
                        enableBreakevenAlerts = false
                        enableInjuryAlerts = false
                        enableLateOutAlerts = false
                        enableTradeAlerts = false
                        enablePriceChangeAlerts = false
                        enableCaptainAlerts = false
                    }
                }
                DispatchQueue.main.async {
                    dismiss()
                }
            }
    }
}

// Preview
#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environmentObject(AFLFantasyToolsClient())
}
