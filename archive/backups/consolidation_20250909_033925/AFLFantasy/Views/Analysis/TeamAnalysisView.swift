import Charts
import SwiftUI

// MARK: - TeamAnalysisView

struct TeamAnalysisView: View {
    @EnvironmentObject var appState: LiveAppState
    @State private var selectedAnalysis: AnalysisType = .structure
    @State private var isAnalyzing = false

    enum AnalysisType: String, CaseIterable {
        case structure = "Structure"
        case performance = "Performance"
        case risk = "Risk"
        case value = "Value"
    }

    var body: some View {
        NavigationView {
            List {
                // Analysis type picker
                Section {
                    Picker("Analysis Type", selection: $selectedAnalysis) {
                        ForEach(AnalysisType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Current analysis view
                Section {
                    switch selectedAnalysis {
                    case .structure:
                        TeamStructureView(appState: appState)
                    case .performance:
                        TeamPerformanceView(appState: appState)
                    case .risk:
                        TeamRiskView(appState: appState)
                    case .value:
                        TeamValueView(appState: appState)
                    }
                }
            }
            .navigationTitle("Team Analysis")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            isAnalyzing = true
                            await analyzeTeam()
                            isAnalyzing = false
                        }
                    } label: {
                        Image(systemName: "wand.and.stars")
                            .symbolEffect(.bounce, value: isAnalyzing)
                    }
                    .disabled(isAnalyzing)
                }
            }
        }
    }

    func analyzeTeam() async {
        // Perform team analysis
    }
}

// MARK: - TeamStructureView

struct TeamStructureView: View {
    @ObservedObject var appState: LiveAppState

    var positionBreakdown: [PositionBreakdown] {
        Position.allCases.map { position in
            let players = appState.players.filter { $0.position == position }
            let totalValue = players.reduce(0) { $0 + $1.price }
            let averageScore = players.reduce(0.0) { $0 + $1.averageScore } / Double(players.count)

            return PositionBreakdown(
                position: position,
                count: players.count,
                totalValue: totalValue,
                averageScore: averageScore
            )
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Position distribution chart
            Chart {
                ForEach(positionBreakdown) { breakdown in
                    SectorMark(
                        angle: .value("Count", breakdown.count)
                    )
                    .foregroundStyle(by: .value("Position", breakdown.position.rawValue))
                }
            }
            .frame(height: 200)

            // Position breakdown
            ForEach(positionBreakdown) { breakdown in
                PositionBreakdownRow(breakdown: breakdown)
            }

            // Recommendations
            RecommendationsView(recommendations: [
                "Consider trading one MID to RUC for better balance",
                "Forward line could use more premium players",
                "Good defensive structure with mix of premiums and cash cows"
            ])
        }
    }
}

// MARK: - PositionBreakdown

struct PositionBreakdown: Identifiable {
    let position: Position
    let count: Int
    let totalValue: Int
    let averageScore: Double

    var id: Position { position }
}

// MARK: - PositionBreakdownRow

struct PositionBreakdownRow: View {
    let breakdown: PositionBreakdown

