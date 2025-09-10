import Foundation

// MARK: - Live Match State
public struct LiveMatchState: Codable, Identifiable, Hashable {
    public let id: String
    public let roundNumber: Int
    public let homeTeam: String
    public let awayTeam: String
    public let venue: String
    public let status: MatchStatus
    public let clock: GameClock?
    public let weather: String?
    public let lastUpdated: Date
    public let homeScore: TeamScore
    public let awayScore: TeamScore
    
    public init(
        id: String,
        roundNumber: Int,
        homeTeam: String,
        awayTeam: String,
        venue: String,
        status: MatchStatus,
        clock: GameClock? = nil,
        weather: String? = nil,
        lastUpdated: Date = Date(),
        homeScore: TeamScore,
        awayScore: TeamScore
    ) {
        self.id = id
        self.roundNumber = roundNumber
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.venue = venue
        self.status = status
        self.clock = clock
        self.weather = weather
        self.lastUpdated = lastUpdated
        self.homeScore = homeScore
        self.awayScore = awayScore
    }
}

public enum MatchStatus: String, Codable, CaseIterable {
    case scheduled = "SCHEDULED"
    case warmup = "WARMUP"
    case live = "LIVE"
    case quarterTime = "QUARTER_TIME"
    case halfTime = "HALF_TIME"
    case threeQuarterTime = "THREE_QUARTER_TIME"
    case fullTime = "FULL_TIME"
    case postponed = "POSTPONED"
    case cancelled = "CANCELLED"
    
    public var isActive: Bool {
        switch self {
        case .live, .quarterTime, .halfTime, .threeQuarterTime:
            return true
        default:
            return false
        }
    }
    
    public var displayName: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .warmup: return "Warm Up"
        case .live: return "Live"
        case .quarterTime: return "Quarter Time"
        case .halfTime: return "Half Time"
        case .threeQuarterTime: return "3/4 Time"
        case .fullTime: return "Full Time"
        case .postponed: return "Postponed"
        case .cancelled: return "Cancelled"
        }
    }
}

public struct GameClock: Codable, Hashable {
    public let quarter: Int
    public let timeRemaining: TimeInterval // seconds
    public let timeElapsed: TimeInterval // seconds in quarter
    public let isPaused: Bool
    public let lastTick: Date
    
    public init(
        quarter: Int,
        timeRemaining: TimeInterval,
        timeElapsed: TimeInterval,
        isPaused: Bool,
        lastTick: Date = Date()
    ) {
        self.quarter = quarter
        self.timeRemaining = timeRemaining
        self.timeElapsed = timeElapsed
        self.isPaused = isPaused
        self.lastTick = lastTick
    }
    
    public var formattedTime: String {
        let minutes = Int(timeElapsed) / 60
        let seconds = Int(timeElapsed) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    public var progressPercentage: Double {
        let quarterLength: TimeInterval = 20 * 60 // 20 minutes
        return min(timeElapsed / quarterLength, 1.0)
    }
}

public struct TeamScore: Codable, Hashable {
    public let goals: Int
    public let behinds: Int
    public let totalPoints: Int
    public let quarterBreakdown: [Int] // Points per quarter
    
    public init(goals: Int, behinds: Int, quarterBreakdown: [Int] = []) {
        self.goals = goals
        self.behinds = behinds
        self.totalPoints = (goals * 6) + behinds
        self.quarterBreakdown = quarterBreakdown
    }
}

// MARK: - Player Live Performance
public struct PlayerStatDelta: Codable, Identifiable, Hashable {
    public let id: String
    public let playerId: String
    public let playerName: String
    public let team: String
    public let position: Position
    public let salary: Int
    
    // Current game stats
    public let currentStats: LivePlayerStats
    public let projectedStats: LivePlayerStats
    public let fantasyScore: Double
    public let projectedFantasyScore: Double
    
