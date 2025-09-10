//
//  CashCowTrackerView.swift
//  AFL Fantasy Intelligence Platform
//
//  Cash generation tracking and optimization
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - CashCowTrackerView

struct CashCowTrackerView: View {
    // MARK: - Environment

    @EnvironmentObject private var toolsClient: AFLFantasyToolsClient
    @EnvironmentObject private var appState: AppState

    // MARK: - State

    @State private var cashTargets: [CashGenerationTarget] = []
    @State private var selectedTimeframe = 3 // weeks
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedTarget: CashGenerationTarget?
    @State private var showingTargetDetail = false
    @State private var totalCashGenerated: Int = 0
    @State private var averageWeeksToTarget: Double = 0

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Cash summary header
                    CashSummaryHeader(
                        totalGenerated: totalCashGenerated,
                        averageWeeks: averageWeeksToTarget,
                        bankBalance: appState.bankBalance
                    )

                    // Timeframe selector
                    TimeframeSelectorSection(
                        selectedTimeframe: $selectedTimeframe,
                        onSelectionChanged: loadCashTargets
                    )

                    // Cash targets list
                    if isLoading {
                        VStack(spacing: 16) {
                            ProgressView("Analyzing cash generation opportunities...")
                                .padding()

                            ForEach(0 ..< 3) { _ in
                                CashTargetCardPlaceholder()
                            }
                        }
                    } else if cashTargets.isEmpty {
                        EmptyTargetsView()
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(cashTargets) { target in
                                CashTargetCard(target: target) {
                                    selectedTarget = target
                                    showingTargetDetail = true
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Cash Generation")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: loadCashTargets) {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(isLoading ? .degrees(360) : .degrees(0))
                            .animation(
                                isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                                value: isLoading
                            )
                    }
                    .disabled(isLoading)
                }
            }
        }
        .sheet(isPresented: $showingTargetDetail) {
            if let target = selectedTarget {
                CashTargetDetailView(target: target)
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear {
            loadCashTargets()
        }
    }

    // MARK: - Methods

    private func loadCashTargets() {
        isLoading = true
        errorMessage = nil

        Task {
            let result = await toolsClient.getCashGenerationTargets(weeks: selectedTimeframe)

            await MainActor.run {
                isLoading = false

                switch result {
                case let .success(targets):
                    cashTargets = targets
                    calculateSummaryMetrics()
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func calculateSummaryMetrics() {
        totalCashGenerated = cashTargets.reduce(0) { $0 + $1.cashGenerated }
        averageWeeksToTarget = cashTargets.isEmpty ? 0 :
            Double(cashTargets.reduce(0) { $0 + $1.expectedWeeks }) / Double(cashTargets.count)
    }
}

// MARK: - CashSummaryHeader

struct CashSummaryHeader: View {
    let totalGenerated: Int
    let averageWeeks: Double
    let bankBalance: Int

    var body: some View {
        VStack(spacing: 16) {
            // Main metrics
            HStack(spacing: 20) {
                CashSummaryItem(
                    title: "Bank Balance",
                    value: "$\(bankBalance / 1000)k",
                    color: .blue,
                    icon: "banknote"
                )

                CashSummaryItem(
                    title: "Potential Cash",
                    value: "$\(totalGenerated / 1000)k",
                    color: .green,
                    icon: "arrow.up.circle.fill"
                )

                CashSummaryItem(
                    title: "Avg Timeline",
                    value: String(format: "%.1f weeks", averageWeeks),
                    color: .orange,
                    icon: "clock.fill"
                )
            }

            // Total available after cash generation
            if totalGenerated > 0 {
                HStack {
                    Text("Total Available After Generation:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("$\((bankBalance + totalGenerated) / 1000)k")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                }
                .padding()
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - CashSummaryItem

struct CashSummaryItem: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
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
    }
}

// MARK: - TimeframeSelectorSection

struct TimeframeSelectorSection: View {
    @Binding var selectedTimeframe: Int
    let onSelectionChanged: () -> Void

    private let timeframes = [
        (weeks: 2, label: "2 weeks"),
        (weeks: 3, label: "3 weeks"),
        (weeks: 4, label: "4 weeks"),
        (weeks: 6, label: "6 weeks"),
        (weeks: 8, label: "8 weeks")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Generation Timeframe")
                .font(.headline)
                .fontWeight(.semibold)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(timeframes, id: \.weeks) { timeframe in
                        Button(timeframe.label) {
                            selectedTimeframe = timeframe.weeks
                            onSelectionChanged()
                        }
                        .buttonStyle(TimeframeChipStyle(isSelected: selectedTimeframe == timeframe.weeks))
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - TimeframeChipStyle

struct TimeframeChipStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - CashTargetCard

struct CashTargetCard: View {
    let target: CashGenerationTarget
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Player header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(target.player)
                        .font(.headline)
                        .fontWeight(.semibold)

                    HStack(spacing: 8) {
                        RiskBadge(risk: target.riskLevel)

                        Text("BE: \(target.breakeven)")
                            .font(.caption)
                            .foregroundColor(target.breakeven < 0 ? .green : .orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .cornerRadius(4)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("$\(target.cashGenerated / 1000)k")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    Text("Potential")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Price progression
            PriceProgressionView(target: target)

            // Timeline and confidence
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(target.expectedWeeks) weeks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                ConfidenceIndicator(
                    confidence: target.confidence,
                    showPercentage: true
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - RiskBadge

struct RiskBadge: View {
    let risk: String

    var body: some View {
        Text(risk.uppercased())
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(riskColor)
            .cornerRadius(4)
    }

    private var riskColor: Color {
        switch risk.lowercased() {
        case "low": .green
        case "medium": .yellow
        case "high": .orange
        default: .red
        }
    }
}

// MARK: - PriceProgressionView

struct PriceProgressionView: View {
    let target: CashGenerationTarget

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Current")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text("$\(target.currentPrice / 1000)k")
                        .font(.caption)
                        .fontWeight(.medium)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Target")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text("$\(target.targetPrice / 1000)k")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(.systemGray5))
                    .frame(height: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.green)
                            .frame(width: geometry.size.width * progressRatio, height: 4),
                        alignment: .leading
                    )
            }
            .frame(height: 4)
        }
    }

    private var progressRatio: CGFloat {
        let totalIncrease = target.targetPrice - target.currentPrice
        let minPrice = target.currentPrice
        return totalIncrease > 0 ? CGFloat(0.3) : 0 // Placeholder progress
    }
}

// MARK: - ConfidenceIndicator

struct ConfidenceIndicator: View {
    let confidence: Double
    let showPercentage: Bool

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(confidenceColor)
                .frame(width: 8, height: 8)

            if showPercentage {
                Text("\(Int(confidence * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(confidenceColor)
            }
        }
    }

    private var confidenceColor: Color {
        switch confidence {
        case 0.8...: .green
        case 0.6 ..< 0.8: .yellow
        default: .orange
        }
    }
}

// MARK: - EmptyTargetsView

struct EmptyTargetsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Cash Generation Opportunities")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Try adjusting the timeframe or check back later for new opportunities")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - CashTargetCardPlaceholder

struct CashTargetCardPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 120, height: 16)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 80, height: 12)
                }

                Spacer()

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 20)
            }

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(height: 20)

            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 12)

                Spacer()

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .redacted(reason: .placeholder)
    }
}

// MARK: - CashTargetDetailView

struct CashTargetDetailView: View {
    let target: CashGenerationTarget
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Player header
                    CashTargetHeader(target: target)

                    // Detailed metrics
                    CashTargetMetrics(target: target)

                    // Price analysis
                    PriceAnalysisSection(target: target)

                    // Risk assessment
                    RiskAnalysisSection(target: target)

                    // Timeline breakdown
                    TimelineBreakdownSection(target: target)
                }
                .padding()
            }
            .navigationTitle(target.player)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - CashTargetHeader