    var body: some View {
        HStack {
            // Position badge
            Text(breakdown.position.shortName)
                .font(.caption)
                .bold()
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(breakdown.position.color)
                .cornerRadius(6)

            // Stats
            VStack(alignment: .leading) {
                Text("\(breakdown.count) Players")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("$\(breakdown.totalValue / 1000)k • Avg: \(String(format: "%.1f", breakdown.averageScore))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - TeamPerformanceView

struct TeamPerformanceView: View {
    @ObservedObject var appState: LiveAppState

    var performanceData: PerformanceData {
        let totalScore = appState.players.reduce(0.0) { $0 + Double($1.currentScore) }
        let averageScore = totalScore / Double(appState.players.count)
        let consistency = appState.players.reduce(0.0) { $0 + $1.consistency } / Double(appState.players.count)
        let topScorers = appState.players
            .sorted { $0.averageScore > $1.averageScore }
            .prefix(3)

        return PerformanceData(
            totalScore: Int(totalScore),
            averageScore: averageScore,
            consistency: consistency,
            topScorers: Array(topScorers)
        )
    }

    var body: some View {
        VStack(spacing: 16) {
            // Performance metrics
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "Total Score",
                    value: String(performanceData.totalScore),
                    trend: "Rank \(appState.teamRank)"
                )

                MetricCard(
                    title: "Average",
                    value: String(format: "%.1f", performanceData.averageScore),
                    trend: String(format: "+%.1f", performanceData.consistency)
                )
            }

            // Top scorers
            VStack(alignment: .leading, spacing: 8) {
                Text("Top Scorers")
                    .font(.headline)

                ForEach(performanceData.topScorers) { player in
                    TopScorerRow(player: player)
                }
            }

            // Performance chart
            Text("Score Trend")
                .font(.headline)

            Chart {
                // Mock data for demonstration
                ForEach(1 ... 10, id: \.self) { round in
                    LineMark(
                        x: .value("Round", round),
                        y: .value("Score", Double.random(in: 1800 ... 2200))
                    )
                    .foregroundStyle(.blue)
                    .interpolationMethod(.catmullRom)
                }
            }
            .frame(height: 200)

            // Recommendations
            RecommendationsView(recommendations: [
                "Consider upgrading underperforming midfielder",
                "Team showing good consistency across positions",
                "Watch for potential role changes affecting scoring"
            ])
        }
    }
}

// MARK: - PerformanceData

struct PerformanceData {
    let totalScore: Int
    let averageScore: Double
    let consistency: Double
    let topScorers: [EnhancedPlayer]
}

// MARK: - TopScorerRow

struct TopScorerRow: View {
    let player: EnhancedPlayer

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(player.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(player.position.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(String(format: "%.1f", player.averageScore))
                .font(.headline)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - TeamRiskView

struct TeamRiskView: View {
    @ObservedObject var appState: LiveAppState

    var riskData: RiskData {
        let totalPlayers = appState.players.count
        let injuryRisk = appState.players.filter { $0.injuryRisk.riskLevel != .low }.count
        let breakevens = appState.players.filter { $0.breakeven > Int($0.averageScore) }.count
        let suspended = appState.players.filter(\.isSuspended).count

        return RiskData(
            injuryRiskCount: injuryRisk,
            highBreakevenCount: breakevens,
            suspendedCount: suspended,
            totalPlayers: totalPlayers
        )
    }

    var body: some View {
        VStack(spacing: 16) {
            // Risk summary
            RiskSummaryView(data: riskData)

            // Risk breakdown
            Chart {
                BarMark(
                    x: .value("Count", Double(riskData.injuryRiskCount) / Double(riskData.totalPlayers) * 100),
                    y: .value("Type", "Injury Risk")
                )
                .foregroundStyle(.orange)

                BarMark(
                    x: .value("Count", Double(riskData.highBreakevenCount) / Double(riskData.totalPlayers) * 100),
                    y: .value("Type", "High BE")
                )
                .foregroundStyle(.red)

                BarMark(
                    x: .value("Count", Double(riskData.suspendedCount) / Double(riskData.totalPlayers) * 100),
                    y: .value("Type", "Suspended")
                )
                .foregroundStyle(.purple)
            }
            .frame(height: 120)

            // Risk factors
            ForEach(appState.players.filter { !$0.injuryRisk.riskFactors.isEmpty }) { player in
                PlayerRiskRow(player: player)
            }

            // Recommendations
            RecommendationsView(recommendations: [
                "Consider trading out high-risk players",
                "Monitor players approaching breakeven",
                "Have cover for potentially suspended players"
            ])
        }
    }
}

// MARK: - RiskData

struct RiskData {
    let injuryRiskCount: Int
    let highBreakevenCount: Int
    let suspendedCount: Int
    let totalPlayers: Int

    var totalRiskScore: Double {
        Double(injuryRiskCount + highBreakevenCount + suspendedCount) / Double(totalPlayers) * 100
    }
}

// MARK: - RiskSummaryView

struct RiskSummaryView: View {
    let data: RiskData

    var body: some View {
        VStack(spacing: 8) {
            Text("Risk Level")
                .font(.headline)

            Text(String(format: "%.1f%%", data.totalRiskScore))
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(riskColor)

            Text(riskDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var riskColor: Color {
        switch data.totalRiskScore {
        case 0 ... 20: .green
        case 20 ... 40: .blue
        case 40 ... 60: .orange
        default: .red
        }
    }

    private var riskDescription: String {
        switch data.totalRiskScore {
        case 0 ... 20: "Low Risk - Team is stable"
        case 20 ... 40: "Moderate Risk - Some concerns"
        case 40 ... 60: "High Risk - Action needed"
        default: "Critical Risk - Immediate attention required"
        }
    }
}

// MARK: - PlayerRiskRow

struct PlayerRiskRow: View {
    let player: EnhancedPlayer

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(player.name)
                    .font(.headline)

                Spacer()

                Text(player.injuryRisk.riskLevel.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(riskColor)
                    .cornerRadius(8)
            }

            ForEach(player.injuryRisk.riskFactors, id: \.self) { factor in
                Label(factor, systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var riskColor: Color {
        switch player.injuryRisk.riskLevel {
        case .low: .green
        case .medium: .orange
        case .high: .red
        }
    }
}

// MARK: - TeamValueView

struct TeamValueView: View {
    @ObservedObject var appState: LiveAppState

    var valueData: ValueData {
        let totalValue = appState.players.reduce(0) { $0 + $1.price }
        let totalScore = appState.players.reduce(0.0) { $0 + $1.averageScore }
        let valuePerPoint = Double(totalValue) / totalScore

        return ValueData(
            totalValue: totalValue,
            bankBalance: appState.bankBalance,
            valuePerPoint: Int(valuePerPoint),
            priceChanges: appState.players.map { player in
                PriceChange(
                    name: player.name,
                    currentPrice: player.price,
                    change: player.priceChange
                )
            }
            .sorted { abs($0.change) > abs($1.change) }
            .prefix(5)
        )
    }

    var body: some View {
        VStack(spacing: 16) {
            // Value metrics
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "Total Value",
                    value: "$\(valueData.totalValue / 1000)k",
                    trend: "+$\(appState.teamValue / 1000)k"
                )

                MetricCard(
                    title: "Bank",
                    value: "$\(valueData.bankBalance / 1000)k",
                    trend: "Available"
                )
            }

            // Value per point
            HStack {
                Text("Value Per Point")
                    .font(.headline)

                Spacer()

                Text("$\(valueData.valuePerPoint / 1000)k")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)

            // Recent price changes
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Price Changes")
                    .font(.headline)

                ForEach(Array(valueData.priceChanges), id: \.name) { change in
                    PriceChangeRow(change: change)
                }
            }

            // Price trend chart
            Chart {
                // Mock data for demonstration
                ForEach(1 ... 10, id: \.self) { week in
                    LineMark(
                        x: .value("Week", week),
                        y: .value("Value", Double(appState.teamValue) + Double.random(in: -50000 ... 50000))
                    )
                    .foregroundStyle(.green)
                    .interpolationMethod(.catmullRom)
                }
            }
            .frame(height: 200)

            // Recommendations
            RecommendationsView(recommendations: [
                "Good opportunity to upgrade midfielder",
                "Consider banking cash for upcoming trade period",
                "Watch for price drops in premium defenders"
            ])
        }
    }
}

// MARK: - ValueData

struct ValueData {
    let totalValue: Int
    let bankBalance: Int
    let valuePerPoint: Int
    let priceChanges: Array<PriceChange>.SubSequence
}

// MARK: - PriceChange

struct PriceChange: Identifiable {
    let name: String
    let currentPrice: Int
    let change: Int

    var id: String { name }
}

// MARK: - PriceChangeRow

struct PriceChangeRow: View {
    let change: PriceChange

    var body: some View {
        HStack {
            Text(change.name)
                .font(.subheadline)

            Spacer()

            VStack(alignment: .trailing) {
                Text("$\(change.currentPrice / 1000)k")
                    .font(.subheadline)

                Text("\(change.change >= 0 ? "+" : "")\(change.change / 1000)k")
                    .font(.caption)
                    .foregroundColor(change.change >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - RecommendationsView

struct RecommendationsView: View {
    let recommendations: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommendations")
                .font(.headline)

            ForEach(recommendations, id: \.self) { recommendation in
                Label(recommendation, systemImage: "lightbulb.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - MetricCard

struct MetricCard: View {
    let title: String
    let value: String
    let trend: String?
    var trendColor: Color = .blue

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            if let trend {
                Text(trend)
                    .font(.caption)
                    .foregroundColor(trendColor)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    TeamAnalysisView()
        .environmentObject(LiveAppState())
}
