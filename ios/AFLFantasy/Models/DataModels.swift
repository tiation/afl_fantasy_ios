//
//  DataModels.swift
//  AFL Fantasy Intelligence Platform
//
//  Data models for AFL Fantasy API integration
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation

// MARK: - Player

/// Legacy Player model for test compatibility
struct Player: Identifiable, Codable {
    let id: String
    let name: String
    let position: Position
    let price: Int
    let currentScore: Int
    let projectedScore: Int
    let breakeven: Int

    var formattedPrice: String {
        String(format: "$%.1fk", Double(price) / 1000)
    }
}

// MARK: - AFLFantasyError

enum AFLFantasyError: LocalizedError, Equatable {
    case networkError(Error)
    case authenticationRequired
    case notAuthenticated
    case missingCredentials
    case dataParsingError(String)
    case invalidResponse
    case rateLimitExceeded
    case maintenanceMode
    case unknownError(String)

    var errorDescription: String? {
        switch self {
        case let .networkError(error):
            "Network error: \(error.localizedDescription)"
        case .authenticationRequired:
            "Authentication required. Please log in with your AFL Fantasy credentials."
        case .notAuthenticated:
            "You are not currently authenticated. Please log in."
        case .missingCredentials:
            "Missing AFL Fantasy credentials. Please check your login information."
        case let .dataParsingError(message):
            "Error parsing data: \(message)"
        case .invalidResponse:
            "Invalid response from AFL Fantasy servers."
        case .rateLimitExceeded:
            "Too many requests. Please wait before trying again."
        case .maintenanceMode:
            "AFL Fantasy is currently under maintenance."
        case let .unknownError(message):
            "Unknown error: \(message)"
        }
    }

    static func == (lhs: AFLFantasyError, rhs: AFLFantasyError) -> Bool {
        switch (lhs, rhs) {
        case (.authenticationRequired, .authenticationRequired),
             (.notAuthenticated, .notAuthenticated),
             (.missingCredentials, .missingCredentials),
             (.invalidResponse, .invalidResponse),
             (.rateLimitExceeded, .rateLimitExceeded),
             (.maintenanceMode, .maintenanceMode):
            true
        case let (.networkError(lhsError), .networkError(rhsError)):
            lhsError.localizedDescription == rhsError.localizedDescription
        case let (.dataParsingError(lhsMessage), .dataParsingError(rhsMessage)):
            lhsMessage == rhsMessage
        case let (.unknownError(lhsMessage), .unknownError(rhsMessage)):
            lhsMessage == rhsMessage
        default:
            false
        }
    }
}

// MARK: - DashboardData

struct DashboardData: Codable {
    let teamValue: TeamValueData
    let teamScore: TeamScoreData
    let overallRank: RankData
    let captain: CaptainData
    let lastUpdated: Date

    init(
        teamValue: TeamValueData,
        teamScore: TeamScoreData,
        overallRank: RankData,
        captain: CaptainData,
        lastUpdated: Date = Date()
    ) {
        self.teamValue = teamValue
        self.teamScore = teamScore
        self.overallRank = overallRank
        self.captain = captain
        self.lastUpdated = lastUpdated
    }

    // Backward compatibility properties
    var rank: RankData { overallRank }
}

// MARK: - TeamValueData

struct TeamValueData: Codable {
    let totalValue: Int
    let remainingSalary: Int
    let playerCount: Int

    init(totalValue: Int, remainingSalary: Int = 0, playerCount: Int = 0) {
        self.totalValue = totalValue
        self.remainingSalary = remainingSalary
        self.playerCount = playerCount
    }

    // Backward compatibility properties
    var teamValue: Double { Double(totalValue) }
    var bankBalance: Int { remainingSalary }
}

// MARK: - TeamScoreData

struct TeamScoreData: Codable {
    let totalScore: Int
    let captainScore: Int
    let changeFromLastRound: Int

    init(totalScore: Int, captainScore: Int = 0, changeFromLastRound: Int = 0) {
        self.totalScore = totalScore
        self.captainScore = captainScore
        self.changeFromLastRound = changeFromLastRound
    }

    // Backward compatibility properties
    var roundScore: Int { totalScore }
}

// MARK: - RankData

struct RankData: Codable {
    let currentRank: Int
    let changeFromLastRound: Int

    init(currentRank: Int, changeFromLastRound: Int = 0) {
        self.currentRank = currentRank
        self.changeFromLastRound = changeFromLastRound
    }

