//
//  AdvancedCashCowTracker.swift
//  AFL Fantasy Intelligence Platform
//
//  Advanced cash cow management with predictive analytics and optimal timing
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - AdvancedCashCowTracker

struct AdvancedCashCowTracker: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedView: CashCowView = .recommendations
    @State private var selectedTimeframe: CashTimeframe = .optimal
    @State private var cashAnalysis: [CashCowAnalysis] = []
    @State private var isAnalyzing = false
    @State private var totalCashGenerated: Int = 0
    @State private var showingDetailedAnalysis: CashCowAnalysis?
    @State private var sellSignals: [SellSignal] = []
    @State private var priceProjections: [PriceProjection] = []

    enum CashCowView: String, CaseIterable {
        case recommendations = "AI Picks"
        case tracker = "Tracker"
        case projections = "Projections"
        case history = "History"
    }

    enum CashTimeframe: String, CaseIterable {
        case immediate = "Now"
        case week2 = "2 Weeks"
        case week4 = "4 Weeks"
        case optimal = "Optimal"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Cash generation summary
                    CashGenerationSummary(
                        totalGenerated: totalCashGenerated,
                        bankBalance: appState.bankBalance,
                        activeCount: activeCashCows.count
                    )

                    // View selector
                    CashCowViewSelector(selectedView: $selectedView)

                    // Timeframe settings
                    TimeframeSelector(
                        selectedTimeframe: $selectedTimeframe,
                        onSelectionChanged: { Task { await analyzeCashCows() } }
                    )

                    // Main content based on selected view
                    Group {
                        switch selectedView {
                        case .recommendations:
                            CashCowRecommendationsView(
                                analysis: cashAnalysis,
                                timeframe: selectedTimeframe
                            )
                        case .tracker:
                            CashCowTrackerView(
                                cashCows: activeCashCows,
                                sellSignals: sellSignals
                            )
                        case .projections:
                            PriceProjectionsView(
                                projections: priceProjections,
                                timeframe: selectedTimeframe
                            )
                        case .history:
                            CashGenerationHistoryView()
                        }
                    }

                    // Market intelligence section
                    MarketIntelligenceSection()
                }
                .padding()
            }
            .navigationTitle("💰 Cash Intelligence")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task { await analyzeCashCows() }
                    }) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .rotationEffect(isAnalyzing ? .degrees(360) : .degrees(0))
                            .animation(
                                isAnalyzing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                                value: isAnalyzing
                            )
                    }
                    .disabled(isAnalyzing)

                    Menu {
                        ForEach(CashTimeframe.allCases, id: \.rawValue) { timeframe in
                            Button(timeframe.rawValue) {
                                selectedTimeframe = timeframe
                                Task { await analyzeCashCows() }
                            }
                        }
                    } label: {
                        Image(systemName: "clock")
                    }
                }
            }
        }
        .sheet(item: $showingDetailedAnalysis) { analysis in
            DetailedCashCowAnalysisView(analysis: analysis)
        }
        .onAppear {
            Task { await analyzeCashCows() }
        }
    }

    private var activeCashCows: [EnhancedPlayer] {
        appState.players
            .filter { $0.isCashCow || ($0.price < 600_000 && $0.averageScore > Double($0.breakeven + 5)) }
    }

    @MainActor
    private func analyzeCashCows() async {
        isAnalyzing = true
        defer { isAnalyzing = false }

        // Simulate advanced cash cow analysis
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        cashAnalysis = await performCashCowAnalysis()
        sellSignals = generateSellSignals()
        priceProjections = generatePriceProjections()
        calculateTotalCashGenerated()
    }

    private func performCashCowAnalysis() async -> [CashCowAnalysis] {
        activeCashCows.map { player in
            CashCowAnalysis(
                player: player,
                cashGenerated: calculateCashGenerated(player),
                projectedCash: calculateProjectedCash(player),
                sellRecommendation: determineSellTiming(player),
                confidenceLevel: calculateSellConfidence(player),
                optimalSellWeek: calculateOptimalSellWeek(player),
                priceTrajectory: generatePriceTrajectory(player),
                riskFactors: identifyRiskFactors(player),
                opportunities: identifyOpportunities(player)
            )
        }
        .sorted { $0.projectedCash > $1.projectedCash }
    }

    // MARK: - Analysis Algorithms

    private func calculateCashGenerated(_ player: EnhancedPlayer) -> Int {
        player.cashGenerated > 0 ? player.cashGenerated : max(0, player.priceChange)
    }

    private func calculateProjectedCash(_ player: EnhancedPlayer) -> Int {
        let weeksToOptimal = calculateOptimalSellWeek(player)
        let weeklyIncrease = calculateWeeklyPriceIncrease(player)
        return calculateCashGenerated(player) + (weeklyIncrease * weeksToOptimal)
    }

    private func determineSellTiming(_ player: EnhancedPlayer) -> SellTiming {
        let performanceVsBreakeven = player.averageScore - Double(player.breakeven)
        let injuryRisk = Double(player.injuryRisk.riskScore)
        let consistency = player.consistency

        // Multiple factors determine timing
        if performanceVsBreakeven > 15, injuryRisk < 20, consistency > 80 {
            return .hold // Strong performer, keep longer
        } else if performanceVsBreakeven > 8, injuryRisk < 30 {
            return .sellSoon // Good cash generation, but sell before risk increases
        } else if performanceVsBreakeven > 0 {
            return .sellNow // At breakeven, sell immediately
        } else {
            return .emergency // Below breakeven, emergency sell
        }
    }

    private func calculateSellConfidence(_ player: EnhancedPlayer) -> Double {
        var confidence = 0.7

        // Higher confidence for consistent cash generation
        if player.averageScore > Double(player.breakeven + 10) {
            confidence += 0.2
        }

        // Lower confidence for injury-prone players
        confidence -= Double(player.injuryRisk.riskScore) / 200

        // Higher confidence for historically strong cash generators
        if player.cashGenerated > 80000 {
            confidence += 0.1
        }

        return min(max(confidence, 0.3), 0.95)
    }

    private func calculateOptimalSellWeek(_ player: EnhancedPlayer) -> Int {
        let performanceGap = player.averageScore - Double(player.breakeven)

        if performanceGap > 20 {
            return 6 // Strong performer, hold longer
        } else if performanceGap > 10 {
            return 4 // Moderate performer
        } else if performanceGap > 0 {
            return 2 // At breakeven soon
        } else {
            return 0 // Sell immediately
        }
    }

    private func calculateWeeklyPriceIncrease(_ player: EnhancedPlayer) -> Int {
        let performanceAboveBreakeven = max(0, player.averageScore - Double(player.breakeven))
        return Int(performanceAboveBreakeven * 1500) // Rough AFL Fantasy price algorithm
    }

    private func generatePriceTrajectory(_ player: EnhancedPlayer) -> [PricePoint] {
        let currentPrice = player.price
        let weeklyIncrease = calculateWeeklyPriceIncrease(player)
        let optimalWeek = calculateOptimalSellWeek(player)

        return (0 ... min(optimalWeek + 2, 8)).map { week in
            let projectedPrice = currentPrice + (weeklyIncrease * week)
            let confidence = max(0.5, 0.9 - Double(week) * 0.1) // Confidence decreases over time

            return PricePoint(
                week: week,
                projectedPrice: projectedPrice,
                confidence: confidence
            )
        }
    }

    private func identifyRiskFactors(_ player: EnhancedPlayer) -> [String] {
        var risks: [String] = []

        if player.injuryRisk.riskScore > 25 {
            risks.append("Elevated injury risk")
        }

        if player.consistency < 70 {
            risks.append("Inconsistent scoring patterns")
        }

        let breakevenCliff = Double(player.breakeven) - player.averageScore
        if breakevenCliff > -5, breakevenCliff < 5 {
            risks.append("Close to breakeven cliff")
        }

        // Using breakeven as proxy for games played since gamesPlayed property is not available
        if player.breakeven > 80 {
            risks.append("High breakeven suggests limited output")
        }

        return risks
    }

    private func identifyOpportunities(_ player: EnhancedPlayer) -> [String] {
        var opportunities: [String] = []

        if player.averageScore > Double(player.breakeven + 15) {
            opportunities.append("Strong cash generation potential")
        }

        if player.consistency > 85 {
            opportunities.append("Highly reliable scorer")
        }

        if player.highScore > Int(player.averageScore) + 25 {
            opportunities.append("High ceiling potential")
        }

        let currentPriceValue = Double(player.price) / player.averageScore
        if currentPriceValue < 8000 { // Good value threshold
            opportunities.append("Excellent value pick")
        }

        return opportunities
    }

    private func generateSellSignals() -> [SellSignal] {
        activeCashCows.compactMap { player in
            let analysis = cashAnalysis.first { $0.player.id == player.id }
            guard let analysis else { return nil }

            let urgency: SellUrgency
            let reason: String

            switch analysis.sellRecommendation {
            case .emergency:
                urgency = .critical
                reason = "Below breakeven - sell immediately"
            case .sellNow:
                urgency = .high
                reason = "At optimal sell point"
            case .sellSoon:
                urgency = .medium
                reason = "Approaching optimal timing"
            case .hold:
                return nil // No sell signal for holds
            }

            return SellSignal(
                player: player,
                urgency: urgency,
                reason: reason,
                projectedCashLoss: calculateCashLossIfHeld(player),
                confidence: analysis.confidenceLevel
            )
        }
    }

    private func generatePriceProjections() -> [PriceProjection] {
        activeCashCows.map { player in
            PriceProjection(
                player: player,
                currentPrice: player.price,
                projectedPrices: generatePriceTrajectory(player),
                peakPrice: calculatePeakPrice(player),
                peakWeek: calculateOptimalSellWeek(player)
            )
        }
    }

    private func calculateCashLossIfHeld(_ player: EnhancedPlayer) -> Int {
        // Simulate potential loss if held too long
        let weeklyDecrease = player.averageScore < Double(player.breakeven) ? 5000 : 0
        return weeklyDecrease * 4 // 4 weeks of potential loss
    }

    private func calculatePeakPrice(_ player: EnhancedPlayer) -> Int {
        let optimalWeek = calculateOptimalSellWeek(player)
        let weeklyIncrease = calculateWeeklyPriceIncrease(player)
        return player.price + (weeklyIncrease * optimalWeek)
    }

    private func calculateTotalCashGenerated() {
        totalCashGenerated = cashAnalysis.reduce(0) { $0 + $1.projectedCash }
    }
}

