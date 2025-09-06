//
//  PlayerPickerView.swift
//  AFL Fantasy Intelligence Platform
//
//  Player selection interface for trade calculator
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - PlayerPickerView

struct PlayerPickerView: View {
    let isSelectingOut: Bool
    @Binding var selectedPlayerOut: EnhancedPlayer?
    @Binding var selectedPlayerIn: EnhancedPlayer?
    @Binding var myTeamPlayers: [EnhancedPlayer]

    @Environment(\.dismiss) private var dismiss
    @StateObject private var playerService = PlayerSearchService()

    @State private var searchText = ""
    @State private var selectedPosition: Position? = nil
    @State private var priceRange: ClosedRange<Double> = 200_000 ... 800_000
    @State private var sortOption: PlayerSortOption = .price
    @State private var showingFilters = false

    // Native iOS Haptic Feedback
    private let selectionFeedback = UISelectionFeedbackGenerator()

    var filteredPlayers: [EnhancedPlayer] {
        let players = isSelectingOut ? myTeamPlayers : playerService.allPlayers

        return players
            .filter { player in
                // Search filter
                if !searchText.isEmpty {
                    return player.name.localizedCaseInsensitiveContains(searchText)
                }
                return true
            }
            .filter { player in
                // Position filter
                if let selectedPosition {
                    return player.position == selectedPosition
                }
                return true
            }
            .filter { player in
                // Price range filter
                Double(player.price) >= priceRange.lowerBound && Double(player.price) <= priceRange.upperBound
            }
            .sorted { player1, player2 in
                switch sortOption {
                case .price:
                    player1.price < player2.price
                case .score:
                    player1.currentScore > player2.currentScore
                case .average:
                    player1.averageScore > player2.averageScore
                case .name:
                    player1.name < player2.name
                case .value:
                    (Double(player1.currentScore) / Double(player1.price)) >
                        (Double(player2.currentScore) / Double(player2.price))
                }
            }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and filter section
                VStack(spacing: DesignSystem.Spacing.m.value) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)

                        TextField("Search players...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(DesignSystem.Spacing.m.value)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium.value)
                            .fill(DesignSystem.Colors.surfaceVariant)
                    )

                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignSystem.Spacing.s.value) {
                            // Position filters
                            ForEach(Position.allCases, id: \.self) { position in
                                FilterChip(
                                    title: position.rawValue,
                                    isSelected: selectedPosition == position,
                                    color: position.color
                                ) {
                                    selectedPosition = selectedPosition == position ? nil : position
                                    selectionFeedback.selectionChanged()
                                }
                            }

                            // Sort options
                            Menu {
                                ForEach(PlayerSortOption.allCases, id: \.self) { option in
                                    Button(option.displayName) {
                                        sortOption = option
                                        selectionFeedback.selectionChanged()
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.up.arrow.down")
                                    Text(sortOption.displayName)
                                }
                                .padding(.horizontal, DesignSystem.Spacing.m.value)
                                .padding(.vertical, DesignSystem.Spacing.s.value)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium.value)
                                        .fill(DesignSystem.Colors.primary.opacity(0.1))
                                )
                                .foregroundColor(DesignSystem.Colors.primary)
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.m.value)
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.m.value)
                .background(DesignSystem.Colors.surface)

                // Player list
                if filteredPlayers.isEmpty {
                    EmptyPlayerListView(searchText: searchText)
                } else {
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.s.value) {
                            ForEach(filteredPlayers) { player in
                                PlayerPickerRow(
                                    player: player,
                                    isOwned: myTeamPlayers.contains { $0.id == player.id },
                                    isSelected: isPlayerSelected(player)
                                ) {
                                    selectPlayer(player)
                                }
                            }
                        }
                        .padding(DesignSystem.Spacing.m.value)
                    }
                }
            }
            .navigationTitle(isSelectingOut ? "Trade Out" : "Trade In")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFilters.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                PlayerFiltersView(
                    priceRange: $priceRange,
                    selectedPosition: $selectedPosition,
                    sortOption: $sortOption
                )
            }
        }
        .onAppear {
            if !isSelectingOut {
                playerService.loadAllPlayers()
            }
        }
    }

    private func isPlayerSelected(_ player: EnhancedPlayer) -> Bool {
        if isSelectingOut {
            selectedPlayerOut?.id == player.id
        } else {
            selectedPlayerIn?.id == player.id
        }
    }

    private func selectPlayer(_ player: EnhancedPlayer) {
        selectionFeedback.selectionChanged()

        if isSelectingOut {
            selectedPlayerOut = player
        } else {
            selectedPlayerIn = player
        }

        dismiss()
    }
}

