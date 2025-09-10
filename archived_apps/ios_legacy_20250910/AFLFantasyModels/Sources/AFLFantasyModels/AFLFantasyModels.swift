import Foundation
import SwiftUI

// Re-export SwiftUI types we depend on
public typealias Color = SwiftUI.Color
public typealias View = SwiftUI.View
public typealias ViewModifier = SwiftUI.ViewModifier

// MARK: - NetworkError

public struct NetworkError: LocalizedError {
    public let code: Int
    public let message: String

    public init(code: Int, message: String) {
        self.code = code
        self.message = message
    }

    public var errorDescription: String? {
        message
    }

    public static let invalidURL = NetworkError(code: -1, message: "Invalid URL")
    public static let noData = NetworkError(code: -2, message: "No data received")
    public static let decodingError = NetworkError(code: -3, message: "Failed to decode response")
    public static let serverError = NetworkError(code: 500, message: "Internal server error")
    public static let clientError = NetworkError(code: 400, message: "Invalid request")
    public static let unauthorized = NetworkError(code: 401, message: "Unauthorized")
    public static let notFound = NetworkError(code: 404, message: "Resource not found")
}

// MARK: - HTTPMethod

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
}

// MARK: - PlayerStats

public struct PlayerStats: Codable, Identifiable {
    public let id: UUID
    public let playerId: Int
    public let name: String
    public let position: Position
    public let team: AFLTeam
    public let price: Double
    public let averageScore: Double
    public let totalScore: Int
    public let gamesPlayed: Int
    public let priceChange: Double
    public let projectedScore: Double?
    public let breakEven: Int
    public let ownership: Double
    public let form: Double
    public let lastRoundScore: Int?
    public let isInjured: Bool
    public let injury: String?
    public let consistencyRating: Double
    public let valueRating: Double

    public var priceChangeText: String {
        let prefix = priceChange >= 0 ? "+" : ""
        return "\(prefix)$\(String(format: "%.1f", priceChange))k"
    }

    public var consistencyGrade: String {
        switch consistencyRating {
        case 90 ... 100: "A+"
        case 80 ..< 90: "A"
        case 70 ..< 80: "B+"
        case 60 ..< 70: "B"
        case 50 ..< 60: "C"
        default: "D"
        }
    }

    public init(
        id: UUID,
        playerId: Int,
        name: String,
        position: Position,
        team: AFLTeam,
        price: Double,
        averageScore: Double,
        totalScore: Int,
        gamesPlayed: Int,
        priceChange: Double,
        projectedScore: Double?,
        breakEven: Int,
        ownership: Double,
        form: Double,
        lastRoundScore: Int?,
        isInjured: Bool,
        injury: String?,
        consistencyRating: Double,
        valueRating: Double
    ) {
        self.id = id
        self.playerId = playerId
        self.name = name
        self.position = position
        self.team = team
        self.price = price
        self.averageScore = averageScore
        self.totalScore = totalScore
        self.gamesPlayed = gamesPlayed
        self.priceChange = priceChange
        self.projectedScore = projectedScore
        self.breakEven = breakEven
        self.ownership = ownership
        self.form = form
        self.lastRoundScore = lastRoundScore
        self.isInjured = isInjured
        self.injury = injury
        self.consistencyRating = consistencyRating
        self.valueRating = valueRating
    }
}

// MARK: - Position

public enum Position: String, Codable, CaseIterable {
    case ruck = "RUCK"
    case forward = "FWD"
    case midfield = "MID"
    case defender = "DEF"

    public var displayName: String {
        switch self {
        case .ruck: "Ruck"
        case .forward: "Forward"
        case .midfield: "Midfielder"
        case .defender: "Defender"
        }
    }
}

// MARK: - AFLTeam

