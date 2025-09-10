//
//  CaptainAdvisorView.swift
//  AFL Fantasy Intelligence Platform
//
//  🧠 AI Captain Advisor - Maximize your points ceiling
//  Analyzes venue bias, opponent DVPs, and recent form to recommend optimal captain
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - CaptainAdvisorView

struct CaptainAdvisorView: View {
    @StateObject private var viewModel = CaptainAdvisorViewModel()
    @State private var selectedSuggestion: CaptainSuggestion?
    @State private var showingReasoningDetail = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // AI Recommendation Header
                    aiRecommendationHeader

                    // Top Suggestions List
                    captainSuggestionsSection

                    // Analysis Breakdown
                    analysisBreakdownSection

                    // Risk vs Reward Matrix
                    riskRewardSection

                    // Historical Performance
                    historicalPerformanceSection
                }
                .padding()
            }
            .navigationTitle("⭐ Captain AI")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    refreshButton
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(item: $selectedSuggestion) { suggestion in
                CaptainDetailView(suggestion: suggestion)
            }
            .alert("Captain Set", isPresented: $viewModel.showingConfirmation) {
                Button("OK") {}
            } message: {
                Text("✅ Captain set to \(viewModel.selectedCaptainName)")
            }
        }
    }

    // MARK: - AI Recommendation Header

    private var aiRecommendationHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.title2)
                            .foregroundColor(.purple)

                        Text("AI Recommendation")
                            .font(.headline)
                            .fontWeight(.semibold)

                        Spacer()

                        if let topSuggestion = viewModel.suggestions.first {
                            VStack {
                                Text("\(topSuggestion.confidence)%")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(topSuggestion.confidenceColor)

                                Text("confidence")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    if let topSuggestion = viewModel.suggestions.first {
                        Text(topSuggestion.player.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        HStack {
                            Text(topSuggestion.player.position.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(topSuggestion.player.position.color.opacity(0.2))
                                .foregroundColor(topSuggestion.player.position.color)
                                .clipShape(Capsule())

                            Text(topSuggestion.player.team.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            Text("\(topSuggestion.projectedPoints) pts")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }

                        // Quick Reasoning
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)

                            Text(topSuggestion.reasoning.first ?? "Strong form and favorable matchup")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 8)
                    }
                }
            }

            // Quick Set Captain Button
            if let topSuggestion = viewModel.suggestions.first {
                Button(action: {
                    viewModel.setCaptain(topSuggestion.player)
                }) {
                    HStack {
                        Image(systemName: "star.fill")
                        Text("Set as Captain")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(viewModel.isLoading)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Captain Suggestions Section

    private var captainSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Top 5 Recommendations", systemImage: "list.number")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Menu {
                    Button("By Confidence") { viewModel.sortBy = .confidence }
                    Button("By Projected Points") { viewModel.sortBy = .projectedPoints }
                    Button("By Ownership") { viewModel.sortBy = .ownership }
                    Button("By Risk Level") { viewModel.sortBy = .risk }
                } label: {
                    HStack {
                        Text("Sort")
                            .font(.caption)
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.caption2)
                    }
                }
            }

            LazyVStack(spacing: 12) {
                ForEach(viewModel.sortedSuggestions.prefix(5), id: \.id) { suggestion in
                    CaptainSuggestionCard(
                        suggestion: suggestion,
                        rank: viewModel.getRank(for: suggestion)
                    ) {
                        selectedSuggestion = suggestion
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Analysis Breakdown Section

    private var analysisBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Analysis Factors", systemImage: "chart.bar.fill")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                AnalysisFactorCard(
                    title: "Venue Bias",
                    value: "+8.3",
                    subtitle: "MCG advantage",
                    icon: "location.fill",
                    color: .green
                )

                AnalysisFactorCard(
                    title: "Opponent DVP",
                    value: "12th",
                    subtitle: "vs Midfielders",
                    icon: "target",
                    color: .orange
                )

                AnalysisFactorCard(
                    title: "Recent Form",
                    value: "127",
                    subtitle: "3-round avg",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )

                AnalysisFactorCard(
                    title: "Weather Impact",
                    value: "Low",
                    subtitle: "Clear conditions",
                    icon: "sun.max.fill",
                    color: .yellow
                )
            }

            // Key Insights
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.caption)
                        .foregroundColor(.purple)

                    Text("Key Insights")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                ForEach(viewModel.keyInsights, id: \.self) { insight in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(.secondary)
                            .frame(width: 4, height: 4)
                            .padding(.top, 6)

                        Text(insight)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.top)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Risk vs Reward Section

    private var riskRewardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Risk vs Reward Analysis", systemImage: "scale.3d")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                RiskRewardCard(
                    title: "High Ceiling",
                    players: viewModel.highCeilingPlayers,
                    color: .green,
                    icon: "arrow.up.circle.fill"
                )

                RiskRewardCard(
                    title: "Safe Floor",
                    players: viewModel.safeFloorPlayers,
                    color: .blue,
                    icon: "checkmark.shield.fill"
                )

                RiskRewardCard(
                    title: "Differential",
                    players: viewModel.differentialPlayers,
                    color: .purple,
                    icon: "person.crop.circle.badge.plus"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Historical Performance Section

    private var historicalPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Historical Captain Performance", systemImage: "chart.bar.xaxis")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button("View All") {
                    // Show detailed history
                }
                .font(.caption)
                .foregroundColor(.blue)
            }

            VStack(spacing: 12) {
                ForEach(viewModel.recentCaptainHistory, id: \.round) { history in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Round \(history.round)")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(history.playerName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(history.score) pts")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(history.score >= history.averageScore ? .green : .red)

                            Text("Avg: \(Int(history.averageScore))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        Image(systemName: history.score >= history
                            .averageScore ? "checkmark.circle.fill" : "xmark.circle.fill"
                        )
                        .foregroundColor(history.score >= history.averageScore ? .green : .red)
                    }
                    .padding(.vertical, 4)

                    if history != viewModel.recentCaptainHistory.last {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Toolbar Items

    private var refreshButton: some View {
        Button(action: {
            Task {
                await viewModel.refresh()
            }
        }) {
            Image(systemName: "arrow.clockwise")
                .font(.title3)
        }
        .disabled(viewModel.isLoading)
    }
}

// MARK: - CaptainSuggestionCard

struct CaptainSuggestionCard: View {
    let suggestion: CaptainSuggestion
    let rank: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Rank Badge
                Text("\(rank)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(suggestion.confidenceColor)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(suggestion.player.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Spacer()

                        Text("\(suggestion.projectedPoints) pts")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }

                    HStack {
                        Text(suggestion.player.position.rawValue)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(suggestion.player.position.color.opacity(0.2))
                            .foregroundColor(suggestion.player.position.color)
                            .clipShape(Capsule())

                        Text(suggestion.player.team.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("\(suggestion.confidence)%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(suggestion.confidenceColor)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - AnalysisFactorCard

struct AnalysisFactorCard: View {
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
    }
}

// MARK: - RiskRewardCard

struct RiskRewardCard: View {
    let title: String
    let players: [String]
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            VStack(spacing: 2) {
                ForEach(players.prefix(2), id: \.self) { player in
                    Text(player)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    CaptainAdvisorView()
}