// MARK: - FilterChip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .typography(.caption1)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, DesignSystem.Spacing.m.value)
                .padding(.vertical, DesignSystem.Spacing.s.value)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium.value)
                        .fill(isSelected ? color : color.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - PlayerPickerRow

struct PlayerPickerRow: View {
    let player: EnhancedPlayer
    let isOwned: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.m.value) {
                // Position indicator
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small.value)
                    .fill(player.position.color)
                    .frame(width: 4, height: 60)

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs.value) {
                    HStack {
                        Text(player.name)
                            .typography(.bodyPrimary)

                        if isOwned {
                            Image(systemName: "person.crop.circle.fill")
                                .foregroundColor(DesignSystem.Colors.primary)
                                .font(.caption)
                        }

                        Spacer()
                    }

                    HStack(spacing: DesignSystem.Spacing.s.value) {
                        Text(player.position.rawValue)
                            .typography(.caption2)
                            .padding(.horizontal, DesignSystem.Spacing.xs.value)
                            .padding(.vertical, 2)
                            .background(player.position.color.opacity(0.2))
                            .cornerRadius(DesignSystem.CornerRadius.small.value)

                        Text(player.formattedPrice)
                            .typography(.caption1)
                            .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)

                        if player.priceChange != 0 {
                            HStack(spacing: 2) {
                                Image(systemName: player.priceChange > 0 ? "arrow.up" : "arrow.down")
                                    .font(.caption2)
                                Text("$\(abs(player.priceChange / 1000))k")
                                    .typography(.caption2)
                            }
                            .foregroundColor(player.priceChange > 0 ? DesignSystem.Colors.success : DesignSystem.Colors
                                .error
                            )
                        }
                    }

                    // Performance metrics
                    HStack(spacing: DesignSystem.Spacing.m.value) {
                        PlayerMetric(title: "Score", value: "\(player.currentScore)")
                        PlayerMetric(title: "Avg", value: "\(Int(player.averageScore))")
                        PlayerMetric(title: "BE", value: "\(player.breakeven)")

                        Spacer()

                        // Value indicator
                        let valueScore = Double(player.currentScore) / Double(player.price) * 1_000_000
                        PlayerMetric(
                            title: "Value",
                            value: String(format: "%.1f", valueScore),
                            color: valueScore > 50 ? DesignSystem.Colors.success :
                                valueScore > 30 ? DesignSystem.Colors.warning : DesignSystem.Colors.error
                        )
                    }
                }

                VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs.value) {
                    Text("\(player.currentScore)")
                        .typography(.title3)
                        .foregroundColor(DesignSystem.Colors.primary)

                    if player.nextRoundProjection.projectedScore > 0 {
                        Text("Proj: \(Int(player.nextRoundProjection.projectedScore))")
                            .typography(.caption2)
                            .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                    }
                }

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DesignSystem.Colors.success)
                        .font(.title2)
                }
            }
            .padding(DesignSystem.Spacing.m.value)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium.value)
                    .fill(isSelected ? DesignSystem.Colors.primary.opacity(0.05) : DesignSystem.Colors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium.value)
                    .stroke(
                        isSelected ? DesignSystem.Colors.primary :
                            isOwned ? DesignSystem.Colors.primary.opacity(0.3) : Color.clear,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - PlayerMetric

struct PlayerMetric: View {
    let title: String
    let value: String
    let color: Color?

    init(title: String, value: String, color: Color? = nil) {
        self.title = title
        self.value = value
        self.color = color
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .typography(.caption2)
                .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)

            Text(value)
                .typography(.caption1)
                .foregroundColor(color ?? DesignSystem.Colors.onSurface)
        }
    }
}

