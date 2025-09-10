import Foundation

// MARK: - Weekly Intelligence Dashboard
struct WeeklyIntelligence: Codable, Identifiable {
    let id = UUID()
    let round: Int
    let season: String
    let fixtureComplexity: FixtureRating
    let captainOptions: [CaptainAnalysis]
    let tradeOpportunities: [TradeWindow]
    let priceAlerts: [PriceMovementAlert]
    let injuryWatch: [InjuryRiskPlayer]
    let weatherImpacts: [WeatherAlert]
    let breakoutCandidates: [BreakoutCandidate]
    let sellTargets: [SellTarget]
    let cashCowAlerts: [CashCowAlert]
    let teamNews: [TeamNewsImpact]
    let lastUpdated: Date
}

// MARK: - Fixture Analysis
struct FixtureRating: Codable {
    let overall: FixtureComplexity
    let byPosition: [String: FixtureComplexity] // position -> complexity
    let easyMatchups: [EasyMatchup]
    let hardMatchups: [HardMatchup]
    let neutralMatchups: [NeutralMatchup]
    let weeklyTrend: TrendDirection
    let comparisonToPreviousWeek: FixtureComparison
}

struct EasyMatchup: Codable, Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let opponent: String
    let difficulty: MatchupDifficulty
    let projectedScore: Double
    let upside: Double
    let confidence: ConfidenceLevel
}

struct HardMatchup: Codable, Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let opponent: String
    let difficulty: MatchupDifficulty
    let projectedScore: Double
    let downside: Double
    let riskFactors: [String]
}

struct NeutralMatchup: Codable, Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let opponent: String
    let difficulty: MatchupDifficulty
    let projectedScore: Double
    let variance: Double
}

enum FixtureComplexity: String, Codable, CaseIterable {
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

enum FixtureComparison: String, Codable, CaseIterable {
    case muchEasier = "much_easier"
    case easier = "easier"
    case similar = "similar"
    case harder = "harder"
    case muchHarder = "much_harder"
}

// MARK: - Captain Analysis
struct CaptainAnalysis: Codable, Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let position: String
    let captainScore: Double // 0.0 - 100.0
    let projectedScore: Double
    let ceiling: Int
    let floor: Int
    let ownership: Double
    let differentialScore: Double // How unique is this pick
    let riskLevel: RiskLevel
    let matchupAdvantage: MatchupAdvantage
    let formRating: FormRating
    let venueImpact: VenueImpact
    let weatherImpact: WeatherImpact_Level
    let keyFactors: [CaptainFactor]
    let recommendation: CaptainRecommendation
}

struct CaptainFactor: Codable {
    let factor: String
    let impact: Double // -10.0 to +10.0
    let weight: Double // 0.0 to 1.0
    let description: String
}

struct MatchupAdvantage: Codable {
    let rating: AdvantageRating
    let opponent: String
    let dvpRank: Int
    let historicalAverage: Double
    let keyAdvantages: [String]
}

struct VenueImpact: Codable {
    let venue: String
    let impact: Double // -10.0 to +10.0
    let historicalAverage: Double
    let venueRating: VenueRating
    let keyFactors: [String]
}

enum AdvantageRating: String, Codable, CaseIterable {
    case massive = "massive"
    case significant = "significant"
    case moderate = "moderate"
    case slight = "slight"
    case none = "none"
    case disadvantage = "disadvantage"
}

enum WeatherImpact_Level: String, Codable, CaseIterable {
    case veryPositive = "very_positive"
    case positive = "positive"
    case neutral = "neutral"
    case negative = "negative"
    case veryNegative = "very_negative"
}

enum CaptainRecommendation: String, Codable, CaseIterable {
    case premium = "premium" // Top tier pick
    case value = "value" // Good option, lower ownership
    case differential = "differential" // Unique pick with upside
    case safe = "safe" // Consistent, lower risk
    case avoid = "avoid" // Too risky this week
}

// MARK: - Trade Opportunities
struct TradeWindow: Codable, Identifiable {
    let id = UUID()
    let tradeType: TradeType
    let priority: TradePriority
    let players: TradePlayerPair
    let tradeScore: Double // 0.0 - 100.0
    let cashImpact: Int
    let projectedGain: Double // points over next 3 rounds
    let riskAssessment: TradeRisk
    let timing: TradeTiming
    let reasoning: String
    let alternatives: [AlternativeTrade]
}

struct TradePlayerPair: Codable {
    let playerOut: TradePlayer
    let playerIn: TradePlayer
    let upgrade: Bool
    let sideways: Bool
    let downgrade: Bool
}

struct TradePlayer: Codable {
    let playerId: String
    let playerName: String
    let position: String
    let price: Int
    let projectedScore: Double
    let form: FormRating
    let fixtures: FixtureRating
}

