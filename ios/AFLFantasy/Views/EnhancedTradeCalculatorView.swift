//
//  EnhancedTradeCalculatorView.swift
//  AFL Fantasy Intelligence Platform
//
//  Enhanced trade calculator with execution workflow
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - EnhancedTradeCalculatorView

struct EnhancedTradeCalculatorView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var dataService: AFLFantasyDataService
    @EnvironmentObject private var offlineManager: OfflineManager

    @Binding var playerOut: EnhancedPlayer?
    @Binding var playerIn: EnhancedPlayer?
    let onPlayerOutTap: () -> Void
    let onPlayerInTap: () -> Void

    @State private var showingTradeConfirmation = false
    @State private var isExecutingTrade = false
    @State private var tradeResult: TradeExecutionResult?
    @State private var showingTradeResult = false
    @State private var showingOfflineAlert = false

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Trade Calculator")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("Analyze and execute your trades")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Player selection cards
            VStack(spacing: 16) {
                // Trade Out Section
                TradePlayerCard(
                    title: "TRADE OUT",
                    subtitle: "Select from your team",
                    player: playerOut,
                    color: .red,
                    onTap: onPlayerOutTap
                )

                // Trade direction indicator
                Image(systemName: "arrow.up.arrow.down")
                    .font(.title2)
                    .foregroundColor(.orange)
                    .background(
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: 40, height: 40)
                    )

                // Trade In Section
                TradePlayerCard(
                    title: "TRADE IN",
                    subtitle: "Select from available players",
                    player: playerIn,
                    color: .green,
                    onTap: onPlayerInTap
                )
            }

            // Trade Analysis
            if let out = playerOut, let inPlayer = playerIn {
                TradeAnalysisCard(
                    playerOut: out,
                    playerIn: inPlayer,
                    onExecuteTrade: {
                        showingTradeConfirmation = true
                    }
                )
            } else {
                EmptyTradeAnalysisCard()
            }
        }
        .padding()
        .alert("Confirm Trade", isPresented: $showingTradeConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Execute Trade") {
                executeTrade()
            }
        } message: {
            if let out = playerOut, let inPlayer = playerIn {
                Text(
                    "Execute trade: \(out.name) → \(inPlayer.name)?\n\nNet Cost: \(formatPrice(inPlayer.price - out.price))\nThis will use 1 of your \(appState.tradesRemaining) remaining trades."
                )
            }
        }
        .sheet(isPresented: $showingTradeResult) {
            if let result = tradeResult {
                TradeExecutionResultView(result: result)
            }
        }
        .offlineAlert(isPresented: $showingOfflineAlert, alert: .queuedOperation)
    }

    private func executeTrade() {
        guard let out = playerOut, let inPlayer = playerIn else { return }

        isExecutingTrade = true

        Task {
            // Check if online, otherwise queue the operation
            if offlineManager.isOnline {
                // Simulate trade execution
                try? await Task.sleep(nanoseconds: 2_000_000_000)

                await MainActor.run {
                    // Execute the trade
                    executeTradeTransaction(playerOut: out, playerIn: inPlayer)

                    // Create result
                    tradeResult = TradeExecutionResult(
                        playerOut: out,
                        playerIn: inPlayer,
                        netCost: inPlayer.price - out.price,
                        executedAt: Date(),
                        success: true,
                        message: "Trade executed successfully!"
                    )

                    // Clear selections
                    playerOut = nil
                    playerIn = nil

                    isExecutingTrade = false
                    showingTradeResult = true

                    // Haptic feedback
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)
                }
            } else {
                // Queue the operation for when online
                let operation = SyncOperation(
                    type: .makeTrade,
                    data: ["playerOutId": out.id, "playerInId": inPlayer.id],
                    createdAt: Date()
                )

                await offlineManager.queueSyncOperation(operation)

                await MainActor.run {
                    // Execute the trade locally
                    executeTradeTransaction(playerOut: out, playerIn: inPlayer)

                    // Show queued message
                    showingOfflineAlert = true

                    // Clear selections
                    playerOut = nil
                    playerIn = nil

                    isExecutingTrade = false

                    // Haptic feedback
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)
                }
            }
        }
    }

    private func executeTradeTransaction(playerOut: EnhancedPlayer, playerIn: EnhancedPlayer) {
        // Remove player out from team
        appState.players.removeAll { $0.id == playerOut.id }

        // Add player in to team
        appState.players.append(playerIn)

        // Update financials
        let netCost = playerIn.price - playerOut.price
        appState.bankBalance -= netCost
        appState.teamValue = appState.teamValue + netCost

        // Use a trade
        appState.tradesUsed += 1
        appState.tradesRemaining -= 1

        // Add to trade history
        let tradeRecord = TradeRecord(
            playerOut: playerOut,
            playerIn: playerIn,
            executedAt: Date(),
            netCost: netCost,
            projectedImpact: playerIn.averageScore - playerOut.averageScore
        )
        appState.tradeHistory.append(tradeRecord)

        print("✅ Trade executed: \(playerOut.name) → \(playerIn.name)")
    }

    private func formatPrice(_ price: Int) -> String {
        let absPrice = abs(price)
        let sign = price >= 0 ? "+" : "-"

        if absPrice >= 1000 {
            return "\(sign)$\(absPrice / 1000)k"
        } else {
            return "\(sign)$\(absPrice)"
        }
    }
}

