//
//  EnhancedTradeCalculatorView.swift
//  AFL Fantasy Intelligence Platform
//
//  Complete trade calculator with player selection and analysis
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - EnhancedTradeCalculatorView

struct EnhancedTradeCalculatorView: View {
    @EnvironmentObject var appState: LiveAppState
    @StateObject private var tradeService = TradeCalculatorService()

    // MARK: - State Properties

    @State private var selectedPlayerOut: EnhancedPlayer?
    @State private var selectedPlayerIn: EnhancedPlayer?
    @State private var searchText = ""
    @State private var selectedPosition: Position?
    @State private var showingPlayerOutSelection = false
    @State private var showingPlayerInSelection = false
    @State private var showingTradeDetails = false

    // Filtering
    @State private var priceRange: ClosedRange<Double> = 300_000 ... 1_000_000
    @State private var sortOption: PlayerSortOption = .price

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Trade Summary Card
                    tradeSummaryCard

                    // Player Selection Section
                    playerSelectionSection

                    // Trade Analysis
                    if selectedPlayerOut != nil, selectedPlayerIn != nil {
                        tradeAnalysisSection
                    }

                    // Trade Recommendations
                    tradeRecommendationsSection
                }
                .padding(.horizontal)
            }
            .navigationTitle("🔄 Trade Calculator")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await appState.refreshTrades()
            }
        }
        .sheet(isPresented: $showingPlayerOutSelection) {
            PlayerSelectionView(
                title: "Select Player to Trade Out",
                players: appState.players,
                selectedPlayer: $selectedPlayerOut,
                searchText: $searchText,
                selectedPosition: $selectedPosition,
                priceRange: $priceRange,
                sortOption: $sortOption
            )
        }
        .sheet(isPresented: $showingPlayerInSelection) {
            PlayerSelectionView(
                title: "Select Player to Trade In",
                players: availablePlayersForTradeIn,
                selectedPlayer: $selectedPlayerIn,
                searchText: $searchText,
                selectedPosition: $selectedPosition,
                priceRange: $priceRange,
                sortOption: $sortOption
            )
        }
    }

    // MARK: - View Components

    private var tradeSummaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Trade Summary")
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                if let score = tradeService.currentTradeScore {
                    TradeScoreCircle(score: score)
                }
            }

            if let tradeOut = selectedPlayerOut, let tradeIn = selectedPlayerIn {
                HStack(spacing: 20) {
                    // Player Out
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Trading Out")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(tradeOut.name)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text(tradeOut.formattedPrice)
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    Image(systemName: "arrow.right")
                        .foregroundColor(.orange)
                        .font(.title2)

                    // Player In
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Trading In")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(tradeIn.name)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text(tradeIn.formattedPrice)
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                // Net Cost
                let netCost = tradeIn.price - tradeOut.price
                HStack {
                    Text("Net Cost:")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Text(formatCurrency(netCost))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(netCost > 0 ? .red : .green)
                }

                // Available Salary Check
                if netCost > appState.remainingSalary {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)

                        Text("Insufficient salary cap space")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

            } else {
                Text("Select players to analyze trade")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(height: 60)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var playerSelectionSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Player Selection")
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                Button("Clear All") {
                    selectedPlayerOut = nil
                    selectedPlayerIn = nil
                    tradeService.clearTrade()
                }
                .font(.caption)
                .foregroundColor(.orange)
            }

            HStack(spacing: 12) {
                // Trade Out Button
                Button(action: {
                    showingPlayerOutSelection = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: selectedPlayerOut != nil ? "checkmark.circle.fill" : "minus.circle")
                            .font(.title2)
                            .foregroundColor(selectedPlayerOut != nil ? .green : .orange)

                        Text(selectedPlayerOut?.name ?? "Select Player Out")
                            .font(.caption)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)

                        if let player = selectedPlayerOut {
                            Text(player.formattedPrice)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())

                // Trade In Button
                Button(action: {
                    showingPlayerInSelection = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: selectedPlayerIn != nil ? "checkmark.circle.fill" : "plus.circle")
                            .font(.title2)
                            .foregroundColor(selectedPlayerIn != nil ? .green : .orange)

                        Text(selectedPlayerIn?.name ?? "Select Player In")
                            .font(.caption)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)

                        if let player = selectedPlayerIn {
                            Text(player.formattedPrice)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var tradeAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trade Analysis")
                .font(.headline)
                .fontWeight(.bold)

            if let analysis = tradeService.currentTradeAnalysis {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    AnalysisCard(
                        title: "Score Impact",
                        value: String(format: "%.1f", analysis.scoreImpact),
                        subtitle: "pts/round",
                        color: analysis.scoreImpact > 0 ? .green : .red,
                        icon: "chart.line.uptrend.xyaxis"
                    )

                    AnalysisCard(
                        title: "Value Rating",
                        value: String(format: "%.1f", analysis.valueRating),
                        subtitle: "/10",
                        color: valueRatingColor(analysis.valueRating),
                        icon: "star.fill"
                    )

                    AnalysisCard(
                        title: "Risk Level",
                        value: analysis.riskLevel.rawValue,
                        subtitle: "risk",
                        color: riskLevelColor(analysis.riskLevel),
                        icon: "shield.fill"
                    )

                    AnalysisCard(
                        title: "ROI Period",
                        value: "\\(analysis.paybackPeriod)",
                        subtitle: "rounds",
                        color: .blue,
                        icon: "calendar"
                    )
                }

                // Detailed Analysis
                VStack(alignment: .leading, spacing: 8) {
                    Text("Analysis Summary")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(analysis.summary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .onAppear {
            calculateTradeAnalysis()
        }
        .onChange(of: selectedPlayerOut) { _ in
            calculateTradeAnalysis()
        }
        .onChange(of: selectedPlayerIn) { _ in
            calculateTradeAnalysis()
        }
    }

    private var tradeRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("AI Recommendations")
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                Button("Refresh") {
                    Task {
                        await appState.refreshTrades()
                    }
                }
                .font(.caption)
                .foregroundColor(.orange)
            }

            if appState.tradeRecommendations.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundColor(.secondary)

                    Text("Loading AI recommendations...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(
                        Array(appState.tradeRecommendations.prefix(3).enumerated()),
                        id: \\.offset
                    ) { index, recommendation in
                        TradeRecommendationCard(
                            recommendation: recommendation,
                            rank: index + 1,
                            onSelect: {
                                selectRecommendedTrade(recommendation)
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    // MARK: - Helper Properties

    private var availablePlayersForTradeIn: [EnhancedPlayer] {
        appState.players.filter { player in
            // Exclude the player being traded out
            guard let playerOut = selectedPlayerOut else { return true }
            return player.id != playerOut.id
        }
    }

    // MARK: - Helper Methods

    private func calculateTradeAnalysis() {
        guard let playerOut = selectedPlayerOut,
              let playerIn = selectedPlayerIn
        else {
            tradeService.clearTrade()
            return
        }

        tradeService.calculateTrade(playerOut: playerOut, playerIn: playerIn)
    }

    private func selectRecommendedTrade(_ recommendation: TradeRecommendation) {
        // Find players by name
        selectedPlayerOut = appState.players.first { $0.name == recommendation.tradeOut }
        selectedPlayerIn = appState.players.first { $0.name == recommendation.tradeIn }

        calculateTradeAnalysis()
    }

    private func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$\\(amount)"
    }

    private func valueRatingColor(_ rating: Double) -> Color {
        switch rating {
        case 8.0...: .green
        case 6.0 ..< 8.0: .orange
        default: .red
        }
    }

    private func riskLevelColor(_ risk: TradeRiskLevel) -> Color {
        switch risk {
        case .low: .green
        case .medium: .orange
        case .high: .red
        }
    }
}

// MARK: - AnalysisCard

struct AnalysisCard: View {
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
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - TradeScoreCircle

struct TradeScoreCircle: View {
    let score: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 8)
                .frame(width: 60, height: 60)

            Circle()
                .trim(from: 0, to: min(score / 100, 1.0))
                .stroke(scoreColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 60, height: 60)

            VStack(spacing: 0) {
                Text("\\(Int(score))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(scoreColor)

                Text("SCORE")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var scoreColor: Color {
        switch score {
        case 80...: .green
        case 60 ..< 80: .orange
        default: .red
        }
    }
}

// MARK: - TradeRecommendationCard

struct TradeRecommendationCard: View {
    let recommendation: TradeRecommendation
    let rank: Int
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Rank Badge
                ZStack {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 24, height: 24)

                    Text("\\(rank)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(recommendation.tradeOut)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.red)

                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(recommendation.tradeIn)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }

                    Text(recommendation.reasoning)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    HStack {
                        Text("Impact: +\\(String(format: "%.1f", recommendation.projectedImpact))")
                            .font(.caption)
                            .foregroundColor(.green)

                        Spacer()

                        Text("\\(Int(recommendation.confidence))% confidence")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var rankColor: Color {
        switch rank {
        case 1: .green
        case 2: .orange
        default: .gray
        }
    }
}

// MARK: - PlayerSortOption

enum PlayerSortOption: String, CaseIterable {
    case price = "Price"
    case average = "Average"
    case name = "Name"
    case position = "Position"
}
