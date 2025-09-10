// 🏈 AFL Fantasy Models - Dashboard & Stats Domain
// Live stats, cash generation, game info, weekly tracking

import Foundation

// MARK: - Dashboard Models

struct LiveStats: Codable {
    let currentScore: Int
    let rank: Int
    let playersPlaying: Int
    let playersRemaining: Int
    let averageScore: Double
    
    init() {
        self.currentScore = 0
        self.rank = 0
        self.playersPlaying = 0
        self.playersRemaining = 0
        self.averageScore = 0.0
    }
    
    init(currentScore: Int, rank: Int, playersPlaying: Int, playersRemaining: Int, averageScore: Double) {
        self.currentScore = currentScore
        self.rank = rank
        self.playersPlaying = playersPlaying
        self.playersRemaining = playersRemaining
        self.averageScore = averageScore
    }
}

struct WeeklyStats: Codable {
    let round: Int
    let projectedScore: Int
    let actualScore: Int?
    let rank: Int?
    let improvement: Double
    
    init() {
        self.round = 0
        self.projectedScore = 0
        self.actualScore = nil
        self.rank = nil
        self.improvement = 0.0
    }
    
    init(round: Int, projectedScore: Int, actualScore: Int?, rank: Int?, improvement: Double) {
        self.round = round
        self.projectedScore = projectedScore
        self.actualScore = actualScore
        self.rank = rank
        self.improvement = improvement
    }
}

struct CashGenStats: Codable {
    let totalGenerated: Int
    let activeCashCows: Int
    let sellRecommendations: Int
    let holdCount: Int
    let recentHistory: [CashHistory]
    
    init() {
        self.totalGenerated = 0
        self.activeCashCows = 0
        self.sellRecommendations = 0
        self.holdCount = 0
        self.recentHistory = []
    }
    
    init(totalGenerated: Int, activeCashCows: Int, sellRecommendations: Int, holdCount: Int, recentHistory: [CashHistory]) {
        self.totalGenerated = totalGenerated
        self.activeCashCows = activeCashCows
        self.sellRecommendations = sellRecommendations
        self.holdCount = holdCount
        self.recentHistory = recentHistory
    }
}

struct CashHistory: Codable, Identifiable {
    let id: String
    let playerId: String
    let playerName: String
    let generated: Double
    let date: Date
    let action: CashAction
    
    init(id: String = UUID().uuidString, playerId: String, playerName: String, generated: Double, date: Date, action: CashAction) {
        self.id = id
        self.playerId = playerId
        self.playerName = playerName
        self.generated = generated
        self.date = date
        self.action = action
    }
}

enum CashAction: String, Codable {
    case buy = "BUY"
    case sell = "SELL"
    case hold = "HOLD"
}

struct GameInfo: Codable, Identifiable {
    let id: String
    let homeTeam: String
    let awayTeam: String
    let status: GameStatus
    let round: Int
    let venue: String
    
    enum GameStatus: String, Codable {
        case scheduled = "SCHEDULED"
        case inProgress = "IN_PROGRESS"
        case finished = "FINISHED"
        case cancelled = "CANCELLED"
    }
}

// MARK: - Cash Cow Analysis

struct CashCowAnalysis: Codable {
    let player: Player
    let generated: Int
    let projectedGeneration: Int
    let sellRecommendation: Bool
    let holdRecommendation: Bool
}

struct CashCowData: Codable {
    let playerId: String
    let playerName: String
    let currentPrice: Int
    let projectedPrice: Int
    let cashGenerated: Int
    let recommendation: String
    let confidence: Double
    let fpAverage: Double
    let gamesPlayed: Int
}

struct BreakEvenTarget: Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let currentPrice: Int
    let targetPrice: Int
    let weeksToTarget: Int
    let probability: Double
    
    enum TimeFrame: String, CaseIterable {
        case oneWeek = "1_WEEK"
        case twoWeeks = "2_WEEKS"
        case threeWeeks = "3_WEEKS"
        case fourWeeks = "4_WEEKS"
        case month = "1_MONTH"
    }
}

struct SellRecommendation: Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let currentPrice: Int
    let reason: String
    let confidence: Double
    let urgency: UrgencyLevel
    
    enum UrgencyLevel: String, Codable {
        case low = "LOW"
        case medium = "MEDIUM"
        case high = "HIGH"
    }
}

struct HoldRecommendation: Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let reason: String
    let weeksToHold: Int
    let expectedGain: Int
}

struct WatchlistPlayer: Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let currentPrice: Int
    let targetPrice: Int
    let breakEven: Int
    let timeframe: String
    let sellWeek: Int
    let confidence: Double
    let priceTrajectory: [PriceProjection]
}

struct PriceProjection: Codable {
    let round: Int
    let price: Int
    let confidence: Double
}

// MARK: - API Response Models

struct APIHealthResponse: Codable {
    let status: String
    let timestamp: String
    let playersCached: Int
    let lastCacheUpdate: String?
}

struct APIStatsResponse: Codable {
    let totalPlayers: Int
    let playersWithData: Int
    let cashCowsIdentified: Int
    let lastUpdated: String?
    let cacheAgeMinutes: Int
}
