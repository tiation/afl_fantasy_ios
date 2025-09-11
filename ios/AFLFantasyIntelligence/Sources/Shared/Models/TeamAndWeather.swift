import Foundation

// MARK: - FantasyTeam

public struct FantasyTeam: Codable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let code: String
    public let league: String
    public let isActive: Bool
    public let manager: String?
    public let totalSalary: Int
    public let remainingSalary: Int
    public let playerCount: Int
    public let averageScore: Double
    public let currentRank: Int?
    public let points: Double?
    public let players: [Player]
    
    public init(
        id: String,
        name: String,
        code: String,
        league: String = "AFL",
        isActive: Bool = true,
        manager: String? = nil,
        totalSalary: Int = 0,
        remainingSalary: Int = 0,
        playerCount: Int = 0,
        averageScore: Double = 0.0,
        currentRank: Int? = nil,
        points: Double? = nil,
        players: [Player] = []
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.league = league
        self.isActive = isActive
        self.manager = manager
        self.totalSalary = totalSalary
        self.remainingSalary = remainingSalary
        self.playerCount = playerCount
        self.averageScore = averageScore
        self.currentRank = currentRank
        self.points = points
        self.players = players
    }
    
    // Computed property for backward compatibility
    public var rank: Int? {
        return currentRank
    }
}

// MARK: - WeatherConditions

public struct WeatherConditions: Codable, Hashable, Sendable {
    public let temperature: Double
    public let humidity: Double
    public let windSpeed: Double
    public let windDirection: String
    public let conditions: String
    
    public init(
        temperature: Double,
        humidity: Double,
        windSpeed: Double,
        windDirection: String,
        conditions: String
    ) {
        self.temperature = temperature
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.windDirection = windDirection
        self.conditions = conditions
    }
    
    public var description: String {
        return "\(Int(temperature))°C, \(conditions), \(Int(windSpeed))km/h \(windDirection)"
    }
}
