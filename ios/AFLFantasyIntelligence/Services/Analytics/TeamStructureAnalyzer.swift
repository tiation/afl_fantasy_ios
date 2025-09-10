import Foundation
import SwiftUI

// MARK: - Team Structure Analyzer
@MainActor
class TeamStructureAnalyzer: ObservableObject {
    @Published var currentAnalysis: TeamStructureAnalysis?
    @Published var isLoading = false
    @Published var error: AnalysisError?
    
    private let playerService: PlayerService
    private let venueService: VenueAnalyticsService
    private let priceService: PriceAnalyticsService
    
    init(playerService: PlayerService, 
         venueService: VenueAnalyticsService,
         priceService: PriceAnalyticsService) {
        self.playerService = playerService
        self.venueService = venueService
        self.priceService = priceService
    }
    
    // MARK: - Main Analysis Function
    func analyzeTeamStructure(team: [Player]) async {
        isLoading = true
        error = nil
        
        do {
            let analysis = try await performStructureAnalysis(team: team)
            await MainActor.run {
                self.currentAnalysis = analysis
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = AnalysisError.analysisFailure(error.localizedDescription)
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Core Analysis Logic
    private func performStructureAnalysis(team: [Player]) async throws -> TeamStructureAnalysis {
        let positionBreakdown = analyzePositionBreakdown(team: team)
        let salaryAllocation = analyzeSalaryAllocation(team: team)
        let valueDistribution = await analyzeValueDistribution(team: team)
        let weaknessDetection = await detectWeaknesses(team: team, positionBreakdown: positionBreakdown)
        let upgradePathways = await generateUpgradePathways(team: team, weaknesses: weaknessDetection)
        let riskAssessment = await assessTeamRisks(team: team)
        let byeRoundExposure = analyzeByeRoundExposure(team: team)
        let benchStrength = analyzeBenchStrength(team: team)
        let teamScore = calculateOverallTeamScore(
            positionBreakdown: positionBreakdown,
            salaryAllocation: salaryAllocation,
            valueDistribution: valueDistribution,
            weaknesses: weaknessDetection,
            risks: riskAssessment
        )
        
        return TeamStructureAnalysis(
            id: UUID(),
            analysisDate: Date(),
            teamScore: teamScore,
            positionBreakdown: positionBreakdown,
            salaryAllocation: salaryAllocation,
            valueDistribution: valueDistribution,
            weaknessDetection: weaknessDetection,
            upgradePathways: upgradePathways,
            riskAssessment: riskAssessment,
            byeRoundExposure: byeRoundExposure,
            benchStrength: benchStrength,
            recommendations: generateRecommendations(
                team: team,
                weaknesses: weaknessDetection,
                upgrades: upgradePathways,
                risks: riskAssessment
            )
        )
    }
    
    // MARK: - Position Analysis
    private func analyzePositionBreakdown(team: [Player]) -> PositionBreakdown {
        var positionCounts: [Position: Int] = [:]
        var positionValues: [Position: Int] = [:]
        var premiumPlayers: [Position: [Player]] = [:]
        var midPlayers: [Position: [Player]] = [:]
        var budgetPlayers: [Position: [Player]] = [:]
        
        for player in team {
            let position = player.position
            positionCounts[position, default: 0] += 1
            positionValues[position, default: 0] += player.price
            
            let tier = classifyPlayerTier(player: player)
            switch tier {
            case .premium:
                premiumPlayers[position, default: []].append(player)
            case .mid:
                midPlayers[position, default: []].append(player)
            case .budget:
                budgetPlayers[position, default: []].append(player)
            }
        }
        
        let positionRatings = Position.allCases.compactMap { position -> PositionRating? in
            guard let count = positionCounts[position], count > 0 else { return nil }
            
            let averageValue = positionValues[position]! / count
            let premiumCount = premiumPlayers[position]?.count ?? 0
            let midCount = midPlayers[position]?.count ?? 0
            let budgetCount = budgetPlayers[position]?.count ?? 0
            
            let strength = calculatePositionStrength(
                premiumCount: premiumCount,
                midCount: midCount,
                budgetCount: budgetCount,
                position: position
            )
            
            return PositionRating(
                position: position,
                playerCount: count,
                averageValue: averageValue,
                premiumCount: premiumCount,
                midCount: midCount,
                budgetCount: budgetCount,
                strength: strength,
                recommendation: generatePositionRecommendation(
                    position: position,
                    strength: strength,
                    distribution: (premiumCount, midCount, budgetCount)
                )
            )
        }
        
        return PositionBreakdown(
            totalPlayers: team.count,
            positionRatings: positionRatings,
            overallStructureRating: calculateStructureRating(positionRatings),
            balanceScore: calculateBalanceScore(positionRatings),
            structureType: determineStructureType(positionRatings)
        )
    }
    
    // MARK: - Salary Analysis
    private func analyzeSalaryAllocation(team: [Player]) -> SalaryAllocation {
        let totalSalary = team.reduce(0) { $0 + $1.price }
        let remainingCap = 10_000_000 - totalSalary // Standard salary cap
        
        var positionAllocations: [Position: PositionSalaryAllocation] = [:]
        
        for position in Position.allCases {
            let positionPlayers = team.filter { $0.position == position }
            let positionTotal = positionPlayers.reduce(0) { $0 + $1.price }
            let positionAverage = positionPlayers.isEmpty ? 0 : positionTotal / positionPlayers.count
            let percentage = totalSalary > 0 ? Double(positionTotal) / Double(totalSalary) * 100 : 0
            
            let optimalRange = getOptimalSalaryRange(for: position)
            let efficiency = calculateSalaryEfficiency(
                current: percentage,
                optimal: optimalRange
            )
            
            positionAllocations[position] = PositionSalaryAllocation(
                position: position,
                totalAllocated: positionTotal,
                averagePrice: positionAverage,
                percentage: percentage,
                efficiency: efficiency,
                recommendation: generateSalaryRecommendation(
                    position: position,
                    current: percentage,
                    optimal: optimalRange,
                    efficiency: efficiency
                )
            )
        }
        
        return SalaryAllocation(
            totalUsed: totalSalary,
            remainingCap: remainingCap,
            utilizationPercentage: Double(totalSalary) / 10_000_000 * 100,
            positionAllocations: positionAllocations,
            allocationRating: calculateAllocationRating(positionAllocations),
            improvements: generateSalaryImprovements(positionAllocations, remainingCap)
        )
    }
    
    // MARK: - Value Distribution Analysis
    private func analyzeValueDistribution(team: [Player]) async -> ValueDistribution {
        var playerValues: [PlayerValueAnalysis] = []
        
        for player in team {
            if let analytics = try? await playerService.getPlayerAnalytics(playerId: player.id) {
                let valueAnalysis = PlayerValueAnalysis(
                    playerId: player.id,
                    playerName: player.name,
                    currentPrice: player.price,
                    projectedValue: Int(analytics.ceilingFloorAnalysis.ceiling.score),
                    valueGap: Int(analytics.ceilingFloorAnalysis.ceiling.score) - player.price,
                    efficiency: calculatePlayerEfficiency(player: player, analytics: analytics),
                    valueRating: determineValueRating(efficiency: calculatePlayerEfficiency(player: player, analytics: analytics)),
                    upside: analytics.ceilingFloorAnalysis.ceiling.score - analytics.ceilingFloorAnalysis.floor.score,
                    consistency: analytics.consistencyScore.numericScore
                )
                playerValues.append(valueAnalysis)
            }
        }
        
        let totalValue = playerValues.reduce(0) { $0 + $1.projectedValue }
        let totalCost = team.reduce(0) { $0 + $1.price }
        let overallEfficiency = totalCost > 0 ? Double(totalValue) / Double(totalCost) : 0
        
        return ValueDistribution(
            playerValues: playerValues,
            totalProjectedValue: totalValue,
            totalCost: totalCost,
            overallEfficiency: overallEfficiency,
            valueGap: totalValue - totalCost,
            distributionRating: calculateDistributionRating(playerValues),
            topPerformers: playerValues.sorted { $0.efficiency > $1.efficiency }.prefix(5).map { $0 },
            underperformers: playerValues.sorted { $0.efficiency < $1.efficiency }.prefix(3).map { $0 }
        )
    }
    
    // MARK: - Weakness Detection
    private func detectWeaknesses(team: [Player], positionBreakdown: PositionBreakdown) async -> WeaknessDetection {
        var weaknesses: [TeamWeakness] = []
        var criticalIssues: [CriticalIssue] = []
        
        // Position imbalance detection
        for rating in positionBreakdown.positionRatings {
            if rating.strength.rawValue == "poor" || rating.strength.rawValue == "very_poor" {
                weaknesses.append(TeamWeakness(
                    type: .positionImbalance,
                    severity: rating.strength == .poor ? .moderate : .critical,
                    description: "\(rating.position) line appears weak with \(rating.premiumCount) premium players",
                    affectedPositions: [rating.position.rawValue],
                    impactScore: calculateWeaknessImpact(strength: rating.strength),
                    recommendedAction: "Consider upgrading to premium \(rating.position) players"
                ))
            }
        }
        
        // Rookie-heavy detection
        let rookieCount = team.filter { $0.price < 200_000 }.count
        if rookieCount > 8 {
            criticalIssues.append(CriticalIssue(
                issue: "Rookie Heavy Structure",
                severity: .high,
                description: "Team has \(rookieCount) rookie-priced players, creating instability",
                urgency: .high,
                fixComplexity: .moderate,
                estimatedCost: 400_000 * (rookieCount - 6) // Rough upgrade cost
            ))
        }
        
        // Premium-light detection
        let premiumCount = team.filter { $0.price > 600_000 }.count
        if premiumCount < 6 {
            criticalIssues.append(CriticalIssue(
                issue: "Premium Light Structure", 
                severity: .moderate,
                description: "Only \(premiumCount) premium players. Optimal range is 6-8.",
                urgency: .medium,
                fixComplexity: .high,
                estimatedCost: 200_000 * (8 - premiumCount)
            ))
        }
        
        // Cash constraint analysis
        let totalValue = team.reduce(0) { $0 + $1.price }
        if totalValue > 9_800_000 {
            criticalIssues.append(CriticalIssue(
                issue: "Salary Cap Constraint",
                severity: .high,
                description: "Limited trading flexibility with \(10_000_000 - totalValue) remaining",
                urgency: .high,
                fixComplexity: .low,
                estimatedCost: 0
            ))
        }
        
        let overallRisk = calculateOverallWeaknessRisk(weaknesses: weaknesses, issues: criticalIssues)
        
        return WeaknessDetection(
            overallRisk: overallRisk,
            weaknesses: weaknesses,
            criticalIssues: criticalIssues,
            improvementPriority: rankImprovementPriority(weaknesses: weaknesses, issues: criticalIssues),
            estimatedFixCost: criticalIssues.reduce(0) { $0 + $1.estimatedCost },
            timeToFix: calculateTimeToFix(issues: criticalIssues)
        )
    }
    
    // MARK: - Upgrade Pathways
    private func generateUpgradePathways(team: [Player], weaknesses: WeaknessDetection) async -> [UpgradePathway] {
        var pathways: [UpgradePathway] = []
        
        for weakness in weaknesses.weaknesses {
            guard let position = Position.allCases.first(where: { weakness.affectedPositions.contains($0.rawValue) }) else { continue }
            
            let currentPlayers = team.filter { $0.position == position }
            let downgradeCandidates = identifyDowngradeCandidates(in: currentPlayers)
            let upgradeTargets = await identifyUpgradeTargets(for: position, budget: calculateAvailableBudget(team))
            
            if !upgradeTargets.isEmpty {
                let pathway = UpgradePathway(
                    id: UUID(),
                    targetPosition: position.rawValue,
                    priority: mapSeverityToPriority(weakness.severity),
                    steps: generateUpgradeSteps(
                        downgrades: downgradeCandidates,
                        upgrades: upgradeTargets,
                        position: position
                    ),
                    totalCost: calculatePathwayCost(downgrades: downgradeCandidates, upgrades: upgradeTargets),
                    projectedGain: calculateProjectedGain(upgrades: upgradeTargets, downgrades: downgradeCandidates),
                    timeframe: estimateTimeframe(steps: generateUpgradeSteps(downgrades: downgradeCandidates, upgrades: upgradeTargets, position: position)),
                    riskLevel: assessPathwayRisk(downgrades: downgradeCandidates, upgrades: upgradeTargets),
                    alternatives: await generateAlternativePathways(position: position, budget: calculateAvailableBudget(team))
                )
                pathways.append(pathway)
            }
        }
        
        return pathways.sorted { $0.priority.order < $1.priority.order }
    }
    
    // MARK: - Helper Functions
    private func classifyPlayerTier(player: Player) -> PlayerTier {
        switch player.price {
        case 600_000...: return .premium
        case 350_000..<600_000: return .mid
        default: return .budget
        }
    }
    
    private func calculatePositionStrength(premiumCount: Int, midCount: Int, budgetCount: Int, position: Position) -> PositionStrength {
        let total = premiumCount + midCount + budgetCount
        let premiumRatio = Double(premiumCount) / Double(total)
        
        switch position {
        case .defender, .forward:
            // Need 1-2 premiums out of 6-7 players
            if premiumRatio >= 0.25 && premiumCount >= 2 { return .excellent }
            if premiumRatio >= 0.15 && premiumCount >= 1 { return .good }
            if premiumCount >= 1 { return .average }
            if midCount >= 2 { return .poor }
            return .veryPoor
            
        case .midfielder:
            // Need 2-4 premiums out of 6-8 players  
            if premiumRatio >= 0.4 && premiumCount >= 3 { return .excellent }
            if premiumRatio >= 0.25 && premiumCount >= 2 { return .good }
            if premiumCount >= 2 { return .average }
            if premiumCount >= 1 { return .poor }
            return .veryPoor
            
        case .ruck:
            // Need 1 premium out of 2-3 players
            if premiumCount >= 1 { return .excellent }
            if midCount >= 1 { return .good }
            return .poor
        }
    }
    
    private func generatePositionRecommendation(position: Position, strength: PositionStrength, distribution: (Int, Int, Int)) -> PositionRecommendation {
        switch strength {
        case .excellent:
            return .maintain
        case .good:
            return .minorUpgrade
        case .average:
            return .upgrade
        case .poor:
            return .majorUpgrade
        case .veryPoor:
            return .completeOverhaul
        }
    }
    
    private func calculateOverallTeamScore(
        positionBreakdown: PositionBreakdown,
        salaryAllocation: SalaryAllocation,
        valueDistribution: ValueDistribution,
        weaknesses: WeaknessDetection,
        risks: TeamRiskAssessment
    ) -> TeamScore {
        let structureScore = positionBreakdown.overallStructureRating
        let salaryScore = salaryAllocation.allocationRating
        let valueScore = valueDistribution.distributionRating
        let weaknessScore = 100.0 - (Double(weaknesses.weaknesses.count) * 10.0)
        let riskScore = 100.0 - (risks.overallRisk == .high ? 30.0 : risks.overallRisk == .moderate ? 15.0 : 5.0)
        
        let overall = (structureScore + salaryScore + valueScore + weaknessScore + riskScore) / 5.0
        
        return TeamScore(
            overall: min(100.0, max(0.0, overall)),
            structure: structureScore,
            salary: salaryScore,
            value: valueScore,
            weakness: weaknessScore,
            risk: riskScore,
            grade: determineGrade(score: overall)
        )
    }
    
    private func determineGrade(score: Double) -> TeamGrade {
        switch score {
        case 90...: return .elite
        case 80..<90: return .excellent
        case 70..<80: return .good
        case 60..<70: return .average
        case 50..<60: return .poor
        default: return .terrible
        }
    }
}

// MARK: - Supporting Data Models
struct TeamStructureAnalysis: Codable, Identifiable {
    let id: UUID
    let analysisDate: Date
    let teamScore: TeamScore
    let positionBreakdown: PositionBreakdown
    let salaryAllocation: SalaryAllocation
    let valueDistribution: ValueDistribution
    let weaknessDetection: WeaknessDetection
    let upgradePathways: [UpgradePathway]
    let riskAssessment: TeamRiskAssessment
    let byeRoundExposure: ByeRoundExposure
    let benchStrength: BenchStrength
    let recommendations: [AnalysisRecommendation]
}

struct TeamScore: Codable {
    let overall: Double // 0.0 - 100.0
    let structure: Double
    let salary: Double
    let value: Double
    let weakness: Double
    let risk: Double
    let grade: TeamGrade
}

enum TeamGrade: String, Codable, CaseIterable {
    case elite = "A+"
    case excellent = "A"
    case good = "B+"
    case average = "B"
    case poor = "C"
    case terrible = "D"
    
    var color: Color {
        switch self {
        case .elite: return .green
        case .excellent: return Color(red: 0.7, green: 0.9, blue: 0.4)
        case .good: return .yellow
        case .average: return .orange
        case .poor: return Color(red: 1.0, green: 0.4, blue: 0.4)
        case .terrible: return .red
        }
    }
}

struct PositionBreakdown: Codable {
    let totalPlayers: Int
    let positionRatings: [PositionRating]
    let overallStructureRating: Double
    let balanceScore: Double
    let structureType: StructureType
}

struct PositionRating: Codable {
    let position: Position
    let playerCount: Int
    let averageValue: Int
    let premiumCount: Int
    let midCount: Int
    let budgetCount: Int
    let strength: PositionStrength
    let recommendation: PositionRecommendation
}

enum PositionStrength: String, Codable, CaseIterable {
    case excellent = "excellent"
    case good = "good" 
    case average = "average"
    case poor = "poor"
    case veryPoor = "very_poor"
}

enum PositionRecommendation: String, Codable, CaseIterable {
    case maintain = "maintain"
    case minorUpgrade = "minor_upgrade"
    case upgrade = "upgrade"
    case majorUpgrade = "major_upgrade"
    case completeOverhaul = "complete_overhaul"
}

enum StructureType: String, Codable, CaseIterable {
    case balanced = "balanced"
    case premiumHeavy = "premium_heavy"
    case rookieHeavy = "rookie_heavy"
    case midHeavy = "mid_heavy"
    case unbalanced = "unbalanced"
}

enum PlayerTier: String, Codable, CaseIterable {
    case premium = "premium"
    case mid = "mid"
    case budget = "budget"
}

struct SalaryAllocation: Codable {
    let totalUsed: Int
    let remainingCap: Int
    let utilizationPercentage: Double
    let positionAllocations: [Position: PositionSalaryAllocation]
    let allocationRating: Double
    let improvements: [SalaryImprovement]
}

struct PositionSalaryAllocation: Codable {
    let position: Position
    let totalAllocated: Int
    let averagePrice: Int
    let percentage: Double
    let efficiency: Double
    let recommendation: String
}

struct SalaryImprovement: Codable {
    let description: String
    let impact: Double
    let cost: Int
    let priority: String
}

struct ValueDistribution: Codable {
    let playerValues: [PlayerValueAnalysis]
    let totalProjectedValue: Int
    let totalCost: Int
    let overallEfficiency: Double
    let valueGap: Int
    let distributionRating: Double
    let topPerformers: [PlayerValueAnalysis]
    let underperformers: [PlayerValueAnalysis]
}

struct PlayerValueAnalysis: Codable {
    let playerId: String
    let playerName: String
    let currentPrice: Int
    let projectedValue: Int
    let valueGap: Int
    let efficiency: Double
    let valueRating: ValueRating
    let upside: Int
    let consistency: Double
}

struct WeaknessDetection: Codable {
    let overallRisk: RiskLevel
    let weaknesses: [TeamWeakness]
    let criticalIssues: [CriticalIssue]
    let improvementPriority: [String]
    let estimatedFixCost: Int
    let timeToFix: Int // rounds
}

struct TeamWeakness: Codable {
    let type: WeaknessType
    let severity: WeaknessSeverity
    let description: String
    let affectedPositions: [String]
    let impactScore: Double
    let recommendedAction: String
}

struct CriticalIssue: Codable {
    let issue: String
    let severity: IssueSeverity
    let description: String
    let urgency: IssueUrgency
    let fixComplexity: FixComplexity
    let estimatedCost: Int
}

struct UpgradePathway: Codable, Identifiable {
    let id: UUID
    let targetPosition: String
    let priority: UpgradePriority
    let steps: [UpgradeStep]
    let totalCost: Int
    let projectedGain: Double
    let timeframe: Int // rounds
    let riskLevel: RiskLevel
    let alternatives: [AlternativePathway]
}

struct UpgradeStep: Codable {
    let stepNumber: Int
    let action: UpgradeAction
    let playerOut: String?
    let playerIn: String?
    let cost: Int
    let reasoning: String
}

enum WeaknessType: String, Codable, CaseIterable {
    case positionImbalance = "position_imbalance"
    case rookieHeavy = "rookie_heavy"
    case premiumLight = "premium_light"
    case valueInefficient = "value_inefficient"
    case highRisk = "high_risk"
    case cashConstrained = "cash_constrained"
}

enum WeaknessSeverity: String, Codable, CaseIterable {
    case negligible = "negligible"
    case minor = "minor"
    case moderate = "moderate"
    case major = "major"
    case critical = "critical"
}

enum IssueSeverity: String, Codable, CaseIterable {
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case critical = "critical"
}

enum IssueUrgency: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case immediate = "immediate"
}

enum FixComplexity: String, Codable, CaseIterable {
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case veryHigh = "very_high"
}

enum UpgradePriority: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium" 
    case high = "high"
    case urgent = "urgent"
    
    var order: Int {
        switch self {
        case .urgent: return 1
        case .high: return 2
        case .medium: return 3
        case .low: return 4
        }
    }
}

enum UpgradeAction: String, Codable, CaseIterable {
    case trade = "trade"
    case downgrade = "downgrade"
    case upgrade = "upgrade"
    case hold = "hold"
}

struct AlternativePathway: Codable {
    let description: String
    let cost: Int
    let projectedGain: Double
    let riskLevel: RiskLevel
}

struct TeamRiskAssessment: Codable {
    let overallRisk: RiskLevel
    let riskFactors: [TeamRiskFactor]
    let mitigationStrategies: [RiskMitigation]
    let contingencyPlans: [ContingencyPlan]
}

struct TeamRiskFactor: Codable {
    let factor: String
    let likelihood: Double
    let impact: Double
    let category: RiskCategory
}

enum RiskCategory: String, Codable, CaseIterable {
    case injury = "injury"
    case form = "form"
    case price = "price"
    case role = "role"
    case structural = "structural"
}

struct RiskMitigation: Codable {
    let strategy: String
    let effectiveness: Double
    let cost: Int
}

struct ContingencyPlan: Codable {
    let scenario: String
    let response: String
    let priority: String
}

struct ByeRoundExposure: Codable {
    let byeRoundBreakdown: [Int: [String]] // round -> player IDs
    let worstRound: Int
    let playersOut: Int
    let riskLevel: RiskLevel
    let mitigationPlan: String
}

struct BenchStrength: Codable {
    let benchPlayers: [String]
    let averageScore: Double
    let reliability: Double
    let emergencyCover: [Position: Int]
    let strength: BenchStrengthRating
}

enum BenchStrengthRating: String, Codable, CaseIterable {
    case excellent = "excellent"
    case good = "good"
    case average = "average"
    case weak = "weak"
    case veryWeak = "very_weak"
}

struct AnalysisRecommendation: Codable {
    let priority: Int
    let category: String
    let action: String
    let reasoning: String
    let expectedImpact: Double
    let timeframe: String
}

enum AnalysisError: Error, LocalizedError {
    case dataNotAvailable
    case analysisFailure(String)
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .dataNotAvailable:
            return "Required data not available for analysis"
        case .analysisFailure(let message):
            return "Analysis failed: \(message)"
        case .networkError:
            return "Network error occurred during analysis"
        }
    }
}

