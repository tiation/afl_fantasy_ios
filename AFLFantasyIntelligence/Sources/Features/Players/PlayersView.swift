import SwiftUI

// MARK: - PlayersView

struct PlayersView: View {
    @EnvironmentObject var apiService: APIService
    @StateObject private var viewModel = PlayersViewModel()
    @StateObject private var prefs = UserPreferencesService.shared
    @State private var showingFilters = false
    @State private var showWatchlistOnly = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                searchAndFilterBar

                // Players List
                playersList
            }
            .navigationTitle("Players")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Compact API status chip
                    APIStatusChip()
                        .environmentObject(apiService)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityLabel("Filters")
                }
            }
            .refreshable {
                await viewModel.loadPlayers(apiService: apiService)
            }
            .sheet(isPresented: $showingFilters) {
                FiltersView(selectedPosition: $selectedPosition)
                    .presentationDetents([.medium])
            }
        }
        .task {
            await viewModel.loadPlayers(apiService: apiService)
            // Restore persisted filters
            // No-op here because prefs uses @AppStorage
        }
        .searchable(text: Binding(
            get: { prefs.searchText },
            set: { prefs.searchText = $0 }
        ), prompt: "Search players...")
    }

    // MARK: - Search and Filter Bar

    private var searchAndFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.s) {
                // All positions filter chip
                FilterChip(
                    title: "All",
                    isSelected: prefs.selectedPosition == nil
                ) {
                    prefs.selectedPosition = nil
                }

                // Position filter chips
                ForEach(Position.allCases, id: \.self) { position in
                    FilterChip(
                        title: position.shortName,
                        isSelected: prefs.selectedPosition == position
                    ) {
                        prefs.selectedPosition = (prefs.selectedPosition == position ? nil : position)
                    }
                }

                // Watchlist toggle chip
                FilterChip(
                    title: "Watchlist",
                    isSelected: showWatchlistOnly
                ) {
                    showWatchlistOnly.toggle()
                }
            }
            .padding(.horizontal, DS.Spacing.l)
        }
        .padding(.vertical, DS.Spacing.s)
    }

    // MARK: - Players List

    private var playersList: some View {
        List {
            ForEach(filteredPlayers) { player in
                PlayerRowView(player: player)
                    .listRowInsets(EdgeInsets(
                        top: DS.Spacing.s,
                        leading: DS.Spacing.l,
                        bottom: DS.Spacing.s,
                        trailing: DS.Spacing.l
                    ))
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading players...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(DS.Colors.surface.opacity(0.8))
            } else if filteredPlayers.isEmpty {
                emptyStateView
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: DS.Spacing.l) {
            Image(systemName: "person.3")
                .font(.system(size: 48))
                .foregroundColor(DS.Colors.onSurfaceVariant)

            Text("No players found")
                .font(DS.Typography.title3)
                .foregroundColor(DS.Colors.onSurface)

            Text("Try adjusting your search or filters")
                .font(DS.Typography.body)
                .foregroundColor(DS.Colors.onSurfaceSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: DS.Spacing.m) {
                DSButton("Reset Filters", style: .secondary) {
                    prefs.selectedPosition = nil
                    prefs.searchText = ""
                    showWatchlistOnly = false
                }
                DSButton("Refresh", style: .outline) {
                    Task {
                        await viewModel.loadPlayers(apiService: apiService)
                    }
                }
            }
            .padding(.horizontal, DS.Spacing.xxxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Computed Properties

    private var filteredPlayers: [Player] {
        var players = viewModel.players

        // Watchlist filter
        if showWatchlistOnly {
            let wl = prefs.watchlist
            players = players.filter { wl.contains($0.id) }
        }

        // Filter by position
        if let pos = prefs.selectedPosition {
            players = players.filter { $0.position == pos }
        }

        // Filter by search text
        if !prefs.searchText.isEmpty {
            players = players.filter {
                $0.name.localizedCaseInsensitiveContains(prefs.searchText) ||
                    $0.team.localizedCaseInsensitiveContains(prefs.searchText)
            }
        }

        // Sort by projected score descending (quick win)
        return players.sorted { $0.projected > $1.projected }
    }
}

// MARK: - FilterChip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DS.Typography.subheadline)
                .padding(.horizontal, DS.Spacing.m)
                .padding(.vertical, DS.Spacing.s)
                .background(
                    Capsule()
                        .fill(isSelected ? DS.Colors.primary : DS.Colors.surfaceSecondary)
                )
                .foregroundColor(isSelected ? .white : DS.Colors.onSurface)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - PlayerRowView

struct PlayerRowView: View {
    let player: Player
    @StateObject private var prefs = UserPreferencesService.shared

    private var playerAccessibilityLabel: String {
        let basicInfo = "\(player.name), \(player.position.displayName), \(player.team)"
        let priceInfo = "Price \(player.price)"
        let statsInfo = "Average \(Int(player.average)), Projected \(Int(player.projected))"
        return "\(basicInfo), \(priceInfo), \(statsInfo)"
    }

    var body: some View {
        DSCard(padding: DS.Spacing.m) {
            HStack(spacing: DS.Spacing.m) {
                // Position indicator
                Circle()
                    .fill(DS.Colors.positionColor(for: player.position))
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(player.name)
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.onSurface)

                    HStack {
                        Text(player.team)
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)

                        Text("•")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)

                        Text(player.position.displayName)
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.positionColor(for: player.position))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: DS.Spacing.xs) {
                    Text("$\(player.price.formatted())")
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.onSurface)

                    HStack(spacing: DS.Spacing.s) {
                        VStack(alignment: .center, spacing: 2) {
                            Text("\(Int(player.average))")
                                .font(DS.Typography.caption)
                                .foregroundColor(DS.Colors.onSurface)
                            Text("AVG")
                                .font(.system(size: 8))
                                .foregroundColor(DS.Colors.onSurfaceSecondary)
                        }

                        VStack(alignment: .center, spacing: 2) {
                            Text("\(Int(player.projected))")
                                .font(DS.Typography.caption)
                                .foregroundColor(DS.Colors.primary)
                            Text("PROJ")
                                .font(.system(size: 8))
                                .foregroundColor(DS.Colors.onSurfaceSecondary)
                        }

                        VStack(alignment: .center, spacing: 2) {
                            Text("\(player.breakeven)")
                                .font(DS.Typography.caption)
                                .foregroundColor(player.breakeven < 0 ? DS.Colors.success : DS.Colors.error)
                            Text("BE")
                                .font(.system(size: 8))
                                .foregroundColor(DS.Colors.onSurfaceSecondary)
                        }
                    }
                }

                // Watchlist star
                Button(action: { prefs.toggleWatchlist(player.id) }) {
                    Image(systemName: prefs.isInWatchlist(player.id) ? "star.fill" : "star")
                        .foregroundColor(prefs.isInWatchlist(player.id) ? DS.Colors.warning : DS.Colors.onSurfaceSecondary)
                        .dsMinimumHitTarget()
                }
                .buttonStyle(.plain)
                .accessibilityLabel(prefs.isInWatchlist(player.id) ? "Remove from watchlist" : "Add to watchlist")
            }
        }
        .dsAccessibility(
            label: playerAccessibilityLabel,
            traits: .isButton
        )
    }
}