struct CashTargetHeader: View {
    let target: CashGenerationTarget

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(target.player)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                RiskBadge(risk: target.riskLevel)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(target.cashGenerated / 1000)k")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)

                Text("Cash Generation")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - CashTargetMetrics

struct CashTargetMetrics: View {
    let target: CashGenerationTarget

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Metrics")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "Current Price",
                    value: "$\(target.currentPrice / 1000)k",
                    color: .blue
                )

                MetricCard(
                    title: "Target Price",
                    value: "$\(target.targetPrice / 1000)k",
                    color: .green
                )

                MetricCard(
                    title: "Breakeven",
                    value: "\(target.breakeven)",
                    color: target.breakeven < 0 ? .green : .orange
                )

                MetricCard(
                    title: "Timeline",
                    value: "\(target.expectedWeeks) weeks",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - MetricCard

struct MetricCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - PriceAnalysisSection

struct PriceAnalysisSection: View {
    let target: CashGenerationTarget

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price Analysis")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                HStack {
                    Text("Price Increase Needed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("$\((target.targetPrice - target.currentPrice) / 1000)k")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }

                HStack {
                    Text("Points Above Breakeven")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(abs(target.breakeven)) pts")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(target.breakeven < 0 ? .green : .orange)
                }

                HStack {
                    Text("Confidence Level")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    HStack(spacing: 4) {
                        ConfidenceIndicator(confidence: target.confidence, showPercentage: false)

                        Text("\(Int(target.confidence * 100))%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - RiskAnalysisSection

struct RiskAnalysisSection: View {
    let target: CashGenerationTarget

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Risk Assessment")
                .font(.headline)
                .fontWeight(.semibold)

            HStack {
                RiskBadge(risk: target.riskLevel)

                Spacer()

                Text(riskDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(riskExplanation)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var riskDescription: String {
        switch target.riskLevel.lowercased() {
        case "low": "Reliable cash generation"
        case "medium": "Moderate risk involved"
        case "high": "Higher risk, higher reward"
        default: "Very high risk"
        }
    }

    private var riskExplanation: String {
        switch target.riskLevel.lowercased() {
        case "low": "This player has consistent scoring patterns and favorable fixtures, making them a reliable cash generation target."
        case "medium": "Some variables may affect performance, but overall trajectory looks positive for cash generation."
        case "high": "Higher volatility in scoring or external factors may impact the cash generation timeline."
        default: "Multiple risk factors present. Consider carefully before committing."
        }
    }
}

// MARK: - TimelineBreakdownSection

struct TimelineBreakdownSection: View {
    let target: CashGenerationTarget

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timeline Breakdown")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                TimelineItem(
                    week: "Week 1-2",
                    description: "Initial price movement expected",
                    isCompleted: false
                )

                TimelineItem(
                    week: "Week \(target.expectedWeeks / 2)",
                    description: "Midpoint price check",
                    isCompleted: false
                )

                TimelineItem(
                    week: "Week \(target.expectedWeeks)",
                    description: "Target price achievement",
                    isCompleted: false
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - TimelineItem

struct TimelineItem: View {
    let week: String
    let description: String
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(isCompleted ? Color.green : Color(.systemGray4))
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text(week)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    CashCowTrackerView()
        .environmentObject(AFLFantasyToolsClient())
        .environmentObject(AppState())
}
