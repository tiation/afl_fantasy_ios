//
//  PlayerDetailView.swift
//  AFL Fantasy Intelligence Platform
//
//  Comprehensive Player Analysis View showing all AI insights
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - PlayerDetailView

struct PlayerDetailView: View {
    let player: Player
    @Environment(\.dismiss) private var dismiss
    @StateObject private var analyticsService = AdvancedAnalyticsService()
    @State private var pricePrediction: PlayerPricePrediction?
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Player Header
                    PlayerHeaderView(player: player)

                    // Tab Selection
                    Picker("Analysis", selection: $selectedTab) {
                        Text("Overview").tag(0)
                        Text("Price Analysis").tag(1)
                        Text("Performance").tag(2)
                        Text("Risk Analysis").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Content based on selected tab
                    Group {
                        switch selectedTab {
                        case 0:
                            OverviewTabView(player: player)
                        case 1:
                            PriceAnalysisTabView(player: player, prediction: pricePrediction)
                        case 2:
                            PerformanceTabView(player: player)
                        case 3:
                            RiskAnalysisTabView(player: player)
                        default:
                            OverviewTabView(player: player)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(player.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                generatePricePrediction()
            }
        }
    }

    private func generatePricePrediction() {
        let predictions = analyticsService.predictPriceChanges(for: [player])
        pricePrediction = predictions.first
    }
}

// MARK: - PlayerHeaderView

struct PlayerHeaderView: View {
    let player: Player

    var body: some View {
        VStack(spacing: 16) {
            // Main player info
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(player.name)
                        .font(.largeTitle)
                        .bold()

                    HStack {
                        Text(player.position.rawValue)
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(player.position.color)
                            .foregroundColor(.white)
                            .cornerRadius(8)

                        Text(player.teamAbbreviation)
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                    }
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(player.formattedPrice)
                        .font(.title)
                        .bold()
                        .foregroundColor(.green)

                    Text("Current Score: \\(player.currentScore)")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
            }

            // Key metrics row
            HStack {
                MetricCard(title: "Average", value: "\\(Int(player.averageScore))", color: .blue)
                MetricCard(
                    title: "Consistency",
                    value: player.consistencyGrade,
                    color: consistencyColor(for: player.consistency)
                )
                MetricCard(title: "Breakeven", value: "\\(player.breakeven)", color: .gray)
                MetricCard(title: "Games", value: "\\(player.gamesPlayed)", color: .purple)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private func consistencyColor(for consistency: Double) -> Color {
        switch consistency {
        case 90...: .green
        case 80 ..< 90: .blue
        case 70 ..< 80: .yellow
        default: .red
        }
    }
}

// MARK: - MetricCard

struct MetricCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .bold()
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
}

// MARK: - OverviewTabView

struct OverviewTabView: View {
    let player: Player

    var body: some View {
        VStack(spacing: 16) {
            // Performance Summary
            AnalyticsCard(title: "⭐ Performance Summary") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Ceiling:")
                        Spacer()
                        Text("\\(player.ceiling)")
                            .bold()
                            .foregroundColor(.green)
                    }

                    HStack {
                        Text("Floor:")
                        Spacer()
                        Text("\\(player.floor)")
                            .bold()
                            .foregroundColor(.red)
                    }

                    HStack {
                        Text("Volatility:")
                        Spacer()
                        Text(String(format: "%.1f", player.volatility))
                            .bold()
                            .foregroundColor(.orange)
                    }

                    HStack {
                        Text("Total Score:")
                        Spacer()
                        Text("\\(player.totalScore)")
                            .bold()
                    }
                }
            }

            // Next Round Projection
            AnalyticsCard(title: "🔮 Next Round Projection") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Projected Score:")
                        Spacer()
                        Text(String(format: "%.1f", player.nextRoundProjection.projectedScore))
                            .bold()
                            .foregroundColor(.blue)
                    }

                    HStack {
                        Text("Opponent:")
                        Spacer()
                        Text(player.nextRoundProjection.opponent)
                            .bold()
                    }

                    HStack {
                        Text("Venue:")
                        Spacer()
                        Text(player.nextRoundProjection.venue)
                            .bold()
                    }

                    HStack {
                        Text("Confidence:")
                        Spacer()
                        Text(String(format: "%.0f%%", player.nextRoundProjection.confidence))
                            .bold()
                            .foregroundColor(.green)
                    }
                }
            }

            // Weather Conditions
            AnalyticsCard(title: "🌤️ Match Conditions") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Temperature:")
                        Spacer()
                        Text("\\(player.nextRoundProjection.conditions.temperature)°C")
                            .bold()
                    }

                    HStack {
                        Text("Wind Speed:")
                        Spacer()
                        Text("\\(player.nextRoundProjection.conditions.windSpeed) km/h")
                            .bold()
                    }

                    HStack {
                        Text("Rain Chance:")
                        Spacer()
                        Text(String(format: "%.0f%%", player.nextRoundProjection.conditions.rainProbability * 100))
                            .bold()
                            .foregroundColor(player.nextRoundProjection.conditions
                                .rainProbability > 0.5 ? .blue : .gray
                            )
                    }
                }
            }
        }
    }
}

