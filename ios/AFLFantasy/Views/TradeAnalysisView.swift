//
//  TradeAnalysisView.swift
//  AFL Fantasy Intelligence Platform
//
//  Advanced trade calculator with AI-powered recommendations
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - EnhancedTradeCalculatorView

struct EnhancedTradeCalculatorView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var tradeAnalyzer = TradeAnalyzer()

    @State private var selectedPlayerOut: EnhancedPlayer?
    @State private var selectedPlayerIn: EnhancedPlayer?
    @State private var showingPlayerPicker = false
    @State private var isSelectingPlayerOut = true
    @State private var calculatedTrade: TradeAnalysis?

    // Native iOS Haptic Feedback
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.l.value) {
                    // Header
                    TradeCalculatorHeader()

                    // Current team trades remaining
                    TradeRemainingCard(tradesRemaining: appState.tradesRemaining)

                    // Player selection section
                    VStack(spacing: DesignSystem.Spacing.m.value) {
                        // Trade OUT section
                        PlayerSelectionCard(
                            title: "TRADE OUT",
                            subtitle: "Select player to trade out",
                            player: selectedPlayerOut,
                            color: DesignSystem.Colors.error,
                            action: {
                                isSelectingPlayerOut = true
                                showingPlayerPicker = true
                                selectionFeedback.selectionChanged()
                            }
                        )

                        // Trade direction indicator
                        VStack(spacing: DesignSystem.Spacing.xs.value) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: DesignSystem.IconSize.large.value))
                                .foregroundColor(DesignSystem.Colors.primary)
                                .symbolEffect(.bounce, value: calculatedTrade)

                            if let analysis = calculatedTrade {
                                Text("Trade Impact Score: \(analysis.impactScore)/100")
                                    .typography(.caption1)
                                    .foregroundColor(impactScoreColor(for: analysis.impactScore))
                            }
                        }

                        // Trade IN section
                        PlayerSelectionCard(
                            title: "TRADE IN",
                            subtitle: "Select player to trade in",
                            player: selectedPlayerIn,
                            color: DesignSystem.Colors.success,
                            action: {
                                isSelectingPlayerOut = false
                                showingPlayerPicker = true
                                selectionFeedback.selectionChanged()
                            }
                        )
                    }

                    // Trade analysis section
                    if let tradeOut = selectedPlayerOut,
                       let tradeIn = selectedPlayerIn
                    {
                        TradeAnalysisSection(
                            playerOut: tradeOut,
                            playerIn: tradeIn,
                            analysis: calculatedTrade
                        )
                        .onAppear {
                            calculateTrade(out: tradeOut, in: tradeIn)
                        }
                        .onChange(of: selectedPlayerOut) { _, _ in
                            if let out = selectedPlayerOut, let inPlayer = selectedPlayerIn {
                                calculateTrade(out: out, in: inPlayer)
                            }
                        }
                        .onChange(of: selectedPlayerIn) { _, _ in
                            if let out = selectedPlayerOut, let inPlayer = selectedPlayerIn {
                                calculateTrade(out: out, in: inPlayer)
                            }
                        }
                    }

                    // AI Trade Suggestions
                    if selectedPlayerOut == nil, selectedPlayerIn == nil {
                        AITradeSuggestionsSection()
                    }

                    Spacer(minLength: DesignSystem.Spacing.xl.value)
                }
                .padding(DesignSystem.Spacing.m.value)
            }
            .navigationTitle("🔄 Trade Calculator")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingPlayerPicker) {
                PlayerPickerView(
                    isSelectingOut: isSelectingPlayerOut,
                    selectedPlayerOut: $selectedPlayerOut,
                    selectedPlayerIn: $selectedPlayerIn,
                    myTeamPlayers: appState.players
                )
            }
        }
    }

    private func calculateTrade(out: EnhancedPlayer, in: EnhancedPlayer) {
        Task {
            let analysis = await tradeAnalyzer.analyzeTrade(playerOut: out, playerIn: in)
            await MainActor.run {
                withAnimation(DesignSystem.Motion.tasteful) {
                    calculatedTrade = analysis
                }
            }
        }
    }

    private func impactScoreColor(for score: Int) -> Color {
        switch score {
        case 80...: DesignSystem.Colors.success
        case 60 ..< 80: DesignSystem.Colors.primary
        case 40 ..< 60: DesignSystem.Colors.warning
        default: DesignSystem.Colors.error
        }
    }
}

// MARK: - TradeCalculatorHeader

