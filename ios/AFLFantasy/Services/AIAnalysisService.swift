//
//  AIAnalysisService.swift
//  AFL Fantasy Intelligence Platform
//
//  AI-Powered Analysis Services for Captain Selection, Trades, and Team Structure
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import SwiftUI

// MARK: - AIAnalysisService

@MainActor
class AIAnalysisService: ObservableObject {
    // MARK: - AI Captain Advisor

    func generateCaptainRecommendations(players: [Player], currentRound: Int) -> [CaptainSuggestion] {
        let analysisResults = players
            .filter { !$0.isInjured && !$0.isDoubtful }
            .map { player in
                analyzeCaptainCandidate(player: player, round: currentRound)
            }
            .sorted { $0.confidence > $1.confidence }
            .prefix(5)

        return Array(analysisResults)
    }

    private func analyzeCaptainCandidate(player: Player, round: Int) -> CaptainSuggestion {
        let venueBonus = calculateVenueBias(player: player, round: round)
        let opponentFactor = calculateOpponentDVP(player: player, round: round)
        let formFactor = calculateRecentForm(player: player)
        let consistencyFactor = player.consistency / 100.0
        let weatherImpact = calculateWeatherImpact(player: player, round: round)

        // AI Confidence Algorithm v3.4.4
        let baseConfidence = (player.averageScore / 130.0) * 100 // Normalize to premium average
        let adjustedConfidence = baseConfidence *
            (1 + venueBonus) *
            (1 + opponentFactor) *
            formFactor *
            consistencyFactor *
            (1 + weatherImpact)

        let finalConfidence = min(max(adjustedConfidence, 0), 100)

        let projectedScore = calculateProjectedScore(
            player: player,
            venueBonus: venueBonus,
            opponentFactor: opponentFactor,
            formFactor: formFactor,
            weatherImpact: weatherImpact
        )

        let analysis = CaptainAnalysis(
            venueImpact: venueBonus,
            opponentMatchup: opponentFactor,
            recentForm: formFactor,
            consistency: consistencyFactor,
            weatherRisk: weatherImpact,
            injuryRisk: player.injuryRisk.riskScore / 100.0,
            ceiling: Double(player.ceiling),
            floor: Double(player.floor)
        )

        return CaptainSuggestion(
            player: player,
            confidence: Int(finalConfidence),
            projectedPoints: Int(projectedScore),
            analysis: analysis
        )
    }

    private func calculateVenueBias(player: Player, round: Int) -> Double {
        // Find venue performance for this round
        let venue = player.nextRoundProjection.venue
        let venuePerf = player.venuePerformance.first { $0.venueName == venue }

        guard let perf = venuePerf, perf.gamesPlayed >= 3 else { return 0.0 }

        // Convert bias to multiplier (-0.2 to +0.3 range)
        return perf.bias * 0.03
    }

    private func calculateOpponentDVP(player: Player, round: Int) -> Double {
        // Defense vs Position analysis
        let opponent = player.nextRoundProjection.opponent
        let oppPerf = player.opponentPerformance.first { $0.opponentTeam == opponent }

        guard let perf = oppPerf else { return 0.0 }

        // DVP ranking: 1 = easiest opponent, 18 = hardest
        let dvpFactor = (19 - perf.dvpRanking) / 18.0 // Normalize to 0-1
        return (dvpFactor - 0.5) * 0.4 // -0.2 to +0.2 range
    }

    private func calculateRecentForm(player: Player) -> Double {
        // Form factor based on last 3 games vs season average
        let recentAvg = Double(player.currentScore) // Simplified - would use last 3 games
        let seasonAvg = player.averageScore

        if seasonAvg == 0 { return 1.0 }

        let formRatio = recentAvg / seasonAvg
        return max(0.7, min(1.4, formRatio)) // Clamp between 0.7 and 1.4
    }

    private func calculateWeatherImpact(player: Player, round: Int) -> Double {
        let conditions = player.nextRoundProjection.conditions

        var impact = 0.0

        // Rain impact (negative for most players)
        if conditions.rainProbability > 0.7 {
            impact -= 0.15
        } else if conditions.rainProbability > 0.4 {
            impact -= 0.08
        }

        // Wind impact
        if conditions.windSpeed > 25 {
            impact -= 0.1
        }

        // Temperature extremes
        if conditions.temperature < 8 || conditions.temperature > 32 {
            impact -= 0.05
        }

        return impact
    }

