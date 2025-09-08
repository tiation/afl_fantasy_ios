//
//  ComprehensiveDashboardView.swift
//  AFL Fantasy Intelligence Platform
//
//  Complex functional dashboard with advanced analytics and insights
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - ComprehensiveDashboardView

struct ComprehensiveDashboardView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTimeFrame: TimeFrame = .current
    @State private var showingPlayerDetail: EnhancedPlayer?
    @State private var selectedInsight: InsightType = .performance
    @State private var isRefreshing = false

    enum TimeFrame: String, CaseIterable {
        case current = "This Round"
        case last3 = "Last 3 Rounds"
        case season = "Season"
        case projected = "Projected"
    }

    enum InsightType: String, CaseIterable {
        case performance = "Performance"
        case trades = "Trades"
        case injuries = "Injuries"
        case value = "Value"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header with key team metrics
                    TeamPerformanceHeader()

                    // Time frame selector
                    TimeFrameSelector(selectedTimeFrame: $selectedTimeFrame)

                    // Dynamic insights section
                    DynamicInsightsSection(
                        selectedInsight: $selectedInsight,
                        timeFrame: selectedTimeFrame
                    )

                    // Advanced team composition analysis
                    TeamCompositionAnalysis()

                    // Player performance matrix
                    PlayerPerformanceMatrix(
                        timeFrame: selectedTimeFrame,
                        onPlayerTap: { player in
                            showingPlayerDetail = player
                        }
                    )

                    // Trade opportunities section
                    TradeOpportunitiesSection()

                    // Risk management alerts
                    RiskManagementSection()
                }
                .padding()
            }
            .navigationTitle("🏆 Team Intelligence")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task { await refreshData() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(isRefreshing ? .degrees(360) : .degrees(0))
                            .animation(
                                isRefreshing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                                value: isRefreshing
                            )
                    }
                    .disabled(isRefreshing)

                    Menu {
                        ForEach(InsightType.allCases, id: \.rawValue) { insight in
                            Button(insight.rawValue) {
                                selectedInsight = insight
                            }
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
        .sheet(item: $showingPlayerDetail) { player in
            PlayerDetailView(player: player)
        }
    }

    @MainActor
    private func refreshData() async {
        isRefreshing = true
        await appState.refreshData()
        try? await Task.sleep(nanoseconds: 500_000_000) // Small delay for smooth animation
        isRefreshing = false
    }
}

// MARK: - TeamPerformanceHeader

struct TeamPerformanceHeader: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 16) {
            // Primary metrics row
            HStack(spacing: 20) {
                MetricCard(
                    title: "Team Score",
                    value: "\(appState.teamScore)",
                    change: calculateScoreChange(),
                    changeType: .points,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )

                MetricCard(
                    title: "Overall Rank",
                    value: "#\(formatRank(appState.teamRank))",
                    change: calculateRankChange(),
                    changeType: .rank,
                    icon: "trophy.fill",
                    color: rankColor()
                )
            }

            // Secondary metrics row
            HStack(spacing: 20) {
                MetricCard(
                    title: "Team Value",
                    value: formatCurrency(appState.teamValue),
                    change: calculateValueChange(),
                    changeType: .currency,
                    icon: "dollarsign.circle.fill",
                    color: .blue
                )

                MetricCard(
                    title: "Bank Balance",
                    value: formatCurrency(appState.bankBalance),
                    change: nil,
                    changeType: .currency,
                    icon: "banknote.fill",
                    color: bankBalanceColor()
                )
            }

            // Performance indicator
            PerformanceIndicator()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private func calculateScoreChange() -> Double {
        // Mock calculation - in real app would compare to previous round
        Double.random(in: -50 ... 100)
    }

    private func calculateRankChange() -> Double {
        // Mock calculation - negative means rank improved
        Double.random(in: -1000 ... 500)
    }

    private func calculateValueChange() -> Double {
        Double(appState.players.reduce(0) { $0 + $1.priceChange })
    }

    private func rankColor() -> Color {
        switch appState.teamRank {
        case 1 ... 5000: .green
        case 5001 ... 15000: .blue
        case 15001 ... 50000: .orange
        default: .red
        }
    }

