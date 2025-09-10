import Foundation

// MARK: - Price Analytics
struct PriceAnalytics: Codable, Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let currentPrice: Int
    let priceTrajectory: [PriceProjection]
    let breakEvenAnalysis: BreakEvenProjection
    let cashGenerationPotential: CashGenPotential
    let optimalSellWindow: SellWindow
    let marketCycle: PriceCycleAnalysis
    let valueAnalysis: ValueAnalysis
    let pricingHistory: [PriceHistoryPeriod]
    let riskAssessment: PriceRiskAssessment
    let comparativeAnalysis: ComparativePrice
    let lastUpdated: Date
}

// MARK: - Price Trajectory & Projections
struct PriceProjection: Codable, Identifiable {
    let id = UUID()
    let round: Int
    let projectedPrice: Int
    let priceChange: Int
    let confidence: ConfidenceLevel
    let keyDrivers: [PriceDriver]
    let scenarioAnalysis: PriceScenarios
    let probability: Double // 0.0 - 1.0
}

struct PriceScenarios: Codable {
    let best_case: PriceScenario
    let expected: PriceScenario
    let worst_case: PriceScenario
}

struct PriceScenario: Codable {
    let price: Int
    let probability: Double
    let assumptions: [String]
    let keyFactors: [String]
}

struct PriceDriver: Codable {
    let factor: PriceDriverType
    let impact: Int // price change in dollars
    let weight: Double // 0.0 - 1.0
    let confidence: ConfidenceLevel
    let description: String
}

enum PriceDriverType: String, Codable, CaseIterable {
    case performance = "performance"
    case injury = "injury"
    case roleChange = "role_change"
    case form = "form"
    case marketSentiment = "market_sentiment"
    case ownership = "ownership"
    case team_news = "team_news"
    case suspension = "suspension"
    case season_context = "season_context"
    
    var description: String {
        switch self {
        case .performance: return "Performance"
        case .injury: return "Injury"
        case .roleChange: return "Role Change"
        case .form: return "Form"
        case .marketSentiment: return "Market Sentiment"
        case .ownership: return "Ownership"
        case .team_news: return "Team News"
        case .suspension: return "Suspension"
        case .season_context: return "Season Context"
        }
    }
}

// MARK: - Breakeven Analysis
struct BreakEvenProjection: Codable {
    let currentBreakEven: Int
    let projectedBreakEvens: [BreakEvenRound]
    let difficultyAssessment: BreakEvenDifficulty
    let achievabilityRating: AchievabilityRating
    let recommendedAction: BreakEvenRecommendation
    let riskFactors: [BreakEvenRisk]
    let opportunities: [BreakEvenOpportunity]
}

struct BreakEvenRound: Codable {
    let round: Int
    let breakEven: Int
    let achievabilityProbability: Double
    let keyMatchups: [String]
    let riskLevel: RiskLevel
}

struct BreakEvenRisk: Codable {
    let risk: String
    let impact: Int // price change impact
    let likelihood: Double
    let mitigation: String
}

struct BreakEvenOpportunity: Codable {
    let opportunity: String
    let potential: Int // price change potential
    let likelihood: Double
    let requirements: [String]
}

enum BreakEvenDifficulty: String, Codable, CaseIterable {
    case veryEasy = "very_easy"
    case easy = "easy"
    case moderate = "moderate"
    case hard = "hard"
    case veryHard = "very_hard"
    
    var description: String {
        switch self {
        case .veryEasy: return "Very Easy"
        case .easy: return "Easy"
        case .moderate: return "Moderate"
        case .hard: return "Hard"
        case .veryHard: return "Very Hard"
        }
    }
}

enum AchievabilityRating: String, Codable, CaseIterable {
    case certain = "certain" // 90%+
    case likely = "likely" // 70-90%
    case moderate = "moderate" // 50-70%
    case unlikely = "unlikely" // 30-50%
    case veryUnlikely = "very_unlikely" // <30%
    
