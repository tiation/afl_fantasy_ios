//
//  OfflineStatusView.swift
//  AFL Fantasy Intelligence Platform
//
//  Offline status indicators and network state components
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - OfflineStatusView

struct OfflineStatusView: View {
    @EnvironmentObject private var offlineManager: OfflineManager
    @State private var showingDetails = false

    var body: some View {
        if !offlineManager.isOnline || offlineManager.pendingSyncOperations > 0 {
            Button(action: { showingDetails = true }) {
                HStack(spacing: 6) {
                    Image(systemName: statusIcon)
                        .font(.caption)
                        .foregroundColor(statusColor)

                    Text(statusText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(statusColor)

                    if offlineManager.pendingSyncOperations > 0 {
                        Text("(\(offlineManager.pendingSyncOperations))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.1))
                .cornerRadius(12)
            }
            .sheet(isPresented: $showingDetails) {
                OfflineStatusDetailView()
            }
        }
    }

    private var statusIcon: String {
        if !offlineManager.isOnline {
            "wifi.slash"
        } else if offlineManager.pendingSyncOperations > 0 {
            "arrow.clockwise"
        } else {
            "checkmark.circle"
        }
    }

    private var statusColor: Color {
        if !offlineManager.isOnline {
            .red
        } else if offlineManager.pendingSyncOperations > 0 {
            .orange
        } else {
            .green
        }
    }

    private var statusText: String {
        if !offlineManager.isOnline {
            "Offline"
        } else if offlineManager.pendingSyncOperations > 0 {
            "Syncing"
        } else {
            "Online"
        }
    }
}

// MARK: - OfflineStatusDetailView

struct OfflineStatusDetailView: View {
    @EnvironmentObject private var offlineManager: OfflineManager
    @Environment(\.dismiss) private var dismiss
    @State private var cacheStats: CacheStatistics?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Network status section
                    NetworkStatusSection()

                    // Data freshness section
                    DataFreshnessSection()

                    // Sync operations section
                    if offlineManager.pendingSyncOperations > 0 {
                        SyncOperationsSection()
                    }

                    // Cache statistics section
                    if let stats = cacheStats {
                        CacheStatisticsSection(stats: stats)
                    }

                    // Offline capabilities section
                    OfflineCapabilitiesSection()
                }
                .padding()
            }
            .navigationTitle("Connection Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            Task {
                cacheStats = await offlineManager.getCacheStatistics()
            }
        }
    }
}

// MARK: - NetworkStatusSection

struct NetworkStatusSection: View {
    @EnvironmentObject private var offlineManager: OfflineManager

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Network Status")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                NetworkStatusIndicator(
                    isOnline: offlineManager.isOnline,
                    connectionType: offlineManager.connectionType
                )
            }

            if let lastOnlineTime = offlineManager.lastOnlineTime, !offlineManager.isOnline {
                HStack {
                    Text("Last online:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(lastOnlineTime, style: .relative)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        + Text(" ago")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - NetworkStatusIndicator

struct NetworkStatusIndicator: View {
    let isOnline: Bool
    let connectionType: ConnectionType

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isOnline ? connectionType.icon : "wifi.slash")
                .foregroundColor(isOnline ? .green : .red)

            Text(isOnline ? connectionType.rawValue : "Offline")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isOnline ? .green : .red)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background((isOnline ? Color.green : Color.red).opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - DataFreshnessSection

struct DataFreshnessSection: View {
    @State private var dataFreshness: [CacheKey: DataFreshness] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Data Freshness")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(Array(dataFreshness.keys), id: \.rawValue) { key in
                    if let freshness = dataFreshness[key] {
                        DataFreshnessItem(
                            title: key.displayName,
                            freshness: freshness
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .onAppear {
            Task {
                await loadDataFreshness()
            }
        }
    }

    private func loadDataFreshness() async {
        let offlineManager = OfflineManager.shared
        var freshness: [CacheKey: DataFreshness] = [:]

        for key in CacheKey.allCases {
            freshness[key] = await offlineManager.getDataFreshness(for: key)
        }

        await MainActor.run {
            dataFreshness = freshness
        }
    }
}

// MARK: - DataFreshnessItem

struct DataFreshnessItem: View {
    let title: String
    let freshness: DataFreshness

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(freshness.color))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)

                Text(freshness.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemBackground))
        .cornerRadius(6)
    }
}

