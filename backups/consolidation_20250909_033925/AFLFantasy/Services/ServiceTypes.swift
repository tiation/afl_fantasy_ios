import Combine
import Foundation

// MARK: - AFLFantasyScraperServiceProtocol

// Note: Main service implementations are in their dedicated files:
// - AFLFantasyScraperService.swift
// - KeychainService.swift
// - DataSyncManager.swift
// This file only contains protocol definitions to avoid circular imports

protocol AFLFantasyScraperServiceProtocol {
    func refreshAllData() async throws -> ScraperResult
}

// MARK: - KeychainServiceProtocol

protocol KeychainServiceProtocol {
    func store(_ data: Data, forKey key: String) throws
    func retrieve(forKey key: String) throws -> Data?
    func delete(forKey key: String) throws
}

// MARK: - DataSyncManagerProtocol

protocol DataSyncManagerProtocol {
    func syncData() async throws
    var isSyncing: Bool { get }
    var lastSyncDate: Date? { get }
}

// MARK: - PlayerData

// These are lightweight data models that don't conflict with main models

struct PlayerData: Codable, Equatable {
    let id: String
    let name: String
    let team: String
    let position: String
    let price: Int
    let averageScore: Double
}

// MARK: - TeamData
// Note: TeamData is now defined in DataModels.swift to avoid conflicts
