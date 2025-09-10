//
//  AdvancedAnalyticsService.swift
//  AFL Fantasy Intelligence Platform
//
//  Advanced Analytics Service for Cash Generation, Price Prediction, and Performance Analysis
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import SwiftUI

// MARK: - AdvancedAnalyticsService

@MainActor
class AdvancedAnalyticsService: ObservableObject {
    // MARK: - Cash Generation Analytics

    func analyzeCashGeneration(for players: [Player]) -> [CashCowAnalysis] {
        let cashCows = players.filter(\.isCashCow)

        return cashCows.map { player in
            let sellWindow = calculateOptimalSellWindow(player: player)
            let holdRisk = calculateHoldRisk(player: player)
            let recommendation = determineCashCowRecommendation(
                player: player,
                sellWindow: sellWindow,
                holdRisk: holdRisk
            )

            return CashCowAnalysis(
                player: player,
                cashGenerated: player.cashGenerated,
                projectedFinalPrice: player.seasonProjection.finalPrice,
                totalGainPotential: player.seasonProjection.totalPriceRise,
                sellWindow: sellWindow,
                holdRisk: holdRisk,
                sellRecommendation: recommendation
            )
        }.sorted { $0.sellWindow.confidence > $1.sellWindow.confidence }
    }

    private func calculateOptimalSellWindow(player: Player) -> SellWindow {
        // Analyze price trajectory and find optimal sell point
        let projections = player.threeRoundProjection + [player.nextRoundProjection]

        var bestRound = projections[0].round
        var maxValue = 0.0
        var confidence = 0.0

        for (index, projection) in projections.enumerated() {
            // Calculate value score (price + projected points)
            let priceScore = Double(projection.priceChange) / 1000.0 // Normalize price changes
            let pointsScore = projection.projectedScore / 10.0 // Normalize points
            let riskAdjustment = 1.0 - (Double(index) * 0.1) // Prefer earlier rounds (less risk)

            let totalValue = (priceScore + pointsScore) * riskAdjustment

            if totalValue > maxValue {
                maxValue = totalValue
                bestRound = projection.round
                confidence = min(0.95, projection.confidence / 100.0 * riskAdjustment)
            }
        }

        return SellWindow(
            optimalRound: bestRound,
            earliestRound: max(1, bestRound - 1),
            latestRound: min(23, bestRound + 2),
            confidence: confidence
        )
    }

    private func calculateHoldRisk(player: Player) -> Double {
        var riskFactors: [Double] = []

        // Risk Factor 1: Injury history
        let injuryRisk = player.injuryRisk.riskScore / 100.0
        riskFactors.append(injuryRisk * 0.3)

        // Risk Factor 2: Price trajectory flattening
        let priceSlowdown = 1.0 - player.priceChangeProbability
        riskFactors.append(priceSlowdown * 0.25)

        // Risk Factor 3: Role stability
        let roleStability = player.volatility > 20 ? 0.2 : 0.0
        riskFactors.append(roleStability)

        // Risk Factor 4: Competition for spot
        let competitionRisk = player.averageScore < 70 ? 0.15 : 0.0
        riskFactors.append(competitionRisk)

        // Risk Factor 5: Late season fade
        let fadeRisk = player.seasonalTrend.fadeRisk * 0.1
        riskFactors.append(fadeRisk)

        return min(1.0, riskFactors.reduce(0.0, +))
    }

    private func determineCashCowRecommendation(
        player: Player,
        sellWindow: SellWindow,
        holdRisk: Double
    ) -> CashCowRecommendation {
        let currentRound = 10 // Would be dynamically determined

        if holdRisk > 0.7 {
            return .sellNow
        } else if sellWindow.optimalRound <= currentRound + 1 {
            return .sellSoon
        } else if player.seasonProjection.premiumPotential > 0.8 {
            return .keepLongTerm
        } else {
            return .hold
        }
    }

    // MARK: - Price Change Predictor

