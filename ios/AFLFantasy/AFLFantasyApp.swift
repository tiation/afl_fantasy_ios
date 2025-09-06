//
//  AFLFantasyApp.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import CoreData
import os.log
import SwiftUI
import UserNotifications

// MARK: - NotificationManager

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    func scheduleCaptainSuggestion(_ suggestion: CaptainSuggestion) async {
        let content = UNMutableNotificationContent()
        content.title = "Captain Suggestion"
        content.body = "Consider \(suggestion.player.name) for captain - \(suggestion.confidence)% confidence"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "captain-\(suggestion.player.id)",
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    func scheduleRoundLockoutReminder(round: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Round Lockout Soon!"
        content.body = "Round \(round) locks out in 1 hour. Check your team!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "lockout-\(round)", content: content, trigger: trigger)

        try? await UNUserNotificationCenter.current().add(request)
    }

    func schedulePlayerAlert(_ alert: AlertFlag, for player: EnhancedPlayer) async {
        let content = UNMutableNotificationContent()
        content.title = "Player Alert"
        content.body = "\(player.name): \(alert.message)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)
        let request = UNNotificationRequest(
            identifier: "alert-\(player.id)-\(alert.type.rawValue)",
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    func scheduleInjuryAlert(for player: EnhancedPlayer) async {
        let content = UNMutableNotificationContent()
        content.title = "Injury Risk Alert"
        content.body = "\(player.name) has \(player.injuryRisk.riskLevel.rawValue.lowercased()) injury risk"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)
        let request = UNNotificationRequest(identifier: "injury-\(player.id)", content: content, trigger: trigger)

        try? await UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - NotificationDelegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func setupWithApp(_ app: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("Notification tapped: \(response.notification.request.identifier)")
        completionHandler()
    }
}

// MARK: - AFLFantasyApp

@main
struct AFLFantasyApp: App {
    @StateObject private var appState = AppState()
    private let notificationDelegate = NotificationDelegate()

    // Core Data Stack (inline for simplicity)
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AFLFantasy")
        container.loadPersistentStores { _, error in
            if let error {
                print("Core Data error: \(error.localizedDescription)")
            } else {
                print("Core Data loaded successfully")
            }
        }
        return container
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environment(\.managedObjectContext, persistentContainer.viewContext)
                .preferredColorScheme(.dark)
                .onAppear {
                    // Setup notifications when app launches
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let app = windowScene.delegate as? UIApplicationDelegate
                    {
                        notificationDelegate.setupWithApp(UIApplication.shared)
                    }

                    // Schedule some demo notifications for testing
                    Task {
                        await scheduleDemoNotifications()
                    }
                }
        }
    }

    // MARK: - Demo Notifications

    private func scheduleDemoNotifications() async {
        let notificationManager = NotificationManager.shared

        // Request authorization first
        _ = await notificationManager.requestAuthorization()

        // Schedule demo notifications for the first few players
        if !appState.players.isEmpty {
            // Demo captain suggestion
            if let captainSuggestion = appState.captainSuggestions.first {
                await notificationManager.scheduleCaptainSuggestion(captainSuggestion)
            }
        }

        // Schedule a lockout reminder
        await notificationManager.scheduleRoundLockoutReminder(round: 15)

        // Schedule alerts for players with alert flags
        for player in appState.players {
            for alert in player.alertFlags {
                await notificationManager.schedulePlayerAlert(alert, for: player)
            }

            // Schedule injury alerts for high-risk players
            if player.injuryRisk.riskLevel == .moderate || player.injuryRisk.riskLevel == .high {
                await notificationManager.scheduleInjuryAlert(for: player)
            }
        }
    }
}

// MARK: - AppState

// Note: PersistentAppState is now the primary state management class
// This AppState is kept for backward compatibility if needed

@MainActor
class AppState: ObservableObject {
    @Published var selectedTab: TabItem = .dashboard
    @Published var teamScore: Int = 1987
    @Published var teamRank: Int = 5432
    @Published var players: [EnhancedPlayer] = []
    @Published var captainSuggestions: [CaptainSuggestion] = []
    @Published var cashCows: [EnhancedPlayer] = []

    init() {
        loadEnhancedData()
        generateCaptainSuggestions()
    }

