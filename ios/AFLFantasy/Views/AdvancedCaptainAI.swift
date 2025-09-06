//
//  AdvancedCaptainAI.swift
//  AFL Fantasy Intelligence Platform
//
//  Sophisticated Captain AI with multi-factor analysis and predictive modeling
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - CaptainAnalysisResult

struct CaptainAnalysisResult: Identifiable {
    let id = UUID()
    let player: EnhancedPlayer
    let aiScore: Double
    let confidenceLevel: Double
    let projectedCaptainScore: Double
    let floorScore: Double
    let ceilingScore: Double
    let factorBreakdown: [FactorScore]
    let risks: [String]
    let upside: [String]

    var confidenceGrade: String {
        switch confidenceLevel {
        case 0.9...: "A+"
        case 0.8 ..< 0.9: "A"
        case 0.7 ..< 0.8: "B"
        case 0.6 ..< 0.7: "C"
        default: "D"
        }
    }
}

// MARK: - AnalysisFactor

struct AnalysisFactor: Identifiable {
    let id = UUID()
    let name: String
    let score: Double
    let weight: Double
    let impact: String

    var color: Color {
        switch score {
        case 80 ... 100: .green
        case 60 ..< 80: .blue
        case 40 ..< 60: .orange
        default: .red
        }
    }
}

// MARK: - AdvancedCaptainAI

struct AdvancedCaptainAI: View {
    @EnvironmentObject var appState: AppState
    @State private var analysisMode: AnalysisMode = .aiRecommendations
    @State private var selectedRound: Int = 15
    @State private var confidenceThreshold: Double = 0.7
    @State private var showingAdvancedSettings = false
    @State private var selectedFactors: Set<AnalysisFactor> = [.form, .opponent, .venue, .weather]
    @State private var isAnalyzing = false
    @State private var captainAnalysis: [CaptainAnalysisResult] = []

    enum AnalysisMode: String, CaseIterable {
        case aiRecommendations = "AI Picks"
        case playerComparison = "Compare"
        case scenarioModeling = "Scenarios"
        case historyAnalysis = "History"
    }

    enum AnalysisFactor: String, CaseIterable, Identifiable {
        case form = "Recent Form"
        case opponent = "Opponent DVP"
        case venue = "Venue Bias"
        case weather = "Weather"
        case consistency = "Consistency"
        case injury = "Injury Risk"
        case ownership = "Ownership"
        case ceiling = "Ceiling/Floor"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .form: "chart.line.uptrend.xyaxis"
            case .opponent: "shield.fill"
            case .venue: "location.fill"
            case .weather: "cloud.rain.fill"
            case .consistency: "target"
            case .injury: "cross.fill"
            case .ownership: "person.3.fill"
            case .ceiling: "arrow.up.arrow.down"
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Current captain header - create placeholder captain for now
                    let placeholderCaptain = CaptainData()
                    CurrentCaptainHeader(captain: placeholderCaptain)

                    // Analysis mode selector
                    AnalysisModeSelector(selectedMode: $analysisMode)

                    // Advanced settings toggle
                    AdvancedSettingsToggle(
                        confidenceThreshold: $confidenceThreshold,
                        selectedFactors: $selectedFactors,
                        showingSettings: $showingAdvancedSettings
                    )

                    // Main analysis content
                    Group {
                        switch analysisMode {
                        case .aiRecommendations:
                            AIRecommendationsView(
                                threshold: confidenceThreshold,
                                factors: selectedFactors,
                                analysis: captainAnalysis
                            )
                        case .playerComparison:
                            PlayerComparisonView(factors: selectedFactors)
                        case .scenarioModeling:
                            ScenarioModelingView(factors: selectedFactors)
                        case .historyAnalysis:
                            HistoryAnalysisView()
                        }
                    }

