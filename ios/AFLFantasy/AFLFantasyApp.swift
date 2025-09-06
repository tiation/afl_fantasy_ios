//
//  AFLFantasyApp.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI
import UserNotifications

// MARK: - Position

// Position enum
enum Position: String, CaseIterable, Codable {
    case defender = "DEF"
    case midfielder = "MID"
    case ruck = "RUC"
    case forward = "FWD"

    var shortName: String {
        switch self {
        case .defender: "DEF"
        case .midfielder: "MID"
        case .ruck: "RUC"
        case .forward: "FWD"
        }
    }

    var color: Color {
        switch self {
        case .defender: .blue
        case .midfielder: .green
        case .ruck: .purple
        case .forward: .red
        }
    }
}

// MARK: - RoundProjection

// Supporting types for EnhancedPlayer
struct RoundProjection: Identifiable, Codable {
    let id = UUID()
    let round: Int
    let opponent: String
    let venue: String
    let projectedScore: Double
    let confidence: Double
    let conditions: WeatherConditions

    init(
        round: Int,
        opponent: String,
        venue: String,
        projectedScore: Double,
        confidence: Double,
        conditions: WeatherConditions
    ) {
        self.round = round
        self.opponent = opponent
        self.venue = venue
        self.projectedScore = projectedScore
        self.confidence = confidence
        self.conditions = conditions
    }
}

// MARK: - WeatherConditions

struct WeatherConditions: Codable {
    let temperature: Double
    let rainProbability: Double
    let windSpeed: Double
    let humidity: Double
}

// MARK: - SeasonProjection

struct SeasonProjection: Codable {
    let projectedTotalScore: Double
    let projectedAverage: Double
    let premiumPotential: Double
}

// MARK: - InjuryRisk

struct InjuryRisk: Codable {
    let riskLevel: InjuryRiskLevel
    let riskScore: Double
    let riskFactors: [String]
}

// MARK: - InjuryRiskLevel

enum InjuryRiskLevel: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"

    var color: Color {
        switch self {
        case .low: .green
        case .medium: .orange
        case .high: .red
        case .critical: .red
        }
    }
}

// MARK: - VenuePerformance

struct VenuePerformance: Identifiable, Codable {
    let id = UUID()
    let venue: String
    let gamesPlayed: Int
    let averageScore: Double
    let bias: Double

    init(venue: String, gamesPlayed: Int, averageScore: Double, bias: Double) {
        self.venue = venue
        self.gamesPlayed = gamesPlayed
        self.averageScore = averageScore
        self.bias = bias
    }
}

// MARK: - AlertFlag

struct AlertFlag: Identifiable, Codable {
    let id = UUID()
    let type: AlertType
    let priority: AlertPriority
    let message: String

    init(type: AlertType, priority: AlertPriority, message: String) {
        self.type = type
        self.priority = priority
        self.message = message
    }
}

// MARK: - AlertType

enum AlertType: String, CaseIterable, Codable {
    case injury
    case priceRise
    case priceDrop
    case breakeven
    case captain
    case trade
    case suspension
    case teamChange
    case breakEvenCliff
    case cashCowSell
    case injuryRisk
    case roleChange
    case weatherRisk
    case contractYear
    case premiumBreakout
}

// MARK: - AlertPriority

enum AlertPriority: String, CaseIterable, Codable {
    case critical
    case high
    case medium
    case low
}

// MARK: - EnhancedPlayer

// EnhancedPlayer model
struct EnhancedPlayer: Identifiable, Codable {
    let id: String
    let name: String
    let position: Position
    let price: Int
    let currentScore: Int
    let averageScore: Double
    let breakeven: Int
    let consistency: Double
    let highScore: Int
    let lowScore: Int
    let priceChange: Int
    let isCashCow: Bool
    let isDoubtful: Bool
    let isSuspended: Bool
    let cashGenerated: Int
    let projectedPeakPrice: Int
    let nextRoundProjection: RoundProjection
    let seasonProjection: SeasonProjection
    let injuryRisk: InjuryRisk
    let venuePerformance: [VenuePerformance]
    let alertFlags: [AlertFlag]