    private func bankBalanceColor() -> Color {
        appState.bankBalance > 200_000 ? .green : appState.bankBalance > 100_000 ? .orange : .red
    }

    private func formatRank(_ rank: Int) -> String {
        if rank < 1000 { return "\(rank)" }
        return "\(Double(rank) / 1000, specifier: "%.1f")k"
    }

    private func formatCurrency(_ amount: Int) -> String {
        if amount >= 1_000_000 {
            "$\(Double(amount) / 1_000_000, specifier: "%.1f")M"
        } else {
            "$\(amount / 1000)k"
        }
    }
}

// MARK: - MetricCard

struct MetricCard: View {
    let title: String
    let value: String
    let change: Double?
    let changeType: ChangeType
    let icon: String
    let color: Color

    enum ChangeType {
        case points, rank, currency
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Spacer()

                if let change {
                    ChangeIndicator(change: change, type: changeType)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - ChangeIndicator

struct ChangeIndicator: View {
    let change: Double
    let type: MetricCard.ChangeType

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: changeIcon)
                .font(.caption)
                .foregroundColor(changeColor)

            Text(formattedChange)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(changeColor)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(changeColor.opacity(0.1))
        .cornerRadius(4)
    }

    private var changeIcon: String {
        if type == .rank {
            change < 0 ? "arrow.up" : "arrow.down"
        } else {
            change > 0 ? "arrow.up" : "arrow.down"
        }
    }

    private var changeColor: Color {
        if type == .rank {
            change < 0 ? .green : .red // Negative rank change is good (rank improved)
        } else {
            change > 0 ? .green : .red
        }
    }

    private var formattedChange: String {
        let absChange = abs(change)
        switch type {
        case .points:
            return "\(Int(absChange))"
        case .rank:
            return absChange >= 1000 ? "\(Int(absChange / 1000))k" : "\(Int(absChange))"
        case .currency:
            return absChange >= 1000 ? "\(Int(absChange / 1000))k" : "\(Int(absChange))"
        }
    }
}

// MARK: - PerformanceIndicator

struct PerformanceIndicator: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Team Performance")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(performanceDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 12) {
                PerformanceBar(value: performanceScore, color: performanceColor, label: "Overall")
                PerformanceBar(value: consistencyScore, color: .blue, label: "Consistency")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }

    private var performanceScore: Double {
        let avgScore = appState.players.isEmpty ? 0 : appState.players
            .reduce(0) { $0 + $1.averageScore } / Double(appState.players.count)
        return min(avgScore / 120.0, 1.0) // Normalize to 0-1 scale
    }

    private var consistencyScore: Double {
        let avgConsistency = appState.players.isEmpty ? 0 : appState.players
            .reduce(0) { $0 + $1.consistency } / Double(appState.players.count)
        return avgConsistency / 100.0
    }

    private var performanceColor: Color {
        switch performanceScore {
        case 0.8...: .green
        case 0.6 ..< 0.8: .blue
        case 0.4 ..< 0.6: .orange
        default: .red
        }
    }

    private var performanceDescription: String {
        switch performanceScore {
        case 0.8...: "Excellent team performance"
        case 0.6 ..< 0.8: "Strong team performance"
        case 0.4 ..< 0.6: "Average team performance"
        default: "Room for improvement"
        }
    }
}

// MARK: - PerformanceBar

struct PerformanceBar: View {
    let value: Double
    let color: Color
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)

            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 3)

                Circle()
                    .trim(from: 0, to: CGFloat(value))
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: value)
            }
            .frame(width: 40, height: 40)

            Text("\(Int(value * 100))%")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

// MARK: - TimeFrameSelector

