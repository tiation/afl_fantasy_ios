import Foundation

// MARK: - Player Analytics
struct PlayerAnalytics: Codable, Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let position: Position
    let team: String
    let consistencyScore: ConsistencyMetrics
    let venuePerformance: [String: Double] // venueId -> avgScore
    let opponentPerformance: [String: Double] // teamId -> avgScore
    let injuryHistory: [InjuryRecord]
    let contractStatus: ContractInfo
    let seasonalTrends: SeasonalPerformance
    let ceilingFloorAnalysis: CeilingFloorStats
    let priceHistory: [PricePoint]
    let roleSecurity: RoleSecurityRating
    let formAnalysis: FormAnalysis
    let matchupSensitivity: MatchupSensitivity
    let weatherSensitivity: WeatherSensitivityProfile
    let lastUpdated: Date
}

// MARK: - Consistency Metrics
struct ConsistencyMetrics: Codable {
    let rating: ConsistencyGrade
    let numericScore: Double // 0.0 - 100.0
    let standardDeviation: Double
    let scoreRange: ScoreRange
    let floorCeiling: FloorCeiling
    let consistencyTrend: TrendDirection
    let volatilityIndex: Double // 0.0 - 1.0 (higher = more volatile)
    let reliabilityScore: Double // 0.0 - 100.0
    let weeklyConsistency: [WeeklyConsistencyData]
}

struct ScoreRange: Codable {
    let minimum: Int
    let maximum: Int
    let range: Int
    let percentile10: Double
    let percentile90: Double
    let interquartileRange: Double
}

struct FloorCeiling: Codable {
    let floor: Int // Bottom 10% average
    let ceiling: Int // Top 10% average
    let averageFloor: Double // Bottom 25% average
    let averageCeiling: Double // Top 25% average
    let floorReliability: Double // How often player hits floor
    let ceilingReliability: Double // How often player hits ceiling
}

struct WeeklyConsistencyData: Codable {
    let week: Int
    let score: Int
    let deviationFromAverage: Double
    let consistencyRating: Double
}

enum ConsistencyGrade: String, Codable, CaseIterable {
    case elite = "A+"
    case veryGood = "A"
    case good = "B+"
    case average = "B"
    case poor = "C"
    case veryPoor = "D"
    
    var description: String {
        switch self {
        case .elite: return "Elite (A+)"
        case .veryGood: return "Very Good (A)"
        case .good: return "Good (B+)"
        case .average: return "Average (B)"
        case .poor: return "Poor (C)"
        case .veryPoor: return "Very Poor (D)"
        }
    }
    
    var color: String {
        switch self {
        case .elite: return "green"
        case .veryGood: return "lightgreen"
        case .good: return "yellow"
        case .average: return "orange"
        case .poor: return "red"
        case .veryPoor: return "darkred"
        }
    }
}

// MARK: - Injury History & Analysis
struct InjuryRecord: Codable, Identifiable {
    let id = UUID()
    let injuryType: InjuryType
    let severity: InjurySeverity
    let dateOccurred: Date
    let dateReturned: Date?
    let gamesOut: Int
    let bodyPart: BodyPart
    let isRecurring: Bool
    let impactOnReturn: InjuryImpact
    let recoveryRating: RecoveryRating
    let ageAtInjury: Int
}

struct InjuryImpact: Codable {
    let returnGameScore: Int?
    let averageFirst3Games: Double?
    let performanceReduction: Double // percentage
    let gamesUntilFullRecovery: Int?
    let longTermEffects: Bool
}

enum InjuryType: String, Codable, CaseIterable {
    case hamstring = "hamstring"
    case knee = "knee"
    case ankle = "ankle"
    case shoulder = "shoulder"
    case concussion = "concussion"
    case calf = "calf"
    case groin = "groin"
    case back = "back"
    case quad = "quad"
    case foot = "foot"
    case other = "other"
    
    var riskLevel: InjuryRiskLevel {
        switch self {
        case .hamstring, .calf, .groin: return .high
        case .knee, .ankle, .concussion: return .veryHigh
        case .shoulder, .back: return .moderate
        case .quad, .foot, .other: return .low
        }
    }
}

