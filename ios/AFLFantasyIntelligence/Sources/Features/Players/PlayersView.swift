import SwiftUI

// MARK: - PlayersView

struct PlayersView: View {
    @EnvironmentObject var apiService: APIService
    @StateObject private var viewModel = PlayersViewModel()
    @StateObject private var prefs = UserPreferencesService.shared
    @State private var showingFilters = false
    @State private var showingAdvancedFilters = false
    @State private var showingPlayerComparison = false
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
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityLabel("Filters")
                    
                    Button {
                        showingAdvancedFilters = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .accessibilityLabel("Advanced Filters")
                    
                    Button {
                        showingPlayerComparison = true
                    } label: {
                        Image(systemName: "person.2.badge.plus")
                    }
                    .accessibilityLabel("Compare Players")
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
            .sheet(isPresented: $showingAdvancedFilters) {
                AdvancedFiltersView()
            }
            .sheet(isPresented: $showingPlayerComparison) {
                PlayerComparisonView()
                    .environmentObject(apiService)
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
            // Error banner if present
            if let errorMessage = viewModel.errorMessage {
                DSCard(style: .bordered) {
                    HStack(spacing: DS.Spacing.m) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(DS.Colors.warning)
                        
                        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                            Text("Connection Issue")
                                .font(DS.Typography.subheadline)
                                .foregroundColor(DS.Colors.onSurface)
                            
                            Text(errorMessage)
                                .font(DS.Typography.caption)
                                .foregroundColor(DS.Colors.onSurfaceSecondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        Button("Retry") {
                            Task {
                                await viewModel.loadPlayers(apiService: apiService)
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .listRowInsets(EdgeInsets(
                    top: DS.Spacing.s,
                    leading: DS.Spacing.l,
                    bottom: DS.Spacing.s,
                    trailing: DS.Spacing.l
                ))
                .listRowBackground(Color.clear)
            }
            
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
            } else if filteredPlayers.isEmpty && viewModel.errorMessage == nil {
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

// MARK: - PlayerDetailView

@available(iOS 16.0, *)
struct PlayerDetailView: View {
    let player: Player
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = PlayerDetailViewModel()
    @StateObject private var prefs = UserPreferencesService.shared
    
    @State private var selectedTab: PlayerDetailTab = .overview
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DS.Spacing.l) {
                    // Player Header
                    playerHeaderSection
                    
                    // Tab Selector
                    tabSelector
                    
                    // Tab Content
                    tabContent
                }
                .padding()
            }
            .navigationTitle(player.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(DS.Motion.spring) {
                            prefs.toggleWatchlist(player.id)
                        }
                    } label: {
                        Image(systemName: prefs.isInWatchlist(player.id) ? "star.fill" : "star")
                            .foregroundColor(prefs.isInWatchlist(player.id) ? DS.Colors.accent : DS.Colors.onSurface)
                    }
                }
            }
        }
        .task {
            await viewModel.loadPlayerDetails(for: player)
        }
    }
    
    // MARK: - Player Header
    
    @ViewBuilder
    private var playerHeaderSection: some View {
        DSGradientCard(gradient: DS.Colors.positionGradient(for: player.position)) {
            VStack(spacing: DS.Spacing.m) {
                HStack {
                    // Position Circle
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Text(player.position.shortName)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text(player.name)
                            .font(DS.Typography.brandTitle)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text(player.team)
                                .font(DS.Typography.headline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            // Premium/Rookie Badge
                            if player.price > 600000 {
                                DSStatusBadge(text: "Premium", style: .custom(.white.opacity(0.2)))
                            } else if player.price < 350000 {
                                DSStatusBadge(text: "Rookie", style: .custom(.white.opacity(0.2)))
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                // Key Stats Row
                HStack(spacing: DS.Spacing.xl) {
                    PlayerDetailStat(title: "Price", value: "$\(player.price / 1000)K", color: .white)
                    PlayerDetailStat(title: "Average", value: "\(player.average, specifier: "%.1f")", color: .white)
                    PlayerDetailStat(title: "Projected", value: "\(player.projected, specifier: "%.1f")", color: .white)
                    PlayerDetailStat(title: "Breakeven", value: "\(player.breakeven)", color: player.breakeven < 0 ? DS.Colors.successLight : DS.Colors.errorLight)
                }
            }
        }
    }
    
    // MARK: - Tab Selector
    
    @ViewBuilder
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.s) {
                ForEach(PlayerDetailTab.allCases, id: \.self) { tab in
                    PlayerDetailTabButton(
                        tab: tab,
                        isSelected: selectedTab == tab
                    ) {
                        withAnimation(DS.Motion.spring) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, DS.Spacing.m)
        }
    }
    
    // MARK: - Tab Content
    
    @ViewBuilder
    private var tabContent: some View {
        Group {
            switch selectedTab {
            case .overview:
                overviewTab
            case .form:
                formTab
            case .splits:
                splitsTab
            case .games:
                gamesTab
            case .insights:
                insightsTab
            }
        }
        .animation(DS.Motion.spring, value: selectedTab)
    }
    
    // MARK: - Overview Tab
    
    @ViewBuilder
    private var overviewTab: some View {
        VStack(spacing: DS.Spacing.l) {
            // Recent Form Chart
            DSCard {
                DSLineChart(
                    data: ChartDataPoint.mockFormData(),
                    title: "Recent Form (Last 6 Games)",
                    color: DS.Colors.primary
                )
            }
            
            // Price Trend
            DSCard {
                DSLineChart(
                    data: ChartDataPoint.mockPriceData(),
                    title: "Price Trend",
                    color: DS.Colors.accent,
                    showGradient: false
                )
            }
            
            // Key Metrics Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DS.Spacing.m) {
                MetricCard(title: "Ownership", value: "23.4%", trend: "+2.1%", color: DS.Colors.info)
                MetricCard(title: "Form Rank", value: "#15", trend: "+5", color: DS.Colors.success)
                MetricCard(title: "Price Rise", value: "+$25K", trend: "This week", color: DS.Colors.warning)
                MetricCard(title: "Reliability", value: "87%", trend: "Season", color: DS.Colors.primary)
            }
        }
    }
    
    // MARK: - Form Tab
    
    @ViewBuilder
    private var formTab: some View {
        VStack(spacing: DS.Spacing.l) {
            DSCard {
                DSLineChart(
                    data: ChartDataPoint.mockFormData(),
                    title: "Season Form Trend",
                    color: DS.Colors.success
                )
            }
            
            DSCard {
                VStack(alignment: .leading, spacing: DS.Spacing.m) {
                    Text("Recent Games")
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    ForEach(0..<5, id: \.self) { index in
                        RecentGameRow(
                            round: "R\(15-index)",
                            opponent: ["COL", "RIC", "ESS", "CAR", "GEE"][index],
                            score: [95.4, 88.7, 105.3, 78.5, 92.1][index],
                            result: ["W", "L", "W", "L", "W"][index]
                        )
                        
                        if index < 4 {
                            Divider()
                                .foregroundColor(DS.Colors.outline.opacity(0.3))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Splits Tab
    
    @ViewBuilder
    private var splitsTab: some View {
        VStack(spacing: DS.Spacing.l) {
            DSCard {
                DSBarChart(
                    data: ChartDataPoint.mockVenueData(),
                    title: "Venue Averages",
                    color: DS.Colors.midfielder
                )
            }
            
            HStack(spacing: DS.Spacing.m) {
                DSCard {
                    VStack(spacing: DS.Spacing.m) {
                        Text("Home vs Away")
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.Colors.onSurface)
                        
                        HStack(spacing: DS.Spacing.l) {
                            VStack {
                                Text("98.2")
                                    .font(DS.Typography.statNumber)
                                    .foregroundColor(DS.Colors.success)
                                Text("Home")
                                    .font(DS.Typography.caption)
                                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                            }
                            
                            VStack {
                                Text("87.4")
                                    .font(DS.Typography.statNumber)
                                    .foregroundColor(DS.Colors.warning)
                                Text("Away")
                                    .font(DS.Typography.caption)
                                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                            }
                        }
                    }
                }
                
                DSCard {
                    VStack(spacing: DS.Spacing.m) {
                        Text("Day vs Night")
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.Colors.onSurface)
                        
                        HStack(spacing: DS.Spacing.l) {
                            VStack {
                                Text("93.8")
                                    .font(DS.Typography.statNumber)
                                    .foregroundColor(DS.Colors.primary)
                                Text("Day")
                                    .font(DS.Typography.caption)
                                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                            }
                            
                            VStack {
                                Text("91.2")
                                    .font(DS.Typography.statNumber)
                                    .foregroundColor(DS.Colors.accent)
                                Text("Night")
                                    .font(DS.Typography.caption)
                                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Games Tab
    
    @ViewBuilder
    private var gamesTab: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                Text("Game Log (Season)")
                    .font(DS.Typography.headline)
                    .foregroundColor(DS.Colors.onSurface)
                
                ForEach(0..<10, id: \.self) { index in
                    GameLogRow(
                        round: "R\(15-index)",
                        date: "Aug \(20-index)",
                        opponent: ["COL", "RIC", "ESS", "CAR", "GEE", "HAW", "FRE", "STK", "NTH", "SYD"][index],
                        score: [95.4, 88.7, 105.3, 78.5, 92.1, 83.6, 89.9, 102.7, 76.3, 88.1][index],
                        disposals: [28, 24, 31, 20, 26, 23, 25, 29, 19, 24][index],
                        goals: [1, 0, 2, 0, 1, 0, 1, 2, 0, 1][index]
                    )
                    
                    if index < 9 {
                        Divider()
                            .foregroundColor(DS.Colors.outline.opacity(0.3))
                    }
                }
            }
        }
    }
    
    // MARK: - Insights Tab
    
    @ViewBuilder
    private var insightsTab: some View {
        VStack(spacing: DS.Spacing.l) {
            // AI Insights Card
            DSGradientCard(gradient: LinearGradient(
                colors: [DS.Colors.primary, DS.Colors.primaryVariant],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )) {
                VStack(alignment: .leading, spacing: DS.Spacing.m) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("AI Analysis")
                            .font(DS.Typography.brandHeadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        DSStatusBadge(text: "92% Confidence", style: .custom(.white.opacity(0.2)))
                    }
                    
                    Text("Strong captain option this week with favorable matchup vs \(player.team == "WB" ? "STK" : "WB"). Recent form trending upward with consistent 90+ scores. Price rise likely.")
                        .font(DS.Typography.body)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            
            // Trade Analysis
            DSCard(style: .elevated) {
                VStack(alignment: .leading, spacing: DS.Spacing.m) {
                    HStack {
                        Image(systemName: "arrow.left.arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(DS.Colors.success)
                        
                        Text("Trade Impact")
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.Colors.onSurface)
                        
                        Spacer()
                        
                        DSStatusBadge(text: "Hold", style: .success)
                    }
                    
                    Text("Current value: \(player.price > 500000 ? "Premium" : "Good value"). Expected price change: +$\(Int.random(in: 15...35))K. Ownership trending up.")
                        .font(DS.Typography.body)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                    
                    HStack(spacing: DS.Spacing.l) {
                        InsightMetric(title: "Buy Score", value: "8.2/10", color: DS.Colors.success)
                        InsightMetric(title: "Captain Score", value: "7.8/10", color: DS.Colors.primary)
                        InsightMetric(title: "Risk Level", value: "Low", color: DS.Colors.success)
                    }
                }
            }
            
            // Upcoming Fixtures
            DSCard {
                VStack(alignment: .leading, spacing: DS.Spacing.m) {
                    Text("Next 3 Fixtures")
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    ForEach(0..<3, id: \.self) { index in
                        FixtureRow(
                            round: "R\(16+index)",
                            opponent: ["STK", "GWS", "PORT"][index],
                            venue: ["Marvel", "MCG", "AO"][index],
                            difficulty: ["Easy", "Medium", "Hard"][index]
                        )
                        
                        if index < 2 {
                            Divider()
                                .foregroundColor(DS.Colors.outline.opacity(0.3))
                        }
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