public enum AFLTeam: String, Codable, CaseIterable {
    case adelaide = "ADE"
    case brisbane = "BRL"
    case carlton = "CAR"
    case collingwood = "COL"
    case essendon = "ESS"
    case fremantle = "FRE"
    case geelong = "GEE"
    case goldCoast = "GCS"
    case greaterWesternSydney = "GWS"
    case hawthorn = "HAW"
    case melbourne = "MEL"
    case northMelbourne = "NTH"
    case portAdelaide = "POR"
    case richmond = "RIC"
    case stKilda = "STK"
    case sydney = "SYD"
    case westCoast = "WCE"
    case westernBulldogs = "WBD"

    public var fullName: String {
        switch self {
        case .adelaide: "Adelaide Crows"
        case .brisbane: "Brisbane Lions"
        case .carlton: "Carlton Blues"
        case .collingwood: "Collingwood Magpies"
        case .essendon: "Essendon Bombers"
        case .fremantle: "Fremantle Dockers"
        case .geelong: "Geelong Cats"
        case .goldCoast: "Gold Coast Suns"
        case .greaterWesternSydney: "GWS Giants"
        case .hawthorn: "Hawthorn Hawks"
        case .melbourne: "Melbourne Demons"
        case .northMelbourne: "North Melbourne Kangaroos"
        case .portAdelaide: "Port Adelaide Power"
        case .richmond: "Richmond Tigers"
        case .stKilda: "St Kilda Saints"
        case .sydney: "Sydney Swans"
        case .westCoast: "West Coast Eagles"
        case .westernBulldogs: "Western Bulldogs"
        }
    }

    public var primaryColor: Color {
        switch self {
        case .adelaide: .red
        case .brisbane: Color(red: 0.78, green: 0.27, blue: 0.18)
        case .carlton: .blue
        case .collingwood: .black
        case .essendon: .red
        case .fremantle: .purple
        case .geelong: .blue
        case .goldCoast: .red
        case .greaterWesternSydney: .orange
        case .hawthorn: Color(red: 0.47, green: 0.27, blue: 0.07)
        case .melbourne: .red
        case .northMelbourne: .blue
        case .portAdelaide: Color(red: 0.0, green: 0.27, blue: 0.53)
        case .richmond: .yellow
        case .stKilda: .red
        case .sydney: .red
        case .westCoast: .blue
        case .westernBulldogs: .red
        }
    }
}

// MARK: - TradeAnalysis

public struct TradeAnalysis: Identifiable, Codable {
    public let id: UUID
    public let playerIn: UUID
    public let playerOut: UUID
    public let tradeScore: Double
    public let recommendation: TradeRecommendation
    public let priceProjection: Double
    public let scoreProjection: Double
    public let riskLevel: RiskLevel
    public let reasons: [String]
    public let riskFactors: [String]
    public let timestamp: Date

    public init(
        id: UUID,
        playerIn: UUID,
        playerOut: UUID,
        tradeScore: Double,
        recommendation: TradeRecommendation,
        priceProjection: Double,
        scoreProjection: Double,
        riskLevel: RiskLevel,
        reasons: [String],
        riskFactors: [String],
        timestamp: Date
    ) {
        self.id = id
        self.playerIn = playerIn
        self.playerOut = playerOut
        self.tradeScore = tradeScore
        self.recommendation = recommendation
        self.priceProjection = priceProjection
        self.scoreProjection = scoreProjection
        self.riskLevel = riskLevel
        self.reasons = reasons
        self.riskFactors = riskFactors
        self.timestamp = timestamp
    }
}

// MARK: - TradeRecommendation

public enum TradeRecommendation: String, CaseIterable, Codable {
    case strongBuy = "STRONG_BUY"
    case buy = "BUY"
    case hold = "HOLD"
    case sell = "SELL"
    case strongSell = "STRONG_SELL"

    public var displayText: String {
        switch self {
        case .strongBuy: "Strong Buy"
        case .buy: "Buy"
        case .hold: "Hold"
        case .sell: "Sell"
        case .strongSell: "Strong Sell"
        }
    }
}

// MARK: - RiskLevel

public enum RiskLevel: String, Codable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"

    public var color: Color {
        switch self {
        case .low: .green
        case .medium: .yellow
        case .high: .red
        }
    }
}