    func predictPriceChanges(for players: [Player]) -> [PlayerPricePrediction] {
        players.map { player in
            let nextRoundChange = predictNextRoundPriceChange(player: player)
            let threeRoundChange = predictThreeRoundPriceChange(player: player)
            let seasonEndPrice = predictSeasonEndPrice(player: player)

            return PlayerPricePrediction(
                player: player,
                nextRoundChange: nextRoundChange,
                threeRoundChange: threeRoundChange,
                seasonEndPrice: seasonEndPrice,
                confidence: calculatePredictionConfidence(player: player),
                factors: analyzePriceFactors(player: player)
            )
        }
    }

    private func predictNextRoundPriceChange(player: Player) -> PriceChangePrediction {
        let projection = player.nextRoundProjection
        let expectedScore = projection.projectedScore
        let breakeven = Double(player.breakeven)

        // Price change algorithm
        let scoreDifference = expectedScore - breakeven
        let priceChange = calculatePriceChangeFromScoreDifference(
            scoreDifference: scoreDifference,
            currentPrice: player.currentPrice
        )

        let probability = calculatePriceChangeProbability(
            scoreDifference: scoreDifference,
            confidence: projection.confidence
        )

        return PriceChangePrediction(
            amount: Int(priceChange),
            probability: probability,
            reasoning: generatePriceChangeReasoning(
                scoreDifference: scoreDifference,
                player: player
            )
        )
    }

    private func predictThreeRoundPriceChange(player: Player) -> PriceChangePrediction {
        let totalScoreDifference = player.threeRoundProjection.reduce(0.0) { acc, projection in
            acc + (projection.projectedScore - Double(player.breakeven))
        }

        let averageScoreDifference = totalScoreDifference / 3.0
        let cumulativePriceChange = calculatePriceChangeFromScoreDifference(
            scoreDifference: averageScoreDifference,
            currentPrice: player.currentPrice
        ) * 3.0 * 0.85 // Diminishing returns factor

        let confidence = player.threeRoundProjection.reduce(0.0) { $0 + $1.confidence } / 3.0
        let probability = calculatePriceChangeProbability(
            scoreDifference: averageScoreDifference,
            confidence: confidence
        )

        return PriceChangePrediction(
            amount: Int(cumulativePriceChange),
            probability: probability,
            reasoning: "Based on 3-round projection averaging \(Int(averageScoreDifference)) above/below breakeven"
        )
    }

    private func predictSeasonEndPrice(player: Player) -> Int {
        let remainingRounds = 23 - 10 // Simplified - current round would be dynamic
        let avgScoreDifference = player.seasonProjection.averageProjectedScore - Double(player.breakeven)

        let totalPriceChange = calculatePriceChangeFromScoreDifference(
            scoreDifference: avgScoreDifference,
            currentPrice: player.currentPrice
        ) * Double(remainingRounds) * 0.7 // Season-long diminishing returns

        return max(player.currentPrice + Int(totalPriceChange), 100_000) // Minimum price floor
    }

    private func calculatePriceChangeFromScoreDifference(scoreDifference: Double, currentPrice: Int) -> Double {
        // AFL Fantasy price change algorithm (simplified)
        let priceMultiplier = Double(currentPrice) / 500_000.0 // Normalize around $500k
        let baseChange = scoreDifference * 1500 * priceMultiplier // Base price change per point

        // Apply price change bands
        if scoreDifference > 20 {
            return baseChange * 1.2 // Bonus for exceptional scores
        } else if scoreDifference < -20 {
            return baseChange * 1.3 // Penalty for poor scores
        } else {
            return baseChange
        }
    }

    private func calculatePriceChangeProbability(scoreDifference: Double, confidence: Double) -> Double {
        let baseProb = confidence / 100.0

        // Adjust probability based on score difference magnitude
        if abs(scoreDifference) > 30 {
            return min(0.95, baseProb * 1.1)
        } else if abs(scoreDifference) > 15 {
            return baseProb
        } else {
            return baseProb * 0.85
        }
    }

    private func generatePriceChangeReasoning(scoreDifference: Double, player: Player) -> String {
        if scoreDifference > 15 {
            "Projected to score \(Int(scoreDifference)) above breakeven (\(player.breakeven))"
        } else if scoreDifference < -15 {
            "Projected to score \(Int(abs(scoreDifference))) below breakeven (\(player.breakeven))"
        } else {
            "Projected score close to breakeven - minimal price movement expected"
        }
    }

