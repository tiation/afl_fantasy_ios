//
//  ContentView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI
import UIKit

// MARK: - ContentView

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    // Native iOS Haptic Feedback for tab switching
    private let selectionFeedback = UISelectionFeedbackGenerator()

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: TabItem.dashboard.systemImage)
                    Text(TabItem.dashboard.rawValue)
                }
                .tag(TabItem.dashboard)

            CaptainAdvisorView()
                .tabItem {
                    Image(systemName: TabItem.captain.systemImage)
                    Text(TabItem.captain.rawValue)
                }
                .tag(TabItem.captain)

            TradeCalculatorView()
                .tabItem {
                    Image(systemName: TabItem.trades.systemImage)
                    Text(TabItem.trades.rawValue)
                }
                .tag(TabItem.trades)

            CashCowView()
                .tabItem {
                    Image(systemName: TabItem.cashCow.systemImage)
                    Text(TabItem.cashCow.rawValue)
                }
                .tag(TabItem.cashCow)

            SettingsView()
                .tabItem {
                    Image(systemName: TabItem.settings.systemImage)
                    Text(TabItem.settings.rawValue)
                }
                .tag(TabItem.settings)
        }
        .accentColor(.orange) // AFL-inspired accent color
        .onChange(of: appState.selectedTab) { _, _ in
            // Haptic feedback when switching tabs
            selectionFeedback.selectionChanged()
        }
    }
}

// MARK: - DashboardView

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @State private var animateScore = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Team Score Header
                    TeamScoreHeaderView()

                    // Player Cards
                    LazyVStack(spacing: 12) {
                        ForEach(appState.players) { player in
                            PlayerCardView(player: player)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("🏆 Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                simulateLiveScores()
            }
        }
    }

    private func simulateLiveScores() {
        // Simulate live score updates for MVP
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        appState.teamScore = Int.random(in: 1800 ... 2200)
                        appState.teamRank = Int.random(in: 1000 ... 15000)
                    }
                }
            }
        }
    }
}

// MARK: - TeamScoreHeaderView

struct TeamScoreHeaderView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.m.value) {
            // Connection Status Bar
            ConnectionStatusBar()
            
            // Main Team Info
            HStack {
                VStack(alignment: .leading) {
                    Text("TEAM SCORE")
                        .typography(.caption1)
                        .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                    Text("\(appState.teamScore)")
                        .typography(.largeTitle)
                        .foregroundColor(DesignSystem.Colors.primary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("RANK")
                        .typography(.caption1)
                        .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                    Text("#\(appState.teamRank)")
                        .typography(.title2)
                        .foregroundColor(DesignSystem.Colors.success)
                }
            }

            // Progress bar for salary cap
            ProgressView(value: 0.85)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)

