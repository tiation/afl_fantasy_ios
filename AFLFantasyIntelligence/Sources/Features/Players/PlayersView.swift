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
                FiltersView(
                    selectedPosition: Binding(
                        get: { prefs.selectedPosition },
                        set: { prefs.selectedPosition = $0 }
                    )
                )
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
    @State private var isPressed = false
    @State private var showingDetails = false

    private var playerAccessibilityLabel: String {
        let basicInfo = "\(player.name), \(player.position.displayName), \(player.team)"
        let priceInfo = "Price $\(player.price.formatted())"
        let statsInfo = "Average \(Int(player.average)), Projected \(Int(player.projected))"
        return "\(basicInfo), \(priceInfo), \(statsInfo)"
    }

    var body: some View {
        Button {
            showingDetails = true
        } label: {
            DSCard(style: .elevated, padding: DS.Spacing.l) {
                HStack(spacing: DS.Spacing.m) {
                    // Enhanced position indicator with gradient
                    ZStack {
                        Circle()
                            .fill(DS.Colors.positionGradient(for: player.position))
                            .frame(width: 40, height: 40)
                            .shadow(
                                color: DS.Colors.positionColor(for: player.position).opacity(0.3),
                                radius: 4,
                                x: 0,
                                y: 2
                            )
                        
                        Text(player.position.shortName)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text(player.name)
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.Colors.onSurface)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: DS.Spacing.xs) {
                            Text(player.team)
                                .font(DS.Typography.subheadline)
                                .foregroundColor(DS.Colors.onSurfaceSecondary)
                                .fontWeight(.medium)
                            
                            // Premium ownership indicator (mock)
                            if player.price > 600000 {
                                DSStatusBadge(text: "Premium", style: .custom(DS.Colors.accent))
                            } else if player.price < 350000 {
                                DSStatusBadge(text: "Rookie", style: .info)
                            }
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: DS.Spacing.s) {
                        Text("$\(player.price / 1000)K")
                            .font(DS.Typography.price)
                            .foregroundColor(DS.Colors.onSurface)
                            .fontWeight(.semibold)

                        HStack(spacing: DS.Spacing.s) {
                            EnhancedStatPill(
                                label: "AVG", 
                                value: "\(Int(player.average))",
                                color: DS.Colors.onSurface
                            )
                            
                            EnhancedStatPill(
                                label: "PROJ", 
                                value: "\(Int(player.projected))",
                                color: DS.Colors.primary,
                                isHighlighted: true
                            )
                            
                            EnhancedStatPill(
                                label: "BE", 
                                value: "\(player.breakeven)",
                                color: player.breakeven < 0 ? DS.Colors.success : DS.Colors.error
                            )
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0) { _ in
            // On press
        } onPressingChanged: { pressing in
            withAnimation(DS.Motion.springFast) {
                isPressed = pressing
            }
        }
        .overlay(alignment: .topTrailing) {
            // Watchlist star overlay
            Button(action: { 
                withAnimation(DS.Motion.spring) {
                    prefs.toggleWatchlist(player.id)
                }
            }) {
                Image(systemName: prefs.isInWatchlist(player.id) ? "star.fill" : "star")
                    .foregroundColor(prefs.isInWatchlist(player.id) ? DS.Colors.accent : DS.Colors.onSurfaceSecondary)
                    .font(.title3)
                    .dsMinimumHitTarget()
            }
            .buttonStyle(.plain)
            .accessibilityLabel(prefs.isInWatchlist(player.id) ? "Remove from watchlist" : "Add to watchlist")
            .offset(x: -8, y: 8)
        }
        .dsAccessibility(
            label: playerAccessibilityLabel,
            traits: .isButton
        )
        .sheet(isPresented: $showingDetails) {
            PlayerDetailView(player: player)
        }
    }
}

// MARK: - EnhancedStatPill

struct EnhancedStatPill: View {
    let label: String
    let value: String
    let color: Color
    let isHighlighted: Bool
    
    init(label: String, value: String, color: Color, isHighlighted: Bool = false) {
        self.label = label
        self.value = value
        self.color = color
        self.isHighlighted = isHighlighted
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(value)
                .font(DS.Typography.microStat)
                .foregroundColor(color)
                .fontWeight(isHighlighted ? .bold : .medium)
            
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(isHighlighted ? color : DS.Colors.onSurfaceVariant)
                .textCase(.uppercase)
        }
        .padding(.horizontal, DS.Spacing.xs)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: DS.CornerRadius.small)
                .fill(isHighlighted ? color.opacity(0.1) : Color.clear)
        )
        .frame(minWidth: 32)
    }
}

// MARK: - PlayerDetailView (Placeholder)

struct PlayerDetailView: View {
    let player: Player
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Player Details")
                    .font(DS.Typography.title)
                
                Text(player.name)
                    .font(DS.Typography.headline)
                    .padding()
                
                Text("Detailed stats and analysis would go here")
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Player Details")
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
