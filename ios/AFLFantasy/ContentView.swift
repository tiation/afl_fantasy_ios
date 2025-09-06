//
//  ContentView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
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
    }
}

// MARK: - Dashboard View
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
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                appState.teamScore = Int.random(in: 1800...2200)
                appState.teamRank = Int.random(in: 1000...15000)
            }
        }
    }
}

// MARK: - Team Score Header
struct TeamScoreHeaderView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("TEAM SCORE")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(appState.teamScore)")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("RANK")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("#\(appState.teamRank)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.green)
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

// MARK: - Player Card View
struct PlayerCardView: View {
    let player: Player
    
    var body: some View {
        HStack {
            // Position indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(player.position.color)
                .frame(width: 6, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text(player.position.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(player.position.color.opacity(0.2))
                        .cornerRadius(4)
                    
                    Text(player.formattedPrice)
                        .font(.caption)
                        .foregroundColor(.secondary)
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
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Captain Advisor View
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

struct CaptainSuggestionCard: View {
    let suggestion: CaptainSuggestion
    let rank: Int
    
    var body: some View {
        HStack {
            // Rank
            ZStack {
                Circle()
                    .fill(rank == 1 ? .yellow : .gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                Text("\(rank)")
                    .font(.headline)
                    .bold()
                    .foregroundColor(rank == 1 ? .black : .white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.player.name)
                    .font(.headline)
                
                Text("Confidence: \(suggestion.confidence)%")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(suggestion.projectedPoints)")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.orange)
                
                Text("proj. pts")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Trade Calculator View
struct TradeCalculatorView: View {
    @State private var selectedPlayerIn: Player?
    @State private var selectedPlayerOut: Player?
    
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

// MARK: - Cash Cow View
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

struct CashCowCard: View {
    let player: Player
    
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

// MARK: - Settings View
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
                    
                    Link("Privacy Policy", destination: URL(string: "https://afl.ai/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://afl.ai/terms")!)
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