    // Comparisons and trends
    public let averageComparison: Double // vs season average
    public let lastRoundComparison: Double // vs last round
    public let breakEvenComparison: Double // vs break-even requirement
    
    // Live insights
    public let momentum: PlayerMomentum
    public let riskFactors: [RiskFactor]
    public let opportunities: [Opportunity]
    
    public init(
        id: String = UUID().uuidString,
        playerId: String,
        playerName: String,
        team: String,
        position: Position,
        salary: Int,
        currentStats: LivePlayerStats,
        projectedStats: LivePlayerStats,
        fantasyScore: Double,
        projectedFantasyScore: Double,
        averageComparison: Double,
        lastRoundComparison: Double,
        breakEvenComparison: Double,
        momentum: PlayerMomentum,
        riskFactors: [RiskFactor] = [],
        opportunities: [Opportunity] = []
    ) {
        self.id = id
        self.playerId = playerId
        self.playerName = playerName
        self.team = team
        self.position = position
        self.salary = salary
        self.currentStats = currentStats
        self.projectedStats = projectedStats
        self.fantasyScore = fantasyScore
        self.projectedFantasyScore = projectedFantasyScore
        self.averageComparison = averageComparison
        self.lastRoundComparison = lastRoundComparison
        self.breakEvenComparison = breakEvenComparison
        self.momentum = momentum
        self.riskFactors = riskFactors
        self.opportunities = opportunities
    }
}

public struct LivePlayerStats: Codable, Hashable {
    public let disposals: Int
    public let kicks: Int
    public let handballs: Int
    public let marks: Int
    public let tackles: Int
    public let hitouts: Int
    public let goals: Int
    public let behinds: Int
    public let frees: Int
    public let freesAgainst: Int
    public let clangers: Int
    public let timeOnGround: Double // percentage
    
    public init(
        disposals: Int = 0,
        kicks: Int = 0,
        handballs: Int = 0,
        marks: Int = 0,
        tackles: Int = 0,
        hitouts: Int = 0,
        goals: Int = 0,
        behinds: Int = 0,
        frees: Int = 0,
        freesAgainst: Int = 0,
        clangers: Int = 0,
        timeOnGround: Double = 0.0
    ) {
        self.disposals = disposals
        self.kicks = kicks
        self.handballs = handballs
        self.marks = marks
        self.tackles = tackles
        self.hitouts = hitouts
        self.goals = goals
        self.behinds = behinds
        self.frees = frees
        self.freesAgainst = freesAgainst
        self.clangers = clangers
        self.timeOnGround = timeOnGround
    }
}

public enum PlayerMomentum: String, Codable, CaseIterable {
    case surging = "SURGING"
    case building = "BUILDING"
    case steady = "STEADY"
    case slowing = "SLOWING"
    case stalling = "STALLING"
    
    public var color: String {
        switch self {
        case .surging: return "green"
        case .building: return "lightGreen"
        case .steady: return "blue"
        case .slowing: return "orange"
        case .stalling: return "red"
        }
    }
    
    public var description: String {
        switch self {
        case .surging: return "Momentum surging - exceeding projections"
        case .building: return "Building momentum - trending upward"
        case .steady: return "Steady performance - on track"
        case .slowing: return "Slowing down - below expectations"
        case .stalling: return "Performance stalled - concerning"
        }
    }
}

public struct RiskFactor: Codable, Identifiable, Hashable {
    public let id: String
    public let type: RiskType
    public let severity: Severity
    public let description: String
    public let impact: String
    
    public init(
        id: String = UUID().uuidString,
        type: RiskType,
        severity: Severity,
        description: String,
        impact: String
    ) {
        self.id = id
        self.type = type
        self.severity = severity
        self.description = description
        self.impact = impact
    }
}

public enum RiskType: String, Codable, CaseIterable {
    case injury = "INJURY"
    case subbed = "SUBBED"
    case tagged = "TAGGED"
    case weatherImpact = "WEATHER_IMPACT"
    case matchFlow = "MATCH_FLOW"
    case rotationReduced = "ROTATION_REDUCED"
}

public enum Severity: String, Codable, CaseIterable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    case critical = "CRITICAL"
}

