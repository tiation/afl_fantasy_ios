//
//  SettingsAdditionalSections.swift
//  AFL Fantasy Intelligence Platform
//
//  Additional Settings View Section Components
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - TeamManagementSection

struct TeamManagementSection: View {
    @EnvironmentObject var appState: AppState

    let formatCurrency: (Int) -> String

    var body: some View {
        Section(header: Text("⚽ Team Management")) {
            HStack {
                Text("Team Value")
                Spacer()
                Text(formatCurrency(appState.teamValue))
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            }

            HStack {
                Text("Bank Balance")
                Spacer()
                Text(formatCurrency(appState.bankBalance))
                    .foregroundColor(appState.bankBalance > 100_000 ? .green : .orange)
                    .fontWeight(.medium)
            }

            HStack {
                Text("Trades Remaining")
                Spacer()
                Text("\(appState.tradesRemaining)")
                    .foregroundColor(appState.tradesRemaining > 5 ? .green :
                        appState.tradesRemaining > 2 ? .orange : .red
                    )
                    .fontWeight(.medium)
            }

            HStack {
                Text("Players")
                Spacer()
                Text("\(appState.players.count) / 30")
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - DataManagementSection

struct DataManagementSection: View {
    @EnvironmentObject var appState: AppState
    @Binding var cacheSize: String
    @Binding var lastSyncTime: Date
    @Binding var showingClearCacheAlert: Bool
    @Binding var showingResetDataAlert: Bool
    @Binding var showingExportData: Bool

    let formatLastSync: (Date) -> String
    let refreshAppData: () -> Void

    var body: some View {
        Section(header: Text("📊 Data Management")) {
            HStack {
                Text("Cache Size")
                Spacer()
                Text(cacheSize)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("Last Sync")
                Spacer()
                Text(formatLastSync(lastSyncTime))
                    .foregroundColor(.secondary)
            }

            Button("Refresh Data Now") {
                refreshAppData()
            }
            .foregroundColor(.blue)
            .disabled(appState.isRefreshing)

            Button("Clear Cache") {
                showingClearCacheAlert = true
            }
            .foregroundColor(.orange)

            Button("Export Team Data") {
                showingExportData = true
            }
            .foregroundColor(.primary)

            Button("Reset All Data") {
                showingResetDataAlert = true
            }
            .foregroundColor(.red)
        }
    }
}

// MARK: - SupportLegalSection

struct SupportLegalSection: View {
    @Binding var showingPrivacyPolicy: Bool
    @Binding var showingTermsOfUse: Bool

    let impactFeedback: UIImpactFeedbackGenerator
    let getBuildNumber: () -> String
    let contactSupport: () -> Void
    let rateApp: () -> Void

    var body: some View {
        Section(header: Text("ℹ️ Support & Legal")) {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0 (MVP)")
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("Build")
                Spacer()
                Text(getBuildNumber())
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

            Button("Contact Support") {
                contactSupport()
            }
            .foregroundColor(.primary)

            Button("Rate App") {
                rateApp()
            }
            .foregroundColor(.primary)
        }
    }
}

// MARK: - DebugSection

struct DebugSection: View {
    @EnvironmentObject var appState: AppState
    @Binding var showingDebugMenu: Bool

    let generateTestData: () -> Void

    var body: some View {
        Section(header: Text("🔧 Debug")) {
            Button("Show Debug Menu") {
                showingDebugMenu = true
            }
            .foregroundColor(.purple)

            Button("Simulate Network Error") {
                appState.simulateError("Network connection failed")
            }
            .foregroundColor(.red)

            Button("Generate Test Data") {
                generateTestData()
            }
            .foregroundColor(.blue)
        }
    }
}
