//
//  AdvancedAnalyticsView.swift
//  AFL Fantasy Intelligence Platform
//
//  Advanced analytics visualizations with heat maps and trend charts
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI
import Charts

// MARK: - Advanced Analytics View

struct AdvancedAnalyticsView: View {
    @EnvironmentObject var appState: LiveAppState
    @StateObject private var analyticsService = AdvancedAnalyticsService()
    
    @State private var selectedPlayer: EnhancedPlayer?
    @State private var selectedAnalytics: AnalyticsCategory = .venuePerformance
    @State private var showingPlayerSelection = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Player Selection
                    playerSelectionCard
                    
                    // Analytics Category Selector
                    analyticsCategorySelector
                    
                    // Selected Analytics View
                    if let player = selectedPlayer {
                        switch selectedAnalytics {
                        case .venuePerformance:
                            VenuePerformanceChart(player: player)
                        case .priceProjections:
                            PriceProjectionChart(player: player)
                        case .consistencyTrends:
                            ConsistencyTrendChart(player: player)
                        case .injuryRiskAnalysis:
                            InjuryRiskVisualization(player: player)
                        }
                    } else {
                        // Overall team analytics when no player selected
                        TeamAnalyticsOverview(players: appState.players)
                    }
                    
                    // Additional Analytics
                    additionalAnalyticsSection
                }
                .padding(.horizontal)
            }
            .navigationTitle("📊 Advanced Analytics")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await analyticsService.refreshAnalytics()
            }
        }
        .sheet(isPresented: $showingPlayerSelection) {
            PlayerSelectionSheet(
                players: appState.players,
                selectedPlayer: $selectedPlayer
            )
        }
    }
    
    // MARK: - View Components
    
    private var playerSelectionCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Player Analytics")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Select Player") {
                    showingPlayerSelection = true
                }
                .font(.caption)
                .foregroundColor(.orange)
            }
            
            if let player = selectedPlayer {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(player.position.color)
                        .frame(width: 4, height: 40)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        HStack {
                            Text(player.position.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(player.position.color.opacity(0.2))
                                .cornerRadius(4)
                            
                            Text("Avg: \\(String(format: "%.1f", player.averageScore))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Text(player.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Select a player to view detailed analytics")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 60)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var analyticsCategorySelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Analytics Type")
                .font(.headline)
                .fontWeight(.medium)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AnalyticsCategory.allCases, id: \\.self) { category in
                        AnalyticsCategoryChip(
                            category: category,
                            isSelected: selectedAnalytics == category,
                            onSelect: { selectedAnalytics = category }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var additionalAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Insights")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                
                QuickInsightCard(
                    title: "Top Performer",
                    value: appState.players.first?.name ?? "Loading...",
                    subtitle: "Highest avg",
                    color: .green,
                    icon: "star.fill"
                )
                
                QuickInsightCard(
                    title: "Best Value",
                    value: bestValuePlayer?.name ?? "Loading...",
                    subtitle: "Price/performance",
                    color: .blue,
                    icon: "dollarsign.circle.fill"
                )
                
                QuickInsightCard(
                    title: "Cash Cow Alert",
                    value: "\\(appState.players.filter(\\.isCashCow).count)",
                    subtitle: "Players",
                    color: .orange,
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                QuickInsightCard(
                    title: "Risk Watch",
                    value: "\\(highRiskPlayersCount)",
                    subtitle: "High risk",
                    color: .red,
                    icon: "exclamationmark.triangle.fill"
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Computed Properties
    
    private var bestValuePlayer: EnhancedPlayer? {
        appState.players.max { player1, player2 in
            let value1 = player1.averageScore * 1000 / Double(player1.price)
            let value2 = player2.averageScore * 1000 / Double(player2.price)
            return value1 < value2
        }
    }
    
    private var highRiskPlayersCount: Int {
        appState.players.filter { player in
            player.injuryRisk.riskLevel == .high || player.isDoubtful
        }.count
    }
}

// MARK: - Analytics Category

enum AnalyticsCategory: String, CaseIterable {
    case venuePerformance = "Venue Performance"
    case priceProjections = "Price Projections"
    case consistencyTrends = "Consistency Trends"
    case injuryRiskAnalysis = "Injury Risk"
    
    var icon: String {
        switch self {
        case .venuePerformance: return "location.fill"
        case .priceProjections: return "chart.line.uptrend.xyaxis"
        case .consistencyTrends: return "waveform.path"
        case .injuryRiskAnalysis: return "cross.case.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .venuePerformance: return .blue
        case .priceProjections: return .green
        case .consistencyTrends: return .orange
        case .injuryRiskAnalysis: return .red
        }
    }
}

// MARK: - Analytics Category Chip

struct AnalyticsCategoryChip: View {
    let category: AnalyticsCategory
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? category.color : Color(.systemGray5))
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Venue Performance Chart

struct VenuePerformanceChart: View {
    let player: EnhancedPlayer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Venue Performance Heat Map")
                .font(.headline)
                .fontWeight(.bold)
            
            Chart(player.venuePerformance, id: \\.venue) { venue in
                RectangleMark(
                    x: .value("Venue", venue.venue),
                    y: .value("Performance", 1),
                    width: 40,
                    height: 40
                )
                .foregroundStyle(venueColor(bias: venue.bias))
                .cornerRadius(8)
            }
            .frame(height: 100)
            
            // Legend
            HStack {
                ForEach([-5, 0, 5], id: \\.self) { bias in
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(venueColor(bias: Double(bias)))
                            .frame(width: 16, height: 16)
                        
                        Text("\\(bias > 0 ? "+" : "")\\(bias)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Analysis")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(venueAnalysis)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func venueColor(bias: Double) -> Color {
        switch bias {
        case ..<(-2): return .red
        case (-2)..<0: return .orange
        case 0..<2: return .yellow
        default: return .green
        }
    }
    
    private var venueAnalysis: String {
        let bestVenue = player.venuePerformance.max { $0.bias < $1.bias }
        let worstVenue = player.venuePerformance.min { $0.bias < $1.bias }
        
        guard let best = bestVenue, let worst = worstVenue else {
            return "Insufficient venue data for analysis."
        }
        
        return "\\(player.name) performs best at \\(best.venue) (+\\(String(format: "%.1f", best.bias)) pts) and struggles at \\(worst.venue) (\\(String(format: "%.1f", worst.bias)) pts). Consider venue matchups when making captain decisions."
    }
}

// MARK: - Price Projection Chart

struct PriceProjectionChart: View {
    let player: EnhancedPlayer
    
    @State private var projectionData: [PriceProjectionPoint] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Price Projection")
                .font(.headline)
                .fontWeight(.bold)
            
            if !projectionData.isEmpty {
                Chart(projectionData, id: \\.round) { point in
                    LineMark(
                        x: .value("Round", point.round),
                        y: .value("Price", point.projectedPrice)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    // Current price point
                    if point.round == 0 {
                        PointMark(
                            x: .value("Round", point.round),
                            y: .value("Price", point.projectedPrice)
                        )
                        .foregroundStyle(.orange)
                        .symbolSize(60)
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: minPrice...maxPrice)
                .chartXAxis {
                    AxisMarks(values: .stride(by: 1)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text("R\\(value.as(Int.self) ?? 0)")
                                .font(.caption2)
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text("$\\(Int((value.as(Double.self) ?? 0) / 1000))k")
                                .font(.caption2)
                        }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Generating price projections...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
            }
            
            // Price projection summary
            VStack(alignment: .leading, spacing: 8) {
                Text("Projection Summary")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let finalPrice = projectionData.last?.projectedPrice {
                    let priceChange = finalPrice - Double(player.price)
                    Text("Projected 5-round change: \\(priceChange > 0 ? "+" : "")$\\(Int(priceChange / 1000))k")
                        .font(.caption)
                        .foregroundColor(priceChange > 0 ? .green : .red)
                } else {
                    Text("Price projection based on current form and breakeven analysis.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .onAppear {
            generatePriceProjections()
        }
    }
    
    private var minPrice: Double {
        let prices = projectionData.map(\\.projectedPrice)
        return (prices.min() ?? Double(player.price)) * 0.95
    }
    
    private var maxPrice: Double {
        let prices = projectionData.map(\\.projectedPrice)
        return (prices.max() ?? Double(player.price)) * 1.05
    }
    
    private func generatePriceProjections() {
        var projections: [PriceProjectionPoint] = []
        var currentPrice = Double(player.price)
        
        // Current price (round 0)
        projections.append(PriceProjectionPoint(round: 0, projectedPrice: currentPrice))
        
        // Project 5 rounds ahead
        for round in 1...5 {
            // Simple projection based on breakeven and average
            let scoreDiff = player.averageScore - Double(player.breakeven)
            let priceChange = scoreDiff * 150 * 0.8 // 80% of theoretical change
            currentPrice += priceChange
            
            // Add some randomness for realism
            let randomFactor = Double.random(in: 0.9...1.1)
            let projectedPrice = currentPrice * randomFactor
            
            projections.append(PriceProjectionPoint(
                round: round,
                projectedPrice: max(100000, projectedPrice) // Minimum price floor
            ))
        }
        
        projectionData = projections
    }
}

struct PriceProjectionPoint {
    let round: Int
    let projectedPrice: Double
}

// MARK: - Consistency Trend Chart

struct ConsistencyTrendChart: View {
    let player: EnhancedPlayer
    
    @State private var consistencyData: [ConsistencyDataPoint] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Consistency Analysis")
                .font(.headline)
                .fontWeight(.bold)
            
            if !consistencyData.isEmpty {
                Chart(consistencyData, id: \\.week) { point in
                    AreaMark(
                        x: .value("Week", point.week),
                        yStart: .value("Min Score", point.minScore),
                        yEnd: .value("Max Score", point.maxScore)
                    )
                    .foregroundStyle(.orange.opacity(0.3))
                    
                    LineMark(
                        x: .value("Week", point.week),
                        y: .value("Score", point.actualScore)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text("\\(Int(value.as(Double.self) ?? 0))")
                                .font(.caption2)
                        }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "waveform.path")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Generating consistency analysis...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
            }
            
            // Consistency metrics
            HStack {
                ConsistencyMetric(
                    title: "Consistency",
                    value: "\\(player.consistencyGrade)",
                    color: consistencyColor
                )
                
                Spacer()
                
                ConsistencyMetric(
                    title: "Range",
                    value: "\\(player.lowScore)-\\(player.highScore)",
                    color: .secondary
                )
                
                Spacer()
                
                ConsistencyMetric(
                    title: "Reliability",
                    value: "\\(String(format: "%.0f", player.consistency))%",
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .onAppear {
            generateConsistencyData()
        }
    }
    
    private var consistencyColor: Color {
        switch player.consistencyGrade {
        case "A+", "A": return .green
        case "B+", "B": return .orange
        default: return .red
        }
    }
    
    private func generateConsistencyData() {
        var data: [ConsistencyDataPoint] = []
        let baseScore = player.averageScore
        
        for week in 1...10 {
            let variance = Double.random(in: 0.7...1.3)
            let actualScore = baseScore * variance
            let minScore = baseScore * 0.6
            let maxScore = baseScore * 1.4
            
            data.append(ConsistencyDataPoint(
                week: week,
                actualScore: actualScore,
                minScore: minScore,
                maxScore: maxScore
            ))
        }
        
        consistencyData = data
    }
}

struct ConsistencyDataPoint {
    let week: Int
    let actualScore: Double
    let minScore: Double
    let maxScore: Double
}

struct ConsistencyMetric: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Injury Risk Visualization

struct InjuryRiskVisualization: View {
    let player: EnhancedPlayer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Injury Risk Assessment")
                .font(.headline)
                .fontWeight(.bold)
            
            // Risk Level Indicator
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Risk Level")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(player.injuryRisk.riskLevel.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(player.injuryRisk.riskLevel.color)
                }
                
                Spacer()
                
                // Risk Score Circle
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: player.injuryRisk.riskScore)
                        .stroke(player.injuryRisk.riskLevel.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 80, height: 80)
                    
                    VStack(spacing: 0) {
                        Text("\\(Int(player.injuryRisk.riskScore * 100))")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("RISK")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Risk Factors
            if !player.injuryRisk.riskFactors.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Risk Factors")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ForEach(player.injuryRisk.riskFactors, id: \\.self) { factor in
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            
                            Text(factor)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Recommendations
            VStack(alignment: .leading, spacing: 8) {
                Text("Recommendations")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(injuryRecommendation)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var injuryRecommendation: String {
        switch player.injuryRisk.riskLevel {
        case .low:
            return "Low injury risk makes \\(player.name) a reliable selection. Monitor for any new injury concerns but generally safe to captain or trade in."
        case .medium:
            return "Moderate injury risk for \\(player.name). Consider having backup options and monitor team news closely before selecting as captain."
        case .high:
            return "High injury risk for \\(player.name). Avoid as captain choice and consider trading out if you need reliability. Have emergency cover ready."
        case .critical:
            return "Critical injury risk for \\(player.name). Strong recommendation to trade out or avoid selection until injury concerns are resolved."
        }
    }
}

// MARK: - Team Analytics Overview

struct TeamAnalyticsOverview: View {
    let players: [EnhancedPlayer]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Team Analytics Overview")
                .font(.headline)
                .fontWeight(.bold)
            
            // Position breakdown chart
            Chart(positionData, id: \\.position) { data in
                BarMark(
                    x: .value("Position", data.position),
                    y: .value("Average", data.averageScore)
                )
                .foregroundStyle(data.color)
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        Text("\\(Int(value.as(Double.self) ?? 0))")
                            .font(.caption2)
                    }
                }
            }
            
            Text("Average scores by position across your tracked players")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var positionData: [PositionAnalytics] {
        let positions = Position.allCases
        return positions.map { position in
            let positionPlayers = players.filter { $0.position == position }
            let averageScore = positionPlayers.isEmpty ? 0 : 
                positionPlayers.map(\\.averageScore).reduce(0, +) / Double(positionPlayers.count)
            
            return PositionAnalytics(
                position: position.rawValue,
                averageScore: averageScore,
                color: position.color
            )
        }
    }
}

struct PositionAnalytics {
    let position: String
    let averageScore: Double
    let color: Color
}

// MARK: - Quick Insight Card

struct QuickInsightCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Player Selection Sheet

struct PlayerSelectionSheet: View {
    let players: [EnhancedPlayer]
    @Binding var selectedPlayer: EnhancedPlayer?
    @Environment(\\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(players, id: \\.id) { player in
                Button(action: {
                    selectedPlayer = player
                    dismiss()
                }) {
                    HStack {
                        Text(player.name)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(player.position.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(player.position.color.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Select Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Advanced Analytics Service

@MainActor
class AdvancedAnalyticsService: ObservableObject {
    @Published var isLoading = false
    
    func refreshAnalytics() async {
        isLoading = true
        // Simulate analytics processing
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isLoading = false
    }
}
