import Foundation

// MARK: - Trade Analysis Models

public struct TradeAnalysis {
    public let tradeOut: Player
    public let tradeIn: Player
    public let value: TradeValue
    public let timing: TradeTiming
    public let risk: TradeRisk
    public let projectedImpact: ProjectedImpact
    public let alternatives: [TradeAlternative]
    
    public init(tradeOut: Player, tradeIn: Player, value: TradeValue, timing: TradeTiming,
                risk: TradeRisk, projectedImpact: ProjectedImpact, alternatives: [TradeAlternative]) {
        self.tradeOut = tradeOut
        self.tradeIn = tradeIn
        self.value = value
        self.timing = timing
        self.risk = risk
        self.projectedImpact = projectedImpact
        self.alternatives = alternatives
    }
}

public struct TradeValue {
    public let priceDifference: Int
    public let projectedPointsDifference: Double // Per round
    public let valueRating: TradeValueRating
    public let breakEvenRounds: Int // Rounds to recover price difference
    
    public init(priceDifference: Int, projectedPointsDifference: Double, 
                valueRating: TradeValueRating, breakEvenRounds: Int) {
        self.priceDifference = priceDifference
        self.projectedPointsDifference = projectedPointsDifference
        self.valueRating = valueRating
        self.breakEvenRounds = breakEvenRounds
    }
}

public enum TradeValueRating: String, CaseIterable {
    case excellent, good, fair, poor, terrible
    
    public var displayName: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good" 
        case .fair: return "Fair"
        case .poor: return "Poor"
        case .terrible: return "Terrible"
        }
    }
    
    public var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "lightGreen"
        case .fair: return "yellow"
        case .poor: return "orange"
        case .terrible: return "red"
        }
    }
}

public struct TradeTiming {
    public let recommendation: TimingRecommendation
    public let priceChangeRisk: PriceChangeRisk
    public let fixtureWindow: FixtureWindow
    public let optimalRound: Int?
    
    public init(recommendation: TimingRecommendation, priceChangeRisk: PriceChangeRisk,
                fixtureWindow: FixtureWindow, optimalRound: Int?) {
        self.recommendation = recommendation
        self.priceChangeRisk = priceChangeRisk
        self.fixtureWindow = fixtureWindow
        self.optimalRound = optimalRound
    }
}

public enum TimingRecommendation: String, CaseIterable {
    case immediatelyBefore, thisRound, nextRound, wait, avoid
    
    public var displayName: String {
        switch self {
        case .immediatelyBefore: return "Before Next Price Rise"
        case .thisRound: return "This Round"
        case .nextRound: return "Next Round"
        case .wait: return "Wait"
        case .avoid: return "Avoid"
        }
    }
}

public enum PriceChangeRisk: String, CaseIterable {
    case rising, stable, falling
    
    public var displayName: String {
        switch self {
        case .rising: return "Price Rising"
        case .stable: return "Price Stable"
        case .falling: return "Price Falling"
        }
    }
    
    public var impact: String {
        switch self {
        case .rising: return "Trade soon to avoid price rise"
        case .stable: return "No immediate price pressure"
        case .falling: return "Wait for price drop"
        }
    }
}

public struct FixtureWindow {
    public let tradeOutDifficulty: [Int] // Next 3 rounds
    public let tradeInDifficulty: [Int]
    public let advantage: FixtureAdvantage
    
    public init(tradeOutDifficulty: [Int], tradeInDifficulty: [Int], advantage: FixtureAdvantage) {
        self.tradeOutDifficulty = tradeOutDifficulty
        self.tradeInDifficulty = tradeInDifficulty
        self.advantage = advantage
    }
}

public enum FixtureAdvantage: String, CaseIterable {
    case strongFavor, favor, neutral, against, strongAgainst
    
    public var displayName: String {
        switch self {
        case .strongFavor: return "Strongly Favors Trade"
        case .favor: return "Favors Trade"
        case .neutral: return "Neutral"
        case .against: return "Against Trade"
        case .strongAgainst: return "Strongly Against Trade"
        }
    }
}

public struct TradeRisk {
    public let injuryRisk: PlayerRiskLevel
    public let formRisk: PlayerRiskLevel
    public let rotationRisk: PlayerRiskLevel
    public let overallRisk: RiskLevel
    
    public init(injuryRisk: PlayerRiskLevel, formRisk: PlayerRiskLevel,
                rotationRisk: PlayerRiskLevel, overallRisk: RiskLevel) {
        self.injuryRisk = injuryRisk
        self.formRisk = formRisk
        self.rotationRisk = rotationRisk
        self.overallRisk = overallRisk
    }
}

public enum PlayerRiskLevel: String, CaseIterable {
    case veryLow, low, medium, high, veryHigh
    
