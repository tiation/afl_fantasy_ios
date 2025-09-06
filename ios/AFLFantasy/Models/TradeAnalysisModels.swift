//
//  TradeAnalysisModels.swift
//  AFL Fantasy Intelligence Platform
//
//  Trade analysis data models and AI recommendation structures
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import SwiftUI

// MARK: - TradeAnalysis

struct TradeAnalysis: Identifiable, Codable {
    let id = UUID()
    let playerOutId: String
    let playerInId: String
    let impactScore: Int // 0-100 score indicating trade quality
    let netCashImpact: Int // In dollars
    let projectedPointsDifference: Double // Points per week difference
    let riskFactors: [RiskFactor]
    let recommendation: TradeRecommendation
    let analysisDate: Date

    init(
        playerOutId: String,
        playerInId: String,
        impactScore: Int,
        netCashImpact: Int,
        projectedPointsDifference: Double,
        riskFactors: [RiskFactor],
        recommendation: TradeRecommendation
    ) {
        self.playerOutId = playerOutId
        self.playerInId = playerInId
        self.impactScore = impactScore
        self.netCashImpact = netCashImpact
        self.projectedPointsDifference = projectedPointsDifference
        self.riskFactors = riskFactors
        self.recommendation = recommendation
        analysisDate = Date()
    }
}

// MARK: - RiskFactor

struct RiskFactor: Identifiable, Codable {
    let id = UUID()
    let type: RiskType
    let description: String
    let severity: RiskSeverity
    let impact: Double // 0.0-1.0 impact on trade score

    var icon: String {
        switch type {
        case .injury: "cross.fill"
        case .suspension: "exclamationmark.triangle.fill"
        case .formDrop: "chart.line.downtrend.xyaxis"
        case .priceVolatility: "dollarsign.circle"
        case .roleChange: "arrow.2.squarepath"
        case .fixtureComplexity: "calendar.badge.exclamationmark"
        case .weatherRisk: "cloud.rain.fill"
        case .teamStrategy: "person.3.fill"
        }
    }
}

// MARK: - RiskType

enum RiskType: String, Codable, CaseIterable {
    case injury
    case suspension
    case formDrop = "form_drop"
    case priceVolatility = "price_volatility"
    case roleChange = "role_change"
    case fixtureComplexity = "fixture_complexity"
    case weatherRisk = "weather_risk"
    case teamStrategy = "team_strategy"
}

// MARK: - RiskSeverity

enum RiskSeverity: String, Codable, CaseIterable {
    case low
    case medium
    case high
    case critical

    var color: Color {
        switch self {
        case .low: .green
        case .medium: .yellow
        case .high: .orange
        case .critical: .red
        }
    }
}

// MARK: - TradeRecommendation

struct TradeRecommendation: Codable {
    let action: TradeAction
    let title: String
    let reasoning: String
    let confidence: Double // 0.0-1.0
    let urgency: TradeUrgency

    var icon: String {
        switch action {
        case .recommend: "checkmark.circle.fill"
        case .caution: "exclamationmark.triangle.fill"
        case .avoid: "xmark.circle.fill"
        case .wait: "clock.fill"
        }
    }

    var color: Color {
        switch action {
        case .recommend: .green
        case .caution: .orange
        case .avoid: .red
        case .wait: .blue
        }
    }
}

// MARK: - TradeAction

enum TradeAction: String, Codable, CaseIterable {
    case recommend
    case caution
    case avoid
    case wait
}

// MARK: - TradeUrgency

enum TradeUrgency: String, Codable, CaseIterable {
    case immediate
    case thisRound = "this_round"
    case nextRound = "next_round"
    case flexible
}

// MARK: - AITradeSuggestion

struct AITradeSuggestion: Identifiable, Codable {
    let id = UUID()
    let title: String
    let rationale: String
    let playerOut: String
    let playerIn: String
    let projectedGain: Int // Points per week
    let confidence: Double // 0.0-1.0
    let category: SuggestionCategory
    let priority: SuggestionPriority

    init(
        title: String,
        rationale: String,
        playerOut: String,
        playerIn: String,
        projectedGain: Int,
        confidence: Double,
        category: SuggestionCategory,
        priority: SuggestionPriority
    ) {
        self.title = title
        self.rationale = rationale
        self.playerOut = playerOut
        self.playerIn = playerIn
        self.projectedGain = projectedGain
        self.confidence = confidence
        self.category = category
        self.priority = priority
    }
}

// MARK: - SuggestionCategory