// MARK: - Extensions for missing functions  
extension TeamStructureAnalyzer {
    private func calculateStructureRating(_ positionRatings: [PositionRating]) -> Double {
        // Implementation needed
        return 75.0
    }
    
    private func calculateBalanceScore(_ positionRatings: [PositionRating]) -> Double {
        // Implementation needed
        return 80.0
    }
    
    private func determineStructureType(_ positionRatings: [PositionRating]) -> StructureType {
        // Implementation needed
        return .balanced
    }
    
    private func getOptimalSalaryRange(for position: Position) -> ClosedRange<Double> {
        // Implementation needed based on position
        switch position {
        case .defender: return 15.0...25.0
        case .midfielder: return 25.0...35.0
        case .ruck: return 10.0...15.0
        case .forward: return 20.0...30.0
        }
    }
    
    private func calculateSalaryEfficiency(current: Double, optimal: ClosedRange<Double>) -> Double {
        if optimal.contains(current) {
            return 100.0
        } else if current < optimal.lowerBound {
            return max(0, 100 - (optimal.lowerBound - current) * 2)
        } else {
            return max(0, 100 - (current - optimal.upperBound) * 2)
        }
    }
    
    private func generateSalaryRecommendation(position: Position, current: Double, optimal: ClosedRange<Double>, efficiency: Double) -> String {
        if efficiency > 80 {
            return "Well allocated"
        } else if current < optimal.lowerBound {
            return "Consider investing more in \(position)"
        } else {
            return "Consider reducing investment in \(position)"
        }
    }
    
