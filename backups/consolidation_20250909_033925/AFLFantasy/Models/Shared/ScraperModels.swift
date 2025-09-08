import Foundation

// MARK: - ScraperResponse

/// Generic response wrapper from the Docker scraper
public struct ScraperResponse<T: Codable>: Codable {
    public let success: Bool
    public let data: T?
    public let error: String?
    public let timestamp: Date
    public let executionTime: Double?
    
    public init(success: Bool, data: T?, error: String? = nil, timestamp: Date = Date(), executionTime: Double? = nil) {
        self.success = success
        self.data = data
        self.error = error
        self.timestamp = timestamp
        self.executionTime = executionTime
    }
}

// MARK: - PlayerDataResponse

/// Player data response from Docker scraper
public struct PlayerDataResponse: Codable {
    public let players: [PlayerData]
    public let lastUpdated: Date
    public let totalCount: Int
    public let round: Int
    
    public init(players: [PlayerData], lastUpdated: Date, totalCount: Int, round: Int) {
        self.players = players
        self.lastUpdated = lastUpdated
        self.totalCount = totalCount
        self.round = round
    }
}

// MARK: - Enhanced PlayerData

/// Enhanced player data from Docker scraper
public struct PlayerData: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let team: String
    public let position: String
    public let price: Int
    public let averageScore: Double
    public let totalScore: Int
    public let form: [Int]
    public let lastScore: Int?
    public let priceChange: Int
    public let ownership: Double?
    public let status: String
    public let isInjured: Bool
    public let isSuspended: Bool
    public let breakeven: Int?
    public let nextOpponent: String?
    public let upcomingFixtures: [String]?
    
    public init(
        id: String,
        name: String,
        team: String,
        position: String,
        price: Int,
        averageScore: Double,
        totalScore: Int,
        form: [Int],
        lastScore: Int? = nil,
        priceChange: Int,
        ownership: Double? = nil,
        status: String,
        isInjured: Bool,
        isSuspended: Bool,
        breakeven: Int? = nil,
        nextOpponent: String? = nil,
        upcomingFixtures: [String]? = nil
    ) {
        self.id = id
        self.name = name
        self.team = team
        self.position = position
        self.price = price
        self.averageScore = averageScore
        self.totalScore = totalScore
        self.form = form
        self.lastScore = lastScore
        self.priceChange = priceChange
        self.ownership = ownership
        self.status = status
        self.isInjured = isInjured
        self.isSuspended = isSuspended
        self.breakeven = breakeven
        self.nextOpponent = nextOpponent
        self.upcomingFixtures = upcomingFixtures
    }
}

// MARK: - TeamDataResponse

/// Team data response from Docker scraper
public struct TeamDataResponse: Codable {
    public let teamId: String
    public let teamName: String
    public let teamValue: Int
    public let totalScore: Int
    public let rank: Int
    public let trades: Int
    public let bank: Int
    public let players: [PlayerData]
    public let lastUpdated: Date
    public let captain: String?
    public let viceCaptain: String?
    
    public init(
        teamId: String,
        teamName: String,
        teamValue: Int,
        totalScore: Int,
        rank: Int,
        trades: Int,
        bank: Int,
        players: [PlayerData],
        lastUpdated: Date,
        captain: String? = nil,
        viceCaptain: String? = nil
    ) {
        self.teamId = teamId
        self.teamName = teamName
        self.teamValue = teamValue
        self.totalScore = totalScore
        self.rank = rank
        self.trades = trades
        self.bank = bank
        self.players = players
        self.lastUpdated = lastUpdated
        self.captain = captain
        self.viceCaptain = viceCaptain
    }
}

// MARK: - LiveDataResponse

/// Live scores response from Docker scraper
public struct LiveDataResponse: Codable {
    public let matches: [MatchData]
    public let lastUpdated: Date
    public let isLive: Bool
    public let round: Int
    public let roundName: String
    
    public init(matches: [MatchData], lastUpdated: Date, isLive: Bool, round: Int, roundName: String) {
        self.matches = matches
        self.lastUpdated = lastUpdated
        self.isLive = isLive
        self.round = round
        self.roundName = roundName
    }
}

// MARK: - MatchData

/// Match data from Docker scraper
public struct MatchData: Codable, Identifiable {
    public let id: String
    public let homeTeam: AFLTeam
    public let awayTeam: AFLTeam
    public let homeScore: Int
    public let awayScore: Int
    public let quarter: String
    public let timeRemaining: String?
    public let isComplete: Bool
    public let venue: String
    public let startTime: Date
    
