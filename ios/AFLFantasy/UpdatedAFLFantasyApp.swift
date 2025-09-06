//
//  UpdatedAFLFantasyApp.swift
//  AFL Fantasy Intelligence Platform
//
//  Updated main app with live API integration and enhanced features
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - UpdatedAFLFantasyApp

@main
struct UpdatedAFLFantasyApp: App {
    @StateObject private var liveAppState = LiveAppState()
    @StateObject private var networkService = NetworkService.shared
    @StateObject private var audioManager = AFLAudioManager()
    @StateObject private var hapticsManager = AFLHapticsManager()

    var body: some Scene {
        WindowGroup {
            UpdatedContentView()
                .environmentObject(liveAppState)
                .environmentObject(networkService)
                .environmentObject(audioManager)
                .environmentObject(hapticsManager)
                .preferredColorScheme(.dark)
                .onAppear {
                    setupApp()
                }
        }
    }

    private func setupApp() {
        // Start performance monitoring
        PerformanceMonitor.shared.startColdStartTimer()

        print("🚀 AFL Fantasy Intelligence Platform started with live features")

        // Trigger AFL experience launch
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                audioManager.onAppLaunch()
                hapticsManager.onAppLaunch()
                PerformanceMonitor.shared.endColdStartTimer()
            }
        }
    }
}

// MARK: - UpdatedContentView

struct UpdatedContentView: View {
    @EnvironmentObject var appState: LiveAppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            // Dashboard with live data
            LiveDashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(TabItem.dashboard)

            // Enhanced Trade Calculator
            EnhancedTradeCalculatorView()
                .tabItem {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Trades")
                }
                .tag(TabItem.trades)

            // Captain Advisor with AI
            LiveCaptainView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Captain")
                }
                .tag(TabItem.captain)

            // Cash Cow Tracker with analytics
            LiveCashCowView()
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Cash Cow")
                }
                .tag(TabItem.cashCow)

            // Advanced Analytics
            AdvancedAnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Analytics")
                }
                .tag(TabItem.settings) // Reuse settings tab for analytics
        }
        .accentColor(.orange)
        .overlay(
            connectionStatusOverlay,
            alignment: .top
        )
    }

    @ViewBuilder
    private var connectionStatusOverlay: some View {
        if !appState.isConnected, !appState.isRefreshing {
            HStack {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.white)
                Text("Offline Mode")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.red)
            .cornerRadius(16)
            .padding(.top, 10)
        }
    }
}

// MARK: - LiveDashboardView

struct LiveDashboardView: View {
    @EnvironmentObject var appState: LiveAppState

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Connection Status & Last Update
                    connectionStatusCard

                    // Team Score Header with live data
                    teamScoreCard

                    // Quick Stats Grid
                    quickStatsGrid

                    // Players List with live data
                    playersSection

                    // Error Display
                    if let error = appState.errorMessage {
                        errorCard(error)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("🏆 Live Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await appState.refreshData()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await appState.refreshData()
                        }
                    }) {
                        Image(systemName: appState.isRefreshing ? "arrow.clockwise" : "arrow.clockwise.circle")
                            .rotationEffect(.degrees(appState.isRefreshing ? 360 : 0))
                            .animation(
                                appState.isRefreshing ?
                                    .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                                value: appState.isRefreshing
                            )
                    }
                }
            }
        }
    }

    private var connectionStatusCard: some View {
        HStack {
            Circle()
                .fill(appState.isConnected ? Color.green : Color.red)
                .frame(width: 12, height: 12)

            Text(appState.isConnected ? "Connected to live data" : "Offline mode")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            if let lastUpdate = appState.lastUpdateTime {
                Text("Updated \\(lastUpdate, formatter: timeFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }

    private var teamScoreCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Team Score")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("\\(appState.teamScore)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Overall Rank")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("#\\(appState.teamRank)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("Team Value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\\(String(format: "%.1f", Double(appState.teamValue) / 1000000))M")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Bank")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\\(Int(appState.bankBalance / 1000))K")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var quickStatsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            QuickStatCard(
                title: "Cash Cows",
                value: "\\(appState.players.filter(\\.isCashCow).count)",
                subtitle: "Players",
                color: .green,
                icon: "dollarsign.circle.fill"
            )

            QuickStatCard(
                title: "Trades Left",
                value: "\\(appState.tradesRemaining)",
                subtitle: "Remaining",
                color: .blue,
                icon: "arrow.triangle.2.circlepath"
            )
        }
    }

    private var playersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Players")
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                Text("\\(appState.players.count) players")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if appState.players.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.title2)
                        .foregroundColor(.secondary)

                    Text(appState.isRefreshing ? "Loading players..." : "No player data available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(appState.players.prefix(10)), id: \\.id) { player in
                        LivePlayerCard(player: player)
                    }
                }
            }
        }
    }

    private func errorCard(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)

            Text(message)
                .font(.caption)
                .foregroundColor(.primary)

            Spacer()

            Button("Dismiss") {
                appState.clearError()
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.red, lineWidth: 1)
        )
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