    public var displayName: String {
        switch self {
        case .veryLow: return "Very Low"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .veryHigh: return "Very High"
        }
    }
}

public enum RiskLevel: String, CaseIterable {
    case low, medium, high
    
    public var displayName: String {
        switch self {
        case .low: return "Low Risk"
        case .medium: return "Medium Risk"
        case .high: return "High Risk"
        }
    }
    
    public var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "red"
        }
    }
}

public struct ProjectedImpact {
    public let pointsGainNext3: Double
    public let pointsGainNext5: Double
    public let rankingImprovement: Int
    public let captainViability: CaptainViability
    
    public init(pointsGainNext3: Double, pointsGainNext5: Double,
                rankingImprovement: Int, captainViability: CaptainViability) {
        self.pointsGainNext3 = pointsGainNext3
        self.pointsGainNext5 = pointsGainNext5
        self.rankingImprovement = rankingImprovement
        self.captainViability = captainViability
    }
}

public enum CaptainViability: String, CaseIterable {
    case excellent, good, limited, poor
    
    public var displayName: String {
        switch self {
        case .excellent: return "Excellent Captain"
        case .good: return "Good Captain"
        case .limited: return "Limited Captain"
        case .poor: return "Poor Captain"
        }
    }
}

public struct TradeAlternative {
    public let player: Player
    public let valueRating: TradeValueRating
    public let shortSummary: String
    
    public init(player: Player, valueRating: TradeValueRating, shortSummary: String) {
        self.player = player
        self.valueRating = valueRating
        self.shortSummary = shortSummary
    }
}

// MARK: - Trade Suggestions

public struct TradeSuggestion {
    public let priority: SuggestionPriority
    public let type: SuggestionType
    public let player: Player
    public let reason: String
    public let urgency: Urgency
    public let alternatives: [Player]
    
    public init(priority: SuggestionPriority, type: SuggestionType, player: Player,
                reason: String, urgency: Urgency, alternatives: [Player]) {
        self.priority = priority
        self.type = type
        self.player = player
        self.reason = reason
        self.urgency = urgency
        self.alternatives = alternatives
    }
}

public enum SuggestionPriority: Int, CaseIterable {
    case critical = 1, high = 2, medium = 3, low = 4
    
    public var displayName: String {
        switch self {
        case .critical: return "Critical"
        case .high: return "High Priority"
        case .medium: return "Medium Priority"
        case .low: return "Low Priority"
        }
    }
    
    public var color: String {
        switch self {
        case .critical: return "red"
        case .high: return "orange"
        case .medium: return "yellow"
        case .low: return "green"
        }
    }
}

public enum SuggestionType: String, CaseIterable {
    case injury, suspension, priceRise, formDrop, fixtureRun, value
    
    public var displayName: String {
        switch self {
        case .injury: return "Injury Concern"
        case .suspension: return "Suspension"
        case .priceRise: return "Price Rise"
        case .formDrop: return "Form Drop"
        case .fixtureRun: return "Fixture Advantage"
        case .value: return "Value Opportunity"
        }
    }
    
    public var icon: String {
        switch self {
        case .injury: return "cross.fill"
        case .suspension: return "exclamationmark.triangle.fill"
        case .priceRise: return "arrow.up.circle.fill"
        case .formDrop: return "arrow.down.circle.fill"
        case .fixtureRun: return "calendar.circle.fill"
        case .value: return "star.circle.fill"
        }
    }
}

public enum Urgency: String, CaseIterable {
    case immediate, thisRound, nextRound, monitor
    
    public var displayName: String {
        switch self {
        case .immediate: return "Act Immediately"
        case .thisRound: return "This Round"
        case .nextRound: return "Next Round"
        case .monitor: return "Monitor"
        }
    }
}

// MARK: - Trade Analyzer Service

@available(iOS 13.0, *)
public class TradeAnalyzerService: ObservableObject {
    @Published public private(set) var currentAnalyses: [TradeAnalysis] = []
    @Published public private(set) var suggestions: [TradeSuggestion] = []
    @Published public private(set) var isAnalyzing = false
    
    private let filterService = PlayerFilteringService()
    
    public init() {}
    
    public func analyzeTrade(tradeOut: Player, tradeIn: Player) async -> TradeAnalysis {
        await MainActor.run {
            self.isAnalyzing = true
        }
        
        // Simulate analysis time
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        let analysis = generateTradeAnalysis(tradeOut: tradeOut, tradeIn: tradeIn)
        
        await MainActor.run {
            self.currentAnalyses.append(analysis)
            self.isAnalyzing = false
        }
        
        return analysis
    }
    