public struct Opportunity: Codable, Identifiable, Hashable {
    public let id: String
    public let type: OpportunityType
    public let confidence: Double
    public let description: String
    public let potentialUpside: String
    
    public init(
        id: String = UUID().uuidString,
        type: OpportunityType,
        confidence: Double,
        description: String,
        potentialUpside: String
    ) {
        self.id = id
        self.type = type
        self.confidence = confidence
        self.description = description
        self.potentialUpside = potentialUpside
    }
}

public enum OpportunityType: String, Codable, CaseIterable {
    case positionalChange = "POSITIONAL_CHANGE"
    case increasedRole = "INCREASED_ROLE"
    case favorableMatchup = "FAVORABLE_MATCHUP"
    case weatherBoost = "WEATHER_BOOST"
    case opponentWeakness = "OPPONENT_WEAKNESS"
    case captainCandidate = "CAPTAIN_CANDIDATE"
}

// MARK: - Team Performance
public struct LiveTeamPerformance: Codable, Identifiable, Hashable {
    public let id: String
    public let team: Team
    public let fantasyTotal: Double
    public let projectedTotal: Double
    public let averageComparison: Double
    public let topPerformers: [PlayerStatDelta]
    public let concerningPerformers: [PlayerStatDelta]
    public let captainOptions: [CaptainCandidate]
    public let tradeTargets: [TradeTarget]
    
    public init(
        id: String = UUID().uuidString,
        team: Team,
        fantasyTotal: Double,
        projectedTotal: Double,
        averageComparison: Double,
        topPerformers: [PlayerStatDelta] = [],
        concerningPerformers: [PlayerStatDelta] = [],
        captainOptions: [CaptainCandidate] = [],
        tradeTargets: [TradeTarget] = []
    ) {
        self.id = id
        self.team = team
        self.fantasyTotal = fantasyTotal
        self.projectedTotal = projectedTotal
        self.averageComparison = averageComparison
        self.topPerformers = topPerformers
        self.concerningPerformers = concerningPerformers
        self.captainOptions = captainOptions
        self.tradeTargets = tradeTargets
    }
}

public struct CaptainCandidate: Codable, Identifiable, Hashable {
    public let id: String
    public let playerId: String
    public let playerName: String
    public let currentScore: Double
    public let projectedScore: Double
    public let captainProbability: Double
    public let riskLevel: Severity
    public let reasoning: String
    
    public init(
        id: String = UUID().uuidString,
        playerId: String,
        playerName: String,
        currentScore: Double,
        projectedScore: Double,
        captainProbability: Double,
        riskLevel: Severity,
        reasoning: String
    ) {
        self.id = id
        self.playerId = playerId
        self.playerName = playerName
        self.currentScore = currentScore
        self.projectedScore = projectedScore
        self.captainProbability = captainProbability
        self.riskLevel = riskLevel
        self.reasoning = reasoning
    }
}

public struct TradeTarget: Codable, Identifiable, Hashable {
    public let id: String
    public let playerId: String
    public let playerName: String
    public let team: Team
    public let position: Position
    public let currentPrice: Int
    public let projectedPriceChange: Int
    public let confidence: Double
    public let reasoning: String
    public let timeframe: TradeTimeframe
    
    public init(
        id: String = UUID().uuidString,
        playerId: String,
        playerName: String,
        team: Team,
        position: Position,
        currentPrice: Int,
        projectedPriceChange: Int,
        confidence: Double,
        reasoning: String,
        timeframe: TradeTimeframe
    ) {
        self.id = id
        self.playerId = playerId
        self.playerName = playerName
        self.team = team
        self.position = position
        self.currentPrice = currentPrice
        self.projectedPriceChange = projectedPriceChange
        self.confidence = confidence
        self.reasoning = reasoning
        self.timeframe = timeframe
    }
}

