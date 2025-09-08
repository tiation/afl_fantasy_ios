//
//  PersistenceManager.swift
//  AFL Fantasy Intelligence Platform
//
//  CoreData persistence with stale-while-revalidate caching
//  Created by AI Assistant on 6/9/2025.
//

import CoreData
import Foundation
import os.log

// MARK: - CachePolicy

enum CachePolicy {
    case liveData(maxAge: TimeInterval = 60) // 60s for live data
    case staticData(maxAge: TimeInterval = 600) // 10min for static data
    case playerStats(maxAge: TimeInterval = 300) // 5min for player stats
    case fixtures(maxAge: TimeInterval = 3600) // 1hour for fixtures

    var maxAge: TimeInterval {
        switch self {
        case let .liveData(age), let .staticData(age), let .playerStats(age), let .fixtures(age):
            age
        }
    }

    var identifier: String {
        switch self {
        case .liveData: "live"
        case .staticData: "static"
        case .playerStats: "players"
        case .fixtures: "fixtures"
        }
    }
}

// MARK: - PersistenceManager

@MainActor
final class PersistenceManager: ObservableObject {
    static let shared = PersistenceManager()

    private let logger = AFLLogger.Category.persistence.logger
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    // Cache metadata tracking
    private var cacheMetadata: [String: CacheEntry] = [:]

    private init() {
        // Initialize Core Data stack
        container = NSPersistentContainer(name: "AFLFantasyDataModel")

        // Configure container for performance
        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores { [weak self] _, error in
            if let error {
                AFLLogger.fault("Failed to load Core Data stack: \(error.localizedDescription)", category: .persistence)
                fatalError("Core Data failed to initialize: \(error)")
            }

            AFLLogger.info("Core Data stack loaded successfully", category: .persistence)
        }

        context = container.viewContext
        context.automaticallyMergesChangesFromParent = true

        // Setup periodic cleanup
        setupPeriodicCleanup()
    }

    // MARK: - Generic Caching Methods

    func cache(_ data: some Codable, for key: String, policy: CachePolicy) async throws {
        let measurement = PerformanceMeasurement("Cache data for key: \(key)")
        defer { measurement.finish() }

        let cachedData = CachedDataEntity(context: context)
        cachedData.key = key
        cachedData.data = try JSONEncoder().encode(data)
        cachedData.timestamp = Date()
        cachedData.policyIdentifier = policy.identifier
        cachedData.maxAge = policy.maxAge

        // Update metadata
        cacheMetadata[key] = CacheEntry(timestamp: Date(), policy: policy)

        try await saveContext()
        AFLLogger.debug("Cached data for key: \(key)", category: .persistence)
    }

    func retrieve<T: Codable>(_ type: T.Type, for key: String, policy: CachePolicy) async throws -> T? {
        let measurement = PerformanceMeasurement("Retrieve cached data for key: \(key)")
        defer { measurement.finish() }

        let request: NSFetchRequest<CachedDataEntity> = CachedDataEntity.fetchRequest()
        request.predicate = NSPredicate(format: "key == %@", key)
        request.fetchLimit = 1

        let results = try context.fetch(request)

        guard let cachedEntity = results.first else {
            AFLLogger.debug("No cached data found for key: \(key)", category: .persistence)
            return nil
        }

        // Check if data is stale
        let age = Date().timeIntervalSince(cachedEntity.timestamp ?? Date.distantPast)
        if age > policy.maxAge {
            AFLLogger.info(
                "Cached data for key \(key) is stale (age: \(age)s, maxAge: \(policy.maxAge)s)",
                category: .persistence
            )
            // Return stale data but mark for refresh (stale-while-revalidate)
        }

        guard let data = cachedEntity.data else {
            throw PersistenceError.corruptedData
        }

        let decoded = try JSONDecoder().decode(type, from: data)
        AFLLogger.debug("Retrieved cached data for key: \(key)", category: .persistence)
        return decoded
    }

    func isCacheValid(for key: String, policy: CachePolicy) async -> Bool {
        guard let entry = cacheMetadata[key] else { return false }
        let age = Date().timeIntervalSince(entry.timestamp)
        return age <= policy.maxAge
    }

    func invalidateCache(for key: String) async throws {
        let request: NSFetchRequest<CachedDataEntity> = CachedDataEntity.fetchRequest()
        request.predicate = NSPredicate(format: "key == %@", key)

        let results = try context.fetch(request)
        for entity in results {
            context.delete(entity)
        }

        cacheMetadata.removeValue(forKey: key)
        try await saveContext()
        AFLLogger.info("Invalidated cache for key: \(key)", category: .persistence)
    }

    func clearExpiredCache() async throws {
        let measurement = PerformanceMeasurement("Clear expired cache entries")
        defer { measurement.finish() }

        let request: NSFetchRequest<CachedDataEntity> = CachedDataEntity.fetchRequest()
        let results = try context.fetch(request)

        var expiredCount = 0

        for entity in results {
            let maxAge = entity.maxAge
            let age = Date().timeIntervalSince(entity.timestamp ?? Date.distantPast)

            if age > maxAge {
                context.delete(entity)
                if let key = entity.key {
                    cacheMetadata.removeValue(forKey: key)
                }
                expiredCount += 1
            }
        }

        if expiredCount > 0 {
            try await saveContext()
            AFLLogger.info("Cleared \(expiredCount) expired cache entries", category: .persistence)
        }
    }