enum SuggestionCategory: String, Codable, CaseIterable {
    case cashCowUpgrade = "cash_cow_upgrade"
    case premiumFix = "premium_fix"
    case formPlayer = "form_player"
    case injuryReplacement = "injury_replacement"
    case fixtureOptimization = "fixture_optimization"
    case valueCapture = "value_capture"
}

// MARK: - SuggestionPriority

enum SuggestionPriority: String, Codable, CaseIterable {
    case critical
    case high
    case medium
    case low

    var color: Color {
        switch self {
        case .critical: .red
        case .high: .orange
        case .medium: .blue
        case .low: .gray
        }
    }
}

// MARK: - TradeAnalyzer

@MainActor
class TradeAnalyzer: ObservableObject {
    @Published var isAnalyzing = false
    @Published var lastAnalysis: TradeAnalysis?

    private let logger = AFLLogger.shared

    func analyzeTrade(playerOut: EnhancedPlayer, playerIn: EnhancedPlayer) async -> TradeAnalysis {
        isAnalyzing = true
        logger.info("🔄 Analyzing trade: \(playerOut.name) → \(playerIn.name)")

        defer { isAnalyzing = false }

        // Simulate API call delay for realistic UX
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        let analysis = await performTradeAnalysis(playerOut: playerOut, playerIn: playerIn)
        lastAnalysis = analysis

        logger.info("✅ Trade analysis complete. Impact score: \(analysis.impactScore)")
        return analysis
    }

    private func performTradeAnalysis(playerOut: EnhancedPlayer, playerIn: EnhancedPlayer) async -> TradeAnalysis {
        // Calculate financial impact
        let netCashImpact = playerOut.price - playerIn.price

        // Calculate projected points difference
        let projectedDifference = playerIn.nextRoundProjection.projectedScore - playerOut.nextRoundProjection
            .projectedScore

        // Assess risk factors
        let riskFactors = await assessRiskFactors(playerOut: playerOut, playerIn: playerIn)

        // Calculate impact score (0-100)
        let impactScore = calculateImpactScore(
            projectedDifference: projectedDifference,
            netCashImpact: netCashImpact,
            riskFactors: riskFactors,
            playerOut: playerOut,
            playerIn: playerIn
        )

        // Generate recommendation
        let recommendation = generateRecommendation(
            impactScore: impactScore,
            riskFactors: riskFactors,
            projectedDifference: projectedDifference
        )

        return TradeAnalysis(
            playerOutId: playerOut.id,
            playerInId: playerIn.id,
            impactScore: impactScore,
            netCashImpact: netCashImpact,
            projectedPointsDifference: projectedDifference,
            riskFactors: riskFactors,
            recommendation: recommendation
        )
    }

    private func assessRiskFactors(playerOut: EnhancedPlayer, playerIn: EnhancedPlayer) async -> [RiskFactor] {
        var factors: [RiskFactor] = []

        // Injury risk assessment
        if playerIn.injuryRisk.riskLevel != .low {
            factors.append(RiskFactor(
                type: .injury,
                description: "\(playerIn.name) has \(playerIn.injuryRisk.riskLevel.rawValue) injury risk",
                severity: mapInjuryRiskToSeverity(playerIn.injuryRisk.riskLevel),
                impact: Double(playerIn.injuryRisk.riskLevel.rawValue == "high" ? 0.3 : 0.15)
            ))
        }

        // Form analysis
        let playerInForm = Double(playerIn.currentScore) / playerIn.averageScore
        if playerInForm < 0.85 {
            factors.append(RiskFactor(
                type: .formDrop,
                description: "\(playerIn.name) is below form average",
                severity: playerInForm < 0.7 ? .high : .medium,
                impact: playerInForm < 0.7 ? 0.25 : 0.15
            ))
        }

        // Price volatility
        if abs(playerIn.priceChange) > 50000 {
            factors.append(RiskFactor(
                type: .priceVolatility,
                description: "\(playerIn.name) has high price volatility",
                severity: .medium,
                impact: 0.1
            ))
        }

        // Fixture complexity - simulated
        let upcomingDifficulty = calculateFixtureDifficulty(for: playerIn)
        if upcomingDifficulty > 0.7 {
            factors.append(RiskFactor(
                type: .fixtureComplexity,
                description: "\(playerIn.name) has difficult upcoming fixtures",
                severity: upcomingDifficulty > 0.85 ? .high : .medium,
                impact: upcomingDifficulty > 0.85 ? 0.2 : 0.1
            ))
        }

        return factors
    }

