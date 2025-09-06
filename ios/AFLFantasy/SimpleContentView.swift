//
//  SimpleContentView.swift
//  AFL Fantasy Intelligence Platform
//
//  Simple ContentView to get the build working
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - SimpleContentView

struct SimpleContentView: View {
    @EnvironmentObject var appState: PersistentAppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            SimpleTradeCalculatorView()
                .tabItem {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Trades")
                }
                .tag(TabItem.trades)

            SimpleDashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(TabItem.dashboard)

            SimpleCaptainView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Captain")
                }
                .tag(TabItem.captain)

            SimpleCashCowView()
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Cash Cow")
                }
                .tag(TabItem.cashCow)

            SimpleSettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(TabItem.settings)
        }
        .accentColor(.orange)
    }
}

// MARK: - SimpleDashboardView

struct SimpleDashboardView: View {
    @EnvironmentObject var appState: PersistentAppState

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Team Score Header
                    VStack {
                        Text("Team Score: \(appState.teamScore)")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Rank: #\(appState.teamRank)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Players List
                    LazyVStack(spacing: 12) {
                        ForEach(appState.players) { player in
                            SimplePlayerCard(player: player)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("🏆 Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - SimplePlayerCard

struct SimplePlayerCard: View {
    let player: EnhancedPlayer

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(player.name)
                        .font(.headline)
                    Text(player.position.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("\(player.currentScore)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text(player.formattedPrice)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

// MARK: - SimpleCaptainView

struct SimpleCaptainView: View {
    @EnvironmentObject var appState: PersistentAppState

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Text("🧠 AI Captain Advisor")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()

                    ForEach(appState.captainSuggestions) { suggestion in
                        SimpleCaptainCard(suggestion: suggestion)
                    }
                }
                .padding()
            }
            .navigationTitle("⭐ Captain AI")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - SimpleCaptainCard

struct SimpleCaptainCard: View {
    let suggestion: CaptainSuggestion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(suggestion.player.name)
                    .font(.headline)

                Spacer()

                Text("\(suggestion.confidence)%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }

            Text("Projected: \(suggestion.projectedPoints) pts")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

// MARK: - SimpleTradeCalculatorView

struct SimpleTradeCalculatorView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("🔄 Trade Calculator")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()

                Text("Coming Soon")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .navigationTitle("🔄 Trades")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - SimpleCashCowView

struct SimpleCashCowView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("💰 Cash Cow Tracker")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()

                Text("Coming Soon")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .navigationTitle("💰 Cash Cow")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - SimpleSettingsView

struct SimpleSettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("⚙️ Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()

                Text("Coming Soon")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .navigationTitle("⚙️ Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - TabItem

enum TabItem: String, CaseIterable {
    case dashboard = "Dashboard"
    case captain = "Captain"
    case trades = "Trades"
    case cashCow = "Cash Cow"
    case settings = "Settings"

    var systemImage: String {
        switch self {
        case .dashboard: "house.fill"
        case .captain: "star.fill"
        case .trades: "arrow.triangle.2.circlepath"
        case .cashCow: "dollarsign.circle.fill"
        case .settings: "gearshape.fill"
        }
    }
}