    // Computed property for projected score
    var projectedScore: Double {
        nextRoundProjection.projectedScore
    }

    var formattedPrice: String {
        String(format: "$%.1fk", Double(price) / 1000)
    }

    var consistencyGrade: String {
        switch consistency {
        case 90 ... 100: "A+"
        case 80 ..< 90: "A"
        case 70 ..< 80: "B+"
        case 60 ..< 70: "B"
        case 50 ..< 60: "C+"
        case 40 ..< 50: "C"
        default: "D"
        }
    }

    var priceChangeText: String {
        let changeK = Double(priceChange) / 1000
        if priceChange > 0 {
            return "+$\(String(format: "%.1f", changeK))k"
        } else if priceChange < 0 {
            return "-$\(String(format: "%.1f", abs(changeK)))k"
        } else {
            return "$0.0k"
        }
    }
}

// MARK: - CaptainSuggestion

// CaptainSuggestion model
struct CaptainSuggestion: Identifiable, Codable {
    let id = UUID()
    let player: EnhancedPlayer
    let confidence: Int
    let projectedPoints: Int

    init(player: EnhancedPlayer, confidence: Int, projectedPoints: Int) {
        self.player = player
        self.confidence = confidence
        self.projectedPoints = projectedPoints
    }

    // Additional properties for ContentView compatibility
    var playerName: String {
        player.name
    }

    var position: String {
        player.position.rawValue
    }

    var opponent: String {
        player.nextRoundProjection.opponent
    }

    var positionColor: Color {
        player.position.color
    }

    var projectedScore: Double {
        player.projectedScore
    }

    var formRating: Double {
        player.consistency / 100.0
    }

    var fixtureRating: Double {
        0.8 // Simulated fixture rating
    }

    var riskFactor: Double {
        player.injuryRisk.riskScore
    }
}

// MARK: - TradeRecord

// TradeRecord model
struct TradeRecord: Identifiable, Codable {
    let id: UUID
    let playerOut: EnhancedPlayer
    let playerIn: EnhancedPlayer
    let executedAt: Date
    let netCost: Int
    let projectedImpact: Double

    init(
        id: UUID = UUID(),
        playerOut: EnhancedPlayer,
        playerIn: EnhancedPlayer,
        executedAt: Date,
        netCost: Int,
        projectedImpact: Double
    ) {
        self.id = id
        self.playerOut = playerOut
        self.playerIn = playerIn
        self.executedAt = executedAt
        self.netCost = netCost
        self.projectedImpact = projectedImpact
    }
}

// MARK: - AFLTeam

enum AFLTeam: String, CaseIterable, Codable {
    case adelaide = "Adelaide"
    case brisbane = "Brisbane"
    case carlton = "Carlton"
    case collingwood = "Collingwood"
    case essendon = "Essendon"
    case fremantle = "Fremantle"
    case geelong = "Geelong"
    case goldCoast = "Gold Coast"
    case gws = "GWS"
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
        case .adelaide: "🔴"
        case .brisbane: "🦁"
        case .carlton: "🔵"
        case .collingwood: "⚫"
        case .essendon: "🔴"
        case .fremantle: "⚓"
        case .geelong: "🐱"
        case .goldCoast: "☀️"
        case .gws: "🧡"
        case .hawthorn: "🦅"
        case .melbourne: "😈"
        case .northMelbourne: "🦘"
        case .portAdelaide: "⚡"
        case .richmond: "🐅"
        case .stKilda: "👼"
        case .sydney: "🦢"
        case .westCoast: "🦅"
        case .westernBulldogs: "🐕"
        }
    }
}

// MARK: - AFLFantasyApp

@main
struct AFLFantasyApp: App {
    // MARK: - State Objects