    private func calculatePredictionConfidence(player: Player) -> Double {
        var confidenceFactors: [Double] = []

        // Factor 1: Historical consistency
        confidenceFactors.append(player.consistency / 100.0 * 0.3)

        // Factor 2: Injury risk (inverse)
        confidenceFactors.append((1.0 - player.injuryRisk.riskScore / 100.0) * 0.2)

        // Factor 3: Role stability (inverse of volatility)
        confidenceFactors.append(max(0.0, (30.0 - player.volatility) / 30.0) * 0.2)

        // Factor 4: Recent form trend
        let trendBonus = player.seasonalTrend.trendDirection == .stable ? 0.2 :
            player.seasonalTrend.trendDirection == .improving ? 0.15 : 0.1
        confidenceFactors.append(trendBonus)

        // Factor 5: Data quality (games played)
        let dataQuality = min(1.0, Double(player.gamesPlayed) / 15.0) * 0.1
        confidenceFactors.append(dataQuality)

        return min(0.95, confidenceFactors.reduce(0.0, +))
    }

    private func analyzePriceFactors(player: Player) -> [PriceFactor] {
        var factors: [PriceFactor] = []

        // Positive factors
        if player.seasonalTrend.trendDirection == .improving {
            factors.append(PriceFactor(
                factor: "Improving Form",
                impact: .positive,
                weight: 0.25,
                description: "Player showing upward trend in scoring"
            ))
        }

        if player.consistency > 80 {
            factors.append(PriceFactor(
                factor: "High Consistency",
                impact: .positive,
                weight: 0.2,
                description: "Reliable scoring reduces price volatility risk"
            ))
        }

        if player.contractStatus.contractYear {
            factors.append(PriceFactor(
                factor: "Contract Year",
                impact: .positive,
                weight: 0.15,
                description: "Extra motivation for strong performance"
            ))
        }

        // Negative factors
        if player.injuryRisk.riskLevel == .high || player.injuryRisk.riskLevel == .extreme {
            factors.append(PriceFactor(
                factor: "Injury Risk",
                impact: .negative,
                weight: 0.3,
                description: "High injury risk threatens price stability"
            ))
        }

        if player.seasonalTrend.fadeRisk > 0.6 {
            factors.append(PriceFactor(
                factor: "Fade Risk",
                impact: .negative,
                weight: 0.2,
                description: "History of late-season performance decline"
            ))
        }

        // Neutral factors
        if player.volatility > 20 {
            factors.append(PriceFactor(
                factor: "High Volatility",
                impact: .neutral,
                weight: 0.1,
                description: "Inconsistent scoring creates price uncertainty"
            ))
        }

        return factors.sorted { $0.weight > $1.weight }
    }

    // MARK: - Buy/Sell Timing Tool

    func generateBuySellTiming(for player: Player) -> BuySellTiming {
        let priceHistory = generatePriceHistory(player: player) // Simulated
        let futurePriceProjections = generateFuturePriceProjections(player: player)

        let currentTiming = determineBuySellTiming(
            player: player,
            priceHistory: priceHistory,
            projections: futurePriceProjections
        )

        return BuySellTiming(
            player: player,
            recommendation: currentTiming.recommendation,
            confidence: currentTiming.confidence,
            priceHistory: priceHistory,
            futurePriceProjections: futurePriceProjections,
            keyMetrics: calculateTimingMetrics(player: player),
            reasoning: currentTiming.reasoning
        )
    }

    private func generatePriceHistory(player: Player) -> [PriceHistoryPoint] {
        // Simulate price history (in real app, this would be actual historical data)
        var history: [PriceHistoryPoint] = []
        var currentPrice = player.startingPrice

        for week in 1 ... 10 {
            let randomChange = Int.random(in: -25000 ... 35000)
            currentPrice = max(currentPrice + randomChange, 100_000)

            history.append(PriceHistoryPoint(
                round: week,
                price: currentPrice,
                change: randomChange,
                score: Int.random(in: 40 ... 140)
            ))
        }

        return history
    }

