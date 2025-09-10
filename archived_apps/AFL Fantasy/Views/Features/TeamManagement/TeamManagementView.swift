import SwiftUI

struct TeamManagementView: View {
    @StateObject private var viewModel = TeamManagementViewModel()
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
                        "Team Management",
                        leadingContent: {
                            NavigationBarButton(icon: "chevron.left") {
                                dismiss()
                            }
                        },
                        trailingContent: {
                            HStack(spacing: 0) {
                                NavigationBarButton(
                                    icon: "rectangle.stack.badge.plus",
                                    isActive: viewModel.selectedLineId != nil
                                ) {
                                    viewModel.saveLine()
                                }
                                
                                NavigationBarButton(
                                    icon: "arrow.2.circlepath",
                                    isActive: viewModel.isOptimized
                                ) {
                                    viewModel.optimizeTeam()
                                }
                            }
                        }
                    )
                    
                    if viewModel.isLoading {
                        // Loading State
                        ProgressView()
                            .progressViewStyle(.circular)
                            .frame(maxHeight: .infinity)
                    } else {
                        // Team Content
                        ScrollView {
                            VStack(spacing: Theme.Spacing.l) {
                                // Saved Lines
                                SavedLinesCard(
                                    lines: viewModel.savedLines,
                                    selectedId: $viewModel.selectedLineId
                                )
                                
                                // Field View
                                FieldView(
                                    lineup: viewModel.currentLineup,
                                    onPlayerTap: { player in
                                        // TODO: Navigate to player details
                                    }
                                )
                                
                                // Line Structure Analysis
                                if let structure = viewModel.teamStructure {
                                    TeamStructureChart(
                                        structure: structure,
                                        showDetails: false
                                    )
                                }
                                
                                // Line Salary Info
                                SalaryInfoCard(
                                    info: viewModel.salaryInfo
                                )
                                
                                // Suggested Trades
                                if !viewModel.suggestedTrades.isEmpty {
                                    SuggestedTradesCard(
                                        trades: viewModel.suggestedTrades
                                    )
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await viewModel.loadData()
                        }
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .task {
                await viewModel.loadData()
            }
        }
    }
}

// MARK: - Supporting Views

