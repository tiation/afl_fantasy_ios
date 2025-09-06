//
//  DataModels.swift
//  AFL Fantasy Intelligence Platform
//
//  Core data models for players, teams, trades, and analytics
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import SwiftUI

// MARK: - Core Player Models

struct EnhancedPlayer: Identifiable, Codable, Hashable {
    let id: UUID
    let aflPlayerId: Int
    let name: String
    let position: PlayerPosition
    let team: AFLTeam
    let price: Int
    let averageScore: Double
    let lastScore: Int
    let priceChange: Int
    let ownership: Double
    let form: [Int] // Last 5 scores
    let projectedScore: Double
    let injuryRisk: InjuryRisk
    let venueAdvantage: Double
    let consistency: Double
    let isDoubtful: Bool
    let isCashCow: Bool
    let breakEvenPrice: Int
    let cashGenerated: Int
    let alertFlags: [AlertFlag]
    let fixtureRating: Double
    let opponentStrength: Double
    
    init(
        id: UUID = UUID(),
        aflPlayerId: Int,
        name: String,
        position: PlayerPosition,
        team: AFLTeam,
        price: Int,
        averageScore: Double = 0,
        lastScore: Int = 0,
        priceChange: Int = 0,
        ownership: Double = 0,
        form: [Int] = [],
        projectedScore: Double = 0,
        injuryRisk: InjuryRisk = .low,
        venueAdvantage: Double = 0,
        consistency: Double = 0,
        isDoubtful: Bool = false,
        isCashCow: Bool = false,
        breakEvenPrice: Int = 0,
        cashGenerated: Int = 0,
        alertFlags: [AlertFlag] = [],
        fixtureRating: Double = 0.5,
        opponentStrength: Double = 0.5
    ) {
        self.id = id
        self.aflPlayerId = aflPlayerId
        self.name = name
        self.position = position
        self.team = team
        self.price = price
        self.averageScore = averageScore
        self.lastScore = lastScore
        self.priceChange = priceChange
        self.ownership = ownership
        self.form = form
        self.projectedScore = projectedScore
        self.injuryRisk = injuryRisk
        self.venueAdvantage = venueAdvantage
        self.consistency = consistency
        self.isDoubtful = isDoubtful
        self.isCashCow = isCashCow
        self.breakEvenPrice = breakEvenPrice
        self.cashGenerated = cashGenerated
        self.alertFlags = alertFlags
        self.fixtureRating = fixtureRating
        self.opponentStrength = opponentStrength
    }
}

// MARK: - Player Extensions

extension EnhancedPlayer {
    var formattedPrice: String {
        return "$\(price / 1000)K"
    }
    
    var priceChangeText: String {
        let change = priceChange / 1000
        return change > 0 ? "+$\(change)K" : "-$\(abs(change))K"
    }
    
    var formAverage: Double {
        guard !form.isEmpty else { return 0 }
        return Double(form.reduce(0, +)) / Double(form.count)
    }
    
    var isGoodValue: Bool {
        return averageScore * 1000 > Double(price) * 0.8
    }
    
    var riskLevel: String {
        switch injuryRisk {
        case .none, .low: return "Low Risk"
        case .medium: return "Medium Risk"
        case .high: return "High Risk"
        case .injured: return "Injured"
        }
    }
}

// MARK: - Supporting Enums

enum PlayerPosition: String, CaseIterable, Codable {
    case defender = "DEF"
    case midfielder = "MID"
    case ruck = "RUC"
    case forward = "FWD"
    
    var color: Color {
        switch self {
        case .defender: return .blue
        case .midfielder: return .green
        case .ruck: return .purple
        case .forward: return .red
        }
    }
    
    var displayName: String {
        switch self {
        case .defender: return "Defender"
        case .midfielder: return "Midfielder"
        case .ruck: return "Ruckman"
        case .forward: return "Forward"
        }
    }
}

enum AFLTeam: String, CaseIterable, Codable {
    case adelaide = "ADE"
    case brisbane = "BL"
    case carlton = "CAR"
    case collingwood = "COL"
    case essendon = "ESS"
    case fremantle = "FRE"
    case geelong = "GEE"
    case goldCoast = "GC"
    case gws = "GWS"
    case hawthorn = "HAW"
    case melbourne = "MEL"
    case northMelbourne = "NM"
    case portAdelaide = "PA"
    case richmond = "RIC"
    case stKilda = "STK"
    case sydney = "SYD"
    case westCoast = "WC"
    case westernBulldogs = "WB"
    
