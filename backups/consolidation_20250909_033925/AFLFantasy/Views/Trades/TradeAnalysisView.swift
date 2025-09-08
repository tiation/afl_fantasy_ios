//
//  TradeAnalysisView.swift
//  AFL Fantasy Intelligence Platform
//
//  Advanced trade analysis and recommendations
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - TradeAnalysisView

struct TradeAnalysisView: View {
    // MARK: - Environment

    @EnvironmentObject private var toolsClient: AFLFantasyToolsClient
    @EnvironmentObject private var dataService: AFLFantasyDataService

    // MARK: - State

    @State private var selectedTab: TradeTab = .recommendations
    @State private var tradeRecommendations: [TradeAnalysis] = []
    @State private var customTradeAnalysis: TradeAnalysis?
    @State private var isLoading = false
    @State private var errorMessage: String?

    // Custom trade inputs
    @State private var playerOut = ""
    @State private var playerIn = ""
    @State private var budget = 100_000
    @State private var selectedPosition: String?
    @State private var showingCustomTrade = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Trade counter header
                TradeCounterHeader()

                // Tab selector
                TradeTabSelector(selectedTab: $selectedTab)

                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    // Recommendations Tab
                    TradeRecommendationsTab(
                        recommendations: tradeRecommendations,
                        isLoading: isLoading,
                        budget: $budget,
                        selectedPosition: $selectedPosition,
                        onRefresh: loadTradeRecommendations
                    )
                    .tag(TradeTab.recommendations)

                    // Custom Analysis Tab
                    CustomTradeTab(
                        playerOut: $playerOut,
                        playerIn: $playerIn,
                        budget: $budget,
                        analysis: customTradeAnalysis,
                        isLoading: isLoading,
                        onAnalyze: analyzeCustomTrade
                    )
                    .tag(TradeTab.custom)

