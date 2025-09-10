import Foundation

// MARK: - Matchup Analytics
struct MatchupAnalytics: Codable, Identifiable {
    let id = UUID()
    let teamId: String
    let teamName: String
    let teamCode: String
    let defensiveValue: [String: DVPRating] // position -> DVP
    let recentForm: FormTrend
    let homeAwayBias: HomeAwayStats
    let travelImpact: TravelImpactRating
    let coachingStyle: CoachingStyle
    let gameStyleMetrics: GameStyleMetrics
    let strengthsWeaknesses: TeamStrengthsWeaknesses
    let playerMatchups: [PlayerMatchupData]
    let historicalPerformance: [SeasonMatchupStats]
    let currentSeasonStats: CurrentSeasonMatchupStats
    let lastUpdated: Date
}

// MARK: - Defensive Value Points (DVP)
struct DVPRating: Codable {
    let position: String
    let rating: Double // 1.0 - 5.0 (1 = hardest, 5 = easiest)
    let pointsAllowedPerGame: Double
    let rank: Int // 1-18 ranking
    let trend: TrendDirection
    let sampleSize: Int
    let confidence: ConfidenceLevel
    let recentGames: [DVPGameData]
    let seasonLong: DVPSeasonStats
    let homeAwayDifference: DVPVariance
}

struct DVPGameData: Codable {
    let round: Int
    let opponent: String
    let pointsAllowed: Double
    let position: String
    let matchupDifficulty: MatchupDifficulty
}

struct DVPSeasonStats: Codable {
    let totalPointsAllowed: Double
    let gamesPlayed: Int
    let averageAllowed: Double
    let bestGame: Double
    let worstGame: Double
    let consistency: Double
}

struct DVPVariance: Codable {
    let homeAverage: Double
    let awayAverage: Double
    let difference: Double
    let homeRank: Int
    let awayRank: Int
}

enum MatchupDifficulty: String, Codable, CaseIterable {
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
    
    var color: String {
        switch self {
        case .veryEasy: return "green"
        case .easy: return "lightgreen"
        case .moderate: return "yellow"
        case .hard: return "orange"
        case .veryHard: return "red"
        }
    }
}

// MARK: - Team Form Analysis
struct FormTrend: Codable {
    let currentForm: TeamForm
    let recentResults: [GameResult]
    let formRating: Double // 0.0 - 10.0
    let trend: TrendDirection
    let momentum: MomentumLevel
    let keyPerformanceIndicators: [TeamKPI]
    let formPrediction: FormProjection
}

struct GameResult: Codable, Identifiable {
    let id = UUID()
    let round: Int
    let opponent: String
    let result: MatchResult
    let margin: Int
    let fantasyPointsAllowed: Double
    let venue: String
    let date: Date
}

struct TeamKPI: Codable {
    let metric: String
    let value: Double
    let trend: TrendDirection
    let rank: Int
    let impact: KPIImpact
}

struct FormProjection: Codable {
    let nextGamePrediction: TeamPerformancePrediction
    let short_term: TrendDirection // next 3 games
    let medium_term: TrendDirection // next 6 games
    let confidence: ConfidenceLevel
}

struct TeamPerformancePrediction: Codable {
    let expectedPointsAllowed: Double
    let difficultySetting: MatchupDifficulty
    let keyFactors: [String]
    let upside: Double
    let downside: Double
}

enum TeamForm: String, Codable, CaseIterable {
    case excellent = "excellent"
    case good = "good"
    case average = "average"
    case poor = "poor"
    case terrible = "terrible"
}

enum MatchResult: String, Codable, CaseIterable {
    case win = "win"
    case loss = "loss"
    case draw = "draw"
}

enum MomentumLevel: String, Codable, CaseIterable {
    case veryPositive = "very_positive"
    case positive = "positive"
    case neutral = "neutral"
    case negative = "negative"
    case veryNegative = "very_negative"
}

enum KPIImpact: String, Codable, CaseIterable {
    case high = "high"
    case medium = "medium"
    case low = "low"
}

// MARK: - Home/Away Analysis
struct HomeAwayStats: Codable {
    let homeStats: VenueStats
    let awayStats: VenueStats
    let bias: VenueBias
    let travelRecord: TravelRecord
    let homeAdvantageRating: Double // 0.0 - 10.0
}

struct VenueStats: Codable {
    let gamesPlayed: Int
    let winRate: Double
    let averagePointsAllowed: Double
    let averageMargin: Double
    let bestPerformance: Double
    let worstPerformance: Double
    let consistency: Double
}

struct TravelRecord: Codable {
    let interstate: TravelStats
    local: TravelStats
    longDistance: TravelStats // 3+ hours
    shortDistance: TravelStats // <2 hours
}

struct TravelStats: Codable {
    let games: Int
    let averagePointsAllowed: Double
    let performance: TravelPerformance
    let fatigueFactor: Double
}

