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
                    // Team Health (quick win)
                    teamHealthSection

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
    
    // MARK: - Team Health (Premium Hero Card)
    @ViewBuilder
    private var teamHealthSection: some View {
        let health = TeamHealth.mock
        
        DSGradientCard(gradient: DS.Colors.primaryGradient) {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                HStack {
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        HStack(spacing: DS.Spacing.s) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.white)
                                .font(DS.Typography.title3)
                            
                            Text("Team Health")
                                .font(DS.Typography.brandHeadline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if health.hasAlerts {
                                DSStatusBadge(text: "\(health.alertCount) alerts", style: .warning)
                            } else {
                                DSStatusBadge(text: "All good", style: .success)
                            }
                        }
                        
                        Text("Deadline \(health.deadlineString)")
                            .font(DS.Typography.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                HStack(spacing: DS.Spacing.l) {
                    TeamHealthMetric(
                        title: "Bank",
                        value: "$\(health.bankBalance.formatted())",
                        icon: "dollarsign.circle.fill",
                        color: DS.Colors.accent
                    )
                    
                    TeamHealthMetric(
                        title: "Trades",
                        value: "\(health.tradesRemaining)",
                        icon: "arrow.left.arrow.right.circle.fill",
                        color: .white.opacity(0.9)
                    )
                    
                    TeamHealthMetric(
                        title: "Captain",
                        value: health.captainSet ? "Set" : "Not set",
                        icon: "star.circle.fill",
                        color: health.captainSet ? DS.Colors.success : DS.Colors.warning
                    )
                }
                
                // Progress indicator for deadline
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text("Time to deadline")
                        .font(DS.Typography.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    ProgressView(value: health.isDeadlineClose ? 0.8 : 0.3)
                        .tint(.white)
                        .background(.white.opacity(0.3))
                }
            }
        }
    }

    // MARK: - API Status (Enhanced Design)
    @ViewBuilder
    private var apiStatusCard: some View {
        DSCard(style: .glass) {
            HStack(spacing: DS.Spacing.m) {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    HStack(spacing: DS.Spacing.s) {
                        Image(systemName: "server.rack")
                            .foregroundColor(DS.Colors.primary)
                            .font(DS.Typography.title3)
                        
                        Text("API Status")
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.Colors.onSurface)
                    }
                    
                    if let health = viewModel.apiHealth {
                        HStack(spacing: DS.Spacing.s) {
                            DSProgressRing(
                                progress: health.status == "healthy" ? 1.0 : 0.0,
                                size: 24,
                                lineWidth: 3,
                                color: health.status == "healthy" ? DS.Colors.success : DS.Colors.error
                            )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(health.status.capitalized)
                                    .font(DS.Typography.subheadline)
                                    .foregroundColor(health.status == "healthy" ? DS.Colors.success : DS.Colors.error)
                                
                                if let cached = viewModel.apiHealth?.playersCache {
                                    Text("\(cached) players cached")
                                        .font(DS.Typography.caption)
                                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                                }
                            }
                        }
                        
                        if let last = viewModel.apiHealth?.lastCacheUpdate {
                            Text("Updated: \(last.replacingOccurrences(of: "T", with: " "))")
                                .font(DS.Typography.caption2)
                                .foregroundColor(DS.Colors.onSurfaceVariant)
                        }
                    } else {
                        HStack(spacing: DS.Spacing.s) {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(DS.Colors.warning)
                            
                            Text("Checking connection...")
                                .font(DS.Typography.subheadline)
                                .foregroundColor(DS.Colors.warning)
                        }
                    }
                }
                
                Spacer()
                
                Button { 
                    Task { 
                        await viewModel.checkAPIHealth() 
                    } 
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(DS.Typography.title2)
                        .foregroundColor(DS.Colors.primary)
                        .dsMinimumHitTarget()
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func summaryCards(_ s: APIStatsResponse) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: DS.Spacing.m) {
            EnhancedMetricCard(
                title: "Total Players",
                value: s.totalPlayers,
                icon: "person.3.fill",
                gradient: DS.Colors.primaryGradient
            )
            
            EnhancedMetricCard(
                title: "Data Rows",
                value: s.totalDataRows,
                icon: "chart.bar.fill",
                gradient: LinearGradient(
                    colors: [DS.Colors.midfielder, DS.Colors.midfielder.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            EnhancedMetricCard(
                title: "Success Rate",
                value: s.successfulPlayers,
                icon: "checkmark.circle.fill",
                gradient: LinearGradient(
                    colors: [DS.Colors.success, DS.Colors.successLight],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                suffix: "/\(s.totalPlayers)"
            )
            
            EnhancedMetricCard(
                title: "Failed",
                value: s.failedPlayers,
                icon: "exclamationmark.triangle.fill",
                gradient: s.failedPlayers > 0 ? 
                    LinearGradient(
                        colors: [DS.Colors.error, DS.Colors.errorLight],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) : 
                    LinearGradient(
                        colors: [DS.Colors.neutral, DS.Colors.neutralLight],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
            )
        }
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

// MARK: - TeamHealthMetric
@available(iOS 16.0, *)
struct TeamHealthMetric: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            HStack(spacing: DS.Spacing.xs) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(DS.Typography.caption)
                
                Text(title)
                    .font(DS.Typography.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .textCase(.uppercase)
            }
            
            Text(value)
                .font(DS.Typography.smallStat)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - EnhancedMetricCard
@available(iOS 16.0, *)
struct EnhancedMetricCard: View {
    let title: String
    let value: Int
    let icon: String
    let gradient: LinearGradient
    let suffix: String?
    
    @State private var isVisible = false
    
    init(title: String, value: Int, icon: String, gradient: LinearGradient, suffix: String? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.gradient = gradient
        self.suffix = suffix
    }
    
    var body: some View {
        DSCard(style: .gradient(gradient)) {
            VStack(alignment: .leading, spacing: DS.Spacing.s) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(DS.Typography.title3)
                    
                    Spacer()
                    
                    // Optional trend indicator could go here
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        if isVisible {
                            DSAnimatedCounter(
                                value: value,
                                font: DS.Typography.statNumber,
                                color: .white
                            )
                        } else {
                            Text("0")
                                .font(DS.Typography.statNumber)
                                .foregroundColor(.white)
                        }
                        
                        if let suffix {
                            Text(suffix)
                                .font(DS.Typography.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Text(title)
                        .font(DS.Typography.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
            }
        }
        .aspectRatio(1.4, contentMode: .fit)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(Double.random(in: 0...0.5))) {
                isVisible = true
            }
        }
    }
}

@available(iOS 16.0, *)
struct PlayerRow: View {
    let player: Player
    
    var body: some View {
        DSCard(padding: DS.Spacing.m) {
            HStack(spacing: DS.Spacing.m) {
                // Position indicator with gradient
                Circle()
                    .fill(DS.Colors.positionGradient(for: player.position))
                    .frame(width: 12, height: 12)
                    .shadow(color: DS.Colors.positionColor(for: player.position).opacity(0.3), radius: 2)
                
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(player.name)
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    HStack(spacing: DS.Spacing.xs) {
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
                    Text("$\(player.price / 1000)K")
                        .font(DS.Typography.price)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    HStack(spacing: DS.Spacing.s) {
                        StatPill(label: "AVG", value: "\(Int(player.average))")
                        StatPill(label: "PROJ", value: "\(Int(player.projected))", color: DS.Colors.primary)
                        StatPill(
                            label: "BE", 
                            value: "\(player.breakeven)", 
                            color: player.breakeven < 0 ? DS.Colors.success : DS.Colors.error
                        )
                    }
                }
            }
        }
    }
}

// MARK: - StatPill
@available(iOS 16.0, *)
struct StatPill: View {
    let label: String
    let value: String
    let color: Color
    
    init(label: String, value: String, color: Color = DS.Colors.onSurfaceSecondary) {
        self.label = label
        self.value = value
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 1) {
            Text(value)
                .font(DS.Typography.microStat)
                .foregroundColor(color)
                .fontWeight(.medium)
            
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(DS.Colors.onSurfaceVariant)
                .textCase(.uppercase)
        }
        .frame(minWidth: 24)
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