enum InjurySeverity: String, Codable, CaseIterable {
    case minor = "minor" // 1-2 weeks
    case moderate = "moderate" // 3-6 weeks
    case major = "major" // 7-12 weeks
    case severe = "severe" // 13+ weeks
    
    var weekRange: String {
        switch self {
        case .minor: return "1-2 weeks"
        case .moderate: return "3-6 weeks"
        case .major: return "7-12 weeks"
        case .severe: return "13+ weeks"
        }
    }
}

enum BodyPart: String, Codable, CaseIterable {
    case upperBody = "upper_body"
    case lowerBody = "lower_body"
    case head = "head"
    case core = "core"
}

enum RecoveryRating: String, Codable, CaseIterable {
    case excellent = "excellent"
    case good = "good"
    case average = "average"
    case poor = "poor"
    case concerning = "concerning"
}

enum InjuryRiskLevel: String, Codable, CaseIterable {
    case veryLow = "very_low"
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case veryHigh = "very_high"
}

// MARK: - Contract Information
struct ContractInfo: Codable {
    let currentYear: Int
    let totalYears: Int
    let yearsRemaining: Int
    let isContractYear: Bool
    let isOutOfContract: Bool
    let salaryTier: SalaryTier
    let contractSecurity: ContractSecurity
    let motivationFactor: MotivationFactor
    let tradeRisk: TradeRisk
}

enum SalaryTier: String, Codable, CaseIterable {
    case elite = "elite" // Top 5%
    case premium = "premium" // Top 15%
    case good = "good" // Top 40%
    case average = "average" // Middle 40%
    case budget = "budget" // Bottom 20%
}

enum ContractSecurity: String, Codable, CaseIterable {
    case secure = "secure"
    case mostlySecure = "mostly_secure"
    case uncertain = "uncertain"
    case risk = "at_risk"
    case high_risk = "high_risk"
}

enum MotivationFactor: String, Codable, CaseIterable {
    case veryHigh = "very_high" // Contract year, proving themselves
    case high = "high"
    case normal = "normal"
    case low = "low" // Secured long-term, complacent
    case veryLow = "very_low"
}

enum TradeRisk: String, Codable, CaseIterable {
    case none = "none"
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case veryHigh = "very_high"
}

// MARK: - Seasonal Performance Analysis
struct SeasonalPerformance: Codable {
    let currentSeason: SeasonStats
    let previousSeasons: [SeasonStats]
    let careerTrajectory: TrendDirection
    let peakSeason: SeasonStats?
    let seasonalPatterns: SeasonalPatterns
    let ageAnalysis: AgeAnalysis
}

struct SeasonStats: Codable {
    let year: String
    let games: Int
    let averageScore: Double
    let totalScore: Int
    let ranking: Int?
    let priceRange: PriceRange
    let injuryGames: Int
    let seasonRating: SeasonRating
}

struct SeasonalPatterns: Codable {
    let earlySeasonAverage: Double // Rounds 1-6
    let midSeasonAverage: Double // Rounds 7-18
    let lateSeasonAverage: Double // Rounds 19-24
    let finalsTrend: TrendDirection
    let seasonLongConsistency: Double
    let fadePattern: FadePattern
}

struct AgeAnalysis: Codable {
    let currentAge: Int
    let peakAgeRange: AgeRange
    let isInPeakYears: Bool
    let declineRisk: DeclineRisk
    let experienceFactor: ExperienceFactor
    let longevityProjection: LongevityProjection
}

struct AgeRange: Codable {
    let min: Int
    let max: Int
    let optimal: Int
}

enum SeasonRating: String, Codable, CaseIterable {
    case outstanding = "outstanding"
    case excellent = "excellent"
    case good = "good"
    case average = "average"
    case poor = "poor"
    case terrible = "terrible"
}

enum FadePattern: String, Codable, CaseIterable {
    case strongFinisher = "strong_finisher"
    case consistent = "consistent"
    case minorFade = "minor_fade"
    case significantFade = "significant_fade"
    case severeFade = "severe_fade"
}

enum DeclineRisk: String, Codable, CaseIterable {
    case minimal = "minimal"
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case imminent = "imminent"
}