            HStack {
                Text("Salary Cap: $10.2M / $12.0M")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("85% Used")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - PlayerCardView

struct PlayerCardView: View {
    let player: EnhancedPlayer
    @State private var showingDetails = false

    // Native iOS Haptic Feedback
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        VStack(spacing: 12) {
            // Main player info row
            HStack {
                // Position indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(player.position.color)
                    .frame(width: 6, height: 50)

                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    HStack(spacing: 8) {
                        Text(player.position.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(player.position.color.opacity(0.2))
                            .cornerRadius(4)

                        Text(player.formattedPrice)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        // Injury risk indicator
                        if player.injuryRisk.riskLevel != .low {
                            Text("⚠️ \(player.injuryRisk.riskLevel.rawValue)")
                                .font(.caption2)
                                .foregroundColor(player.injuryRisk.riskLevel.color)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(player.currentScore)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.orange)

                    Text("BE: \(player.breakeven)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Advanced analytics row
            HStack {
                // Consistency grade
                VStack(spacing: 2) {
                    Text("Consistency")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(player.consistencyGrade)
                        .font(.caption)
                        .bold()
                        .foregroundColor(consistencyColor(for: player.consistency))
                }

                Spacer()

                // Average score
                VStack(spacing: 2) {
                    Text("Average")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(Int(player.averageScore))")
                        .font(.caption)
                        .bold()
                }

                Spacer()

                // Price change indicator
                VStack(spacing: 2) {
                    Text("Price Δ")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(player.priceChangeText)
                        .font(.caption)
                        .bold()
                        .foregroundColor(player.priceChange >= 0 ? .green : .red)
                }

                Spacer()

                // Next round projection
                VStack(spacing: 2) {
                    Text("Projected")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(Int(player.nextRoundProjection.projectedScore))")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 8)

            // Cash cow indicator
            if player.isCashCow, player.cashGenerated > 50000 {
                HStack {
                    Text("💰 Cash Generated: $\(player.cashGenerated / 1000)k")
                        .font(.caption)
                        .foregroundColor(.green)

                    Spacer()

                    if player.seasonProjection.premiumPotential > 0.8 {
                        Text("🚀 Premium Potential")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal, 8)
            }

            // Alert indicators
            if !player.alertFlags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(player.alertFlags, id: \.type) { alert in
                            Text(alertIcon(for: alert.type))
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(alertColor(for: alert.priority).opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .onTapGesture {
            // Haptic feedback when opening player details
            impactFeedback.impactOccurred()
            showingDetails.toggle()
        }
        .sheet(isPresented: $showingDetails) {
            VStack {
                Text("Player Details")
                    .font(.title)
                    .padding()
                Text("\(player.name) - \(player.position.rawValue)")
                    .font(.headline)
                Text("Current Score: \(player.currentScore)")
                Text("Price: \(player.formattedPrice)")
                Text("Average: \(String(format: "%.1f", player.averageScore))")
                Spacer()
                Button("Close") {
                    showingDetails = false
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }

    private func consistencyColor(for consistency: Double) -> Color {
        switch consistency {
        case 90...: .green
        case 80 ..< 90: .blue
        case 70 ..< 80: .yellow
        default: .red
        }
    }

    private func alertIcon(for alertType: AlertType) -> String {
        switch alertType {
        case .priceDrop: "📉"
        case .breakEvenCliff: "⚠️"
        case .cashCowSell: "💰"
        case .injuryRisk: "🏥"
        case .roleChange: "🔄"
        case .weatherRisk: "🌧️"
        case .contractYear: "📋"
        case .premiumBreakout: "🚀"
        }
    }

    private func alertColor(for priority: AlertPriority) -> Color {
        switch priority {
        case .critical: .red
        case .high: .orange
        case .medium: .yellow
        case .low: .blue
        }
    }
}

// MARK: - CaptainAdvisorView

struct CaptainAdvisorView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // AI Confidence Header
                    VStack {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)

                        Text("AI Captain Advisor")
                            .font(.title2)
                            .bold()

                        Text("Based on venue, form, and opponent analysis")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()

                    // Captain Suggestions
                    ForEach(Array(appState.captainSuggestions.enumerated()), id: \.element.id) { index, suggestion in
                        CaptainSuggestionCard(suggestion: suggestion, rank: index + 1)
                    }
                }
                .padding()
            }
            .navigationTitle("⭐ Captain AI")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - CaptainSuggestionCard

struct CaptainSuggestionCard: View {
    let suggestion: CaptainSuggestion
    let rank: Int
    @State private var showingDetails = false

    // Native iOS Haptic Feedback
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        VStack(spacing: 12) {
            // Main captain info
            HStack {
                // Rank
                ZStack {
                    Circle()
                        .fill(rank == 1 ? .yellow : rank == 2 ? .gray.opacity(0.7) : .gray.opacity(0.3))
                        .frame(width: 40, height: 40)

                    Text("\(rank)")
                        .font(.headline)
                        .bold()
                        .foregroundColor(rank == 1 ? .black : .white)

                    if rank == 1 {
                        Circle()
                            .stroke(Color.orange, lineWidth: 3)
                            .frame(width: 42, height: 42)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.player.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    HStack(spacing: 8) {
                        Text(suggestion.player.position.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(suggestion.player.position.color.opacity(0.2))
                            .cornerRadius(4)

                        Text("vs \(suggestion.player.nextRoundProjection.opponent)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("@ \(suggestion.player.nextRoundProjection.venue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(suggestion.projectedPoints)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.orange)

                    Text("proj. pts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // AI Analysis factors
            VStack(spacing: 8) {
                // Confidence and key factors
                HStack {
                    VStack(spacing: 2) {
                        Text("AI Confidence")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(suggestion.confidence)%")
                            .font(.caption)
                            .bold()
                            .foregroundColor(confidenceColor(for: suggestion.confidence))
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("Form Factor")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(formGrade(for: suggestion.player))
                            .font(.caption)
                            .bold()
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("Venue Bias")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        let venueBias = suggestion.player.venuePerformance.first?.bias ?? 0
                        Text(venueBias >= 0 ? "+\(String(format: "%.1f", venueBias))" : String(
                            format: "%.1f",
                            venueBias
                        ))
                        .font(.caption)
                        .bold()
                        .foregroundColor(venueBias >= 0 ? .green : .red)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("Weather")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        let rainChance = suggestion.player.nextRoundProjection.conditions.rainProbability
                        Text(rainChance > 0.5 ? "🌧️" : rainChance > 0.3 ? "⛅" : "☀️")
                            .font(.caption)
                    }
                }

                // Risk indicators
                HStack {
                    if suggestion.player.injuryRisk.riskLevel != .low {
                        HStack(spacing: 4) {
                            Text("⚠️")
                            Text(suggestion.player.injuryRisk.riskLevel.rawValue)
                                .font(.caption2)
                                .foregroundColor(suggestion.player.injuryRisk.riskLevel.color)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(suggestion.player.injuryRisk.riskLevel.color.opacity(0.1))
                        .cornerRadius(4)
                    }

                    if suggestion.player.isDoubtful {
                        HStack(spacing: 4) {
                            Text("❓")
                            Text("Doubtful")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(4)
                    }

                    Spacer()

                    // Captain recommendation strength
                    if rank == 1 {
                        HStack(spacing: 4) {
                            Text("👑")
                            Text("Top Pick")
                                .font(.caption2)
                                .bold()
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
        .background(
            rank == 1 ? AnyView(LinearGradient(
                colors: [Color.orange.opacity(0.1), Color.yellow.opacity(0.1)],
                startPoint: .leading,
                endPoint: .trailing
            )) :
                AnyView(Color(.secondarySystemBackground))
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(rank == 1 ? Color.orange.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            // Stronger haptic feedback for captain selections
            impactFeedback.impactOccurred()
            showingDetails.toggle()
        }
        .sheet(isPresented: $showingDetails) {
            VStack {
                Text("Captain Details")
                    .font(.title)
                    .padding()
                Text("\(suggestion.player.name) - Rank #\(rank)")
                    .font(.headline)
                Text("Projected Points: \(suggestion.projectedPoints)")
                Text("Confidence: \(suggestion.confidence)%")
                Text("Current Score: \(suggestion.player.currentScore)")
                Spacer()
                Button("Close") {
                    showingDetails = false
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }

    private func confidenceColor(for confidence: Int) -> Color {
        switch confidence {
        case 90...: .green
        case 80 ..< 90: .blue
        case 70 ..< 80: .orange
        default: .red
        }
    }

    private func formGrade(for player: EnhancedPlayer) -> String {
        let recentForm = Double(player.currentScore) / player.averageScore
        switch recentForm {
        case 1.2...: return "🔥"
        case 1.1 ..< 1.2: return "📈"
        case 0.9 ..< 1.1: return "➡️"
        case 0.8 ..< 0.9: return "📉"
        default: return "❄️"
        }
    }
}

// MARK: - TradeCalculatorView

struct TradeCalculatorView: View {
    @State private var selectedPlayerIn: EnhancedPlayer?
    @State private var selectedPlayerOut: EnhancedPlayer?

    // Native iOS Haptic Feedback
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("🔄 Trade Calculator")
                        .font(.title)
                        .bold()
                        .padding()

                    // Trade OUT section
                    VStack(alignment: .leading) {
                        Text("TRADE OUT")
                            .font(.headline)
                            .foregroundColor(.red)

                        Button("Select Player to Trade Out") {
                            selectionFeedback.selectionChanged()
                            // TODO: Show player picker
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)

                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title)
                        .foregroundColor(.orange)

                    // Trade IN section
                    VStack(alignment: .leading) {
                        Text("TRADE IN")
                            .font(.headline)
                            .foregroundColor(.green)

                        Button("Select Player to Trade In") {
                            selectionFeedback.selectionChanged()
                            // TODO: Show player picker
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)

                    // Trade Score
                    TradeScoreView()

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("🔄 Trades")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - TradeScoreView

struct TradeScoreView: View {
    var body: some View {
        VStack {
            Text("Trade Score")
                .font(.headline)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: 0.75)

                VStack {
                    Text("75")
                        .font(.title)
                        .bold()
                        .foregroundColor(.orange)
                    Text("Good Trade")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - CashCowView

struct CashCowView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)

                        Text("Cash Cow Tracker")
                            .font(.title2)
                            .bold()

                        Text("Rookies optimized for cash generation")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()

                    // Cash Cow Cards
                    ForEach(appState.cashCows) { player in
                        CashCowCard(player: player)
                    }
                }
                .padding()
            }
            .navigationTitle("💰 Cash Cows")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - CashCowCard

struct CashCowCard: View {
    let player: EnhancedPlayer

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)

                HStack {
                    Text(player.position.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(player.position.color.opacity(0.2))
                        .cornerRadius(4)

                    // Sell signal
                    if player.breakeven < 0 {
                        Text("🚀 SELL NOW")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.green)
                    } else if player.breakeven < 50 {
                        Text("⚠️ HOLD")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.orange)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(player.formattedPrice)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.green)

                Text("BE: \(player.breakeven)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - SettingsView

struct SettingsView: View {
    @State private var enableBreakevenAlerts = true
    @State private var enableInjuryAlerts = true
    @State private var enableLateOutAlerts = true

    var body: some View {
        NavigationView {
            Form {
                Section("🔔 Notifications") {
                    Toggle("Breakeven Alerts", isOn: $enableBreakevenAlerts)
                    Toggle("Injury Alerts", isOn: $enableInjuryAlerts)
                    Toggle("Late Out Alerts", isOn: $enableLateOutAlerts)
                }

                Section("📊 Data") {
                    HStack {
                        Text("Cache Size")
                        Spacer()
                        Text("12.4 MB")
                            .foregroundColor(.secondary)
                    }

                    Button("Clear Cache") {
                        // TODO: Implement cache clearing
                    }
                    .foregroundColor(.red)
                }

                Section("ℹ️ About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (MVP)")
                            .foregroundColor(.secondary)
                    }

                    if let privacyURL = URL(string: "https://afl.ai/privacy") {
                        Link("Privacy Policy", destination: privacyURL)
                    }
                    if let termsURL = URL(string: "https://afl.ai/terms") {
                        Link("Terms of Service", destination: termsURL)
                    }
                }
            }
            .navigationTitle("⚙️ Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AppState())
}