// MARK: - PriceAnalysisTabView

struct PriceAnalysisTabView: View {
    let player: Player
    let prediction: PlayerPricePrediction?

    var body: some View {
        VStack(spacing: 16) {
            if let prediction {
                // Next Round Price Change
                AnalyticsCard(title: "📈 Next Round Price Change") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Predicted Change:")
                            Spacer()
                            Text(
                                "\\(prediction.nextRoundChange.amount >= 0 ? \"+\" : \"\")$\\(prediction.nextRoundChange.amount/1000)k"
                            )
                            .bold()
                            .foregroundColor(prediction.nextRoundChange.amount >= 0 ? .green : .red)
                        }

                        HStack {
                            Text("Probability:")
                            Spacer()
                            Text(String(format: "%.0f%%", prediction.nextRoundChange.probability * 100))
                                .bold()
                                .foregroundColor(.blue)
                        }

                        Text("Reasoning:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(prediction.nextRoundChange.reasoning)
                            .font(.caption)
                    }
                }

                // 3-Round Outlook
                AnalyticsCard(title: "📊 3-Round Outlook") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Expected Change:")
                            Spacer()
                            Text(
                                "\\(prediction.threeRoundChange.amount >= 0 ? \"+\" : \"\")$\\(prediction.threeRoundChange.amount/1000)k"
                            )
                            .bold()
                            .foregroundColor(prediction.threeRoundChange.amount >= 0 ? .green : .red)
                        }

                        HStack {
                            Text("Confidence:")
                            Spacer()
                            Text(String(format: "%.0f%%", prediction.confidence * 100))
                                .bold()
                                .foregroundColor(.green)
                        }
                    }
                }

                // Season End Projection
                AnalyticsCard(title: "🏆 Season End Projection") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Projected Final Price:")
                            Spacer()
                            Text("$\\(prediction.seasonEndPrice/1000)k")
                                .bold()
                                .foregroundColor(.purple)
                        }

                        HStack {
                            Text("Total Rise:")
                            Spacer()
                            let totalRise = prediction.seasonEndPrice - player.currentPrice
                            Text("\\(totalRise >= 0 ? \"+\" : \"\")$\\(totalRise/1000)k")
                                .bold()
                                .foregroundColor(totalRise >= 0 ? .green : .red)
                        }
                    }
                }

                // Price Factors
                AnalyticsCard(title: "🔍 Price Factors") {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(prediction.factors, id: \\.factor) { factor in
                            HStack {
                                Text(factorIcon(for: factor.impact))
                                Text(factor.factor)
                                    .font(.caption)
                                Spacer()
                                Text(String(format: "%.0f%%", factor.weight * 100))
                                    .font(.caption)
                                    .foregroundColor(factor.impact.color)
                            }
                        }
                    }
                }
            }

            // Cash Cow Analysis (if applicable)
            if player.isCashCow {
                AnalyticsCard(title: "💰 Cash Cow Analysis") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Cash Generated:")
                            Spacer()
                            Text("$\\(player.cashGenerated/1000)k")
                                .bold()
                                .foregroundColor(.green)
                        }

                        HStack {
                            Text("Premium Potential:")
                            Spacer()
                            Text(String(format: "%.0f%%", player.seasonProjection.premiumPotential * 100))
                                .bold()
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
    }

    private func factorIcon(for impact: FactorImpact) -> String {
        switch impact {
        case .positive: "✅"
        case .negative: "❌"
        case .neutral: "⚪"
        }
    }
}

// MARK: - PerformanceTabView

struct PerformanceTabView: View {
    let player: Player

