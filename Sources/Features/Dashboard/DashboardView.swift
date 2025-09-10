//
//  DashboardView.swift
//
//  Main dashboard with real AFL Fantasy data
//

import SwiftUI

@available(iOS 16.0, *)
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingTeamImport = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with API + Summary
                    apiStatusCard
                    if let summary = viewModel.summary {
                        summaryCards(summary)
                    }

                    // Quick actions
                    quickActionsSection

                    // Filters
                    filtersSection

                    // Players
                    playersSection

                    // Cash Cow Analysis
                    if !viewModel.cashCows.isEmpty { cashCowsSection }

                    // Captain Suggestions
                    if !viewModel.captainSuggestions.isEmpty { captainSuggestionsSection }
                }
                .padding()
            }
            .navigationTitle("AFL Fantasy AI")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Import Team") { showingTeamImport = true }
                }
            }
            .refreshable { await viewModel.refreshData() }
            .sheet(isPresented: $showingTeamImport) { TeamImportView() }
            .task { await viewModel.loadInitialData() }
            .overlay(alignment: .top) { errorBanner }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search players")
    }
    
    // MARK: - Header
    @ViewBuilder
    private var apiStatusCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("API Status")
                    .font(.headline)
                if let health = viewModel.apiHealth {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(health.status == "healthy" ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text(health.status.capitalized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    if let cached = viewModel.apiHealth?.playersCache {
                        Text("Cached: \(cached) players")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if let last = viewModel.apiHealth?.lastCacheUpdate {
                        Text("Updated: \(last.replacingOccurrences(of: "T", with: " "))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    HStack(spacing: 8) {
                        ProgressView().scaleEffect(0.8)
                        Text("Checking...")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
            }
            Spacer()
            Button { Task { await viewModel.checkAPIHealth() } } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func summaryCards(_ s: APIStatsResponse) -> some View {
        HStack(spacing: 12) {
            metricCard(title: "Players", value: "\(s.totalPlayers)", color: .blue)
            metricCard(title: "Rows", value: "\(s.totalDataRows)", color: .purple)
            metricCard(title: "OK", value: "\(s.successfulPlayers)", color: .green)
            metricCard(title: "Fail", value: "\(s.failedPlayers)", color: .red)
        }
    }

    private func metricCard(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Quick Actions
    @ViewBuilder
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ActionCard(
                    title: "Import Team",
                    subtitle: "Connect your AFL Fantasy",
                    icon: "square.and.arrow.down.fill",
                    color: .blue
                ) { showingTeamImport = true }
                ActionCard(
                    title: "Refresh Data",
                    subtitle: "Update player stats",
                    icon: "arrow.clockwise",
                    color: .green
                ) { Task { await viewModel.refreshData() } }
            }
        }
    }

    // MARK: - Filters
    @ViewBuilder
    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Picker("Position", selection: $viewModel.selectedPosition) {
                    Text("All").tag(Position?.none)
                    Text("DEF").tag(Position?.some(.defender))
                    Text("MID").tag(Position?.some(.midfielder))
                    Text("RUC").tag(Position?.some(.ruck))
                    Text("FWD").tag(Position?.some(.forward))
                }
                .pickerStyle(.segmented)

                Menu {
                    Picker("Sort by", selection: $viewModel.sort) {
                        ForEach(PlayerSort.allCases, id: \.self) { sort in
                            Label(sort.title, systemImage: sort.icon).tag(sort)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
        }
    }

    // MARK: - Players
    @ViewBuilder
    private var playersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Players")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.filteredPlayers.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Group {
                if viewModel.isLoading && viewModel.filteredPlayers.isEmpty {
                    ForEach(0..<5, id: \.self) { _ in
                        PlayerRow(player: .init(id: "", name: "Loading...", team: "--", position: .midfielder, price: 0, average: 0, projected: 0, breakeven: 0))
                            .redacted(reason: .placeholder)
                            .shimmer()
                    }
                } else if viewModel.filteredPlayers.isEmpty {
                    ContentUnavailableView("No players", systemImage: "person.2", description: Text("Try adjusting filters or search."))
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.filteredPlayers.prefix(20)) { player in
                            PlayerRow(player: player)
                                .background(Color.clear)
                        }
                        if viewModel.filteredPlayers.count > 20 {
                            Text("... and \(viewModel.filteredPlayers.count - 20) more players")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Cash Cows
    @ViewBuilder
    private var cashCowsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cash Cows Analysis")
                .font(.headline)
            LazyVStack(spacing: 8) {
                ForEach(viewModel.cashCows.prefix(5)) { CashCowRow(cashCow: $0) }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Captain Suggestions
    @ViewBuilder
    private var captainSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Captain Suggestions")
                .font(.headline)
            LazyVStack(spacing: 8) {
                ForEach(viewModel.captainSuggestions.prefix(3)) { CaptainSuggestionRow(suggestion: $0) }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Error Banner
    @ViewBuilder
    private var errorBanner: some View {
        if let err = viewModel.errorMessage {
            Text(err)
                .font(.footnote)
                .foregroundColor(.white)
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Supporting Views

@available(iOS 16.0, *)
struct PlayerRow: View {
    let player: Player
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(player.team) • \(player.position.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(player.price / 1000)K")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Avg: \(player.average, specifier: "%.1f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

@available(iOS 16.0, *)
struct CashCowRow: View {
    let cashCow: CashCowData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(cashCow.playerName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(cashCow.recommendation)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(cashCow.cashGenerated)K")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                
                if let confidence = cashCow.confidence {
                    Text("\(confidence * 100, specifier: "%.0f")% confidence")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

@available(iOS 16.0, *)
struct CaptainSuggestionRow: View {
    let suggestion: CaptainSuggestionResponse
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.playerName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(suggestion.reasoning)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(suggestion.recommendation)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                Text("\(suggestion.confidence * 100, specifier: "%.0f")%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

@available(iOS 16.0, *)
struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ViewModel

@available(iOS 16.0, *)
@MainActor
final class DashboardViewModel: ObservableObject {
    // Data
    @Published var players: [Player] = []
    @Published var cashCows: [CashCowData] = []
    @Published var captainSuggestions: [CaptainSuggestionResponse] = []
    @Published var apiHealth: APIHealthResponse?
    @Published var summary: APIStatsResponse?

    // UI State
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedPosition: Position? = nil
    @Published var searchText: String = ""
    @Published var sort: PlayerSort = .averageDesc

    var filteredPlayers: [Player] {
        var list = players
        if let pos = selectedPosition { list = list.filter { $0.position == pos } }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            list = list.filter { $0.name.lowercased().contains(q) || $0.team.lowercased().contains(q) }
        }
        list = sort.apply(to: list)
        return list
    }

    private let apiClient = AFLFantasyAPIClient.shared

    func loadInitialData() async {
        isLoading = true
        defer { isLoading = false }
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.checkAPIHealth() }
            group.addTask { await self.loadSummary() }
            group.addTask { await self.loadPlayers() }
            group.addTask { await self.loadCashCows() }
            group.addTask { await self.loadCaptainSuggestions() }
        }
    }

    func refreshData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadPlayers() }
            group.addTask { await self.loadCashCows() }
            group.addTask { await self.loadCaptainSuggestions() }
            group.addTask { await self.loadSummary() }
            group.addTask { await self.checkAPIHealth() }
        }
    }

    func checkAPIHealth() async {
        do {
            let health = try await apiClient.healthCheck()
            self.apiHealth = health
        } catch {
            self.errorMessage = "API health check failed"
        }
    }

    private func loadSummary() async {
        do {
            self.summary = try await apiClient.getDataSummary()
        } catch {
            // no-op
        }
    }

    private func loadPlayers() async {
        do {
            let fetchedPlayers = try await apiClient.getAllPlayers()
            self.players = fetchedPlayers
        } catch {
            self.errorMessage = "Failed to load players"
        }
    }

    private func loadCashCows() async {
        do {
            self.cashCows = try await apiClient.getCashCowAnalysis()
        } catch {
            self.errorMessage = "Failed to load cash cows"
        }
    }

    private func loadCaptainSuggestions() async {
        do {
            self.captainSuggestions = try await apiClient.getCaptainSuggestions()
        } catch {
            self.errorMessage = "Failed to load captain suggestions"
        }
    }
}

// MARK: - Sorting
enum PlayerSort: CaseIterable {
    case priceDesc, priceAsc, averageDesc, averageAsc, breakevenAsc

    var title: String {
        switch self {
        case .priceDesc: return "Price ↓"
        case .priceAsc: return "Price ↑"
        case .averageDesc: return "Avg ↓"
        case .averageAsc: return "Avg ↑"
        case .breakevenAsc: return "BE ↑"
        }
    }

    var icon: String {
        switch self {
        case .priceDesc, .priceAsc: return "dollarsign.circle"
        case .averageDesc, .averageAsc: return "chart.bar"
        case .breakevenAsc: return "bolt"
        }
    }

    func apply(to players: [Player]) -> [Player] {
        switch self {
        case .priceDesc: return players.sorted { $0.price > $1.price }
        case .priceAsc: return players.sorted { $0.price < $1.price }
        case .averageDesc: return players.sorted { $0.average > $1.average }
        case .averageAsc: return players.sorted { $0.average < $1.average }
        case .breakevenAsc: return players.sorted { $0.breakeven < $1.breakeven }
        }
    }
}

// MARK: - Extensions
extension View {
    func shimmer() -> some View {
        self.overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, Color.white.opacity(0.3), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .rotationEffect(.degrees(-15))
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                    value: UUID()
                )
        )
        .clipped()
    }
}

#Preview {
    DashboardView()
}
