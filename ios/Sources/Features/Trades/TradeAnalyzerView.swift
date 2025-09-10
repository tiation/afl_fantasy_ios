import SwiftUI

@available(iOS 14.0, *)
struct TradeAnalyzerView: View {
    @StateObject private var tradeService = TradeAnalyzerService()
    @State private var playersIn: [Player] = []
    @State private var playersOut: [Player] = []
    @State private var currentAnalysis: TradeAnalysis?
    @State private var showingPlayerPicker = false
    @State private var pickerMode: PickerMode = .playersIn
    
    enum PickerMode: String, CaseIterable {
        case playersIn = "Players In"
        case playersOut = "Players Out"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    TradeBuilderSection(
                        playersIn: playersIn,
                        playersOut: playersOut,
                        onAddPlayerIn: { showPlayerPicker(.playersIn) },
                        onAddPlayerOut: { showPlayerPicker(.playersOut) },
                        onRemovePlayer: removePlayer
                    )
                    
                    if canAnalyzeTrade {
                        AnalyzeTradeButton {
                            analyzeTrade()
                        }
                    }
                    
                    if let analysis = currentAnalysis {
                        TradeAnalysisResultsView(analysis: analysis)
                    }
                    
                    if tradeService.isLoading {
                        LoadingView()
                    }
                }
                .padding()
            }
            .navigationTitle("Trade Analyzer")
            .sheet(isPresented: $showingPlayerPicker) {
                PlayerPickerView(
                    selectedPlayers: pickerMode == .playersIn ? playersIn : playersOut,
                    onPlayerSelected: { player in
                        addPlayer(player, to: pickerMode)
                    }
                )
            }
        }
    }
    
    private var canAnalyzeTrade: Bool {
        !playersIn.isEmpty && !playersOut.isEmpty
    }
    
    private func showPlayerPicker(_ mode: PickerMode) {
        pickerMode = mode
        showingPlayerPicker = true
    }
    
    private func addPlayer(_ player: Player, to mode: PickerMode) {
        switch mode {
        case .playersIn:
            if !playersIn.contains(where: { $0.id == player.id }) {
                playersIn.append(player)
            }
        case .playersOut:
            if !playersOut.contains(where: { $0.id == player.id }) {
                playersOut.append(player)
            }
        }
        showingPlayerPicker = false
    }
    
    private func removePlayer(_ player: Player, from mode: PickerMode) {
        switch mode {
        case .playersIn:
            playersIn.removeAll { $0.id == player.id }
        case .playersOut:
            playersOut.removeAll { $0.id == player.id }
        }
    }
    
    private func analyzeTrade() {
        Task {
            currentAnalysis = await tradeService.analyzeTrade(playersIn: playersIn, playersOut: playersOut)
        }
    }
}

@available(iOS 14.0, *)
private struct TradeBuilderSection: View {
    let playersIn: [Player]
    let playersOut: [Player]
    let onAddPlayerIn: () -> Void
    let onAddPlayerOut: () -> Void
    let onRemovePlayer: (Player, TradeAnalyzerView.PickerMode) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Players In
            TradePlayersSection(
                title: "Players In",
                players: playersIn,
                addAction: onAddPlayerIn,
                removeAction: { player in
                    onRemovePlayer(player, .playersIn)
                }
            )
            
            // Trade Direction Indicator
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("Trade")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            // Players Out
            TradePlayersSection(
                title: "Players Out",
                players: playersOut,
                addAction: onAddPlayerOut,
                removeAction: { player in
                    onRemovePlayer(player, .playersOut)
                }
            )
        }
    }
}

@available(iOS 14.0, *)
private struct TradePlayersSection: View {
    let title: String
    let players: [Player]
    let addAction: () -> Void
    let removeAction: (Player) -> Void
    
    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button("Add Player", action: addAction)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                }
                
                if players.isEmpty {
                    Text("No players selected")
                        .foregroundColor(.secondary)
                        .italic()
                        .padding(.vertical, 8)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(players, id: \\.id) { player in
                            TradePlayerRow(player: player) {
                                removeAction(player)
                            }
                        }
                    }
                }
                
                // Summary
                if !players.isEmpty {
                    Divider()
                    
                    HStack {
                        Text("Total Value:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(totalValue.formatted(.currency(code: "AUD")))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
        }
    }
    
    private var totalValue: Double {
        players.reduce(0) { $0 + $1.price }
    }
}

@available(iOS 14.0, *)
private struct TradePlayerRow: View {
    let player: Player
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\\(player.team) - \\(player.position.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(player.price.formatted(.currency(code: "AUD")))
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("Avg: \\(String(format: \"%.1f\", player.average))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }
            .dsMinimumHitTarget()
        }
        .padding(.vertical, 4)
    }
}

@available(iOS 14.0, *)
private struct AnalyzeTradeButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text("Analyze Trade")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

@available(iOS 14.0, *)
private struct TradeAnalysisResultsView: View {
    let analysis: TradeAnalysis
    
    var body: some View {
        VStack(spacing: 16) {
            // Overall Rating
            TradeRatingCard(analysis: analysis)
            
            // Key Metrics
            TradeMetricsGrid(analysis: analysis)
            
            // Recommendations
            if !analysis.recommendations.isEmpty {
                RecommendationsSection(recommendations: analysis.recommendations)
            }
            
            // Risk Assessment
            RiskAssessmentSection(analysis: analysis)
        }
    }
}

@available(iOS 14.0, *)
private struct TradeRatingCard: View {
    let analysis: TradeAnalysis
    