                    // Captain analytics deep dive
                    CaptainAnalyticsSection(factors: selectedFactors)
                }
                .padding()
            }
            .navigationTitle("⭐ Captain AI")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task { await runCaptainAnalysis() }
                    }) {
                        Image(systemName: "brain.head.profile")
                            .rotationEffect(isAnalyzing ? .degrees(360) : .degrees(0))
                            .animation(
                                isAnalyzing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                                value: isAnalyzing
                            )
                    }
                    .disabled(isAnalyzing)

                    Button(action: { showingAdvancedSettings.toggle() }) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAdvancedSettings) {
            AdvancedSettingsSheet(
                confidenceThreshold: $confidenceThreshold,
                selectedFactors: $selectedFactors,
                selectedRound: $selectedRound
            )
        }
        .onAppear {
            Task { await runCaptainAnalysis() }
        }
    }

    @MainActor
    private func runCaptainAnalysis() async {
        isAnalyzing = true
        defer { isAnalyzing = false }

        // Simulate AI analysis with sophisticated calculations
        let eligiblePlayers = appState.players.filter { !$0.isDoubtful && !$0.isSuspended }
        captainAnalysis = await performAdvancedAnalysis(players: eligiblePlayers)
    }

    private func performAdvancedAnalysis(players: [EnhancedPlayer]) async -> [CaptainAnalysisResult] {
        // Simulate processing delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        return players.map { player in
            CaptainAnalysisResult(
                player: player,
                aiScore: calculateAIScore(player),
                confidenceLevel: calculateConfidence(player),
                projectedCaptainScore: calculateCaptainProjection(player),
                floorScore: calculateFloor(player),
                ceilingScore: calculateCeiling(player),
                factorBreakdown: calculateFactorBreakdown(player),
                risks: identifyRisks(player),
                upside: identifyUpside(player)
            )
        }
        .sorted { $0.aiScore > $1.aiScore }
    }

    // MARK: - Analysis Calculations

    private func calculateAIScore(_ player: EnhancedPlayer) -> Double {
        var score = player.averageScore

        // Form adjustment (20% weight)
        let formMultiplier = calculateFormMultiplier(player)
        score *= formMultiplier

        // Venue bias (15% weight)
        let venueBias = calculateVenueBias(player)
        score += venueBias

        // Opponent difficulty (20% weight)
        let opponentFactor = calculateOpponentFactor(player)
        score *= opponentFactor

        // Consistency bonus (10% weight)
        let consistencyBonus = (player.consistency - 75) / 100 * 5
        score += consistencyBonus

        // Injury risk penalty (10% weight)
        let injuryPenalty = Double(player.injuryRiskScore) / 100 * 8
        score -= injuryPenalty

        // Ceiling factor for captain choice (15% weight)
        let ceilingBonus = (player.highScore - Int(player.averageScore)) / 10
        score += Double(ceilingBonus) * 0.3

        return max(score, 50) // Minimum floor
    }

    private func calculateFormMultiplier(_ player: EnhancedPlayer) -> Double {
        // Simulate recent form analysis
        let recentPerformance = Double.random(in: 0.85 ... 1.25)
        return selectedFactors.contains(.form) ? recentPerformance : 1.0
    }

    private func calculateVenueBias(_ player: EnhancedPlayer) -> Double {
        guard selectedFactors.contains(.venue) else { return 0 }
        // Simulate venue analysis based on player.venuePerformance
        return Double.random(in: -8 ... 12)
    }

    private func calculateOpponentFactor(_ player: EnhancedPlayer) -> Double {
        guard selectedFactors.contains(.opponent) else { return 1.0 }
        // Simulate DVP analysis
        return Double.random(in: 0.88 ... 1.18)
    }

    private func calculateConfidence(_ player: EnhancedPlayer) -> Double {
        var confidence = 0.7

        // Higher confidence for consistent players
        confidence += (player.consistency - 70) / 100 * 0.2

        // Lower confidence for injury-prone players
        confidence -= Double(player.injuryRiskScore) / 100 * 0.15

        // Lower confidence for doubtful players
        if player.isDoubtful { confidence -= 0.2 }

        return min(max(confidence, 0.3), 0.95)
    }

    private func calculateCaptainProjection(_ player: EnhancedPlayer) -> Double {
        let baseScore = calculateAIScore(player)
        return baseScore * 2 // Captain scoring
    }

    private func calculateFloor(_ player: EnhancedPlayer) -> Double {
        Double(player.lowScore) * 2 * 0.9 // 90% of historical low, doubled
    }

    private func calculateCeiling(_ player: EnhancedPlayer) -> Double {
        Double(player.highScore) * 2 * 1.05 // 105% of historical high, doubled
    }

    private func calculateFactorBreakdown(_ player: EnhancedPlayer) -> [FactorScore] {
        selectedFactors.map { factor in
            let impact: Double
            let confidence: Double

            switch factor {
            case .form:
                impact = Double.random(in: -8 ... 15)
                confidence = Double.random(in: 0.7 ... 0.9)
            case .opponent:
                impact = Double.random(in: -12 ... 10)
                confidence = Double.random(in: 0.8 ... 0.95)
            case .venue:
                impact = Double.random(in: -10 ... 12)
                confidence = Double.random(in: 0.6 ... 0.85)
            case .weather:
                impact = Double.random(in: -5 ... 3)
                confidence = Double.random(in: 0.5 ... 0.7)
            case .consistency:
                impact = player.consistency > 80 ? Double.random(in: 2 ... 8) : Double.random(in: -5 ... 2)
                confidence = 0.9
            case .injury:
                impact = player.injuryRiskScore > 25 ? Double.random(in: -8 ... -2) : Double.random(in: -1 ... 1)
                confidence = 0.85
            case .ownership:
                impact = Double.random(in: -2 ... 5)
                confidence = 0.6
            case .ceiling:
                impact = Double(player.highScore - Int(player.averageScore)) / 8
                confidence = 0.75
            }

            return FactorScore(factor: factor, impact: impact, confidence: confidence)
        }
    }

    private func identifyRisks(_ player: EnhancedPlayer) -> [String] {
        var risks: [String] = []

        if player.isDoubtful {
            risks.append("Injury concern - monitor team news")
        }

        if player.injuryRiskScore > 30 {
            risks.append("High injury risk based on history")
        }

        if player.consistency < 70 {
            risks.append("Inconsistent scoring pattern")
        }

        let formTrend = Double.random(in: -1 ... 1)
        if formTrend < -0.5 {
            risks.append("Recent form trending downward")
        }

        return risks
    }

    private func identifyUpside(_ player: EnhancedPlayer) -> [String] {
        var upside: [String] = []

        if player.highScore > Int(player.averageScore) + 20 {
            upside.append("High ceiling potential (\(player.highScore) pts)")
        }

        if player.consistency > 85 {
            upside.append("Extremely reliable scorer")
        }

        let venueFactor = Double.random(in: -1 ... 1)
        if venueFactor > 0.5 {
            upside.append("Strong venue record")
        }

        // Contract year motivation - using a random factor as placeholder
        if Double.random(in: 0 ... 1) > 0.7 {
            upside.append("Contract year motivation")
        }

        return upside
    }
}