    private func calculateProjectedScore(
        player: Player,
        venueBonus: Double,
        opponentFactor: Double,
        formFactor: Double,
        weatherImpact: Double
    ) -> Double {
        let baseProjection = player.nextRoundProjection.projectedScore

        return baseProjection *
            (1 + venueBonus) *
            (1 + opponentFactor) *
            formFactor *
            (1 + weatherImpact)
    }

    // MARK: - AI Trade Suggester

    func generateTradeRecommendations(
        currentTeam: [Player],
        playerPool: [Player],
        availableCash: Int,
        tradesRemaining: Int
    ) -> [TradeRecommendation] {
        var recommendations: [TradeRecommendation] = []

        // Identify upgrade opportunities
        let upgradeOpportunities = findUpgradeOpportunities(
            currentTeam: currentTeam,
            playerPool: playerPool,
            cash: availableCash
        )

        // Identify cash cow opportunities
        let cashCowOpportunities = findCashCowOpportunities(
            currentTeam: currentTeam,
            playerPool: playerPool,
            cash: availableCash
        )

        // Identify correction trades (falling premiums)
        let correctionTrades = findCorrectionTrades(
            currentTeam: currentTeam,
            playerPool: playerPool,
            cash: availableCash
        )

        recommendations.append(contentsOf: upgradeOpportunities)
        recommendations.append(contentsOf: cashCowOpportunities)
        recommendations.append(contentsOf: correctionTrades)

        return recommendations.sorted { $0.priority.rawValue < $1.priority.rawValue }
    }

    private func findUpgradeOpportunities(
        currentTeam: [Player],
        playerPool: [Player],
        cash: Int
    ) -> [TradeRecommendation] {
        var recommendations: [TradeRecommendation] = []

        // Find weakest players in team
        let weakestPlayers = currentTeam
            .sorted { $0.averageScore < $1.averageScore }
            .prefix(5)

        for weakPlayer in weakestPlayers {
            let samePositionPlayers = playerPool.filter {
                $0.position == weakPlayer.position &&
                    $0.averageScore > weakPlayer.averageScore &&
                    $0.currentPrice <= weakPlayer.currentPrice + cash
            }

            if let bestUpgrade = samePositionPlayers
                .max(by: { $0.seasonProjection.averageProjectedScore < $1.seasonProjection.averageProjectedScore }) {
                let analysis = TradeAnalysis(
                    playerOut: weakPlayer,
                    playerIn: bestUpgrade,
                    costDifference: bestUpgrade.currentPrice - weakPlayer.currentPrice,
                    tradeScore: calculateTradeScore(from: weakPlayer, to: bestUpgrade),
                    nextRoundImpact: TradeImpact(
                        pointsGained: bestUpgrade.nextRoundProjection.projectedScore - weakPlayer.nextRoundProjection
                            .projectedScore,
                        priceGained: bestUpgrade.nextRoundProjection.priceChange - weakPlayer.nextRoundProjection
                            .priceChange,
                        riskAdjustedValue: 0.85
                    ),
                    threeRoundImpact: calculateThreeRoundImpact(from: weakPlayer, to: bestUpgrade),
                    seasonImpact: calculateSeasonImpact(from: weakPlayer, to: bestUpgrade),
                    risks: identifyTradeRisks(from: weakPlayer, to: bestUpgrade),
                    opportunities: identifyTradeOpportunities(from: weakPlayer, to: bestUpgrade),
                    recommendation: determineTradeRecommendation(analysis: 85.0) // Placeholder
                )

                recommendations.append(
                    TradeRecommendation(
                        type: .upgrade,
                        playerOut: weakPlayer.name,
                        playerIn: bestUpgrade.name,
                        costDifference: analysis.costDifference,
                        score: analysis.tradeScore,
                        priority: analysis.tradeScore > 80 ? .high : .medium,
                        reasoning: "Upgrade to higher scoring premium with \(Int(analysis.nextRoundImpact.pointsGained)) point projection increase",
                        analysis: analysis
                    )
                )
            }
        }

        return recommendations
    }

