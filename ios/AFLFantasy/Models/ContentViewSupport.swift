//
//  ContentViewSupport.swift
//  AFL Fantasy Intelligence Platform
//
//  Supporting types and extensions for ContentView
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import SwiftUI

// MARK: - AFLTeam

// AFLTeam enum for team management
enum AFLTeam: String, CaseIterable {
    case adelaide = "Adelaide"
    case brisbane = "Brisbane"
    case carlton = "Carlton"
    case collingwood = "Collingwood"
    case essendon = "Essendon"
    case fremantle = "Fremantle"
    case geelong = "Geelong"
    case goldCoast = "Gold Coast"
    case gws = "GWS Giants"
    case hawthorn = "Hawthorn"
    case melbourne = "Melbourne"
    case northMelbourne = "North Melbourne"
    case portAdelaide = "Port Adelaide"
    case richmond = "Richmond"
    case stKilda = "St Kilda"
    case sydney = "Sydney"
    case westCoast = "West Coast"
    case westernBulldogs = "Western Bulldogs"

    var emoji: String {
        switch self {
        case .adelaide: "🦅"
        case .brisbane: "🦁"
        case .carlton: "💙"
        case .collingwood: "🖤"
        case .essendon: "✈️"
        case .fremantle: "⚓"
        case .geelong: "🐱"
        case .goldCoast: "☀️"
        case .gws: "🧡"
        case .hawthorn: "🦅"
        case .melbourne: "😈"
        case .northMelbourne: "🦘"
        case .portAdelaide: "⚡"
        case .richmond: "🐅"
        case .stKilda: "⚡"
        case .sydney: "🦢"
        case .westCoast: "🦅"
        case .westernBulldogs: "🐕"
        }
    }
}

// Extended AlertType to match ContentView usage
extension AlertType {
    static let injury = AlertType.injuryRisk
    static let priceRise = AlertType.premiumBreakout
    static let breakeven = AlertType.breakEvenCliff
    static let captain = AlertType.premiumBreakout
    static let trade = AlertType.cashCowSell
    static let suspension = AlertType.roleChange
    static let teamChange = AlertType.roleChange
}

// Extended CaptainSuggestion for ContentView compatibility
extension CaptainSuggestion {
    var playerName: String {
        player.name
    }

    var position: String {
        player.position.rawValue
    }

    var opponent: String {
        player.nextRoundProjection.opponent
    }

    var projectedScore: Double {
        player.nextRoundProjection.projectedScore
    }

    var positionColor: Color {
        player.position.color
    }

    var formRating: Double {
        player.consistency
    }

    var fixtureRating: Double {
        Double(confidence) / 100.0
    }

    var riskFactor: Double {
        1.0 - (player.injuryRisk.riskScore / 10.0)
    }
}

// Extended InjuryRiskLevel for ContentView
extension InjuryRiskLevel {
    var color: Color {
        switch self {
        case .low: .green
        case .medium: .yellow
        case .high: .orange
        case .critical: .red
        }
    }
}

// Extended EnhancedPlayer for missing computed properties
extension EnhancedPlayer {
    var priceChangeText: String {
        let prefix = priceChange >= 0 ? "+" : ""
        return "\(prefix)\(priceChange)"
    }

    var consistencyGrade: String {
        switch consistency {
        case 0.9...: "A+"
        case 0.8 ..< 0.9: "A"
        case 0.7 ..< 0.8: "B"
        case 0.6 ..< 0.7: "C"
        default: "D"
        }
    }
}

// MARK: - View Extensions for Typography

extension Text {
    func typography(_ style: DesignSystem.Typography) -> some View {
        font(style.font)
    }
}

// MARK: - Missing View Types

struct TradeCalculatorView: View {
    @Binding var playerOut: EnhancedPlayer?
    @Binding var playerIn: EnhancedPlayer?
    let onPlayerOutTap: () -> Void
    let onPlayerInTap: () -> Void

    // Parameterless initializer for ContentView usage
    init() {
        _playerOut = .constant(nil)
        _playerIn = .constant(nil)
        onPlayerOutTap = {}
        onPlayerInTap = {}
    }

