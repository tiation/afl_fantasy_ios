//
//  CaptainAdvisorViewModel.swift
//  AFL Fantasy Intelligence Platform
//
//  ViewModel for AI Captain Advisor
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - CaptainAdvisorViewModel

@MainActor
class CaptainAdvisorViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isLoading = false
    @Published var suggestions: [CaptainSuggestion] = []
    @Published var sortBy: SortOption = .confidence
    @Published var showingConfirmation = false
    @Published var selectedCaptainName = ""
    @Published var keyInsights: [String] = []
    @Published var highCeilingPlayers: [String] = []
    @Published var safeFloorPlayers: [String] = []
    @Published var differentialPlayers: [String] = []
    @Published var recentCaptainHistory: [CaptainHistory] = []

    // MARK: - Computed Properties

    var sortedSuggestions: [CaptainSuggestion] {
        switch sortBy {
        case .confidence:
            suggestions.sorted { $0.confidence > $1.confidence }
        case .projectedPoints:
            suggestions.sorted { $0.projectedPoints > $1.projectedPoints }
        case .ownership:
            suggestions.sorted { $0.ownership < $1.ownership } // Lower ownership first
        case .risk:
            suggestions.sorted { $0.player.riskLevel.rawValue < $1.player.riskLevel.rawValue }
        }
    }

    // MARK: - Private Properties

    private let dataService = AFLFantasyDataService()

    // MARK: - Initialization

    init() {
        loadData()
    }

    // MARK: - Public Methods

    func refresh() async {
        isLoading = true

        // Simulate API delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        loadData()

        isLoading = false
    }

    func setCaptain(_ player: AFLPlayer) {
        selectedCaptainName = player.name
        showingConfirmation = true

        // In a real app, this would make an API call
        // Task {
        //     try await dataService.setCaptain(player.id)
        // }
    }

    func getRank(for suggestion: CaptainSuggestion) -> Int {
        guard let index = sortedSuggestions.firstIndex(where: { $0.id == suggestion.id }) else { return 0 }
        return index + 1
    }

    // MARK: - Private Methods

    private func loadData() {
        suggestions = generateCaptainSuggestions()
        keyInsights = generateKeyInsights()
        highCeilingPlayers = ["Bontempelli", "Daicos"]
        safeFloorPlayers = ["Miller", "Cripps"]
        differentialPlayers = ["Butters", "Young"]
        recentCaptainHistory = generateCaptainHistory()
    }

    private func generateCaptainSuggestions() -> [CaptainSuggestion] {
        let players = createSamplePlayers()

        return players.map { player in
            CaptainSuggestion(
                player: player,
                confidence: Int.random(in: 65 ... 95),
                projectedPoints: Int.random(in: 140 ... 180),
                reasoning: generateReasoning(for: player),
                riskFactors: generateRiskFactors(for: player),
                upside: generateUpside(for: player),
                ownership: Double.random(in: 15.0 ... 55.0)
            )
        }
        .sorted { $0.confidence > $1.confidence }
    }

    private func createSamplePlayers() -> [AFLPlayer] {
        [
            createPlayer(
                name: "Marcus Bontempelli",
                position: .midfielder,
                team: .westernBulldogs,
                price: 850_000,
                averageScore: 118.5,
                consistency: 92.0
            ),
            createPlayer(
                name: "Nick Daicos",
                position: .midfielder,
                team: .collingwood,
                price: 720_000,
                averageScore: 115.2,
                consistency: 88.5
            ),
            createPlayer(
                name: "Touk Miller",
                position: .midfielder,
                team: .goldCoast,
                price: 720_000,
                averageScore: 108.8,
                consistency: 89.0
            ),
            createPlayer(
                name: "Patrick Cripps",
                position: .midfielder,
                team: .carlton,
                price: 780_000,
                averageScore: 112.4,
                consistency: 85.7
            ),
            createPlayer(
                name: "Jason Butters",
                position: .midfielder,
                team: .portAdelaide,
                price: 650_000,
                averageScore: 105.3,
                consistency: 82.1
            ),
            createPlayer(
                name: "Hayden Young",
                position: .defender,
                team: .fremantle,
                price: 580_000,
                averageScore: 95.4,
                consistency: 78.9
            )
        ]
    }

    private func createPlayer(
        name: String,
        position: PlayerPosition,
        team: AFLTeam,
        price: Int,
        averageScore: Double,
        consistency: Double
    ) -> AFLPlayer {
        AFLPlayer(
            id: UUID().uuidString,
            name: name,
            displayName: name,
            team: team,
            position: position,
            price: price,
            currentScore: Int.random(in: 80 ... 140),
            averageScore: averageScore,
            breakeven: Int.random(in: 60 ... 100),
            ownership: Double.random(in: 15.0 ... 55.0),
            projected: createProjection(),
            analytics: createAnalytics(consistency: consistency),
            alerts: [],
            updated: Date()
        )
    }

    private func createProjection() -> PlayerProjection {
        PlayerProjection(
            nextRound: PlayerProjection.RoundProjection(
                round: 15,
                opponent: .richmond,
                venue: "MCG",
                homeGame: Bool.random(),
                projectedScore: Double.random(in: 90 ... 130),
                confidence: Double.random(in: 0.7 ... 0.9),
                ceiling: Double.random(in: 140 ... 160),
                floor: Double.random(in: 70 ... 90),
                conditions: PlayerProjection.MatchConditions(
                    temperature: 18.0,
                    rainProbability: 0.2,
                    windSpeed: 12.0,
                    humidity: 65.0,
                    surfaceQuality: 0.85
                )
            ),
            next3Rounds: [],
            restOfSeason: PlayerProjection.SeasonProjection(
                totalPoints: Double.random(in: 1800 ... 2400),
                averagePoints: Double.random(in: 90 ... 120),
                gamesRemaining: 8,
                premiumPotential: Double.random(in: 0.7 ... 0.95),
                breakoutRisk: Double.random(in: 0.1 ... 0.3)
            ),
            priceProjection: PlayerProjection.PriceProjection(
                nextPrice: Int.random(in: 500_000 ... 900_000),
                peakPrice: Int.random(in: 600_000 ... 1_000_000),
                peakDate: Date().addingTimeInterval(Double.random(in: 0 ... 2_592_000)), // 0-30 days
                sellWindow: nil,
                priceVolatility: Double.random(in: 0.1 ... 0.4)
            ),
            captainScore: Double.random(in: 180 ... 240)
        )
    }

    private func createAnalytics(consistency: Double) -> PlayerAnalytics {
        PlayerAnalytics(
            consistency: consistency,
            volatility: Double.random(in: 0.15 ... 0.35),
            injuryRisk: Double.random(in: 0.05 ... 0.25),
            suspensionRisk: Double.random(in: 0.01 ... 0.1),
            priceChange: Int.random(in: -30000 ... 40000),
            cashGenerated: Int.random(in: 0 ... 150_000),
            venuePerformance: [],
            opponentPerformance: [],
            formTrend: PlayerAnalytics.FormTrend(
                last5Games: [
                    Int.random(in: 80 ... 130),
                    Int.random(in: 80 ... 130),
                    Int.random(in: 80 ... 130),
                    Int.random(in: 80 ... 130),
                    Int.random(in: 80 ... 130)
                ],
                trend: PlayerAnalytics.TrendDirection.allCases.randomElement() ?? .stable,
                momentum: Double.random(in: -0.2 ... 0.3)
            ),
            contractStatus: PlayerAnalytics.ContractStatus(
                yearRemaining: Int.random(in: 1 ... 4),
                contractYear: Bool.random(),
                motivationBonus: Double.random(in: 0.0 ... 0.15)
            )
        )
    }

    private func generateReasoning(for player: AFLPlayer) -> [String] {
        let reasoningPool = [
            "Excellent recent form with 3 consecutive 100+ scores",
            "Favorable matchup against weak midfield defense",
            "Strong venue record at MCG with +8.3 average bonus",
            "Low injury risk and full fitness confirmed",
            "Weather conditions favor outdoor play style",
            "Contract year motivation showing in performances",
            "Minimal tag threat from opposition",
            "High ceiling potential in favorable game script"
        ]

        return Array(reasoningPool.shuffled().prefix(Int.random(in: 2 ... 4)))
    }

    private func generateRiskFactors(for player: AFLPlayer) -> [String] {
        let riskPool = [
            "Tagged heavily in last matchup vs this opponent",
            "Weather forecast shows possible rain",
            "Coming off 5-day break",
            "Opponent has strong midfield defense",
            "Venue historically not favorable for this player"
        ]

        return Array(riskPool.shuffled().prefix(Int.random(in: 0 ... 2)))
    }

    private func generateUpside(for player: AFLPlayer) -> String {
        let upsidePool = [
            "Perfect conditions for explosive scoring",
            "Multiple ways to score with contested and uncontested possessions",
            "Goal scoring threat adds ceiling",
            "Proven performer in big games",
            "Fresh legs after managed minutes"
        ]

        return upsidePool.randomElement() ?? "Strong upside potential"
    }

    private func generateKeyInsights() -> [String] {
        [
            "MCG games historically produce 12% higher scores for midfielders",
            "Opposition allows 105+ to midfielders in 67% of games this season",
            "Weather forecast shows clear conditions - favor contested ball winners",
            "3 of top 5 options coming off season-high performances"
        ]
    }

    private func generateCaptainHistory() -> [CaptainHistory] {
        [
            CaptainHistory(round: 13, playerName: "M. Bontempelli", score: 142, averageScore: 118.5),
            CaptainHistory(round: 12, playerName: "N. Daicos", score: 98, averageScore: 115.2),
            CaptainHistory(round: 11, playerName: "T. Miller", score: 126, averageScore: 108.8),
            CaptainHistory(round: 10, playerName: "P. Cripps", score: 134, averageScore: 112.4),
            CaptainHistory(round: 9, playerName: "M. Bontempelli", score: 156, averageScore: 118.5)
        ]
    }
}

// MARK: - SortOption

enum SortOption: CaseIterable {
    case confidence
    case projectedPoints
    case ownership
    case risk
}

// MARK: - CaptainHistory

struct CaptainHistory {
    let round: Int
    let playerName: String
    let score: Int
    let averageScore: Double
}

// MARK: Equatable

extension CaptainHistory: Equatable {
    static func == (lhs: CaptainHistory, rhs: CaptainHistory) -> Bool {
        lhs.round == rhs.round && lhs.playerName == rhs.playerName
    }
}
