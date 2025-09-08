//
//  CaptainAnalysisView.swift
//  AFL Fantasy Intelligence Platform
//
//  Advanced captain analysis and suggestions
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - CaptainAnalysisView

struct CaptainAnalysisView: View {
    // MARK: - Environment

    @EnvironmentObject private var toolsClient: AFLFantasyToolsClient
    @EnvironmentObject private var dataService: AFLFantasyDataService

    // MARK: - State

    @State private var captainSuggestions: [CaptainSuggestionAnalysis] = []
    @State private var selectedCaptainAnalysis: CaptainSuggestionAnalysis?
    @State private var isLoading = false
    @State private var showingPlayerAnalysis = false
    @State private var searchText = ""
    @State private var selectedRound: Int?
    @State private var errorMessage: String?

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with current captain info - placeholder for now
                let placeholderCaptain = CaptainData()
                CurrentCaptainHeader(captain: placeholderCaptain)
                    .padding()
                    .background(Color(.systemGray6))

                // Search and filters
                SearchAndFilterSection(
                    searchText: $searchText,
                    selectedRound: $selectedRound,
                    onRefresh: loadCaptainSuggestions
                )

                // Suggestions list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredSuggestions) { suggestion in
                            CaptainSuggestionCard(suggestion: suggestion) {
                                selectedCaptainAnalysis = suggestion
                                showingPlayerAnalysis = true
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Captain Analysis")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: loadCaptainSuggestions) {
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
        .sheet(isPresented: $showingPlayerAnalysis) {
            if let analysis = selectedCaptainAnalysis {
                PlayerAnalysisDetailView(analysis: analysis)
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
            loadCaptainSuggestions()
        }
    }

    // MARK: - Computed Properties

    private var filteredSuggestions: [CaptainSuggestionAnalysis] {
        let filtered = captainSuggestions.filter { suggestion in
            searchText.isEmpty ||
                suggestion.player.localizedCaseInsensitiveContains(searchText) ||
                suggestion.team.localizedCaseInsensitiveContains(searchText)
        }
        return filtered.sorted { $0.projectedScore > $1.projectedScore }
    }

    // MARK: - Methods

    private func loadCaptainSuggestions() {
        isLoading = true
        errorMessage = nil

        Task {
            let result = await toolsClient.getCaptainSuggestions(round: selectedRound)

            await MainActor.run {
                isLoading = false

                switch result {
                case let .success(suggestions):
                    captainSuggestions = suggestions
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - SearchAndFilterSection

struct SearchAndFilterSection: View {
    @Binding var searchText: String
    @Binding var selectedRound: Int?
    let onRefresh: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search players...", text: $searchText)
                    .textFieldStyle(.plain)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            // Round selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    RoundFilterChip(
                        title: "All Rounds",
                        isSelected: selectedRound == nil,
                        action: { selectedRound = nil; onRefresh() }
                    )

                    ForEach(1 ... 24, id: \.self) { round in
                        RoundFilterChip(
                            title: "R\(round)",
                            isSelected: selectedRound == round,
                            action: { selectedRound = round; onRefresh() }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
}

// MARK: - RoundFilterChip

struct RoundFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .cornerRadius(16)
        }
    }
}

// MARK: - CaptainSuggestionCard

struct CaptainSuggestionCard: View {
    let suggestion: CaptainSuggestionAnalysis
    let onTap: () -> Void
    @EnvironmentObject private var dataService: AFLFantasyDataService
    @State private var showingCaptainConfirmation = false
    @State private var isSettingCaptain = false

    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Player info header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.player)
                        .font(.headline)
                        .fontWeight(.semibold)

                    HStack(spacing: 8) {
                        Text(suggestion.team)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(suggestion.position)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(positionColor(suggestion.position))
                            .cornerRadius(4)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.1f", suggestion.projectedScore))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Projected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Score range and confidence
            HStack(spacing: 16) {
                ScoreRangeIndicator(
                    floor: suggestion.floor,
                    ceiling: suggestion.ceiling,
                    projected: suggestion.projectedScore
                )

                Spacer()

                ConfidenceMeter(
                    confidence: suggestion.confidence,
                    level: suggestion.confidenceLevel
                )
            }

            // Fixture analysis (if available)
            if let fixture = suggestion.fixture {
                FixtureInfoCard(fixture: fixture)
            }

            // Reasoning preview
            Text(suggestion.reasoning)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // Quick captain actions
            HStack(spacing: 12) {
                Button(action: {
                    onTap()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle")
                        Text("Details")
                    }
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                }

                Spacer()

                if !isCurrentCaptain {
                    Button(action: {
                        impactFeedback.impactOccurred()
                        showingCaptainConfirmation = true
                    }) {
                        HStack(spacing: 4) {
                            if isSettingCaptain {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "star.fill")
                                Text("Set Captain")
                            }
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                    }
                    .disabled(isSettingCaptain)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                        Text("Current Captain")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .alert("Set Captain", isPresented: $showingCaptainConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Set Captain") {
                setCaptain()
            }
        } message: {
            Text("Set \(suggestion.player) as your captain? This will replace your current captain selection.")
        }
    }

    private func positionColor(_ position: String) -> Color {
        switch position {
        case "DEF": .blue
        case "MID": .green
        case "RUC": .purple
        case "FWD": .red
        default: .gray
        }
    }

    private var isCurrentCaptain: Bool {
        // Placeholder - would check against actual current captain when available
        false
    }

    private func setCaptain() {
        isSettingCaptain = true

        Task {
            do {
                try await dataService.setCaptain(playerName: suggestion.player)

                await MainActor.run {
                    isSettingCaptain = false
                    // Provide haptic feedback on success
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)
                }
            } catch {
                await MainActor.run {
                    isSettingCaptain = false
                    // Provide haptic feedback on error
                    let errorFeedback = UINotificationFeedbackGenerator()
                    errorFeedback.notificationOccurred(.error)
                }
            }
        }
    }
}

// MARK: - ScoreRangeIndicator

struct ScoreRangeIndicator: View {
    let floor: Double
    let ceiling: Double
    let projected: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Range")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                VStack(spacing: 2) {
                    Text(String(format: "%.0f", floor))
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("Floor")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 40, height: 4)
                    .cornerRadius(2)
                    .overlay(
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 8, height: 8)
                            .offset(x: rangePosition)
                    )

                VStack(spacing: 2) {
                    Text(String(format: "%.0f", ceiling))
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("Ceiling")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var rangePosition: CGFloat {
        let range = ceiling - floor
        let position = projected - floor
        return CGFloat((position / range) * 32 - 16) // 40 - 8 = 32 for dot movement
    }
}

// MARK: - ConfidenceMeter

struct ConfidenceMeter: View {
    let confidence: Double
    let level: String

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("Confidence")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 4) {
                Text(String(format: "%.0f%%", confidence * 100))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(confidenceColor)

                Circle()
                    .fill(confidenceColor)
                    .frame(width: 8, height: 8)
            }

            Text(level)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    private var confidenceColor: Color {
        switch confidence {
        case 0.8...: .green
        case 0.7 ..< 0.8: .yellow
        case 0.6 ..< 0.7: .orange
        default: .red
        }
    }
}

// MARK: - FixtureInfoCard

struct FixtureInfoCard: View {
    let fixture: FixtureAnalysis

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("vs \(fixture.opponent)")
                    .font(.caption)
                    .fontWeight(.medium)