struct TimeFrameSelector: View {
    @Binding var selectedTimeFrame: ComprehensiveDashboardView.TimeFrame

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ComprehensiveDashboardView.TimeFrame.allCases, id: \.rawValue) { timeFrame in
                    Button(timeFrame.rawValue) {
                        selectedTimeFrame = timeFrame
                    }
                    .buttonStyle(TimeFrameButtonStyle(isSelected: selectedTimeFrame == timeFrame))
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - TimeFrameButtonStyle

struct TimeFrameButtonStyle: ButtonStyle {
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

// MARK: - DynamicInsightsSection

struct DynamicInsightsSection: View {
    @Binding var selectedInsight: ComprehensiveDashboardView.InsightType
    let timeFrame: ComprehensiveDashboardView.TimeFrame
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Intelligence Insights")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Picker("Insight Type", selection: $selectedInsight) {
                    ForEach(ComprehensiveDashboardView.InsightType.allCases, id: \.rawValue) { insight in
                        Text(insight.rawValue).tag(insight)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            switch selectedInsight {
            case .performance:
                PerformanceInsights(timeFrame: timeFrame)
            case .trades:
                TradeInsights(timeFrame: timeFrame)
            case .injuries:
                InjuryInsights(timeFrame: timeFrame)
            case .value:
                ValueInsights(timeFrame: timeFrame)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - PerformanceInsights

struct PerformanceInsights: View {
    let timeFrame: ComprehensiveDashboardView.TimeFrame
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                InsightCard(
                    title: "Top Performer",
                    value: topPerformer?.name ?? "None",
                    subtitle: topPerformer != nil ? "\(Int(topPerformer!.averageScore)) avg" : "",
                    icon: "star.fill",
                    color: .green
                )

                InsightCard(
                    title: "Most Consistent",
                    value: mostConsistent?.name ?? "None",
                    subtitle: mostConsistent != nil ? "\(Int(mostConsistent!.consistency))% reliability" : "",
                    icon: "target",
                    color: .blue
                )

                InsightCard(
                    title: "Biggest Riser",
                    value: biggestRiser?.name ?? "None",
                    subtitle: biggestRiser != nil ? "+\(biggestRiser!.priceChange / 1000)k price" : "",
                    icon: "arrow.up.circle.fill",
                    color: .mint
                )

                InsightCard(
                    title: "Underperformer",
                    value: underperformer?.name ?? "None",
                    subtitle: underperformer != nil ?
                        "\(underperformer!.breakeven - Int(underperformer!.averageScore)) below BE" : "",
                    icon: "arrow.down.circle.fill",
                    color: .orange
                )
            }
        }
    }

    private var topPerformer: EnhancedPlayer? {
        appState.players.max(by: { $0.averageScore < $1.averageScore })
    }

    private var mostConsistent: EnhancedPlayer? {
        appState.players.max(by: { $0.consistency < $1.consistency })
    }

    private var biggestRiser: EnhancedPlayer? {
        appState.players.filter { $0.priceChange > 0 }.max(by: { $0.priceChange < $1.priceChange })
    }

    private var underperformer: EnhancedPlayer? {
        appState.players.filter { $0.averageScore < Double($0.breakeven) }.first
    }
}

// MARK: - TradeInsights

struct TradeInsights: View {
    let timeFrame: ComprehensiveDashboardView.TimeFrame
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Trades Available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("\(appState.tradesRemaining)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(appState.tradesRemaining > 5 ? .green : .orange)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Trade Value")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("\(formatCurrency(potentialTradeValue))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }

            TradeOpportunityList()
        }
    }

    private var potentialTradeValue: Int {
        // Calculate potential value from trading underperforming players
        appState.players.filter { $0.averageScore < Double($0.breakeven - 10) }
            .reduce(0) { $0 + ($1.priceChange < 0 ? abs($1.priceChange) : 0) }
    }

    private func formatCurrency(_ amount: Int) -> String {
        if amount >= 1000 {
            "$\(amount / 1000)k"
        } else {
            "$\(amount)"
        }
    }
}

// MARK: - TradeOpportunityList

struct TradeOpportunityList: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trade Opportunities")
                .font(.subheadline)
                .fontWeight(.medium)

            ForEach(tradeTargets.prefix(3), id: \.id) { player in
                TradeOpportunityRow(player: player)
            }
        }
    }

    private var tradeTargets: [EnhancedPlayer] {
        appState.players
            .filter { $0.averageScore < Double($0.breakeven) - 5 || $0.injuryRiskScore > 35 }
            .sorted { $0.averageScore - Double($0.breakeven) < $1.averageScore - Double($1.breakeven) }
    }
}