    private func findCashCowOpportunities(
        currentTeam: [Player],
        playerPool: [Player],
        cash: Int
    ) -> [TradeRecommendation] {
        let topCashCows = playerPool
            .filter { $0.isCashCow && $0.cashGenerated > 50000 }
            .sorted { $0.seasonProjection.totalPriceRise > $1.seasonProjection.totalPriceRise }
            .prefix(3)

        return topCashCows.compactMap { cashCow in
            // Find a bench player to trade out
            let benchPlayers = currentTeam.filter { $0.averageScore < 60 }
            guard let tradeOut = benchPlayers
                .min(by: { $0.seasonProjection.averageProjectedScore < $1.seasonProjection.averageProjectedScore })
            else { return nil }

            let analysis = TradeAnalysis(
                playerOut: tradeOut,
                playerIn: cashCow,
                costDifference: cashCow.currentPrice - tradeOut.currentPrice,
                tradeScore: calculateTradeScore(from: tradeOut, to: cashCow),
                nextRoundImpact: TradeImpact(pointsGained: 10, priceGained: 15000, riskAdjustedValue: 0.9),
                threeRoundImpact: TradeImpact(pointsGained: 45, priceGained: 80000, riskAdjustedValue: 0.85),
                seasonImpact: TradeImpact(
                    pointsGained: 120,
                    priceGained: cashCow.seasonProjection.totalPriceRise,
                    riskAdjustedValue: 0.75
                ),
                risks: [TradeRisk(risk: "May plateau early", probability: 0.3, impact: .medium)],
                opportunities: [TradeOpportunity(
                    opportunity: "Major price rises",
                    likelihood: 0.8,
                    benefit: "$\(cashCow.seasonProjection.totalPriceRise / 1000)k gain"
                )],
                recommendation: .buy
            )

            return TradeRecommendation(
                type: .cashGeneration,
                playerOut: tradeOut.name,
                playerIn: cashCow.name,
                costDifference: analysis.costDifference,
                score: analysis.tradeScore,
                priority: .high,
                reasoning: "Cash cow with $\(cashCow.seasonProjection.totalPriceRise / 1000)k projected rise",
                analysis: analysis
            )
        }
    }

    private func findCorrectionTrades(
        currentTeam: [Player],
        playerPool: [Player],
        cash: Int
    ) -> [TradeRecommendation] {
        // Find falling premiums to trade out
        let fallingPremiums = currentTeam.filter {
            $0.currentPrice > 600_000 &&
                $0.seasonalTrend.trendDirection == .declining &&
                $0.seasonalTrend.fadeRisk > 0.6
        }

        return fallingPremiums.compactMap { fallingPlayer in
            let alternatives = playerPool.filter {
                $0.position == fallingPlayer.position &&
                    $0.currentPrice <= fallingPlayer.currentPrice + cash &&
                    $0.seasonalTrend.trendDirection == .improving
            }

            guard let bestAlternative = alternatives
                .max(by: { $0.seasonProjection.averageProjectedScore < $1.seasonProjection.averageProjectedScore })
            else { return nil }

            let analysis = TradeAnalysis(
                playerOut: fallingPlayer,
                playerIn: bestAlternative,
                costDifference: bestAlternative.currentPrice - fallingPlayer.currentPrice,
                tradeScore: calculateTradeScore(from: fallingPlayer, to: bestAlternative),
                nextRoundImpact: TradeImpact(pointsGained: 8, priceGained: 0, riskAdjustedValue: 0.9),
                threeRoundImpact: TradeImpact(pointsGained: 35, priceGained: 25000, riskAdjustedValue: 0.85),
                seasonImpact: TradeImpact(pointsGained: 150, priceGained: 100_000, riskAdjustedValue: 0.8),
                risks: [TradeRisk(risk: "Original player may bounce back", probability: 0.25, impact: .medium)],
                opportunities: [TradeOpportunity(
                    opportunity: "Avoid further price drops",
                    likelihood: 0.75,
                    benefit: "Capital preservation"
                )],
                recommendation: .sell
            )

            return TradeRecommendation(
                type: .correction,
                playerOut: fallingPlayer.name,
                playerIn: bestAlternative.name,
                costDifference: analysis.costDifference,
                score: analysis.tradeScore,
                priority: .medium,
                reasoning: "Move from declining premium to improving alternative",
                analysis: analysis
            )
        }
    }

