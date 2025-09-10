import SwiftUI
import Charts

struct CashCowAnalyzerView: View {
    @StateObject private var viewModel = CashCowAnalyzerViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Theme.Colors.background
                    .ignoresSafeArea()
                
                // Content
                VStack(spacing: 0) {
                    // Custom Navigation Bar
                    NavigationBar(
                        "Cash Cow Analyzer",
                        leadingContent: {
                            NavigationBarButton(icon: "chevron.left") {
                                dismiss()
                            }
                        }
                    )
                    
                    ScrollView {
                        VStack(spacing: Theme.Spacing.l) {
                            // Overview Card
                            CashGenerationCard(stats: viewModel.cashStats)
                            
                            // Break-even Analysis
                            BreakEvenCard(
                                targets: viewModel.breakEvenTargets,
                                selection: $viewModel.selectedTarget
                            )
                            
                            // Potential Sells
                            if !viewModel.sellRecommendations.isEmpty {
                                PotentialSellsCard(
                                    recommendations: viewModel.sellRecommendations
                                )
                            }
                            
                            // Hold Recommendations
                            if !viewModel.holdRecommendations.isEmpty {
                                HoldRecommendationsCard(
                                    recommendations: viewModel.holdRecommendations
                                )
                            }
                            
                            // Cash Cow Watchlist
                            if !viewModel.watchlistPlayers.isEmpty {
                                WatchlistCard(players: viewModel.watchlistPlayers)
                            }
                        }
                        .padding()
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .onAppear {
                viewModel.loadData()
            }
        }
    }
}

// MARK: - Supporting Views

