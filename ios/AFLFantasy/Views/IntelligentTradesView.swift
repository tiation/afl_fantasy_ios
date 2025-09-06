//
//  IntelligentTradesView.swift
//  AFL Fantasy Intelligence Platform
//
//  Advanced trade analysis with intelligent scoring and multi-scenario planning
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - IntelligentTradesView

struct IntelligentTradesView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTradeMode: TradeMode = .recommendations
    @State private var selectedPlayerOut: EnhancedPlayer?
    @State private var selectedPlayerIn: EnhancedPlayer?
    @State private var tradeScenarios: [TradeScenario] = []
    @State private var isAnalyzing = false
    @State private var showingPlayerPicker = false
    @State private var pickerMode: PlayerPickerMode = .tradeOut
    @State private var tradeHistory: [CompletedTrade] = []
    @State private var selectedTimeHorizon: TimeHorizon = .nextRound
    @State private var riskTolerance: RiskTolerance = .moderate

    enum TradeMode: String, CaseIterable {
        case recommendations = "AI Picks"
        case calculator = "Calculator"
        case multiTrade = "Multi-Trade"
        case history = "History"
    }

    enum PlayerPickerMode {
        case tradeOut, tradeIn
    }

    enum TimeHorizon: String, CaseIterable {
        case nextRound = "Next Round"
        case next3Rounds = "3 Rounds"
        case restOfSeason = "Season"
        case playoffs = "Finals"
    }

    enum RiskTolerance: String, CaseIterable {
        case conservative = "Conservative"
        case moderate = "Moderate"
        case aggressive = "Aggressive"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Trade capacity header
                    TradeCapacityHeader()

                    // Mode selector
                    TradeModeSelector(selectedMode: $selectedTradeMode)

                    // Analysis settings
                    TradeAnalysisSettings(
                        timeHorizon: $selectedTimeHorizon,
                        riskTolerance: $riskTolerance
                    )

                    // Main content based on selected mode
                    Group {
                        switch selectedTradeMode {
                        case .recommendations:
                            TradeRecommendationsView(
                                scenarios: tradeScenarios,
                                timeHorizon: selectedTimeHorizon,
                                riskTolerance: riskTolerance
                            )
                        case .calculator:
                            EnhancedTradeCalculatorView(
                                playerOut: $selectedPlayerOut,
                                playerIn: $selectedPlayerIn,
                                onPlayerOutTap: { showPlayerPicker(.tradeOut) },
                                onPlayerInTap: { showPlayerPicker(.tradeIn) }
                            )
                        case .multiTrade:
                            MultiTradeView(timeHorizon: selectedTimeHorizon)
                        case .history:
                            TradeHistoryView(trades: tradeHistory)
                        }
                    }

                    // Quick actions section
                    QuickTradeActions()
                }
                .padding()
            }
            .navigationTitle("🔄 Trade Intelligence")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task { await analyzeTradeOpportunities() }
                    }) {
                        Image(systemName: "brain")
                            .rotationEffect(isAnalyzing ? .degrees(360) : .degrees(0))
                            .animation(
                                isAnalyzing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                                value: isAnalyzing
                            )
                    }
                    .disabled(isAnalyzing)

                    Menu {
                        ForEach(TimeHorizon.allCases, id: \.rawValue) { horizon in
                            Button(horizon.rawValue) {
                                selectedTimeHorizon = horizon
                            }
                        }
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
            }
        }
        .sheet(isPresented: $showingPlayerPicker) {
            PlayerPickerView(
                mode: pickerMode == .tradeOut ? .tradeOut : .tradeIn
            ) { player in
                if pickerMode == .tradeOut {
                    selectedPlayerOut = player
                } else {
                    selectedPlayerIn = player
                }
            }
        }
        .onAppear {
            Task {
                await analyzeTradeOpportunities()
                generateMockTradeHistory()
            }
        }
    }

    private func showPlayerPicker(_ mode: PlayerPickerMode) {
        pickerMode = mode
        showingPlayerPicker = true
    }

    private var eligiblePlayers: [EnhancedPlayer] {
        switch pickerMode {
        case .tradeOut:
            appState.players // Your current players
        case .tradeIn:
            // In a real app, this would be all AFL players not in your team
            appState.players.shuffled() // Mock data
        }
    }

    @MainActor
    private func analyzeTradeOpportunities() async {
        isAnalyzing = true
        defer { isAnalyzing = false }

        // Simulate intelligent trade analysis
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        tradeScenarios = await generateTradeScenarios()
    }

    private func generateTradeScenarios() async -> [TradeScenario] {
        let underperformers = appState.players.filter {
            $0.averageScore < Double($0.breakeven) - 3 || $0.injuryRiskScore > 30
        }

        return underperformers.prefix(5).map { playerOut in
            let potentialTargets = appState.players.shuffled().prefix(3)
            let bestTarget = potentialTargets.max { calculateTradeScore(out: playerOut, in: $0) < calculateTradeScore(
                out: playerOut,
                in: $1
            ) }!

            return TradeScenario(
                id: UUID(),
                playerOut: playerOut,
                playerIn: bestTarget,
                tradeScore: calculateTradeScore(out: playerOut, in: bestTarget),
                projectedPointsGain: calculatePointsGain(out: playerOut, in: bestTarget),
                netCost: bestTarget.currentPrice - playerOut.currentPrice,
                confidenceLevel: calculateTradeConfidence(out: playerOut, in: bestTarget),
                timeframe: selectedTimeHorizon,
                risks: identifyTradeRisks(out: playerOut, in: bestTarget),
                benefits: identifyTradeBenefits(out: playerOut, in: bestTarget),
                recommendation: determineRecommendation(out: playerOut, in: bestTarget)
            )
        }
    }

    // MARK: - Trade Analysis Algorithms

    private func calculateTradeScore(out playerOut: EnhancedPlayer, in playerIn: EnhancedPlayer) -> Double {
        var score = 0.0

        // Performance difference (40% weight)
        let performanceDiff = playerIn.averageScore - playerOut.averageScore
        score += performanceDiff * 0.4

        // Value efficiency (20% weight)
        let outValue = playerOut.currentPrice / Int(playerOut.averageScore + 1)
        let inValue = playerIn.currentPrice / Int(playerIn.averageScore + 1)
        let valueImprovement = Double(outValue - inValue) * 0.2
        score += valueImprovement

        // Consistency improvement (15% weight)
        let consistencyImprovement = (playerIn.consistency - playerOut.consistency) * 0.15
        score += consistencyImprovement

        // Injury risk reduction (15% weight)
        let riskReduction = (playerOut.injuryRiskScore - playerIn.injuryRiskScore) * 0.15
        score += riskReduction

        // Future potential (10% weight)
        let futurePotential = calculateFuturePotential(playerIn) - calculateFuturePotential(playerOut)
        score += futurePotential * 0.1

        return max(score, -50) // Floor at -50
    }

    private func calculatePointsGain(out playerOut: EnhancedPlayer, in playerIn: EnhancedPlayer) -> Double {
        let baseGain = playerIn.averageScore - playerOut.averageScore

        // Adjust for fixture difficulty
        let fixtureFactor = 1.0 // Simplified - would analyze upcoming fixtures

        // Adjust for form
        let formFactor = calculateFormFactor(playerIn) - calculateFormFactor(playerOut)

        return (baseGain * fixtureFactor + formFactor) * Double(getRoundsForTimeHorizon())
    }

    private func calculateTradeConfidence(out playerOut: EnhancedPlayer, in playerIn: EnhancedPlayer) -> Double {
        var confidence = 0.7

        // Higher confidence for consistent players
        confidence += (playerIn.consistency - playerOut.consistency) / 200

        // Lower confidence for injury-prone players
        confidence -= playerIn.injuryRiskScore / 200

        // Lower confidence for high-priced players (higher downside risk)
        if playerIn.currentPrice > 800_000 {
            confidence -= 0.1
        }

        return min(max(confidence, 0.2), 0.95)
    }

    private func calculateFuturePotential(_ player: EnhancedPlayer) -> Double {
        var potential = 0.0

        if player.contractYear {
            potential += 5.0 // Contract year motivation
        }

        if player.isCashCow, player.averageScore > Double(player.breakeven + 10) {
            potential += 3.0 // Strong cash cow
        }

        // Age factor (younger players have more upside)
        // This would use real age data in production
        potential += Double.random(in: -2 ... 4)

        return potential
    }

    private func calculateFormFactor(_ player: EnhancedPlayer) -> Double {
        // Simulate recent form analysis
        Double.random(in: -5 ... 8)
    }

    private func getRoundsForTimeHorizon() -> Int {
        switch selectedTimeHorizon {
        case .nextRound: 1
        case .next3Rounds: 3
        case .restOfSeason: 10
        case .playoffs: 4
        }
    }

    private func identifyTradeRisks(out playerOut: EnhancedPlayer, in playerIn: EnhancedPlayer) -> [String] {
        var risks: [String] = []

        if playerIn.injuryRiskScore > 25 {
            risks.append("Target has elevated injury risk")
        }

        if playerIn.currentPrice > 800_000 {
            risks.append("High-priced target with downside risk")
        }

        if playerIn.consistency < 75 {
            risks.append("Target has inconsistent scoring")
        }

        if playerOut.averageScore > 100, playerIn.averageScore < playerOut.averageScore + 10 {
            risks.append("Marginal upgrade for premium player")
        }

        return risks
    }

    private func identifyTradeBenefits(out playerOut: EnhancedPlayer, in playerIn: EnhancedPlayer) -> [String] {
        var benefits: [String] = []

        if playerIn.averageScore > playerOut.averageScore + 10 {
            benefits.append("Significant scoring upgrade")
        }

        if playerIn.consistency > playerOut.consistency + 10 {
            benefits.append("Much more consistent scorer")
        }

        if playerOut.injuryRiskScore > 30, playerIn.injuryRiskScore < 20 {
            benefits.append("Reduces injury risk exposure")
        }

        if playerIn.contractYear {
            benefits.append("Contract year motivation bonus")
        }

        return benefits
    }

    private func determineRecommendation(
        out playerOut: EnhancedPlayer,
        in playerIn: EnhancedPlayer
    ) -> TradeRecommendation {
        let score = calculateTradeScore(out: playerOut, in: playerIn)
        let confidence = calculateTradeConfidence(out: playerOut, in: playerIn)

        if score > 15, confidence > 0.8 {
            return .strongBuy
        } else if score > 8, confidence > 0.7 {
            return .buy
        } else if score > 0 {
            return .consider
        } else if score > -8 {
            return .hold
        } else {
            return .avoid
        }
    }

    private func generateMockTradeHistory() {
        // Generate some mock trade history
        tradeHistory = [
            CompletedTrade(
                id: UUID(),
                playerOut: appState.players.randomElement()!,
                playerIn: appState.players.randomElement()!,
                executedDate: Date().addingTimeInterval(-7 * 24 * 3600),
                netCost: -50000,
                actualPointsGain: 12.5,
                projectedPointsGain: 15.0
            )
        ]
    }
}