    var percentage: String {
        switch self {
        case .certain: return "90%+"
        case .likely: return "70-90%"
        case .moderate: return "50-70%"
        case .unlikely: return "30-50%"
        case .veryUnlikely: return "<30%"
        }
    }
}

enum BreakEvenRecommendation: String, Codable, CaseIterable {
    case hold = "hold"
    case sellNow = "sell_now"
    case sellNext1_2 = "sell_next_1_2"
    case sellNext3_5 = "sell_next_3_5"
    case longTermHold = "long_term_hold"
    case upgrade = "upgrade"
    
    var description: String {
        switch self {
        case .hold: return "Hold Current Position"
        case .sellNow: return "Sell Immediately"
        case .sellNext1_2: return "Sell in Next 1-2 Rounds"
        case .sellNext3_5: return "Sell in Next 3-5 Rounds"
        case .longTermHold: return "Long Term Hold"
        case .upgrade: return "Upgrade if Possible"
        }
    }
}

enum RiskLevel: String, Codable, CaseIterable {
    case minimal = "minimal"
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case critical = "critical"
}

// MARK: - Cash Generation Analysis
struct CashGenPotential: Codable {
    let potentialGain: Int
    let timeToGenerate: Int // rounds
    let efficiency: CashGenEfficiency
    let optimalEntry: OptimalEntryPoint
    let exitStrategy: ExitStrategy
    let alternativeOptions: [AlternativeOption]
    let riskReward: RiskRewardProfile
}

struct OptimalEntryPoint: Codable {
    let round: Int?
    let price: Int?
    let conditions: [EntryCondition]
    let probability: Double
}

struct EntryCondition: Codable {
    let condition: String
    let importance: ConditionImportance
    let description: String
}

struct ExitStrategy: Codable {
    let recommendedRounds: [Int]
    let targetPrice: Int
    let conditions: [ExitCondition]
    let fallbackPlan: String
}

struct ExitCondition: Codable {
    let condition: String
    let triggerValue: String
    let action: ExitAction
}

struct AlternativeOption: Codable {
    let playerId: String
    let playerName: String
    let advantage: String
    let reason: String
    let comparison: ComparisonMetric
}

struct RiskRewardProfile: Codable {
    let reward: Int // potential cash generation
    let risk: RiskAssessment
    let timeframe: Int // rounds
    let confidence: ConfidenceLevel
}

struct RiskAssessment: Codable {
    let injuryRisk: RiskLevel
    let suspensionRisk: RiskLevel
    let formRisk: RiskLevel
    let roleRisk: RiskLevel
    let overallRisk: RiskLevel
}

enum CashGenEfficiency: String, Codable, CaseIterable {
    case excellent = "excellent" // High gain, low risk
    case good = "good"
    case average = "average"
    case poor = "poor"
    case terrible = "terrible" // Low gain, high risk
}

enum ConditionImportance: String, Codable, CaseIterable {
    case critical = "critical"
    case important = "important"
    case moderate = "moderate"
    case minor = "minor"
}

enum ExitAction: String, Codable, CaseIterable {
    case sellImmediately = "sell_immediately"
    case sellNextRound = "sell_next_round"
    case holdAndReassess = "hold_and_reassess"
    case upgradeNow = "upgrade_now"
}

struct ComparisonMetric: Codable {
    let cashGenPotential: Int
    let timeframe: Int
    let risk: RiskLevel
    let overall: ComparisonRating
}

enum ComparisonRating: String, Codable, CaseIterable {
    case muchBetter = "much_better"
    case better = "better"
    case similar = "similar"
    case worse = "worse"
    case muchWorse = "much_worse"
}

// MARK: - Optimal Sell Windows
struct SellWindow: Codable {
    let window: SellWindowPeriod
    let recommendedRounds: [Int]
    let peakPriceProjection: PeakProjection
    let marketTiming: MarketTiming
    let sellTriggers: [SellTrigger]
    let holdTriggers: [HoldTrigger]
}

struct SellWindowPeriod: Codable {
    let start: Int // round number
    let end: Int // round number
    let optimalRound: Int
    let confidence: ConfidenceLevel
}