    private func generateFuturePriceProjections(player: Player) -> [FuturePricePoint] {
        var projections: [FuturePricePoint] = []
        var runningPrice = player.currentPrice

        for projection in player.threeRoundProjection {
            let predictedChange = calculatePriceChangeFromScoreDifference(
                scoreDifference: projection.projectedScore - Double(player.breakeven),
                currentPrice: runningPrice
            )

            runningPrice += Int(predictedChange)

            projections.append(FuturePricePoint(
                round: projection.round,
                projectedPrice: runningPrice,
                projectedChange: Int(predictedChange),
                confidence: projection.confidence / 100.0
            ))
        }

        return projections
    }

    private func determineBuySellTiming(
        player: Player,
        priceHistory: [PriceHistoryPoint],
        projections: [FuturePricePoint]
    ) -> (recommendation: TimingRecommendation, confidence: Double, reasoning: String) {
        let currentPriceTrend = analyzePriceTrend(history: priceHistory)
        let futureOutlook = analyzeProjections(projections: projections)
        let valueAssessment = assessCurrentValue(player: player)

        // Decision matrix
        if futureOutlook.expectedGain > 50000 && valueAssessment == .undervalued {
            return (
                .buy,
                0.85,
                "Strong price rise expected (+$\(futureOutlook.expectedGain / 1000)k) from undervalued position"
            )
        } else if futureOutlook.expectedGain < -30000 || valueAssessment == .overvalued {
            return (.sell, 0.8, "Price decline expected (\(futureOutlook.expectedGain / 1000)k) or overvalued")
        } else if currentPriceTrend == .declining, futureOutlook.expectedGain > 0 {
            return (.buyDip, 0.7, "Buy the dip - recent decline but positive outlook")
        } else if currentPriceTrend == .rising, futureOutlook.expectedGain < 0 {
            return (.sellHigh, 0.75, "Sell high - recent gains but negative outlook")
        } else {
            return (.hold, 0.6, "Stable outlook - no compelling timing signal")
        }
    }

    private func analyzePriceTrend(history: [PriceHistoryPoint]) -> PriceTrend {
        let recentPoints = history.suffix(3)
        let totalChange = recentPoints.reduce(0) { $0 + $1.change }

        if totalChange > 30000 {
            return .rising
        } else if totalChange < -30000 {
            return .declining
        } else {
            return .stable
        }
    }

    private func analyzeProjections(projections: [FuturePricePoint]) -> (expectedGain: Int, confidence: Double) {
        let totalGain = projections.reduce(0) { $0 + $1.projectedChange }
        let avgConfidence = projections.reduce(0.0) { $0 + $1.confidence } / Double(projections.count)

        return (totalGain, avgConfidence)
    }

    private func assessCurrentValue(player: Player) -> ValueAssessment {
        let performanceValue = player.averageScore * 7500 // Rough price per point
        let priceDifference = Double(player.currentPrice) - performanceValue

        if priceDifference < -100_000 {
            return .undervalued
        } else if priceDifference > 100_000 {
            return .overvalued
        } else {
            return .fairValue
        }
    }

    private func calculateTimingMetrics(player: Player) -> TimingMetrics {
        TimingMetrics(
            volatilityIndex: player.volatility,
            momentumScore: calculateMomentumScore(player: player),
            valueRatio: Double(player.currentPrice) / (player.averageScore * 7500),
            riskRewardRatio: calculateRiskRewardRatio(player: player)
        )
    }

    private func calculateMomentumScore(player: Player) -> Double {
        // Momentum based on trend direction and recent form
        let trendScore = player.seasonalTrend.trendDirection == .improving ? 0.4 :
            player.seasonalTrend.trendDirection == .stable ? 0.0 : -0.4

        let formScore = (Double(player.currentScore) - player.averageScore) / player.averageScore

        return max(-1.0, min(1.0, trendScore + formScore))
    }

    private func calculateRiskRewardRatio(player: Player) -> Double {
        let potentialReward = Double(player.seasonProjection.totalPriceRise) / Double(player.currentPrice)
        let risk = player.injuryRisk.riskScore / 100.0 + player.seasonalTrend.fadeRisk

        return risk > 0 ? potentialReward / risk : potentialReward
    }

    // MARK: - Consistency Scores