    private func calculateAllocationRating(_ positionAllocations: [Position: PositionSalaryAllocation]) -> Double {
        let efficiencies = positionAllocations.values.map { $0.efficiency }
        return efficiencies.reduce(0, +) / Double(efficiencies.count)
    }
    
    private func generateSalaryImprovements(_ positionAllocations: [Position: PositionSalaryAllocation], _ remainingCap: Int) -> [SalaryImprovement] {
        // Implementation needed
        return []
    }
    
    private func calculatePlayerEfficiency(player: Player, analytics: PlayerAnalytics) -> Double {
        // Implementation needed
        return Double(analytics.ceilingFloorAnalysis.ceiling.score) / Double(player.price) * 1000
    }
    
    private func determineValueRating(efficiency: Double) -> ValueRating {
        switch efficiency {
        case 1.2...: return .exceptional
        case 1.1..<1.2: return .excellent
        case 1.0..<1.1: return .good
        case 0.9..<1.0: return .fair
        case 0.8..<0.9: return .poor
        default: return .terrible
        }
    }
    
    private func calculateDistributionRating(_ playerValues: [PlayerValueAnalysis]) -> Double {
        // Implementation needed
        return 75.0
    }
    
    private func calculateWeaknessImpact(strength: PositionStrength) -> Double {
        switch strength {
        case .veryPoor: return 30.0
        case .poor: return 20.0
        case .average: return 10.0
        case .good: return 5.0
        case .excellent: return 0.0
        }
    }
    