// MARK: - FiltersView

struct FiltersView: View {
    @Binding var selectedPosition: Position?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: DS.Spacing.l) {
                VStack(alignment: .leading, spacing: DS.Spacing.m) {
                    Text("Position")
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.onSurface)

                    VStack(spacing: DS.Spacing.s) {
                        Button("All Positions") {
                            selectedPosition = nil
                        }
                        .foregroundColor(selectedPosition == nil ? DS.Colors.primary : DS.Colors.onSurface)

                        ForEach(Position.allCases, id: \.self) { position in
                            Button(position.displayName) {
                                selectedPosition = position
                            }
                            .foregroundColor(selectedPosition == position ? DS.Colors.primary : DS.Colors.onSurface)
                        }
                    }
                }

                Spacer()
            }
            .padding(DS.Spacing.l)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
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

// MARK: - PlayersViewModel

@MainActor
final class PlayersViewModel: ObservableObject {
    @Published var players: [Player] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadPlayers(apiService: APIService) async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let fetchedPlayers = try await apiService.fetchAllPlayers()
            players = fetchedPlayers
            print("✅ Loaded \(fetchedPlayers.count) players from API")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to load players: \(error)")
            
            // Try to fallback to mock data only if API is completely unreachable
            if players.isEmpty {
                players = Player.mockPlayers
                print("🔄 Using mock data fallback")
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
    struct PlayersView_Previews: PreviewProvider {
        static var previews: some View {
            PlayersView()
                .environmentObject(APIService.mock)
        }
    }

    struct PlayerRowView_Previews: PreviewProvider {
        static var previews: some View {
            VStack {
                PlayerRowView(player: Player.mockPlayers[0])
                PlayerRowView(player: Player.mockPlayers[1])
            }
            .padding()
        }
    }
#endif