    public init(
        id: String,
        homeTeam: AFLTeam,
        awayTeam: AFLTeam,
        homeScore: Int,
        awayScore: Int,
        quarter: String,
        timeRemaining: String? = nil,
        isComplete: Bool,
        venue: String,
        startTime: Date
    ) {
        self.id = id
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.homeScore = homeScore
        self.awayScore = awayScore
        self.quarter = quarter
        self.timeRemaining = timeRemaining
        self.isComplete = isComplete
        self.venue = venue
        self.startTime = startTime
    }
}

// MARK: - HistoricalPerformance

/// Historical performance data for AI analysis
public struct HistoricalPerformance: Codable {
    public let playerId: String
    public let seasons: [SeasonData]
    public let venueStats: [VenueStats]
    public let opponentStats: [OpponentStats]
    public let weatherStats: WeatherImpactStats?
    
    public init(
        playerId: String,
        seasons: [SeasonData],
        venueStats: [VenueStats],
        opponentStats: [OpponentStats],
        weatherStats: WeatherImpactStats? = nil
    ) {
        self.playerId = playerId
        self.seasons = seasons
        self.venueStats = venueStats
        self.opponentStats = opponentStats
        self.weatherStats = weatherStats
    }
    
    public static func fromScraperData(_ data: [String: Any]) -> HistoricalPerformance? {
        // Convert scraper dictionary data to HistoricalPerformance
        guard let playerId = data["player_id"] as? String else { return nil }
        
        // This would be implemented based on your scraper's actual data structure
        return HistoricalPerformance(
            playerId: playerId,
            seasons: [],
            venueStats: [],
            opponentStats: []
        )
    }
}

// MARK: - Supporting Structures

public struct SeasonData: Codable {
    public let year: Int
    public let gamesPlayed: Int
    public let totalPoints: Int
    public let averagePoints: Double
    public let consistency: Double
    public let ceiling: Int
    public let floor: Int
    
    public init(year: Int, gamesPlayed: Int, totalPoints: Int, averagePoints: Double, consistency: Double, ceiling: Int, floor: Int) {
        self.year = year
        self.gamesPlayed = gamesPlayed
        self.totalPoints = totalPoints
        self.averagePoints = averagePoints
        self.consistency = consistency
        self.ceiling = ceiling
        self.floor = floor
    }
}

public struct VenueStats: Codable {
    public let venue: String
    public let gamesPlayed: Int
    public let averageScore: Double
    public let winRate: Double?
    
    public init(venue: String, gamesPlayed: Int, averageScore: Double, winRate: Double? = nil) {
        self.venue = venue
        self.gamesPlayed = gamesPlayed
        self.averageScore = averageScore
        self.winRate = winRate
    }
}

public struct OpponentStats: Codable {
    public let opponent: String
    public let gamesPlayed: Int
    public let averageScore: Double
    public let winRate: Double?
    
    public init(opponent: String, gamesPlayed: Int, averageScore: Double, winRate: Double? = nil) {
        self.opponent = opponent
        self.gamesPlayed = gamesPlayed
        self.averageScore = averageScore
        self.winRate = winRate
    }
}

public struct WeatherImpactStats: Codable {
    public let rainGames: Int
    public let rainAverageScore: Double
    public let windGames: Int
    public let windAverageScore: Double
    public let coldGames: Int
    public let coldAverageScore: Double
    
    public init(
        rainGames: Int,
        rainAverageScore: Double,
        windGames: Int,
        windAverageScore: Double,
        coldGames: Int,
        coldAverageScore: Double
    ) {
        self.rainGames = rainGames
        self.rainAverageScore = rainAverageScore
        self.windGames = windGames
        self.windAverageScore = windAverageScore
        self.coldGames = coldGames
        self.coldAverageScore = coldAverageScore
    }
}

// MARK: - ScraperResult

/// Result type for scraper operations
public enum ScraperResult {
    case success(message: String)
    case failure(error: Error)
    case partial(completed: Int, total: Int, error: Error?)
}

// MARK: - NetworkError Extensions

extension NetworkError {
    static func scraperError(_ message: String) -> NetworkError {
        .serverError("Scraper: \(message)")
    }
    
    static var dockerUnavailable: NetworkError {
        .serverError("Docker scraper service unavailable")
    }
    
    static func httpError(_ statusCode: Int, _ message: String) -> NetworkError {
        .httpError(statusCode)
    }
    
    static func decodingError(_ error: Error) -> NetworkError {
        .decodingError(error)
    }
}