    var displayName: String {
        switch self {
        case .adelaide: return "Adelaide Crows"
        case .brisbane: return "Brisbane Lions"
        case .carlton: return "Carlton Blues"
        case .collingwood: return "Collingwood Magpies"
        case .essendon: return "Essendon Bombers"
        case .fremantle: return "Fremantle Dockers"
        case .geelong: return "Geelong Cats"
        case .goldCoast: return "Gold Coast Suns"
        case .gws: return "GWS Giants"
        case .hawthorn: return "Hawthorn Hawks"
        case .melbourne: return "Melbourne Demons"
        case .northMelbourne: return "North Melbourne Kangaroos"
        case .portAdelaide: return "Port Adelaide Power"
        case .richmond: return "Richmond Tigers"
        case .stKilda: return "St Kilda Saints"
        case .sydney: return "Sydney Swans"
        case .westCoast: return "West Coast Eagles"
        case .westernBulldogs: return "Western Bulldogs"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .adelaide: return .red
        case .brisbane: return .orange
        case .carlton: return .blue
        case .collingwood: return .black
        case .essendon: return .red
        case .fremantle: return .purple
        case .geelong: return .blue
        case .goldCoast: return .red
        case .gws: return .orange
        case .hawthorn: return .brown
        case .melbourne: return .red
        case .northMelbourne: return .blue
        case .portAdelaide: return .teal
        case .richmond: return .yellow
        case .stKilda: return .red
        case .sydney: return .red
        case .westCoast: return .blue
        case .westernBulldogs: return .blue
        }
    }
}

enum InjuryRisk: String, Codable, CaseIterable {
    case none = "none"
    case low = "low"
    case medium = "medium"
    case high = "high"
    case injured = "injured"
}

enum AlertFlag: String, Codable, CaseIterable {
    case priceRise = "price_rise"
    case priceDrop = "price_drop"
    case injuryWatch = "injury_watch"
    case formDrop = "form_drop"
    case breakoutCandidate = "breakout"
    case sellSignal = "sell_signal"
    case bargainBuy = "bargain_buy"
    
    var displayText: String {
        switch self {
        case .priceRise: return "Price Rising"
        case .priceDrop: return "Price Dropping"
        case .injuryWatch: return "Injury Watch"
        case .formDrop: return "Form Drop"
        case .breakoutCandidate: return "Breakout Candidate"
        case .sellSignal: return "Sell Signal"
        case .bargainBuy: return "Bargain Buy"
        }
    }
    
    var color: Color {
        switch self {
        case .priceRise, .breakoutCandidate, .bargainBuy: return .green
        case .priceDrop, .formDrop, .sellSignal: return .red
        case .injuryWatch: return .orange
        }
    }
}

// MARK: - Trade Models

struct TradeScenario: Identifiable, Codable {
    let id: UUID
    let playersOut: [EnhancedPlayer]
    let playersIn: [EnhancedPlayer]
    let costDifference: Int
    let projectedScoreGain: Double
    let confidence: Double
    let aiRecommendation: String
    let riskLevel: TradeRisk
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        playersOut: [EnhancedPlayer],
        playersIn: [EnhancedPlayer],
        costDifference: Int = 0,
        projectedScoreGain: Double = 0,
        confidence: Double = 0,
        aiRecommendation: String = "",
        riskLevel: TradeRisk = .medium,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.playersOut = playersOut
        self.playersIn = playersIn
        self.costDifference = costDifference
        self.projectedScoreGain = projectedScoreGain
        self.confidence = confidence
        self.aiRecommendation = aiRecommendation
        self.riskLevel = riskLevel
        self.createdAt = createdAt
    }
}

enum TradeRisk: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    var displayText: String {
        switch self {
        case .low: return "Low Risk"
        case .medium: return "Medium Risk"
        case .high: return "High Risk"
        }
    }
}

// MARK: - Captain Models

struct CaptainSuggestion: Identifiable, Codable {
    let id: UUID
    let player: EnhancedPlayer
    let confidence: Int
    let projectedPoints: Int
    let formRating: Double
    let fixtureRating: Double
    let opponent: String
    let venue: String
    let reasoning: String
    let riskFactors: [String]
    
    init(
        id: UUID = UUID(),
        player: EnhancedPlayer,
        confidence: Int,
        projectedPoints: Int,
        formRating: Double,
        fixtureRating: Double,
        opponent: String,
        venue: String = "",
        reasoning: String = "",
        riskFactors: [String] = []
    ) {
        self.id = id
        self.player = player
        self.confidence = confidence
        self.projectedPoints = projectedPoints
        self.formRating = formRating
        self.fixtureRating = fixtureRating
        self.opponent = opponent
        self.venue = venue
        self.reasoning = reasoning
        self.riskFactors = riskFactors
    }
}

// MARK: - Cash Cow Models

struct CashCowRecommendation: Identifiable, Codable {
    let id: UUID
    let playerName: String
    let currentPrice: Int
    let targetPrice: Int
    let cashGenerated: Int
    let projectedWeeks: Int
    let confidence: Double
    let sellUrgency: String
    let reasoning: String
    
    init(
        id: UUID = UUID(),
        playerName: String,
        currentPrice: Int,
        targetPrice: Int,
        cashGenerated: Int,
        projectedWeeks: Int,
        confidence: Double,
        sellUrgency: String,
        reasoning: String = ""
    ) {
        self.id = id
        self.playerName = playerName
        self.currentPrice = currentPrice
        self.targetPrice = targetPrice
        self.cashGenerated = cashGenerated
        self.projectedWeeks = projectedWeeks
        self.confidence = confidence
        self.sellUrgency = sellUrgency
        self.reasoning = reasoning
    }
}

// MARK: - Analytics Models