    @StateObject private var dataService = AFLFantasyDataService()
    @StateObject private var appState = AppState()
    @StateObject private var keychainManager = KeychainManager()
    @StateObject private var audioManager = AFLAudioManager()
    @StateObject private var hapticsManager = AFLHapticsManager()
    @State private var showOnboarding = false
    @State private var hasCheckedOnboarding = false

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasCheckedOnboarding {
                    // Show loading state while checking onboarding status
                    LoadingView()
                } else if showOnboarding {
                    // Show onboarding flow
                    OnboardingView {
                        showOnboarding = false
                        setupApp()
                    }
                } else {
                    // Show main app
                    SimpleContentView()
                        .environmentObject(dataService)
                        .environmentObject(appState)
                        .environmentObject(audioManager)
                        .environmentObject(hapticsManager)
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                checkOnboardingStatus()
            }
        }
    }

    // MARK: - Setup

    private func checkOnboardingStatus() {
        // Check if user needs onboarding
        showOnboarding = keychainManager.needsOnboarding()
        hasCheckedOnboarding = true

        // Setup app if not showing onboarding
        if !showOnboarding {
            setupApp()
        }
    }

    private func setupApp() {
        // Configure any app-level settings here
        print("🚀 AFL Fantasy Intelligence Platform started")

        // Load user preferences
        if let userName = keychainManager.getUserName() {
            print("👋 Welcome back, \(userName)!")
        }

        if let favoriteTeam = keychainManager.getFavoriteTeam() {
            print("🏈 Go \(favoriteTeam)!")
        }
        
        // Trigger AFL experience launch
        Task {
            await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            await MainActor.run {
                audioManager.onAppLaunch()
                hapticsManager.onAppLaunch()
            }
        }

        // Debug information
        #if DEBUG
            print("📱 Running in DEBUG mode")
            if dataService.authenticated {
                print("✅ User is authenticated")
            } else {
                print("❌ User not authenticated")
            }
        #endif
    }
}

// MARK: - AppState

// AppState type alias for compatibility
typealias PersistentAppState = AppState

// MARK: - AppState

@MainActor
class AppState: ObservableObject {
    @Published var selectedTab: TabItem = .dashboard
    @Published var teamScore: Int = 1987
    @Published var teamRank: Int = 5432
    @Published var players: [EnhancedPlayer] = []
    @Published var captainSuggestions: [CaptainSuggestion] = []
    @Published var cashCows: [EnhancedPlayer] = []

    // Trade management
    @Published var tradesUsed: Int = 2
    @Published var tradesRemaining: Int = 8
    @Published var tradeHistory: [TradeRecord] = []

    // Team financials
    @Published var teamValue: Int = 12_000_000
    @Published var bankBalance: Int = 300_000

    // Connection and sync
    @Published var isRefreshing: Bool = false
    @Published var lastUpdateTime: Date? = Date()
    @Published var errorMessage: String?

    init() {
        loadEnhancedData()
        generateCaptainSuggestions()
    }

    private func loadEnhancedData() {
        players = createSamplePlayers()
        cashCows = players.filter(\.isCashCow)
    }

    private func createSamplePlayers() -> [EnhancedPlayer] {
        let samplePlayers = [
            createPremiumMidfielder(),
            createPremiumRuck(),
            createConsistentMidfielder(),
            createCashCowDefender(),
            createContractYearMidfielder()
        ]
        return samplePlayers
    }

    private func createPremiumMidfielder() -> EnhancedPlayer {
        EnhancedPlayer(
            id: UUID().uuidString,
            name: "Marcus Bontempelli",
            position: .midfielder,
            price: 850_000,
            currentScore: 125,
            averageScore: 118.5,
            breakeven: 85,
            consistency: 92.0,
            highScore: 156,
            lowScore: 85,
            priceChange: 25000,
            isCashCow: false,
            isDoubtful: false,
            isSuspended: false,
            cashGenerated: 0,
            projectedPeakPrice: 900_000,
            nextRoundProjection: RoundProjection(
                round: 15,
                opponent: "Richmond",
                venue: "Marvel Stadium",
                projectedScore: 130.0,
                confidence: 0.85,
                conditions: WeatherConditions(temperature: 18.0, rainProbability: 0.2, windSpeed: 12.0, humidity: 65.0)
            ),
            seasonProjection: SeasonProjection(
                projectedTotalScore: 2368.0,
                projectedAverage: 118.4,
                premiumPotential: 0.92
            ),
            injuryRisk: InjuryRisk(
                riskLevel: .low,
                riskScore: 0.15,
                riskFactors: []
            ),
            venuePerformance: [
                VenuePerformance(venue: "Marvel Stadium", gamesPlayed: 8, averageScore: 122.3, bias: 3.5)
            ],
            alertFlags: []
        )
    }