// MARK: - EnhancedPlayer

public struct EnhancedPlayer: Identifiable, Codable {
    public let id: UUID
    public let playerId: Int
    public let name: String
    public let position: Position
    public let teamId: Int
    public let teamName: String
    public let teamAbbreviation: String
    public let currentPrice: Double
    public let startingPrice: Double
    public let priceChange: Double
    public let priceChangeProbability: Double
    public let projectedPriceChange: Double
    public let valueGain: Double
    public let totalScore: Int
    public let averageScore: Double
    public let gamesPlayed: Int
    public let ceiling: Int
    public let floor: Int
    public let volatility: Double
    public let form: Double
    public let consistency: Double
    public let opponentPerformance: Double
    public let contractStatus: String
    public let seasonalTrend: SeasonalTrend
    public let threeRoundProjection: [RoundProjection]
    public let benchProbability: Double
    public let isInjured: Bool
    public let injuryDetails: InjuryDetails?
    public let isCaptainRecommended: Bool
    public let isTradeTarget: Bool

    public struct InjuryDetails: Codable {
        public let type: String
        public let expectedReturn: Int
        public let severity: String

        public init(type: String, expectedReturn: Int, severity: String) {
            self.type = type
            self.expectedReturn = expectedReturn
            self.severity = severity
        }
    }

    public struct SeasonalTrend: Codable {
        public let lastFiveScores: [Int]
        public let trendDirection: TrendDirection
        public let formRating: Double

        public init(
            lastFiveScores: [Int],
            trendDirection: TrendDirection,
            formRating: Double
        ) {
            self.lastFiveScores = lastFiveScores
            self.trendDirection = trendDirection
            self.formRating = formRating
        }
    }

    public struct RoundProjection: Codable {
        public let round: Int
        public let projectedScore: Double
        public let confidence: Double
        public let priceChange: Double
        public let breakeven: Int
        public let opponent: AFLTeam
        public let venue: String
        public let conditions: WeatherConditions

        public init(
            round: Int,
            projectedScore: Double,
            confidence: Double,
            priceChange: Double,
            breakeven: Int,
            opponent: AFLTeam,
            venue: String,
            conditions: WeatherConditions
        ) {
            self.round = round
            self.projectedScore = projectedScore
            self.confidence = confidence
            self.priceChange = priceChange
            self.breakeven = breakeven
            self.opponent = opponent
            self.venue = venue
            self.conditions = conditions
        }
    }

    public enum TrendDirection: String, Codable {
        case up = "UP"
        case down = "DOWN"
        case stable = "STABLE"
    }

    public init(
        id: UUID,
        playerId: Int,
        name: String,
        position: Position,
        teamId: Int,
        teamName: String,
        teamAbbreviation: String,
        currentPrice: Double,
        startingPrice: Double,
        priceChange: Double,
        priceChangeProbability: Double,
        projectedPriceChange: Double,
        valueGain: Double,
        totalScore: Int,
        averageScore: Double,
        gamesPlayed: Int,
        ceiling: Int,
        floor: Int,
        volatility: Double,
        form: Double,
        consistency: Double,
        opponentPerformance: Double,
        contractStatus: String,
        seasonalTrend: SeasonalTrend,
        threeRoundProjection: [RoundProjection],
        benchProbability: Double,
        isInjured: Bool,
        injuryDetails: InjuryDetails?,
        isCaptainRecommended: Bool,
        isTradeTarget: Bool
    ) {
        self.id = id
        self.playerId = playerId
        self.name = name
        self.position = position
        self.teamId = teamId
        self.teamName = teamName
        self.teamAbbreviation = teamAbbreviation
        self.currentPrice = currentPrice
        self.startingPrice = startingPrice
        self.priceChange = priceChange
        self.priceChangeProbability = priceChangeProbability
        self.projectedPriceChange = projectedPriceChange
        self.valueGain = valueGain
        self.totalScore = totalScore
        self.averageScore = averageScore
        self.gamesPlayed = gamesPlayed
        self.ceiling = ceiling
        self.floor = floor
        self.volatility = volatility
        self.form = form
        self.consistency = consistency
        self.opponentPerformance = opponentPerformance
        self.contractStatus = contractStatus
        self.seasonalTrend = seasonalTrend
        self.threeRoundProjection = threeRoundProjection
        self.benchProbability = benchProbability
        self.isInjured = isInjured
        self.injuryDetails = injuryDetails
        self.isCaptainRecommended = isCaptainRecommended
        self.isTradeTarget = isTradeTarget
    }
}