// MARK: - TradePlayerCard

struct TradePlayerCard: View {
    let title: String
    let subtitle: String
    let player: EnhancedPlayer?
    let color: Color
    let onTap: () -> Void

    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        Button(action: {
            impactFeedback.impactOccurred()
            onTap()
        }) {
            VStack(spacing: 12) {
                // Header
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(color)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Player content
                if let player {
                    SelectedPlayerContent(player: player, color: color)
                } else {
                    EmptyPlayerContent(color: color)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SelectedPlayerContent

struct SelectedPlayerContent: View {
    let player: EnhancedPlayer
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            // Player name and position
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(player.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(player.position.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(player.position.color.opacity(0.2))
                        .cornerRadius(4)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(player.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Avg: \(Int(player.averageScore))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Key stats
            HStack(spacing: 16) {
                StatPill(title: "Form", value: "\(Int(player.currentScore))", color: .blue)
                StatPill(title: "BE", value: "\(player.breakeven)", color: .orange)
                StatPill(title: "Owned", value: "45%", color: .purple) // Mock data
            }
        }
    }
}

// MARK: - EmptyPlayerContent

struct EmptyPlayerContent: View {
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle.fill")
                .font(.title)
                .foregroundColor(color.opacity(0.6))

            Text("Tap to select player")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(minHeight: 60)
    }
}

// MARK: - StatPill

struct StatPill: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)

            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
}

// MARK: - TradeAnalysisCard

struct TradeAnalysisCard: View {
    let playerOut: EnhancedPlayer
    let playerIn: EnhancedPlayer
    let onExecuteTrade: () -> Void

    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 16) {
            // Trade analysis header
            Text("Trade Analysis")
                .font(.headline)
                .fontWeight(.semibold)

            // Net cost and impact
            HStack(spacing: 20) {
                AnalysisMetric(
                    title: "Net Cost",
                    value: formatPrice(playerIn.price - playerOut.price),
                    color: netCostColor,
                    icon: "dollarsign.circle"
                )

                AnalysisMetric(
                    title: "Points Impact",
                    value: formatPointsImpact(playerIn.averageScore - playerOut.averageScore),
                    color: pointsImpactColor,
                    icon: "chart.line.uptrend.xyaxis"
                )

                AnalysisMetric(
                    title: "Value Rating",
                    value: valueRating,
                    color: valueRatingColor,
                    icon: "star.circle"
                )
            }

            // Trade score
            TradeScoreView(score: tradeScore)

            // Execute button
            Button(action: onExecuteTrade) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Execute Trade")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.green, Color.green.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(appState.tradesRemaining <= 0)
            .opacity(appState.tradesRemaining <= 0 ? 0.6 : 1.0)

            if appState.tradesRemaining <= 0 {
                Text("No trades remaining")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private var netCostColor: Color {
        let cost = playerIn.price - playerOut.price
        return cost <= 0 ? .green : cost <= 100_000 ? .orange : .red
    }

    private var pointsImpactColor: Color {
        let impact = playerIn.averageScore - playerOut.averageScore
        return impact >= 5 ? .green : impact >= 0 ? .blue : .red
    }

    private var valueRatingColor: Color {
        switch valueRating {
        case "Excellent": .green
        case "Good": .blue
        case "Fair": .orange
        default: .red
        }
    }

    private var valueRating: String {
        let pointsPerDollar = (playerIn.averageScore - playerOut.averageScore) / Double(max(
            playerIn.price - playerOut.price,
            1000
        )) * 10000

        switch pointsPerDollar {
        case 0.5...: "Excellent"
        case 0.2 ..< 0.5: "Good"
        case 0 ..< 0.2: "Fair"
        default: "Poor"
        }
    }

    private var tradeScore: Double {
        // Simplified trade score calculation
        let pointsImpact = (playerIn.averageScore - playerOut.averageScore) * 5
        let costPenalty = Double(max(playerIn.price - playerOut.price, 0)) / 50000
        let consistencyBonus = (playerIn.consistency - playerOut.consistency) * 10

        return max(min(pointsImpact - costPenalty + consistencyBonus, 100), 0)
    }

    private func formatPrice(_ price: Int) -> String {
        let absPrice = abs(price)
        let sign = price >= 0 ? "+" : "-"

        if absPrice >= 1000 {
            return "\(sign)$\(absPrice / 1000)k"
        } else {
            return "\(sign)$\(absPrice)"
        }
    }

    private func formatPointsImpact(_ impact: Double) -> String {
        let sign = impact >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", impact))"
    }
}

// MARK: - AnalysisMetric

struct AnalysisMetric: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - TradeScoreView

struct TradeScoreView: View {
    let score: Double

    var body: some View {
        VStack(spacing: 8) {
            Text("Trade Score")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            ZStack {
                Circle()
                    .stroke(Color(.systemGray4), lineWidth: 8)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: score / 100)
                    .stroke(
                        scoreColor,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: score)

                VStack(spacing: 2) {
                    Text("\(Int(score))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(scoreColor)

                    Text(scoreLabel)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var scoreColor: Color {
        switch score {
        case 80...: .green
        case 60 ..< 80: .blue
        case 40 ..< 60: .orange
        default: .red
        }
    }

    private var scoreLabel: String {
        switch score {
        case 80...: "Excellent"
        case 60 ..< 80: "Good"
        case 40 ..< 60: "Fair"
        default: "Poor"
        }
    }
}

// MARK: - EmptyTradeAnalysisCard

struct EmptyTradeAnalysisCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.6))

            Text("Select both players to analyze trade")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - TradeExecutionResult

struct TradeExecutionResult {
    let playerOut: EnhancedPlayer
    let playerIn: EnhancedPlayer
    let netCost: Int
    let executedAt: Date
    let success: Bool
    let message: String
}

// MARK: - TradeExecutionResultView

struct TradeExecutionResultView: View {
    let result: TradeExecutionResult
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Success indicator
                VStack(spacing: 16) {
                    Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(result.success ? .green : .red)

                    Text(result.success ? "Trade Successful!" : "Trade Failed")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(result.success ? .green : .red)

                    Text(result.message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Trade summary
                VStack(spacing: 16) {
                    TradeResultSummary(
                        playerOut: result.playerOut,
                        playerIn: result.playerIn,
                        netCost: result.netCost
                    )
                }

                Spacer()

                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .navigationTitle("Trade Result")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - TradeResultSummary

struct TradeResultSummary: View {
    let playerOut: EnhancedPlayer
    let playerIn: EnhancedPlayer
    let netCost: Int

    var body: some View {
        VStack(spacing: 12) {
            Text("Trade Summary")
                .font(.headline)
                .fontWeight(.semibold)

            HStack {
                VStack(spacing: 4) {
                    Text("OUT")
                        .font(.caption)
                        .foregroundColor(.red)

                    Text(playerOut.name)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(playerOut.formattedPrice)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)

                VStack(spacing: 4) {
                    Text("IN")
                        .font(.caption)
                        .foregroundColor(.green)

                    Text(playerIn.name)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(playerIn.formattedPrice)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }

            Divider()

            HStack {
                Text("Net Cost:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Text(formatPrice(netCost))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(netCost <= 0 ? .green : .primary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func formatPrice(_ price: Int) -> String {
        let absPrice = abs(price)
        let sign = price >= 0 ? "+" : "-"

        if absPrice >= 1000 {
            return "\(sign)$\(absPrice / 1000)k"
        } else {
            return "\(sign)$\(absPrice)"
        }
    }
}

// MARK: - Preview

#Preview {
    EnhancedTradeCalculatorView(
        playerOut: .constant(nil),
        playerIn: .constant(nil),
        onPlayerOutTap: {},
        onPlayerInTap: {}
    )
    .environmentObject(AppState())
    .environmentObject(AFLFantasyDataService())
}