    private func calculateTradeScore(from playerOut: Player, to playerIn: Player) -> Double {
        let pointsImprovement = (playerIn.seasonProjection.averageProjectedScore - playerOut.seasonProjection
            .averageProjectedScore
        ) * 5
        let priceImprovement = Double(playerIn.seasonProjection.totalPriceRise - playerOut.seasonProjection
            .totalPriceRise
        ) / 10000
        let consistencyImprovement = (playerIn.consistency - playerOut.consistency) * 2
        let injuryRiskReduction = (playerOut.injuryRisk.riskScore - playerIn.injuryRisk.riskScore) * 0.5

        let totalScore = pointsImprovement + priceImprovement + consistencyImprovement + injuryRiskReduction
        return max(0, min(100, 50 + totalScore))
    }

    private func calculateThreeRoundImpact(from playerOut: Player, to playerIn: Player) -> TradeImpact {
        let pointsGain = playerIn.threeRoundProjection.reduce(0) { $0 + $1.projectedScore } -
            playerOut.threeRoundProjection.reduce(0) { $0 + $1.projectedScore }
        let priceGain = playerIn.threeRoundProjection.reduce(0) { $0 + $1.priceChange } -
            playerOut.threeRoundProjection.reduce(0) { $0 + $1.priceChange }

        return TradeImpact(
            pointsGained: pointsGain,
            priceGained: priceGain,
            riskAdjustedValue: 0.85
        )
    }

    private func calculateSeasonImpact(from playerOut: Player, to playerIn: Player) -> TradeImpact {
        TradeImpact(
            pointsGained: playerIn.seasonProjection.averageProjectedScore - playerOut.seasonProjection
                .averageProjectedScore,
            priceGained: playerIn.seasonProjection.totalPriceRise - playerOut.seasonProjection.totalPriceRise,
            riskAdjustedValue: 0.75
        )
    }

    private func identifyTradeRisks(from playerOut: Player, to playerIn: Player) -> [TradeRisk] {
        var risks: [TradeRisk] = []

        if playerIn.injuryRisk.riskLevel == .high || playerIn.injuryRisk.riskLevel == .extreme {
            risks.append(TradeRisk(
                risk: "High injury risk",
                probability: playerIn.injuryRisk.riskScore / 100.0,
                impact: .high
            ))
        }

        if playerIn.seasonalTrend.fadeRisk > 0.7 {
            risks.append(TradeRisk(
                risk: "Late season fade risk",
                probability: playerIn.seasonalTrend.fadeRisk,
                impact: .medium
            ))
        }

        if playerIn.volatility > 25 {
            risks.append(TradeRisk(
                risk: "High score volatility",
                probability: 0.8,
                impact: .low
            ))
        }

        return risks
    }

    private func identifyTradeOpportunities(from playerOut: Player, to playerIn: Player) -> [TradeOpportunity] {
        var opportunities: [TradeOpportunity] = []

        if playerIn.seasonProjection.premiumPotential > 0.7 {
            opportunities.append(TradeOpportunity(
                opportunity: "Premium breakout potential",
                likelihood: playerIn.seasonProjection.premiumPotential,
                benefit: "Major scoring upside"
            ))
        }

        if playerIn.contractStatus.contractYear {
            opportunities.append(TradeOpportunity(
                opportunity: "Contract year motivation",
                likelihood: 0.6,
                benefit: "\(playerIn.contractStatus.motivationBonus * 100)% performance boost"
            ))
        }

        return opportunities
    }

    private func determineTradeRecommendation(analysis tradeScore: Double) -> TradeRecommendation {
        switch tradeScore {
        case 90...: .strongBuy
        case 75 ..< 90: .buy
        case 50 ..< 75: .hold
        case 25 ..< 50: .sell
        default: .strongSell
        }
    }

    // MARK: - Team Structure Analysis