// MARK: - LivePlayerCard

struct LivePlayerCard: View {
    let player: EnhancedPlayer

    var body: some View {
        HStack(spacing: 12) {
            // Position indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(player.position.color)
                .frame(width: 6, height: 50)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(player.name)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Text(player.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }

                HStack {
                    Text(player.position.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(player.position.color.opacity(0.2))
                        .cornerRadius(4)

                    Text("Avg: \\(String(format: "%.1f", player.averageScore))")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if player.priceChange != 0 {
                        Text(player.priceChangeText)
                            .font(.caption)
                            .foregroundColor(player.priceChange > 0 ? .green : .red)
                    }

                    Spacer()

                    // Status indicators
                    HStack(spacing: 4) {
                        if player.isCashCow {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }

                        if player.isDoubtful {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }

                        if !player.alertFlags.isEmpty {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - LiveCaptainView

struct LiveCaptainView: View {
    @EnvironmentObject var appState: LiveAppState

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // AI Captain Advisor Header
                    aiAdvisorHeader

                    // Captain Suggestions
                    if appState.captainSuggestions.isEmpty {
                        loadingCaptainSuggestions
                    } else {
                        captainSuggestionsSection
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("⭐ AI Captain Advisor")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await appState.refreshCaptains()
            }
        }
    }

    private var aiAdvisorHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.largeTitle)
                .foregroundColor(.blue)

            Text("AI Captain Recommendations")
                .font(.headline)
                .fontWeight(.bold)

            Text("Based on form, fixtures, venue bias, and injury risk")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var loadingCaptainSuggestions: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Analyzing captain options...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var captainSuggestionsSection: some View {
        LazyVStack(spacing: 16) {
            ForEach(Array(appState.captainSuggestions.enumerated()), id: \\.offset) { index, suggestion in
                LiveCaptainCard(
                    suggestion: suggestion,
                    rank: index + 1
                )
            }
        }
    }
}

// MARK: - LiveCaptainCard

struct LiveCaptainCard: View {
    let suggestion: CaptainSuggestion
    let rank: Int

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Rank badge
                ZStack {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 32, height: 32)

                    Text("\\(rank)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.player.name)
                        .font(.headline)
                        .fontWeight(.bold)

                    HStack {
                        Text(suggestion.player.position.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(suggestion.player.position.color.opacity(0.2))
                            .cornerRadius(4)

                        Text("vs \\(suggestion.opponent)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\\(suggestion.confidence)%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(rankColor)

                    Text("Confidence")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            HStack {
                StatItem(
                    title: "Projected",
                    value: "\\(suggestion.projectedPoints) pts",
                    color: .orange
                )

                Spacer()

                StatItem(
                    title: "Form",
                    value: String(format: "%.1f/5", suggestion.formRating * 5),
                    color: .green
                )

                Spacer()

                StatItem(
                    title: "Fixture",
                    value: String(format: "%.1f/5", suggestion.fixtureRating * 5),
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var rankColor: Color {
        switch rank {
        case 1: .green
        case 2: .orange
        default: .gray
        }
    }
}

// MARK: - LiveCashCowView

struct LiveCashCowView: View {
    @EnvironmentObject var appState: LiveAppState

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Cash generation summary
                    cashGenerationSummary

                    // Cash cow recommendations
                    cashCowRecommendations
                }
                .padding(.horizontal)
            }
            .navigationTitle("💰 Cash Cow Tracker")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await appState.refreshCashCows()
            }
        }
    }

    private var cashGenerationSummary: some View {
        VStack(spacing: 12) {
            Text("Total Cash Generated")
                .font(.headline)
                .fontWeight(.bold)

            Text("$\\(Int(appState.players.map(\\.cashGenerated).reduce(0, +) / 1000))K")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)

            Text("From \\(appState.players.filter(\\.isCashCow).count) cash cows")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var cashCowRecommendations: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Smart Sell Signals")
                .font(.headline)
                .fontWeight(.bold)

            if appState.cashCows.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle")
                        .font(.title2)
                        .foregroundColor(.secondary)

                    Text("Loading cash cow analysis...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(appState.cashCows, id: \\.playerName) { recommendation in
                        CashCowRecommendationCard(recommendation: recommendation)
                    }
                }
            }
        }
    }
}

// MARK: - QuickStatCard

struct QuickStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - StatItem

struct StatItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - CashCowRecommendationCard

struct CashCowRecommendationCard: View {
    let recommendation: CashCowRecommendation

    var body: some View {
        HStack(spacing: 12) {
            // Sell urgency indicator
            Circle()
                .fill(urgencyColor)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.playerName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(recommendation.sellUrgency)
                    .font(.caption)
                    .foregroundColor(urgencyColor)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("+$\\(recommendation.cashGenerated / 1000)K")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)

                Text("\\(Int(recommendation.confidence * 100))% confidence")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }

    private var urgencyColor: Color {
        switch recommendation.sellUrgency {
        case "SELL NOW":
            .red
        case "HOLD":
            .orange
        default:
            .green
        }
    }
}