// MARK: - SyncOperationsSection

struct SyncOperationsSection: View {
    @EnvironmentObject private var offlineManager: OfflineManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pending Sync")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Text("\\(offlineManager.pendingSyncOperations) operations")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }

            if offlineManager.pendingSyncOperations > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)

                        Text("Waiting for network connection to sync changes...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Text("Your changes are saved locally and will sync automatically when online.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - CacheStatisticsSection

struct CacheStatisticsSection: View {
    let stats: CacheStatistics

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cache Statistics")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                CacheStatRow(title: "Total Items", value: "\\(stats.totalItems)")
                CacheStatRow(title: "Cache Size", value: stats.formattedSize)
                CacheStatRow(title: "Hit Rate", value: stats.formattedHitRate)

                if let oldest = stats.oldestItem {
                    CacheStatRow(
                        title: "Oldest Data",
                        value: DateFormatter.relative.string(from: oldest)
                    )
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - CacheStatRow

struct CacheStatRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - OfflineCapabilitiesSection

struct OfflineCapabilitiesSection: View {
    @EnvironmentObject private var offlineManager: OfflineManager
    @State private var capabilities: OfflineCapabilities?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Offline Capabilities")
                .font(.headline)
                .fontWeight(.semibold)

            if let capabilities {
                VStack(spacing: 6) {
                    CapabilityRow(title: "View Dashboard", isAvailable: capabilities.canViewDashboard)
                    CapabilityRow(title: "View Players", isAvailable: capabilities.canViewPlayers)
                    CapabilityRow(title: "Analyze Trades", isAvailable: capabilities.canAnalyzeTrades)
                    CapabilityRow(title: "Set Captain", isAvailable: capabilities.canSetCaptain)
                    CapabilityRow(title: "Make Trades", isAvailable: capabilities.canMakeTrades)
                    CapabilityRow(title: "View History", isAvailable: capabilities.canViewHistory)
                    CapabilityRow(title: "Settings", isAvailable: capabilities.canViewSettings)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .onAppear {
            capabilities = offlineManager.getOfflineCapabilities()
        }
    }
}

// MARK: - CapabilityRow

struct CapabilityRow: View {
    let title: String
    let isAvailable: Bool

    var body: some View {
        HStack {
            Image(systemName: isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.caption)
                .foregroundColor(isAvailable ? .green : .red)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()

            if !isAvailable {
                Text("Requires data")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - MinimalOfflineIndicator

struct MinimalOfflineIndicator: View {
    @EnvironmentObject private var offlineManager: OfflineManager

    var body: some View {
        if !offlineManager.isOnline {
            HStack(spacing: 4) {
                Image(systemName: "wifi.slash")
                    .font(.caption2)
                Text("Offline")
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.red)
            .cornerRadius(6)
        }
    }
}

// MARK: - Extensions

extension CacheKey {
    var displayName: String {
        switch self {
        case .dashboardData: "Dashboard"
        case .playerList: "Players"
        case .captainSuggestions: "Captains"
        case .tradeRecommendations: "Trades"
        case .cashCowTargets: "Cash Cows"
        case .userSettings: "Settings"
        case .teamData: "Team"
        case .leagueData: "League"
        }
    }
}

extension DateFormatter {
    static let relative: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
}

// MARK: - Preview

#Preview {
    OfflineStatusView()
        .environmentObject(OfflineManager.shared)
}
