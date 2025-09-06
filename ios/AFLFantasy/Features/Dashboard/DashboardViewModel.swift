//
//  DashboardViewModel.swift
//  AFL Fantasy Intelligence Platform
//
//  ViewModel for the Core Intelligence Dashboard
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

// MARK: - DashboardViewModel

@MainActor
class DashboardViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isLoading = false
    @Published var isLive = true
    @Published var currentScore = 2145
    @Published var currentRank = 3247
    @Published var scoreChange = 87
    @Published var rankChange = -156
    @Published var projectedScore: Double = 1987
    @Published var teamValue = "$13.2M"
    @Published var bankBalance = "$145K"
    @Published var tradesRemaining = 8
    @Published var tradesUsed = 2
    @Published var cashCowCount = 4
    @Published var cashGenerationRate = "125K"
    @Published var riskLevel: RiskLevel = .medium
    @Published var winProbability: Double = 73
    @Published var expectedRank = 2854
    @Published var keyMatchups = "4"
    @Published var aiInsights: [AIInsight] = []
    @Published var criticalAlerts: [PlayerAlert] = []
    @Published var teamAnalysis: TeamAnalysis?

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private let dataService = AFLFantasyDataService()

    // MARK: - Initialization

    init() {
        setupData()
        setupBindings()
    }

    // MARK: - Public Methods

    func refresh() async {
        isLoading = true

        // Simulate API delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        await loadDashboardData()

        isLoading = false
    }

    func refreshLiveData() async {
        // Update live scores without loading state
        await loadLiveScores()
    }

    // MARK: - Private Methods

    private func setupData() {
        Task {
            await loadDashboardData()
        }
    }

    private func setupBindings() {
        // Listen to data service updates
        dataService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    Task {
                        await self?.loadDashboardData()
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func loadDashboardData() async {
        // Load AI insights
        aiInsights = generateAIInsights()

        // Load critical alerts
        criticalAlerts = generateCriticalAlerts()

        // Load team analysis
        teamAnalysis = generateTeamAnalysis()

        // Update live scores
        await loadLiveScores()
    }

    private func loadLiveScores() async {
        // Simulate live score updates with small variations
        let variation = Int.random(in: -10 ... 15)
        currentScore = max(1800, currentScore + variation)

        // Update projected score with some realism
        projectedScore = Double(currentScore) * 1.05 + Double.random(in: -50 ... 100)
    }

    private func generateAIInsights() -> [AIInsight] {
        [
            AIInsight(
                title: "Premium Breakout Alert",
                description: "Sam Walsh showing contract year motivation with 3 consecutive 120+ scores. Consider captaincy.",
                icon: "star.fill",
                color: .green
            ),
            AIInsight(
                title: "Price Drop Opportunity",
                description: "Max Gawn dropped $15k this week despite solid performance. Buy low window open.",
                icon: "arrow.down.circle",
                color: .blue
            ),
            AIInsight(
                title: "Weather Risk",
                description: "Heavy rain forecast for MCG games this round. Consider indoor venue players for captain.",
                icon: "cloud.rain.fill",
                color: .orange
            ),
            AIInsight(
                title: "Bye Round Preparation",
                description: "Round 12-14 bye coverage at 62%. Consider upgrading your bench strength soon.",
                icon: "calendar.badge.exclamationmark",
                color: .purple
            ),
            AIInsight(
                title: "Cash Cow Timing",
                description: "4 rookies approaching peak price. Optimal sell window opens in 2-3 rounds.",
                icon: "dollarsign.circle",
                color: .green
            )
        ]
    }

    private func generateCriticalAlerts() -> [PlayerAlert] {
        [
            PlayerAlert(
                type: .injuryUpdate,
                priority: .critical,
                title: "Connor Rozee",
                message: "Hamstring strain - Test to play Friday",
                actionable: true,
                created: Date().addingTimeInterval(-3600),
                expires: Date().addingTimeInterval(86400)
            ),
            PlayerAlert(
                type: .priceDrop,
                priority: .high,
                title: "Tim Taranto",
                message: "Price dropped $18k after poor performance",
                actionable: true,
                created: Date().addingTimeInterval(-1800),
                expires: nil
            ),
            PlayerAlert(
                type: .breakeven,
                priority: .high,
                title: "Hayden Young",
                message: "Breakeven cliff at 68 points - sell window closing",
                actionable: true,
                created: Date().addingTimeInterval(-7200),
                expires: Date().addingTimeInterval(172_800)
            ),
            PlayerAlert(
                type: .suspension,
                priority: .critical,
                title: "Toby Greene",
                message: "MRO charge - likely 1 week suspension",
                actionable: true,
                created: Date().addingTimeInterval(-900),
                expires: Date().addingTimeInterval(259_200)
            )
        ]
    }

    private func generateTeamAnalysis() -> TeamAnalysis {
        TeamAnalysis(
            totalValue: 13_200_000,
            bankBalance: 145_000,
            projectedScore: projectedScore,
            projectedRank: expectedRank,
            premiumCount: 12,
            cashCowCount: cashCowCount,
            positionDistribution: [
                .defender: TeamAnalysis.PositionAnalysis(
                    playerCount: 6,
                    totalValue: 3_100_000,
                    averageValue: 516_000,
                    leagueAverageValue: 485_000,
                    strengthRating: 85.2
                ),
                .midfielder: TeamAnalysis.PositionAnalysis(
                    playerCount: 8,
                    totalValue: 5_800_000,
                    averageValue: 725_000,
                    leagueAverageValue: 680_000,
                    strengthRating: 92.7
                ),
                .ruck: TeamAnalysis.PositionAnalysis(
                    playerCount: 2,
                    totalValue: 1_400_000,
                    averageValue: 700_000,
                    leagueAverageValue: 650_000,
                    strengthRating: 88.1
                ),
                .forward: TeamAnalysis.PositionAnalysis(
                    playerCount: 6,
                    totalValue: 2_900_000,
                    averageValue: 483_000,
                    leagueAverageValue: 520_000,
                    strengthRating: 78.4
                )
            ],
            byeRoundCoverage: [
                12: 18,
                13: 15,
                14: 19
            ],
            weakestPositions: [.forward],
            upgradeTargets: [],
            riskExposure: TeamAnalysis.RiskExposure(
                injuryRisk: 0.23,
                suspensionRisk: 0.08,
                priceDropRisk: 0.31,
                overallRisk: riskLevel
            )
        )
    }
}

// MARK: - AIInsight

struct AIInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
}