    private func calculateOverallWeaknessRisk(weaknesses: [TeamWeakness], issues: [CriticalIssue]) -> RiskLevel {
        let criticalCount = issues.filter { $0.severity == .critical }.count
        let highCount = issues.filter { $0.severity == .high }.count
        
        if criticalCount > 0 { return .critical }
        if highCount > 2 { return .high }
        if highCount > 0 || weaknesses.count > 3 { return .moderate }
        return .low
    }
    
    private func rankImprovementPriority(weaknesses: [TeamWeakness], issues: [CriticalIssue]) -> [String] {
        // Implementation needed
        return issues.sorted { $0.severity.rawValue > $1.severity.rawValue }.map { $0.issue }
    }
    
    private func calculateTimeToFix(issues: [CriticalIssue]) -> Int {
        // Implementation needed - estimate rounds needed to fix issues
        return max(1, issues.count * 2)
    }
    
    private func identifyDowngradeCandidates(in players: [Player]) -> [Player] {
        // Implementation needed
        return players.filter { $0.price > 400_000 }
    }
    
    private func identifyUpgradeTargets(for position: Position, budget: Int) async -> [Player] {
        // Implementation needed
        return []
    }
    
    private func calculateAvailableBudget(_ team: [Player]) -> Int {
        let totalCost = team.reduce(0) { $0 + $1.price }
        return 10_000_000 - totalCost
    }
    
