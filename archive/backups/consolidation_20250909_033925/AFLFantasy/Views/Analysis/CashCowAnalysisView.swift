import Charts
import SwiftUI

// MARK: - CashCowAnalysisView

struct CashCowAnalysisView: View {
    @EnvironmentObject var appState: LiveAppState
    @State private var selectedTimeframe: CashTimeframe = .optimal
    @State private var isAnalyzing = false
    @State private var showingCashCowGuide = false

    enum CashTimeframe: String, CaseIterable {
        case immediate = "Now"
        case week2 = "2 Weeks"
        case week4 = "4 Weeks"
        case optimal = "Optimal"
    }

    var totalCashGenerated: Int {
        appState.cashCows.reduce(0) { $0 + $1.cashGenerated }
    }

    var projectedCash: Int {
        appState.cashCows.reduce(0) { $0 + $1.targetPrice }
    }

    var body: some View {
        NavigationView {
            List {
                // Summary metrics
                Section {
                    CashMetricsView(
                        generated: totalCashGenerated,
                        projected: projectedCash,
                        count: appState.cashCows.count
                    )
                }

                // Cash generation chart
                Section("Cash Generation") {
                    CashGenerationChart(recommendations: appState.cashCows)
                        .frame(height: 200)
                }

                // Timeframe selector
                Section {
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(CashTimeframe.allCases, id: \.self) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedTimeframe) { _ in
                        Task {
                            await analyzeCashCows()
                        }
                    }
                }

                // Cash cow recommendations
                Section {
                    ForEach(appState.cashCows, id: \.playerName) { cow in
                        CashCowRecommendationRow(recommendation: cow)
                    }
                } header: {
                    HStack {
                        Text("Recommendations")
                        Spacer()
                        Button {
                            showingCashCowGuide = true
                        } label: {
                            Image(systemName: "info.circle")
                        }
                    }
                }
            }
            .navigationTitle("Cash Cows")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            isAnalyzing = true
                            await analyzeCashCows()
                            isAnalyzing = false
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .symbolEffect(.bounce, value: isAnalyzing)
                    }
                    .disabled(isAnalyzing)
                }
            }
            .refreshable {
                await analyzeCashCows()
            }
            .sheet(isPresented: $showingCashCowGuide) {
                NavigationView {
                    CashCowGuideView()
                }
            }
        }
    }

    func analyzeCashCows() async {
        do {
            let analysis = try await appState.api.analyzeCashCows(teamId: "user_team")
            await MainActor.run {
                appState.cashCows = analysis
            }
        } catch {
            print("Failed to analyze cash cows: \(error)")
        }
    }
}

// MARK: - CashMetricsView

struct CashMetricsView: View {
    let generated: Int
    let projected: Int
    let count: Int

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            MetricCard(
                title: "Generated",
                value: "$\(generated / 1000)k",
                icon: "dollarsign.circle.fill",
                color: .green
            )

            MetricCard(
                title: "Projected",
                value: "$\(projected / 1000)k",
                icon: "chart.line.uptrend.xyaxis",
                color: .blue
            )

            MetricCard(
                title: "Cash Cows",
                value: "\(count)",
                icon: "person.3.fill",
                color: .orange
            )
        }
    }
}

// MARK: - MetricCard

struct MetricCard: View {
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
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - CashGenerationChart

struct CashGenerationChart: View {
    let recommendations: [CashCowRecommendation]

    var chartData: [(week: Int, value: Int)] {
        var data: [(week: Int, value: Int)] = []
        var totalCash = 0

        for week in 0 ... 8 {
            let weekValue = recommendations.reduce(0) { total, cow in
                if week >= cow.projectedWeeks {
                    return total + cow.targetPrice
                } else {
                    let weeklyGain = cow.targetPrice / cow.projectedWeeks
                    return total + (weeklyGain * week)
                }
            }
            totalCash = weekValue
            data.append((week: week, value: totalCash))
        }

        return data
    }

    var body: some View {
        Chart {
            ForEach(chartData, id: \.week) { item in
                LineMark(
                    x: .value("Week", item.week),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(.green)
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Week", item.week),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(.green)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let value = value.as(Int.self) {
                        Text("$\(value / 1000)k")
                            .font(.caption)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let week = value.as(Int.self) {
                        Text("W\(week)")
                            .font(.caption)
                    }
                }
            }
        }
    }
}

// MARK: - CashCowRecommendationRow

struct CashCowRecommendationRow: View {
    let recommendation: CashCowRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.playerName)
                        .font(.headline)

