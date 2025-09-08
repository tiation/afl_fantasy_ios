//
//  IntelligentTradesView.swift
//  AFL Fantasy Intelligence Platform
//
//  Comprehensive trade calculator with backend integration
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - IntelligentTradesView

struct IntelligentTradesView: View {
    // MARK: - Environment

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var toolsClient: AFLFantasyToolsClient

    // MARK: - State

    @State private var selectedPlayerOut: EnhancedPlayer?
    @State private var selectedPlayerIn: EnhancedPlayer?
    @State private var tradeAnalysis: TradeAnalysis?
    @State private var tradeRecommendations: [TradeAnalysis] = []
    @State private var isAnalyzing = false
    @State private var isLoadingRecommendations = false
    @State private var errorMessage: String?
    @State private var showingPlayerPicker = false
    @State private var isSelectingPlayerOut = true
    @State private var availablePlayersBudget = 500_000 // Default budget for recommendations
    @State private var selectedPosition: String?
    @State private var showingTradeConfirmation = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Trade summary header
                    TradeSummaryHeader(
                        tradesUsed: appState.tradesUsed,
                        tradesRemaining: appState.tradesRemaining,
                        bankBalance: appState.bankBalance
                    )

                    // Player selection section
                    TradePlayerSelectionSection(
                        playerOut: selectedPlayerOut,
                        playerIn: selectedPlayerIn,
                        onSelectPlayerOut: {
                            isSelectingPlayerOut = true
                            showingPlayerPicker = true
                        },
                        onSelectPlayerIn: {
                            isSelectingPlayerOut = false
                            showingPlayerPicker = true
                        },
                        onClearSelection: clearTradeSelection
                    )

                    // Trade analysis section
                    if let analysis = tradeAnalysis {
                        TradeAnalysisSection(analysis: analysis) {
                            showingTradeConfirmation = true
                        }
                    } else if isAnalyzing {
                        TradeAnalysisPlaceholder()
                    }

                    // Trade recommendations
                    TradeRecommendationsSection(
                        recommendations: tradeRecommendations,
                        isLoading: isLoadingRecommendations,
                        availableBudget: $availablePlayersBudget,
                        selectedPosition: $selectedPosition,
                        onLoadRecommendations: loadTradeRecommendations,
                        onSelectRecommendation: selectRecommendation
                    )
                }
                .padding()
            }
            .navigationTitle("Trade Calculator")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        Task {
                            await refreshTradeData()
                        }
                    }
                    .disabled(isAnalyzing || isLoadingRecommendations)
                }
            }
        }
        .sheet(isPresented: $showingPlayerPicker) {
            PlayerPickerSheet(
                players: appState.players,
                isSelectingOut: isSelectingPlayerOut,
                currentSelection: isSelectingPlayerOut ? selectedPlayerOut : selectedPlayerIn,
                onSelection: handlePlayerSelection
            )
        }
        .alert("Execute Trade?", isPresented: $showingTradeConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Execute Trade", role: .destructive) {
                executeSelectedTrade()
            }
        } message: {
            if let out = selectedPlayerOut, let in_ = selectedPlayerIn {
                Text(
                    "Trade out \(out.name) for \(in_.name)?\nThis will use 1 of your remaining \(appState.tradesRemaining) trades."
                )
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear {
            Task {
                await loadTradeRecommendations()
            }
        }
        .onChange(of: selectedPlayerOut) { _, _ in
            Task { await analyzeCurrentTrade() }
        }
        .onChange(of: selectedPlayerIn) { _, _ in
            Task { await analyzeCurrentTrade() }
        }
    }

    // MARK: - Methods

    private func handlePlayerSelection(_ player: EnhancedPlayer) {
        if isSelectingPlayerOut {
            selectedPlayerOut = player
        } else {
            selectedPlayerIn = player
        }
        showingPlayerPicker = false
    }

    private func clearTradeSelection() {
        selectedPlayerOut = nil
        selectedPlayerIn = nil
        tradeAnalysis = nil
    }

    private func analyzeCurrentTrade() async {
        guard let playerOut = selectedPlayerOut,
              let playerIn = selectedPlayerIn
        else {
            tradeAnalysis = nil
            return
        }

        isAnalyzing = true
        errorMessage = nil

        let result = await toolsClient.analyzeTradeOpportunity(
            playerOut: playerOut.name,
            playerIn: playerIn.name,
            budget: appState.bankBalance
        )

        await MainActor.run {
            isAnalyzing = false

            switch result {
            case let .success(analysis):
                tradeAnalysis = analysis
            case let .failure(error):
                errorMessage = error.localizedDescription
                tradeAnalysis = nil
            }
        }
    }

    private func loadTradeRecommendations() async {
        isLoadingRecommendations = true
        errorMessage = nil

        let result = await toolsClient.getTradeRecommendations(
            budget: availablePlayersBudget,
            position: selectedPosition
        )

        await MainActor.run {
            isLoadingRecommendations = false

            switch result {
            case let .success(recommendations):
                tradeRecommendations = recommendations
            case let .failure(error):
                errorMessage = error.localizedDescription
            }
        }
    }

    private func selectRecommendation(_ recommendation: TradeAnalysis) {
        // Find the corresponding players
        if let playerOut = appState.players.first(where: { $0.name == recommendation.playerOut }),
           let playerIn = appState.players.first(where: { $0.name == recommendation.playerIn }) {
            selectedPlayerOut = playerOut
            selectedPlayerIn = playerIn
            tradeAnalysis = recommendation
        }
    }

    private func executeSelectedTrade() {
        guard let playerOut = selectedPlayerOut,
              let playerIn = selectedPlayerIn,
              appState.tradesRemaining > 0
        else {
            return
        }

        // Create trade record
        let tradeRecord = TradeRecord(
            playerOut: playerOut,
            playerIn: playerIn,
            executedAt: Date(),
            netCost: playerIn.currentPrice - playerOut.currentPrice,
            projectedImpact: tradeAnalysis?.projectedImpact ?? 0
        )

        // Update app state
        appState.tradesUsed += 1
        appState.tradesRemaining -= 1
        appState.tradeHistory.append(tradeRecord)
        appState.bankBalance -= (playerIn.currentPrice - playerOut.currentPrice)

        // Update players in team
        if let index = appState.players.firstIndex(where: { $0.id == playerOut.id }) {
            appState.players[index] = playerIn
        }

        // Clear selection
        clearTradeSelection()
    }

    private func refreshTradeData() async {
        await loadTradeRecommendations()
        if selectedPlayerOut != nil, selectedPlayerIn != nil {
            await analyzeCurrentTrade()
        }
    }
}

#Preview {
    IntelligentTradesView()
        .environmentObject(AppState())
        .environmentObject(AFLFantasyToolsClient())
}