    var body: some View {
        DSCard {
            VStack(spacing: 16) {
                HStack {
                    Text("Trade Rating")
                        .font(.headline)
                    
                    Spacer()
                    
                    TradeRatingBadge(rating: analysis.overallRating)
                }
                
                HStack(spacing: 32) {
                    MetricColumn(
                        title: "Cash Impact",
                        value: analysis.cashImpact.formatted(.currency(code: "AUD")),
                        color: analysis.cashImpact >= 0 ? .green : .red
                    )
                    
                    MetricColumn(
                        title: "Points/Week",
                        value: String(format: "%+.1f", analysis.projectedPointsChange),
                        color: analysis.projectedPointsChange >= 0 ? .green : .red
                    )
                    
                    MetricColumn(
                        title: "Risk Level",
                        value: analysis.riskLevel.displayName,
                        color: riskColor(analysis.riskLevel)
                    )
                }
            }
        }
    }
    
    private func riskColor(_ risk: RiskLevel) -> Color {
        switch risk {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

@available(iOS 14.0, *)
private struct TradeRatingBadge: View {
    let rating: TradeRating
    
    var body: some View {
        Text(rating.displayName)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(12)
    }
    
    private var backgroundColor: Color {
        switch rating {
        case .excellent: return .green
        case .good: return .blue
        case .neutral: return .gray
        case .poor: return .orange
        case .terrible: return .red
        }
    }
}

@available(iOS 14.0, *)
private struct MetricColumn: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

@available(iOS 14.0, *)
private struct TradeMetricsGrid: View {
    let analysis: TradeAnalysis
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            MetricCard(
                title: "Form Analysis",
                subtitle: "Recent trends",
                value: String(format: "%.1f", analysis.formAnalysis.overallTrend),
                trend: analysis.formAnalysis.overallTrend > 0 ? .up : .down
            )
            
            MetricCard(
                title: "Fixture Difficulty",
                subtitle: "Next 3 rounds",
                value: String(format: "%.1f", analysis.fixtureAnalysis.averageDifficulty),
                trend: analysis.fixtureAnalysis.averageDifficulty < 3.0 ? .up : .down
            )
        }
    }
}

@available(iOS 14.0, *)
private struct MetricCard: View {
    let title: String
    let subtitle: String
    let value: String
    let trend: TrendDirection
    
    enum TrendDirection {
        case up, down, neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .gray
            }
        }
    }
    
    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Image(systemName: trend.icon)
                        .foregroundColor(trend.color)
                }
            }
        }
    }
}

@available(iOS 14.0, *)
private struct RecommendationsSection: View {
    let recommendations: [String]
    
    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recommendations")
                    .font(.headline)
                
                ForEach(recommendations, id: \\.self) { recommendation in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        
                        Text(recommendation)
                            .font(.caption)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

@available(iOS 14.0, *)
private struct RiskAssessmentSection: View {
    let analysis: TradeAnalysis
    
    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Risk Assessment")
                    .font(.headline)
                
                VStack(spacing: 8) {
                    RiskFactorRow(
                        factor: "Price Volatility",
                        level: analysis.riskFactors.priceVolatility,
                        description: "Based on recent price changes"
                    )
                    
                    RiskFactorRow(
                        factor: "Form Consistency",
                        level: analysis.riskFactors.formConsistency,
                        description: "Scoring reliability over time"
                    )
                    
                    RiskFactorRow(
                        factor: "Injury History",
                        level: analysis.riskFactors.injuryHistory,
                        description: "Past injury frequency"
                    )
                }
            }
        }
    }
}

@available(iOS 14.0, *)
private struct RiskFactorRow: View {
    let factor: String
    let level: RiskLevel
    let description: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(factor)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            RiskLevelBadge(level: level)
        }
    }
}

@available(iOS 14.0, *)
private struct RiskLevelBadge: View {
    let level: RiskLevel
    
    var body: some View {
        Text(level.displayName)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColor.opacity(0.2))
            .foregroundColor(backgroundColor)
            .cornerRadius(4)
    }
    
    private var backgroundColor: Color {
        switch level {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

@available(iOS 14.0, *)
private struct LoadingView: View {
    var body: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Analyzing trade...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Player Picker (Simplified)

@available(iOS 14.0, *)
private struct PlayerPickerView: View {
    let selectedPlayers: [Player]
    let onPlayerSelected: (Player) -> Void
    @Environment(\\.presentationMode) private var presentationMode
    @StateObject private var playerService = PlayerService()
    
    var body: some View {
        NavigationView {
            List(playerService.players, id: \\.id) { player in
                Button {
                    onPlayerSelected(player)
                } label: {
                    PlayerPickerRow(
                        player: player,
                        isSelected: selectedPlayers.contains { $0.id == player.id }
                    )
                }
                .disabled(selectedPlayers.contains { $0.id == player.id })
            }
            .navigationTitle("Select Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await playerService.loadPlayers()
            }
        }
    }
}

@available(iOS 14.0, *)
private struct PlayerPickerRow: View {
    let player: Player
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(player.name)
                    .foregroundColor(.primary)
                Text("\\(player.team) - \\(player.position.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(player.price.formatted(.currency(code: "AUD")))
                    .font(.caption)
                    .foregroundColor(.primary)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
        .opacity(isSelected ? 0.5 : 1.0)
    }
}

// MARK: - Previews

@available(iOS 14.0, *)
struct TradeAnalyzerView_Previews: PreviewProvider {
    static var previews: some View {
        TradeAnalyzerView()
    }
}