                    Text("$\(recommendation.currentPrice / 1000)k → $\(recommendation.targetPrice / 1000)k")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("+$\(recommendation.cashGenerated / 1000)k")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    Text("\(recommendation.projectedWeeks) weeks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Progress and timing
            VStack(spacing: 8) {
                // Confidence bar
                ConfidenceBar(
                    percentage: recommendation.confidence * 100,
                    label: "Confidence"
                )

                // Sell urgency
                HStack {
                    Label(
                        recommendation.sellUrgency,
                        systemImage: sellUrgencyIcon
                    )
                    .font(.caption)
                    .foregroundColor(sellUrgencyColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(sellUrgencyColor.opacity(0.1))
                    .cornerRadius(8)

                    Spacer()

                    Button {
                        // Add to watchlist
                    } label: {
                        Text("Watch")
                            .font(.footnote)
                    }
                    .buttonStyle(.bordered)
                }
            }

            // Reasoning
            if !recommendation.reasoning.isEmpty {
                Text(recommendation.reasoning)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var sellUrgencyIcon: String {
        switch recommendation.sellUrgency.lowercased() {
        case "urgent", "high": "exclamationmark.triangle.fill"
        case "soon", "medium": "clock.fill"
        default: "hand.raised.fill"
        }
    }

    private var sellUrgencyColor: Color {
        switch recommendation.sellUrgency.lowercased() {
        case "urgent", "high": .red
        case "soon", "medium": .orange
        default: .blue
        }
    }
}

// MARK: - ConfidenceBar

struct ConfidenceBar: View {
    let percentage: Double
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(Int(percentage))%")
                    .font(.caption)
                    .foregroundColor(confidenceColor)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                        .cornerRadius(3)

                    Rectangle()
                        .fill(confidenceColor)
                        .frame(width: geometry.size.width * percentage / 100, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
    }

    private var confidenceColor: Color {
        switch percentage {
        case 80...: .green
        case 60...: .blue
        default: .orange
        }
    }
}

// MARK: - CashCowGuideView

struct CashCowGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)

                    Text("Cash Cow Guide")
                        .font(.title2)
                        .bold()

                    Text("Learn how to maximize your team value through effective cash cow management.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }

            Section("What is a Cash Cow?") {
                InfoRow(
                    title: "Affordable Player",
                    description: "A player priced under $300k with potential for significant price rises.",
                    icon: "dollarsign.circle"
                )

                InfoRow(
                    title: "High Scoring",
                    description: "Consistently scores above their breakeven, leading to price increases.",
                    icon: "chart.line.uptrend.xyaxis"
                )

                InfoRow(
                    title: "Limited Time",
                    description: "Should be traded out at peak price for maximum profit.",
                    icon: "clock"
                )
            }

            Section("Strategy") {
                InfoRow(
                    title: "Buy Low",
                    description: "Target rookies and underpriced players early in the season.",
                    icon: "cart"
                )

                InfoRow(
                    title: "Monitor Performance",
                    description: "Track breakevens and scoring trends to time trades perfectly.",
                    icon: "eyes"
                )

                InfoRow(
                    title: "Sell High",
                    description: "Trade to premium players when cash cows reach peak value.",
                    icon: "arrow.up.right"
                )
            }

            Section("Tips") {
                InfoRow(
                    title: "Job Security",
                    description: "Prioritize players with secure spots in their team's best 22.",
                    icon: "lock"
                )

                InfoRow(
                    title: "Role Changes",
                    description: "Watch for players getting increased midfield time or responsibility.",
                    icon: "arrow.triangle.swap"
                )

                InfoRow(
                    title: "Team Structure",
                    description: "Maintain a balanced mix of premiums and cash cows.",
                    icon: "square.stack.3d.up"
                )
            }
        }
        .navigationTitle("Cash Cow Guide")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }
}

// MARK: - InfoRow

struct InfoRow: View {
    let title: String
    let description: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.green)

                Text(title)
                    .font(.headline)
            }

            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    CashCowAnalysisView()
        .environmentObject(LiveAppState())
}