// MARK: - TradeScenario

struct TradeScenario: Identifiable {
    let id: UUID
    let playerOut: EnhancedPlayer
    let playerIn: EnhancedPlayer
    let tradeScore: Double
    let projectedPointsGain: Double
    let netCost: Int
    let confidenceLevel: Double
    let timeframe: IntelligentTradesView.TimeHorizon
    let risks: [String]
    let benefits: [String]
    let recommendation: TradeRecommendation

    var formattedNetCost: String {
        let absValue = abs(netCost)
        let prefix = netCost >= 0 ? "+" : "-"
        if absValue >= 1000 {
            return "\(prefix)$\(absValue / 1000)k"
        } else {
            return "\(prefix)$\(absValue)"
        }
    }
}

// MARK: - TradeRecommendation

enum TradeRecommendation: String, CaseIterable {
    case strongBuy = "Strong Buy"
    case buy = "Buy"
    case consider = "Consider"
    case hold = "Hold"
    case avoid = "Avoid"

    var color: Color {
        switch self {
        case .strongBuy: .green
        case .buy: .mint
        case .consider: .blue
        case .hold: .orange
        case .avoid: .red
        }
    }

    var icon: String {
        switch self {
        case .strongBuy: "arrow.up.circle.fill"
        case .buy: "arrow.up.circle"
        case .consider: "questionmark.circle"
        case .hold: "minus.circle"
        case .avoid: "arrow.down.circle.fill"
        }
    }
}

