import Foundation

// MARK: - Performance Tracking Models

public struct UserPerformance {
    public let seasonStats: SeasonPerformance
    public let weeklyHistory: [WeeklyPerformance]
    public let tradeAnalytics: TradeAnalytics
    public let captainAnalytics: CaptainAnalytics
    public let leagueComparisons: LeagueComparisons
    public let achievements: [Achievement]
    
    public init(seasonStats: SeasonPerformance, weeklyHistory: [WeeklyPerformance],
                tradeAnalytics: TradeAnalytics, captainAnalytics: CaptainAnalytics,
                leagueComparisons: LeagueComparisons, achievements: [Achievement]) {
        self.seasonStats = seasonStats
        self.weeklyHistory = weeklyHistory
        self.tradeAnalytics = tradeAnalytics
        self.captainAnalytics = captainAnalytics
        self.leagueComparisons = leagueComparisons
        self.achievements = achievements
    }
}

public struct SeasonPerformance {
    public let currentRank: Int
    public let totalPoints: Int
    public let averageScore: Double
    public let highestScore: Int
    public let lowestScore: Int
    public let roundsCompleted: Int
    public let rankingTrend: RankingTrend
    public let consistency: Double // 0-1 scale
    
    public init(currentRank: Int, totalPoints: Int, averageScore: Double, highestScore: Int,
                lowestScore: Int, roundsCompleted: Int, rankingTrend: RankingTrend, consistency: Double) {
        self.currentRank = currentRank
        self.totalPoints = totalPoints
        self.averageScore = averageScore
        self.highestScore = highestScore
        self.lowestScore = lowestScore
        self.roundsCompleted = roundsCompleted
        self.rankingTrend = rankingTrend
        self.consistency = consistency
    }
}

public enum RankingTrend: String, CaseIterable {
    case rising, stable, falling
    
    public var displayName: String {
        switch self {
        case .rising: return "Rising"
        case .stable: return "Stable"
        case .falling: return "Falling"
        }
    }
    
    public var icon: String {
        switch self {
        case .rising: return "arrow.up.circle.fill"
        case .stable: return "minus.circle.fill"
        case .falling: return "arrow.down.circle.fill"
        }
    }
    
    public var color: String {
        switch self {
        case .rising: return "green"
        case .stable: return "blue"
        case .falling: return "red"
        }
    }
}

public struct WeeklyPerformance {
    public let round: Int
    public let score: Int
    public let rank: Int
    public let benchScore: Int
    public let captainScore: Int
    public let tradesMade: Int
    public let playersMissed: Int
    public let date: Date
    
    public init(round: Int, score: Int, rank: Int, benchScore: Int, captainScore: Int,
                tradesMade: Int, playersMissed: Int, date: Date) {
        self.round = round
        self.score = score
        self.rank = rank
        self.benchScore = benchScore
        self.captainScore = captainScore
        self.tradesMade = tradesMade
        self.playersMissed = playersMissed
        self.date = date
    }
}

public struct TradeAnalytics {
    public let totalTrades: Int
    public let tradesRemaining: Int
    public let successfulTrades: Int
    public let averageTradeValue: Double
    public let bestTrade: TradeOutcome?
    public let worstTrade: TradeOutcome?
    public let tradeHistory: [TradeOutcome]
    
    public init(totalTrades: Int, tradesRemaining: Int, successfulTrades: Int, averageTradeValue: Double,
                bestTrade: TradeOutcome?, worstTrade: TradeOutcome?, tradeHistory: [TradeOutcome]) {
        self.totalTrades = totalTrades
        self.tradesRemaining = tradesRemaining
        self.successfulTrades = successfulTrades
        self.averageTradeValue = averageTradeValue
        self.bestTrade = bestTrade
        self.worstTrade = worstTrade
        self.tradeHistory = tradeHistory
    }
    
    public var successRate: Double {
        guard totalTrades > 0 else { return 0 }
        return Double(successfulTrades) / Double(totalTrades)
    }
}

public struct TradeOutcome {
    public let round: Int
    public let playerOut: String
    public let playerIn: String
    public let pointsGained: Int
    public let priceChange: Int
    public let success: Bool
    public let reason: String
    
    public init(round: Int, playerOut: String, playerIn: String, pointsGained: Int,
                priceChange: Int, success: Bool, reason: String) {
        self.round = round
        self.playerOut = playerOut
        self.playerIn = playerIn
        self.pointsGained = pointsGained
        self.priceChange = priceChange
        self.success = success
        self.reason = reason
    }
}