                Text(fixture.venue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            DifficultyBadge(difficulty: fixture.difficulty)

            if let vulnerability = fixture.defensiveVulnerability {
                VStack(spacing: 2) {
                    Text(String(format: "%.1f", vulnerability))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)

                    Text("DEF↓")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - DifficultyBadge

struct DifficultyBadge: View {
    let difficulty: String

    var body: some View {
        Text(difficulty)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(difficultyColor)
            .cornerRadius(4)
    }

    private var difficultyColor: Color {
        switch difficulty.lowercased() {
        case "easy": .green
        case "medium": .yellow
        case "hard": .orange
        case "very hard": .red
        default: .gray
        }
    }
}

// MARK: - PlayerAnalysisDetailView

struct PlayerAnalysisDetailView: View {
    let analysis: CaptainSuggestionAnalysis
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Player header
                    PlayerAnalysisHeader(analysis: analysis)

                    // Detailed metrics
                    PlayerMetricsSection(analysis: analysis)

                    // Fixture analysis
                    if let fixture = analysis.fixture {
                        FixtureAnalysisSection(fixture: fixture)
                    }

                    // AI Reasoning
                    ReasoningSection(reasoning: analysis.reasoning)
                }
                .padding()
            }
            .navigationTitle(analysis.player)
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

// MARK: - PlayerAnalysisHeader

struct PlayerAnalysisHeader: View {
    let analysis: CaptainSuggestionAnalysis

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(analysis.player)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                HStack(spacing: 12) {
                    Text(analysis.team)
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text(analysis.position)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor)
                        .cornerRadius(6)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.1f", analysis.projectedScore))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)

                Text("Projected Score")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - PlayerMetricsSection

struct PlayerMetricsSection: View {
    let analysis: CaptainSuggestionAnalysis

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Metrics")
                .font(.headline)
                .fontWeight(.semibold)

            HStack(spacing: 20) {
                MetricItem(
                    title: "Floor",
                    value: String(format: "%.1f", analysis.floor),
                    color: .red
                )

                MetricItem(
                    title: "Projected",
                    value: String(format: "%.1f", analysis.projectedScore),
                    color: .accentColor
                )

                MetricItem(
                    title: "Ceiling",
                    value: String(format: "%.1f", analysis.ceiling),
                    color: .green
                )
            }

            ConfidenceIndicator(confidence: analysis.confidence)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - MetricItem

struct MetricItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - ConfidenceIndicator

struct ConfidenceIndicator: View {
    let confidence: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Confidence Level")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text(String(format: "%.0f%%", confidence * 100))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
            }

            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.accentColor)
                            .frame(width: geometry.size.width * CGFloat(confidence), height: 8),
                        alignment: .leading
                    )
            }
            .frame(height: 8)
        }
    }
}

// MARK: - FixtureAnalysisSection

struct FixtureAnalysisSection: View {
    let fixture: FixtureAnalysis

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fixture Analysis")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                FixtureDetailRow(title: "Opponent", value: fixture.opponent)
                FixtureDetailRow(title: "Venue", value: fixture.venue)
                FixtureDetailRow(title: "Difficulty", value: fixture.difficulty)

                if let vulnerability = fixture.defensiveVulnerability {
                    FixtureDetailRow(
                        title: "Defensive Vulnerability",
                        value: String(format: "%.1f/10", vulnerability)
                    )
                }

                if let weather = fixture.weatherImpact {
                    FixtureDetailRow(title: "Weather Impact", value: weather)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - FixtureDetailRow

struct FixtureDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - ReasoningSection

struct ReasoningSection: View {
    let reasoning: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Analysis")
                .font(.headline)
                .fontWeight(.semibold)

            Text(reasoning)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Preview

#Preview {
    CaptainAnalysisView()
        .environmentObject(AFLFantasyToolsClient())
        .environmentObject(AFLFantasyDataService())
}