struct PeakProjection: Codable {
    let projectedPeak: Int
    let peakRound: Int
    let peakProbability: Double
    let peakConditions: [String]
}

struct MarketTiming: Codable {
    let marketPhase: MarketPhase
    let sentiment: MarketSentiment
    let timing: TimingAdvice
    let alternativeWindows: [SellWindowPeriod]
}

struct SellTrigger: Codable {
    let trigger: String
    let importance: TriggerImportance
    let action: SellAction
    let description: String
}

struct HoldTrigger: Codable {
    let trigger: String
    let reason: String
    let reassessmentRound: Int
    let description: String
}

enum MarketPhase: String, Codable, CaseIterable {
    case earlyRising = "early_rising"
    case peaking = "peaking"
    case plateauing = "plateauing"
    case declining = "declining"
    case bottoming = "bottoming"
}

enum MarketSentiment: String, Codable, CaseIterable {
    case veryBullish = "very_bullish"
    case bullish = "bullish"
    case neutral = "neutral"
    case bearish = "bearish"
    case veryBearish = "very_bearish"
}

enum TimingAdvice: String, Codable, CaseIterable {
    case sellNow = "sell_now"
    case sellSoon = "sell_soon"
    case waitForPeak = "wait_for_peak"
    case hold = "hold"
    case buyMore = "buy_more"
}

enum TriggerImportance: String, Codable, CaseIterable {
    case critical = "critical"
    case high = "high"
    case medium = "medium"
    case low = "low"
}

enum SellAction: String, Codable, CaseIterable {
    case sellImmediately = "sell_immediately"
    case sellThisRound = "sell_this_round"
    case sellNextRound = "sell_next_round"
    case prepareToSell = "prepare_to_sell"
}

// MARK: - Price Cycle Analysis
struct PriceCycleAnalysis: Codable {
    let currentPhase: PriceCyclePhase
    let cyclePosition: Double // 0.0 - 1.0
    let cycleDuration: CycleDuration
    let historicalPatterns: [HistoricalCycle]
    let cyclePrediction: CyclePrediction
    let buyLowSellHighOpportunities: [BuyLowSellHighOpportunity]
}

struct CycleDuration: Codable {
    let averageLength: Int // rounds
    let currentCycleLength: Int
    let predictedRemainingLength: Int
}

struct HistoricalCycle: Codable {
    let startRound: Int
    let endRound: Int
    let startPrice: Int
    let peakPrice: Int
    let endPrice: Int
    let gain: Int
    let duration: Int
}

struct CyclePrediction: Codable {
    let nextPhase: PriceCyclePhase
    let phaseTransitionRound: Int
    let confidence: ConfidenceLevel
    let keyIndicators: [CycleIndicator]
}

struct CycleIndicator: Codable {
    let indicator: String
    let currentValue: Double
    let thresholdValue: Double
    let signal: SignalStrength
}

struct BuyLowSellHighOpportunity: Codable, Identifiable {
    let id = UUID()
    let opportunityType: OpportunityType
    let entryPrice: Int
    let targetPrice: Int
    let entryRound: Int
    let exitRound: Int
    let profit: Int
    let risk: RiskLevel
    let confidence: ConfidenceLevel
}

enum PriceCyclePhase: String, Codable, CaseIterable {
    case bottom = "bottom"
    case earlyRise = "early_rise"
    case rising = "rising"
    case peak = "peak"
    case earlyDecline = "early_decline"
    case declining = "declining"
    
    var description: String {
        switch self {
        case .bottom: return "Bottom"
        case .earlyRise: return "Early Rise"
        case .rising: return "Rising"
        case .peak: return "Peak"
        case .earlyDecline: return "Early Decline"
        case .declining: return "Declining"
        }
    }
}

enum SignalStrength: String, Codable, CaseIterable {
    case veryStrong = "very_strong"
    case strong = "strong"
    case moderate = "moderate"
    case weak = "weak"
    case veryWeak = "very_weak"
}