// MARK: - WeatherConditions

public struct WeatherConditions: Codable {
    public let temperature: Double
    public let rainChance: Int
    public let windSpeed: Double
    public let description: String
    public let impact: WeatherImpact

    public init(
        temperature: Double,
        rainChance: Int,
        windSpeed: Double,
        description: String,
        impact: WeatherImpact
    ) {
        self.temperature = temperature
        self.rainChance = rainChance
        self.windSpeed = windSpeed
        self.description = description
        self.impact = impact
    }

    public enum WeatherImpact: String, Codable {
        case none = "NONE"
        case low = "LOW"
        case medium = "MEDIUM"
        case high = "HIGH"
    }
}

// MARK: - DashboardData

public struct DashboardData: Codable {
    public struct TeamValue: Codable {
        public let teamValue: Int
        public let valueChange: Int

        public init(teamValue: Int, valueChange: Int) {
            self.teamValue = teamValue
            self.valueChange = valueChange
        }
    }

    public struct TeamScore: Codable {
        public let totalScore: Int
        public let lastRoundScore: Int
        public let projected: Int

        public init(totalScore: Int, lastRoundScore: Int, projected: Int) {
            self.totalScore = totalScore
            self.lastRoundScore = lastRoundScore
            self.projected = projected
        }
    }

    public struct Rank: Codable {
        public let rank: Int
        public let change: Int

        public init(rank: Int, change: Int) {
            self.rank = rank
            self.change = change
        }
    }

    public struct Captain: Codable {
        public let captain: UUID
        public let viceCaptain: UUID
        public let emergencies: [UUID]

        public init(captain: UUID, viceCaptain: UUID, emergencies: [UUID]) {
            self.captain = captain
            self.viceCaptain = viceCaptain
            self.emergencies = emergencies
        }
    }

    public let teamValue: TeamValue
    public let teamScore: TeamScore
    public let rank: Rank
    public let captain: Captain
    public let tradeRecommendations: [TradeRecommendation]

    public init(
        teamValue: TeamValue,
        teamScore: TeamScore,
        rank: Rank,
        captain: Captain,
        tradeRecommendations: [TradeRecommendation]
    ) {
        self.teamValue = teamValue
        self.teamScore = teamScore
        self.rank = rank
        self.captain = captain
        self.tradeRecommendations = tradeRecommendations
    }
}

// MARK: - AlertFlag

public struct AlertFlag: Identifiable, Codable {
    public let id: UUID
    public let type: AlertType
    public let title: String
    public let message: String
    public let severity: AlertSeverity
    public let timestamp: Date
    public let actionRequired: Bool
    public let relatedPlayerId: UUID?

    public init(
        id: UUID,
        type: AlertType,
        title: String,
        message: String,
        severity: AlertSeverity,
        timestamp: Date,
        actionRequired: Bool,
        relatedPlayerId: UUID?
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.severity = severity
        self.timestamp = timestamp
        self.actionRequired = actionRequired
        self.relatedPlayerId = relatedPlayerId
    }

    public enum AlertType: String, Codable {
        case injury = "INJURY"
        case trade = "TRADE"
        case captain = "CAPTAIN"
        case priceRise = "PRICE_RISE"
        case priceDrop = "PRICE_DROP"
        case suspension = "SUSPENSION"
    }

    public enum AlertSeverity: String, Codable {
        case info = "INFO"
        case warning = "WARNING"
        case critical = "CRITICAL"
    }
}