    func calculateConsistencyScores(for players: [Player]) -> [PlayerConsistencyScore] {
        players.map { player in
            let baseConsistency = player.consistency
            let adjustedConsistency = calculateAdjustedConsistency(player: player)
            let reliabilityGrade = determineReliabilityGrade(consistency: adjustedConsistency)
            let consistencyFactors = analyzeConsistencyFactors(player: player)

            return PlayerConsistencyScore(
                player: player,
                rawConsistency: baseConsistency,
                adjustedConsistency: adjustedConsistency,
                reliabilityGrade: reliabilityGrade,
                factors: consistencyFactors,
                ranking: 0 // Will be set after sorting
            )
        }.sorted { $0.adjustedConsistency > $1.adjustedConsistency }
            .enumerated()
            .map { index, score in
                var rankedScore = score
                rankedScore.ranking = index + 1
                return rankedScore
            }
    }

    private func calculateAdjustedConsistency(player: Player) -> Double {
        var adjustments: [Double] = [player.consistency]

        // Adjustment 1: Role stability
        let roleStability = max(0.0, (25.0 - player.volatility) / 25.0) * 10.0
        adjustments.append(roleStability)

        // Adjustment 2: Injury history penalty
        let injuryPenalty = player.injuryRisk.riskScore / 100.0 * -15.0
        adjustments.append(injuryPenalty)

        // Adjustment 3: Games played factor
        let gamesPlayedFactor = min(Double(player.gamesPlayed) / 15.0, 1.0) * 5.0
        adjustments.append(gamesPlayedFactor)

        // Adjustment 4: Position consistency (some positions are more consistent)
        let positionAdjustment = player.position == .midfielder ? 5.0 :
            player.position == .defender ? 3.0 : 0.0
        adjustments.append(positionAdjustment)

        let total = adjustments.reduce(0.0, +)
        return max(0.0, min(100.0, total))
    }

    private func determineReliabilityGrade(consistency: Double) -> ReliabilityGrade {
        switch consistency {
        case 90...: .elite
        case 80 ..< 90: .excellent
        case 70 ..< 80: .veryGood
        case 60 ..< 70: .good
        case 50 ..< 60: .average
        case 40 ..< 50: .poor
        default: .veryPoor
        }
    }

    private func analyzeConsistencyFactors(player: Player) -> [ConsistencyFactor] {
        var factors: [ConsistencyFactor] = []

        // Positive factors
        if player.gamesPlayed >= 15 {
            factors.append(ConsistencyFactor(
                factor: "Durable",
                impact: .positive,
                description: "Rarely misses games due to injury/rotation"
            ))
        }

        if player.volatility < 15 {
            factors.append(ConsistencyFactor(
                factor: "Low Volatility",
                impact: .positive,
                description: "Scores remain within narrow range"
            ))
        }

        if player.floor > 60 {
            factors.append(ConsistencyFactor(
                factor: "High Floor",
                impact: .positive,
                description: "Rarely produces very low scores"
            ))
        }

        // Negative factors
        if player.injuryRisk.riskLevel == .high {
            factors.append(ConsistencyFactor(
                factor: "Injury Prone",
                impact: .negative,
                description: "History of missing games due to injury"
            ))
        }

        if player.volatility > 25 {
            factors.append(ConsistencyFactor(
                factor: "High Volatility",
                impact: .negative,
                description: "Wide scoring range creates uncertainty"
            ))
        }

        if player.floor < 40 {
            factors.append(ConsistencyFactor(
                factor: "Low Floor",
                impact: .negative,
                description: "Capable of very poor scores"
            ))
        }

        return factors
    }

    // MARK: - Injury Risk Modeling

    func generateInjuryRiskModel(for players: [Player]) -> [PlayerInjuryRisk] {
        players.map { player in
            let riskModel = buildRiskModel(player: player)
            let recommendations = generateInjuryRecommendations(riskModel: riskModel, player: player)

            return PlayerInjuryRisk(
                player: player,
                riskModel: riskModel,
                recommendations: recommendations
            )
        }.sorted { $0.riskModel.overallRisk > $1.riskModel.overallRisk }
    }

