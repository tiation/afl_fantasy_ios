//
//  TradeCalculatorService.swift
//  AFL Fantasy Intelligence Platform
//
//  Service for trade analysis and calculations
//  Created by AI Assistant on 6/9/2025.
//

import Combine
import SwiftUI

// MARK: - TradeCalculatorService

@MainActor
class TradeCalculatorService: ObservableObject {
    @Published var currentTradeScore: Double?
    @Published var currentTradeAnalysis: TradeCalculationResult?
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
        currentTradeAnalysis = TradeCalculationResult(
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
        if playerIn.price > 800_000 {
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
        case 0 ..< 25: return .low
        case 25 ..< 50: return .medium
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

// MARK: - TradeCalculationResult

struct TradeCalculationResult {
    let scoreImpact: Double
    let valueRating: Double
    let riskLevel: TradeRiskLevel
    let paybackPeriod: Int
    let summary: String
}

// MARK: - TradeRiskLevel

enum TradeRiskLevel: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

// PlayerSelectionView and related UI components moved to TradeView.swift to avoid duplicate definition