    private func loadEnhancedData() {
        players = [
            EnhancedPlayer(
                id: "1",
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
                projectedPeakPrice: 0,
                nextRoundProjection: RoundProjection(
                    round: 15,
                    opponent: "Richmond",
                    venue: "Marvel Stadium",
                    projectedScore: 130.0,
                    confidence: 0.88,
                    conditions: WeatherConditions(
                        temperature: 18.0,
                        rainProbability: 0.2,
                        windSpeed: 15.0,
                        humidity: 65.0
                    )
                ),
                seasonProjection: SeasonProjection(
                    projectedTotalScore: 2370.0,
                    projectedAverage: 118.5,
                    premiumPotential: 0.95
                ),
                injuryRisk: InjuryRisk(
                    riskLevel: .low,
                    riskScore: 0.15,
                    riskFactors: []
                ),
                venuePerformance: [
                    VenuePerformance(venue: "Marvel Stadium", gamesPlayed: 6, averageScore: 125.2, bias: 6.7),
                    VenuePerformance(venue: "MCG", gamesPlayed: 4, averageScore: 112.8, bias: -5.7)
                ],
                alertFlags: []
            ),
            EnhancedPlayer(
                id: "2",
                name: "Max Gawn",
                position: .ruck,
                price: 780_000,
                currentScore: 98,
                averageScore: 105.2,
                breakeven: 90,
                consistency: 88.0,
                highScore: 144,
                lowScore: 65,
                priceChange: -15000,
                isCashCow: false,
                isDoubtful: true,
                isSuspended: false,
                cashGenerated: 0,
                projectedPeakPrice: 0,
                nextRoundProjection: RoundProjection(
                    round: 15,
                    opponent: "Collingwood",
                    venue: "MCG",
                    projectedScore: 105.0,
                    confidence: 0.75,
                    conditions: WeatherConditions(
                        temperature: 14.0,
                        rainProbability: 0.1,
                        windSpeed: 20.0,
                        humidity: 70.0
                    )
                ),
                seasonProjection: SeasonProjection(
                    projectedTotalScore: 2104.0,
                    projectedAverage: 105.2,
                    premiumPotential: 0.88
                ),
                injuryRisk: InjuryRisk(
                    riskLevel: .moderate,
                    riskScore: 0.35,
                    riskFactors: ["Knee soreness", "Age concern"]
                ),
                venuePerformance: [
                    VenuePerformance(venue: "MCG", gamesPlayed: 8, averageScore: 108.5, bias: 3.3),
                    VenuePerformance(venue: "Marvel Stadium", gamesPlayed: 2, averageScore: 98.0, bias: -7.2)
                ],
                alertFlags: [
                    AlertFlag(type: .injuryRisk, priority: .high, message: "Knee soreness reported at training")
                ]
            ),
            EnhancedPlayer(
                id: "3",
                name: "Touk Miller",
                position: .midfielder,
                price: 720_000,
                currentScore: 110,
                averageScore: 108.8,
                breakeven: 75,
                consistency: 89.0,
                highScore: 141,
                lowScore: 78,
                priceChange: 20000,
                isCashCow: false,
                isDoubtful: false,
                isSuspended: false,
                cashGenerated: 0,
                projectedPeakPrice: 0,
                nextRoundProjection: RoundProjection(
                    round: 15,
                    opponent: "Geelong",
                    venue: "GMHBA Stadium",
                    projectedScore: 115.0,
                    confidence: 0.82,
                    conditions: WeatherConditions(
                        temperature: 16.0,
                        rainProbability: 0.4,
                        windSpeed: 25.0,
                        humidity: 68.0
                    )
                ),
                seasonProjection: SeasonProjection(
                    projectedTotalScore: 2176.0,
                    projectedAverage: 108.8,
                    premiumPotential: 0.91
                ),
                injuryRisk: InjuryRisk(
                    riskLevel: .low,
                    riskScore: 0.12,
                    riskFactors: []
                ),
                venuePerformance: [
                    VenuePerformance(venue: "GMHBA Stadium", gamesPlayed: 3, averageScore: 118.7, bias: 9.9),
                    VenuePerformance(venue: "Gabba", gamesPlayed: 5, averageScore: 105.2, bias: -3.6)
                ],
                alertFlags: [
                    AlertFlag(type: .contractYear, priority: .medium, message: "Contract year motivation boost")
                ]
            ),
            EnhancedPlayer(
                id: "4",
                name: "Hayden Young",
                position: .defender,
                price: 550_000,
                currentScore: 78,
                averageScore: 85.2,
                breakeven: 45,
                consistency: 76.0,
                highScore: 112,
                lowScore: 45,
                priceChange: 35000,
                isCashCow: true,
                isDoubtful: false,
                isSuspended: false,
                cashGenerated: 120_000,
                projectedPeakPrice: 680_000,
                nextRoundProjection: RoundProjection(
                    round: 15,
                    opponent: "Sydney",
                    venue: "Optus Stadium",
                    projectedScore: 88.0,
                    confidence: 0.78,
                    conditions: WeatherConditions(
                        temperature: 22.0,
                        rainProbability: 0.0,
                        windSpeed: 12.0,
                        humidity: 55.0
                    )
                ),
                seasonProjection: SeasonProjection(
                    projectedTotalScore: 1704.0,
                    projectedAverage: 85.2,
                    premiumPotential: 0.65
                ),
                injuryRisk: InjuryRisk(
                    riskLevel: .low,
                    riskScore: 0.14,
                    riskFactors: []
                ),
                venuePerformance: [
                    VenuePerformance(venue: "Optus Stadium", gamesPlayed: 6, averageScore: 89.4, bias: 4.2),
                    VenuePerformance(venue: "MCG", gamesPlayed: 2, averageScore: 75.5, bias: -9.7)
                ],
                alertFlags: [
                    AlertFlag(type: .cashCowSell, priority: .high, message: "Approaching breakeven - consider selling")
                ]
            ),
            EnhancedPlayer(
                id: "5",
                name: "Sam Walsh",
                position: .midfielder,
                price: 750_000,
                currentScore: 115,
                averageScore: 112.4,
                breakeven: 80,
                consistency: 87.0,
                highScore: 148,
                lowScore: 82,
                priceChange: 30000,
                isCashCow: false,
                isDoubtful: false,
                isSuspended: false,
                cashGenerated: 0,
                projectedPeakPrice: 0,
                nextRoundProjection: RoundProjection(
                    round: 15,
                    opponent: "Hawthorn",
                    venue: "MCG",
                    projectedScore: 118.0,
                    confidence: 0.85,
                    conditions: WeatherConditions(
                        temperature: 15.0,
                        rainProbability: 0.3,
                        windSpeed: 18.0,
                        humidity: 72.0
                    )
                ),
                seasonProjection: SeasonProjection(
                    projectedTotalScore: 2248.0,
                    projectedAverage: 112.4,
                    premiumPotential: 0.93
                ),
                injuryRisk: InjuryRisk(
                    riskLevel: .low,
                    riskScore: 0.18,
                    riskFactors: []
                ),
                venuePerformance: [
                    VenuePerformance(venue: "MCG", gamesPlayed: 5, averageScore: 116.2, bias: 3.8),
                    VenuePerformance(venue: "Marvel Stadium", gamesPlayed: 3, averageScore: 106.7, bias: -5.7)
                ],
                alertFlags: [
                    AlertFlag(type: .contractYear, priority: .low, message: "Contract year - extra motivation expected")
                ]
            )
        ]

        cashCows = players.filter(\.isCashCow)
    }

