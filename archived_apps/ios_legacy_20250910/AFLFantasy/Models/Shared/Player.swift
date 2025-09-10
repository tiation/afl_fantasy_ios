// MARK: - Player

/// Player represents an AFL fantasy player with all stats and analysis.
/// This is the single source of truth for player data in the app.
/// - Note: For API mapping, see extension in Generated/ApiClient/Mapping/
public struct Player: Identifiable, Codable, Hashable, Equatable {
    // MARK: - Core Properties

    public let id: String // Internal ID (String for flexibility)
    public let apiId: Int // ID from AFL API
    public let name: String
    public let position: Position
    public let teamId: Int
    public let teamName: String
    public let teamAbbreviation: String

    // MARK: - Statistics

    public let currentPrice: Int
    public let currentScore: Int
    public let averageScore: Double
    public let totalScore: Int
    public let breakeven: Int
    public let gamesPlayed: Int
    public let consistency: Double
    public let ceiling: Int
    public let floor: Int
    public let volatility: Double
    public let ownership: Double? // From API
    public let lastScore: Int? // From API

    // MARK: - Price & Value

    public let startingPrice: Int
    public let priceChange: Int
    public let priceChangeProbability: Double
    public let cashGenerated: Int
    public let valueGain: Double

    // MARK: - Status

    public let isInjured: Bool
    public let isDoubtful: Bool
    public let isSuspended: Bool
    public var isActive: Bool { !isInjured && !isDoubtful && !isSuspended }

    // MARK: - Risk Assessment

    public let injuryRisk: InjuryRisk

    // MARK: - Projections & Analysis

    public let contractStatus: String
    public let seasonalTrend: [Double]
    public let nextRoundProjection: RoundProjection
    public let threeRoundProjection: [RoundProjection]
    public let seasonProjection: SeasonProjection
    public let venuePerformance: [VenuePerformance]
    public let opponentPerformance: [String: Double]

    // MARK: - Flags & Indicators

    public let isCaptainRecommended: Bool
    public let isTradeTarget: Bool
    public let isCashCow: Bool
    public let alertFlags: [AlertFlag]

    // MARK: - Initializer

    public init(
        id: String,
        apiId: Int,
        name: String,
        position: Position,
        teamId: Int,
        teamName: String,
        teamAbbreviation: String,
        currentPrice: Int,
        currentScore: Int,
        averageScore: Double,
        totalScore: Int,
        breakeven: Int,
        gamesPlayed: Int,
        consistency: Double,
        ceiling: Int,
        floor: Int,
        volatility: Double,
        ownership: Double? = nil,
        lastScore: Int? = nil,
        startingPrice: Int,
        priceChange: Int,
        priceChangeProbability: Double,
        cashGenerated: Int,
        valueGain: Double,
        isInjured: Bool,
        isDoubtful: Bool,
        isSuspended: Bool,
        injuryRisk: InjuryRisk,
        contractStatus: String,
        seasonalTrend: [Double],
        nextRoundProjection: RoundProjection,
        threeRoundProjection: [RoundProjection],
        seasonProjection: SeasonProjection,
        venuePerformance: [VenuePerformance],
        opponentPerformance: [String: Double],
        isCaptainRecommended: Bool,
        isTradeTarget: Bool,
        isCashCow: Bool,
        alertFlags: [AlertFlag]
    ) {
        self.id = id
        self.apiId = apiId
        self.name = name
        self.position = position
        self.teamId = teamId
        self.teamName = teamName
        self.teamAbbreviation = teamAbbreviation
        self.currentPrice = currentPrice
        self.currentScore = currentScore
        self.averageScore = averageScore
        self.totalScore = totalScore
        self.breakeven = breakeven
        self.gamesPlayed = gamesPlayed
        self.consistency = consistency
        self.ceiling = ceiling
        self.floor = floor
        self.volatility = volatility
        self.ownership = ownership
        self.lastScore = lastScore
        self.startingPrice = startingPrice
        self.priceChange = priceChange
        self.priceChangeProbability = priceChangeProbability
        self.cashGenerated = cashGenerated
        self.valueGain = valueGain
        self.isInjured = isInjured
        self.isDoubtful = isDoubtful
        self.isSuspended = isSuspended
        self.injuryRisk = injuryRisk
        self.contractStatus = contractStatus
        self.seasonalTrend = seasonalTrend
        self.nextRoundProjection = nextRoundProjection
        self.threeRoundProjection = threeRoundProjection
        self.seasonProjection = seasonProjection
        self.venuePerformance = venuePerformance
        self.opponentPerformance = opponentPerformance
        self.isCaptainRecommended = isCaptainRecommended
        self.isTradeTarget = isTradeTarget
        self.isCashCow = isCashCow
        self.alertFlags = alertFlags
    }
}

// MARK: - Computed Properties

public extension Player {
    var formattedPrice: String { "$\(currentPrice / 1000)k" }

    var priceChangeText: String {
        let prefix = priceChange >= 0 ? "+" : ""
        return "\(prefix)$\(abs(priceChange) / 1000)k"
    }

    var consistencyGrade: String {
        switch consistency {
        case ..<60: "D"
        case ..<70: "C"
        case ..<80: "B"
        case ..<90: "A"
        default: "A+"
        }
    }
}