public struct CaptainAnalytics {
    public let totalCaptainPoints: Int
    public let averageCaptainScore: Double
    public let bestCaptainRound: CaptainChoice?
    public let worstCaptainRound: CaptainChoice?
    public let captainHistory: [CaptainChoice]
    public let popularityStats: CaptainPopularityStats
    
    public init(totalCaptainPoints: Int, averageCaptainScore: Double, bestCaptainRound: CaptainChoice?,
                worstCaptainRound: CaptainChoice?, captainHistory: [CaptainChoice],
                popularityStats: CaptainPopularityStats) {
        self.totalCaptainPoints = totalCaptainPoints
        self.averageCaptainScore = averageCaptainScore
        self.bestCaptainRound = bestCaptainRound
        self.worstCaptainRound = worstCaptainRound
        self.captainHistory = captainHistory
        self.popularityStats = popularityStats
    }
}

public struct CaptainChoice {
    public let round: Int
    public let playerName: String
    public let score: Int
    public let multiplier: Int // 2 for captain, 1.5 for vice
    public let totalPoints: Int
    public let ownership: Double
    public let rank: CaptainChoiceRank
    
    public init(round: Int, playerName: String, score: Int, multiplier: Int, totalPoints: Int,
                ownership: Double, rank: CaptainChoiceRank) {
        self.round = round
        self.playerName = playerName
        self.score = score
        self.multiplier = multiplier
        self.totalPoints = totalPoints
        self.ownership = ownership
        self.rank = rank
    }
}

public enum CaptainChoiceRank: String, CaseIterable {
    case excellent, good, average, poor, terrible
    
    public var displayName: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .average: return "Average"
        case .poor: return "Poor"
        case .terrible: return "Terrible"
        }
    }
    
    public var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "lightGreen"
        case .average: return "yellow"
        case .poor: return "orange"
        case .terrible: return "red"
        }
    }
}

public struct CaptainPopularityStats {
    public let differentialChoices: Int // Captain choices <20% ownership
    public let popularChoices: Int // Captain choices >50% ownership
    public let averageOwnership: Double
    
    public init(differentialChoices: Int, popularChoices: Int, averageOwnership: Double) {
        self.differentialChoices = differentialChoices
        self.popularChoices = popularChoices
        self.averageOwnership = averageOwnership
    }
}

public struct LeagueComparisons {
    public let globalRanking: LeagueRanking
    public let friendsLeagues: [LeagueRanking]
    public let stateRanking: LeagueRanking?
    public let improvements: [ImprovementArea]
    
    public init(globalRanking: LeagueRanking, friendsLeagues: [LeagueRanking],
                stateRanking: LeagueRanking?, improvements: [ImprovementArea]) {
        self.globalRanking = globalRanking
        self.friendsLeagues = friendsLeagues
        self.stateRanking = stateRanking
        self.improvements = improvements
    }
}

public struct LeagueRanking {
    public let leagueName: String
    public let currentRank: Int
    public let totalPlayers: Int
    public let pointsBehindFirst: Int
    public let pointsAheadOfNext: Int
    public let percentile: Double
    
    public init(leagueName: String, currentRank: Int, totalPlayers: Int,
                pointsBehindFirst: Int, pointsAheadOfNext: Int, percentile: Double) {
        self.leagueName = leagueName
        self.currentRank = currentRank
        self.totalPlayers = totalPlayers
        self.pointsBehindFirst = pointsBehindFirst
        self.pointsAheadOfNext = pointsAheadOfNext
        self.percentile = percentile
    }
}

public struct ImprovementArea {
    public let category: ImprovementCategory
    public let description: String
    public let impact: ImpactLevel
    public let actionable: Bool
    
    public init(category: ImprovementCategory, description: String, impact: ImpactLevel, actionable: Bool) {
        self.category = category
        self.description = description
        self.impact = impact
        self.actionable = actionable
    }
}

public enum ImprovementCategory: String, CaseIterable {
    case trading, captaincy, teamSelection, timing, research
    
    public var displayName: String {
        switch self {
        case .trading: return "Trading"
        case .captaincy: return "Captaincy"
        case .teamSelection: return "Team Selection"
        case .timing: return "Timing"
        case .research: return "Research"
        }
    }
    
    public var icon: String {
        switch self {
        case .trading: return "arrow.swap"
        case .captaincy: return "star.fill"
        case .teamSelection: return "person.3.fill"
        case .timing: return "clock.fill"
        case .research: return "magnifyingglass"
        }
    }
}