    private func generateCaptainSuggestions() {
        let topPlayers = players.sorted { $0.averageScore > $1.averageScore }.prefix(3)

        captainSuggestions = topPlayers.enumerated().map { index, player in
            let confidence = Int(90 - Double(index) * 5 + player.consistency * 0.1)
            let projectedPoints = Int(player.nextRoundProjection.projectedScore * 2 + Double.random(in: -10 ... 10))

            return CaptainSuggestion(
                player: player,
                confidence: confidence,
                projectedPoints: projectedPoints
            )
        }
    }
}

// MARK: - EnhancedPlayer

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

    var formattedPrice: String {
        "$\(price / 1000)k"
    }

    var priceChangeText: String {
        let prefix = priceChange >= 0 ? "+" : ""
        return "\(prefix)\(priceChange / 1000)k"
    }

    var consistencyGrade: String {
        switch consistency {
        case 90...: "A+"
        case 80 ..< 90: "A"
        case 70 ..< 80: "B"
        case 60 ..< 70: "C"
        default: "D"
        }
    }
}

// MARK: - RoundProjection

struct RoundProjection: Codable {
    let round: Int
    let opponent: String
    let venue: String
    let projectedScore: Double
    let confidence: Double
    let conditions: WeatherConditions
}

// MARK: - SeasonProjection

struct SeasonProjection: Codable {
    let projectedTotalScore: Double
    let projectedAverage: Double
    let premiumPotential: Double
}

// MARK: - InjuryRisk

struct InjuryRisk: Codable {
    let riskLevel: RiskLevel
    let riskScore: Double
    let riskFactors: [String]
}