struct TradeCalculatorHeader: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.s.value) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 50))
                .foregroundColor(DesignSystem.Colors.primary)

            Text("Trade Calculator")
                .typography(.title2)

            Text("AI-powered trade analysis and recommendations")
                .typography(.caption1)
                .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.m.value)
    }
}

// MARK: - TradeRemainingCard

struct TradeRemainingCard: View {
    let tradesRemaining: Int

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.m.value) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs.value) {
                Text("Trades Remaining")
                    .typography(.caption1)
                    .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)

                Text("\(tradesRemaining)")
                    .typography(.largeTitle)
                    .foregroundColor(tradesRemaining > 0 ? DesignSystem.Colors.success : DesignSystem.Colors.error)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs.value) {
                Text("Trade Value")
                    .typography(.caption1)
                    .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)

                Text("$\(tradeValueEstimate)")
                    .typography(.title2)
                    .foregroundColor(DesignSystem.Colors.primary)
            }
        }
        .padding(DesignSystem.Spacing.m.value)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium.value)
                .fill(DesignSystem.Colors.surfaceVariant)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium.value)
                .stroke(
                    tradesRemaining > 0 ? DesignSystem.Colors.success.opacity(0.3) : DesignSystem.Colors.error
                        .opacity(0.3),
                    lineWidth: 1
                )
        )
    }

    private var tradeValueEstimate: Int {
        // Estimate trade value based on remaining trades
        switch tradesRemaining {
        case 8...: 0 // Free trades
        case 4 ..< 8: 4 // Mid-season
        case 1 ..< 4: 8 // Premium trades
        default: 12 // Emergency trades
        }
    }
}

// MARK: - PlayerSelectionCard

struct PlayerSelectionCard: View {
    let title: String
    let subtitle: String
    let player: EnhancedPlayer?
    let color: Color
    let action: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.m.value) {
            HStack {
                Text(title)
                    .typography(.headline)
                    .foregroundColor(color)

                Spacer()

                Button(action: action) {
                    Image(systemName: player == nil ? "plus.circle" : "pencil.circle")
                        .font(.system(size: DesignSystem.IconSize.medium.value))
                        .foregroundColor(color)
                }
                .tappableFrame()
            }

            if let player {
                SelectedPlayerView(player: player, isOut: title.contains("OUT"))
            } else {
                Button(action: action) {
                    VStack(spacing: DesignSystem.Spacing.s.value) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: DesignSystem.IconSize.large.value))
                            .foregroundColor(color.opacity(0.6))

                        Text(subtitle)
                            .typography(.bodySecondary)
                            .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(DesignSystem.Spacing.l.value)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium.value)
                            .stroke(color.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(DesignSystem.Spacing.m.value)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium.value)
                .fill(color.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium.value)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - SelectedPlayerView

struct SelectedPlayerView: View {
    let player: EnhancedPlayer
    let isOut: Bool

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.m.value) {
            // Position indicator
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small.value)
                .fill(player.position.color)
                .frame(width: 4, height: 60)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs.value) {
                Text(player.name)
                    .typography(.bodyPrimary)

                HStack(spacing: DesignSystem.Spacing.s.value) {
                    Text(player.position.rawValue)
                        .typography(.caption2)
                        .padding(.horizontal, DesignSystem.Spacing.xs.value)
                        .padding(.vertical, 2)
                        .background(player.position.color.opacity(0.2))
                        .cornerRadius(DesignSystem.CornerRadius.small.value)

                    Text(player.formattedPrice)
                        .typography(.caption1)
                        .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                }

                // Key metrics
                HStack(spacing: DesignSystem.Spacing.m.value) {
                    MetricView(title: "Score", value: "\(player.currentScore)", color: .primary)
                    MetricView(title: "Avg", value: "\(Int(player.averageScore))", color: .secondary)
                    MetricView(
                        title: "BE",
                        value: "\(player.breakeven)",
                        color: player.breakeven < 50 ? .green : .orange
                    )
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs.value) {
                Text("\(player.currentScore)")
                    .typography(.title3)
                    .foregroundColor(isOut ? DesignSystem.Colors.error : DesignSystem.Colors.success)

                Text("this round")
                    .typography(.caption2)
                    .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
            }
        }
        .padding(DesignSystem.Spacing.m.value)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium.value)
                .fill(DesignSystem.Colors.surface)
        )
    }
}

// MARK: - MetricView

struct MetricView: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .typography(.caption2)
                .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)

            Text(value)
                .typography(.caption1)
                .foregroundColor(color == .primary ? DesignSystem.Colors.primary :
                    color == .secondary ? DesignSystem.Colors.onSurfaceSecondary : color
                )
        }
    }
}

// MARK: - TradeAnalysisSection