    // Backward compatibility properties
    var rank: Int { currentRank }
}

// MARK: - CaptainData

struct CaptainData: Codable {
    var playerName: String
    var score: Int
    var ownershipPercentage: Double

    init(playerName: String = "Unknown", score: Int = 0, ownershipPercentage: Double = 0.0) {
        self.playerName = playerName
        self.score = score
        self.ownershipPercentage = ownershipPercentage
    }

    // Backward compatibility
    struct Captain: Codable {
        let name: String
        let team: String
        let position: String
    }

    var captain: Captain {
        Captain(name: playerName, team: "Unknown", position: "Unknown")
    }

    var name: String { playerName }
}

// MARK: - Error conversion helper

extension AFLFantasyError {
    static func from(aflAPIError: AFLFantasyAPIClient.AFLAPIError) -> AFLFantasyError {
        switch aflAPIError {
        case .notAuthenticated:
            .notAuthenticated
        case let .networkError(error):
            .networkError(error)
        case let .dataParsingError(message):
            .dataParsingError(message)
        case .missingCredentials:
            .missingCredentials
        }
    }
}

// MARK: - AFLFantasyAPIClient Error Types

extension AFLFantasyAPIClient {
    enum AFLAPIError: LocalizedError {
        case notAuthenticated
        case networkError(Error)
        case dataParsingError(String)
        case missingCredentials

        var errorDescription: String? {
            switch self {
            case .notAuthenticated:
                "Not authenticated with AFL Fantasy"
            case let .networkError(error):
                "Network error: \(error.localizedDescription)"
            case let .dataParsingError(message):
                "Data parsing error: \(message)"
            case .missingCredentials:
                "Missing AFL Fantasy credentials"
            }
        }
    }
}

//
//  DataModels.swift
//  AFL Fantasy Intelligence Platform
//
//  Complete data models for AFL Fantasy services
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Dashboard Data Models

/// Main dashboard data container
struct DashboardData: Codable {
    let teamValue: TeamValueData
    let teamScore: TeamScoreData
    let overallRank: RankData
    var captain: CaptainData
    let lastUpdated: Date

    init(
        teamValue: TeamValueData = TeamValueData(totalValue: 0, remainingSalary: 0, playerCount: 0),
        teamScore: TeamScoreData = TeamScoreData(totalScore: 0, captainScore: 0, changeFromLastRound: 0),
        overallRank: RankData = RankData(currentRank: 0, changeFromLastRound: 0),
        captain: CaptainData = CaptainData(),
        lastUpdated: Date = Date()
    ) {
        self.teamValue = teamValue
        self.teamScore = teamScore
        self.overallRank = overallRank
        self.captain = captain
        self.lastUpdated = lastUpdated
    }
}

/// Team value information
struct TeamValueData: Codable {
    let totalValue: Int
    let remainingSalary: Int
    let playerCount: Int

    var teamValue: Double {
        Double(totalValue)
    }

    var formattedValue: String {
        "$\(String(format: "%.1f", Double(totalValue) / 1_000_000))M"
    }

    var formattedRemaining: String {
        "$\(remainingSalary / 1000)K"
    }
}

/// Team score information
struct TeamScoreData: Codable {
    let totalScore: Int
    let captainScore: Int
    let changeFromLastRound: Int
}

/// Rank information
struct RankData: Codable {
    let currentRank: Int
    let changeFromLastRound: Int

    var rank: Int {
        currentRank
    }

    var formattedRank: String {
        NumberFormatter.localizedString(from: NSNumber(value: currentRank), number: .decimal)
    }
}

/// Captain information
struct CaptainData: Codable {
    var playerName: String
    var score: Int
    var ownershipPercentage: Double
    var captain: Captain?

    init(
        playerName: String = "No Captain",
        score: Int = 0,
        ownershipPercentage: Double = 0.0,
        captain: Captain? = nil
    ) {
        self.playerName = playerName
        self.score = score
        self.ownershipPercentage = ownershipPercentage
        self.captain = captain
    }

    var formattedOwnership: String {
        "\(String(format: "%.1f", ownershipPercentage))% of teams"
    }

    /// Captain player details
    struct Captain: Codable {
        let name: String
        let team: String?
        let position: String?

        init(name: String = "Unknown", team: String? = nil, position: String? = nil) {
            self.name = name
            self.team = team
            self.position = position
        }
    }
}

// MARK: - Team Data Models

