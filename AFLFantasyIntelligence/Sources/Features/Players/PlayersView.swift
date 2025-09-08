import SwiftUI

struct PlayersView: View {
    @EnvironmentObject var apiService: APIService
    @StateObject private var viewModel = PlayersViewModel()
    @State private var searchText = ""
    @State private var selectedPosition: Position? = nil
    @State private var showingFilters = false
    
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
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
        }
        .searchable(text: $searchText, prompt: "Search players...")
    }
    
    // MARK: - Search and Filter Bar
    
    private var searchAndFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.s) {
                // All positions filter chip
                FilterChip(
                    title: "All",
                    isSelected: selectedPosition == nil
                ) {
                    selectedPosition = nil
                }
                
                // Position filter chips
                ForEach(Position.allCases, id: \.self) { position in
                    FilterChip(
                        title: position.shortName,
                        isSelected: selectedPosition == position
                    ) {
                        selectedPosition = selectedPosition == position ? nil : position
                    }
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
                    .listRowInsets(EdgeInsets(top: DS.Spacing.s, leading: DS.Spacing.l, bottom: DS.Spacing.s, trailing: DS.Spacing.l))
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
            
            DSButton("Refresh", style: .outline) {
                Task {
                    await viewModel.loadPlayers(apiService: apiService)
                }
            }
            .padding(.horizontal, DS.Spacing.xxxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Computed Properties
    
    private var filteredPlayers: [Player] {
        var players = viewModel.players
        
        // Filter by position
        if let selectedPosition = selectedPosition {
            players = players.filter { $0.position == selectedPosition }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            players = players.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.team.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort by projected score descending
        return players.sorted { $0.projected > $1.projected }
    }
}

// MARK: - Filter Chip

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

// MARK: - Player Row View

struct PlayerRowView: View {
    let player: Player
    
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
            }
        }
        .dsAccessibility(
            label: "\(player.name), \(player.position.displayName), \(player.team), Price \(player.price), Average \(Int(player.average)), Projected \(Int(player.projected))",
            traits: .button
        )
    }
}

// MARK: - Filters Sheet

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

// MARK: - View Model

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
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to load players: \(error)")
            
            // Use mock data as fallback for development
            #if DEBUG
            players = Player.mockPlayers
            #endif
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