struct TradeAnalysisSection: View {
    let playerOut: EnhancedPlayer
    let playerIn: EnhancedPlayer
    let analysis: TradeAnalysis?

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.m.value) {
            // Analysis Header
            HStack {
                Text("Trade Analysis")
                    .typography(.headline)

                Spacer()

                if let analysis {
                    TradeScoreIndicator(score: analysis.impactScore)
                }
            }

            if let analysis {
                VStack(spacing: DesignSystem.Spacing.m.value) {
                    // Financial Impact
                    FinancialImpactView(
                        cashOut: playerOut.price,
                        cashIn: playerIn.price,
                        netCash: analysis.netCashImpact
                    )

                    // Performance Comparison
                    PerformanceComparisonView(
                        playerOut: playerOut,
                        playerIn: playerIn,
                        projectedDifference: analysis.projectedPointsDifference
                    )

                    // Risk Assessment
                    RiskAssessmentView(riskFactors: analysis.riskFactors)

                    // Recommendation
                    TradeRecommendationView(recommendation: analysis.recommendation)
                }
            } else {
                ProgressView("Analyzing trade...")
                    .padding(DesignSystem.Spacing.l.value)
            }
        }
        .padding(DesignSystem.Spacing.m.value)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium.value)
                .fill(DesignSystem.Colors.surfaceVariant)
        )
    }
}

// MARK: - TradeScoreIndicator

struct TradeScoreIndicator: View {
    let score: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(DesignSystem.Colors.onSurface.opacity(0.2), lineWidth: 4)
                .frame(width: 50, height: 50)

            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(scoreColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: score)

            Text("\(score)")
                .typography(.caption1)
                .foregroundColor(scoreColor)
        }
    }

    private var scoreColor: Color {
        switch score {
        case 80...: DesignSystem.Colors.success
        case 60 ..< 80: DesignSystem.Colors.primary
        case 40 ..< 60: DesignSystem.Colors.warning
        default: DesignSystem.Colors.error
        }
    }
}

// MARK: - FinancialImpactView

struct FinancialImpactView: View {
    let cashOut: Int
    let cashIn: Int
    let netCash: Int

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.s.value) {
            Text("Financial Impact")
                .typography(.bodySecondary)

            HStack {
                VStack(alignment: .leading) {
                    Text("Cash From Sale")
                        .typography(.caption2)
                        .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                    Text("+$\(cashOut / 1000)k")
                        .typography(.bodyPrimary)
                        .foregroundColor(DesignSystem.Colors.success)
                }

                Spacer()

                Image(systemName: "minus")
                    .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Purchase Cost")
                        .typography(.caption2)
                        .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                    Text("-$\(cashIn / 1000)k")
                        .typography(.bodyPrimary)
                        .foregroundColor(DesignSystem.Colors.error)
                }
            }

            Divider()

            HStack {
                Text("Net Cash Impact")
                    .typography(.bodySecondary)

                Spacer()

                Text(netCash >= 0 ? "+$\(netCash / 1000)k" : "-$\(abs(netCash) / 1000)k")
                    .typography(.bodyPrimary)
                    .foregroundColor(netCash >= 0 ? DesignSystem.Colors.success : DesignSystem.Colors.error)
            }
        }
        .padding(DesignSystem.Spacing.m.value)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small.value)
                .fill(DesignSystem.Colors.surface)
        )
    }
}

// MARK: - PerformanceComparisonView

struct PerformanceComparisonView: View {
    let playerOut: EnhancedPlayer
    let playerIn: EnhancedPlayer
    let projectedDifference: Double

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.s.value) {
            Text("Performance Comparison (Next 3 Rounds)")
                .typography(.bodySecondary)

            HStack {
                PlayerPerformanceColumn(
                    name: playerOut.name,
                    projected: playerOut.nextRoundProjection.projectedScore,
                    isOut: true
                )

                Spacer()

                VStack(spacing: DesignSystem.Spacing.xs.value) {
                    Text("vs")
                        .typography(.caption2)
                        .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)

                    Text(projectedDifference >= 0 ? "+\(Int(projectedDifference))" : "\(Int(projectedDifference))")
                        .typography(.bodyPrimary)
                        .foregroundColor(projectedDifference >= 0 ? DesignSystem.Colors.success : DesignSystem.Colors
                            .error
                        )

                    Text("pts diff")
                        .typography(.caption2)
                        .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                }

                Spacer()

                PlayerPerformanceColumn(
                    name: playerIn.name,
                    projected: playerIn.nextRoundProjection.projectedScore,
                    isOut: false
                )
            }
        }
        .padding(DesignSystem.Spacing.m.value)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small.value)
                .fill(DesignSystem.Colors.surface)
        )
    }
}