public enum TradeTimeframe: String, Codable, CaseIterable {
    case immediate = "IMMEDIATE"
    case thisWeek = "THIS_WEEK"
    case nextWeek = "NEXT_WEEK"
    case longTerm = "LONG_TERM"
    
    public var displayName: String {
        switch self {
        case .immediate: return "Now"
        case .thisWeek: return "This Week"
        case .nextWeek: return "Next Week"
        case .longTerm: return "Long Term"
        }
    }
}

// MARK: - Live Performance Summary
public struct LivePerformanceSummary: Codable {
    public let totalFantasyScore: Double
    public let projectedTotalScore: Double
    public let averageComparison: Double
    public let rankProjection: RankProjection
    public let topMovers: [PlayerStatDelta]
    public let captainPerformance: CaptainPerformance?
    public let alerts: [PerformanceAlert]
    public let lastUpdated: Date
    
    public init(
        totalFantasyScore: Double,
        projectedTotalScore: Double,
        averageComparison: Double,
        rankProjection: RankProjection,
        topMovers: [PlayerStatDelta] = [],
        captainPerformance: CaptainPerformance? = nil,
        alerts: [PerformanceAlert] = [],
        lastUpdated: Date = Date()
    ) {
        self.totalFantasyScore = totalFantasyScore
        self.projectedTotalScore = projectedTotalScore
        self.averageComparison = averageComparison
        self.rankProjection = rankProjection
        self.topMovers = topMovers
        self.captainPerformance = captainPerformance
        self.alerts = alerts
        self.lastUpdated = lastUpdated
    }
}

public struct RankProjection: Codable, Hashable {
    public let currentRank: Int?
    public let projectedRank: Int
    public let rankChange: Int
    public let confidence: Double
    public let percentile: Double
    
    public init(
        currentRank: Int? = nil,
        projectedRank: Int,
        rankChange: Int,
        confidence: Double,
        percentile: Double
    ) {
        self.currentRank = currentRank
        self.projectedRank = projectedRank
        self.rankChange = rankChange
        self.confidence = confidence
        self.percentile = percentile
    }
}

public struct CaptainPerformance: Codable, Hashable {
    public let playerId: String
    public let playerName: String
    public let currentScore: Double
    public let projectedScore: Double
    public let doubledScore: Double
    public let alternativeOptions: [CaptainCandidate]
    
    public init(
        playerId: String,
        playerName: String,
        currentScore: Double,
        projectedScore: Double,
        alternativeOptions: [CaptainCandidate] = []
    ) {
        self.playerId = playerId
        self.playerName = playerName
        self.currentScore = currentScore
        self.projectedScore = projectedScore
        self.doubledScore = projectedScore * 2
        self.alternativeOptions = alternativeOptions
    }
}

public struct PerformanceAlert: Codable, Identifiable, Hashable {
    public let id: String
    public let type: AlertType
    public let severity: Severity
    public let playerId: String?
    public let playerName: String?
    public let message: String
    public let action: String?
    public let timestamp: Date
    
    public init(
        id: String = UUID().uuidString,
        type: AlertType,
        severity: Severity,
        playerId: String? = nil,
        playerName: String? = nil,
        message: String,
        action: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.severity = severity
        self.playerId = playerId
        self.playerName = playerName
        self.message = message
        self.action = action
        self.timestamp = timestamp
    }
}

public enum AlertType: String, Codable, CaseIterable {
    case captainChange = "CAPTAIN_CHANGE"
    case playerInjured = "PLAYER_INJURED"
    case playerSubbed = "PLAYER_SUBBED"
    case breakoutPerformance = "BREAKOUT_PERFORMANCE"
    case disappointing = "DISAPPOINTING"
    case tradeOpportunity = "TRADE_OPPORTUNITY"
    case rankThreat = "RANK_THREAT"
    case weatherChange = "WEATHER_CHANGE"
}