enum ExperienceFactor: String, Codable, CaseIterable {
    case rookie = "rookie"
    case developing = "developing"
    case experienced = "experienced"
    case veteran = "veteran"
    case elder = "elder"
}

enum LongevityProjection: String, Codable, CaseIterable {
    case longTerm = "long_term" // 5+ years
    case medium = "medium" // 3-4 years
    case short = "short" // 1-2 years
    case immediate = "immediate" // This season only
}

// MARK: - Ceiling/Floor Statistics
struct CeilingFloorStats: Codable {
    let ceiling: CeilingAnalysis
    let floor: FloorAnalysis
    let volatilityMetrics: VolatilityMetrics
    let rangePrediction: RangePrediction
}

struct CeilingAnalysis: Codable {
    let score: Int
    let frequency: Double // How often reached
    let conditions: [CeilingCondition]
    let reliability: Double
    let trend: TrendDirection
}

struct FloorAnalysis: Codable {
    let score: Int
    let frequency: Double // How often hit
    let riskFactors: [RiskFactor]
    let avoidanceRate: Double
    let trend: TrendDirection
}

struct CeilingCondition: Codable {
    let condition: String
    let impactMultiplier: Double
    let frequency: Double
}

struct RiskFactor: Codable {
    let factor: String
    let impactSeverity: Double
    let likelihood: Double
}

struct VolatilityMetrics: Codable {
    let volatilityIndex: Double // 0.0 - 1.0
    let scoreSwingRange: Int
    let weekToWeekStability: Double
    let predictabilityScore: Double
}

struct RangePrediction: Codable {
    let expectedFloor: Int
    let expectedCeiling: Int
    let mostLikelyRange: IntRange
    let confidence: ConfidenceLevel
}

struct IntRange: Codable {
    let min: Int
    let max: Int
}

// MARK: - Price History & Analytics
struct PricePoint: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let price: Int
    let priceChange: Int
    let round: Int
    let breakeven: Int
    let ownership: Double?
    let fantasyScore: Int?
    let priceChangeReason: PriceChangeReason
}

enum PriceChangeReason: String, Codable, CaseIterable {
    case performance = "performance"
    case injury = "injury"
    case suspension = "suspension"
    case roleChange = "role_change"
    case formSlump = "form_slump"
    case market = "market"
    case rookie = "rookie_pricing"
}

struct PriceRange: Codable {
    let min: Int
    let max: Int
    let season_start: Int
    let season_end: Int?
    let peak: Int
    let valley: Int
}

// MARK: - Role Security Analysis
struct RoleSecurityRating: Codable {
    let overall: RoleSecurity
    let position: PositionSecurity
    let teamStatus: TeamStatus
    let competitionLevel: CompetitionLevel
    let recentTrends: [RoleChange]
    let threats: [RoleThreat]
    let opportunities: [RoleOpportunity]
}

struct PositionSecurity: Codable {
    let primary: RoleSecurity
    let secondary: RoleSecurity?
    let versatility: VersatilityRating
}

struct RoleChange: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let oldRole: String
    let newRole: String
    let impact: RoleImpact
    let reason: String
}

struct RoleThreat: Codable {
    let source: String // Player name or situation
    let severity: ThreatSeverity
    let likelihood: Double
    let description: String
}

struct RoleOpportunity: Codable {
    let situation: String
    let potentialGain: Double
    let likelihood: Double
    let description: String
}

enum RoleSecurity: String, Codable, CaseIterable {
    case locked = "locked"
    case secure = "secure"
    case mostlySecure = "mostly_secure"
    case uncertain = "uncertain"
    case risk = "at_risk"
    case insecure = "insecure"
}

enum TeamStatus: String, Codable, CaseIterable {
    case firstChoice = "first_choice"
    case regularStarter = "regular_starter"
    case rotational = "rotational"
    case fringe = "fringe"
    case development = "development"
}

enum CompetitionLevel: String, Codable, CaseIterable {
    case none = "none"
    case minimal = "minimal"
    case moderate = "moderate"
    case high = "high"
    case extreme = "extreme"
}