// MARK: - PlayerPerformanceColumn

struct PlayerPerformanceColumn: View {
    let name: String
    let projected: Double
    let isOut: Bool

    var body: some View {
        VStack(alignment: isOut ? .leading : .trailing, spacing: DesignSystem.Spacing.xs.value) {
            Text(name)
                .typography(.caption1)
                .lineLimit(1)

            Text("\(Int(projected))")
                .typography(.title3)
                .foregroundColor(isOut ? DesignSystem.Colors.error : DesignSystem.Colors.success)

            Text("projected")
                .typography(.caption2)
                .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
        }
        .frame(maxWidth: 80)
    }
}

// MARK: - RiskAssessmentView

struct RiskAssessmentView: View {
    let riskFactors: [RiskFactor]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.s.value) {
            Text("Risk Assessment")
                .typography(.bodySecondary)

            ForEach(riskFactors, id: \.type) { factor in
                HStack(spacing: DesignSystem.Spacing.s.value) {
                    Image(systemName: factor.icon)
                        .foregroundColor(factor.severity.color)
                        .frame(width: 16)

                    Text(factor.description)
                        .typography(.caption1)
                        .foregroundColor(DesignSystem.Colors.onSurface)

                    Spacer()

                    Text(factor.severity.rawValue.uppercased())
                        .typography(.caption2)
                        .foregroundColor(factor.severity.color)
                        .padding(.horizontal, DesignSystem.Spacing.xs.value)
                        .padding(.vertical, 2)
                        .background(factor.severity.color.opacity(0.1))
                        .cornerRadius(DesignSystem.CornerRadius.small.value)
                }
            }
        }
        .padding(DesignSystem.Spacing.m.value)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small.value)
                .fill(DesignSystem.Colors.surface)
        )
    }
}

// MARK: - TradeRecommendationView

struct TradeRecommendationView: View {
    let recommendation: TradeRecommendation

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.m.value) {
            Image(systemName: recommendation.icon)
                .font(.system(size: DesignSystem.IconSize.large.value))
                .foregroundColor(recommendation.color)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs.value) {
                Text(recommendation.title)
                    .typography(.bodySecondary)
                    .foregroundColor(recommendation.color)

                Text(recommendation.reasoning)
                    .typography(.caption1)
                    .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
            }

            Spacer()
        }
        .padding(DesignSystem.Spacing.m.value)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small.value)
                .fill(recommendation.color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small.value)
                .stroke(recommendation.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - AITradeSuggestionsSection

struct AITradeSuggestionsSection: View {
    @StateObject private var suggestionEngine = AITradeSuggestionEngine()

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.m.value) {
            Text("AI Trade Suggestions")
                .typography(.headline)

            if suggestionEngine.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Analyzing your team...")
                        .typography(.caption1)
                        .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                }
                .padding(DesignSystem.Spacing.l.value)
            } else {
                ForEach(suggestionEngine.suggestions.prefix(3), id: \.id) { suggestion in
                    AITradeSuggestionCard(suggestion: suggestion)
                }
            }
        }
        .padding(DesignSystem.Spacing.m.value)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium.value)
                .fill(DesignSystem.Colors.surfaceVariant)
        )
        .onAppear {
            suggestionEngine.loadSuggestions()
        }
    }
}

// MARK: - AITradeSuggestionCard

struct AITradeSuggestionCard: View {
    let suggestion: AITradeSuggestion

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.s.value) {
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs.value) {
                    Text(suggestion.title)
                        .typography(.bodySecondary)

                    Text(suggestion.rationale)
                        .typography(.caption1)
                        .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs.value) {
                    Text("+\(suggestion.projectedGain)")
                        .typography(.bodyPrimary)
                        .foregroundColor(DesignSystem.Colors.success)

                    Text("pts/week")
                        .typography(.caption2)
                        .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                }
            }

            HStack(spacing: DesignSystem.Spacing.s.value) {
                Text("OUT:")
                    .typography(.caption2)
                    .foregroundColor(DesignSystem.Colors.error)

                Text(suggestion.playerOut)
                    .typography(.caption1)

                Spacer()

                Text("IN:")
                    .typography(.caption2)
                    .foregroundColor(DesignSystem.Colors.success)

                Text(suggestion.playerIn)
                    .typography(.caption1)
            }
        }
        .padding(DesignSystem.Spacing.m.value)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small.value)
                .fill(DesignSystem.Colors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small.value)
                .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    EnhancedTradeCalculatorView()
        .environmentObject(AppState())
}