    private func createPremiumRuck() -> EnhancedPlayer {
        EnhancedPlayer(
            id: UUID().uuidString,
            name: "Max Gawn",
            position: .ruck,
            price: 780_000,
            currentScore: 98,
            averageScore: 105.2,
            breakeven: 90,
            consistency: 88.0,
            highScore: 135,
            lowScore: 68,
            priceChange: -15000,
            isCashCow: false,
            isDoubtful: true,
            isSuspended: false,
            cashGenerated: 0,
            projectedPeakPrice: 800_000,
            nextRoundProjection: RoundProjection(
                round: 15,
                opponent: "Collingwood",
                venue: "MCG",
                projectedScore: 105.0,
                confidence: 0.78,
                conditions: WeatherConditions(temperature: 16.0, rainProbability: 0.1, windSpeed: 8.0, humidity: 58.0)
            ),
            seasonProjection: SeasonProjection(
                projectedTotalScore: 2104.0,
                projectedAverage: 105.2,
                premiumPotential: 0.88
            ),
            injuryRisk: InjuryRisk(
                riskLevel: .medium,
                riskScore: 0.35,
                riskFactors: ["Previous knee injury", "Heavy ruck load"]
            ),
            venuePerformance: [
                VenuePerformance(venue: "MCG", gamesPlayed: 12, averageScore: 107.3, bias: 2.0)
            ],
            alertFlags: [
                AlertFlag(type: .injuryRisk, priority: .medium, message: "Monitor knee condition")
            ]
        )
    }

    private func createConsistentMidfielder() -> EnhancedPlayer {
        EnhancedPlayer(
            id: UUID().uuidString,
            name: "Touk Miller",
            position: .midfielder,
            price: 720_000,
            currentScore: 110,
            averageScore: 108.8,
            breakeven: 75,
            consistency: 89.0,
            highScore: 132,
            lowScore: 88,
            priceChange: 20000,
            isCashCow: false,
            isDoubtful: false,
            isSuspended: false,
            cashGenerated: 0,
            projectedPeakPrice: 740_000,
            nextRoundProjection: RoundProjection(
                round: 15,
                opponent: "Geelong",
                venue: "GMHBA Stadium",
                projectedScore: 115.0,
                confidence: 0.82,
                conditions: WeatherConditions(temperature: 14.0, rainProbability: 0.4, windSpeed: 18.0, humidity: 75.0)
            ),
            seasonProjection: SeasonProjection(
                projectedTotalScore: 2176.0,
                projectedAverage: 108.8,
                premiumPotential: 0.89
            ),
            injuryRisk: InjuryRisk(
                riskLevel: .low,
                riskScore: 0.12,
                riskFactors: []
            ),
            venuePerformance: [
                VenuePerformance(venue: "GMHBA Stadium", gamesPlayed: 6, averageScore: 103.2, bias: -1.5)
            ],
            alertFlags: [
                AlertFlag(
                    type: .premiumBreakout,
                    priority: .high,
                    message: "Contract year motivation - monitor performance"
                )
            ]
        )
    }

    private func createCashCowDefender() -> EnhancedPlayer {
        EnhancedPlayer(
            id: UUID().uuidString,
            name: "Hayden Young",
            position: .defender,
            price: 550_000,
            currentScore: 78,
            averageScore: 85.2,
            breakeven: 45,
            consistency: 76.0,
            highScore: 98,
            lowScore: 62,
            priceChange: 35000,
            isCashCow: true,
            isDoubtful: false,
            isSuspended: false,
            cashGenerated: 120_000,
            projectedPeakPrice: 620_000,
            nextRoundProjection: RoundProjection(
                round: 15,
                opponent: "Sydney",
                venue: "Optus Stadium",
                projectedScore: 88.0,
                confidence: 0.74,
                conditions: WeatherConditions(temperature: 20.0, rainProbability: 0.0, windSpeed: 22.0, humidity: 45.0)
            ),
            seasonProjection: SeasonProjection(
                projectedTotalScore: 1704.0,
                projectedAverage: 85.2,
                premiumPotential: 0.76
            ),
            injuryRisk: InjuryRisk(
                riskLevel: .low,
                riskScore: 0.14,
                riskFactors: []
            ),
            venuePerformance: [
                VenuePerformance(venue: "Optus Stadium", gamesPlayed: 5, averageScore: 89.4, bias: 4.2)
            ],
            alertFlags: [
                AlertFlag(
                    type: .cashCowSell,
                    priority: .high,
                    message: "Cash cow approaching peak price - consider selling soon"
                )
            ]
        )
    }