    // MARK: - Specialized Data Methods

    func cachePlayerStats(_ players: [PlayerStats]) async throws {
        try await cache(players, for: "player_stats", policy: .playerStats())
    }

    func getCachedPlayerStats() async throws -> [PlayerStats]? {
        try await retrieve([PlayerStats].self, for: "player_stats", policy: .playerStats())
    }

    func cacheTeamData(_ teamData: TeamData) async throws {
        try await cache(teamData, for: "team_data", policy: .liveData())
    }

    func getCachedTeamData() async throws -> TeamData? {
        try await retrieve(TeamData.self, for: "team_data", policy: .liveData())
    }

    func cacheLiveScores(_ liveScores: LiveScores) async throws {
        try await cache(liveScores, for: "live_scores", policy: .liveData(maxAge: 30)) // 30s for live scores
    }

    func getCachedLiveScores() async throws -> LiveScores? {
        try await retrieve(LiveScores.self, for: "live_scores", policy: .liveData(maxAge: 30))
    }

    func cacheFixtures(_ fixtures: [AFLFixture]) async throws {
        try await cache(fixtures, for: "fixtures", policy: .fixtures())
    }

    func getCachedFixtures() async throws -> [AFLFixture]? {
        try await retrieve([AFLFixture].self, for: "fixtures", policy: .fixtures())
    }

    // MARK: - Context Management

    private func saveContext() async throws {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            AFLLogger.error("Failed to save context: \(error.localizedDescription)", category: .persistence)
            throw PersistenceError.saveFailed(error)
        }
    }

    private func setupPeriodicCleanup() {
        // Clean up expired cache entries every 10 minutes
        Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { [weak self] _ in
            Task { @MainActor in
                do {
                    try await self?.clearExpiredCache()
                } catch {
                    AFLLogger.error(
                        "Failed to clear expired cache: \(error.localizedDescription)",
                        category: .persistence
                    )
                }
            }
        }
    }

    // MARK: - Memory Management

    func memoryPressureCleanup() async throws {
        AFLLogger.warning("Performing memory pressure cleanup", category: .persistence)

        // Clear all cache except critical data
        let request: NSFetchRequest<CachedDataEntity> = CachedDataEntity.fetchRequest()
        request.predicate = NSPredicate(format: "policyIdentifier != %@", CachePolicy.liveData().identifier)

        let results = try context.fetch(request)
        for entity in results {
            context.delete(entity)
            if let key = entity.key {
                cacheMetadata.removeValue(forKey: key)
            }
        }

        try await saveContext()

        // Reset managed object context to free memory
        context.refreshAllObjects()

        AFLLogger.info("Memory pressure cleanup completed", category: .persistence)
    }
}

// MARK: - CacheEntry

private struct CacheEntry {
    let timestamp: Date
    let policy: CachePolicy
}

// MARK: - AFLFixture

struct AFLFixture: Codable {
    let id: String
    let round: String
    let homeTeam: String
    let awayTeam: String
    let venue: String
    let date: Date
}

// MARK: - PersistenceError

enum PersistenceError: LocalizedError {
    case saveFailed(Error)
    case corruptedData
    case cacheNotFound

    var errorDescription: String? {
        switch self {
        case let .saveFailed(error):
            "Failed to save data: \(error.localizedDescription)"
        case .corruptedData:
            "Cached data is corrupted"
        case .cacheNotFound:
            "Cache entry not found"
        }
    }
}

// MARK: - Core Data Extensions

extension CachedDataEntity {
    static func fetchRequest() -> NSFetchRequest<CachedDataEntity> {
        NSFetchRequest<CachedDataEntity>(entityName: "CachedDataEntity")
    }
}

// MARK: - Background Context Support

extension PersistenceManager {
    func performBackgroundTask<T>(_ task: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            container.performBackgroundTask { backgroundContext in
                do {
                    let result = try task(backgroundContext)
                    try backgroundContext.save()
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Cache Statistics

extension PersistenceManager {
    func getCacheStatistics() async throws -> CacheStatistics {
        let request: NSFetchRequest<CachedDataEntity> = CachedDataEntity.fetchRequest()
        let allEntries = try context.fetch(request)

        let totalEntries = allEntries.count
        let totalSize = allEntries.compactMap { $0.data?.count }.reduce(0, +)

        var categoryCounts: [String: Int] = [:]
        for entry in allEntries {
            let policy = entry.policyIdentifier ?? "unknown"
            categoryCounts[policy, default: 0] += 1
        }

        return CacheStatistics(
            totalEntries: totalEntries,
            totalSizeBytes: totalSize,
            categoryCounts: categoryCounts
        )
    }
}

struct CacheStatistics {
    let totalEntries: Int
    let totalSizeBytes: Int
    let categoryCounts: [String: Int]

    var formattedSize: String {
        if totalSizeBytes < 1024 {
            "\(totalSizeBytes) bytes"
        } else if totalSizeBytes < 1024 * 1024 {
            String(format: "%.1f KB", Double(totalSizeBytes) / 1024)
        } else {
            String(format: "%.1f MB", Double(totalSizeBytes) / (1024 * 1024))
        }
    }
}
