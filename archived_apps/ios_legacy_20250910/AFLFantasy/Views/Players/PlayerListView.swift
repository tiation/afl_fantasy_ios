import SwiftUI

// MARK: - PlayerListView

struct PlayerListView: View {
    @EnvironmentObject var appState: LiveAppState
    @State private var sortOption: PlayerSortOption = .averageScore
    @State private var searchText = ""
    @State private var selectedPosition: Position?
    @State private var showFilters = false
    @State private var selectedPlayers = Set<UUID>()
    @State private var showingPlayerDetails: EnhancedPlayer?

    private var filteredPlayers: [EnhancedPlayer] {
        var result = appState.players

        // Apply position filter
        if let position = selectedPosition {
            result = result.filter { $0.position == position }
        }

        // Apply search
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }

        // Apply sorting
        result = result.sorted { p1, p2 in
            switch sortOption {
            case .price:
                return p1.price > p2.price
            case .averageScore:
                return p1.averageScore > p2.averageScore
            case .projection:
                return p1.nextRoundProjection.projectedScore > p2.nextRoundProjection.projectedScore
            case .consistency:
                return p1.consistency > p2.consistency
            case .value:
                let value1 = p1.averageScore / Double(p1.price)
                let value2 = p2.averageScore / Double(p2.price)
                return value1 > value2
            }
        }

        return result
    }

    var body: some View {
        NavigationView {
            List {
                if !selectedPlayers.isEmpty {
                    Section {
                        SelectionActionsView(
                            selectedCount: selectedPlayers.count,
                            onClear: { selectedPlayers.removeAll() },
                            onTrade: { /* Handle trade */ }
                        )
                    }
                }

                ForEach(filteredPlayers) { player in
                    PlayerRow(
                        player: player,
                        isSelected: selectedPlayers.contains(UUID(uuidString: player.id) ?? UUID()),
                        onSelect: { isSelected in
                            let id = UUID(uuidString: player.id) ?? UUID()
                            if isSelected {
                                selectedPlayers.insert(id)
                            } else {
                                selectedPlayers.remove(id)
                            }
                        }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingPlayerDetails = player
                    }
                }
            }
            .navigationTitle("Players")
            .searchable(text: $searchText, prompt: "Search players")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(PlayerSortOption.allCases, id: \.rawValue) { option in
                            Button {
                                sortOption = option
                            } label: {
                                Label(
                                    option.rawValue,
                                    systemImage: sortOption == option ? "checkmark" : ""
                                )
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .symbolVariant(showFilters ? .fill : .none)
                    }
                }
            }
            .sheet(item: $showingPlayerDetails) { player in
                NavigationView {
                    PlayerDetailsView(player: player)
                }
            }
            .overlay(alignment: .top) {
                if showFilters {
                    PositionFilterBar(
                        selectedPosition: $selectedPosition,
                        playerCounts: positionCounts
                    )
                    .transition(.move(edge: .top))
                }
            }
            .animation(.spring(), value: showFilters)
        }
    }

    private var positionCounts: [Position: Int] {
        var counts: [Position: Int] = [:]
        for player in appState.players {
            counts[player.position, default: 0] += 1
        }
        return counts
    }
}

// MARK: - SelectionActionsView

struct SelectionActionsView: View {
    let selectedCount: Int
    let onClear: () -> Void
    let onTrade: () -> Void

    var body: some View {
        HStack {
            Text("\(selectedCount) selected")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Button(role: .destructive, action: onClear) {
                Text("Clear")
            }

            Button(action: onTrade) {
                Text("Trade")
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - PositionFilterBar

struct PositionFilterBar: View {
    @Binding var selectedPosition: Position?
    let playerCounts: [Position: Int]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All",
                    count: playerCounts.values.reduce(0, +),
                    isSelected: selectedPosition == nil,
                    color: .gray
                ) {
                    selectedPosition = nil
                }

                ForEach(Position.allCases, id: \.self) { position in
                    FilterChip(
                        title: position.rawValue,
                        count: playerCounts[position, default: 0],
                        isSelected: selectedPosition == position,
                        color: position.color
                    ) {
                        selectedPosition = position
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
    }
}

// MARK: - FilterChip

struct FilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Text("\(count)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? color.opacity(0.2) : Color(.systemGray6))
            .foregroundColor(isSelected ? color : .primary)
            .cornerRadius(8)
        }
    }
}

// MARK: - PlayerRow

struct PlayerRow: View {
    let player: EnhancedPlayer
    let isSelected: Bool
    let onSelect: (Bool) -> Void

    var body: some View {
        HStack {
            Toggle(isOn: Binding(
                get: { isSelected },
                set: { onSelect($0) }
            )) {
                EmptyView()
            }
            .toggleStyle(.circle)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(player.name)
                        .font(.headline)

                    PositionBadge(position: player.position)
                }

                HStack(spacing: 8) {
                    StatBadge(
                        title: "AVG",
                        value: String(format: "%.1f", player.averageScore)
                    )

                    StatBadge(
                        title: "BE",
                        value: "\(player.breakeven)"
                    )

                    if player.isCashCow {
                        Text("💰")
                    }

                    if player.isDoubtful {
                        Text("⚠️")
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(player.formattedPrice)
                    .font(.headline)

                if player.priceChange != 0 {
                    PriceChangeLabel(change: player.priceChange)
                }
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - PositionBadge

struct PositionBadge: View {
    let position: Position

    var body: some View {
        Text(position.shortName)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(position.color)
            .cornerRadius(4)
    }
}

// MARK: - StatBadge

struct StatBadge: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)

            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

// MARK: - PriceChangeLabel

struct PriceChangeLabel: View {
    let change: Int

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
            Text("\(abs(change / 1000))k")
        }
        .font(.caption)
        .foregroundColor(change >= 0 ? .green : .red)
    }
}

// MARK: - Preview

#Preview {
    PlayerListView()
        .environmentObject(LiveAppState())
}