    private func createContractYearMidfielder() -> EnhancedPlayer {
        EnhancedPlayer(
            id: UUID().uuidString,
            name: "Sam Walsh",
            position: .midfielder,
            price: 750_000,
            currentScore: 115,
            averageScore: 112.4,
            breakeven: 80,
            consistency: 87.0,
            highScore: 145,
            lowScore: 92,
            priceChange: 30000,
            isCashCow: false,
            isDoubtful: false,
            isSuspended: false,
            cashGenerated: 0,
            projectedPeakPrice: 780_000,
            nextRoundProjection: RoundProjection(
                round: 15,
                opponent: "Hawthorn",
                venue: "MCG",
                projectedScore: 118.0,
                confidence: 0.80,
                conditions: WeatherConditions(temperature: 15.0, rainProbability: 0.3, windSpeed: 15.0, humidity: 68.0)
            ),
            seasonProjection: SeasonProjection(
                projectedTotalScore: 2248.0,
                projectedAverage: 112.4,
                premiumPotential: 0.87
            ),
            injuryRisk: InjuryRisk(
                riskLevel: .low,
                riskScore: 0.18,
                riskFactors: ["Minor shoulder concern"]
            ),
            venuePerformance: [
                VenuePerformance(venue: "MCG", gamesPlayed: 9, averageScore: 115.1, bias: 1.8)
            ],
            alertFlags: [
                AlertFlag(type: .contractYear, priority: .high, message: "Contract year - motivated for strong finish")
            ]
        )
    }

    private func generateCaptainSuggestions() {
        let topPlayers = players.sorted { $0.averageScore > $1.averageScore }.prefix(3)

        captainSuggestions = topPlayers.enumerated().map { index, player in
            let confidence = Int(90 - Double(index) * 5 + player.consistency * 0.1)
            let projectedPoints = Int(player.projectedScore * 2 + Double.random(in: -10 ... 10))

            return CaptainSuggestion(
                player: player,
                confidence: confidence,
                projectedPoints: projectedPoints
            )
        }
    }

    // MARK: - Public Methods

    func refreshData() {
        Task {
            await MainActor.run {
                isRefreshing = true
                errorMessage = nil
            }

            // Simulate API call
            try? await Task.sleep(nanoseconds: 2_000_000_000)

            await MainActor.run {
                isRefreshing = false
                lastUpdateTime = Date()

                // Update some sample data
                teamScore = Int.random(in: 1800 ... 2200)
                teamRank = Int.random(in: 1000 ... 15000)
            }
        }
    }

    func simulateError(_ message: String) {
        errorMessage = message
    }

    func clearError() {
        errorMessage = nil
    }
}

// MARK: - LoadingView

struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.orange, .red]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "football.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                Text("AFL Fantasy Intelligence")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - OnboardingView

struct OnboardingView: View {
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundColor(.white)

                Text("Welcome to AFL Fantasy Intelligence")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Get AI-powered insights and analysis to dominate your fantasy league")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                Button("Get Started") {
                    onComplete()
                }
                .font(.headline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.white)
                .cornerRadius(12)
                .padding(.horizontal, 40)

                Spacer()
            }
        }
    }
}

// MARK: - SimpleContentView

