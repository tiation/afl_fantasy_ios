//
//  DashboardView.swift
//  AFL Fantasy Intelligence Platform
//
//  🏈 Core Intelligence Dashboard - The Ultimate Coaching Advantage
//  Transform raw data into actionable winning strategies
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - DashboardView

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var selectedTimeframe: Timeframe = .week
    @State private var showingTeamAnalysis = false

    enum Timeframe: String, CaseIterable {
        case week = "This Week"
        case month = "This Month"
        case season = "Season"
    }

    var body: some View {
        NavigationView {
            Group {
                if viewModel.hasError {
                    errorStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Live Performance Header
                            livePerformanceHeader

                            // Quick Stats Cards
                            quickStatsSection

                            // Weekly Projection Summary
                            weeklyProjectionSection

                            // AI Insights Panel
                            aiInsightsSection

                            // Critical Alerts
                            criticalAlertsSection
                        }
                        .padding()
                        .opacity(viewModel.isRefreshing ? 0.6 : 1.0)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle("🏆 Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .overlay {
                if viewModel.isRefreshing && !viewModel.hasError {
                    VStack {
                        AFLLoadingAnimation()
                        Text("Updating...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
                }
            }
        }
    }

    // MARK: - Live Performance Header

    private var livePerformanceHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                            .opacity(viewModel.isLive ? 1.0 : 0.3)
                            .accessibilityHidden(true)

                        Text("LIVE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(viewModel.isLive ? "Live scores updating" : "Scores not live")

                    Text("Team Score")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(viewModel.currentScore)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .accessibilityLabel("\(viewModel.currentScore) points")

                        Text("pts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .accessibilityHidden(true)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Current team score: \(viewModel.currentScore) points")

                    HStack(spacing: 4) {
                        Image(systemName: viewModel.scoreChange >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                            .foregroundColor(viewModel.scoreChange >= 0 ? .green : .red)

                        Text("\(abs(viewModel.scoreChange)) from last week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Rank")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("#\(viewModel.currentRank)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)

                    HStack(spacing: 4) {
                        Image(systemName: viewModel.rankChange <= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                            .foregroundColor(viewModel.rankChange <= 0 ? .green : .red)

                        Text("\(abs(viewModel.rankChange))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Projected Performance Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Projected This Round")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Text("\(Int(viewModel.projectedScore)) pts")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }

                ProgressView(value: viewModel.projectedScore, total: 2400) {
                    EmptyView()
                } currentValueLabel: {
                    EmptyView()
                }
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(y: 2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Quick Stats Section

    private var quickStatsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            StatCard(
                title: "Team Value",
                value: viewModel.teamValue,
                subtitle: "Bank: \(viewModel.bankBalance)",
                icon: "creditcard.fill",
                color: .green
            )

            StatCard(
                title: "Trades Left",
                value: "\(viewModel.tradesRemaining)",
                subtitle: "Used: \(viewModel.tradesUsed)",
                icon: "arrow.triangle.2.circlepath",
                color: .blue
            )

            StatCard(
                title: "Cash Cows",
                value: "\(viewModel.cashCowCount)",
                subtitle: "\(viewModel.cashGenerationRate)/wk avg",
                icon: "dollarsign.circle.fill",
                color: .orange
            )

            StatCard(
                title: "Risk Level",
                value: viewModel.riskLevel.displayName.replacingOccurrences(of: " Risk", with: ""),
                subtitle: "Overall exposure",
                icon: viewModel.riskLevel.icon,
                color: viewModel.riskLevel.color
            )
        }
    }

    // MARK: - Weekly Projection Section

    private var weeklyProjectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Weekly Projection Summary", systemImage: "crystal.ball.fill")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ProjectionCard(
                    title: "Win Probability",
                    value: "\(Int(viewModel.winProbability))%",
                    icon: "trophy.fill",
                    color: .green
                )

                ProjectionCard(
                    title: "Expected Rank",
                    value: "#\(viewModel.expectedRank)",
                    icon: "number.circle.fill",
                    color: .blue
                )

                ProjectionCard(
                    title: "Key Matchups",
                    value: "\(viewModel.keyMatchups)",
                    icon: "target",
                    color: .orange
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - AI Insights Section

    private var aiInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("AI Insights", systemImage: "brain.head.profile")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
            }

            ForEach(viewModel.aiInsights.prefix(3), id: \.id) { insight in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: insight.icon)
                        .font(.title3)
                        .foregroundColor(insight.color)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(insight.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text(insight.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()
                }
                .padding(.vertical, 8)

                if insight != viewModel.aiInsights.prefix(3).last {
                    Divider()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Critical Alerts Section

    private var criticalAlertsSection: some View {
        if !viewModel.criticalAlerts.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Critical Alerts", systemImage: "exclamationmark.triangle.fill")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)

                    Spacer()

                    Text("\(viewModel.criticalAlerts.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }

                ForEach(viewModel.criticalAlerts.prefix(3), id: \.id) { alert in
                    HStack(spacing: 12) {
                        Image(systemName: alert.type.icon)
                            .font(.title3)
                            .foregroundColor(alert.type.color)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(alert.title)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Text(alert.message)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Circle()
                            .fill(alert.priority.color)
                            .frame(width: 8, height: 8)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.red.opacity(0.05))
            )
        }
    }
    
    // MARK: - Error State View
    
    private var errorStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            VStack(spacing: 12) {
                Text("Something went wrong")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            AFLButton(
                title: "Try Again",
                style: .primary
            ) {
                Task {
                    await viewModel.refresh()
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - StatCard

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .accessibilityHidden(true)
                Spacer()
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value). \(subtitle)")
        .accessibilityAddTraits(.isStaticText)
    }
}

// MARK: - ProjectionCard

struct ProjectionCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .accessibilityHidden(true)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
        .accessibilityAddTraits(.isStaticText)
    }
}

#Preview {
    DashboardView()
}
