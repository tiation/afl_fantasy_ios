//
//  PlayerPickerView.swift
//  AFL Fantasy Intelligence Platform
//
//  Player selection interface for trades and team management
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - PlayerPickerView

struct PlayerPickerView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let mode: PickerMode
    let onSelection: (EnhancedPlayer) -> Void

    @State private var searchText = ""
    @State private var selectedPosition: Position?
    @State private var sortOption: SortOption = .score
    @State private var maxPrice: Double = 1_200_000

    enum PickerMode {
        case tradeOut
        case tradeIn
        case teamSelection

        var title: String {
            switch self {
            case .tradeOut: "Select Player to Trade Out"
            case .tradeIn: "Select Player to Trade In"
            case .teamSelection: "Select Player"
            }
        }

        var subtitle: String {
            switch self {
            case .tradeOut: "Choose from your current team"
            case .tradeIn: "Choose from all available players"
            case .teamSelection: "Choose any player"
            }
        }
    }

    enum SortOption: String, CaseIterable {
        case score = "Score"
        case price = "Price"
        case name = "Name"
        case value = "Value"

        var systemImage: String {
            switch self {
            case .score: "chart.bar.fill"
            case .price: "dollarsign.circle"
            case .name: "textformat.abc"
            case .value: "star.circle"
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header info
                VStack(spacing: 8) {
                    Text(mode.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    // Budget info for trade in
                    if mode == .tradeIn {
                        Text("Budget: $\(Int(maxPrice / 1000))k")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                .padding()

                // Search and filters
                PlayerSearchFilters(
                    searchText: $searchText,
                    selectedPosition: $selectedPosition,
                    sortOption: $sortOption,
                    maxPrice: $maxPrice,
                    showPriceFilter: mode == .tradeIn
                )

                // Player list
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredPlayers) { player in
                            PlayerPickerRow(
                                player: player,
                                mode: mode,
                                onSelect: {
                                    onSelection(player)
                                    dismiss()
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var availablePlayers: [EnhancedPlayer] {
        switch mode {
        case .tradeOut:
            appState.players // Current team players
        case .tradeIn, .teamSelection:
            // In production, this would fetch all AFL players
            // For demo, we'll use a mix of current and generated players
            generateAvailablePlayers()
        }
    }

    private var filteredPlayers: [EnhancedPlayer] {
        let filtered = availablePlayers.filter { player in
            // Search filter
            if !searchText.isEmpty {
                let matchesSearch = player.name.localizedCaseInsensitiveContains(searchText) ||
                    player.position.rawValue.localizedCaseInsensitiveContains(searchText)
                if !matchesSearch { return false }
            }

            // Position filter
            if let position = selectedPosition {
                if player.position != position { return false }
            }

            // Price filter for trade in
            if mode == .tradeIn {
                if Double(player.price) > maxPrice { return false }
            }

            return true
        }

        // Sort players
        return filtered.sorted { player1, player2 in
            switch sortOption {
            case .score:
                return player1.averageScore > player2.averageScore
            case .price:
                return player1.price > player2.price
            case .name:
                return player1.name < player2.name
            case .value:
                let value1 = player1.averageScore / Double(player1.price / 10000)
                let value2 = player2.averageScore / Double(player2.price / 10000)
                return value1 > value2
            }
        }
    }

    private func generateAvailablePlayers() -> [EnhancedPlayer] {
        // Generate some mock players for trade-in options
        let mockPlayers: [EnhancedPlayer] = [
            createMockPlayer(name: "Sam Walsh", position: .midfielder, price: 750_000, score: 112.4),
            createMockPlayer(name: "Clayton Oliver", position: .midfielder, price: 820_000, score: 115.2),
            createMockPlayer(name: "Christian Petracca", position: .midfielder, price: 790_000, score: 108.8),
            createMockPlayer(name: "Jeremy Cameron", position: .forward, price: 680_000, score: 95.6),
            createMockPlayer(name: "Tom Hawkins", position: .forward, price: 650_000, score: 88.3),
            createMockPlayer(name: "Nick Daicos", position: .defender, price: 580_000, score: 92.1),
            createMockPlayer(name: "Jordan Dawson", position: .defender, price: 620_000, score: 95.4)
        ]

        return (appState.players + mockPlayers).uniqued()
    }

    private func createMockPlayer(name: String, position: Position, price: Int, score: Double) -> EnhancedPlayer {
        EnhancedPlayer(
            id: UUID().uuidString,
            name: name,
            position: position,
            price: price,
            currentScore: Int(score + Double.random(in: -15 ... 15)),
            averageScore: score,
            breakeven: Int.random(in: 40 ... 80),
            consistency: Double.random(in: 0.7 ... 0.95),
            highScore: Int(score + Double.random(in: 15 ... 35)),
            lowScore: Int(score - Double.random(in: 15 ... 25)),
            priceChange: Int.random(in: -30000 ... 30000),
            isCashCow: price < 600_000,
            isDoubtful: Bool.random(),
            isSuspended: false,
            cashGenerated: price < 600_000 ? Int.random(in: 50000 ... 150_000) : 0,
            projectedPeakPrice: price + Int.random(in: -50000 ... 100_000),
            nextRoundProjection: RoundProjection(
                round: 15,
                opponent: ["Richmond", "Collingwood", "Geelong", "Sydney"].randomElement()!,
                venue: ["MCG", "Marvel Stadium", "Adelaide Oval"].randomElement()!,
                projectedScore: score + Double.random(in: -10 ... 10),
                confidence: Double.random(in: 0.6 ... 0.9),
                conditions: WeatherConditions(temperature: 18, rainProbability: 0.2, windSpeed: 15, humidity: 60)
            ),
            seasonProjection: SeasonProjection(
                projectedTotalScore: score * 20,
                projectedAverage: score,
                premiumPotential: Double.random(in: 0.6 ... 0.95)
            ),
            injuryRisk: InjuryRisk(
                riskLevel: [.low, .medium, .high].randomElement()!,
                riskScore: Double.random(in: 0.1 ... 0.4),
                riskFactors: []
            ),
            venuePerformance: [],
            alertFlags: []
        )
    }
}

// MARK: - PlayerSearchFilters

struct PlayerSearchFilters: View {
    @Binding var searchText: String
    @Binding var selectedPosition: Position?
    @Binding var sortOption: PlayerPickerView.SortOption
    @Binding var maxPrice: Double
    let showPriceFilter: Bool

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

            // Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Position filter
                    Menu {
                        Button("All Positions") {
                            selectedPosition = nil
                        }

                        ForEach(Position.allCases, id: \.rawValue) { position in
                            Button(position.rawValue) {
                                selectedPosition = position
                            }
                        }
                    } label: {
                        FilterChip(
                            title: selectedPosition?.rawValue ?? "Position",
                            isSelected: selectedPosition != nil,
                            icon: "person.3.fill"
                        )
                    }

                    // Sort filter
                    Menu {
                        ForEach(PlayerPickerView.SortOption.allCases, id: \.rawValue) { option in
                            Button(action: { sortOption = option }) {
                                HStack {
                                    Image(systemName: option.systemImage)
                                    Text(option.rawValue)
                                }
                            }
                        }
                    } label: {
                        FilterChip(
                            title: "Sort: \(sortOption.rawValue)",
                            isSelected: true,
                            icon: sortOption.systemImage
                        )
                    }

                    // Price filter (for trade in)
                    if showPriceFilter {
                        Menu {
                            Button("Under $500k") { maxPrice = 500_000 }
                            Button("Under $750k") { maxPrice = 750_000 }
                            Button("Under $1M") { maxPrice = 1_000_000 }
                            Button("All Prices") { maxPrice = 1_200_000 }
                        } label: {
                            FilterChip(
                                title: "$\(Int(maxPrice / 1000))k max",
                                isSelected: maxPrice < 1_200_000,
                                icon: "dollarsign.circle"
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - FilterChip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let icon: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(isSelected ? .white : .primary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isSelected ? Color.accentColor : Color(.systemGray5))
        .cornerRadius(16)
    }
}

// MARK: - PlayerPickerRow

struct PlayerPickerRow: View {
    let player: EnhancedPlayer
    let mode: PlayerPickerView.PickerMode
    let onSelect: () -> Void

    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        Button(action: {
            impactFeedback.impactOccurred()
            onSelect()
        }) {
            HStack(spacing: 12) {
                // Position indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(player.position.color)
                    .frame(width: 4, height: 50)

                // Player info
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    HStack(spacing: 8) {
                        Text(player.position.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(player.position.color.opacity(0.2))
                            .cornerRadius(4)

                        Text("Avg: \(Int(player.averageScore))")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if player.isDoubtful {
                            Text("⚠️")
                                .font(.caption)
                        }
                    }
                }

                Spacer()

                // Price and value
                VStack(alignment: .trailing, spacing: 4) {
                    Text(player.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("Value: \(valueRating)")
                        .font(.caption)
                        .foregroundColor(valueColor)
                }

                // Selection indicator
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(.plain)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var valueRating: String {
        let value = player.averageScore / Double(player.price / 10000)
        switch value {
        case 12...: "★★★"
        case 8 ..< 12: "★★☆"
        case 6 ..< 8: "★☆☆"
        default: "☆☆☆"
        }
    }

    private var valueColor: Color {
        let value = player.averageScore / Double(player.price / 10000)
        switch value {
        case 12...: .green
        case 8 ..< 12: .orange
        default: .red
        }
    }
}

// MARK: - Extensions

extension Array where Element: Identifiable {
    func uniqued() -> [Element] {
        var seen = Set<Element.ID>()
        return filter { seen.insert($0.id).inserted }
    }
}

// MARK: - Preview

#Preview {
    PlayerPickerView(mode: .tradeIn) { _ in }
        .environmentObject(AppState())
}
