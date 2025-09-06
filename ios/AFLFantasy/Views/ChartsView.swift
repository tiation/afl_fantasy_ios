//
//  ChartsView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI
import Charts

// MARK: - Player Performance Chart

struct PlayerPerformanceChart: View {
    let player: EnhancedPlayer
    @State private var chartData: [ScoreDataPoint] = []
    @State private var selectedRange: ChartTimeRange = .last5Games
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Performance Trend")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Picker("Time Range", selection: $selectedRange) {
                    ForEach(ChartTimeRange.allCases, id: \.self) { range in
                        Text(range.displayName).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // Chart
            Chart(chartData) { dataPoint in
                LineMark(
                    x: .value("Round", dataPoint.round),
                    y: .value("Score", dataPoint.score)
                )
                .foregroundStyle(.orange)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                PointMark(
                    x: .value("Round", dataPoint.round),
                    y: .value("Score", dataPoint.score)
                )
                .foregroundStyle(.orange)
                .symbolSize(80)
                
                // Average line
                RuleMark(y: .value("Average", player.averageScore))
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .annotation(position: .trailing, alignment: .leading) {
                        Text("Avg: \(Int(player.averageScore))")
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .padding(4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    }
            }
            .frame(height: 200)
            .chartYScale(domain: 0...180)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5))
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .onAppear {
                generateChartData()
            }
            .onChange(of: selectedRange) { oldValue, newValue in
                generateChartData()
            }
            
            // Statistics
            HStack(spacing: 20) {
                StatCard(title: "Highest", value: "\(chartData.map(\.score).max() ?? 0)", color: .green)
                StatCard(title: "Lowest", value: "\(chartData.map(\.score).min() ?? 0)", color: .red)
                StatCard(title: "Trend", value: trendIndicator, color: trendColor)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func generateChartData() {
        // Generate mock data based on selected range
        let rounds = selectedRange.roundCount
        chartData = (1...rounds).map { round in
            let baseScore = player.averageScore
            let variance = Double.random(in: -30...40)
            let score = max(0, Int(baseScore + variance))
            return ScoreDataPoint(round: "R\(round)", score: score)
        }
    }
    
    private var trendIndicator: String {
        guard chartData.count >= 3 else { return "–" }
        let recent = Array(chartData.suffix(3))
        let trend = recent.last!.score - recent.first!.score
        return trend > 5 ? "↗" : trend < -5 ? "↘" : "→"
    }
    
    private var trendColor: Color {
        guard chartData.count >= 3 else { return .gray }
        let recent = Array(chartData.suffix(3))
        let trend = recent.last!.score - recent.first!.score
        return trend > 5 ? .green : trend < -5 ? .red : .gray
    }
}

// MARK: - Price Trend Chart

struct PriceTrendChart: View {
    let player: EnhancedPlayer
    @State private var priceData: [PriceDataPoint] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Price Trend")
                .font(.headline)
                .foregroundColor(.primary)
            
            Chart(priceData) { dataPoint in
                AreaMark(
                    x: .value("Round", dataPoint.round),
                    y: .value("Price", dataPoint.price)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.6), .blue.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                LineMark(
                    x: .value("Round", dataPoint.round),
                    y: .value("Price", dataPoint.price)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .frame(height: 150)
            .chartYScale(domain: (priceData.map(\.price).min() ?? 0)...(priceData.map(\.price).max() ?? 1000000))
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let price = value.as(Int.self) {
                            Text("$\(price/1000)k")
                                .font(.caption2)
                        }
                    }
                }
            }
            .onAppear {
                generatePriceData()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Price")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(player.formattedPrice)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Price Change")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(player.priceChangeText)
                        .font(.title3)
                        .bold()
                        .foregroundColor(player.priceChange >= 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func generatePriceData() {
        let currentPrice = player.price
        priceData = (1...10).map { round in
            let variation = Int.random(in: -50000...30000)
            let price = max(200000, currentPrice + variation * (11 - round))
            return PriceDataPoint(round: "R\(round)", price: price)
        }
    }
}

// MARK: - Ownership Chart

struct OwnershipChart: View {
    let player: EnhancedPlayer
    @State private var ownershipData: [OwnershipDataPoint] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ownership Breakdown")
                .font(.headline)
                .foregroundColor(.primary)
            