struct TradeRisk: Codable {
    let overall: RiskLevel
    let playerOutRisks: [String]
    let playerInRisks: [String]
    let timingRisk: RiskLevel
    let marketRisk: RiskLevel
}

struct TradeTiming: Codable {
    let urgency: TradeUrgency
    let optimalRound: Int?
    let deadline: Date?
    let priceChangeRisk: RiskLevel
}

struct AlternativeTrade: Codable {
    let playerId: String
    let playerName: String
    let reason: String
    let scoreAdvantage: Double
    let riskAdvantage: RiskLevel
}

enum TradeType: String, Codable, CaseIterable {
    case upgrade = "upgrade"
    case sideways = "sideways"
    case downgrade = "downgrade"
    case cashGeneration = "cash_generation"
    case riskMitigation = "risk_mitigation"
    case fixturePlay = "fixture_play"
}

enum TradePriority: String, Codable, CaseIterable {
    case urgent = "urgent"
    case high = "high"
    case medium = "medium"
    case low = "low"
    case optional = "optional"
}

enum TradeUrgency: String, Codable, CaseIterable {
    case immediate = "immediate" // Must do this round
    case thisWeek = "this_week" // Should do this round
    case nextWeek = "next_week" // Can wait 1 round
    case flexible = "flexible" // No time pressure
}

// MARK: - Price Movement Alerts
struct PriceMovementAlert: Codable, Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let alertType: PriceAlertType
    let currentPrice: Int
    let projectedChange: Int
    let confidence: ConfidenceLevel
    let timeframe: Int // rounds
    let action: RecommendedAction
    let reasoning: String
    let urgency: AlertUrgency
}

enum PriceAlertType: String, Codable, CaseIterable {
    case riseAlert = "rise_alert"
    case fallAlert = "fall_alert"
    case sellWindow = "sell_window"
    case buyWindow = "buy_window"
    case breakEvenRisk = "breakeven_risk"
    case cashCowPeak = "cash_cow_peak"
}

enum RecommendedAction: String, Codable, CaseIterable {
    case buyNow = "buy_now"
    case sellNow = "sell_now"
    case holdAndMonitor = "hold_and_monitor"
    case waitForDip = "wait_for_dip"
    case avoidCompletely = "avoid_completely"
}

enum AlertUrgency: String, Codable, CaseIterable {
    case critical = "critical" // Act immediately
    case high = "high" // Act this round
    case medium = "medium" // Act within 2 rounds
    case low = "low" // Monitor closely
    case info = "info" // Good to know
}

// MARK: - Injury Watch
struct InjuryRiskPlayer: Codable, Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let riskLevel: InjuryRiskLevel
    let riskFactors: [InjuryRiskFactor]
    let injuryHistory: [RecentInjury]
    let loadManagement: LoadManagementStatus
    let recommendation: InjuryRecommendation
    let monitoring: MonitoringAdvice
}

struct InjuryRiskFactor: Codable {
    let factor: String
    let severity: RiskLevel
    let description: String
    let likelihood: Double
}

struct RecentInjury: Codable {
    let date: Date
    let injury: String
    let gamesOut: Int
    let returnImpact: Double
    let recurringRisk: Double
}

enum LoadManagementStatus: String, Codable, CaseIterable {
    case none = "none"
    case light = "light"
    case moderate = "moderate"
    case heavy = "heavy"
    case managed = "managed"
}

enum InjuryRecommendation: String, Codable, CaseIterable {
    case hold = "hold"
    case sellBeforeInjury = "sell_before_injury"
    case tradeOut = "trade_out"
    case monitorClosely = "monitor_closely"
    case noAction = "no_action"
}

enum MonitoringAdvice: String, Codable, CaseIterable {
    case dailyCheck = "daily_check"
    case weeklyCheck = "weekly_check"
    case matchDayCheck = "match_day_check"
    case noMonitoringNeeded = "no_monitoring_needed"
}

// MARK: - Weather Alerts
struct WeatherAlert: Codable, Identifiable {
    let id = UUID()
    let venue: String
    let match: String
    let weatherCondition: WeatherCondition
    let impact: WeatherGameImpact
    let affectedPlayers: [WeatherAffectedPlayer]
    let recommendation: WeatherRecommendation
}

struct WeatherCondition: Codable {
    let condition: WeatherType
    let severity: WeatherSeverity
    let temperature: Double
    let windSpeed: Double
    let humidity: Double
    let precipitation: Double
}

struct WeatherGameImpact: Codable {
    let gameImpact: GameImpactLevel
    let scoringImpact: ScoringImpact
    let positionImpacts: [String: PositionImpact] // position -> impact
}

struct WeatherAffectedPlayer: Codable {
    let playerId: String
    let playerName: String
    let expectedImpact: Double
    let historicalImpact: Double
    let recommendation: PlayerWeatherRecommendation
}

