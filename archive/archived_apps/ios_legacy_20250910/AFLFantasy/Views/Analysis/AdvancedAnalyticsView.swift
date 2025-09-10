//
//  AdvancedAnalyticsView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//

import Charts
import SwiftUI

// MARK: - VenueData

struct VenueData: Identifiable {
    let id = UUID()
    let venue: String
    let score: Double
    let bias: Double
}

// MARK: - ChartData

struct ChartData: Identifiable {
    let id = UUID()
    let round: Int
    let score: Double
}

// MARK: - ConsistencyData

struct ConsistencyData: Identifiable {
    let id = UUID()
    let round: Int
    let score: Double
    let minScore: Double
    let maxScore: Double
}

// MARK: - AdvancedAnalyticsView

struct AdvancedAnalyticsView: View {
    @StateObject private var analyticsService = AnalyticsService()
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlayer: EnhancedPlayer?
    @State private var showingPlayerSelect = false
    @State private var chartData: [ChartData] = []
    @State private var venueData: [VenueData] = []
    @State private var consistencyData: [ConsistencyData] = []

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Player Select Card
                    PlayerSelectCard(
                        player: selectedPlayer,
                        onSelect: { showingPlayerSelect = true }
                    )

                    // Performance Chart
                    PerformanceChart(chartData: chartData)

                    // Venue Analysis
                    VenueAnalysisChart(venueData: venueData)

                    // Consistency Chart
                    ConsistencyChart(data: consistencyData)

                    // Quick Stats Grid
                    QuickStatsGrid(player: selectedPlayer)
                }
                .padding()
            }
            .navigationTitle("Advanced Analytics")
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
        .sheet(isPresented: $showingPlayerSelect) {
            PlayerSelectSheet(selectedPlayer: $selectedPlayer)
        }
        .onChange(of: selectedPlayer) { player in
            Task {
                if let player {
                    await loadPlayerData(player)
                }
            }
        }
        .task {
            // Load initial data
            if let player = selectedPlayer {
                await loadPlayerData(player)
            }
        }
    }

    private func loadPlayerData(_ player: EnhancedPlayer) async {
        // Performance chart data
        chartData = player.scores.enumerated().map { round, score in
            ChartData(round: round + 1, score: score)
        }

        // Venue data
        venueData = player.venueStats.map { venue, stats in
            VenueData(venue: venue, score: stats.avgScore, bias: stats.bias)
        }

        // Consistency data
        consistencyData = player.scores.enumerated().map { round, score in
            ConsistencyData(
                round: round + 1,
                score: score,
                minScore: max(0, score - score * 0.2),
                maxScore: score + score * 0.2
            )
        }
    }
}

// MARK: - PlayerSelectCard

struct PlayerSelectCard: View {
    let player: EnhancedPlayer?
    let onSelect: () -> Void

    var body: some View {
        VStack {
            HStack {
                Text("Select Player")
                    .font(.headline)
                Spacer()
                Button("Choose", action: onSelect)
            }

            if let player {
                HStack {
                    Text(player.name)
                        .font(.title2)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Avg: \(player.avgScore, specifier: "%.1f")")
                        Text(player.position)
                    }
                    .font(.caption)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            } else {
                Text("No player selected")
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - PerformanceChart

struct PerformanceChart: View {
    let chartData: [ChartData]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Score Progression")
                .font(.headline)

            Chart(chartData) { data in
                LineMark(
                    x: .value("Round", data.round),
                    y: .value("Score", data.score)
                )
                .foregroundStyle(.blue)

                PointMark(
                    x: .value("Round", data.round),
                    y: .value("Score", data.score)
                )
                .foregroundStyle(.blue)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
    }
}

// MARK: - VenueAnalysisChart

struct VenueAnalysisChart: View {
    let venueData: [VenueData]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Venue Analysis")
                .font(.headline)

            Chart(venueData) { data in
                BarMark(
                    x: .value("Venue", data.venue),
                    y: .value("Score", data.score)
                )
                .foregroundStyle(colorForBias(data.bias))
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
        }
    }

    private func colorForBias(_ bias: Double) -> Color {
        if bias > 5 {
            .green
        } else if bias < -5 {
            .red
        } else {
            .blue
        }
    }
}

// MARK: - ConsistencyChart

struct ConsistencyChart: View {
    let data: [ConsistencyData]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Consistency Range")
                .font(.headline)

            Chart(data) { point in
                AreaMark(
                    x: .value("Round", point.round),
                    yStart: .value("Min", point.minScore),
                    yEnd: .value("Max", point.maxScore)
                )
                .foregroundStyle(.blue.opacity(0.2))

                LineMark(
                    x: .value("Round", point.round),
                    y: .value("Score", point.score)
                )
                .foregroundStyle(.blue)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
    }
}

// MARK: - QuickStatsGrid

struct QuickStatsGrid: View {
    let player: EnhancedPlayer?

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]) {
            if let player {
                StatCard(
                    title: "High",
                    value: "\(Int(player.highScore))",
                    color: .green
                )
                StatCard(
                    title: "Average",
                    value: String(format: "%.1f", player.avgScore),
                    color: .blue
                )
                StatCard(
                    title: "Low",
                    value: "\(Int(player.lowScore))",
                    color: .red
                )
            }
        }
    }
}

// MARK: - PlayerSelectSheet

struct PlayerSelectSheet: View {
    @Binding var selectedPlayer: EnhancedPlayer?
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""

    var body: some View {
        NavigationView {
            List(filteredPlayers, id: \.id) { player in
                Button {
                    selectedPlayer = player
                    dismiss()
                } label: {
                    HStack {
                        Text(player.name)
                        Spacer()
                        Text(player.position)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Select Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Cancel") { dismiss() }
            }
        }
    }

    private var filteredPlayers: [EnhancedPlayer] {
        if searchText.isEmpty {
            players
        } else {
            players.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

// MARK: - AnalyticsService

@MainActor
class AnalyticsService: ObservableObject {
    @Published var isLoading = false

    func refreshData() async {
        isLoading = true
        // Add data refresh logic here
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isLoading = false
    }
}

// MARK: - Preview

#Preview {
    AdvancedAnalyticsView()
}