// MARK: - CashCowAnalysis

struct CashCowAnalysis: Identifiable {
    let id = UUID()
    let player: EnhancedPlayer
    let cashGenerated: Int
    let projectedCash: Int
    let sellRecommendation: SellTiming
    let confidenceLevel: Double
    let optimalSellWeek: Int
    let priceTrajectory: [PricePoint]
    let riskFactors: [String]
    let opportunities: [String]
}

// MARK: - PricePoint

struct PricePoint: Identifiable {
    let id = UUID()
    let week: Int
    let projectedPrice: Int
    let confidence: Double
}

// MARK: - SellTiming

enum SellTiming: String, CaseIterable {
    case hold = "Hold"
    case sellSoon = "Sell Soon"
    case sellNow = "Sell Now"
    case emergency = "Emergency"

    var color: Color {
        switch self {
        case .hold: .green
        case .sellSoon: .blue
        case .sellNow: .orange
        case .emergency: .red
        }
    }

    var icon: String {
        switch self {
        case .hold: "hand.raised.fill"
        case .sellSoon: "clock.fill"
        case .sellNow: "dollarsign.circle.fill"
        case .emergency: "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - SellSignal

struct SellSignal: Identifiable {
    let id = UUID()
    let player: EnhancedPlayer
    let urgency: SellUrgency
    let reason: String
    let projectedCashLoss: Int
    let confidence: Double
}

// MARK: - SellUrgency

enum SellUrgency: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"

    var color: Color {
        switch self {
        case .low: .green
        case .medium: .blue
        case .high: .orange
        case .critical: .red
        }
    }
}

// MARK: - PriceProjection

struct PriceProjection: Identifiable {
    let id = UUID()
    let player: EnhancedPlayer
    let currentPrice: Int
    let projectedPrices: [PricePoint]
    let peakPrice: Int
    let peakWeek: Int
}

// MARK: - CashGenerationSummary

struct CashGenerationSummary: View {
    let totalGenerated: Int
    let bankBalance: Int
    let activeCount: Int

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                CashMetricCard(
                    title: "Bank Balance",
                    value: formatCurrency(bankBalance),
                    icon: "banknote.fill",
                    color: .green
                )

                CashMetricCard(
                    title: "Projected Cash",
                    value: formatCurrency(totalGenerated),
                    icon: "arrow.up.circle.fill",
                    color: .mint
                )

                CashMetricCard(
                    title: "Active Cash Cows",
                    value: "\(activeCount)",
                    icon: "dollarsign.circle.fill",
                    color: .orange
                )
            }

            // Total available cash after generation
            if totalGenerated > 0 {
                HStack {
                    Text("Total Available After Generation:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(formatCurrency(bankBalance + totalGenerated))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private func formatCurrency(_ amount: Int) -> String {
        if amount >= 1_000_000 {
            String(format: "$%.1fM", Double(amount) / 1_000_000)
        } else {
            "$\(amount / 1000)k"
        }
    }
}

// MARK: - CashMetricCard

struct CashMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - CashCowViewSelector

struct CashCowViewSelector: View {
    @Binding var selectedView: AdvancedCashCowTracker.CashCowView

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AdvancedCashCowTracker.CashCowView.allCases, id: \.rawValue) { view in
                    Button(view.rawValue) {
                        selectedView = view
                    }
                    .buttonStyle(CashCowViewButtonStyle(isSelected: selectedView == view))
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - CashCowViewButtonStyle

struct CashCowViewButtonStyle: ButtonStyle {
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

// MARK: - TimeframeSelector

struct TimeframeSelector: View {
    @Binding var selectedTimeframe: AdvancedCashCowTracker.CashTimeframe
    let onSelectionChanged: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Analysis Timeframe")
                .font(.headline)
                .fontWeight(.medium)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(AdvancedCashCowTracker.CashTimeframe.allCases, id: \.rawValue) { timeframe in
                        Button(timeframe.rawValue) {
                            selectedTimeframe = timeframe
                            onSelectionChanged()
                        }
                        .buttonStyle(TimeframeButtonStyle(isSelected: selectedTimeframe == timeframe))
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - TimeframeButtonStyle

struct TimeframeButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.green : Color(.systemGray5))
            .cornerRadius(16)
    }
}

// MARK: - CashCowRecommendationsView

struct CashCowRecommendationsView: View {
    let analysis: [CashCowAnalysis]
    let timeframe: AdvancedCashCowTracker.CashTimeframe

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cash Cow Recommendations")
                .font(.headline)
                .fontWeight(.semibold)

            if analysis.isEmpty {
                EmptyCashCowsView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(analysis.prefix(5), id: \.id) { analysis in
                        CashCowAnalysisCard(analysis: analysis)
                    }
                }
            }
        }
    }
}

// MARK: - CashCowAnalysisCard

struct CashCowAnalysisCard: View {
    let analysis: CashCowAnalysis
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(analysis.player.name)
                        .font(.headline)
                        .fontWeight(.semibold)

