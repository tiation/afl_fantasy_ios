//
//  AFLFantasyTabView.swift
//  AFL Fantasy Intelligence Platform
//
//  Main TabView bringing together all the intelligence features
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - AFLFantasyTabView

struct AFLFantasyTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: TabItem = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            // 🏆 Core Intelligence Dashboard
            DashboardView()
                .tabItem {
                    Label(TabItem.dashboard.rawValue, systemImage: TabItem.dashboard.systemImage)
                }
                .tag(TabItem.dashboard)

            // ⭐ AI Captain Advisor
            AdvancedCaptainAI()
                .tabItem {
                    Label(TabItem.captain.rawValue, systemImage: TabItem.captain.systemImage)
                }
                .tag(TabItem.captain)

            // 🔄 AI Trade Suggester
            TradeAnalyzerView()
                .tabItem {
                    Label(TabItem.trades.rawValue, systemImage: TabItem.trades.systemImage)
                }
                .tag(TabItem.trades)

            // ⚠️ Smart Alert Center
            AlertCenterView()
                .tabItem {
                    Label(TabItem.alerts.rawValue, systemImage: TabItem.alerts.systemImage)
                }
                .tag(TabItem.alerts)

            // 📊 Advanced Analysis
            AnalysisCenterView()
                .tabItem {
                    Label(TabItem.analysis.rawValue, systemImage: TabItem.analysis.systemImage)
                }
                .tag(TabItem.analysis)
        }
        .accentColor(.orange)
        .environmentObject(appState)
    }
}

// MARK: - TradeAnalyzerView

struct TradeAnalyzerView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .padding()

                Text("🤖 AI Trade Suggester")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()

                Text(
                    "Machine learning models suggest the most impactful trades by projecting not just next week's scores, but price changes for the next 3 rounds and rest of season."
                )
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                Spacer()

                Text("Coming Soon")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }
            .navigationTitle("🔄 Trade AI")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - AlertCenterView

struct AlertCenterView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "bell.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .padding()

                Text("⚠️ Smart Alert System")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()

                Text(
                    "AI Alert Generator proactively warns you about price drop risks, breakeven cliffs, and potential cash cows before the market moves."
                )
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                Spacer()

                Text("Coming Soon")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }
            .navigationTitle("⚠️ Alert Center")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - AnalysisCenterView

struct AnalysisCenterView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)

                        Text("📊 Advanced Analysis")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Deep dive analytics and contextual player analysis")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()

                    // Analysis Categories
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        AnalysisCategoryCard(
                            title: "Cash Generation",
                            subtitle: "Price Analytics",
                            icon: "dollarsign.circle.fill",
                            color: .green,
                            description: "Track cash cow potential and optimal sell windows"
                        )

                        AnalysisCategoryCard(
                            title: "Venue Bias",
                            subtitle: "Ground Analysis",
                            icon: "location.fill",
                            color: .blue,
                            description: "Player performance by venue and conditions"
                        )

                        AnalysisCategoryCard(
                            title: "Consistency Scores",
                            subtitle: "Reliability Metrics",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .orange,
                            description: "How reliably players hit projected scores"
                        )

                        AnalysisCategoryCard(
                            title: "Risk Assessment",
                            subtitle: "Injury & Suspension",
                            icon: "exclamationmark.triangle.fill",
                            color: .red,
                            description: "Algorithmic risk scoring for smart decisions"
                        )

                        AnalysisCategoryCard(
                            title: "Fixture Analysis",
                            subtitle: "Upcoming Difficulty",
                            icon: "calendar.circle.fill",
                            color: .purple,
                            description: "5-round fixture difficulty ratings"
                        )

                        AnalysisCategoryCard(
                            title: "Weather Impact",
                            subtitle: "Conditions Model",
                            icon: "cloud.rain.fill",
                            color: .gray,
                            description: "Performance adjustments for rain and wind"
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("📊 Analysis")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - AnalysisCategoryCard

struct AnalysisCategoryCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    AFLFantasyTabView()
}