struct SavedLinesCard: View {
    let lines: [SavedLine]
    @Binding var selectedId: String?
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            // Header
            HStack {
                Text("Saved Lines")
                    .font(Theme.Font.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Text("\(lines.count) Lines")
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            // Lines
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.s) {
                    ForEach(lines) { line in
                        SavedLineItem(
                            line: line,
                            isSelected: selectedId == line.id
                        ) {
                            if selectedId == line.id {
                                selectedId = nil
                            } else {
                                selectedId = line.id
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

struct SavedLineItem: View {
    let line: SavedLine
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            // Name & Score
            VStack(spacing: Theme.Spacing.xxs) {
                Text(line.name)
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("\(line.totalScore) pts")
                    .font(Theme.Font.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            // Structure Summary
            HStack(spacing: Theme.Spacing.s) {
                PositionCount(position: "DEF", count: line.defCount)
                PositionCount(position: "MID", count: line.midCount)
                PositionCount(position: "RUC", count: line.rucCount)
                PositionCount(position: "FWD", count: line.fwdCount)
            }
        }
        .padding()
        .frame(width: 150)
        .background(isSelected ? Theme.Colors.accent.opacity(0.1) : Theme.Colors.background)
        .cornerRadius(Theme.Radius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .stroke(isSelected ? Theme.Colors.accent : .clear)
        )
        .onTapGesture(perform: onTap)
    }
}

struct PositionCount: View {
    let position: String
    let count: Int
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xxs) {
            Text("\(count)")
                .font(Theme.Font.caption)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text(position)
                .font(Theme.Font.caption2)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
}

struct FieldView: View {
    let lineup: [FieldPlayer]
    let onPlayerTap: (FieldPlayer) -> Void
    
    var body: some View {
        VStack(spacing: Theme.Spacing.m) {
            // Field Title
            HStack {
                Text("On Field")
                    .font(Theme.Font.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Text("18 Players")
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            // Lines
            VStack(spacing: Theme.Spacing.s) {
                // Forwards
                HStack {
                    ForEach(getPlayers(for: .fwd)) { player in
                        FieldPlayerItem(player: player, onTap: onPlayerTap)
                    }
                }
                
                // Midfield
                HStack {
                    ForEach(getPlayers(for: .mid)) { player in
                        FieldPlayerItem(player: player, onTap: onPlayerTap)
                    }
                }
                
                // Ruck
                HStack {
                    ForEach(getPlayers(for: .ruc)) { player in
                        FieldPlayerItem(player: player, onTap: onPlayerTap)
                    }
                }
                
                // Defense
                HStack {
                    ForEach(getPlayers(for: .def)) { player in
                        FieldPlayerItem(player: player, onTap: onPlayerTap)
                    }
                }
            }
            
            // Bench
            VStack(spacing: Theme.Spacing.s) {
                Text("Bench")
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                HStack {
                    ForEach(getPlayers(for: .bench)) { player in
                        FieldPlayerItem(player: player, onTap: onPlayerTap)
                    }
                }
            }
            .padding(.top, Theme.Spacing.m)
        }
        .padding()
        .cardStyle()
    }
    
    private func getPlayers(for position: FieldPosition) -> [FieldPlayer] {
        switch position {
        case .def:
            return lineup.filter { $0.position == .defender && $0.isOnField }
        case .mid:
            return lineup.filter { $0.position == .midfielder && $0.isOnField }
        case .ruc:
            return lineup.filter { $0.position == .ruck && $0.isOnField }
        case .fwd:
            return lineup.filter { $0.position == .forward && $0.isOnField }
        case .bench:
            return lineup.filter { !$0.isOnField }
        }
    }
}

struct FieldPlayerItem: View {
    let player: FieldPlayer
    let onTap: (FieldPlayer) -> Void
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xxs) {
            // Player Name
            Text(player.name)
                .font(Theme.Font.caption)
                .foregroundColor(Theme.Colors.textPrimary)
                .lineLimit(1)
            
            // Price only (score not available in canonical FieldPlayer)
            Text("$\(player.price / 1000)k")
                .font(Theme.Font.caption)
                .foregroundColor(Theme.Colors.accent)
        }
        .padding(.vertical, Theme.Spacing.xs)
        .padding(.horizontal, Theme.Spacing.s)
        .background(Theme.Colors.background)
        .cornerRadius(Theme.Radius.small)
        .onTapGesture {
            onTap(player)
        }
    }
}

struct SalaryInfoCard: View {
    let info: SalaryInfo
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            // Header
            HStack {
                Text("Salary Info")
                    .font(Theme.Font.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Text("$\(info.totalSalary / 1000)k")
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            // Details Grid
            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: Theme.Spacing.m) {
                StatBox(
                    title: "Available",
                    value: "$\(info.availableSalary / 1000)k"
                )
                
                StatBox(
                    title: "Avg. Player",
                    value: "$\(info.averagePlayerPrice / 1000)k"
                )
                
                StatBox(
                    title: "Premium %",
                    value: "\(Int(info.premiumPercentage * 100))%"
                )
                
                StatBox(
                    title: "Rookie %",
                    value: "\(Int(info.rookiePercentage * 100))%"
                )
            }
        }
        .padding()
        .cardStyle()
    }
}

struct SuggestedTradesCard: View {
    let trades: [SuggestedTrade]
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            // Header
            HStack {
                Text("Suggested Trades")
                    .font(Theme.Font.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Text("\(trades.count) Options")
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            // Trades
            ForEach(trades) { trade in
                SuggestedTradeRow(trade: trade)
            }
        }
        .padding()
        .cardStyle()
    }
}

struct SuggestedTradeRow: View {
    let trade: SuggestedTrade
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            // Trade Players
            HStack(spacing: Theme.Spacing.m) {
                // Out Player
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(trade.playerOut.name)
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("OUT")
                        .font(Theme.Font.caption)
                        .foregroundColor(Theme.Colors.error)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Spacer()
                
                // In Player
                VStack(alignment: .trailing, spacing: Theme.Spacing.xxs) {
                Text(trade.playerIn.name)
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("IN")
                        .font(Theme.Font.caption)
                        .foregroundColor(Theme.Colors.success)
                }
            }
            
            // Trade Details
            HStack(spacing: Theme.Spacing.m) {
                // Score Impact
                StatBox(
                    title: "Score Impact",
                    value: "\(trade.projectedPointsGain > 0 ? "+" : "")\(Int(trade.projectedPointsGain))",
                    valueColor: trade.projectedPointsGain > 0 ? Theme.Colors.success : Theme.Colors.error
                )
                
                // Price Impact
                StatBox(
                    title: "Price Impact",
                    value: "$\(abs(trade.cashDifference) / 1000)k",
                    valueColor: trade.cashDifference > 0 ? Theme.Colors.success : Theme.Colors.error
                )
                
                // Break-even
                StatBox(
                    title: "Confidence",
                    value: "\(Int(trade.confidence * 100))%"
                )
            }
        }
        .padding()
        .background(Theme.Colors.background)
        .cornerRadius(Theme.Radius.medium)
    }
}

// MARK: - Data Models

// FieldPlayer, SavedLine, SalaryInfo, SuggestedTrade are defined in Models/Models.swift

enum FieldPosition {
    case def
    case mid
    case ruc
    case fwd
    case bench
}

// MARK: - Preview

struct TeamManagementView_Previews: PreviewProvider {
    static var sampleLines: [SavedLine] {
        [
            .init(id: "1", name: "Best 22", lineup: [], createdDate: Date(), totalValue: 12500000, totalScore: 2150, defCount: 6, midCount: 8, rucCount: 2, fwdCount: 6),
            .init(id: "2", name: "Value Line", lineup: [], createdDate: Date(), totalValue: 12000000, totalScore: 2080, defCount: 6, midCount: 8, rucCount: 2, fwdCount: 6),
            .init(id: "3", name: "No Risks", lineup: [], createdDate: Date(), totalValue: 11500000, totalScore: 1950, defCount: 6, midCount: 8, rucCount: 2, fwdCount: 6)
        ]
    }
    
    static var sampleLineup: [FieldPlayer] {
        [
            // Forwards
            .init(id: "1", name: "T. Greene", position: .forward, price: 450000, isOnField: true, isCaptain: false, isViceCaptain: false),
            .init(id: "2", name: "J. Amiss", position: .forward, price: 350000, isOnField: true, isCaptain: false, isViceCaptain: false),
            .init(id: "3", name: "N. Daicos", position: .forward, price: 650000, isOnField: true, isCaptain: true, isViceCaptain: false),
            
            // Midfield
            .init(id: "4", name: "M. Rowell", position: .midfielder, price: 550000, isOnField: true, isCaptain: false, isViceCaptain: false),
            .init(id: "5", name: "C. Mills", position: .midfielder, price: 750000, isOnField: true, isCaptain: false, isViceCaptain: true),
            .init(id: "6", name: "L. Neale", position: .midfielder, price: 850000, isOnField: true, isCaptain: false, isViceCaptain: false),
            
            // Ruck
            .init(id: "7", name: "M. Gawn", position: .ruck, price: 850000, isOnField: true, isCaptain: false, isViceCaptain: false),
            
            // Defense
            .init(id: "8", name: "J. Sicily", position: .defender, price: 650000, isOnField: true, isCaptain: false, isViceCaptain: false),
            .init(id: "9", name: "L. Ryan", position: .defender, price: 450000, isOnField: true, isCaptain: false, isViceCaptain: false),
            .init(id: "10", name: "N. Vlastuin", position: .defender, price: 400000, isOnField: true, isCaptain: false, isViceCaptain: false),
            
            // Bench
            .init(id: "11", name: "M. Johnson", position: .midfielder, price: 250000, isOnField: false, isCaptain: false, isViceCaptain: false),
            .init(id: "12", name: "C. Warner", position: .forward, price: 280000, isOnField: false, isCaptain: false, isViceCaptain: false)
        ]
    }
    
    static var sampleTrades: [SuggestedTrade] {
        let outPlayer1 = Player(id: "9", name: "L. Ryan", team: "WCE", position: .defender, price: 450000, average: 90.0, projected: 88.0, breakeven: 85, consistency: .b, priceChange: -5000, ownership: 0.15, injuryStatus: .healthy, venueStats: nil, formFactor: nil, dvpImpact: nil)
        let inPlayer1 = Player(id: "20", name: "J. Ridley", team: "ESS", position: .defender, price: 400000, average: 102.0, projected: 100.0, breakeven: 75, consistency: .a, priceChange: 8000, ownership: 0.25, injuryStatus: .healthy, venueStats: nil, formFactor: nil, dvpImpact: nil)
        
        let outPlayer2 = Player(id: "10", name: "N. Vlastuin", team: "RIC", position: .defender, price: 400000, average: 85.0, projected: 82.0, breakeven: 75, consistency: .c, priceChange: -3000, ownership: 0.12, injuryStatus: .healthy, venueStats: nil, formFactor: nil, dvpImpact: nil)
        let inPlayer2 = Player(id: "21", name: "B. Dale", team: "GWS", position: .defender, price: 370000, average: 93.0, projected: 90.0, breakeven: 65, consistency: .b, priceChange: 5000, ownership: 0.18, injuryStatus: .healthy, venueStats: nil, formFactor: nil, dvpImpact: nil)
        
        return [
            .init(id: "trade1", playerOut: outPlayer1, playerIn: inPlayer1, cashDifference: -50000, projectedPointsGain: 12.0, confidence: 0.85, reasoning: "Ridley offers better scoring potential and value"),
            .init(id: "trade2", playerOut: outPlayer2, playerIn: inPlayer2, cashDifference: -30000, projectedPointsGain: 8.0, confidence: 0.75, reasoning: "Dale has better role and consistency")
        ]
    }
    
    static var previews: some View {
        TeamManagementView()
            .previewDisplayName("Full Screen")
        
        ScrollView {
            VStack(spacing: Theme.Spacing.m) {
                SavedLinesCard(
                    lines: sampleLines,
                    selectedId: .constant("1")
                )
                
                FieldView(
                    lineup: sampleLineup,
                    onPlayerTap: { _ in }
                )
                
                SalaryInfoCard(
                    info: SalaryInfo(
                        totalSalary: 12500000,
                        availableSalary: 250000,
                        averagePlayerPrice: 568000,
                        premiumPercentage: 0.35,
                        rookiePercentage: 0.25
                    )
                )
                
                SuggestedTradesCard(
                    trades: sampleTrades
                )
            }
            .padding()
        }
        .previewDisplayName("Components")
        .previewLayout(.sizeThatFits)
    }
}