    private func calculateImpactScore(
        projectedDifference: Double,
        netCashImpact: Int,
        riskFactors: [RiskFactor],
        playerOut: EnhancedPlayer,
        playerIn: EnhancedPlayer
    ) -> Int {
        var score = 50 // Base score

        // Points differential impact (±40 points)
        let pointsImpact = Int(projectedDifference * 2) // Scale points difference
        score += min(max(pointsImpact, -40), 40)

        // Cash impact (±15 points)
        let cashImpact = netCashImpact / 10000 // Scale to reasonable range
        score += min(max(cashImpact, -15), 15)

        // Risk penalty
        let totalRiskImpact = riskFactors.reduce(0) { $0 + $1.impact }
        let riskPenalty = Int(totalRiskImpact * 30)
        score -= riskPenalty

        // Value play bonus - if getting premium player for good price
        if playerIn.averageScore > 100, playerIn.price < 600_000 {
            score += 10
        }

        // Cash cow optimization
        if playerOut.isCashCow, playerOut.breakeven < 30 {
            score += 15 // Good time to sell cash cow
        }

        return min(max(score, 0), 100)
    }

    private func generateRecommendation(
        impactScore: Int,
        riskFactors: [RiskFactor],
        projectedDifference: Double
    ) -> TradeRecommendation {
        let hasHighRisk = riskFactors.contains { $0.severity == .high || $0.severity == .critical }

        switch impactScore {
        case 80...:
            return TradeRecommendation(
                action: .recommend,
                title: "Excellent Trade",
                reasoning: "Strong projected points gain with manageable risk. Great value opportunity.",
                confidence: hasHighRisk ? 0.75 : 0.9,
                urgency: hasHighRisk ? .thisRound : .immediate
            )
        case 65 ..< 80:
            return TradeRecommendation(
                action: hasHighRisk ? .caution : .recommend,
                title: hasHighRisk ? "Good Trade with Risk" : "Good Trade",
                reasoning: hasHighRisk ? "Solid points gain but consider the identified risks." :
                    "Positive projected impact with reasonable risk profile.",
                confidence: 0.7,
                urgency: .thisRound
            )
        case 40 ..< 65:
            return TradeRecommendation(
                action: .caution,
                title: "Marginal Trade",
                reasoning: "Limited upside with some concerns. Consider alternatives or wait for better opportunities.",
                confidence: 0.5,
                urgency: .flexible
            )
        default:
            return TradeRecommendation(
                action: .avoid,
                title: "Poor Trade",
                reasoning: "Negative projected impact or high risk factors. Look for better options.",
                confidence: 0.8,
                urgency: .flexible
            )
        }
    }

    private func mapInjuryRiskToSeverity(_ riskLevel: InjuryRiskLevel) -> RiskSeverity {
        switch riskLevel {
        case .low: .low
        case .medium: .medium
        case .high: .high
        case .critical: .critical
        }
    }

    private func calculateFixtureDifficulty(for player: EnhancedPlayer) -> Double {
        // Simulate fixture difficulty calculation
        // In real implementation, this would analyze upcoming opponents, venues, etc.
        Double.random(in: 0.3 ... 0.9)
    }
}

// MARK: - AITradeSuggestionEngine

@MainActor
class AITradeSuggestionEngine: ObservableObject {
    @Published var suggestions: [AITradeSuggestion] = []
    @Published var isLoading = false

    private let logger = AFLLogger.shared

    func loadSuggestions() {
        guard suggestions.isEmpty else { return }

        isLoading = true
        logger.info("🧠 Loading AI trade suggestions")

        Task {
            await generateSuggestions()
            await MainActor.run {
                isLoading = false
            }
        }
    }

    private func generateSuggestions() async {
        // Simulate API call delay
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        let mockSuggestions = [
            AITradeSuggestion(
                title: "Premium Forward Upgrade",
                rationale: "Toby Greene has excellent upcoming fixtures and strong form",
                playerOut: "M. Pickett",
                playerIn: "T. Greene",
                projectedGain: 25,
                confidence: 0.85,
                category: .premiumFix,
                priority: .high
            ),
            AITradeSuggestion(
                title: "Cash Cow Harvest",
                rationale: "Darcy Wilson has peaked in price and unlikely to gain more",
                playerOut: "D. Wilson",
                playerIn: "J. Daicos",
                projectedGain: 18,
                confidence: 0.75,
                category: .cashCowUpgrade,
                priority: .medium
            ),
            AITradeSuggestion(
                title: "Form Play Opportunity",
                rationale: "Clayton Oliver returning from injury with favorable matchups",
                playerOut: "T. Mitchell",
                playerIn: "C. Oliver",
                projectedGain: 32,
                confidence: 0.78,
                category: .formPlayer,
                priority: .high
            )
        ]

        await MainActor.run {
            self.suggestions = mockSuggestions
            logger.info("✅ Loaded \(mockSuggestions.count) AI trade suggestions")
        }
    }
}
