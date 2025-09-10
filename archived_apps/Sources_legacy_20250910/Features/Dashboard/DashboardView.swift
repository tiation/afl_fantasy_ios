import SwiftUI

@available(iOS 15.0, *)
struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    @State private var showingFilters = false
    
    init(viewModel: DashboardViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DS.Spacing.l) {
                    // Summary Stats Section
                    summarySection
                    
                    // Quick Actions Section
                    quickActionsSection
                    
                    // Top Performers Section
                    topPerformersSection
                    
                    // Cash Cows Section
                    cashCowsSection
                    
                    // Captain Suggestions Section
                    captainSuggestionsSection
                    
                    // All Players Section
                    playersSection
                }
                .padding(.horizontal, DS.Spacing.l)
                .padding(.bottom, DS.Spacing.huge)
            }
            .navigationTitle("AFL Fantasy")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Filters") {
                        showingFilters = true
                    }
                    .foregroundColor(.aflPrimary)
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search players...")
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(isPresented: $showingFilters) {
                FiltersView(viewModel: viewModel)
            }
            .task {
                await viewModel.refresh()
            }
        }
    }
    
    // MARK: - Summary Section
    @ViewBuilder
    private var summarySection: some View {
        Card {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                Text("League Summary")
                    .font(.aflTitle2)
                    .foregroundColor(.textPrimary)
                
                switch viewModel.summaryState {
                case .idle, .loading:
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading summary...")
                            .font(.aflBody)
                            .foregroundColor(.textSecondary)
                    }
                    
                case .loaded(let summary):
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DS.Spacing.m) {
                        StatChip(title: "Total Players", value: "\(summary.totalPlayers)")
                        StatChip(title: "Teams", value: "\(summary.totalTeams)")
                        StatChip(title: "Avg Price", value: "$\(Int(summary.averagePrice / 1000))k")
                        StatChip(title: "Max Price", value: "$\(Int(summary.highestPrice / 1000))k")
                    }
                    
                case .error(let error):
                    ErrorView(message: error.localizedDescription) {
                        Task { await viewModel.loadSummary() }
                    }
                }
            }
        }
    }
    
    // MARK: - Quick Actions Section
    @ViewBuilder
    private var quickActionsSection: some View {
        Card {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                Text("Quick Actions")
                    .font(.aflTitle2)
                    .foregroundColor(.textPrimary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: DS.Spacing.s) {
                    PrimaryButton(title: "My Team") {
                        // Navigate to team view
                    }
                    
                    PrimaryButton(title: "Trades") {
                        // Navigate to trades view
                    }
                    
                    PrimaryButton(title: "Leagues") {
                        // Navigate to leagues view
                    }
                    
                    PrimaryButton(title: "Alerts") {
                        // Navigate to alerts view
                    }
                }
            }
        }
    }
    
    // MARK: - Top Performers Section
    @ViewBuilder
    private var topPerformersSection: some View {
        Card {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                HStack {
                    Text("Top Performers")
                        .font(.aflTitle2)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button("See All") {
                        // Navigate to full list
                    }
                    .font(.aflCaption)
                    .foregroundColor(.aflPrimary)
                }
                
                if viewModel.topPerformers.isEmpty {
                    Text("No data available")
                        .font(.aflBody)
                        .foregroundColor(.textSecondary)
                } else {
                    LazyVStack(spacing: DS.Spacing.s) {
                        ForEach(viewModel.topPerformers, id: \.id) { player in
                            PlayerRow(player: player, showDetail: true) {
                                // Navigate to player detail
                            }
                            
                            if player.id != viewModel.topPerformers.last?.id {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Cash Cows Section
    @ViewBuilder
    private var cashCowsSection: some View {
        Card {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                HStack {
                    Text("Cash Cows")
                        .font(.aflTitle2)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button("See All") {
                        // Navigate to full list
                    }
                    .font(.aflCaption)
                    .foregroundColor(.aflPrimary)
                }
                
                switch viewModel.cashCowsState {
                case .idle, .loading:
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading cash cows...")
                            .font(.aflBody)
                            .foregroundColor(.textSecondary)
                    }
                    
                case .loaded(let cashCows):
                    if cashCows.isEmpty {
                        Text("No cash cows found")
                            .font(.aflBody)
                            .foregroundColor(.textSecondary)
                    } else {
                        LazyVStack(spacing: DS.Spacing.s) {
                            ForEach(Array(cashCows.prefix(3)), id: \.id) { cow in
                                CashCowRow(cashCow: cow)
                                
                                if cow.id != cashCows.prefix(3).last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    
                case .error(let error):
                    ErrorView(message: error.localizedDescription) {
                        Task { await viewModel.loadCashCows() }
                    }
                }
            }
        }
    }
    
    // MARK: - Captain Suggestions Section
    @ViewBuilder
    private var captainSuggestionsSection: some View {
        Card {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                HStack {
                    Text("Captain Suggestions")
                        .font(.aflTitle2)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button("See All") {
                        // Navigate to full list
                    }
                    .font(.aflCaption)
                    .foregroundColor(.aflPrimary)
                }
                
                switch viewModel.captainSuggestionsState {
                case .idle, .loading:
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading suggestions...")
                            .font(.aflBody)
                            .foregroundColor(.textSecondary)
                    }
                    
                case .loaded(let suggestions):
                    if suggestions.isEmpty {
                        Text("No suggestions available")
                            .font(.aflBody)
                            .foregroundColor(.textSecondary)
                    } else {
                        LazyVStack(spacing: DS.Spacing.s) {
                            ForEach(Array(suggestions.prefix(3)), id: \.id) { suggestion in
                                CaptainSuggestionRow(suggestion: suggestion)
                                
                                if suggestion.id != suggestions.prefix(3).last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    
                case .error(let error):
                    ErrorView(message: error.localizedDescription) {
                        Task { await viewModel.loadCaptainSuggestions() }
                    }
                }
            }
        }
    }
    
    // MARK: - Players Section
    @ViewBuilder
    private var playersSection: some View {
        Card {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                HStack {
                    Text("All Players")
                        .font(.aflTitle2)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Text("\(viewModel.filteredPlayers.count) players")
                        .font(.aflCaption)
                        .foregroundColor(.textSecondary)
                }
                
                switch viewModel.playersState {
                case .idle:
                    Text("Tap to load players")
                        .font(.aflBody)
                        .foregroundColor(.textSecondary)
                    
                case .loading:
                    LoadingView(message: "Loading players...")
                    
                case .loaded:
                    if viewModel.filteredPlayers.isEmpty {
                        Text("No players match your filters")
                            .font(.aflBody)
                            .foregroundColor(.textSecondary)
                    } else {
                        LazyVStack(spacing: DS.Spacing.s) {
                            ForEach(Array(viewModel.filteredPlayers.prefix(10)), id: \.id) { player in
                                PlayerRow(player: player, showDetail: true) {
                                    // Navigate to player detail
                                }
                                
                                if player.id != viewModel.filteredPlayers.prefix(10).last?.id {
                                    Divider()
                                }
                            }
                        }
                        
                        if viewModel.filteredPlayers.count > 10 {
                            Button("View All \(viewModel.filteredPlayers.count) Players") {
                                // Navigate to full list
                            }
                            .font(.aflCallout)
                            .foregroundColor(.aflPrimary)
                            .padding(.top, DS.Spacing.s)
                        }
                    }
                    
                case .error(let error):
                    ErrorView(message: error.localizedDescription) {
                        Task { await viewModel.loadPlayers() }
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct CashCowRow: View {
    let cashCow: CashCow
    
    var body: some View {
        HStack(spacing: DS.Spacing.m) {
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(cashCow.name)
                    .font(.aflSubheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text("\(cashCow.team) • \(cashCow.position)")
                    .font(.aflCaption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: DS.Spacing.xs) {
                Text("$\(Int(cashCow.price / 1000))k")
                    .font(.aflSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text("+$\(Int(cashCow.potentialGain / 1000))k")
                    .font(.aflCaption)
                    .foregroundColor(.success)
            }
        }
    }
}

struct CaptainSuggestionRow: View {
    let suggestion: CaptainSuggestion
    
    var body: some View {
        HStack(spacing: DS.Spacing.m) {
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(suggestion.name)
                    .font(.aflSubheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text(suggestion.team)
                    .font(.aflCaption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: DS.Spacing.xs) {
                Text("\(Int(suggestion.projectedScore))")
                    .font(.aflSubheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text("\(Int(suggestion.confidence * 100))% confidence")
                    .font(.aflCaption)
                    .foregroundColor(.success)
            }
        }
    }
}

@available(iOS 15.0, *)
struct FiltersView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Position") {
                    Picker("Position", selection: $viewModel.selectedPosition) {
                        Text("All Positions").tag(nil as Position?)
                        ForEach(viewModel.availablePositions, id: \.self) { position in
                            Text(position.displayName).tag(position as Position?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Team") {
                    Picker("Team", selection: $viewModel.selectedTeam) {
                        Text("All Teams").tag(nil as String?)
                        ForEach(viewModel.availableTeams, id: \.self) { team in
                            Text(team).tag(team as String?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    Button("Clear All Filters") {
                        viewModel.clearFilters()
                    }
                    .foregroundColor(.aflPrimary)
                }
            }
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
