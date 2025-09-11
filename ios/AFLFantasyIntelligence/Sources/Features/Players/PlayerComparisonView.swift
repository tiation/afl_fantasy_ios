import SwiftUI

// MARK: - PlayerComparisonView

struct PlayerComparisonView: View {
    @StateObject private var comparisonService = PlayerComparisonService()
    @StateObject private var playersViewModel = PlayersViewModel()
    @EnvironmentObject var apiService: APIService
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPlayers: [Player] = []
    @State private var showingPlayerPicker = false
    @State private var comparisonData: PlayerComparisonData?
    @State private var isAnalyzing = false
    
    private let maxPlayers = 4
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                ScrollView {
                    VStack(spacing: DS.Spacing.l) {
                        // Player Selection Section
                        playerSelectionSection
                        
                        // Comparison Results
                        if let data = comparisonData {
                            comparisonResultsSection(data)
                        } else if !selectedPlayers.isEmpty {
                            comparisonPromptSection
                        }
                    }
                    .padding(DS.Spacing.l)
                }
            }
            .navigationTitle("Player Comparison")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        clearComparison()
                    }
                    .disabled(selectedPlayers.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingPlayerPicker) {
            PlayerComparisonPicker(
                selectedPlayers: $selectedPlayers,
                maxPlayers: maxPlayers,
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
            colors: [DS.Colors.secondary, DS.Colors.secondaryVariant],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )) {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                HStack {
                    Image(systemName: "person.2.badge.plus.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text("Player Comparison")
                            .font(DS.Typography.brandHeadline)
                            .foregroundColor(.white)
                        
                        Text("Compare up to \(maxPlayers) players side-by-side")
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
    
    // MARK: - Player Selection Section
    
    private var playerSelectionSection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                HStack {
                    Text("Selected Players")
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    Spacer()
                    
                    Text("\(selectedPlayers.count)/\(maxPlayers)")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                }
                
                if selectedPlayers.isEmpty {
                    // Empty State
                    VStack(spacing: DS.Spacing.m) {
                        Image(systemName: "person.2.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(DS.Colors.secondary.opacity(0.6))
                        
                        Text("No players selected")
                            .font(DS.Typography.title3)
                            .foregroundColor(DS.Colors.onSurface)
                        
                        Text("Add players to compare their stats, form, fixtures, and value")
                            .font(DS.Typography.body)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                            .multilineTextAlignment(.center)
                        
                        DSButton("Add Players") {
                            showingPlayerPicker = true
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DS.Spacing.xl)
                } else {
                    // Selected Players Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.s), count: min(selectedPlayers.count, 2)), spacing: DS.Spacing.s) {
                        ForEach(selectedPlayers) { player in
                            CompactPlayerCard(player: player) {
                                removePlayer(player)
                            }
                        }
                    }
                    
                    if selectedPlayers.count < maxPlayers {
                        DSButton("Add More Players", style: .outline) {
                            showingPlayerPicker = true
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Comparison Prompt Section
    
    private var comparisonPromptSection: some View {
        DSCard {
            VStack(spacing: DS.Spacing.m) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 32))
                    .foregroundColor(DS.Colors.secondary)
                
                Text("Ready to Compare")
                    .font(DS.Typography.headline)
                    .foregroundColor(DS.Colors.onSurface)
                
                Text("Analyze selected players across multiple metrics including form, value, fixtures, and risk assessment.")
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                    .multilineTextAlignment(.center)
                
                DSButton(isAnalyzing ? "Analyzing..." : "Compare Players") {
                    compareSelectedPlayers()
                }
                .disabled(isAnalyzing || selectedPlayers.count < 2)
            }
            .padding(.vertical, DS.Spacing.m)
        }
    }
    
    // MARK: - Comparison Results Section
    
    private func comparisonResultsSection(_ data: PlayerComparisonData) -> some View {
        VStack(spacing: DS.Spacing.l) {
            // Summary Metrics Table
            summaryMetricsSection(data)
            
            // Detailed Analysis
            detailedAnalysisSection(data)
            
            // Recommendations
            if !data.recommendations.isEmpty {
                recommendationsSection(data.recommendations)
            }
        }
    }
    
    private func summaryMetricsSection(_ data: PlayerComparisonData) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                Text("Comparison Summary")
                    .font(DS.Typography.headline)
                    .foregroundColor(DS.Colors.onSurface)
                
                // Metrics Table
                VStack(spacing: DS.Spacing.xs) {
                    // Header Row
                    HStack {
                        Text("Metric")
                            .font(DS.Typography.subheadline)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(selectedPlayers.prefix(3)) { player in
                            Text(player.name.components(separatedBy: " ").first ?? player.name)
                                .font(DS.Typography.subheadline)
                                .foregroundColor(DS.Colors.onSurfaceSecondary)
                                .frame(maxWidth: .infinity)
                                .lineLimit(1)
                        }
                    }
                    .padding(.bottom, DS.Spacing.xs)
                    
                    Divider()
                    
                    // Data Rows
                    ForEach(data.summaryMetrics, id: \.metric) { summary in
                        ComparisonMetricRow(summary: summary, playerCount: min(selectedPlayers.count, 3))
                    }
                }
            }
        }
    }
    
    private func detailedAnalysisSection(_ data: PlayerComparisonData) -> some View {
        VStack(spacing: DS.Spacing.m) {
            // Best Value Player
            if let bestValue = data.bestValuePlayer {
                DSCard(style: .gradient(LinearGradient(
                    colors: [DS.Colors.success, DS.Colors.successLight],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))) {
                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.white)
                            
                            Text("Best Value")
                                .font(DS.Typography.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        Text(bestValue.playerName)
                            .font(DS.Typography.brandTitle)
                            .foregroundColor(.white)
                        
                        Text(bestValue.reason)
                            .font(DS.Typography.body)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            
            // Risk Assessment
            DSCard {
                VStack(alignment: .leading, spacing: DS.Spacing.m) {
                    Text("Risk Assessment")
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    ForEach(data.riskAssessments, id: \.playerName) { assessment in
                        HStack {
                            Text(assessment.playerName)
                                .font(DS.Typography.body)
                                .foregroundColor(DS.Colors.onSurface)
                            
                            Spacer()
                            
                            DSStatusBadge(
                                text: assessment.riskLevel.rawValue,
                                style: assessment.riskLevel == .low ? .success :
                                       assessment.riskLevel == .medium ? .warning : .error
                            )
                        }
                    }
                }
            }
        }
    }
    
    private func recommendationsSection(_ recommendations: [String]) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                Text("Recommendations")
                    .font(DS.Typography.headline)
                    .foregroundColor(DS.Colors.onSurface)
                
                VStack(alignment: .leading, spacing: DS.Spacing.s) {
                    ForEach(recommendations, id: \.self) { recommendation in
                        HStack(alignment: .top, spacing: DS.Spacing.s) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption)
                                .foregroundColor(DS.Colors.secondary)
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
    
    // MARK: - Actions
    
    private func loadPlayersIfNeeded() async {
        guard playersViewModel.players.isEmpty else { return }
        await playersViewModel.loadPlayers(apiService: apiService)
    }
    
    private func removePlayer(_ player: Player) {
        withAnimation(DS.Motion.spring) {
            selectedPlayers.removeAll { $0.id == player.id }
            comparisonData = nil
        }
    }
    
    private func compareSelectedPlayers() {
        guard selectedPlayers.count >= 2 else { return }
        
        isAnalyzing = true
        
        Task {
            do {
                let result = try await comparisonService.comparePlayers(selectedPlayers)
                
                await MainActor.run {
                    withAnimation(DS.Motion.spring) {
                        comparisonData = result
                        isAnalyzing = false
                    }
                }
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    print("❌ Player comparison failed: \(error)")
                }
            }
        }
    }
    
    private func clearComparison() {
        withAnimation(DS.Motion.spring) {
            selectedPlayers.removeAll()
            comparisonData = nil
        }
    }
}

// MARK: - Supporting Views

struct CompactPlayerCard: View {
    let player: Player
    let onRemove: () -> Void
    
    var body: some View {
        DSCard(padding: DS.Spacing.m, style: .elevated) {
            VStack(alignment: .leading, spacing: DS.Spacing.s) {
                HStack {
                    // Position indicator
                    Circle()
                        .fill(DS.Colors.positionGradient(for: player.position))
                        .frame(width: 20, height: 20)
                        .overlay(
                            Text(player.position.shortName)
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                        )
                    
                    Spacer()
                    
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DS.Colors.error)
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
                
                Text(player.name)
                    .font(DS.Typography.subheadline)
                    .foregroundColor(DS.Colors.onSurface)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                HStack {
                    Text(player.team)
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                    
                    Spacer()
                    
                    Text("$\(player.price / 1000)K")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.primary)
                        .fontWeight(.medium)
                }
            }
        }
    }
}

struct ComparisonMetricRow: View {
    let summary: ComparisonSummaryMetric
    let playerCount: Int
    
    var body: some View {
        HStack {
            Text(summary.metric)
                .font(DS.Typography.body)
                .foregroundColor(DS.Colors.onSurface)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(0..<playerCount, id: \.self) { index in
                if index < summary.values.count {
                    Text(summary.values[index])
                        .font(DS.Typography.body)
                        .foregroundColor(summary.bestPlayerIndex == index ? DS.Colors.success : DS.Colors.onSurface)
                        .fontWeight(summary.bestPlayerIndex == index ? .semibold : .regular)
                        .frame(maxWidth: .infinity)
                } else {
                    Text("-")
                        .font(DS.Typography.body)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}

// MARK: - Player Comparison Picker

struct PlayerComparisonPicker: View {
    @Binding var selectedPlayers: [Player]
    let maxPlayers: Int
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
                    PlayerComparisonPickerRow(player: player) {
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
            .navigationTitle("Add Players (\(selectedPlayers.count)/\(maxPlayers))")
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
        guard selectedPlayers.count < maxPlayers else { return }
        selectedPlayers.append(player)
    }
}

struct PlayerComparisonPickerRow: View {
    let player: Player
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

// MARK: - Previews

#if DEBUG
struct PlayerComparisonView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerComparisonView()
            .environmentObject(APIService.mock)
    }
}
#endif