enum WeatherType: String, Codable, CaseIterable {
    case sunny = "sunny"
    case cloudy = "cloudy"
    case rain = "rain"
    case heavyRain = "heavy_rain"
    case wind = "wind"
    case strongWind = "strong_wind"
    case hot = "hot"
    case cold = "cold"
    case humid = "humid"
}

enum WeatherSeverity: String, Codable, CaseIterable {
    case mild = "mild"
    case moderate = "moderate"
    case severe = "severe"
    case extreme = "extreme"
}

enum GameImpactLevel: String, Codable, CaseIterable {
    case minimal = "minimal"
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case severe = "severe"
}

enum ScoringImpact: String, Codable, CaseIterable {
    case increased = "increased"
    case normal = "normal"
    case decreased = "decreased"
    case significantlyDecreased = "significantly_decreased"
}

struct PositionImpact: Codable {
    let impact: Double // -20.0 to +20.0
    let affected: Bool
    let reasoning: String
}

enum WeatherRecommendation: String, Codable, CaseIterable {
    case capitalize = "capitalize" // Weather helps certain players
    case avoid = "avoid" // Weather hurts certain players
    case neutral = "neutral" // No significant impact
    case monitor = "monitor" // Watch for changes
}

enum PlayerWeatherRecommendation: String, Codable, CaseIterable {
    case captain = "captain" // Great captain option
    case start = "start" // Good to play
    case avoid = "avoid" // Bench if possible
    case neutral = "neutral" // No change needed
}

// MARK: - Breakout Candidates & Other Alerts
struct BreakoutCandidate: Codable, Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let breakoutProbability: Double
    let catalysts: [BreakoutCatalyst]
    let projectedScoreIncrease: Double
    let timeframe: Int // rounds
    let investment: BreakoutInvestment
}

struct BreakoutCatalyst: Codable {
    let catalyst: String
    let impact: Double
    let likelihood: Double
    let description: String
}

enum BreakoutInvestment: String, Codable, CaseIterable {
    case lowRisk = "low_risk"
    case moderate = "moderate"
    case aggressive = "aggressive"
    case speculative = "speculative"
}

struct SellTarget: Codable, Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let sellReason: SellReason
    let urgency: SellUrgency
    let targetPrice: Int?
    let alternativeOptions: [String]
    let riskOfHolding: RiskLevel
}

enum SellReason: String, Codable, CaseIterable {
    case peakPrice = "peak_price"
    case injuryRisk = "injury_risk"
    case badFixtures = "bad_fixtures"
    case roleChange = "role_change"
    case formDecline = "form_decline"
    case betterOptions = "better_options"
}

enum SellUrgency: String, Codable, CaseIterable {
    case immediate = "immediate"
    case thisRound = "this_round"
    case nextRound = "next_round"
    case soon = "soon"
    case flexible = "flexible"
}

struct CashCowAlert: Codable, Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let alertType: CashCowAlertType
    let currentPrice: Int
    let targetPrice: Int
    let estimatedRounds: Int
    let confidence: ConfidenceLevel
    let riskFactors: [String]
}

enum CashCowAlertType: String, Codable, CaseIterable {
    case peakReached = "peak_reached"
    case nearPeak = "near_peak"
    case sellWindow = "sell_window"
    case holdLonger = "hold_longer"
    case riskEmerging = "risk_emerging"
}

struct TeamNewsImpact: Codable, Identifiable {
    let id = UUID()
    let team: String
    let newsType: TeamNewsType
    let impact: TeamImpactLevel
    let affectedPlayers: [String]
    let recommendation: TeamNewsRecommendation
    let details: String
}

enum TeamNewsType: String, Codable, CaseIterable {
    case coaching = "coaching"
    case injury = "injury"
    case suspension = "suspension"
    case trade = "trade"
    case roleChange = "role_change"
    case gameplan = "gameplan"
    case other = "other"
}

enum TeamImpactLevel: String, Codable, CaseIterable {
    case gameChanging = "game_changing"
    case significant = "significant"
    case moderate = "moderate"
    case minor = "minor"
    case negligible = "negligible"
}

enum TeamNewsRecommendation: String, Codable, CaseIterable {
    case buyAffected = "buy_affected"
    case sellAffected = "sell_affected"
    case monitor = "monitor"
    case noAction = "no_action"
    case waitAndSee = "wait_and_see"
}

// MARK: - Shared Analytics Types
struct ScoreRange: Codable {
    let min: Int
    let max: Int
    let expected: Double
    let confidence: ConfidenceLevel
}

// Fix for SellUrgency enum
extension SellUrgency {
    static var flexible: SellUrgency {
        return SellUrgency(rawValue: "flexible")!
    }
}

// Fix for InjuryRecommendation enum  
extension InjuryRecommendation {
    static var sellBeforeInjury: InjuryRecommendation {
        return InjuryRecommendation(rawValue: "sell_before_injury")!
    }
}