    private func buildRiskModel(player: Player) -> InjuryRiskModel {
        let historyRisk = calculateHistoryRisk(player: player)
        let ageRisk = calculateAgeRisk(player: player)
        let positionRisk = calculatePositionRisk(player: player)
        let workloadRisk = calculateWorkloadRisk(player: player)
        let reinjuryRisk = player.injuryRisk.reinjuryProbability

        let overallRisk = [historyRisk, ageRisk, positionRisk, workloadRisk, reinjuryRisk].reduce(0.0, +) / 5.0

        return InjuryRiskModel(
            overallRisk: overallRisk,
            historyRisk: historyRisk,
            ageRisk: ageRisk,
            positionRisk: positionRisk,
            workloadRisk: workloadRisk,
            reinjuryRisk: reinjuryRisk,
            riskTrend: analyzeRiskTrend(player: player)
        )
    }

    private func calculateHistoryRisk(player: Player) -> Double {
        let recentInjuries = player.injuryRisk.injuryHistory.filter { $0.season >= 2023 }
        let severityScore = recentInjuries.reduce(0.0) { acc, injury in
            acc + (Double(injury.weeksOut) / 22.0) // Normalize by season length
        }

        return min(1.0, severityScore)
    }

    private func calculateAgeRisk(player: Player) -> Double {
        // Simplified age calculation - in real app would have player age data
        let estimatedAge = player.currentPrice > 600_000 ? 28.0 : 22.0 // Premium vs rookie assumption

        if estimatedAge < 23 {
            return 0.1 // Low risk for young players
        } else if estimatedAge > 30 {
            return 0.8 // High risk for older players
        } else {
            return (estimatedAge - 23) / 7 * 0.6 // Linear increase from 23-30
        }
    }

    private func calculatePositionRisk(player: Player) -> Double {
        // Positional injury risk based on contact and running demands
        switch player.position {
        case .defender: 0.3
        case .midfielder: 0.6 // Highest running load
        case .ruck: 0.7 // High contact
        case .forward: 0.4
        }
    }

    private func calculateWorkloadRisk(player: Player) -> Double {
        let avgMinutes = 85.0 // Simplified - would use actual TOG data
        let highWorkload = avgMinutes > 90 ? 0.3 : 0.1
        let consistentSelection = player.gamesPlayed > 18 ? 0.2 : 0.0

        return highWorkload + consistentSelection
    }

    private func analyzeRiskTrend(player: Player) -> RiskTrend {
        let recentInjuries = player.injuryRisk.injuryHistory.filter { $0.season >= 2024 }
        let historicalInjuries = player.injuryRisk.injuryHistory.filter { $0.season < 2024 }

        if recentInjuries.count > historicalInjuries.count {
            return .increasing
        } else if recentInjuries.count < historicalInjuries.count {
            return .decreasing
        } else {
            return .stable
        }
    }

    private func generateInjuryRecommendations(riskModel: InjuryRiskModel, player: Player) -> [InjuryRecommendation] {
        var recommendations: [InjuryRecommendation] = []

        if riskModel.overallRisk > 0.7 {
            recommendations.append(InjuryRecommendation(
                priority: .high,
                action: "Consider trading out",
                reasoning: "Very high injury risk - trade before potential setback"
            ))
        } else if riskModel.overallRisk > 0.5 {
            recommendations.append(InjuryRecommendation(
                priority: .medium,
                action: "Monitor closely",
                reasoning: "Elevated risk - watch for signs of soreness/fatigue"
            ))
        }

        if riskModel.reinjuryRisk > 0.8 {
            recommendations.append(InjuryRecommendation(
                priority: .critical,
                action: "Avoid as captain",
                reasoning: "Extremely high reinjury risk - unsafe captain choice"
            ))
        }

        if riskModel.workloadRisk > 0.6 {
            recommendations.append(InjuryRecommendation(
                priority: .low,
                action: "Monitor workload",
                reasoning: "High game time may lead to fatigue-related injuries"
            ))
        }

        return recommendations
    }
}

// MARK: - PlayerPricePrediction

struct PlayerPricePrediction: Identifiable, Codable {
    let id = UUID()
    let player: Player
    let nextRoundChange: PriceChangePrediction
    let threeRoundChange: PriceChangePrediction
    let seasonEndPrice: Int
    let confidence: Double
    let factors: [PriceFactor]
}

// MARK: - PriceChangePrediction

struct PriceChangePrediction: Codable {
    let amount: Int
    let probability: Double
    let reasoning: String
}

// MARK: - PriceFactor