    private func mapSeverityToPriority(_ severity: WeaknessSeverity) -> UpgradePriority {
        switch severity {
        case .critical: return .urgent
        case .major: return .high
        case .moderate: return .medium
        case .minor: return .low
        case .negligible: return .low
        }
    }
    
    private func generateUpgradeSteps(downgrades: [Player], upgrades: [Player], position: Position) -> [UpgradeStep] {
        // Implementation needed
        return []
    }
    
    private func calculatePathwayCost(downgrades: [Player], upgrades: [Player]) -> Int {
        let downgradeValue = downgrades.reduce(0) { $0 + $1.price }
        let upgradeValue = upgrades.reduce(0) { $0 + $1.price }
        return upgradeValue - downgradeValue
    }
    
    private func calculateProjectedGain(upgrades: [Player], downgrades: [Player]) -> Double {
        // Implementation needed - projected points gain
        return Double(upgrades.count * 10 - downgrades.count * 5)
    }
    
    private func estimateTimeframe(steps: [UpgradeStep]) -> Int {
        return max(1, steps.count)
    }
    
    private func assessPathwayRisk(downgrades: [Player], upgrades: [Player]) -> RiskLevel {
        // Implementation needed
        return .moderate
    }
    
    private func generateAlternativePathways(position: Position, budget: Int) async -> [AlternativePathway] {
        // Implementation needed
        return []
    }
    
    private func assessTeamRisks(team: [Player]) async -> TeamRiskAssessment {
        // Implementation needed
        return TeamRiskAssessment(
            overallRisk: .moderate,
            riskFactors: [],
            mitigationStrategies: [],
            contingencyPlans: []
        )
    }
    
    private func analyzeByeRoundExposure(team: [Player]) -> ByeRoundExposure {
        // Implementation needed
        return ByeRoundExposure(
            byeRoundBreakdown: [:],
            worstRound: 12,
            playersOut: 6,
            riskLevel: .moderate,
            mitigationPlan: "Ensure bench coverage"
        )
    }
    
    private func analyzeBenchStrength(team: [Player]) -> BenchStrength {
        // Implementation needed
        return BenchStrength(
            benchPlayers: [],
            averageScore: 45.0,
            reliability: 70.0,
            emergencyCover: [:],
            strength: .average
        )
    }
    
    private func generateRecommendations(team: [Player], weaknesses: WeaknessDetection, upgrades: [UpgradePathway], risks: TeamRiskAssessment) -> [AnalysisRecommendation] {
        // Implementation needed
        return []
    }
}