                    HStack(spacing: 8) {
                        Text(analysis.player.nextRoundProjection.opponent)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(analysis.player.position.shortName)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(analysis.player.position.color)
                            .cornerRadius(4)

                        Text(analysis.player.formattedPrice)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    SellTimingBadge(timing: analysis.sellRecommendation)

                    Text("$\(analysis.projectedCash / 1000)k")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    Text("Projected")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Key metrics
            HStack(spacing: 16) {
                CashMetricPill(
                    title: "Generated",
                    value: "$\(analysis.cashGenerated / 1000)k",
                    color: .mint
                )

                CashMetricPill(
                    title: "Sell Week",
                    value: "\(analysis.optimalSellWeek)w",
                    color: .blue
                )

                CashMetricPill(
                    title: "Confidence",
                    value: String(format: "%.0f%%", analysis.confidenceLevel * 100),
                    color: confidenceColor
                )
            }

            // Price trajectory mini-chart
            PriceTrajectoryMiniChart(trajectory: analysis.priceTrajectory)

            // Expand button
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text(isExpanded ? "Show Less" : "Show Details")
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
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Opportunities")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.green)

                            ForEach(analysis.opportunities, id: \.self) { opportunity in
                                Text("• " + opportunity)
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Risk Factors")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.red)

                            ForEach(analysis.riskFactors, id: \.self) { risk in
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
        switch analysis.confidenceLevel {
        case 0.8...: .green
        case 0.6 ..< 0.8: .blue
        default: .orange
        }
    }
}

// MARK: - SellTimingBadge

struct SellTimingBadge: View {
    let timing: SellTiming

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: timing.icon)
                .font(.caption2)
                .foregroundColor(timing.color)

            Text(timing.rawValue)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(timing.color)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(timing.color.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - CashMetricPill

struct CashMetricPill: View {
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

// MARK: - PriceTrajectoryMiniChart

struct PriceTrajectoryMiniChart: View {
    let trajectory: [PricePoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Price Trajectory")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            GeometryReader { geometry in
                let maxPrice = trajectory.map(\.projectedPrice).max() ?? 0
                let minPrice = trajectory.map(\.projectedPrice).min() ?? 0
                let priceRange = max(1, maxPrice - minPrice)

                Path { path in
                    let stepWidth = geometry.size.width / CGFloat(max(1, trajectory.count - 1))

                    for (index, point) in trajectory.enumerated() {
                        let x = CGFloat(index) * stepWidth
                        let normalizedPrice = CGFloat(point.projectedPrice - minPrice) / CGFloat(priceRange)
                        let y = geometry.size.height * (1 - normalizedPrice)

                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.green, lineWidth: 2)
            }
            .frame(height: 30)

            HStack {
                Text("Week 0")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()

                Text("Week \(trajectory.last?.week ?? 0)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - EmptyCashCowsView

struct EmptyCashCowsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Active Cash Cows")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Your team doesn't have any players generating significant cash at the moment")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - CashCowTrackerView

struct CashCowTrackerView: View {
    let cashCows: [EnhancedPlayer]
    let sellSignals: [SellSignal]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cash Cow Tracker")
                .font(.headline)
                .fontWeight(.semibold)

            if !sellSignals.isEmpty {
                Text(
                    "🚨 \(sellSignals.filter { $0.urgency == .critical || $0.urgency == .high }.count) urgent sell signals"
                )
                .font(.subheadline)
                .foregroundColor(.red)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }

            LazyVStack(spacing: 8) {
                ForEach(cashCows.prefix(5), id: \.id) { player in
                    CashCowTrackerRow(player: player)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - CashCowTrackerRow

struct CashCowTrackerRow: View {
    let player: EnhancedPlayer

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(player.nextRoundProjection.opponent) • BE: \(player.breakeven)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(player.cashGenerated / 1000)k")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)

                Text("Generated")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

// MARK: - PriceProjectionsView

struct PriceProjectionsView: View {
    let projections: [PriceProjection]
    let timeframe: AdvancedCashCowTracker.CashTimeframe

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price Projections")
                .font(.headline)
                .fontWeight(.semibold)

            Text("Projected price movements based on current form and breakeven analysis")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - CashGenerationHistoryView

struct CashGenerationHistoryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cash Generation History")
                .font(.headline)
                .fontWeight(.semibold)

            Text("Track your historical cash generation performance and decisions")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - MarketIntelligenceSection

struct MarketIntelligenceSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Market Intelligence")
                .font(.headline)
                .fontWeight(.semibold)

            Text("Advanced market trends and cash generation opportunities across all AFL Fantasy players")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - DetailedCashCowAnalysisView

struct DetailedCashCowAnalysisView: View {
    let analysis: CashCowAnalysis
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Detailed analysis content would go here
                    Text("Detailed analysis for \(analysis.player.name)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding()
            }
            .navigationTitle("Cash Cow Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AdvancedCashCowTracker()
        .environmentObject(AppState())
}