struct PriceFactor: Identifiable, Codable {
    let id = UUID()
    let factor: String
    let impact: FactorImpact
    let weight: Double
    let description: String
}

// MARK: - FactorImpact

enum FactorImpact: String, CaseIterable, Codable {
    case positive = "Positive"
    case negative = "Negative"
    case neutral = "Neutral"

    var color: Color {
        switch self {
        case .positive: .green
        case .negative: .red
        case .neutral: .gray
        }
    }
}

// MARK: - BuySellTiming

struct BuySellTiming: Identifiable, Codable {
    let id = UUID()
    let player: Player
    let recommendation: TimingRecommendation
    let confidence: Double
    let priceHistory: [PriceHistoryPoint]
    let futurePriceProjections: [FuturePricePoint]
    let keyMetrics: TimingMetrics
    let reasoning: String
}

// MARK: - TimingRecommendation

enum TimingRecommendation: String, CaseIterable, Codable {
    case buy = "Buy"
    case buyDip = "Buy Dip"
    case sell = "Sell"
    case sellHigh = "Sell High"
    case hold = "Hold"

    var color: Color {
        switch self {
        case .buy, .buyDip: .green
        case .sell, .sellHigh: .red
        case .hold: .yellow
        }
    }
}

// MARK: - PriceHistoryPoint

struct PriceHistoryPoint: Identifiable, Codable {
    let id = UUID()
    let round: Int
    let price: Int
    let change: Int
    let score: Int
}

// MARK: - FuturePricePoint

struct FuturePricePoint: Identifiable, Codable {
    let id = UUID()
    let round: Int
    let projectedPrice: Int
    let projectedChange: Int
    let confidence: Double
}

// MARK: - PriceTrend

enum PriceTrend: String, CaseIterable, Codable {
    case rising = "Rising"
    case declining = "Declining"
    case stable = "Stable"
}

// MARK: - ValueAssessment

enum ValueAssessment: String, CaseIterable, Codable {
    case undervalued = "Undervalued"
    case fairValue = "Fair Value"
    case overvalued = "Overvalued"
}

// MARK: - TimingMetrics

struct TimingMetrics: Codable {
    let volatilityIndex: Double
    let momentumScore: Double
    let valueRatio: Double
    let riskRewardRatio: Double
}

// MARK: - PlayerConsistencyScore

struct PlayerConsistencyScore: Identifiable, Codable {
    let id = UUID()
    let player: Player
    let rawConsistency: Double
    let adjustedConsistency: Double
    let reliabilityGrade: ReliabilityGrade
    let factors: [ConsistencyFactor]
    var ranking: Int
}

// MARK: - ReliabilityGrade

enum ReliabilityGrade: String, CaseIterable, Codable {
    case elite = "Elite"
    case excellent = "Excellent"
    case veryGood = "Very Good"
    case good = "Good"
    case average = "Average"
    case poor = "Poor"
    case veryPoor = "Very Poor"

    var color: Color {
        switch self {
        case .elite: .purple
        case .excellent: .green
        case .veryGood: .mint
        case .good: .blue
        case .average: .yellow
        case .poor: .orange
        case .veryPoor: .red
        }
    }
}

// MARK: - ConsistencyFactor

struct ConsistencyFactor: Identifiable, Codable {
    let id = UUID()
    let factor: String
    let impact: FactorImpact
    let description: String
}

// MARK: - PlayerInjuryRisk

struct PlayerInjuryRisk: Identifiable, Codable {
    let id = UUID()
    let player: Player
    let riskModel: InjuryRiskModel
    let recommendations: [InjuryRecommendation]
}

// MARK: - InjuryRiskModel

struct InjuryRiskModel: Codable {
    let overallRisk: Double
    let historyRisk: Double
    let ageRisk: Double
    let positionRisk: Double
    let workloadRisk: Double
    let reinjuryRisk: Double
    let riskTrend: RiskTrend
}

// MARK: - RiskTrend

enum RiskTrend: String, CaseIterable, Codable {
    case increasing = "Increasing"
    case stable = "Stable"
    case decreasing = "Decreasing"
}

// MARK: - InjuryRecommendation

struct InjuryRecommendation: Identifiable, Codable {
    let id = UUID()
    let priority: RecommendationPriority
    let action: String
    let reasoning: String
}