// MARK: - EmptyPlayerListView

struct EmptyPlayerListView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.l.value) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)

            VStack(spacing: DesignSystem.Spacing.s.value) {
                Text("No Players Found")
                    .typography(.headline)

                if !searchText.isEmpty {
                    Text("No players match '\(searchText)'")
                        .typography(.bodySecondary)
                        .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                } else {
                    Text("Try adjusting your filters")
                        .typography(.bodySecondary)
                        .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                }
            }
        }
        .padding(DesignSystem.Spacing.xl.value)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - PlayerFiltersView

struct PlayerFiltersView: View {
    @Binding var priceRange: ClosedRange<Double>
    @Binding var selectedPosition: Position?
    @Binding var sortOption: PlayerSortOption

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("Price Range") {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.s.value) {
                        HStack {
                            Text("$\(Int(priceRange.lowerBound / 1000))k")
                            Spacer()
                            Text("$\(Int(priceRange.upperBound / 1000))k")
                        }
                        .typography(.caption1)
                        .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)

                        // Note: In iOS 17+, you'd use RangedSliderStyle or custom implementation
                        Text("Price range filter - implement with dual thumb slider")
                            .typography(.caption2)
                            .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                    }
                }

                Section("Position") {
                    ForEach(Position.allCases, id: \.self) { position in
                        Button {
                            selectedPosition = selectedPosition == position ? nil : position
                        } label: {
                            HStack {
                                Circle()
                                    .fill(position.color)
                                    .frame(width: 12, height: 12)

                                Text(position.rawValue)
                                    .foregroundColor(DesignSystem.Colors.onSurface)

                                Spacer()

                                if selectedPosition == position {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(DesignSystem.Colors.primary)
                                }
                            }
                        }
                    }
                }

                Section("Sort By") {
                    ForEach(PlayerSortOption.allCases, id: \.self) { option in
                        Button {
                            sortOption = option
                        } label: {
                            HStack {
                                Text(option.displayName)
                                    .foregroundColor(DesignSystem.Colors.onSurface)

                                Spacer()

                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(DesignSystem.Colors.primary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden()
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

// MARK: - PlayerSortOption

enum PlayerSortOption: String, CaseIterable {
    case price
    case score
    case average
    case name
    case value

    var displayName: String {
        switch self {
        case .price: "Price"
        case .score: "Current Score"
        case .average: "Average"
        case .name: "Name"
        case .value: "Value"
        }
    }
}

// MARK: - PlayerSearchService

@MainActor
class PlayerSearchService: ObservableObject {
    @Published var allPlayers: [EnhancedPlayer] = []
    @Published var isLoading = false

    private let logger = AFLLogger.shared

    func loadAllPlayers() {
        guard allPlayers.isEmpty else { return }

        isLoading = true
        logger.info("🔍 Loading all players for selection")

        Task {
            await fetchAllPlayers()
            await MainActor.run {
                isLoading = false
            }
        }
    }

    private func fetchAllPlayers() async {
        // Simulate API call delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // In real implementation, this would fetch from AFL Fantasy API or repository
        let mockPlayers = generateMockPlayers()

        await MainActor.run {
            self.allPlayers = mockPlayers
            logger.info("✅ Loaded \(mockPlayers.count) players for selection")
        }
    }

    private func generateMockPlayers() -> [EnhancedPlayer] {
        // Generate a comprehensive list of mock players for demonstration
        // In production, this would come from the actual AFL Fantasy API
        [
            // Add more mock players as needed for testing
        ]
    }
}

// MARK: - Preview

#Preview {
    PlayerPickerView(
        isSelectingOut: false,
        selectedPlayerOut: .constant(nil),
        selectedPlayerIn: .constant(nil),
        myTeamPlayers: .constant([])
    )
}