enum VersatilityRating: String, Codable, CaseIterable {
    case onePosition = "one_position"
    case twoPositions = "two_positions"
    case multiPosition = "multi_position"
    case utility = "utility"
}

enum RoleImpact: String, Codable, CaseIterable {
    case majorPositive = "major_positive"
    case positive = "positive"
    case neutral = "neutral"
    case negative = "negative"
    case majorNegative = "major_negative"
}

enum ThreatSeverity: String, Codable, CaseIterable {
    case minimal = "minimal"
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case critical = "critical"
}

// MARK: - Form Analysis
struct FormAnalysis: Codable {
    let currentForm: FormRating
    let recentScores: [Int] // Last 5 games
    let formTrend: TrendDirection
    let formConsistency: Double
    let breakoutPotential: BreakoutPotential
    let slumpRisk: SlumpRisk
    let formPrediction: FormPrediction
}

struct FormPrediction: Codable {
    let nextGamePrediction: Double
    let shortTermTrend: TrendDirection // Next 3 games
    let mediumTermTrend: TrendDirection // Next 6 games
    let confidence: ConfidenceLevel
}

enum FormRating: String, Codable, CaseIterable {
    case hot = "hot"
    case good = "good"
    case average = "average"
    case poor = "poor"
    case terrible = "terrible"
}

enum BreakoutPotential: String, Codable, CaseIterable {
    case high = "high"
    case moderate = "moderate"
    case low = "low"
    case minimal = "minimal"
}

enum SlumpRisk: String, Codable, CaseIterable {
    case minimal = "minimal"
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case imminent = "imminent"
}

// MARK: - Matchup Sensitivity
struct MatchupSensitivity: Codable {
    let overall: MatchupSensitivity_Level
    let positionalImpact: [Position: MatchupImpact]
    let opponentStrengths: [OpponentStrength]
    let weaknesses: [OpponentWeakness]
    let matchupHistory: [MatchupRecord]
}

struct MatchupImpact: Codable {
    let impact: Double // -20.0 to +20.0
    let confidence: ConfidenceLevel
    let sampleSize: Int
}

struct OpponentStrength: Codable {
    let strength: String
    let impact: Double
    let examples: [String]
}

struct OpponentWeakness: Codable {
    let weakness: String
    let exploitation: Double
    let frequency: Double
}

struct MatchupRecord: Codable, Identifiable {
    let id = UUID()
    let opponent: String
    let date: Date
    let score: Int
    let matchupRating: MatchupRating
}

enum MatchupSensitivity_Level: String, Codable, CaseIterable {
    case veryHigh = "very_high"
    case high = "high"
    case moderate = "moderate"
    case low = "low"
    case minimal = "minimal"
}

enum MatchupRating: String, Codable, CaseIterable {
    case veryFavorable = "very_favorable"
    case favorable = "favorable"
    case neutral = "neutral"
    case difficult = "difficult"
    case veryDifficult = "very_difficult"
}

// MARK: - Weather Sensitivity Profile
struct WeatherSensitivityProfile: Codable {
    let overallSensitivity: WeatherSensitivity
    let windSensitivity: WeatherImpactRating
    let rainSensitivity: WeatherImpactRating
    let temperatureSensitivity: WeatherImpactRating
    let humiditySensitivity: WeatherImpactRating
    let roofPreference: RoofPreference
    let surfacePreference: SurfacePreference
}

struct WeatherImpactRating: Codable {
    let rating: ImpactSeverity
    let averageImpact: Double
    let sampleSize: Int
    let confidence: ConfidenceLevel
}

enum ImpactSeverity: String, Codable, CaseIterable {
    case minimal = "minimal"
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case severe = "severe"
}

enum RoofPreference: String, Codable, CaseIterable {
    case strongOpen = "strong_open"
    case preferOpen = "prefer_open"
    case neutral = "neutral"
    case preferClosed = "prefer_closed"
    case strongClosed = "strong_closed"
}

enum SurfacePreference: String, Codable, CaseIterable {
    case strongNatural = "strong_natural"
    case preferNatural = "prefer_natural"
    case neutral = "neutral"
    case preferArtificial = "prefer_artificial"
    case strongArtificial = "strong_artificial"
}