// MARK: - TradeOpportunityRow

struct TradeOpportunityRow: View {
    let player: EnhancedPlayer

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text("BE: \(player.breakeven) | Avg: \(Int(player.averageScore))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(tradeRecommendation)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(recommendationColor)

                Text(player.formattedPrice)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }

    private var tradeRecommendation: String {
        let diff = player.averageScore - Double(player.breakeven)
        if diff < -10 {
            return "SELL"
        } else if player.injuryRiskScore > 35 {
            return "RISK"
        } else {
            return "HOLD"
        }
    }

    private var recommendationColor: Color {
        switch tradeRecommendation {
        case "SELL": .red
        case "RISK": .orange
        default: .blue
        }
    }
}

// MARK: - TeamCompositionAnalysis

struct TeamCompositionAnalysis: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Team Composition")
                .font(.headline)
                .fontWeight(.semibold)

            // Position breakdown
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(
                    [Position.defender, Position.midfielder, Position.ruck, Position.forward],
                    id: \.rawValue
                ) { position in
                    PositionCard(position: position, players: playersInPosition(position))
                }
            }

            // Salary cap utilization
            SalaryCapVisualization()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private func playersInPosition(_ position: Position) -> [EnhancedPlayer] {
        appState.players.filter { $0.position == position }
    }
}

// MARK: - PositionCard

struct PositionCard: View {
    let position: Position
    let players: [EnhancedPlayer]

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(position.shortName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(position.color)

                Spacer()

                Text("\(players.count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Avg Score:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(Int(averageScore))")
                        .font(.caption)
                        .fontWeight(.medium)
                }

                HStack {
                    Text("Total Value:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("$\(totalValue / 1000)k")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(position.color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(position.color.opacity(0.3), lineWidth: 1)
        )
    }

    private var averageScore: Double {
        players.isEmpty ? 0 : players.reduce(0) { $0 + $1.averageScore } / Double(players.count)
    }

    private var totalValue: Int {
        players.reduce(0) { $0 + $1.currentPrice }
    }
}

// MARK: - SalaryCapVisualization

struct SalaryCapVisualization: View {
    @EnvironmentObject var appState: AppState

    private let totalCap = 15_000_000 // Standard AFL Fantasy salary cap

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Salary Cap Utilization")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(Int(utilizationPercentage))% Used")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(utilizationColor)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(utilizationColor)
                        .frame(width: geometry.size.width * CGFloat(utilizationPercentage / 100), height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut(duration: 0.8), value: utilizationPercentage)
                }
            }
            .frame(height: 8)

            HStack {
                Text("Used: \(formatCurrency(appState.teamValue))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("Remaining: \(formatCurrency(totalCap - appState.teamValue))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }

    private var utilizationPercentage: Double {
        Double(appState.teamValue) / Double(totalCap) * 100
    }

    private var utilizationColor: Color {
        switch utilizationPercentage {
        case 95...: .red
        case 90 ..< 95: .orange
        case 80 ..< 90: .green
        default: .blue
        }
    }

    private func formatCurrency(_ amount: Int) -> String {
        if amount >= 1_000_000 {
            "$\(Double(amount) / 1_000_000, specifier: "%.1f")M"
        } else {
            "$\(amount / 1000)k"
        }
    }
}

// MARK: - PlayerPerformanceMatrix