enum OpportunityType: String, Codable, CaseIterable {
    case buyLow = "buy_low"
    case sellHigh = "sell_high"
    case quickFlip = "quick_flip"
    case longTermHold = "long_term_hold"
}

// MARK: - Value Analysis
struct ValueAnalysis: Codable {
    let currentValue: ValueAssessment
    let projectedValue: [ValueProjection]
    let valueVsPrice: ValueRating
    let valueDrivers: [ValueDriver]
    let marketComparison: MarketComparison
    let valueRisk: ValueRisk
}

struct ValueAssessment: Codable {
    let intrinsicValue: Int
    let marketValue: Int
    let fantasyValue: Int
    let efficiency: ValueEfficiency
    let rating: ValueRating
}

struct ValueProjection: Codable {
    let round: Int
    let projectedValue: Int
    let valueChange: Int
    let confidence: ConfidenceLevel
}

struct ValueDriver: Codable {
    let driver: String
    let impact: Int
    let weight: Double
    let trend: TrendDirection
    let sustainability: Sustainability
}

struct MarketComparison: Codable {
    let positionRank: Int
    let priceRank: Int
    let valueRank: Int
    let overvaluedBy: Int?
    let undervaluedBy: Int?
    let fairValue: Int
}

struct ValueRisk: Codable {
    let volatility: VolatilityRating
    let downside: Int
    let upside: Int
    let stabilityFactors: [String]
    let riskFactors: [String]
}

enum ValueRating: String, Codable, CaseIterable {
    case exceptional = "exceptional"
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
    case terrible = "terrible"
}

enum ValueEfficiency: String, Codable, CaseIterable {
    case veryHigh = "very_high"
    case high = "high"
    case moderate = "moderate"
    case low = "low"
    case veryLow = "very_low"
}

enum Sustainability: String, Codable, CaseIterable {
    case veryHigh = "very_high"
    case high = "high"
    case moderate = "moderate"
    case low = "low"
    case veryLow = "very_low"
}

enum VolatilityRating: String, Codable, CaseIterable {
    case veryHigh = "very_high"
    case high = "high"
    case moderate = "moderate"
    case low = "low"
    case veryLow = "very_low"
}

// MARK: - Historical Pricing Analysis
struct PriceHistoryPeriod: Codable {
    let period: TimePeriod
    let startPrice: Int
    let endPrice: Int
    let peakPrice: Int
    let valleyPrice: Int
    let volatility: Double
    let majorEvents: [PriceMajorEvent]
    let patterns: [PricePattern]
}

struct PriceMajorEvent: Codable {
    let date: Date
    let round: Int
    let event: String
    let priceImpact: Int
    let impactDuration: Int // rounds
    let eventType: EventType
}

struct PricePattern: Codable {
    let pattern: String
    let frequency: Double
    let impact: Int
    let reliability: Double
    let description: String
}

enum TimePeriod: String, Codable, CaseIterable {
    case currentSeason = "current_season"
    case last3Rounds = "last_3_rounds"
    case last6Rounds = "last_6_rounds"
    case earlySession = "early_season"
    case midSeason = "mid_season"
    case lateSeason = "late_season"
    case previousSeason = "previous_season"
    case careerHistory = "career_history"
}

enum EventType: String, Codable, CaseIterable {
    case injury = "injury"
    case return = "return"
    case roleChange = "role_change"
    case formBreakout = "form_breakout"
    case formSlump = "form_slump"
    case suspension = "suspension"
    case marketCorrection = "market_correction"
    case ownershipShift = "ownership_shift"
}

// MARK: - Risk Assessment
struct PriceRiskAssessment: Codable {
    let overallRisk: RiskLevel
    let specificRisks: [SpecificRisk]
    let riskMitigation: [RiskMitigation]
    let worstCaseScenario: WorstCaseScenario
    let bestCaseScenario: BestCaseScenario
    let probabilityDistribution: ProbabilityDistribution
}

