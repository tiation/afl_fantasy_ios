//
//  DataManagementView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - DataManagementView

struct DataManagementView: View {
    @Binding var cacheSize: String
    @Binding var lastDataUpdate: Date
    @Binding var refreshInterval: Double

    @State private var autoBackup = true
    @State private var offlineMode = false
    @State private var dataQuality = "High"

    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    private let successFeedback = UINotificationFeedbackGenerator()

    var body: some View {
        Form {
            Section("📊 Cache Management") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cache Size")
                            .font(.headline)
                        Text("Player data, images, and analytics")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text(cacheSize)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.blue)
                }

                Button("Clear Player Cache") {
                    impactFeedback.impactOccurred()
                    clearCache()
                }
                .foregroundColor(.orange)

                Button("Clear All Data") {
                    impactFeedback.impactOccurred()
                    clearAllData()
                }
                .foregroundColor(.red)
            }

            Section("🔄 Refresh Settings") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Auto Refresh Interval")
                            .font(.headline)
                        Spacer()
                        Text(refreshIntervalText)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.green)
                    }

                    Slider(value: $refreshInterval, in: 15 ... 300, step: 15) {
                        Text("Refresh Interval")
                    } minimumValueLabel: {
                        Text("15s")
                            .font(.caption)
                    } maximumValueLabel: {
                        Text("5m")
                            .font(.caption)
                    }
                    .onChange(of: refreshInterval) { _, _ in
                        impactFeedback.impactOccurred()
                    }
                }
                .padding(.vertical, 8)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Last Update")
                            .font(.subheadline)
                        Text(timeAgoString(from: lastDataUpdate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button("Refresh Now") {
                        impactFeedback.impactOccurred()
                        refreshData()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            Section("🏠 Offline Mode") {
                Toggle(isOn: $offlineMode) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Offline Mode")
                            .font(.headline)
                        Text("Use cached data when network is unavailable")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onChange(of: offlineMode) { _, _ in
                    impactFeedback.impactOccurred()
                }

                Toggle(isOn: $autoBackup) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Auto Backup")
                            .font(.headline)
                        Text("Automatically backup settings and preferences")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onChange(of: autoBackup) { _, _ in
                    impactFeedback.impactOccurred()
                }
            }

            Section("📈 Data Quality") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Quality")
                            .font(.headline)
                        Text("Based on data freshness and completeness")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text(dataQuality)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.green)
                }

                Button("Run Data Integrity Check") {
                    impactFeedback.impactOccurred()
                    checkDataIntegrity()
                }
                .foregroundColor(.blue)
            }
        }
        .navigationTitle("📊 Data Management")
        .navigationBarTitleDisplayMode(.large)
    }

    private var refreshIntervalText: String {
        if refreshInterval < 60 {
            "\(Int(refreshInterval))s"
        } else {
            "\(Int(refreshInterval / 60))m"
        }
    }

    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func clearCache() {
        cacheSize = "0 MB"
        successFeedback.notificationOccurred(.success)
    }

    private func clearAllData() {
        cacheSize = "0 MB"
        successFeedback.notificationOccurred(.success)
    }

    private func refreshData() {
        lastDataUpdate = Date()
        successFeedback.notificationOccurred(.success)
    }

    private func checkDataIntegrity() {
        dataQuality = "Excellent"
        successFeedback.notificationOccurred(.success)
    }
}

// MARK: - AdvancedSettingsView

struct AdvancedSettingsView: View {
    @Binding var priceChangeThreshold: Double

    @State private var enableBetaFeatures = false
    @State private var debugMode = false
    @State private var analyticsSharing = true

    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        Form {
            Section("💰 Price Thresholds") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Price Change Alert")
                            .font(.headline)
                        Spacer()
                        Text("$\(Int(priceChangeThreshold / 1000))k")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.green)
                    }

                    Slider(value: $priceChangeThreshold, in: 5000 ... 50000, step: 1000) {
                        Text("Price Threshold")
                    } minimumValueLabel: {
                        Text("$5k")
                            .font(.caption)
                    } maximumValueLabel: {
                        Text("$50k")
                            .font(.caption)
                    }
                    .onChange(of: priceChangeThreshold) { _, _ in
                        impactFeedback.impactOccurred()
                    }
                }
                .padding(.vertical, 8)
            }

            Section("🧪 Experimental") {
                Toggle(isOn: $enableBetaFeatures) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Beta Features")
                            .font(.headline)
                        Text("Early access to new features and improvements")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onChange(of: enableBetaFeatures) { _, _ in
                    impactFeedback.impactOccurred()
                }

                Toggle(isOn: $debugMode) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Debug Mode")
                            .font(.headline)
                        Text("Show additional diagnostic information")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onChange(of: debugMode) { _, _ in
                    impactFeedback.impactOccurred()
                }
            } footer: {
                Text("Beta features may be unstable and are not recommended for league play.")
            }

            Section("📊 Analytics") {
                Toggle(isOn: $analyticsSharing) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Anonymous Analytics")
                            .font(.headline)
                        Text("Help improve the app by sharing anonymous usage data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onChange(of: analyticsSharing) { _, _ in
                    impactFeedback.impactOccurred()
                }
            }
        }
        .navigationTitle("⚙️ Advanced")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview("Data Management") {
    NavigationView {
        DataManagementView(
            cacheSize: .constant("12.4 MB"),
            lastDataUpdate: .constant(Date()),
            refreshInterval: .constant(30.0)
        )
    }
}

#Preview("Advanced Settings") {
    NavigationView {
        AdvancedSettingsView(
            priceChangeThreshold: .constant(10000.0)
        )
    }
}