enum VenueBias: String, Codable, CaseIterable {
    case strongHome = "strong_home"
    case home = "home"
    case neutral = "neutral"
    case away = "away"
    case strongAway = "strong_away"
}

enum TravelPerformance: String, Codable, CaseIterable {
    case excellent = "excellent"
    case good = "good"
    case average = "average"
    case poor = "poor"
    case terrible = "terrible"
}

// MARK: - Travel Impact Analysis
struct TravelImpactRating: Codable {
    let overallImpact: TravelImpact
    let distanceImpact: [TravelDistance: TravelEffect]
    let recoveryTime: Int // days needed
    let travelFatigueFactor: Double // 0.0 - 1.0
    let adaptabilityRating: AdaptabilityRating
    let historicalTravelData: [TravelGame]
}

struct TravelEffect: Codable {
    let performanceChange: Double // percentage change
    let consistencyImpact: Double
    let sampleSize: Int
    let confidence: ConfidenceLevel
}

struct TravelGame: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let distance: Double // km
    let timeZoneChange: Int
    let performance: Double
    let recovery: RecoveryMetrics
}

struct RecoveryMetrics: Codable {
    let daysToRecover: Int
    let nextGameImpact: Double
    let recoveryRating: RecoveryRating
}

enum TravelImpact: String, Codable, CaseIterable {
    case minimal = "minimal"
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case severe = "severe"
}

enum TravelDistance: String, Codable, CaseIterable {
    case local = "local" // <200km
    case regional = "regional" // 200-800km
    case interstate = "interstate" // 800-2000km
    case longHaul = "long_haul" // >2000km
}

enum AdaptabilityRating: String, Codable, CaseIterable {
    case excellent = "excellent"
    case good = "good"
    case average = "average"
    case poor = "poor"
    case terrible = "terrible"
}

// MARK: - Coaching & Game Style
struct CoachingStyle: Codable {
    let coach: String
    let philosophy: CoachingPhilosophy
    let tacticalApproach: TacticalApproach
    let adaptability: CoachingAdaptability
    let playerDevelopment: DevelopmentRating
    let gameManagement: GameManagementRating
    let fantasyImpact: CoachingFantasyImpact
}

struct GameStyleMetrics: Codable {
    let pace: GamePace
    let style: PlayingStyle
    let rotationPolicy: RotationPolicy
    let injuryManagement: InjuryManagementStyle
    let youthPolicy: YouthPolicy
    let fantasyFriendliness: FantasyFriendliness
}

enum CoachingPhilosophy: String, Codable, CaseIterable {
    case attacking = "attacking"
    case defensive = "defensive"
    case balanced = "balanced"
    case possession = "possession"
    case counterAttack = "counter_attack"
}

enum TacticalApproach: String, Codable, CaseIterable {
    case aggressive = "aggressive"
    case conservative = "conservative"
    case adaptable = "adaptable"
    case systematic = "systematic"
    case innovative = "innovative"
}

enum CoachingAdaptability: String, Codable, CaseIterable {
    case veryHigh = "very_high"
    case high = "high"
    case moderate = "moderate"
    case low = "low"
    case rigid = "rigid"
}

enum DevelopmentRating: String, Codable, CaseIterable {
    case excellent = "excellent"
    case good = "good"
    case average = "average"
    case poor = "poor"
    case concerning = "concerning"
}

enum GameManagementRating: String, Codable, CaseIterable {
    case excellent = "excellent"
    case good = "good"
    case average = "average"
    case questionable = "questionable"
    case poor = "poor"
}

struct CoachingFantasyImpact: Codable {
    let positiveFactors: [String]
    let negativeFactors: [String]
    let overallRating: FantasyCoachRating
    let predictability: PredictabilityRating
}

enum FantasyCoachRating: String, Codable, CaseIterable {
    case veryPositive = "very_positive"
    case positive = "positive"
    case neutral = "neutral"
    case negative = "negative"
    case veryNegative = "very_negative"
}

enum PredictabilityRating: String, Codable, CaseIterable {
    case veryPredictable = "very_predictable"
    case predictable = "predictable"
    case moderate = "moderate"
    case unpredictable = "unpredictable"
    case veryUnpredictable = "very_unpredictable"
}

enum GamePace: String, Codable, CaseIterable {
    case veryFast = "very_fast"
    case fast = "fast"
    case moderate = "moderate"
    case slow = "slow"
    case verySlow = "very_slow"
}

enum PlayingStyle: String, Codable, CaseIterable {
    case highScoring = "high_scoring"
    case balanced = "balanced"
    case defensive = "defensive"
    case chaotic = "chaotic"
    case structured = "structured"
}

