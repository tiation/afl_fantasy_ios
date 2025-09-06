//
//  AFLFantasyApp.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI
import UserNotifications

@main
struct AFLFantasyApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark) // Dark mode first design
                .onAppear {
                    requestNotificationPermissions()
                }
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Notification permissions granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - App State Management
@MainActor
class AppState: ObservableObject {
    @Published var selectedTab: TabItem = .dashboard
    @Published var teamScore: Int = 0
    @Published var teamRank: Int = 0
    @Published var isLoading: Bool = false
    
    // Mock data for MVP
    @Published var players: [Player] = []
    @Published var captainSuggestions: [CaptainSuggestion] = []
    @Published var cashCows: [Player] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        // Load mock AFL players for MVP
        players = [
            Player(id: "1", name: "Marcus Bontempelli", position: .midfielder, price: 850000, currentScore: 125, projectedScore: 130, breakeven: 85),
            Player(id: "2", name: "Max Gawn", position: .ruck, price: 780000, currentScore: 98, projectedScore: 105, breakeven: 90),
            Player(id: "3", name: "Touk Miller", position: .midfielder, price: 720000, currentScore: 110, projectedScore: 115, breakeven: 75),
            Player(id: "4", name: "Jeremy Cameron", position: .forward, price: 680000, currentScore: 95, projectedScore: 100, breakeven: 80),
            Player(id: "5", name: "Nick Daicos", position: .defender, price: 620000, currentScore: 85, projectedScore: 95, breakeven: 70)
        ]
        
        captainSuggestions = [
            CaptainSuggestion(player: players[0], confidence: 92, projectedPoints: 260),
            CaptainSuggestion(player: players[2], confidence: 88, projectedPoints: 230),
            CaptainSuggestion(player: players[1], confidence: 85, projectedPoints: 210)
        ]
        
        cashCows = players.filter { $0.price < 700000 }
    }
}

// MARK: - Models
struct Player: Identifiable, Codable {
    let id: String
    let name: String
    let position: Position
    let price: Int
    let currentScore: Int
    let projectedScore: Int
    let breakeven: Int
    
    var formattedPrice: String {
        return "$\(price / 1000)k"
    }
}

struct CaptainSuggestion: Identifiable {
    let id = UUID()
    let player: Player
    let confidence: Int
    let projectedPoints: Int
}

enum Position: String, CaseIterable, Codable {
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
}

enum TabItem: String, CaseIterable {
    case dashboard = "Dashboard"
    case captain = "Captain"
    case trades = "Trades"
    case cashCow = "Cash Cow"
    case settings = "Settings"
    
    var systemImage: String {
        switch self {
        case .dashboard: return "chart.line.uptrend.xyaxis"
        case .captain: return "star.fill"
        case .trades: return "arrow.triangle.2.circlepath"
        case .cashCow: return "dollarsign.circle.fill"
        case .settings: return "gearshape.fill"
        }
    }
}