struct PlayerPerformanceMatrix: View {
    let timeFrame: ComprehensiveDashboardView.TimeFrame
    let onPlayerTap: (EnhancedPlayer) -> Void
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Player Performance Matrix")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(appState.players.count) Players")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            LazyVStack(spacing: 8) {
                ForEach(sortedPlayers, id: \.id) { player in
                    PlayerPerformanceRow(
                        player: player,
                        timeFrame: timeFrame,
                        onTap: { onPlayerTap(player) }
                    )
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var sortedPlayers: [EnhancedPlayer] {
        appState.players.sorted { $0.averageScore > $1.averageScore }
    }
}

// MARK: - PlayerPerformanceRow

struct PlayerPerformanceRow: View {
    let player: EnhancedPlayer
    let timeFrame: ComprehensiveDashboardView.TimeFrame
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Position indicator
                Text(player.position.shortName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 20)
                    .background(player.position.color)
                    .cornerRadius(4)

                // Player info
                VStack(alignment: .leading, spacing: 2) {
                    Text(player.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text("\(player.teamAbbreviation) • \(player.formattedPrice)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Performance metrics
                HStack(spacing: 16) {
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("\(Int(player.averageScore))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Text("avg")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .trailing, spacing: 1) {
                        Text("\(player.breakeven)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(breakevenColor)

                        Text("BE")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    // Status indicators
                    VStack(spacing: 2) {
                        if player.isDoubtful {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }

                        if player.isCashCow {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }

                        if player.injuryRiskScore > 30 {
                            Image(systemName: "cross.circle.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var breakevenColor: Color {
        let diff = player.averageScore - Double(player.breakeven)
        if diff > 10 { return .green }
        if diff > 0 { return .blue }
        if diff > -10 { return .orange }
        return .red
    }
}

// MARK: - InsightCard

struct InsightCard: View {
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
                    .font(.title3)

                Spacer()
            }

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(color)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - InjuryInsights

// Additional insight views (InjuryInsights, ValueInsights, etc.) would follow similar patterns...

struct InjuryInsights: View {
    let timeFrame: ComprehensiveDashboardView.TimeFrame
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Injury Risk Analysis")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(highRiskCount) high risk")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            ForEach(highRiskPlayers.prefix(3), id: \.id) { player in
                InjuryRiskRow(player: player)
            }
        }
    }

    private var highRiskPlayers: [EnhancedPlayer] {
        appState.players.filter { $0.injuryRiskScore > 25 }.sorted { $0.injuryRiskScore > $1.injuryRiskScore }
    }

    private var highRiskCount: Int {
        appState.players.filter { $0.injuryRiskScore > 35 }.count
    }
}

// MARK: - InjuryRiskRow

struct InjuryRiskRow: View {
    let player: EnhancedPlayer

    var body: some View {
        HStack {
            Text(player.name)
                .font(.caption)
                .lineLimit(1)

            Spacer()

            Text(player.injuryRiskLevel)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(player.injuryRiskColor)
                .cornerRadius(4)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
}

// MARK: - ValueInsights

struct ValueInsights: View {
    let timeFrame: ComprehensiveDashboardView.TimeFrame
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                InsightCard(
                    title: "Best Value",
                    value: bestValue?.name ?? "None",
                    subtitle: bestValue != nil ? "$\(Int(bestValue!.currentPrice / 1000))k" : "",
                    icon: "star.circle.fill",
                    color: .green
                )

                InsightCard(
                    title: "Overpriced",
                    value: overpriced?.name ?? "None",
                    subtitle: overpriced != nil ? "Poor value" : "",
                    icon: "exclamationmark.circle.fill",
                    color: .red
                )
            }
        }
    }

    private var bestValue: EnhancedPlayer? {
        appState.players
            .filter { $0.averageScore > 80 }
            .min { ($0.currentPrice / Int($0.averageScore)) < ($1.currentPrice / Int($1.averageScore)) }
    }

    private var overpriced: EnhancedPlayer? {
        appState.players
            .filter { $0.currentPrice > 600_000 && $0.averageScore < 90 }
            .first
    }
}

// MARK: - TradeOpportunitiesSection

struct TradeOpportunitiesSection: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trade Opportunities")
                .font(.headline)
                .fontWeight(.semibold)

            Text("Intelligent trade suggestions based on performance, value, and risk analysis")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - RiskManagementSection

struct RiskManagementSection: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Risk Management")
                .font(.headline)
                .fontWeight(.semibold)

            Text("Monitor player injury risks, breakeven cliffs, and price volatility")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

#Preview {
    ComprehensiveDashboardView()
        .environmentObject(AppState())
}
