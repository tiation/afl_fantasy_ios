//
//  MissingTypes.swift
//  AFL Fantasy Intelligence Platform
//
//  Additional type definitions and extensions to support the app
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import SwiftUI

// MARK: - DesignSystem

enum DesignSystem {
    enum Colors {
        static let defender: Color = .blue
        static let midfielder: Color = .green
        static let ruck: Color = .purple
        static let forward: Color = .red
    }

    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
}

// MARK: - OfflineAlert

/// Offline alert types
enum OfflineAlert: String, CaseIterable {
    case dataOutdated
    case connectionLost
    case syncFailed

    var title: String {
        switch self {
        case .dataOutdated: "Data Outdated"
        case .connectionLost: "Connection Lost"
        case .syncFailed: "Sync Failed"
        }
    }

    var message: String {
        switch self {
        case .dataOutdated: "Your data may be outdated. Connect to the internet to refresh."
        case .connectionLost: "Internet connection lost. Some features may be limited."
        case .syncFailed: "Failed to sync data. Please try again later."
        }
    }
}

// MARK: - DataFreshness

/// Data freshness levels
enum DataFreshness {
    case fresh
    case stale
    case expired
}

// MARK: - OfflineDataType

/// Data types for offline management
enum OfflineDataType {
    case dashboardData
    case playerStats
    case teamData
    case captainSuggestions
}

// MARK: - AFLFantasyRepositoryProtocol

protocol AFLFantasyRepositoryProtocol {
    func fetchTeamData() async throws -> TeamData
    func fetchPlayerStats() async throws -> [PlayerStats]
    func fetchLiveScores() async throws -> LiveScores
}

// MARK: - PersistenceManagerProtocol

protocol PersistenceManagerProtocol {
    func getCachedTeamData() async throws -> TeamData?
    func cacheTeamData(_ data: TeamData) async throws
    func getCachedPlayerStats() async throws -> [PlayerStats]?
    func cachePlayerStats(_ data: [PlayerStats]) async throws
    func getCachedLiveScores() async throws -> LiveScores?
    func cacheLiveScores(_ data: LiveScores) async throws
}

// MARK: - AFLFantasyRepository

/// Simple AFL Fantasy repository implementation
class AFLFantasyRepository: AFLFantasyRepositoryProtocol {
    static let shared = AFLFantasyRepository()
    private init() {}

    func fetchTeamData() async throws -> TeamData {
        // Stub implementation
        TeamData()
    }

    func fetchPlayerStats() async throws -> [PlayerStats] {
        // Stub implementation
        []
    }

    func fetchLiveScores() async throws -> LiveScores {
        // Stub implementation
        LiveScores()
    }
}

// MARK: - PersistenceManager

/// Simple persistence manager implementation
class PersistenceManager: PersistenceManagerProtocol {
    static let shared = PersistenceManager()
    private init() {}

    func getCachedTeamData() async throws -> TeamData? {
        nil
    }

    func cacheTeamData(_ data: TeamData) async throws {
        // Stub implementation
    }

    func getCachedPlayerStats() async throws -> [PlayerStats]? {
        nil
    }

    func cachePlayerStats(_ data: [PlayerStats]) async throws {
        // Stub implementation
    }

    func getCachedLiveScores() async throws -> LiveScores? {
        nil
    }

    func cacheLiveScores(_ data: LiveScores) async throws {
        // Stub implementation
    }
}

// MARK: - OfflineManager

@MainActor
class OfflineManager: ObservableObject {
    @Published var isOnline: Bool = true
    static let shared = OfflineManager()

    private init() {}

    func getDataFreshness(for dataType: OfflineDataType) async -> DataFreshness {
        .fresh // Stub implementation
    }
}

// MARK: - AFLLogger

enum AFLLogger {
    enum Category {
        case general

        var logger: AFLLoggerType {
            AFLLoggerType()
        }
    }

    static func info(_ message: String, category: Category) {
        print("[INFO] \(message)")
    }

    static func debug(_ message: String, category: Category) {
        print("[DEBUG] \(message)")
    }

    static func warning(_ message: String, category: Category) {
        print("[WARNING] \(message)")
    }

    static func error(_ message: String, category: Category) {
        print("[ERROR] \(message)")
    }
}

// MARK: - AFLLoggerType

struct AFLLoggerType {
    func log(_ message: String) {
        print(message)
    }
}

// MARK: - PerformanceMeasurement

class PerformanceMeasurement {
    private let name: String
    private let startTime: Date

    init(_ name: String) {
        self.name = name
        startTime = Date()
    }

    func finish() {
        let duration = Date().timeIntervalSince(startTime)
        print("[PERF] \(name): \(String(format: "%.3f", duration))s")
    }
}

// MARK: - View Modifiers

extension View {
    func withOfflineStatus() -> some View {
        self // Stub implementation
    }

    func offlineAlert(isPresented: Binding<Bool>, alert: OfflineAlert) -> some View {
        self.alert(
            alert.title,
            isPresented: isPresented,
            actions: {
                Button("OK") {}
            },
            message: {
                Text(alert.message)
            }
        )
    }
}