    var body: some View {
        VStack(spacing: 16) {
            // Seasonal Trend Analysis
            AnalyticsCard(title: "📈 Seasonal Trends") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Early Season Avg:")
                        Spacer()
                        Text(String(format: "%.1f", player.seasonalTrend.earlySeasonAvg))
                            .bold()
                    }

                    HStack {
                        Text("Mid Season Avg:")
                        Spacer()
                        Text(String(format: "%.1f", player.seasonalTrend.midSeasonAvg))
                            .bold()
                    }

                    HStack {
                        Text("Late Season Avg:")
                        Spacer()
                        Text(String(format: "%.1f", player.seasonalTrend.lateSeasonAvg))
                            .bold()
                    }

                    HStack {
                        Text("Trend Direction:")
                        Spacer()
                        Text(trendIcon(for: player.seasonalTrend.trendDirection))
                        Text(player.seasonalTrend.trendDirection.rawValue)
                            .bold()
                            .foregroundColor(trendColor(for: player.seasonalTrend.trendDirection))
                    }

                    HStack {
                        Text("Fade Risk:")
                        Spacer()
                        Text(String(format: "%.0f%%", player.seasonalTrend.fadeRisk * 100))
                            .bold()
                            .foregroundColor(player.seasonalTrend.fadeRisk > 0.5 ? .red : .green)
                    }
                }
            }

            // Venue Performance
            if !player.venuePerformance.isEmpty {
                AnalyticsCard(title: "🏟️ Venue Performance") {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(player.venuePerformance.prefix(3), id: \\.venueName) { venue in
                            HStack {
                                Text(venue.venueName)
                                    .font(.caption)
                                Spacer()
                                Text(String(format: "%.1f", venue.averageScore))
                                    .font(.caption)
                                    .bold()
                                Text("(\\(venue.bias > 0 ? \"+\" : \"\")\\(String(format: \"%.1f\", venue.bias)))")
                                    .font(.caption)
                                    .foregroundColor(venue.bias >= 0 ? .green : .red)
                            }
                        }
                    }
                }
            }

            // Contract Status
            AnalyticsCard(title: "📋 Contract Status") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Contract Year:")
                        Spacer()
                        Text(player.contractStatus.contractYear ? "Yes" : "No")
                            .bold()
                            .foregroundColor(player.contractStatus.contractYear ? .orange : .gray)
                    }

                    HStack {
                        Text("Years Remaining:")
                        Spacer()
                        Text("\\(player.contractStatus.yearsRemaining)")
                            .bold()
                    }

                    if player.contractStatus.contractYear {
                        HStack {
                            Text("Motivation Bonus:")
                            Spacer()
                            Text(String(format: "%.1f%%", player.contractStatus.motivationBonus * 100))
                                .bold()
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
    }

    private func trendIcon(for trend: TrendDirection) -> String {
        switch trend {
        case .improving: "📈"
        case .stable: "➡️"
        case .declining: "📉"
        case .volatile: "⚡"
        }
    }

    private func trendColor(for trend: TrendDirection) -> Color {
        switch trend {
        case .improving: .green
        case .stable: .blue
        case .declining: .red
        case .volatile: .orange
        }
    }
}

// MARK: - RiskAnalysisTabView

struct RiskAnalysisTabView: View {
    let player: Player

    var body: some View {
        VStack(spacing: 16) {
            // Injury Risk Analysis
            AnalyticsCard(title: "🏥 Injury Risk Analysis") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Risk Level:")
                        Spacer()
                        Text(player.injuryRisk.riskLevel.rawValue)
                            .bold()
                            .foregroundColor(player.injuryRisk.riskLevel.color)
                    }

                    HStack {
                        Text("Risk Score:")
                        Spacer()
                        Text(String(format: "%.0f/100", player.injuryRisk.riskScore))
                            .bold()
                            .foregroundColor(riskScoreColor(for: player.injuryRisk.riskScore))
                    }

                    HStack {
                        Text("Reinjury Probability:")
                        Spacer()
                        Text(String(format: "%.0f%%", player.injuryRisk.reinjuryProbability * 100))
                            .bold()
                            .foregroundColor(.orange)
                    }
                }
            }

            // Injury History
            if !player.injuryRisk.injuryHistory.isEmpty {
                AnalyticsCard(title: "📋 Injury History") {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(player.injuryRisk.injuryHistory.prefix(3), id: \\.id) { injury in
                            HStack {
                                Text(injury.injuryType)
                                    .font(.caption)
                                Spacer()
                                Text("\\(injury.season) R\\(injury.round)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("(\\(injury.weeksOut)w)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }

                        if player.injuryRisk.injuryHistory.count > 3 {
                            Text("... and \\(player.injuryRisk.injuryHistory.count - 3) more")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            // Player Status
            AnalyticsCard(title: "🚨 Current Status") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Injured:")
                        Spacer()
                        Text(player.isInjured ? "Yes" : "No")
                            .bold()
                            .foregroundColor(player.isInjured ? .red : .green)
                    }

                    HStack {
                        Text("Doubtful:")
                        Spacer()
                        Text(player.isDoubtful ? "Yes" : "No")
                            .bold()
                            .foregroundColor(player.isDoubtful ? .orange : .green)
                    }

                    HStack {
                        Text("Trade Target:")
                        Spacer()
                        Text(player.isTradeTarget ? "Yes" : "No")
                            .bold()
                            .foregroundColor(player.isTradeTarget ? .orange : .gray)
                    }

                    HStack {
                        Text("Captain Recommended:")
                        Spacer()
                        Text(player.isCaptainRecommended ? "Yes" : "No")
                            .bold()
                            .foregroundColor(player.isCaptainRecommended ? .green : .gray)
                    }
                }
            }
        }
    }

    private func riskScoreColor(for score: Double) -> Color {
        switch score {
        case 0 ..< 25: .green
        case 25 ..< 50: .yellow
        case 50 ..< 75: .orange
        default: .red
        }
    }
}

// MARK: - AnalyticsCard

struct AnalyticsCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            content
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
