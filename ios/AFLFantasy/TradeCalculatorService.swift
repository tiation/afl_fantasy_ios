//
//  TradeCalculatorService.swift
//  AFL Fantasy Intelligence Platform
//
//  Service for trade analysis and calculations
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI
import Combine

// MARK: - Trade Calculator Service

@MainActor
class TradeCalculatorService: ObservableObject {
    @Published var currentTradeScore: Double?
    @Published var currentTradeAnalysis: TradeAnalysis?
    @Published var isCalculating = false
    
    // MARK: - Trade Analysis
    
    func calculateTrade(playerOut: EnhancedPlayer, playerIn: EnhancedPlayer) {
        isCalculating = true
        
        // Simulate calculation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.performTradeAnalysis(playerOut: playerOut, playerIn: playerIn)
            self?.isCalculating = false
        }
    }
    
    func clearTrade() {
        currentTradeScore = nil
        currentTradeAnalysis = nil
    }
    
    // MARK: - Private Methods
    
    private func performTradeAnalysis(playerOut: EnhancedPlayer, playerIn: EnhancedPlayer) {
        // Calculate score impact
        let scoreImpact = playerIn.averageScore - playerOut.averageScore
        
        // Calculate value rating (0-10 scale)
        let priceRatio = Double(playerOut.price) / Double(playerIn.price)
        let scoreRatio = playerIn.averageScore / playerOut.averageScore
        let valueRating = min(10.0, max(0.0, (scoreRatio / priceRatio) * 5.0))
        
        // Calculate risk level
        let riskLevel = calculateRiskLevel(playerOut: playerOut, playerIn: playerIn)
        
        // Calculate payback period (rounds to recover trade cost)
        let netCost = playerIn.price - playerOut.price
        let weeklyGain = scoreImpact
        let paybackPeriod = weeklyGain > 0 ? max(1, Int(Double(netCost) / (weeklyGain * 1000))) : 999
        
        // Generate summary
        let summary = generateTradeSummary(
            scoreImpact: scoreImpact,
            valueRating: valueRating,
            riskLevel: riskLevel,
            paybackPeriod: paybackPeriod,
            netCost: netCost
        )
        
        // Calculate overall trade score (0-100)
        let tradeScore = calculateOverallTradeScore(
            scoreImpact: scoreImpact,
            valueRating: valueRating,
            riskLevel: riskLevel,
            paybackPeriod: paybackPeriod
        )
        
        // Create analysis object
        currentTradeAnalysis = TradeAnalysis(
            scoreImpact: scoreImpact,
            valueRating: valueRating,
            riskLevel: riskLevel,
            paybackPeriod: paybackPeriod,
            summary: summary
        )
        
        currentTradeScore = tradeScore
    }
    
    private func calculateRiskLevel(playerOut: EnhancedPlayer, playerIn: EnhancedPlayer) -> TradeRiskLevel {
        var riskScore = 0.0
        
        // Injury risk
        if playerIn.injuryRisk.riskLevel == .high {
            riskScore += 30
        } else if playerIn.injuryRisk.riskLevel == .medium {
            riskScore += 15
        }
        
        // Price volatility
        if playerIn.price > 800000 {
            riskScore += 10
        }
        
        // Consistency risk
        if playerIn.consistency < 70 {
            riskScore += 20
        }
        
        // Position change risk
        if playerOut.position != playerIn.position {
            riskScore += 10
        }
        
        // Form risk (if trading in a player with declining form)
        if playerIn.priceChange < -20000 {
            riskScore += 15
        }
        
        switch riskScore {
        case 0..<25: return .low
        case 25..<50: return .medium
        default: return .high
        }
    }
    
    private func calculateOverallTradeScore(
        scoreImpact: Double,
        valueRating: Double,
        riskLevel: TradeRiskLevel,
        paybackPeriod: Int
    ) -> Double {
        var score = 50.0 // Base score
        
        // Score impact component (40% weight)
        score += (scoreImpact * 2.0) // +/- 2 points per point of score difference
        
        // Value rating component (30% weight)
        score += (valueRating - 5.0) * 6.0 // Scale value rating to +/- 30
        
        // Risk adjustment (20% weight)
        switch riskLevel {
        case .low: score += 10
        case .medium: score += 0
        case .high: score -= 15
        }
        
        // Payback period adjustment (10% weight)
        if paybackPeriod <= 3 {
            score += 10
        } else if paybackPeriod <= 6 {
            score += 5
        } else if paybackPeriod > 10 {
            score -= 10
        }
        
        return min(100, max(0, score))
    }
    
    private func generateTradeSummary(
        scoreImpact: Double,
        valueRating: Double,
        riskLevel: TradeRiskLevel,
        paybackPeriod: Int,
        netCost: Int
    ) -> String {
        var summary = ""
        
        if scoreImpact > 5 {
            summary += "Excellent scoring upgrade. "
        } else if scoreImpact > 0 {
            summary += "Modest scoring improvement. "
        } else if scoreImpact < -5 {
            summary += "Significant scoring downgrade. "
        } else {
            summary += "Minimal scoring impact. "
        }
        
        if valueRating > 8 {
            summary += "Outstanding value trade. "
        } else if valueRating > 6 {
            summary += "Good value proposition. "
        } else if valueRating < 4 {
            summary += "Poor value for money. "
        }
        
        switch riskLevel {
        case .low:
            summary += "Low risk move. "
        case .medium:
            summary += "Moderate risk involved. "
        case .high:
            summary += "High risk trade - consider carefully. "
        }
        
        if paybackPeriod <= 3 {
            summary += "Quick return on investment."
        } else if paybackPeriod > 10 {
            summary += "Long payback period - consider alternatives."
        }
        
        return summary.trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Trade Analysis Model

struct TradeAnalysis {
    let scoreImpact: Double
    let valueRating: Double
    let riskLevel: TradeRiskLevel
    let paybackPeriod: Int
    let summary: String
}

enum TradeRiskLevel: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

// MARK: - Player Selection View

struct PlayerSelectionView: View {
    let title: String
    let players: [EnhancedPlayer]
    @Binding var selectedPlayer: EnhancedPlayer?
    @Binding var searchText: String
    @Binding var selectedPosition: Position?
    @Binding var priceRange: ClosedRange<Double>
    @Binding var sortOption: PlayerSortOption
    
    @Environment(\\.dismiss) private var dismiss
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search players...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Filters") {
                        showingFilters.toggle()
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Filter Bar
                if showingFilters {
                    filterSection
                }
                
                // Players List
                List(filteredPlayers, id: \\.id) { player in
                    PlayerSelectionRow(
                        player: player,
                        isSelected: selectedPlayer?.id == player.id,
                        onSelect: {
                            selectedPlayer = player
                            dismiss()
                        }
                    )
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        selectedPlayer = nil
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private var filterSection: some View {
        VStack(spacing: 12) {
            // Position Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "All",
                        isSelected: selectedPosition == nil,
                        onTap: { selectedPosition = nil }
                    )
                    
                    ForEach(Position.allCases, id: \\.self) { position in
                        FilterChip(
                            title: position.rawValue,
                            isSelected: selectedPosition == position,
                            onTap: { selectedPosition = position }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Sort Options
            HStack {
                Text("Sort by:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Sort", selection: $sortOption) {
                    ForEach(PlayerSortOption.allCases, id: \\.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
    
    private var filteredPlayers: [EnhancedPlayer] {
        var filtered = players
        
        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Position filter
        if let position = selectedPosition {
            filtered = filtered.filter { $0.position == position }
        }
        
        // Price range filter
        filtered = filtered.filter {
            let price = Double($0.price)
            return price >= priceRange.lowerBound && price <= priceRange.upperBound
        }
        
        // Sort
        switch sortOption {
        case .price:
            filtered.sort { $0.price < $1.price }
        case .average:
            filtered.sort { $0.averageScore > $1.averageScore }
        case .name:
            filtered.sort { $0.name < $1.name }
        case .position:
            filtered.sort { $0.position.rawValue < $1.position.rawValue }
        }
        
        return filtered
    }
}

// MARK: - Player Selection Row

struct PlayerSelectionRow: View {
    let player: EnhancedPlayer
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Position Indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(player.position.color)
                    .frame(width: 4, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(player.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(player.formattedPrice)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    
                    HStack {
                        Text(player.position.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(player.position.color.opacity(0.2))
                            .cornerRadius(4)
                        
                        Text("Avg: \\(String(format: "%.1f", player.averageScore))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if player.isCashCow {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                        
                        if player.isDoubtful {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 4)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.orange : Color(.systemGray5))
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