public enum ImpactLevel: String, CaseIterable {
    case high, medium, low
    
    public var displayName: String {
        switch self {
        case .high: return "High Impact"
        case .medium: return "Medium Impact"
        case .low: return "Low Impact"
        }
    }
    
    public var color: String {
        switch self {
        case .high: return "red"
        case .medium: return "orange"
        case .low: return "green"
        }
    }
}

public struct Achievement {
    public let id: String
    public let title: String
    public let description: String
    public let category: AchievementCategory
    public let progress: AchievementProgress
    public let unlockedDate: Date?
    public let icon: String
    
    public init(id: String, title: String, description: String, category: AchievementCategory,
                progress: AchievementProgress, unlockedDate: Date?, icon: String) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.progress = progress
        self.unlockedDate = unlockedDate
        self.icon = icon
    }
    
    public var isUnlocked: Bool {
        unlockedDate != nil
    }
}

public enum AchievementCategory: String, CaseIterable {
    case scoring, trading, captaincy, consistency, social
    
    public var displayName: String {
        switch self {
        case .scoring: return "Scoring"
        case .trading: return "Trading"
        case .captaincy: return "Captaincy"
        case .consistency: return "Consistency"
        case .social: return "Social"
        }
    }
}

public struct AchievementProgress {
    public let current: Int
    public let target: Int
    
    public init(current: Int, target: Int) {
        self.current = current
        self.target = target
    }
    
    public var percentage: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1.0)
    }
    
    public var isComplete: Bool {
        current >= target
    }
}

// MARK: - Performance Tracking Service

@available(iOS 13.0, *)
public class PerformanceTrackingService: ObservableObject {
    @Published public private(set) var userPerformance: UserPerformance?
    @Published public private(set) var isLoading = false
    @Published public private(set) var lastUpdated: Date?
    
    public init() {}
    
    public func loadPerformanceData() async -> UserPerformance {
        await MainActor.run {
            self.isLoading = true
        }
        
        // Simulate loading time
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        let performance = generateMockPerformanceData()
        
        await MainActor.run {
            self.userPerformance = performance
            self.lastUpdated = Date()
            self.isLoading = false
        }
        
        return performance
    }
    
    public func refreshData() async {
        _ = await loadPerformanceData()
    }
    
    public func trackTradeOutcome(_ outcome: TradeOutcome) {
        // In real implementation, would save to persistent storage
        // and update analytics
    }
    
    public func trackCaptainChoice(_ choice: CaptainChoice) {
        // In real implementation, would save to persistent storage
        // and update captain analytics
    }
    
    // MARK: - Mock Data Generation
    
    private func generateMockPerformanceData() -> UserPerformance {
        let seasonStats = SeasonPerformance(
            currentRank: Int.random(in: 1000...100000),
            totalPoints: Int.random(in: 1800...2400),
            averageScore: Double.random(in: 80...120),
            highestScore: Int.random(in: 120...180),
            lowestScore: Int.random(in: 40...80),
            roundsCompleted: Int.random(in: 15...23),
            rankingTrend: RankingTrend.allCases.randomElement() ?? .stable,
            consistency: Double.random(in: 0.4...0.9)
        )
        
        let weeklyHistory = generateWeeklyHistory()
        let tradeAnalytics = generateTradeAnalytics()
        let captainAnalytics = generateCaptainAnalytics()
        let leagueComparisons = generateLeagueComparisons()
        let achievements = generateAchievements()
        
        return UserPerformance(
            seasonStats: seasonStats,
            weeklyHistory: weeklyHistory,
            tradeAnalytics: tradeAnalytics,
            captainAnalytics: captainAnalytics,
            leagueComparisons: leagueComparisons,
            achievements: achievements
        )
    }
    
    private func generateWeeklyHistory() -> [WeeklyPerformance] {
        return (1...20).map { round in
            WeeklyPerformance(
                round: round,
                score: Int.random(in: 1400...2200),
                rank: Int.random(in: 1000...150000),
                benchScore: Int.random(in: 150...400),
                captainScore: Int.random(in: 80...200),
                tradesMade: Int.random(in: 0...3),
                playersMissed: Int.random(in: 0...2),
                date: Calendar.current.date(byAdding: .day, value: -7 * (20 - round), to: Date()) ?? Date()
            )
        }
    }
    
