import SwiftUI

// MARK: - TradeView

struct TradeView: View {
    @EnvironmentObject var appState: LiveAppState
    @State private var isAnalyzing = false
    @State private var showPlayerSelection = false
    @State private var selectionMode: SelectionMode = .out

    enum SelectionMode {
        case out, `in`
    }

    var body: some View {
        NavigationView {
            List {
                // Current trade scenario
                if !appState.playersToTradeOut.isEmpty || !appState.playersToTradeIn.isEmpty {
                    Section {
                        TradeScenarioView(
                            playersOut: appState.playersToTradeOut,
                            playersIn: appState.playersToTradeIn,
                            onClear: {
                                appState.playersToTradeOut = []
                                appState.playersToTradeIn = []
                                appState.tradeAnalysisResult = nil
                            }
                        )
                    }

                    if let analysis = appState.tradeAnalysisResult {
                        Section("Analysis") {
                            TradeResultView(result: analysis)
                        }
                    }
                }

                // Trade actions
                Section {
                    Button {
                        selectionMode = .out
                        showPlayerSelection = true
                    } label: {
                        Label("Select Players to Trade Out", systemImage: "arrow.up.right")
                    }

                    Button {
                        selectionMode = .in
                        showPlayerSelection = true
                    } label: {
                        Label("Select Players to Trade In", systemImage: "arrow.down.left")
                    }

                    if !appState.playersToTradeOut.isEmpty, !appState.playersToTradeIn.isEmpty {
                        Button {
                            isAnalyzing = true
                            Task {
                                await appState.analyzeTradeScenario()
                                isAnalyzing = false
                            }
                        } label: {
                            if isAnalyzing {
                                HStack {
                                    Text("Analyzing...")
                                    Spacer()
                                    ProgressView()
                                }
                            } else {
                                Text("Analyze Trade")
                            }
                        }
                        .disabled(isAnalyzing)
                    }
                }

                // AI recommendations
                Section("Trade Recommendations") {
                    ForEach(appState.tradeRecommendations, id: \.playerOut) { trade in
                        TradeRecommendationRow(recommendation: trade) {
                            // Apply recommendation
                            if let playerOut = appState.players.first(where: { $0.name == trade.playerOut }),
                               let playerIn = appState.players.first(where: { $0.name == trade.playerIn }) {
                                appState.playersToTradeOut = [playerOut]
                                appState.playersToTradeIn = [playerIn]

                                // Auto-analyze
                                Task {
                                    await appState.analyzeTradeScenario()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Trade Center")
            .refreshable {
                await appState.refreshTrades()
            }
            .sheet(isPresented: $showPlayerSelection) {
                NavigationView {
                    PlayerSelectionView(
                        mode: selectionMode,
                        selected: selectionMode == .out ? appState.playersToTradeOut : appState.playersToTradeIn,
                        onSelect: { players in
                            if selectionMode == .out {
                                appState.playersToTradeOut = players
                            } else {
                                appState.playersToTradeIn = players
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - TradeScenarioView

struct TradeScenarioView: View {
    let playersOut: [EnhancedPlayer]
    let playersIn: [EnhancedPlayer]
    let onClear: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            if !playersOut.isEmpty {
                PlayerTradeList(title: "Trading Out", players: playersOut)
            }

            if !playersIn.isEmpty {
                PlayerTradeList(title: "Trading In", players: playersIn)
            }

            Button(role: .destructive, action: onClear) {
                Label("Clear Trade", systemImage: "xmark")
            }
        }
    }
}

// MARK: - PlayerTradeList

struct PlayerTradeList: View {
    let title: String
    let players: [EnhancedPlayer]

    var totalValue: Int {
        players.reduce(0) { $0 + $1.price }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            ForEach(players) { player in
                HStack {
                    Text(player.name)
                        .font(.headline)

                    Spacer()

                    Text(player.formattedPrice)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            HStack {
                Text("Total")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Text("$\(totalValue / 1000)k")
                    .font(.headline)
            }
        }
    }
}

// MARK: - TradeResultView

struct TradeResultView: View {
    let result: TradeAnalysisResult

    var body: some View {
        VStack(spacing: 16) {
            // Score impact
            HStack {
                VStack(alignment: .leading) {
                    Text("Score Impact")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(String(format: "%+.1f", result.projectedScoreChange))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(result.projectedScoreChange >= 0 ? .green : .red)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Salary Change")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("$\(result.salaryChange / 1000)k")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }

            // Risk factors
            if !result.riskFactors.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Risk Factors")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ForEach(result.riskFactors, id: \.self) { risk in
                        Label(risk, systemImage: "exclamationmark.triangle")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
            }

            // Recommendations
            if !result.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommendations")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ForEach(result.recommendations, id: \.self) { recommendation in
                        Text("• \(recommendation)")
                            .font(.subheadline)
                    }
                }
            }

            // Trade feasibility
            HStack {
                Image(systemName: result.feasible ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(result.feasible ? .green : .red)

                Text(result.feasible ? "Trade is valid" : "Trade not possible")
                    .font(.subheadline)
                    .foregroundColor(result.feasible ? .green : .red)
            }
        }
    }
}

// MARK: - PlayerSelectionView

struct PlayerSelectionView: View {
    let mode: TradeView.SelectionMode
    let selected: [EnhancedPlayer]
    let onSelect: ([EnhancedPlayer]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlayers: Set<String> = []
    @State private var searchText = ""
    @State private var selectedPosition: Position?
    @EnvironmentObject var appState: LiveAppState

    var title: String {
        switch mode {
        case .out: "Trade Out"
        case .in: "Trade In"
        }
    }

    var filteredPlayers: [EnhancedPlayer] {
        var players = appState.players

        // Apply position filter
        if let position = selectedPosition {
            players = players.filter { $0.position == position }
        }

        // Apply search
        if !searchText.isEmpty {
            players = players.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }

        return players
    }

    var body: some View {
        List(filteredPlayers) { player in
            HStack {
                VStack(alignment: .leading) {
                    Text(player.name)
                        .font(.headline)

                    Text(player.position.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(player.formattedPrice)
                        .font(.headline)

                    if player.priceChange != 0 {
                        Text("\(player.priceChange >= 0 ? "+" : "")\(player.priceChange / 1000)k")
                            .font(.caption)
                            .foregroundColor(player.priceChange >= 0 ? .green : .red)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if selectedPlayers.contains(player.id) {
                    selectedPlayers.remove(player.id)
                } else {
                    selectedPlayers.insert(player.id)
                }
            }
            .overlay(alignment: .trailing) {
                if selectedPlayers.contains(player.id) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .searchable(text: $searchText)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    let players = filteredPlayers.filter { selectedPlayers.contains($0.id) }
                    onSelect(players)
                    dismiss()
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - TradeRecommendationRow

struct TradeRecommendationRow: View {
    let recommendation: TradeRecommendation
    let onApply: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    // Trade summary
                    HStack {
                        Text(recommendation.playerOut)
                            .strikethrough()
                            .foregroundColor(.secondary)

                        Image(systemName: "arrow.right")
                            .font(.caption)

                        Text(recommendation.playerIn)
                            .fontWeight(.medium)
                    }
                }

                Spacer()

                // Apply button
                Button(action: onApply) {
                    Text("Apply")
                        .font(.footnote)
                }
                .buttonStyle(.bordered)
            }

            // Reasoning
            Text(recommendation.reasoning)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    TradeView()
        .environmentObject(LiveAppState())
}