                    // Trade History Tab
                    TradeHistoryTab()
                        .tag(TradeTab.history)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Trade Analysis")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Refresh Data") {
                            loadTradeRecommendations()
                        }

                        Button("Settings") {
                            // Trade settings
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
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
            loadTradeRecommendations()
        }
    }

    // MARK: - Methods

    private func loadTradeRecommendations() {
        isLoading = true
        errorMessage = nil

        Task {
            let result = await toolsClient.getTradeRecommendations(
                budget: budget,
                position: selectedPosition
            )

            await MainActor.run {
                isLoading = false

                switch result {
                case let .success(recommendations):
                    tradeRecommendations = recommendations
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func analyzeCustomTrade() {
        guard !playerOut.isEmpty, !playerIn.isEmpty else {
            errorMessage = "Please enter both players for analysis"
            return
        }

        isLoading = true
        errorMessage = nil
        customTradeAnalysis = nil

        Task {
            let result = await toolsClient.analyzeTradeOpportunity(
                playerOut: playerOut,
                playerIn: playerIn,
                budget: budget
            )

            await MainActor.run {
                isLoading = false

                switch result {
                case let .success(analysis):
                    customTradeAnalysis = analysis
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - TradeTab

enum TradeTab: String, CaseIterable {
    case recommendations = "Recommendations"
    case custom = "Custom"
    case history = "History"

    var systemImage: String {
        switch self {
        case .recommendations: "star.fill"
        case .custom: "magnifyingglass"
        case .history: "clock.fill"
        }
    }
}

// MARK: - TradeCounterHeader

struct TradeCounterHeader: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        HStack(spacing: 24) {
            TradeCounterItem(
                value: "\(appState.tradesUsed)",
                label: "Used",
                color: .red
            )

            TradeCounterItem(
                value: "\(appState.tradesRemaining)",
                label: "Remaining",
                color: .green
            )

            TradeCounterItem(
                value: "$\(appState.bankBalance / 1000)k",
                label: "Budget",
                color: .blue
            )
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

// MARK: - TradeCounterItem

struct TradeCounterItem: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - TradeTabSelector

struct TradeTabSelector: View {
    @Binding var selectedTab: TradeTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TradeTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                            .font(.caption)

                        Text(tab.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == tab ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedTab == tab ? Color.accentColor : Color.clear)
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding()
    }
}

// MARK: - TradeRecommendationsTab

struct TradeRecommendationsTab: View {
    let recommendations: [TradeAnalysis]
    let isLoading: Bool
    @Binding var budget: Int
    @Binding var selectedPosition: String?
    let onRefresh: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Filters
            TradeFiltersSection(
                budget: $budget,
                selectedPosition: $selectedPosition,
                onRefresh: onRefresh
            )

            // Recommendations list
            if isLoading {
                VStack {
                    ProgressView("Analyzing trades...")
                        .padding()

                    Spacer()
                }
            } else if recommendations.isEmpty {
                VStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                        .padding()

                    Text("No trade recommendations")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("Try adjusting your budget or position filter")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(recommendations) { recommendation in
                            TradeRecommendationCard(trade: recommendation)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - TradeFiltersSection

struct TradeFiltersSection: View {
    @Binding var budget: Int
    @Binding var selectedPosition: String?
    let onRefresh: () -> Void

    private let positions = ["DEF", "MID", "RUC", "FWD"]
    private let budgetOptions = [50000, 100_000, 200_000, 300_000, 500_000]

    var body: some View {
        VStack(spacing: 12) {
            // Budget selector
            VStack(alignment: .leading, spacing: 8) {
                Text("Budget: $\(budget / 1000)k")
                    .font(.subheadline)
                    .fontWeight(.medium)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(budgetOptions, id: \.self) { option in
                            Button("$\(option / 1000)k") {
                                budget = option
                                onRefresh()
                            }
                            .buttonStyle(FilterChipStyle(isSelected: budget == option))
                        }
                    }
                    .padding(.horizontal)
                }
            }

            // Position filter
            VStack(alignment: .leading, spacing: 8) {
                Text("Position Filter")
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    Button("All") {
                        selectedPosition = nil
                        onRefresh()
                    }
                    .buttonStyle(FilterChipStyle(isSelected: selectedPosition == nil))

                    ForEach(positions, id: \.self) { position in
                        Button(position) {
                            selectedPosition = position
                            onRefresh()
                        }
                        .buttonStyle(FilterChipStyle(isSelected: selectedPosition == position))
                    }

                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

// MARK: - FilterChipStyle

struct FilterChipStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .cornerRadius(16)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - TradeRecommendationCard

struct TradeRecommendationCard: View {
    let trade: TradeAnalysis
    @State private var showingDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Trade header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Trade Recommendation")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        Text(trade.impactGrade)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(gradeColor(trade.impactGrade))

                        Text("Impact")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(trade.netCostFormatted)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(trade.netCost >= 0 ? .red : .green)

                    Text("Net Cost")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Players
            HStack {
                // Player Out
                VStack(alignment: .leading, spacing: 4) {
                    Text("OUT")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .fontWeight(.semibold)

                    Text(trade.playerOut)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Image(systemName: "arrow.right")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .padding(.horizontal)

                // Player In
                VStack(alignment: .leading, spacing: 4) {
                    Text("IN")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .fontWeight(.semibold)

                    Text(trade.playerIn)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Spacer()
            }

            // Confidence and reasoning preview
            HStack {
                ConfidenceBadge(confidence: trade.confidence)

                Spacer()

                Button("View Details") {
                    showingDetail = true
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }

            // Reasoning preview
            Text(trade.reasoning)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            // Warnings (if any)
            if let warnings = trade.warnings, !warnings.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(warnings, id: \.self) { warning in
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)

                            Text(warning)
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $showingDetail) {
            TradeDetailView(trade: trade)
        }
    }

    private func gradeColor(_ grade: String) -> Color {
        switch grade {
        case "A+", "A": .green
        case "B": .yellow
        case "C": .orange
        default: .red
        }
    }
}

// MARK: - ConfidenceBadge

struct ConfidenceBadge: View {
    let confidence: Double

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(confidenceColor)
                .frame(width: 8, height: 8)

            Text(String(format: "%.0f%% Confidence", confidence * 100))
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(confidenceColor)
        }
    }

    private var confidenceColor: Color {
        switch confidence {
        case 0.8...: .green
        case 0.6 ..< 0.8: .yellow
        default: .red
        }
    }
}

// MARK: - CustomTradeTab

struct CustomTradeTab: View {
    @Binding var playerOut: String
    @Binding var playerIn: String
    @Binding var budget: Int
    let analysis: TradeAnalysis?
    let isLoading: Bool
    let onAnalyze: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Input form
                VStack(alignment: .leading, spacing: 16) {
                    Text("Analyze Custom Trade")
                        .font(.headline)
                        .fontWeight(.semibold)

                    // Player Out
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Player Out")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        TextField("Enter player to trade out", text: $playerOut)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Player In
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Player In")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        TextField("Enter player to trade in", text: $playerIn)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Budget
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Available Budget: $\(budget / 1000)k")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Slider(value: Binding(
                            get: { Double(budget) },
                            set: { budget = Int($0) }
                        ), in: 0 ... 1_000_000, step: 10000) {
                            Text("Budget")
                        }
                    }

                    // Analyze button
                    Button(action: onAnalyze) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }

                            Text(isLoading ? "Analyzing..." : "Analyze Trade")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading || playerOut.isEmpty || playerIn.isEmpty)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Analysis results
                if let analysis {
                    TradeAnalysisResultCard(analysis: analysis)
                }

                Spacer(minLength: 100)
            }
            .padding()
        }
    }
}

// MARK: - TradeAnalysisResultCard

struct TradeAnalysisResultCard: View {
    let analysis: TradeAnalysis

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Analysis Results")
                .font(.headline)
                .fontWeight(.semibold)

            // Grade and impact
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Impact Grade")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(analysis.impactGrade)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(gradeColor(analysis.impactGrade))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Net Cost")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(analysis.netCostFormatted)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(analysis.netCost >= 0 ? .red : .green)
                }
            }

            // Confidence
            HStack {
                Text("Confidence")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text(String(format: "%.0f%%", analysis.confidence * 100))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
            }

            // Reasoning
            VStack(alignment: .leading, spacing: 8) {
                Text("Analysis")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(analysis.reasoningText)
                    .font(.body)
                    .foregroundColor(.primary)
            }

            // Warnings
            if let warnings = analysis.warnings, !warnings.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Warnings")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)

                    ForEach(warnings, id: \.self) { warning in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.top, 2)

                            Text(warning)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private func gradeColor(_ grade: String) -> Color {
        switch grade {
        case "A+", "A": .green
        case "B": .yellow
        case "C": .orange
        default: .red
        }
    }
}

// MARK: - TradeHistoryTab

struct TradeHistoryTab: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if appState.tradeHistory.isEmpty {
            VStack {
                Image(systemName: "clock")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                    .padding()

                Text("No trade history yet")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("Your completed trades will appear here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(appState.tradeHistory) { trade in
                        TradeHistoryCard(trade: trade)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - TradeHistoryCard

struct TradeHistoryCard: View {
    let trade: TradeRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date and cost
            HStack {
                Text(trade.executedAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("$\(abs(trade.netCost) / 1000)k")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(trade.netCost >= 0 ? .red : .green)
            }

            // Players
            HStack {
                Text(trade.playerOut.name)
                    .strikethrough()
                    .foregroundColor(.secondary)

                Image(systemName: "arrow.right")
                    .foregroundColor(.accentColor)

                Text(trade.playerIn.name)
                    .fontWeight(.medium)

                Spacer()
            }

            // Impact
            HStack {
                Text("Projected Impact: \(String(format: "%.1f", trade.projectedImpact))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - TradeDetailView

struct TradeDetailView: View {
    let trade: TradeAnalysis
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Trade summary
                    TradeDetailHeader(trade: trade)

                    // Detailed analysis
                    TradeDetailAnalysis(trade: trade)

                    // Warnings and recommendations
                    if let warnings = trade.warnings, !warnings.isEmpty {
                        TradeWarningsSection(warnings: warnings)
                    }
                }
                .padding()
            }
            .navigationTitle("Trade Analysis")
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

// MARK: - TradeDetailHeader

struct TradeDetailHeader: View {
    let trade: TradeAnalysis

    var body: some View {
        VStack(spacing: 16) {
            // Players
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("OUT")
                        .font(.caption)
                        .foregroundColor(.red)
                        .fontWeight(.semibold)

                    Text(trade.playerOut)
                        .font(.title2)
                        .fontWeight(.semibold)
                }

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.title)
                    .foregroundColor(.accentColor)

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text("IN")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.semibold)

                    Text(trade.playerIn)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }

            // Metrics
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text(trade.impactGrade)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    Text("Impact Grade")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 4) {
                    Text(trade.netCostFormatted)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(trade.netCost >= 0 ? .red : .green)

                    Text("Net Cost")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 4) {
                    Text(String(format: "%.0f%%", trade.confidence * 100))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)

                    Text("Confidence")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - TradeDetailAnalysis

struct TradeDetailAnalysis: View {
    let trade: TradeAnalysis

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detailed Analysis")
                .font(.headline)
                .fontWeight(.semibold)

            Text(trade.reasoning)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - TradeWarningsSection

struct TradeWarningsSection: View {
    let warnings: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Warnings & Considerations")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(warnings, id: \.self) { warning in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                            .padding(.top, 2)

                        Text(warning)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    TradeAnalysisView()
        .environmentObject(AFLFantasyToolsClient())
        .environmentObject(AFLFantasyDataService())
        .environmentObject(AppState())
}