// MARK: - CompletedTrade

struct CompletedTrade: Identifiable {
    let id: UUID
    let playerOut: EnhancedPlayer
    let playerIn: EnhancedPlayer
    let executedDate: Date
    let netCost: Int
    let actualPointsGain: Double
    let projectedPointsGain: Double

    var accuracy: Double {
        guard projectedPointsGain != 0 else { return 0 }
        return (actualPointsGain / projectedPointsGain) * 100
    }
}

// MARK: - TradeCapacityHeader

struct TradeCapacityHeader: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Trade Capacity")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("\(appState.tradesRemaining) trades left")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(tradeColor)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Bank Balance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("$\(appState.bankBalance / 1000)k")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }

            // Trade capacity visualization
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(tradeColor)
                        .frame(width: geometry.size.width * tradeUtilization, height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut(duration: 0.5), value: tradeUtilization)
                }
            }
            .frame(height: 8)

            HStack {
                Text("Used: \(appState.tradesUsed)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("Total: \(appState.tradesUsed + appState.tradesRemaining)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var tradeColor: Color {
        switch appState.tradesRemaining {
        case 6...: .green
        case 3 ..< 6: .blue
        case 1 ..< 3: .orange
        default: .red
        }
    }

    private var tradeUtilization: CGFloat {
        let total = appState.tradesUsed + appState.tradesRemaining
        return total > 0 ? CGFloat(appState.tradesUsed) / CGFloat(total) : 0
    }
}

// MARK: - TradeModeSelector

struct TradeModeSelector: View {
    @Binding var selectedMode: IntelligentTradesView.TradeMode

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(IntelligentTradesView.TradeMode.allCases, id: \.rawValue) { mode in
                    Button(mode.rawValue) {
                        selectedMode = mode
                    }
                    .buttonStyle(TradeModeButtonStyle(isSelected: selectedMode == mode))
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - TradeModeButtonStyle

struct TradeModeButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.orange : Color(.systemGray5))
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - TradeAnalysisSettings

struct TradeAnalysisSettings: View {
    @Binding var timeHorizon: IntelligentTradesView.TimeHorizon
    @Binding var riskTolerance: IntelligentTradesView.RiskTolerance

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Analysis Settings")
                    .font(.headline)
                    .fontWeight(.medium)

                Spacer()
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Time Horizon")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Picker("Time Horizon", selection: $timeHorizon) {
                        ForEach(IntelligentTradesView.TimeHorizon.allCases, id: \.rawValue) { horizon in
                            Text(horizon.rawValue).tag(horizon)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.subheadline)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Risk Profile")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Picker("Risk Tolerance", selection: $riskTolerance) {
                        ForEach(IntelligentTradesView.RiskTolerance.allCases, id: \.rawValue) { risk in
                            Text(risk.rawValue).tag(risk)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - TradeRecommendationsView

struct TradeRecommendationsView: View {
    let scenarios: [TradeScenario]
    let timeHorizon: IntelligentTradesView.TimeHorizon
    let riskTolerance: IntelligentTradesView.RiskTolerance

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI Trade Recommendations")
                .font(.headline)
                .fontWeight(.semibold)

            if scenarios.isEmpty {
                EmptyRecommendationsView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredScenarios.prefix(5), id: \.id) { scenario in
                        TradeScenarioCard(scenario: scenario)
                    }
                }
            }
        }
    }

    private var filteredScenarios: [TradeScenario] {
        scenarios.filter { scenario in
            switch riskTolerance {
            case .conservative:
                scenario.confidenceLevel > 0.8 && scenario.risks.count <= 1
            case .moderate:
                scenario.confidenceLevel > 0.6
            case .aggressive:
                true
            }
        }.sorted { $0.tradeScore > $1.tradeScore }
    }
}