struct BreakEvenCard: View {
    let targets: [BreakEvenTarget]
    @Binding var selection: BreakEvenTarget.TimeFrame?
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            // Header
            HStack {
                Text("Break-even Analysis")
                    .font(Theme.Font.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                // Time frame picker
                Picker("Time Frame", selection: $selection) {
                    Text("2W")
                        .tag(Optional(BreakEvenTarget.TimeFrame.twoWeeks))
                    Text("3W")
                        .tag(Optional(BreakEvenTarget.TimeFrame.threeWeeks))
                    Text("4W")
                        .tag(Optional(BreakEvenTarget.TimeFrame.fourWeeks))
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
            }
            
            // Chart
            Chart {
                ForEach(targets) { target in
                    LineMark(
                        x: .value("Price", target.startPrice),
                        y: .value("Break-even Price", target.breakEvenPrice)
                    )
                    .foregroundStyle(by: .value("Time Frame", target.timeFrame.rawValue))
                    
                    PointMark(
                        x: .value("Price", target.startPrice),
                        y: .value("Break-even Price", target.breakEvenPrice)
                    )
                    .foregroundStyle(by: .value("Time Frame", target.timeFrame.rawValue))
                }
            }
            .chartForegroundStyleScale([
                "2 Weeks": Theme.Colors.primary,
                "3 Weeks": Theme.Colors.accent,
                "4 Weeks": Theme.Colors.success
            ])
            .chartLegend(.hidden)
            .frame(height: 200)
            
            // Legend
            HStack(spacing: Theme.Spacing.m) {
                ForEach(BreakEvenTarget.TimeFrame.allCases, id: \.rawValue) { timeFrame in
                    LegendItem(
                        color: legendColor(for: timeFrame),
                        label: timeFrame.rawValue
                    )
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private func legendColor(for timeFrame: BreakEvenTarget.TimeFrame) -> Color {
        switch timeFrame {
        case .twoWeeks:
            return Theme.Colors.primary
        case .threeWeeks:
            return Theme.Colors.accent
        case .fourWeeks:
            return Theme.Colors.success
        }
    }
}

struct PotentialSellsCard: View {
    let recommendations: [SellRecommendation]
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            // Header
            HStack {
                Text("Potential Sells")
                    .font(Theme.Font.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Text("\(recommendations.count) Players")
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            // Recommendations
            ForEach(recommendations) { rec in
                SellRecommendationRow(recommendation: rec)
            }
        }
        .padding()
        .cardStyle()
    }
}

struct SellRecommendationRow: View {
    let recommendation: SellRecommendation
    
    var body: some View {
        HStack(spacing: Theme.Spacing.m) {
            // Player Info
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(recommendation.playerName)
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("\(recommendation.position) • \(recommendation.breakEvenTarget.timeFrame.rawValue)")
                    .font(Theme.Font.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
            
            // Price Change
            VStack(alignment: .trailing, spacing: Theme.Spacing.xxs) {
                HStack(alignment: .lastTextBaseline, spacing: Theme.Spacing.xxs) {
                    Text("$\(recommendation.currentPrice / 1000)k")
                        .font(Theme.Font.bodyBold)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    TrendIndicator(
                        value: recommendation.priceChange,
                        inverted: false
                    )
                }
                
                Text("$\(abs(recommendation.priceChange) / 1000)k")
                    .font(Theme.Font.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            // Break-even Info
            VStack(alignment: .trailing, spacing: Theme.Spacing.xxs) {
                Text("BE: \(recommendation.breakEvenTarget.breakEvenPrice)")
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.accent)
                
                Text("Target")
                    .font(Theme.Font.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .padding()
        .background(Theme.Colors.background)
        .cornerRadius(Theme.Radius.medium)
    }
}

struct HoldRecommendationsCard: View {
    let recommendations: [HoldRecommendation]
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            // Header
            HStack {
                Text("Hold Recommendations")
                    .font(Theme.Font.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Text("\(recommendations.count) Players")
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            // Recommendations
            ForEach(recommendations) { rec in
                HoldRecommendationRow(recommendation: rec)
            }
        }
        .padding()
        .cardStyle()
    }
}

struct HoldRecommendationRow: View {
    let recommendation: HoldRecommendation
    
    var body: some View {
        HStack(spacing: Theme.Spacing.m) {
            // Player Info
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(recommendation.playerName)
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(recommendation.position)
                    .font(Theme.Font.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
            
            // Price Info
            VStack(alignment: .trailing, spacing: Theme.Spacing.xxs) {
                Text("$\(recommendation.currentPrice / 1000)k")
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("Current")
                    .font(Theme.Font.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            // Reason Tag
            Text(recommendation.reason)
                .font(Theme.Font.caption)
                .foregroundColor(Theme.Colors.success)
                .padding(.horizontal, Theme.Spacing.xs)
                .padding(.vertical, 2)
                .background(Theme.Colors.success.opacity(0.1))
                .cornerRadius(Theme.Radius.small)
        }
        .padding()
        .background(Theme.Colors.background)
        .cornerRadius(Theme.Radius.medium)
    }
}

struct WatchlistCard: View {
    let players: [WatchlistPlayer]
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            // Header
            HStack {
                Text("Cash Cow Watchlist")
                    .font(Theme.Font.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Text("\(players.count) Players")
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            // Players
            ForEach(players) { player in
                WatchlistPlayerRow(player: player)
            }
        }
        .padding()
        .cardStyle()
    }
}

struct WatchlistPlayerRow: View {
    let player: WatchlistPlayer
    
    var body: some View {
        HStack(spacing: Theme.Spacing.m) {
            // Player Info
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(player.name)
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(player.position)
                    .font(Theme.Font.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
            
            // Price Info
            VStack(alignment: .trailing, spacing: Theme.Spacing.xxs) {
                Text("$\(player.currentPrice / 1000)k")
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                HStack(alignment: .lastTextBaseline, spacing: Theme.Spacing.xxs) {
                    Text("BE: \(player.breakEven)")
                        .font(Theme.Font.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                    
                    TrendIndicator(value: player.projection)
                }
            }
            
            // Ownership Change
            VStack(alignment: .trailing, spacing: Theme.Spacing.xxs) {
                Text("\(String(format: "%.1f", player.ownership))%")
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                TrendIndicator(value: Int(player.ownershipChange * 100))
            }
        }
        .padding()
        .background(Theme.Colors.background)
        .cornerRadius(Theme.Radius.medium)
    }
}

// Using CashGenStats, BreakEvenTarget, SellRecommendation, HoldRecommendation, WatchlistPlayer from Models.swift

// MARK: - Preview

struct CashCowAnalyzerView_Previews: PreviewProvider {
    static var breakEvenTargets: [BreakEvenTarget] {
        [
            .init(startPrice: 180000, breakEvenPrice: 210000, timeFrame: .twoWeeks),
            .init(startPrice: 200000, breakEvenPrice: 240000, timeFrame: .twoWeeks),
            .init(startPrice: 180000, breakEvenPrice: 230000, timeFrame: .threeWeeks),
            .init(startPrice: 200000, breakEvenPrice: 260000, timeFrame: .threeWeeks),
            .init(startPrice: 180000, breakEvenPrice: 250000, timeFrame: .fourWeeks),
            .init(startPrice: 200000, breakEvenPrice: 280000, timeFrame: .fourWeeks)
        ]
    }
    
    static var sellRecommendations: [SellRecommendation] {
        [
            .init(
                playerName: "Nick Daicos",
                position: "DEF/MID",
                currentPrice: 450000,
                priceChange: 120000,
                breakEvenTarget: breakEvenTargets[0],
                confidence: 0.85
            ),
            .init(
                playerName: "Errol Gulden",
                position: "MID/FWD",
                currentPrice: 380000,
                priceChange: 80000,
                breakEvenTarget: breakEvenTargets[1],
                confidence: 0.75
            )
        ]
    }
    
    static var holdRecommendations: [HoldRecommendation] {
        [
            .init(
                playerName: "Harley Reid",
                position: "MID/FWD",
                currentPrice: 290000,
                reason: "Strong JS Score",
                weeksToHold: 2
            ),
            .init(
                playerName: "Colby McKercher",
                position: "MID",
                currentPrice: 270000,
                reason: "Good Fixtures",
                weeksToHold: 3
            )
        ]
    }
    
    static var watchlistPlayers: [WatchlistPlayer] {
        [
            .init(
                name: "Caleb Windsor",
                position: "FWD",
                currentPrice: 200000,
                breakEven: -20,
                projection: 15,
                ownership: 5.2,
                ownershipChange: 0.8
            ),
            .init(
                name: "James Borlase",
                position: "DEF",
                currentPrice: 190000,
                breakEven: -15,
                projection: 10,
                ownership: 3.8,
                ownershipChange: 1.2
            )
        ]
    }
    
    static var previews: some View {
        CashCowAnalyzerView()
            .previewDisplayName("Full Screen")
        
        ScrollView {
            VStack(spacing: Theme.Spacing.m) {
                BreakEvenCard(
                    targets: breakEvenTargets,
                    selection: .constant(.twoWeeks)
                )
                
                PotentialSellsCard(
                    recommendations: sellRecommendations
                )
                
                HoldRecommendationsCard(
                    recommendations: holdRecommendations
                )
                
                WatchlistCard(
                    players: watchlistPlayers
                )
            }
            .padding()
        }
        .previewDisplayName("Components")
        .previewLayout(.sizeThatFits)
    }
}

// MARK: - Legend Helper

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(Theme.Font.caption)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
}