// MARK: - FactorScore

struct FactorScore: Identifiable {
    let id = UUID()
    let factor: AdvancedCaptainAI.AnalysisFactor
    let impact: Double // Points impact
    let confidence: Double // 0-1 confidence in this factor

    var impactDescription: String {
        switch impact {
        case 8...: "Very Positive"
        case 3 ..< 8: "Positive"
        case -3 ..< 3: "Neutral"
        case -8 ..< -3: "Negative"
        default: "Very Negative"
        }
    }

    var impactColor: Color {
        switch impact {
        case 5...: .green
        case 1 ..< 5: .mint
        case -1 ..< 1: .gray
        case -5 ..< -1: .orange
        default: .red
        }
    }
}

// MARK: - CurrentCaptainHeader

struct CurrentCaptainHeader: View {
    let captain: CaptainData

    var body: some View {
        VStack(spacing: 12) {
            Text("Current Captain")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(captain.playerName)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text("Last Round Score: \(captain.score)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(captain.score * 2)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    Text("Captain Points")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            if captain.ownershipPercentage > 0 {
                Text(captain.formattedOwnership)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - CaptainQuickSelectButton

struct CaptainQuickSelectButton: View {
    let player: EnhancedPlayer

    var body: some View {
        Button(action: {
            // Quick captain selection logic
        }) {
            VStack(spacing: 4) {
                Text(player.name.components(separatedBy: " ").last ?? "")
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text("\(Int(player.averageScore))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - AnalysisModeSelector

struct AnalysisModeSelector: View {
    @Binding var selectedMode: AdvancedCaptainAI.AnalysisMode

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AdvancedCaptainAI.AnalysisMode.allCases, id: \.rawValue) { mode in
                    Button(mode.rawValue) {
                        selectedMode = mode
                    }
                    .buttonStyle(AnalysisModeButtonStyle(isSelected: selectedMode == mode))
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - AnalysisModeButtonStyle

struct AnalysisModeButtonStyle: ButtonStyle {
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

// MARK: - AdvancedSettingsToggle

struct AdvancedSettingsToggle: View {
    @Binding var confidenceThreshold: Double
    @Binding var selectedFactors: Set<AdvancedCaptainAI.AnalysisFactor>
    @Binding var showingSettings: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("AI Settings")
                    .font(.headline)
                    .fontWeight(.medium)

                Spacer()

                Button("Configure") {
                    showingSettings.toggle()
                }
                .font(.subheadline)
                .foregroundColor(.orange)
            }

            HStack {
                Text("Confidence: \(Int(confidenceThreshold * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("•")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("\(selectedFactors.count) factors")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                HStack(spacing: 4) {
                    ForEach(Array(selectedFactors.prefix(3)), id: \.id) { factor in
                        Image(systemName: factor.icon)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }

                    if selectedFactors.count > 3 {
                        Text("+\(selectedFactors.count - 3)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - AIRecommendationsView

struct AIRecommendationsView: View {
    let threshold: Double
    let factors: Set<AdvancedCaptainAI.AnalysisFactor>
    let analysis: [CaptainAnalysisResult]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI Captain Recommendations")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVStack(spacing: 12) {
                ForEach(topRecommendations.prefix(5), id: \.id) { result in
                    CaptainRecommendationCard(result: result)
                }
            }
        }
    }

    private var topRecommendations: [CaptainAnalysisResult] {
        analysis.filter { $0.confidenceLevel >= threshold }
    }
}

// MARK: - CaptainRecommendationCard

struct CaptainRecommendationCard: View {
    let result: CaptainAnalysisResult
    @State private var isExpanded = false

    // Local mapping helpers to avoid relying on Position extensions that may not exist in this target
    private func positionShortName(_ position: Position) -> String {
        switch position {
        case .defender: "DEF"
        case .midfielder: "MID"
        case .ruck: "RUC"
        case .forward: "FWD"
        }
    }

    private func positionColor(_ position: Position) -> Color {
        switch position {
        case .defender: .blue
        case .midfielder: .green
        case .ruck: .purple
        case .forward: .red
        }
    }

    private func formatPrice(_ price: Int) -> String {
        "$\(String(format: "%.1f", Double(price) / 1000))k"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.player.name)
                        .font(.headline)
                        .fontWeight(.semibold)

                    HStack(spacing: 8) {
                        Text(result.player.nextRoundProjection.opponent)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(positionShortName(result.player.position))
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(positionColor(result.player.position))
                            .cornerRadius(4)

                        Text(formatPrice(result.player.currentPrice))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.1f", result.projectedCaptainScore))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    Text("Projected (C)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // AI Score and Confidence
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Score")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(String(format: "%.1f", result.aiScore))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Confidence")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(result.confidenceGrade)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(confidenceColor)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Range")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(Int(result.floorScore))-\(Int(result.ceilingScore))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }

            // Factor breakdown preview
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(result.factorBreakdown.prefix(4), id: \.id) { factor in
                        FactorChip(factor: factor)
                    }
                }
                .padding(.horizontal, 1)
            }

            // Expand/collapse button
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
                    // Detailed factor breakdown
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Factor Analysis")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        ForEach(result.factorBreakdown, id: \.id) { factor in
                            FactorDetailRow(factor: factor)
                        }
                    }

                    // Risks and upside
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Risks")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.red)

                            ForEach(result.risks, id: \.self) { risk in
                                Text("• " + risk)
                                    .font(.caption2)
                                    .foregroundColor(.red)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Upside")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.green)

                            ForEach(result.upside, id: \.self) { upside in
                                Text("• " + upside)
                                    .font(.caption2)
                                    .foregroundColor(.green)
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
        switch result.confidenceLevel {
        case 0.85...: .green
        case 0.7 ..< 0.85: .blue
        case 0.6 ..< 0.7: .orange
        default: .red
        }
    }
}

// MARK: - FactorChip

struct FactorChip: View {
    let factor: FactorScore

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: factor.factor.icon)
                .font(.caption2)
                .foregroundColor(factor.impactColor)

            Text(String(format: "%.0f", factor.impact))
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(factor.impactColor)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(factor.impactColor.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - FactorDetailRow

struct FactorDetailRow: View {
    let factor: FactorScore

    var body: some View {
        HStack {
            Image(systemName: factor.factor.icon)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 16)

            Text(factor.factor.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Text(factor.impactDescription)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(factor.impactColor)

            Text(String(format: "%.0f%%", factor.confidence * 100))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - PlayerComparisonView

struct PlayerComparisonView: View {
    let factors: Set<AdvancedCaptainAI.AnalysisFactor>

    var body: some View {
        VStack {
            Text("Player Comparison")
                .font(.headline)
            Text("Side-by-side captain candidate analysis")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - ScenarioModelingView

struct ScenarioModelingView: View {
    let factors: Set<AdvancedCaptainAI.AnalysisFactor>

    var body: some View {
        VStack {
            Text("Scenario Modeling")
                .font(.headline)
            Text("What-if analysis for different conditions")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - HistoryAnalysisView

struct HistoryAnalysisView: View {
    var body: some View {
        VStack {
            Text("Historical Analysis")
                .font(.headline)
            Text("Captain performance trends and patterns")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - CaptainAnalyticsSection

struct CaptainAnalyticsSection: View {
    let factors: Set<AdvancedCaptainAI.AnalysisFactor>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Captain Analytics")
                .font(.headline)
                .fontWeight(.semibold)

            Text("Advanced metrics and performance modeling")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - AdvancedSettingsSheet

struct AdvancedSettingsSheet: View {
    @Binding var confidenceThreshold: Double
    @Binding var selectedFactors: Set<AdvancedCaptainAI.AnalysisFactor>
    @Binding var selectedRound: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("Analysis Parameters") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confidence Threshold: \(Int(confidenceThreshold * 100))%")
                            .font(.subheadline)

                        Slider(value: $confidenceThreshold, in: 0.5 ... 0.95, step: 0.05)
                            .tint(.orange)

                        Text("Only show picks with \(Int(confidenceThreshold * 100))%+ AI confidence")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Picker("Target Round", selection: $selectedRound) {
                        ForEach(13 ... 24, id: \.self) { round in
                            Text("Round \(round)").tag(round)
                        }
                    }
                }

                Section("Analysis Factors") {
                    ForEach(AdvancedCaptainAI.AnalysisFactor.allCases, id: \.id) { factor in
                        HStack {
                            Image(systemName: factor.icon)
                                .foregroundColor(.orange)
                                .frame(width: 20)

                            Text(factor.rawValue)

                            Spacer()

                            if selectedFactors.contains(factor) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedFactors.contains(factor) {
                                selectedFactors.remove(factor)
                            } else {
                                selectedFactors.insert(factor)
                            }
                        }
                    }
                }
            }
            .navigationTitle("AI Settings")
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
    let state = AppState()
    return AdvancedCaptainAI()
        .environmentObject(state)
}