    func analyzeTeamStructure(team: [Player], salaryCap: Int) -> TeamStructure {
        let usedCap = team.reduce(0) { $0 + $1.currentPrice }
        let remainingCap = salaryCap - usedCap
        let utilization = Double(usedCap) / Double(salaryCap)

        let defAllocation = analyzePositionAllocation(players: team, position: .defender, totalCap: salaryCap)
        let midAllocation = analyzePositionAllocation(players: team, position: .midfielder, totalCap: salaryCap)
        let rucAllocation = analyzePositionAllocation(players: team, position: .ruck, totalCap: salaryCap)
        let fwdAllocation = analyzePositionAllocation(players: team, position: .forward, totalCap: salaryCap)

        let grade = calculateStructureGrade(
            defAllocation: defAllocation,
            midAllocation: midAllocation,
            rucAllocation: rucAllocation,
            fwdAllocation: fwdAllocation,
            utilization: utilization
        )

        let weaknesses = identifyStructureWeaknesses(
            team: team,
            defAllocation: defAllocation,
            midAllocation: midAllocation,
            rucAllocation: rucAllocation,
            fwdAllocation: fwdAllocation
        )

        let recommendations = generateStructureRecommendations(weaknesses: weaknesses, remainingCap: remainingCap)

        return TeamStructure(
            totalSalaryCap: salaryCap,
            usedSalaryCap: usedCap,
            remainingCap: remainingCap,
            capUtilization: utilization,
            defenderAllocation: defAllocation,
            midfielderAllocation: midAllocation,
            ruckAllocation: rucAllocation,
            forwardAllocation: fwdAllocation,
            structureGrade: grade,
            weaknesses: weaknesses,
            recommendations: recommendations
        )
    }

    private func analyzePositionAllocation(players: [Player], position: Position, totalCap: Int) -> PositionAllocation {
        let positionPlayers = players.filter { $0.position == position }
        let totalValue = positionPlayers.reduce(0) { $0 + $1.currentPrice }
        let averageValue = positionPlayers.isEmpty ? 0 : totalValue / positionPlayers.count
        let allocation = Double(totalValue) / Double(totalCap)

        // Calculate bench strength (simplified)
        let benchStrength = positionPlayers.count > 2 ?
            positionPlayers.sorted { $0.averageScore > $1.averageScore }
            .suffix(positionPlayers.count - 2)
            .reduce(0.0) { $0 + $1.averageScore } / Double(positionPlayers.count - 2) : 0.0

        let upgradeTargets = positionPlayers
            .filter { $0.averageScore < 80 }
            .map(\.name)

        let downgradeTargets = positionPlayers
            .filter { $0.averageScore > 100 && $0.seasonalTrend.trendDirection == .declining }
            .map(\.name)

        return PositionAllocation(
            position: position,
            playersCount: positionPlayers.count,
            totalValue: totalValue,
            averageValue: averageValue,
            allocation: allocation,
            benchStrength: benchStrength,
            upgradeTargets: upgradeTargets,
            downgradeTargets: downgradeTargets
        )
    }

    private func calculateStructureGrade(
        defAllocation: PositionAllocation,
        midAllocation: PositionAllocation,
        rucAllocation: PositionAllocation,
        fwdAllocation: PositionAllocation,
        utilization: Double
    ) -> StructureGrade {
        var score = 0.0

        // Salary cap utilization (optimal 85-95%)
        if utilization >= 0.85, utilization <= 0.95 {
            score += 25
        } else if utilization >= 0.80, utilization <= 0.98 {
            score += 20
        } else {
            score += 10
        }

        // Position balance (each position should have adequate allocation)
        let allocations = [
            defAllocation.allocation,
            midAllocation.allocation,
            rucAllocation.allocation,
            fwdAllocation.allocation
        ]
        let balanceScore = allocations.reduce(25.0) { acc, allocation in
            if allocation >= 0.15, allocation <= 0.35 { return acc }
            return acc - 5
        }
        score += balanceScore

        // Bench strength
        let avgBenchStrength = (defAllocation.benchStrength + midAllocation.benchStrength + rucAllocation
            .benchStrength + fwdAllocation.benchStrength
        ) / 4
        if avgBenchStrength >= 60 { score += 25 } else if avgBenchStrength >= 45 { score += 20 } else if avgBenchStrength >= 30 { score += 10 }

        // Premium coverage
        let avgValues = [
            defAllocation.averageValue,
            midAllocation.averageValue,
            rucAllocation.averageValue,
            fwdAllocation.averageValue
        ]
        let premiumCoverage = avgValues.filter { $0 >= 550_000 }.count
        score += Double(premiumCoverage) * 6.25

        switch score {
        case 90...: return .excellent
        case 80 ..< 90: return .veryGood
        case 70 ..< 80: return .good
        case 60 ..< 70: return .average
        case 50 ..< 60: return .poor
        default: return .veryPoor
        }
    }

