import SwiftUI

// MARK: - TradeAnalyzerView

struct TradeAnalyzerView: View {
    @StateObject private var tradeService = TradeAnalyzerService()
    @EnvironmentObject var apiService: APIService
    @StateObject private var playersViewModel = PlayersViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPlayersIn: [Player] = []
    @State private var selectedPlayersOut: [Player] = []
    @State private var showingPlayerPicker = false
    @State private var isPickingForTradeIn = true
    @State private var tradeResult: TradeAnalysisResult?
    @State private var isAnalyzing = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                ScrollView {
                    VStack(spacing: DS.Spacing.l) {
                        // Trade Builder
                        tradeBuilderSection
                        
                        // Analysis Results
                        if let result = tradeResult {
                            tradeResultsSection(result)
                        } else if !selectedPlayersIn.isEmpty || !selectedPlayersOut.isEmpty {
                            analyzePromptSection
                        }
                    }
                    .padding(DS.Spacing.l)
                }
            }
            .navigationTitle("Trade Analyzer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        clearAll()
                    }
                    .disabled(selectedPlayersIn.isEmpty && selectedPlayersOut.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingPlayerPicker) {
            PlayerPickerView(
                selectedPlayers: isPickingForTradeIn ? 
                    Binding(get: { selectedPlayersIn }, set: { selectedPlayersIn = $0 }) :
                    Binding(get: { selectedPlayersOut }, set: { selectedPlayersOut = $0 }),
                isTradeIn: isPickingForTradeIn,
                availablePlayers: playersViewModel.players
            )
        }
        .task {
            await loadPlayersIfNeeded()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        DSGradientCard(gradient: LinearGradient(
            colors: [DS.Colors.primary, DS.Colors.primaryVariant],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )) {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                HStack {
                    Image(systemName: "arrow.left.arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text("Trade Analyzer")
                            .font(DS.Typography.brandHeadline)
                            .foregroundColor(.white)
                        
                        Text("AI-powered trade analysis and recommendations")
                            .font(DS.Typography.body)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, DS.Spacing.l)
        .padding(.bottom, DS.Spacing.m)
    }
    
    // MARK: - Trade Builder Section
    
    private var tradeBuilderSection: some View {
        VStack(spacing: DS.Spacing.l) {
            // Trade In Section
            tradeSection(
                title: "Trading In",
                players: selectedPlayersIn,
                addButtonTitle: "Add Player to Trade In",
                emptyStateText: "Select players to trade into your team",
                color: DS.Colors.success
            ) {
                isPickingForTradeIn = true
                showingPlayerPicker = true
            }
            
            // Trade Out Section  
            tradeSection(
                title: "Trading Out",
                players: selectedPlayersOut,
                addButtonTitle: "Add Player to Trade Out", 
                emptyStateText: "Select players to trade out of your team",
                color: DS.Colors.error
            ) {
                isPickingForTradeIn = false
                showingPlayerPicker = true
            }
        }
    }
    
    private func tradeSection(
        title: String,
        players: [Player],
        addButtonTitle: String,
        emptyStateText: String,
        color: Color,
        addAction: @escaping () -> Void
    ) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                HStack {
                    Text(title)
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    Spacer()
                    
                    Text("\(players.count) player\(players.count != 1 ? "s" : "")")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                }
                
                if players.isEmpty {
                    // Empty State
                    VStack(spacing: DS.Spacing.m) {
                        Image(systemName: title.contains("In") ? "plus.circle" : "minus.circle")
                            .font(.system(size: 32))
                            .foregroundColor(color.opacity(0.6))
                        
                        Text(emptyStateText)
                            .font(DS.Typography.body)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                            .multilineTextAlignment(.center)
                        
                        DSButton(addButtonTitle, style: .outline) {
                            addAction()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DS.Spacing.l)
                } else {
                    // Players List
                    VStack(spacing: DS.Spacing.s) {
                        ForEach(players) { player in
                            TradePlayerRow(
                                player: player,
                                isTradeIn: title.contains("In")
                            ) {
                                removePlayer(player, from: title.contains("In") ? .tradeIn : .tradeOut)
                            }
                        }
                        
                        DSButton(addButtonTitle, style: .secondary) {
                            addAction()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Analyze Prompt Section
    
    private var analyzePromptSection: some View {
        DSCard {
            VStack(spacing: DS.Spacing.m) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 32))
                    .foregroundColor(DS.Colors.primary)
                
                Text("Ready to Analyze")
                    .font(DS.Typography.headline)
                    .foregroundColor(DS.Colors.onSurface)
                
                Text("Get detailed analysis of your trade including points impact, cash flow, and risk assessment.")
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                    .multilineTextAlignment(.center)
                
                DSButton(isAnalyzing ? "Analyzing..." : "Analyze Trade") {
                    analyzeTrade()
                }
                .disabled(isAnalyzing || (selectedPlayersIn.isEmpty && selectedPlayersOut.isEmpty))
            }
            .padding(.vertical, DS.Spacing.m)
        }
    }
    
    // MARK: - Trade Results Section
    
    private func tradeResultsSection(_ result: TradeAnalysisResult) -> some View {
        VStack(spacing: DS.Spacing.l) {
            // Overall Rating Card
            DSGradientCard(gradient: LinearGradient(
                colors: [result.overallRating >= 7.5 ? DS.Colors.success : result.overallRating >= 5.0 ? DS.Colors.warning : DS.Colors.error,
                        result.overallRating >= 7.5 ? DS.Colors.successLight : result.overallRating >= 5.0 ? DS.Colors.warningLight : DS.Colors.errorLight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )) {
                VStack(spacing: DS.Spacing.m) {
                    Text("Trade Rating")
                        .font(DS.Typography.headline)
                        .foregroundColor(.white)
                    
                    Text("\(result.overallRating, specifier: "%.1f")/10")
                        .font(DS.Typography.brandTitle)
                        .foregroundColor(.white)
                    
                    Text(result.recommendation)
                        .font(DS.Typography.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
            }
            
            // Financial Impact
            DSCard {
                VStack(alignment: .leading, spacing: DS.Spacing.m) {
                    Text("Financial Impact")
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    HStack(spacing: DS.Spacing.l) {
                        FinancialMetric(
                            title: "Cash Impact",
                            value: "$\(result.cashImpact >= 0 ? "+" : "")\(Int(result.cashImpact / 1000))K",
                            color: result.cashImpact >= 0 ? DS.Colors.success : DS.Colors.error
                        )
                        
                        FinancialMetric(
                            title: "Points/Week",
                            value: "\(result.pointsPerWeek >= 0 ? "+" : "")\(result.pointsPerWeek, specifier: "%.1f")",
                            color: result.pointsPerWeek >= 0 ? DS.Colors.success : DS.Colors.error
                        )
                        
                        FinancialMetric(
                            title: "Risk Level",
                            value: result.riskLevel.rawValue,
                            color: result.riskLevel.color
                        )
                    }
                }
            }
            
            // Detailed Metrics
            DSCard {
                VStack(alignment: .leading, spacing: DS.Spacing.m) {
                    Text("Detailed Analysis")
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    VStack(spacing: DS.Spacing.s) {
                        ForEach(result.detailedMetrics, id: \.title) { metric in
                            DetailedMetricRow(metric: metric)
                        }
                    }
                }
            }
            
            // Recommendations
            if !result.recommendations.isEmpty {
                DSCard {
                    VStack(alignment: .leading, spacing: DS.Spacing.m) {
                        Text("Recommendations")
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.Colors.onSurface)
                        
                        VStack(alignment: .leading, spacing: DS.Spacing.s) {
                            ForEach(result.recommendations, id: \.self) { recommendation in
                                HStack(alignment: .top, spacing: DS.Spacing.s) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.caption)
                                        .foregroundColor(DS.Colors.primary)
                                        .padding(.top, 2)
                                    
                                    Text(recommendation)
                                        .font(DS.Typography.body)
                                        .foregroundColor(DS.Colors.onSurface)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func loadPlayersIfNeeded() async {
        guard playersViewModel.players.isEmpty else { return }
        await playersViewModel.loadPlayers(apiService: apiService)
    }
    
    private func removePlayer(_ player: Player, from type: TradeType) {
        withAnimation(DS.Motion.spring) {
            switch type {
            case .tradeIn:
                selectedPlayersIn.removeAll { $0.id == player.id }
            case .tradeOut:
                selectedPlayersOut.removeAll { $0.id == player.id }
            }
            
            // Clear results when trade changes
            tradeResult = nil
        }
    }
    
    private func analyzeTrade() {
        guard !selectedPlayersIn.isEmpty || !selectedPlayersOut.isEmpty else { return }
        
        isAnalyzing = true
        
        Task {
            do {
                let result = try await tradeService.analyzeTrade(
                    playersIn: selectedPlayersIn,
                    playersOut: selectedPlayersOut,
                    currentBudget: 150000,
                    tradesRemaining: 15
                )
                
                await MainActor.run {
                    withAnimation(DS.Motion.spring) {
                        tradeResult = result
                        isAnalyzing = false
                    }
                }
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    print("❌ Trade analysis failed: \(error)")
                }
            }
        }
    }
    
    private func clearAll() {
        withAnimation(DS.Motion.spring) {
            selectedPlayersIn.removeAll()
            selectedPlayersOut.removeAll()
            tradeResult = nil
        }
    }
}

// MARK: - Supporting Views

struct TradePlayerRow: View {
    let player: Player
    let isTradeIn: Bool
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: DS.Spacing.m) {
            // Position indicator
            Circle()
                .fill(DS.Colors.positionGradient(for: player.position))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(player.position.shortName)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(player.name)
                    .font(DS.Typography.subheadline)
                    .foregroundColor(DS.Colors.onSurface)
                
                HStack(spacing: DS.Spacing.s) {
                    Text(player.team)
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                    
                    Text("$\(player.price / 1000)K")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.primary)
                }
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(DS.Colors.error)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}

struct FinancialMetric: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: DS.Spacing.xs) {
            Text(value)
                .font(DS.Typography.statNumber)
                .foregroundColor(color)
            
            Text(title)
                .font(DS.Typography.caption)
                .foregroundColor(DS.Colors.onSurfaceSecondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DetailedMetricRow: View {
    let metric: TradeMetric
    
    var body: some View {
        HStack {
            Text(metric.title)
                .font(DS.Typography.body)
                .foregroundColor(DS.Colors.onSurface)
            
            Spacer()
            
            Text(metric.value)
                .font(DS.Typography.body)
                .foregroundColor(DS.Colors.primary)
                .fontWeight(.medium)
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}

// MARK: - PlayerPickerView

struct PlayerPickerView: View {
    @Binding var selectedPlayers: [Player]
    let isTradeIn: Bool
    let availablePlayers: [Player]
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var selectedPosition: Position? = nil
    
    private var filteredPlayers: [Player] {
        var players = availablePlayers
        
        // Remove already selected players
        let selectedIds = Set(selectedPlayers.map { $0.id })
        players = players.filter { !selectedIds.contains($0.id) }
        
        // Filter by position
        if let position = selectedPosition {
            players = players.filter { $0.position == position }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            players = players.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.team.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort by projected score
        return players.sorted { $0.projected > $1.projected }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Position filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Spacing.s) {
                        FilterChip(title: "All", isSelected: selectedPosition == nil) {
                            selectedPosition = nil
                        }
                        
                        ForEach(Position.allCases, id: \.self) { position in
                            FilterChip(title: position.shortName, isSelected: selectedPosition == position) {
                                selectedPosition = selectedPosition == position ? nil : position
                            }
                        }
                    }
                    .padding(.horizontal, DS.Spacing.l)
                }
                .padding(.vertical, DS.Spacing.s)
                
                // Players list
                List(filteredPlayers) { player in
                    PlayerPickerRow(player: player, isSelected: false) {
                        selectPlayer(player)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(
                        top: DS.Spacing.s,
                        leading: DS.Spacing.l,
                        bottom: DS.Spacing.s,
                        trailing: DS.Spacing.l
                    ))
                }
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "Search players...")
            }
            .navigationTitle(isTradeIn ? "Select Players to Trade In" : "Select Players to Trade Out")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func selectPlayer(_ player: Player) {
        selectedPlayers.append(player)
    }
}

struct PlayerPickerRow: View {
    let player: Player
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.m) {
                // Position indicator
                Circle()
                    .fill(DS.Colors.positionGradient(for: player.position))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(player.position.shortName)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(player.name)
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.onSurface)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: DS.Spacing.s) {
                        Text(player.team)
                            .font(DS.Typography.subheadline)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                        
                        Text("$\(player.price / 1000)K")
                            .font(DS.Typography.subheadline)
                            .foregroundColor(DS.Colors.primary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: DS.Spacing.xs) {
                    Text("\(Int(player.projected))")
                        .font(DS.Typography.price)
                        .foregroundColor(DS.Colors.primary)
                    
                    Text("PROJ")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                        .textCase(.uppercase)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Supporting Types

enum TradeType {
    case tradeIn
    case tradeOut
}

// MARK: - Extensions

extension RiskLevel {
    var color: Color {
        switch self {
        case .low: return DS.Colors.success
        case .medium: return DS.Colors.warning  
        case .high: return DS.Colors.error
        }
    }
}

// MARK: - Previews

#if DEBUG
struct TradeAnalyzerView_Previews: PreviewProvider {
    static var previews: some View {
        TradeAnalyzerView()
            .environmentObject(APIService.mock)
    }
}
#endif
