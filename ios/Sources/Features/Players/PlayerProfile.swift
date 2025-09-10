import Foundation

// MARK: - Enhanced Player Profile Models

public struct PlayerProfile {
    public let player: Player
    public let seasonStats: SeasonStats
    public let formTrends: FormTrendData
    public let priceHistory: [PriceHistoryPoint]
    public let injuryHistory: [PlayerInjury]
    public let upcomingFixtures: [DetailedFixture]
    public let ownershipData: OwnershipTrend
    public let performanceAnalytics: PerformanceAnalytics
    
    public init(player: Player, seasonStats: SeasonStats, formTrends: FormTrendData,
                priceHistory: [PriceHistoryPoint], injuryHistory: [PlayerInjury],
                upcomingFixtures: [DetailedFixture], ownershipData: OwnershipTrend,
                performanceAnalytics: PerformanceAnalytics) {
        self.player = player
        self.seasonStats = seasonStats
        self.formTrends = formTrends
        self.priceHistory = priceHistory
        self.injuryHistory = injuryHistory
        self.upcomingFixtures = upcomingFixtures
        self.ownershipData = ownershipData
        self.performanceAnalytics = performanceAnalytics
    }
}

public struct SeasonStats {
    public let gamesPlayed: Int
    public let totalPoints: Int
    public let averagePoints: Double
    public let goals: Int
    public let assists: Int
    public let possessions: Double
    public let disposalEfficiency: Double
    public let tacklesPerGame: Double
    public let marksPerGame: Double
    public let hitoutsPerGame: Double // For rucks
    
    public init(gamesPlayed: Int, totalPoints: Int, averagePoints: Double, goals: Int,
                assists: Int, possessions: Double, disposalEfficiency: Double,
                tacklesPerGame: Double, marksPerGame: Double, hitoutsPerGame: Double = 0) {
        self.gamesPlayed = gamesPlayed
        self.totalPoints = totalPoints
        self.averagePoints = averagePoints
        self.goals = goals
        self.assists = assists
        self.possessions = possessions
        self.disposalEfficiency = disposalEfficiency
        self.tacklesPerGame = tacklesPerGame
        self.marksPerGame = marksPerGame
        self.hitoutsPerGame = hitoutsPerGame
    }
}

public struct FormTrendData {
    public let last5Games: [GameScore]
    public let last3Average: Double
    public let last5Average: Double
    public let trend: TrendDirection
    public let consistency: Double // 0-1 scale
    
    public init(last5Games: [GameScore], last3Average: Double, last5Average: Double,
                trend: TrendDirection, consistency: Double) {
        self.last5Games = last5Games
        self.last3Average = last3Average
        self.last5Average = last5Average
        self.trend = trend
        self.consistency = consistency
    }
}

public struct GameScore {
    public let round: Int
    public let opponent: String
    public let score: Int
    public let isHome: Bool
    public let date: Date
    
    public init(round: Int, opponent: String, score: Int, isHome: Bool, date: Date) {
        self.round = round
        self.opponent = opponent
        self.score = score
        self.isHome = isHome
        self.date = date
    }
}

public enum TrendDirection: String, CaseIterable {
    case stronglyUp, up, stable, down, stronglyDown
    
    public var displayName: String {
        switch self {
        case .stronglyUp: return "Strongly Improving"
        case .up: return "Improving"
        case .stable: return "Stable"
        case .down: return "Declining"
        case .stronglyDown: return "Strongly Declining"
        }
    }
    
    public var icon: String {
        switch self {
        case .stronglyUp: return "arrow.up.circle.fill"
        case .up: return "arrow.up.circle"
        case .stable: return "minus.circle"
        case .down: return "arrow.down.circle"
        case .stronglyDown: return "arrow.down.circle.fill"
        }
    }
}

public struct PriceHistoryPoint {
    public let round: Int
    public let price: Int
    public let change: Int
    public let date: Date
    
    public init(round: Int, price: Int, change: Int, date: Date) {
        self.round = round
        self.price = price
        self.change = change
        self.date = date
    }
}