            Chart(ownershipData, id: \.category) { data in
                SectorMark(
                    angle: .value("Percentage", data.percentage),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(data.color)
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartLegend(position: .bottom, alignment: .center) {
                HStack(spacing: 16) {
                    ForEach(ownershipData, id: \.category) { data in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(data.color)
                                .frame(width: 8, height: 8)
                            Text("\(data.category): \(Int(data.percentage))%")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .onAppear {
                generateOwnershipData()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func generateOwnershipData() {
        let ownership = player.ownership
        ownershipData = [
            OwnershipDataPoint(category: "Owned", percentage: ownership, color: .orange),
            OwnershipDataPoint(category: "Available", percentage: 100 - ownership, color: .gray.opacity(0.3))
        ]
    }
}

// MARK: - Consistency Chart

struct ConsistencyChart: View {
    let player: EnhancedPlayer
    @State private var consistencyData: [ConsistencyDataPoint] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Score Consistency")
                .font(.headline)
                .foregroundColor(.primary)
            
            Chart(consistencyData) { dataPoint in
                BarMark(
                    x: .value("Range", dataPoint.scoreRange),
                    y: .value("Games", dataPoint.gameCount)
                )
                .foregroundStyle(dataPoint.color)
                .cornerRadius(4)
            }
            .frame(height: 150)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let count = value.as(Int.self) {
                            Text("\(count)")
                                .font(.caption2)
                        }
                    }
                }
            }
            .onAppear {
                generateConsistencyData()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Consistency Grade")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(player.consistencyGrade)
                        .font(.title2)
                        .bold()
                        .foregroundColor(consistencyColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Games 100+")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(consistencyData.last?.gameCount ?? 0)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func generateConsistencyData() {
        consistencyData = [
            ConsistencyDataPoint(scoreRange: "0-49", gameCount: Int.random(in: 1...3), color: .red),
            ConsistencyDataPoint(scoreRange: "50-79", gameCount: Int.random(in: 3...6), color: .orange),
            ConsistencyDataPoint(scoreRange: "80-99", gameCount: Int.random(in: 4...8), color: .yellow),
            ConsistencyDataPoint(scoreRange: "100+", gameCount: Int.random(in: 2...6), color: .green)
        ]
    }
    
    private var consistencyColor: Color {
        switch player.consistency {
        case 90...: return .green
        case 80..<90: return .blue
        case 70..<80: return .orange
        default: return .red
        }
    }
}

// MARK: - Data Models

struct ScoreDataPoint {
    let round: String
    let score: Int
}

struct PriceDataPoint {
    let round: String
    let price: Int
}

struct OwnershipDataPoint {
    let category: String
    let percentage: Double
    let color: Color
}

struct ConsistencyDataPoint {
    let scoreRange: String
    let gameCount: Int
    let color: Color
}

enum ChartTimeRange: CaseIterable {
    case last5Games, last10Games, season
    
    var displayName: String {
        switch self {
        case .last5Games: return "5 Games"
        case .last10Games: return "10 Games"
        case .season: return "Season"
        }
    }
    
    var roundCount: Int {
        switch self {
        case .last5Games: return 5
        case .last10Games: return 10
        case .season: return 22
        }
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .bold()
                .foregroundColor(color)
        }
        .padding(8)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            PlayerPerformanceChart(player: AppState().players.first!)
            PriceTrendChart(player: AppState().players.first!)
            OwnershipChart(player: AppState().players.first!)
            ConsistencyChart(player: AppState().players.first!)
        }
        .padding()
    }
}