struct SpecificRisk: Codable {
    let riskType: RiskType
    let probability: Double
    let impact: Int
    let timeframe: Int
    let mitigation: String
}

struct RiskMitigation: Codable {
    let strategy: String
    let effectiveness: MitigationEffectiveness
    let cost: MitigationCost
    let implementation: String
}

struct WorstCaseScenario: Codable {
    let scenario: String
    let priceImpact: Int
    let probability: Double
    let triggers: [String]
    let timeframe: Int
}

struct BestCaseScenario: Codable {
    let scenario: String
    let priceGain: Int
    let probability: Double
    let requirements: [String]
    let timeframe: Int
}

struct ProbabilityDistribution: Codable {
    let outcomes: [PriceOutcome]
    let expectedValue: Int
    let variance: Double
    let confidenceInterval: ConfidenceRange
}

struct PriceOutcome: Codable {
    let priceChange: Int
    let probability: Double
    let scenario: String
}

struct ConfidenceRange: Codable {
    let lower: Int
    let upper: Int
    let confidence: Double // 0.0 - 1.0
}

enum RiskType: String, Codable, CaseIterable {
    case injury = "injury"
    case suspension = "suspension"
    case formSlump = "form_slump"
    case roleChange = "role_change"
    case teamChanges = "team_changes"
    case marketVolatility = "market_volatility"
    case overpricing = "overpricing"
    case competition = "competition"
}

enum MitigationEffectiveness: String, Codable, CaseIterable {
    case veryHigh = "very_high"
    case high = "high"
    case moderate = "moderate"
    case low = "low"
    case minimal = "minimal"
}

enum MitigationCost: String, Codable, CaseIterable {
    case free = "free"
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case veryHigh = "very_high"
}

// MARK: - Comparative Price Analysis
struct ComparativePrice: Codable {
    let positionComparison: PositionPriceComparison
    let teamComparison: TeamPriceComparison
    let marketComparison: MarketPositioning
    let historicalComparison: HistoricalPositioning
    let efficiencyRanking: EfficiencyRanking
}

struct PositionPriceComparison: Codable {
    let position: String
    let priceRank: Int
    let valueRank: Int
    let efficiencyRank: Int
    let comparison: [PlayerPriceComparison]
}

struct PlayerPriceComparison: Codable {
    let playerId: String
    let playerName: String
    let price: Int
    let value: Int
    let efficiency: Double
    let comparison: ComparisonResult
}

struct TeamPriceComparison: Codable {
    let teamRank: Int
    let teamAveragePrice: Int
    let teamPriceEfficiency: Double
    let comparison: [TeammatePriceComparison]
}

struct TeammatePriceComparison: Codable {
    let playerId: String
    let playerName: String
    let priceGap: Int
    let valueGap: Int
    let efficiencyGap: Double
}

struct MarketPositioning: Codable {
    let overallRank: Int
    let pricePercentile: Double
    let valuePercentile: Double
    let marketShare: Double
    let positioning: MarketPosition
}

struct HistoricalPositioning: Codable {
    let currentVsHistoricalAverage: Int
    let percentileRank: Double
    let trendOverTime: TrendDirection
    let cyclicalPosition: CyclicalPosition
}

struct EfficiencyRanking: Codable {
    let overallEfficiency: Int
    let positionEfficiency: Int
    let priceEfficiency: Int
    let valueEfficiency: Double
}

enum ComparisonResult: String, Codable, CaseIterable {
    case muchBetter = "much_better"
    case better = "better"
    case similar = "similar"
    case worse = "worse"
    case muchWorse = "much_worse"
}

enum MarketPosition: String, Codable, CaseIterable {
    case premium = "premium"
    case midTier = "mid_tier"
    case budget = "budget"
    case value = "value"
    case overpriced = "overpriced"
}

enum CyclicalPosition: String, Codable, CaseIterable {
    case wellAboveAverage = "well_above_average"
    case aboveAverage = "above_average"
    case average = "average"
    case belowAverage = "below_average"
    case wellBelowAverage = "well_below_average"
}