    public func generateSuggestions(for team: [Player]) async -> [TradeSuggestion] {
        await MainActor.run {
            self.isAnalyzing = true
        }
        
        // Simulate suggestion generation
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        let suggestions = generateMockSuggestions(for: team)
        
        await MainActor.run {
            self.suggestions = suggestions
            self.isAnalyzing = false
        }
        
        return suggestions
    }
    
    public func clearAnalyses() {
        currentAnalyses.removeAll()
    }
    
    public func removeAnalysis(_ analysis: TradeAnalysis) {
        currentAnalyses.removeAll { $0.tradeOut.id == analysis.tradeOut.id && $0.tradeIn.id == analysis.tradeIn.id }
    }
    
    // MARK: - Private Analysis Methods
    
    private func generateTradeAnalysis(tradeOut: Player, tradeIn: Player) -> TradeAnalysis {
        let priceDiff = tradeIn.price - tradeOut.price
        let pointsDiff = tradeIn.projected - tradeOut.projected
        let breakEvenRounds = max(1, abs(priceDiff) / max(Int(abs(pointsDiff) * 1000), 1))
        
        let value = TradeValue(
            priceDifference: priceDiff,
            projectedPointsDifference: pointsDiff,
            valueRating: calculateValueRating(priceDiff: priceDiff, pointsDiff: pointsDiff),
            breakEvenRounds: breakEvenRounds
        )
        
        let timing = TradeTiming(
            recommendation: TimingRecommendation.allCases.randomElement() ?? .thisRound,
            priceChangeRisk: PriceChangeRisk.allCases.randomElement() ?? .stable,
            fixtureWindow: FixtureWindow(
                tradeOutDifficulty: [3, 2, 4],
                tradeInDifficulty: [2, 1, 3],
                advantage: FixtureAdvantage.allCases.randomElement() ?? .neutral
            ),
            optimalRound: Int.random(in: 24...27)
        )
        
        let risk = TradeRisk(
            injuryRisk: PlayerRiskLevel.allCases.randomElement() ?? .low,
            formRisk: PlayerRiskLevel.allCases.randomElement() ?? .medium,
            rotationRisk: PlayerRiskLevel.allCases.randomElement() ?? .low,
            overallRisk: RiskLevel.allCases.randomElement() ?? .medium
        )
        
        let impact = ProjectedImpact(
            pointsGainNext3: pointsDiff * 3,
            pointsGainNext5: pointsDiff * 5,
            rankingImprovement: Int.random(in: -5000...15000),
            captainViability: CaptainViability.allCases.randomElement() ?? .good
        )
        
        let alternatives = generateTradeAlternatives(for: tradeIn)
        
        return TradeAnalysis(
            tradeOut: tradeOut,
            tradeIn: tradeIn,
            value: value,
            timing: timing,
            risk: risk,
            projectedImpact: impact,
            alternatives: alternatives
        )
    }
    
    private func calculateValueRating(priceDiff: Int, pointsDiff: Double) -> TradeValueRating {
        let valueRatio = pointsDiff / Double(max(abs(priceDiff), 1000)) * 100000
        
        switch valueRatio {
        case 15...: return .excellent
        case 10..<15: return .good
        case 5..<10: return .fair
        case 0..<5: return .poor
        default: return .terrible
        }
    }
    
    private func generateTradeAlternatives(for player: Player) -> [TradeAlternative] {
        // In real implementation, would find similar players
        return (1...3).map { i in
            TradeAlternative(
                player: Player(
                    id: "alt_\(i)",
                    name: "Alternative \(i)",
                    position: player.position,
                    team: "ALT",
                    price: player.price + Int.random(in: -100000...100000),
                    average: Double.random(in: 60...120),
                    projected: Double.random(in: 60...120),
                    breakeven: Int.random(in: 30...100)
                ),
                valueRating: TradeValueRating.allCases.randomElement() ?? .fair,
                shortSummary: "Similar player with different fixtures"
            )
        }
    }
    
    private func generateMockSuggestions(for team: [Player]) -> [TradeSuggestion] {
        return team.prefix(5).map { player in
            TradeSuggestion(
                priority: SuggestionPriority.allCases.randomElement() ?? .medium,
                type: SuggestionType.allCases.randomElement() ?? .value,
                player: player,
                reason: generateSuggestionReason(),
                urgency: Urgency.allCases.randomElement() ?? .monitor,
                alternatives: []
            )
        }
    }
    
    private func generateSuggestionReason() -> String {
        let reasons = [
            "Has difficult fixtures coming up",
            "Price expected to rise soon", 
            "Form trending downward",
            "Injury concern reported",
            "Better value alternatives available",
            "Rotation risk increasing"
        ]
        return reasons.randomElement() ?? "Monitor closely"
    }
}