// MARK: - TradeScenarioCard

struct TradeScenarioCard: View {
    let scenario: TradeScenario
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("OUT:")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text(scenario.playerOut.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    HStack {
                        Text("IN:")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text(scenario.playerIn.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    TradeRecommendationBadge(recommendation: scenario.recommendation)

                    Text(String(format: "%.1f", scenario.tradeScore))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)

                    Text("Trade Score")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Key metrics
            HStack(spacing: 16) {
                MetricPill(
                    title: "Points Gain",
                    value: String(format: "%.1f", scenario.projectedPointsGain),
                    color: scenario.projectedPointsGain > 0 ? .green : .red
                )

                MetricPill(
                    title: "Net Cost",
                    value: scenario.formattedNetCost,
                    color: scenario.netCost <= 0 ? .green : .orange
                )

                MetricPill(
                    title: "Confidence",
                    value: String(format: "%.0f%%", scenario.confidenceLevel * 100),
                    color: confidenceColor
                )
            }

            // Expand button
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text(isExpanded ? "Show Less" : "Show Analysis")
                        .font(.caption)
                        .foregroundColor(.orange)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Player comparison
                    PlayerComparisonRow(
                        playerOut: scenario.playerOut,
                        playerIn: scenario.playerIn
                    )

                    // Benefits and risks
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Benefits")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.green)

                            ForEach(scenario.benefits, id: \.self) { benefit in
                                Text("• " + benefit)
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Risks")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.red)

                            ForEach(scenario.risks, id: \.self) { risk in
                                Text("• " + risk)
                                    .font(.caption2)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var confidenceColor: Color {
        switch scenario.confidenceLevel {
        case 0.8...: .green
        case 0.6 ..< 0.8: .blue
        default: .orange
        }
    }
}

// MARK: - TradeRecommendationBadge

struct TradeRecommendationBadge: View {
    let recommendation: TradeRecommendation

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: recommendation.icon)
                .font(.caption2)
                .foregroundColor(recommendation.color)

            Text(recommendation.rawValue)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(recommendation.color)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(recommendation.color.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - MetricPill

struct MetricPill: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)

            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - PlayerComparisonRow

struct PlayerComparisonRow: View {
    let playerOut: EnhancedPlayer
    let playerIn: EnhancedPlayer

    var body: some View {
        VStack(spacing: 8) {
            Text("Player Comparison")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            HStack {
                // Player Out
                VStack(alignment: .leading, spacing: 4) {
                    Text(playerOut.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.red)

                    Text("Avg: \(Int(playerOut.averageScore))")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text("BE: \(playerOut.breakeven)")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text(playerOut.formattedPrice)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                // Player In
                VStack(alignment: .trailing, spacing: 4) {
                    Text(playerIn.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)

                    Text("Avg: \(Int(playerIn.averageScore))")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text("BE: \(playerIn.breakeven)")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text(playerIn.formattedPrice)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - EmptyRecommendationsView

struct EmptyRecommendationsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("Team Looking Good!")
                .font(.headline)
                .foregroundColor(.primary)

            Text("No urgent trade recommendations at this time. Your team is well-balanced.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - TradeCalculatorView

struct TradeCalculatorView: View {
    @Binding var playerOut: EnhancedPlayer?
    @Binding var playerIn: EnhancedPlayer?
    let onPlayerOutTap: () -> Void
    let onPlayerInTap: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Trade Calculator")
                .font(.headline)
                .fontWeight(.semibold)

            // Player selection interface would go here
            VStack(spacing: 12) {
                Button("Select Player to Trade Out") {
                    onPlayerOutTap()
                }
                .buttonStyle(.bordered)

                Button("Select Player to Trade In") {
                    onPlayerInTap()
                }
                .buttonStyle(.bordered)
            }

            if let out = playerOut, let inPlayer = playerIn {
                Text("Calculating trade: \(out.name) → \(inPlayer.name)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - MultiTradeView

struct MultiTradeView: View {
    let timeHorizon: IntelligentTradesView.TimeHorizon

    var body: some View {
        VStack {
            Text("Multi-Trade Planner")
                .font(.headline)
            Text("Plan optimal trade sequences over multiple rounds")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - TradeHistoryView

struct TradeHistoryView: View {
    let trades: [CompletedTrade]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trade History")
                .font(.headline)
                .fontWeight(.semibold)

            if trades.isEmpty {
                Text("No trades completed yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(trades, id: \.id) { trade in
                    TradeHistoryRow(trade: trade)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - TradeHistoryRow

struct TradeHistoryRow: View {
    let trade: CompletedTrade

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(trade.playerOut.name) → \(trade.playerIn.name)")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(trade.executedDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f pts", trade.actualPointsGain))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(trade.actualPointsGain > 0 ? .green : .red)

                Text("\(Int(trade.accuracy))% accuracy")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

// MARK: - QuickTradeActions

struct QuickTradeActions: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                QuickActionButton(
                    title: "Injury Trades",
                    subtitle: "Replace injured players",
                    icon: "cross.circle.fill",
                    color: .red
                ) {}

                QuickActionButton(
                    title: "Value Trades",
                    subtitle: "Best value upgrades",
                    icon: "star.circle.fill",
                    color: .green
                ) {}

                QuickActionButton(
                    title: "Cash Cows",
                    subtitle: "Rookie to premium",
                    icon: "dollarsign.circle.fill",
                    color: .mint
                ) {}

                QuickActionButton(
                    title: "Corrections",
                    subtitle: "Fix poor selections",
                    icon: "arrow.uturn.left.circle.fill",
                    color: .orange
                ) {}
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - QuickActionButton

struct QuickActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                VStack(spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding()
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - PlayerPickerSheet

struct PlayerPickerSheet: View {
    let players: [EnhancedPlayer]
    let mode: IntelligentTradesView.PlayerPickerMode
    let onSelection: (EnhancedPlayer) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List(players, id: \.id) { player in
                Button(action: { onSelection(player) }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(player.name)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Text("\(player.teamAbbreviation) • \(player.position.shortName)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(Int(player.averageScore))")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text(player.formattedPrice)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle(mode == .tradeOut ? "Trade Out" : "Trade In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    IntelligentTradesView()
        .environmentObject(AppState())
}