    private func generateTradeAnalytics() -> TradeAnalytics {
        let tradeHistory = (1...15).map { i in
            TradeOutcome(
                round: i,
                playerOut: "Player Out \(i)",
                playerIn: "Player In \(i)",
                pointsGained: Int.random(in: -50...100),
                priceChange: Int.random(in: -20000...30000),
                success: Bool.random(),
                reason: ["Form improvement", "Injury return", "Fixture run", "Price rise"].randomElement() ?? "Strategy"
            )
        }
        
        return TradeAnalytics(
            totalTrades: 15,
            tradesRemaining: Int.random(in: 5...15),
            successfulTrades: tradeHistory.filter { $0.success }.count,
            averageTradeValue: Double.random(in: -5...25),
            bestTrade: tradeHistory.max { $0.pointsGained < $1.pointsGained },
            worstTrade: tradeHistory.min { $0.pointsGained < $1.pointsGained },
            tradeHistory: tradeHistory
        )
    }
    
    private func generateCaptainAnalytics() -> CaptainAnalytics {
        let captainHistory = (1...20).map { round in
            CaptainChoice(
                round: round,
                playerName: ["Daicos", "Bontempelli", "Oliver", "Cripps", "Walsh"].randomElement() ?? "Player",
                score: Int.random(in: 60...180),
                multiplier: 2,
                totalPoints: Int.random(in: 120...360),
                ownership: Double.random(in: 10...80),
                rank: CaptainChoiceRank.allCases.randomElement() ?? .average
            )
        }
        
        let popularityStats = CaptainPopularityStats(
            differentialChoices: captainHistory.filter { $0.ownership < 20 }.count,
            popularChoices: captainHistory.filter { $0.ownership > 50 }.count,
            averageOwnership: captainHistory.reduce(0) { $0 + $1.ownership } / Double(captainHistory.count)
        )
        
        return CaptainAnalytics(
            totalCaptainPoints: captainHistory.reduce(0) { $0 + $1.totalPoints },
            averageCaptainScore: Double(captainHistory.reduce(0) { $0 + $1.totalPoints }) / Double(captainHistory.count),
            bestCaptainRound: captainHistory.max { $0.totalPoints < $1.totalPoints },
            worstCaptainRound: captainHistory.min { $0.totalPoints < $1.totalPoints },
            captainHistory: captainHistory,
            popularityStats: popularityStats
        )
    }
    
    private func generateLeagueComparisons() -> LeagueComparisons {
        let globalRanking = LeagueRanking(
            leagueName: "Overall",
            currentRank: Int.random(in: 5000...500000),
            totalPlayers: Int.random(in: 800000...1200000),
            pointsBehindFirst: Int.random(in: 200...800),
            pointsAheadOfNext: Int.random(in: 5...50),
            percentile: Double.random(in: 10...90)
        )
        
        let friendsLeagues = (1...3).map { i in
            LeagueRanking(
                leagueName: "Friends League \(i)",
                currentRank: Int.random(in: 1...20),
                totalPlayers: Int.random(in: 10...50),
                pointsBehindFirst: Int.random(in: 0...200),
                pointsAheadOfNext: Int.random(in: 0...30),
                percentile: Double.random(in: 20...95)
            )
        }
        
        let improvements = [
            ImprovementArea(category: .trading, description: "Consider holding trades longer", impact: .medium, actionable: true),
            ImprovementArea(category: .captaincy, description: "More differential captain choices", impact: .high, actionable: true),
            ImprovementArea(category: .teamSelection, description: "Better value picks in defense", impact: .low, actionable: false)
        ]
        
        return LeagueComparisons(
            globalRanking: globalRanking,
            friendsLeagues: friendsLeagues,
            stateRanking: nil,
            improvements: improvements
        )
    }
    
    private func generateAchievements() -> [Achievement] {
        return [
            Achievement(
                id: "century_scorer",
                title: "Century Scorer",
                description: "Score 100+ points in a round",
                category: .scoring,
                progress: AchievementProgress(current: 8, target: 10),
                unlockedDate: nil,
                icon: "100.circle.fill"
            ),
            Achievement(
                id: "trade_master",
                title: "Trade Master",
                description: "Make 20 successful trades in a season",
                category: .trading,
                progress: AchievementProgress(current: 12, target: 20),
                unlockedDate: nil,
                icon: "arrow.swap.circle.fill"
            ),
            Achievement(
                id: "captain_fantastic",
                title: "Captain Fantastic",
                description: "Captain scores 150+ points in a round",
                category: .captaincy,
                progress: AchievementProgress(current: 3, target: 5),
                unlockedDate: Date(),
                icon: "star.circle.fill"
            )
        ]
    }
}