    // Full initializer for real usage
    init(
        playerOut: Binding<EnhancedPlayer?>,
        playerIn: Binding<EnhancedPlayer?>,
        onPlayerOutTap: @escaping () -> Void,
        onPlayerInTap: @escaping () -> Void
    ) {
        _playerOut = playerOut
        _playerIn = playerIn
        self.onPlayerOutTap = onPlayerOutTap
        self.onPlayerInTap = onPlayerInTap
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Trade Calculator")
                    .font(.title)
                    .padding()

                Text("Coming Soon")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .navigationTitle("🔄 Trades")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct CashCowView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Cash Cow Tracker")
                    .font(.title)
                    .padding()

                Text("Coming Soon")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .navigationTitle("💰 Cash Cow")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings")
                    .font(.title)
                    .padding()

                Text("Coming Soon")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .navigationTitle("⚙️ Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading AFL Fantasy Intelligence...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct OnboardingView: View {
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("🏆")
                .font(.system(size: 80))

            Text("Welcome to AFL Fantasy Intelligence")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)

            Text("Your AI-powered fantasy football companion")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button("Get Started") {
                onComplete()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - AppState Alias

typealias AppState = PersistentAppState

// MARK: - PersistentAppState

class PersistentAppState: ObservableObject {
    @Published var selectedTab: TabItem = .dashboard
    @Published var teamScore: Int = 1950
    @Published var teamRank: Int = 5432
    @Published var players: [EnhancedPlayer] = []
    @Published var captainSuggestions: [CaptainSuggestion] = []
    @Published var tradesUsed: Int = 2

    init() {
        // Initialize with sample data
        generateSampleData()
    }

    private func generateSampleData() {
        // Sample players
        let samplePlayers: [EnhancedPlayer] = [
            EnhancedPlayer(
                id: "1",
                name: "Marcus Bontempelli",
                position: .midfielder,
                price: 850_000,
                currentScore: 124,
                averageScore: 108.5,
                breakeven: 89,
                consistency: 0.85,
                highScore: 156,
                lowScore: 78,
                priceChange: 12000,
                isCashCow: false,
                isDoubtful: false,
                isSuspended: false,
                cashGenerated: 0,
                projectedPeakPrice: 900_000,
                nextRoundProjection: RoundProjection(
                    round: 10,
                    opponent: "Essendon",
                    venue: "Marvel Stadium",
                    projectedScore: 115.0,
                    confidence: 0.82,
                    conditions: WeatherConditions(temperature: 18, rainProbability: 0.2, windSpeed: 15, humidity: 65)
                ),
                seasonProjection: SeasonProjection(
                    projectedTotalScore: 2285,
                    projectedAverage: 108.8,
                    premiumPotential: 0.95
                ),
                injuryRisk: InjuryRisk(
                    riskLevel: .low,
                    riskScore: 2.1,
                    riskFactors: []
                ),
                venuePerformance: [],
                alertFlags: []
            ),
            EnhancedPlayer(
                id: "2",
                name: "Sam Darcy",
                position: .forward,
                price: 234_000,
                currentScore: 82,
                averageScore: 74.2,
                breakeven: 45,
                consistency: 0.68,
                highScore: 98,
                lowScore: 52,
                priceChange: 28000,
                isCashCow: true,
                isDoubtful: false,
                isSuspended: false,
                cashGenerated: 85000,
                projectedPeakPrice: 350_000,
                nextRoundProjection: RoundProjection(
                    round: 10,
                    opponent: "Richmond",
                    venue: "Marvel Stadium",
                    projectedScore: 78.0,
                    confidence: 0.71,
                    conditions: WeatherConditions(temperature: 16, rainProbability: 0.4, windSpeed: 12, humidity: 72)
                ),
                seasonProjection: SeasonProjection(
                    projectedTotalScore: 1563,
                    projectedAverage: 74.4,
                    premiumPotential: 0.82
                ),
                injuryRisk: InjuryRisk(
                    riskLevel: .medium,
                    riskScore: 4.5,
                    riskFactors: ["Youth", "Position change"]
                ),
                venuePerformance: [],
                alertFlags: [
                    AlertFlag(type: .cashCowSell, priority: .medium, message: "Price peaked - consider selling")
                ]
            )
        ]

        players = samplePlayers

        // Sample captain suggestions
        captainSuggestions = [
            CaptainSuggestion(player: samplePlayers[0], confidence: 85, projectedPoints: 115),
            CaptainSuggestion(player: samplePlayers[1], confidence: 71, projectedPoints: 78)
        ]
    }
}