enum RotationPolicy: String, Codable, CaseIterable {
    case minimal = "minimal"
    case selective = "selective"
    case moderate = "moderate"
    case heavy = "heavy"
    case excessive = "excessive"
}

enum InjuryManagementStyle: String, Codable, CaseIterable {
    case conservative = "conservative"
    case moderate = "moderate"
    case aggressive = "aggressive"
    case reckless = "reckless"
}

enum YouthPolicy: String, Codable, CaseIterable {
    case youthFocused = "youth_focused"
    case developmental = "developmental"
    case balanced = "balanced"
    case experienceFocused = "experience_focused"
    case veteranReliant = "veteran_reliant"
}

enum FantasyFriendliness: String, Codable, CaseIterable {
    case veryHigh = "very_high"
    case high = "high"
    case moderate = "moderate"
    case low = "low"
    case veryLow = "very_low"
}

// MARK: - Team Strengths & Weaknesses
struct TeamStrengthsWeaknesses: Codable {
    let strengths: [TeamStrength]
    let weaknesses: [TeamWeakness]
    let exploitableWeaknesses: [ExploitableWeakness]
    let consistencyFactors: [ConsistencyFactor]
    let volatilityRisks: [VolatilityRisk]
}

struct TeamStrength: Codable {
    let area: String
    let rating: StrengthRating
    let impact: FantasyImpact
    let consistency: Double
    let description: String
}

struct TeamWeakness: Codable {
    let area: String
    let severity: WeaknessSeverity
    let impact: FantasyImpact
    let exploitability: ExploitabilityLevel
    let description: String
}

struct ExploitableWeakness: Codable {
    let weakness: String
    let exploitationRate: Double
    let averageImpact: Double
    let positions: [String] // affected positions
    let description: String
}

struct ConsistencyFactor: Codable {
    let factor: String
    let impact: Double
    let frequency: Double
    let description: String
}

struct VolatilityRisk: Codable {
    let risk: String
    let likelihood: Double
    let severity: Double
    let positions: [String]
    let description: String
}

enum StrengthRating: String, Codable, CaseIterable {
    case elite = "elite"
    case veryStrong = "very_strong"
    case strong = "strong"
    case solid = "solid"
    case adequate = "adequate"
}

enum WeaknessSeverity: String, Codable, CaseIterable {
    case critical = "critical"
    case major = "major"
    case moderate = "moderate"
    case minor = "minor"
    case negligible = "negligible"
}

enum ExploitabilityLevel: String, Codable, CaseIterable {
    case veryHigh = "very_high"
    case high = "high"
    case moderate = "moderate"
    case low = "low"
    case minimal = "minimal"
}

enum FantasyImpact: String, Codable, CaseIterable {
    case veryPositive = "very_positive"
    case positive = "positive"
    case neutral = "neutral"
    case negative = "negative"
    case veryNegative = "very_negative"
}

// MARK: - Player-Specific Matchup Data
struct PlayerMatchupData: Codable, Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let position: String
    let matchupRating: MatchupRating
    let historical: HistoricalMatchupStats
    let projected: ProjectedMatchupImpact
    let keyFactors: [MatchupFactor]
}

struct HistoricalMatchupStats: Codable {
    let games: Int
    let averageScore: Double
    let bestScore: Int
    let worstScore: Int
    let consistency: Double
    let trend: TrendDirection
    let recentForm: [Int] // last 3 games vs this opponent
}

struct ProjectedMatchupImpact: Codable {
    let expectedScore: Double
    let range: ScoreRange
    let confidence: ConfidenceLevel
    let upside: Double
    let downside: Double
}

struct MatchupFactor: Codable {
    let factor: String
    let impact: Double // -10.0 to +10.0
    let weight: Double // 0.0 to 1.0
    let description: String
}

// MARK: - Historical & Current Season Stats
struct SeasonMatchupStats: Codable {
    let season: String
    let games: Int
    let averagePointsAllowed: [String: Double] // position -> avg
    let ranking: [String: Int] // position -> rank
    let consistency: [String: Double] // position -> consistency
    let bestGames: [String: Double] // position -> best allowed
    let worstGames: [String: Double] // position -> worst allowed
}

struct CurrentSeasonMatchupStats: Codable {
    let season: String
    let gamesPlayed: Int
    let currentRankings: [String: Int] // position -> current rank
    let formTrend: [String: TrendDirection] // position -> trend
    let recentPerformance: [RecentMatchupGame]
    let projectedEndSeason: [String: DVPProjection]
}

struct RecentMatchupGame: Codable {
    let round: Int
    let opponent: String
    let pointsAllowed: [String: Double] // position -> points
    let standoutPerformers: [String] // player IDs who excelled
    let disappointments: [String] // player IDs who underperformed
}

struct DVPProjection: Codable {
    let projectedRank: Int
    let projectedAverage: Double
    let confidence: ConfidenceLevel
    let keyFactors: [String]
}