struct VenuePerformance: Identifiable, Codable {
    let id: UUID
    let venue: String
    let team: AFLTeam
    let averageScore: Double
    let gamesPlayed: Int
    let winRate: Double
    let scoreVariance: Double
    
    init(
        id: UUID = UUID(),
        venue: String,
        team: AFLTeam,
        averageScore: Double,
        gamesPlayed: Int,
        winRate: Double,
        scoreVariance: Double
    ) {
        self.id = id
        self.venue = venue
        self.team = team
        self.averageScore = averageScore
        self.gamesPlayed = gamesPlayed
        self.winRate = winRate
        self.scoreVariance = scoreVariance
    }
}

struct PriceProjection: Identifiable, Codable {
    let id: UUID
    let playerId: Int
    let currentPrice: Int
    let projectedPrices: [Int] // Next 8 weeks
    let confidence: Double
    let factors: [String]
    
    init(
        id: UUID = UUID(),
        playerId: Int,
        currentPrice: Int,
        projectedPrices: [Int],
        confidence: Double,
        factors: [String] = []
    ) {
        self.id = id
        self.playerId = playerId
        self.currentPrice = currentPrice
        self.projectedPrices = projectedPrices
        self.confidence = confidence
        self.factors = factors
    }
}

struct ConsistencyData: Identifiable, Codable {
    let id: UUID
    let playerId: Int
    let weeklyScores: [Int]
    let mean: Double
    let standardDeviation: Double
    let coefficientOfVariation: Double
    
    init(
        id: UUID = UUID(),
        playerId: Int,
        weeklyScores: [Int],
        mean: Double,
        standardDeviation: Double,
        coefficientOfVariation: Double
    ) {
        self.id = id
        self.playerId = playerId
        self.weeklyScores = weeklyScores
        self.mean = mean
        self.standardDeviation = standardDeviation
        self.coefficientOfVariation = coefficientOfVariation
    }
}

struct TeamAnalytics: Identifiable, Codable {
    let id: UUID
    let team: AFLTeam
    let averageScore: Double
    let defensiveRating: Double
    let offensiveRating: Double
    let homeAdvantage: Double
    let recentForm: [Int]
    
    init(
        id: UUID = UUID(),
        team: AFLTeam,
        averageScore: Double,
        defensiveRating: Double,
        offensiveRating: Double,
        homeAdvantage: Double,
        recentForm: [Int]
    ) {
        self.id = id
        self.team = team
        self.averageScore = averageScore
        self.defensiveRating = defensiveRating
        self.offensiveRating = offensiveRating
        self.homeAdvantage = homeAdvantage
        self.recentForm = recentForm
    }
}

// MARK: - App State Models

enum TabItem: String, CaseIterable {
    case dashboard = "dashboard"
    case trades = "trades"
    case captain = "captain"
    case cashCow = "cash_cow"
    case settings = "settings"
}

struct UserTeam: Codable {
    let teamId: String
    let teamName: String
    let players: [EnhancedPlayer]
    let totalValue: Int
    let bankBalance: Int
    let tradesRemaining: Int
    let overallRank: Int
    let weeklyScore: Int
    
    init(
        teamId: String = "",
        teamName: String = "",
        players: [EnhancedPlayer] = [],
        totalValue: Int = 0,
        bankBalance: Int = 0,
        tradesRemaining: Int = 2,
        overallRank: Int = 0,
        weeklyScore: Int = 0
    ) {
        self.teamId = teamId
        self.teamName = teamName
        self.players = players
        self.totalValue = totalValue
        self.bankBalance = bankBalance
        self.tradesRemaining = tradesRemaining
        self.overallRank = overallRank
        self.weeklyScore = weeklyScore
    }
}

// MARK: - API Response Models

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
    let timestamp: Date
    
    init(success: Bool, data: T? = nil, message: String? = nil, timestamp: Date = Date()) {
        self.success = success
        self.data = data
        self.message = message
        self.timestamp = timestamp
    }
}

struct LiveScoreUpdate: Codable {
    let playerId: Int
    let currentScore: Int
    let isPlaying: Bool
    let timeRemaining: String?
    let lastAction: String?
    let updated: Date
}

struct InjuryUpdate: Codable {
    let playerId: Int
    let injuryType: String
    let severity: InjuryRisk
    let estimatedReturn: String?
    let updated: Date
}

// MARK: - Error Models

enum AFLFantasyError: LocalizedError, Identifiable {
    case networkError(String)
    case dataError(String)
    case authenticationError
    case rateLimitExceeded
    case serverError(Int)
    case unknownError
    
    var id: String {
        switch self {
        case .networkError(let message): return "network_\(message)"
        case .dataError(let message): return "data_\(message)"
        case .authenticationError: return "auth_error"
        case .rateLimitExceeded: return "rate_limit"
        case .serverError(let code): return "server_\(code)"
        case .unknownError: return "unknown"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .dataError(let message):
            return "Data Error: \(message)"
        case .authenticationError:
            return "Authentication failed. Please log in again."
        case .rateLimitExceeded:
            return "Too many requests. Please try again later."
        case .serverError(let code):
            return "Server error (Code: \(code)). Please try again."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