// MARK: - RiskLevel

enum RiskLevel: String, Codable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case extreme = "Extreme"

    var color: Color {
        switch self {
        case .low: .green
        case .moderate: .yellow
        case .high: .orange
        case .extreme: .red
        }
    }
}

// MARK: - VenuePerformance

struct VenuePerformance: Codable {
    let venue: String
    let gamesPlayed: Int
    let averageScore: Double
    let bias: Double
}

// MARK: - AlertFlag

struct AlertFlag: Codable {
    let type: AlertType
    let priority: AlertPriority
    let message: String
}

// MARK: - AlertType

enum AlertType: String, Codable {
    case priceDrop = "Price Drop"
    case breakEvenCliff = "Breakeven Cliff"
    case cashCowSell = "Cash Cow Sell"
    case injuryRisk = "Injury Risk"
    case roleChange = "Role Change"
    case weatherRisk = "Weather Risk"
    case contractYear = "Contract Year"
    case premiumBreakout = "Premium Breakout"
}

// MARK: - AlertPriority

enum AlertPriority: String, Codable {
    case critical = "Critical"
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}

// MARK: - WeatherConditions

struct WeatherConditions: Codable {
    let temperature: Double
    let rainProbability: Double
    let windSpeed: Double
    let humidity: Double
}

// MARK: - CaptainSuggestion

struct CaptainSuggestion: Identifiable {
    let id = UUID()
    let player: EnhancedPlayer
    let confidence: Int
    let projectedPoints: Int
}

// MARK: - ConnectionStatusBar

struct ConnectionStatusBar: View {
    @State private var connectionStatus: ConnectionStatus = .live
    @State private var animateConnection = false

    var body: some View {
        HStack {
            Image(systemName: connectionStatus.systemImage)
                .foregroundColor(connectionStatus.color)
                .scaleEffect(animateConnection ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: animateConnection)

            Text(connectionStatus.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(connectionStatus.color)

            Spacer()

            Text("Last updated: now")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(connectionStatus.color.opacity(0.1))
        )
        .onAppear {
            animateConnection = connectionStatus == .live
        }
    }
}

// MARK: - DesignSystem

enum DesignSystem {
    enum Colors {
        static let primary = Color.orange
        static let onSurfaceSecondary = Color.secondary
        static let success = Color.green
    }

    enum Spacing {
        case s, m, l, xl

        var value: CGFloat {
            switch self {
            case .s: 8
            case .m: 16
            case .l: 24
            case .xl: 32
            }
        }
    }
}

// MARK: - TypographyModifier

struct TypographyModifier: ViewModifier {
    let style: Font.TextStyle

    func body(content: Content) -> some View {
        content
            .font(.system(style))
    }
}

extension View {
    func typography(_ style: Font.TextStyle) -> some View {
        modifier(TypographyModifier(style: style))
    }
}

// MARK: - Position

enum Position: String, CaseIterable, Codable {
    case defender = "DEF"
    case midfielder = "MID"
    case ruck = "RUC"
    case forward = "FWD"

    var color: Color {
        switch self {
        case .defender: .blue
        case .midfielder: .green
        case .ruck: .purple
        case .forward: .red
        }
    }
}

// MARK: - ConnectionStatus

enum ConnectionStatus: String, CaseIterable {
    case disconnected = "Disconnected"
    case connecting = "Connecting"
    case connected = "Connected"
    case live = "Live"
    case error = "Error"

    var color: Color {
        switch self {
        case .disconnected: .gray
        case .connecting: .orange
        case .connected: .green
        case .live: .red
        case .error: .red
        }
    }

    var systemImage: String {
        switch self {
        case .disconnected: "wifi.slash"
        case .connecting: "wifi.exclamationmark"
        case .connected: "wifi"
        case .live: "dot.radiowaves.left.and.right"
        case .error: "exclamationmark.triangle"
        }
    }
}

// MARK: - TabItem

enum TabItem: String, CaseIterable {
    case dashboard = "Dashboard"
    case captain = "Captain"
    case trades = "Trades"
    case cashCow = "Cash Cow"
    case settings = "Settings"

    var systemImage: String {
        switch self {
        case .dashboard: "chart.line.uptrend.xyaxis"
        case .captain: "star.fill"
        case .trades: "arrow.triangle.2.circlepath"
        case .cashCow: "dollarsign.circle.fill"
        case .settings: "gearshape.fill"
        }
    }
}
