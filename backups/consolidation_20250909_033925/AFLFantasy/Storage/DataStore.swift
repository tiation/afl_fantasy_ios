import Combine
import CoreData
import Foundation
import OSLog

// MARK: - DataStore

/// DataStore acts as a facade for all storage operations, combining CoreData and cache storage
final class DataStore {
    static let shared = DataStore()

    private let persistentStore: PersistentStore
    private let cacheStorage: CacheStorage
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "AFLFantasy",
        category: "DataStore"
    )

    private var cancellables = Set<AnyCancellable>()

    private init(
        persistentStore: PersistentStore = .shared,
        cacheStorage: CacheStorage = .shared
    ) {
        self.persistentStore = persistentStore
        self.cacheStorage = cacheStorage
        setupPeriodicCacheCleanup()
    }

    // MARK: - Player Operations

    func fetchPlayers() -> AnyPublisher<[EnhancedPlayer], Error> {
        // Try cache first
        if let cached: [EnhancedPlayer] = try? cacheStorage.retrieve([EnhancedPlayer].self, for: "players") {
            return Just(cached)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        // Fall back to CoreData
        let request = CDPlayer.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "averageScore", ascending: false)]

        return Future { [weak self] promise in
            guard let self else { return }

            do {
                let players = try persistentStore.viewContext.fetch(request)
                let models = players.map(\.asEnhancedPlayer)

                // Cache for next time
                try? cacheStorage.cache(models, for: "players", expiry: 300) // 5 minutes

                promise(.success(models))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func save(_ player: EnhancedPlayer) async throws {
        try await persistentStore.viewContext.perform {
            if let existing = CDPlayer.fetch(player.id, in: self.persistentStore.viewContext) {
                existing.update(from: player, in: self.persistentStore.viewContext)
            } else {
                let new = CDPlayer(context: self.persistentStore.viewContext)
                new.update(from: player, in: self.persistentStore.viewContext)
            }

            try self.persistentStore.viewContext.save()

            // Invalidate cache
            try? self.cacheStorage.removeCache(for: "players")
        }
    }

    func savePlayers(_ players: [EnhancedPlayer]) async throws {
        // Use batch import for efficiency
        try await persistentStore.importData(players, entityName: CDPlayer.entityName, uniqueKey: "id") { player in
            [
                "id": player.id,
                "name": player.name,
                "position": player.position.rawValue,
                "currentPrice": player.price as NSNumber,
                "currentScore": player.currentScore as NSNumber,
                "averageScore": player.averageScore as NSNumber,
                "breakeven": player.breakeven as NSNumber,
                "consistency": player.consistency as NSNumber,
                "highScore": player.highScore as NSNumber,
                "lowScore": player.lowScore as NSNumber,
                "priceChange": player.priceChange as NSNumber,
                "isCashCow": player.isCashCow as NSNumber,
                "isDoubtful": player.isDoubtful as NSNumber,
                "isSuspended": player.isSuspended as NSNumber,
                "cashGenerated": player.cashGenerated as NSNumber,
                "projectedPeakPrice": player.projectedPeakPrice as NSNumber,
                "lastUpdated": Date()
            ]
        }

        // Update cache
        try cacheStorage.cache(players, for: "players", expiry: 300)
    }

    func delete(_ player: EnhancedPlayer) async throws {
        try await persistentStore.viewContext.perform {
            if let existing = CDPlayer.fetch(player.id, in: self.persistentStore.viewContext) {
                self.persistentStore.viewContext.delete(existing)
                try self.persistentStore.viewContext.save()

                // Invalidate cache
                try? self.cacheStorage.removeCache(for: "players")
            }
        }
    }

    // MARK: - Cache Operations

    func cache(_ data: some Codable, for key: String, expiry: TimeInterval = 3600) throws {
        try cacheStorage.cache(data, for: key, expiry: expiry)
    }

    func retrieve<T: Codable>(_ type: T.Type, for key: String) throws -> T? {
        try cacheStorage.retrieve(type, for: key)
    }

    func clearCache(for key: String) throws {
        try cacheStorage.removeCache(for: key)
    }

    func clearAllCache() throws {
        try cacheStorage.clearAllCache()
    }

    // MARK: - Private Methods

    private func setupPeriodicCacheCleanup() {
        Timer.publish(every: 3600, on: .main, in: .common) // Every hour
            .autoconnect()
            .sink { [weak self] _ in
                self?.cacheStorage.cleanExpiredCache()
            }
            .store(in: &cancellables)
    }
}

// MARK: - CoreData Batch Operations

extension DataStore {
    /// Performs a batch update on CoreData entities
    func batchUpdate(entityName: String, properties: [AnyHashable: Any]) async throws {
        try await persistentStore.batchUpdate(entityName: entityName, propertiesToUpdate: properties)
    }

    /// Performs a batch delete on CoreData entities
    func batchDelete(fetchRequest: NSFetchRequest<NSFetchRequestResult>) async throws {
        try await persistentStore.batchDelete(fetchRequest: fetchRequest)
    }
}