/// Team information
struct TeamData: Codable {
    let teamId: String
    let teamName: String
    let players: [Player]
    let totalValue: Double
    let remainingSalary: Double

    init(
        teamId: String = "",
        teamName: String = "My Team",
        players: [Player] = [],
        totalValue: Double = 0.0,
        remainingSalary: Double = 0.0
    ) {
        self.teamId = teamId
        self.teamName = teamName
        self.players = players
        self.totalValue = totalValue
        self.remainingSalary = remainingSalary
    }
}

/// Player information
struct Player: Codable, Identifiable {
    let id: String
    let name: String
    let team: String
    let position: PlayerPosition
    let price: Int
    let score: Int
    let average: Double

    init(
        id: String = UUID().uuidString,
        name: String,
        team: String,
        position: PlayerPosition,
        price: Int,
        score: Int = 0,
        average: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.team = team
        self.position = position
        self.price = price
        self.score = score
        self.average = average
    }
}

/// Player statistics
struct PlayerStats: Codable, Identifiable {
    let id: String
    let playerId: String
    let name: String
    let currentScore: Int
    let projectedScore: Double?
    let average: Double
    let lastUpdated: Date

    init(
        id: String = UUID().uuidString,
        playerId: String,
        name: String,
        currentScore: Int,
        projectedScore: Double? = nil,
        average: Double,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.playerId = playerId
        self.name = name
        self.currentScore = currentScore
        self.projectedScore = projectedScore
        self.average = average
        self.lastUpdated = lastUpdated
    }
}

/// Live scores information
struct LiveScores: Codable {
    let matchesInProgress: [Match]
    let lastUpdated: Date

    init(matchesInProgress: [Match] = [], lastUpdated: Date = Date()) {
        self.matchesInProgress = matchesInProgress
        self.lastUpdated = lastUpdated
    }

    /// Match information
    struct Match: Codable, Identifiable {
        let id: String
        let homeTeam: String
        let awayTeam: String
        let status: String

        init(id: String = UUID().uuidString, homeTeam: String, awayTeam: String, status: String) {
            self.id = id
            self.homeTeam = homeTeam
            self.awayTeam = awayTeam
            self.status = status
        }
    }
}

// MARK: - Player Position

/// Player positions
enum PlayerPosition: String, CaseIterable, Codable {
    case def = "DEF"
    case mid = "MID"
    case ruck = "RUC"
    case fwd = "FWD"

    var displayName: String {
        switch self {
        case .def: "Defender"
        case .mid: "Midfielder"
        case .ruck: "Ruck"
        case .fwd: "Forward"
        }
    }

    var color: Color {
        switch self {
        case .def: .blue
        case .mid: .green
        case .ruck: .purple
        case .fwd: .red
        }
    }
}

// MARK: - Captain Suggestion

/// Captain suggestion with analysis
struct CaptainSuggestion: Codable, Identifiable {
    let id = UUID()
    let player: EnhancedPlayer
    let confidence: Int
    let projectedPoints: Int

    // Computed properties for compatibility
    var name: String? { player.name }
    var playerName: String { player.name }
    var position: String { player.position.rawValue }
    var opponent: String { player.nextRoundProjection.opponent }
    var positionColor: Color { player.position.color }
    var projectedScore: Double { Double(projectedPoints) }
    var formRating: Double { player.consistency / 100.0 }
    var fixtureRating: Double { 0.8 } // Placeholder
    var riskFactor: Double { player.injuryRisk.riskScore }

    init(player: EnhancedPlayer, confidence: Int, projectedPoints: Int) {
        self.player = player
        self.confidence = confidence
        self.projectedPoints = projectedPoints
    }
}

// MARK: - AI Recommendation

/// AI recommendation data
struct AIRecommendation: Codable, Identifiable {
    let id = UUID()
    let type: String
    let title: String
    let description: String
    let priority: String
    let confidence: Double

    init(type: String, title: String, description: String, priority: String = "medium", confidence: Double = 0.8) {
        self.type = type
        self.title = title
        self.description = description
        self.priority = priority
        self.confidence = confidence
    }
}

/// Captain suggestion analysis
struct CaptainSuggestionAnalysis: Codable, Identifiable {
    let id = UUID()
    let player: Player
    let projectedScore: Double
    let confidence: Double
    let reasons: [String]

    init(player: Player, projectedScore: Double, confidence: Double, reasons: [String] = []) {
        self.player = player
        self.projectedScore = projectedScore
        self.confidence = confidence
        self.reasons = reasons
    }
}
