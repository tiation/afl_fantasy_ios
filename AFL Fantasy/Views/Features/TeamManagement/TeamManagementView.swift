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
            .onAppear {
                viewModel.loadData()
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
        lineup.filter { $0.position == position }
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
                    Text(trade.outPlayer)
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
                    Text(trade.inPlayer)
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
                    value: "\(trade.scoreImpact > 0 ? "+" : "")\(trade.scoreImpact)",
                    valueColor: trade.scoreImpact > 0 ? Theme.Colors.success : Theme.Colors.error
                )
                
                // Price Impact
                StatBox(
                    title: "Price Impact",
                    value: "$\(abs(trade.priceImpact) / 1000)k",
                    valueColor: trade.priceImpact > 0 ? Theme.Colors.success : Theme.Colors.error
                )
                
                // Break-even
                StatBox(
                    title: "Break-even",
                    value: String(trade.breakEven)
                )
            }
        }
        .padding()
        .background(Theme.Colors.background)
        .cornerRadius(Theme.Radius.medium)
    }
}

// MARK: - Data Models

struct SavedLine: Identifiable {
    let id: String
    let name: String
    let totalScore: Int
    let defCount: Int
    let midCount: Int
    let rucCount: Int
    let fwdCount: Int
}

// FieldPlayer is defined in Models/Models.swift

enum FieldPosition {
    case def
    case mid
    case ruc
    case fwd
    case bench
}

struct SalaryInfo {
    let totalSalary: Int
    let availableSalary: Int
    let averagePlayerPrice: Int
    let premiumPercentage: Double
    let rookiePercentage: Double
}

struct SuggestedTrade: Identifiable {
    let id = UUID()
    let outPlayer: String
    let inPlayer: String
    let scoreImpact: Int
    let priceImpact: Int
    let breakEven: Int
}

// MARK: - Preview

struct TeamManagementView_Previews: PreviewProvider {
    static var sampleLines: [SavedLine] {
        [
            .init(id: "1", name: "Best 22", totalScore: 2150, defCount: 6, midCount: 8, rucCount: 2, fwdCount: 6),
            .init(id: "2", name: "Value Line", totalScore: 2080, defCount: 6, midCount: 8, rucCount: 2, fwdCount: 6),
            .init(id: "3", name: "No Risks", totalScore: 1950, defCount: 6, midCount: 8, rucCount: 2, fwdCount: 6)
        ]
    }
    
    static var sampleLineup: [FieldPlayer] {
        [
            // Forwards
            .init(id: "1", name: "T. Greene", position: .fwd, score: 95, price: 450000),
            .init(id: "2", name: "J. Amiss", position: .fwd, score: 85, price: 350000),
            .init(id: "3", name: "N. Daicos", position: .fwd, score: 110, price: 650000),
            
            // Midfield
            .init(id: "4", name: "M. Rowell", position: .mid, score: 105, price: 550000),
            .init(id: "5", name: "C. Mills", position: .mid, score: 115, price: 750000),
            .init(id: "6", name: "L. Neale", position: .mid, score: 120, price: 850000),
            
            // Ruck
            .init(id: "7", name: "M. Gawn", position: .ruc, score: 125, price: 850000),
            
            // Defense
            .init(id: "8", name: "J. Sicily", position: .def, score: 100, price: 650000),
            .init(id: "9", name: "L. Ryan", position: .def, score: 90, price: 450000),
            .init(id: "10", name: "N. Vlastuin", position: .def, score: 85, price: 400000),
            
            // Bench
            .init(id: "11", name: "M. Johnson", position: .bench, score: 65, price: 250000),
            .init(id: "12", name: "C. Warner", position: .bench, score: 70, price: 280000)
        ]
    }
    
    static var sampleTrades: [SuggestedTrade] {
        [
            .init(outPlayer: "L. Ryan", inPlayer: "J. Ridley", scoreImpact: 12, priceImpact: -50000, breakEven: 85),
            .init(outPlayer: "N. Vlastuin", inPlayer: "B. Dale", scoreImpact: 8, priceImpact: -30000, breakEven: 75)
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