    private func identifyStructureWeaknesses(
        team: [Player],
        defAllocation: PositionAllocation,
        midAllocation: PositionAllocation,
        rucAllocation: PositionAllocation,
        fwdAllocation: PositionAllocation
    ) -> [StructureWeakness] {
        var weaknesses: [StructureWeakness] = []

        // Check for thin bench coverage
        for allocation in [defAllocation, midAllocation, rucAllocation, fwdAllocation] {
            if allocation.benchStrength < 30 {
                weaknesses.append(StructureWeakness(
                    issue: "Weak \(allocation.position.rawValue) bench coverage",
                    severity: .major,
                    impact: "Risk of donuts if starter injured"
                ))
            }
        }

        // Check for over-allocation
        for allocation in [defAllocation, midAllocation, rucAllocation, fwdAllocation] {
            if allocation.allocation > 0.4 {
                weaknesses.append(StructureWeakness(
                    issue: "Over-invested in \(allocation.position.rawValue)s",
                    severity: .minor,
                    impact: "Limited flexibility for upgrades"
                ))
            }
        }

        // Check for cash cows ready to sell
        let readyToSell = team.filter { $0.isCashCow && $0.cashGenerated > 150_000 }
        if readyToSell.count >= 2 {
            weaknesses.append(StructureWeakness(
                issue: "\(readyToSell.count) cash cows ready for upgrade",
                severity: .major,
                impact: "Missing opportunity for premium upgrades"
            ))
        }

        return weaknesses
    }

    private func generateStructureRecommendations(
        weaknesses: [StructureWeakness],
        remainingCap: Int
    ) -> [StructureRecommendation] {
        var recommendations: [StructureRecommendation] = []

        for weakness in weaknesses {
            switch weakness.issue {
            case let issue where issue.contains("bench coverage"):
                recommendations.append(StructureRecommendation(
                    action: "Upgrade bench player in affected position",
                    priority: .high,
                    expectedImprovement: "Reduce donut risk and improve emergency scoring",
                    cost: 200_000
                ))

            case let issue where issue.contains("Over-invested"):
                recommendations.append(StructureRecommendation(
                    action: "Consider downgrading one premium to spread funds",
                    priority: .medium,
                    expectedImprovement: "Better position balance and upgrade flexibility",
                    cost: nil
                ))

            case let issue where issue.contains("cash cows"):
                recommendations.append(StructureRecommendation(
                    action: "Upgrade cash cows to premium players",
                    priority: .urgent,
                    expectedImprovement: "Lock in cash generation and improve scoring",
                    cost: 400_000
                ))

            default:
                break
            }
        }

        if remainingCap > 300_000 {
            recommendations.append(StructureRecommendation(
                action: "Deploy excess cash in premium upgrade",
                priority: .high,
                expectedImprovement: "Maximize salary cap efficiency",
                cost: remainingCap
            ))
        }

        return recommendations
    }
}

// MARK: - CaptainAnalysis

struct CaptainAnalysis: Codable {
    let venueImpact: Double
    let opponentMatchup: Double
    let recentForm: Double
    let consistency: Double
    let weatherRisk: Double
    let injuryRisk: Double
    let ceiling: Double
    let floor: Double
}

// MARK: - TradeType

enum TradeType: String, CaseIterable, Codable {
    case upgrade = "Upgrade"
    case cashGeneration = "Cash Generation"
    case correction = "Correction"
    case byeRoundCover = "Bye Round Cover"
    case valuePlay = "Value Play"
}

// MARK: - TradePriority

enum TradePriority: String, CaseIterable, Codable {
    case urgent = "Urgent"
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}

// MARK: - TradeRecommendation

struct TradeRecommendation: Identifiable, Codable {
    let id = UUID()
    let type: TradeType
    let playerOut: String
    let playerIn: String
    let costDifference: Int
    let score: Double
    let priority: TradePriority
    let reasoning: String
    let analysis: TradeAnalysis
}