struct SimpleContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            SimpleTradeCalculatorView()
                .tabItem {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Trades")
                }
                .tag(TabItem.trades)

            SimpleDashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(TabItem.dashboard)

            SimpleCaptainView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Captain")
                }
                .tag(TabItem.captain)

            SimpleCashCowView()
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Cash Cow")
                }
                .tag(TabItem.cashCow)

            SimpleSettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(TabItem.settings)
        }
        .accentColor(.orange)
    }
}

// MARK: - SimpleDashboardView

struct SimpleDashboardView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Team Score Header
                    VStack {
                        Text("Team Score: \(appState.teamScore)")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Rank: #\(appState.teamRank)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Players List
                    LazyVStack(spacing: 12) {
                        ForEach(appState.players) { player in
                            SimplePlayerCard(player: player)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("🏆 Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - SimplePlayerCard

struct SimplePlayerCard: View {
    let player: EnhancedPlayer

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(player.name)
                        .font(.headline)
                    Text(player.position.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("\(player.currentScore)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text(player.formattedPrice)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

// MARK: - SimpleCaptainView

struct SimpleCaptainView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Text("🧠 AI Captain Advisor")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()

                    ForEach(appState.captainSuggestions) { suggestion in
                        SimpleCaptainCard(suggestion: suggestion)
                    }
                }
                .padding()
            }
            .navigationTitle("⭐ Captain AI")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - SimpleCaptainCard

struct SimpleCaptainCard: View {
    let suggestion: CaptainSuggestion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(suggestion.player.name)
                    .font(.headline)

                Spacer()

                Text("\(suggestion.confidence)%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }

            Text("Projected: \(suggestion.projectedPoints) pts")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

// MARK: - SimpleTradeCalculatorView

struct SimpleTradeCalculatorView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("🔄 Trade Calculator")
                    .font(.title2)
                    .fontWeight(.bold)
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

// MARK: - SimpleCashCowView

struct SimpleCashCowView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("💰 Cash Cow Tracker")
                    .font(.title2)
                    .fontWeight(.bold)
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

// MARK: - SimpleSettingsView

struct SimpleSettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("⚙️ Settings")
                    .font(.title2)
                    .fontWeight(.bold)
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

// MARK: - AFLFantasyTabView

struct AFLFantasyTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Text("Advanced TabView Coming Soon")
            .font(.title)
            .foregroundColor(.orange)
    }
}

struct AlertCenterView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "bell.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .padding()
                
                Text("⚠️ Smart Alert System")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                Text("AI Alert Generator proactively warns you about price drop risks, breakeven cliffs, and potential cash cows before the market moves.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Text("Coming Soon")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }
            .navigationTitle("⚠️ Alert Center")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct AnalysisCenterView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                        
                        Text("📊 Advanced Analysis")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Deep dive analytics and contextual player analysis")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Analysis Categories
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        AnalysisCategoryCard(
                            title: "Cash Generation",
                            subtitle: "Price Analytics",
                            icon: "dollarsign.circle.fill",
                            color: .green,
                            description: "Track cash cow potential and optimal sell windows"
                        )
                        
                        AnalysisCategoryCard(
                            title: "Venue Bias",
                            subtitle: "Ground Analysis",
                            icon: "location.fill",
                            color: .blue,
                            description: "Player performance by venue and conditions"
                        )
                        
                        AnalysisCategoryCard(
                            title: "Consistency Scores",
                            subtitle: "Reliability Metrics",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .orange,
                            description: "How reliably players hit projected scores"
                        )
                        
                        AnalysisCategoryCard(
                            title: "Risk Assessment",
                            subtitle: "Injury & Suspension",
                            icon: "exclamationmark.triangle.fill",
                            color: .red,
                            description: "Algorithmic risk scoring for smart decisions"
                        )
                        
                        AnalysisCategoryCard(
                            title: "Fixture Analysis",
                            subtitle: "Upcoming Difficulty",
                            icon: "calendar.circle.fill",
                            color: .purple,
                            description: "5-round fixture difficulty ratings"
                        )
                        
                        AnalysisCategoryCard(
                            title: "Weather Impact",
                            subtitle: "Conditions Model",
                            icon: "cloud.rain.fill",
                            color: .gray,
                            description: "Performance adjustments for rain and wind"
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("📊 Analysis")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct AnalysisCategoryCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