public struct PlayerInjury {
    public let type: String
    public let description: String
    public let startDate: Date
    public let endDate: Date?
    public let roundsOut: Int
    public let severity: InjurySeverity
    public let returnRisk: ReturnRisk
    
    public init(type: String, description: String, startDate: Date, endDate: Date?,
                roundsOut: Int, severity: InjurySeverity, returnRisk: ReturnRisk) {
        self.type = type
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.roundsOut = roundsOut
        self.severity = severity
        self.returnRisk = returnRisk
    }
}

public enum ReturnRisk: String, CaseIterable {
    case low, medium, high, uncertain
    
    public var displayName: String {
        switch self {
        case .low: return "Low Risk"
        case .medium: return "Medium Risk"
        case .high: return "High Risk"
        case .uncertain: return "Uncertain"
        }
    }
}

public struct DetailedFixture {
    public let round: Int
    public let opponent: String
    public let isHome: Bool
    public let date: Date
    public let venue: String
    public let difficulty: FixtureDifficulty
    public let opponentForm: [Double] // Last 5 defensive scores against this position
    public let weatherImpact: WeatherImpact
    
    public init(round: Int, opponent: String, isHome: Bool, date: Date, venue: String,
                difficulty: FixtureDifficulty, opponentForm: [Double], weatherImpact: WeatherImpact) {
        self.round = round
        self.opponent = opponent
        self.isHome = isHome
        self.date = date
        self.venue = venue
        self.difficulty = difficulty
        self.opponentForm = opponentForm
        self.weatherImpact = weatherImpact
    }
}

public enum FixtureDifficulty: Int, CaseIterable {
    case veryEasy = 1, easy = 2, medium = 3, hard = 4, veryHard = 5
    
    public var displayName: String {
        switch self {
        case .veryEasy: return "Very Easy"
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .veryHard: return "Very Hard"
        }
    }
    
    public var color: String {
        switch self {
        case .veryEasy: return "green"
        case .easy: return "lightGreen"
        case .medium: return "yellow"
        case .hard: return "orange"
        case .veryHard: return "red"
        }
    }
}

public enum WeatherImpact: String, CaseIterable {
    case none, slight, moderate, significant
    
    public var displayName: String {
        switch self {
        case .none: return "No Impact"
        case .slight: return "Slight Impact"
        case .moderate: return "Moderate Impact"
        case .significant: return "Significant Impact"
        }
    }
}

public struct OwnershipTrend {
    public let currentPercentage: Double
    public let trend: [OwnershipPoint]
    public let rank: OwnershipRank
    
    public init(currentPercentage: Double, trend: [OwnershipPoint], rank: OwnershipRank) {
        self.currentPercentage = currentPercentage
        self.trend = trend
        self.rank = rank
    }
}

public struct OwnershipPoint {
    public let round: Int
    public let percentage: Double
    public let date: Date
    
    public init(round: Int, percentage: Double, date: Date) {
        self.round = round
        self.percentage = percentage
        self.date = date
    }
}

public enum OwnershipRank: String, CaseIterable {
    case differential, moderate, popular, essential
    
    public var displayName: String {
        switch self {
        case .differential: return "Differential"
        case .moderate: return "Moderate"
        case .popular: return "Popular"
        case .essential: return "Essential"
        }
    }
    
    public var threshold: ClosedRange<Double> {
        switch self {
        case .differential: return 0...15
        case .moderate: return 15.1...40
        case .popular: return 40.1...70
        case .essential: return 70.1...100
        }
    }
}

public struct PerformanceAnalytics {
    public let valueRating: Double // Points per $1000
    public let projectedBreakeven: Int
    public let ceilingScore: Int
    public let floorScore: Int
    public let homeAdvantage: Double
    public let positionRanking: Int
    public let teamDependency: Double // How much performance relies on team performance
    
    public init(valueRating: Double, projectedBreakeven: Int, ceilingScore: Int,
                floorScore: Int, homeAdvantage: Double, positionRanking: Int, teamDependency: Double) {
        self.valueRating = valueRating
        self.projectedBreakeven = projectedBreakeven
        self.ceilingScore = ceilingScore
        self.floorScore = floorScore
        self.homeAdvantage = homeAdvantage
        self.positionRanking = positionRanking
        self.teamDependency = teamDependency
    }
}

