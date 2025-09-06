//
//  ContentView.swift
//  AFLFantasy
//
//  Main app entry point and content view
//

import SwiftUI

// Removed @main from here - using SimpleAFLFantasyApp as entry point
struct AFLFantasyApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var dataService = AFLFantasyDataService()
    @StateObject private var toolsClient = AFLFantasyToolsClient()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(dataService)
                .environmentObject(toolsClient)
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            SimpleDashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(TabItem.dashboard)
            
            SimpleTradeCalculatorView()
                .tabItem {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Trades")
                }
                .tag(TabItem.trades)
            
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

// MARK: - Simple Views

// MARK: - SimpleDashboardView

struct SimpleDashboardView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Header with trophy
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.orange)

                            Text("Dashboard")
                                .font(.title2)
                                .fontWeight(.bold)

                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)

                    // Players List
                    ForEach(Array(appState.players.enumerated()), id: \.offset) { _, player in
                        SimplePlayerCard(player: player)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                    }
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("🏆 Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - SimplePlayerCard

struct SimplePlayerCard: View {
    let player: EnhancedPlayer

    private var positionColor: Color {
        switch player.position {
        case .defender: .blue
        case .midfielder: .green
        case .ruck: .purple
        case .forward: .red
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(player.position.rawValue.uppercased())
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(positionColor)
                            .cornerRadius(4)
                        
                        Text(player.formattedPrice)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(player.currentScore)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("Avg: \(String(format: "%.1f", player.averageScore))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - SimpleCaptainView

struct SimpleCaptainView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 28))
                                .foregroundColor(.orange)

                            Text("AI Captain Advisor")
                                .font(.title2)
                                .fontWeight(.bold)

                            Spacer()
                        }
                        .padding(.horizontal)

                        Text("Based on venue, form, and opponent analysis")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                    .padding(.bottom)

                    ForEach(Array(appState.captainSuggestions.enumerated()), id: \.offset) { index, suggestion in
                        SimpleCaptainCard(suggestion: suggestion, rank: index + 1, isTopPick: index == 0)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                    }
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("⭐ Captain")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - SimpleCaptainCard

struct SimpleCaptainCard: View {
    let suggestion: CaptainSuggestion
    let rank: Int
    let isTopPick: Bool

    private var confidenceColor: Color {
        switch suggestion.confidence {
        case 90 ... 100: .green
        case 80 ..< 90: Color.green.opacity(0.8)
        case 70 ..< 80: .blue
        default: .orange
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Rank circle
                ZStack {
                    Circle()
                        .fill(isTopPick ? Color.orange : Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)

                    Text("\(rank)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isTopPick ? .white : .primary)
                }

                // Player info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(suggestion.player.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)

                        if isTopPick {
                            HStack(spacing: 4) {
                                Text("🔥")
                                Text("Top Pick")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }

                        Spacer()
                    }

                    HStack {
                        Text(suggestion.player.position.rawValue.uppercased())
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(suggestion.player.position.color)
                            .cornerRadius(4)

                        Text("vs \(suggestion.player.opponent)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }

                // Projected points
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(suggestion.projectedPoints)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.orange)

                    Text("proj. pts")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            // Confidence info
            HStack {
                Text("AI Confidence: \(suggestion.confidence)%")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(confidenceColor)
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isTopPick ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
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

#Preview {
    ContentView()
        .environmentObject(AppState())
}