// MARK: - Player Profile Service

@available(iOS 13.0, *)
public class PlayerProfileService: ObservableObject {
    @Published public private(set) var profileCache: [String: PlayerProfile] = [:]
    @Published public private(set) var isLoading = false
    
    public init() {}
    
    public func loadProfile(for player: Player) async -> PlayerProfile {
        if let cached = profileCache[player.id] {
            return cached
        }
        
        await MainActor.run {
            self.isLoading = true
        }
        
        // Simulate API loading
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        let profile = generateMockProfile(for: player)
        
        await MainActor.run {
            self.profileCache[player.id] = profile
            self.isLoading = false
        }
        
        return profile
    }
    
    public func invalidateCache(for playerId: String) {
        profileCache.removeValue(forKey: playerId)
    }
    
    // MARK: - Mock Data Generation
    
    private func generateMockProfile(for player: Player) -> PlayerProfile {
        let seasonStats = SeasonStats(
            gamesPlayed: Int.random(in: 15...23),
            totalPoints: Int.random(in: 1200...2400),
            averagePoints: player.average,
            goals: Int.random(in: 0...50),
            assists: Int.random(in: 0...30),
            possessions: Double.random(in: 15...35),
            disposalEfficiency: Double.random(in: 0.65...0.95),
            tacklesPerGame: Double.random(in: 2...8),
            marksPerGame: Double.random(in: 3...12)
        )
        
        let last5Games = (1...5).map { i in
            GameScore(round: 23 - i, opponent: "OPP", score: Int.random(in: 40...140),
                     isHome: Bool.random(), date: Date())
        }
        
        let formTrends = FormTrendData(
            last5Games: last5Games,
            last3Average: Double.random(in: 70...120),
            last5Average: Double.random(in: 70...120),
            trend: TrendDirection.allCases.randomElement() ?? .stable,
            consistency: Double.random(in: 0.4...0.9)
        )
        
        let priceHistory = (1...20).map { round in
            PriceHistoryPoint(round: round, price: player.price + Int.random(in: -100000...100000),
                            change: Int.random(in: -20000...20000), date: Date())
        }
        
        let upcomingFixtures = (1...6).map { round in
            DetailedFixture(
                round: 24 + round,
                opponent: ["COL", "ESS", "CAR", "FRE", "GEE"].randomElement() ?? "OPP",
                isHome: Bool.random(),
                date: Calendar.current.date(byAdding: .day, value: round * 7, to: Date()) ?? Date(),
                venue: "Venue",
                difficulty: FixtureDifficulty.allCases.randomElement() ?? .medium,
                opponentForm: (1...5).map { _ in Double.random(in: 60...100) },
                weatherImpact: WeatherImpact.allCases.randomElement() ?? .none
            )
        }
        
        let ownershipTrend = (1...20).map { round in
            OwnershipPoint(round: round, percentage: Double.random(in: 5...80), date: Date())
        }
        
        let ownershipData = OwnershipTrend(
            currentPercentage: Double.random(in: 5...80),
            trend: ownershipTrend,
            rank: OwnershipRank.allCases.randomElement() ?? .moderate
        )
        
        let analytics = PerformanceAnalytics(
            valueRating: Double.random(in: 0.05...0.25),
            projectedBreakeven: Int.random(in: 40...120),
            ceilingScore: Int.random(in: 120...180),
            floorScore: Int.random(in: 20...60),
            homeAdvantage: Double.random(in: -5...15),
            positionRanking: Int.random(in: 1...50),
            teamDependency: Double.random(in: 0.3...0.9)
        )
        
        return PlayerProfile(
            player: player,
            seasonStats: seasonStats,
            formTrends: formTrends,
            priceHistory: priceHistory,
            injuryHistory: [],
            upcomingFixtures: upcomingFixtures,
            ownershipData: ownershipData,
            performanceAnalytics: analytics
        )
    }
}
