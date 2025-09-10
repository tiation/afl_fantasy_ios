//
//  OfflineManager.swift
//  AFL Fantasy Intelligence Platform
//
//  Comprehensive offline state management and caching system
//  Created by AI Assistant on 6/9/2025.
//

import Combine
import Foundation
import Network

// MARK: - OfflineManager

@MainActor
class OfflineManager: ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var isOnline: Bool = true
    @Published private(set) var connectionType: ConnectionType = .wifi
    @Published private(set) var hasOfflineData: Bool = false
    @Published private(set) var lastOnlineTime: Date?
    @Published private(set) var pendingSyncOperations: Int = 0

    // MARK: - Private Properties

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let cacheManager = CacheManager()
    private let syncQueue = SyncOperationQueue()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Singleton

    static let shared = OfflineManager()

    private init() {
        startMonitoring()
        checkOfflineData()
    }

    deinit {
        monitor.cancel()
    }

    // MARK: - Network Monitoring

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                await self?.handleNetworkStatusChange(path)
            }
        }
        monitor.start(queue: queue)
    }

    private func handleNetworkStatusChange(_ path: NWPath) {
        let wasOnline = isOnline
        isOnline = path.status == .satisfied
        connectionType = getConnectionType(from: path)

        if isOnline {
            lastOnlineTime = Date()
            if !wasOnline {
                // Just came back online
                print("🌐 Network restored - syncing pending operations")
                Task {
                    await syncPendingOperations()
                }
            }
        } else {
            print("❌ Network lost - entering offline mode")
        }

        // Notify the app about network status change
        NotificationCenter.default.post(
            name: .networkStatusChanged,
            object: NetworkStatus(
                isOnline: isOnline,
                connectionType: connectionType
            )
        )
    }

    private func getConnectionType(from path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            .wifi
        } else if path.usesInterfaceType(.cellular) {
            .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            .ethernet
        } else {
            .unknown
        }
    }

    // MARK: - Cache Management

    func cacheData(_ data: some Codable, for key: CacheKey, expiry: TimeInterval = 300) async {
        await cacheManager.store(data, for: key.rawValue, expiry: expiry)
        hasOfflineData = true
        print("💾 Cached data for key: \(key.rawValue)")
    }

    func getCachedData<T: Codable>(for key: CacheKey, type: T.Type) async -> T? {
        await cacheManager.retrieve(for: key.rawValue, type: type)
    }

    func isCacheValid(for key: CacheKey) async -> Bool {
        await cacheManager.isValid(for: key.rawValue)
    }

    func clearCache(for key: CacheKey) async {
        await cacheManager.remove(for: key.rawValue)
    }

    func clearAllCache() async {
        await cacheManager.clearAll()
        hasOfflineData = false
        print("🗑️ All cache cleared")
    }

    // MARK: - Sync Operations

    func addSyncOperation(_ operation: SyncOperation) async {
        await syncQueue.add(operation)
        pendingSyncOperations = await syncQueue.count()

        // Try to sync immediately if online
        if isOnline {
            await syncPendingOperations()
        }
    }

    private func syncPendingOperations() async {
        guard isOnline else { return }

        let operations = await syncQueue.getAllOperations()
        var completedOperations: [UUID] = []

        for operation in operations {
            do {
                try await executeOperation(operation)
                completedOperations.append(operation.id)
                print("✅ Synced operation: \(operation.type)")
            } catch {
                print("❌ Failed to sync operation \(operation.type): \(error)")
                // Keep the operation in queue for retry
            }
        }

        // Remove completed operations
        for operationId in completedOperations {
            await syncQueue.remove(operationId)
        }

        pendingSyncOperations = await syncQueue.count()
    }

    private func executeOperation(_ operation: SyncOperation) async throws {
        switch operation.type {
        case .setCaptain:
            try await syncCaptainOperation(operation)
        case .executeTrade:
            try await syncTradeOperation(operation)
        case .updateSettings:
            try await syncSettingsOperation(operation)
        case .submitTeam:
            try await syncTeamSubmissionOperation(operation)
        }
    }

    private func syncCaptainOperation(_ operation: SyncOperation) async throws {
        guard let playerName = operation.data["playerName"] as? String else {
            throw OfflineError.invalidOperationData
        }

        // In production, this would call the actual API
        try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate network delay
        print("🎯 Synced captain selection: \(playerName)")
    }

    private func syncTradeOperation(_ operation: SyncOperation) async throws {
        guard let playerOutId = operation.data["playerOutId"] as? String,
              let playerInId = operation.data["playerInId"] as? String
        else {
            throw OfflineError.invalidOperationData
        }

        // In production, this would call the actual API
        try await Task.sleep(nanoseconds: 2_000_000_000) // Simulate network delay
        print("🔄 Synced trade: \(playerOutId) → \(playerInId)")
    }

    private func syncSettingsOperation(_ operation: SyncOperation) async throws {
        // Sync settings changes
        try await Task.sleep(nanoseconds: 500_000_000)
        print("⚙️ Synced settings")
    }

    private func syncTeamSubmissionOperation(_ operation: SyncOperation) async throws {
        // Sync team submission
        try await Task.sleep(nanoseconds: 1_500_000_000)
        print("⚽ Synced team submission")
    }

    // MARK: - Offline Data Check

    private func checkOfflineData() {
        Task {
            let hasData = await cacheManager.hasAnyData()
            await MainActor.run {
                hasOfflineData = hasData
            }
        }
    }

    // MARK: - Offline Capabilities

    func getOfflineCapabilities() -> OfflineCapabilities {
        OfflineCapabilities(
            canViewDashboard: hasOfflineData,
            canViewPlayers: hasOfflineData,
            canAnalyzeTrades: hasOfflineData,
            canSetCaptain: true, // Can queue operation
            canMakeTrades: true, // Can queue operation
            canViewHistory: hasOfflineData,
            canViewSettings: true
        )
    }

    // MARK: - Data Freshness

    func getDataFreshness(for key: CacheKey) async -> DataFreshness {
        guard await cacheManager.exists(for: key.rawValue) else {
            return .noData
        }

        let isValid = await cacheManager.isValid(for: key.rawValue)
        let age = await cacheManager.getAge(for: key.rawValue)

        if isValid {
            return .fresh
        } else if age < 3600 { // 1 hour
            return .stale
        } else {
            return .expired
        }
    }

    // MARK: - Cache Statistics

    func getCacheStatistics() async -> CacheStatistics {
        let stats = await cacheManager.getStatistics()
        return CacheStatistics(
            totalItems: stats.totalItems,
            totalSize: stats.totalSize,
            oldestItem: stats.oldestItem,
            newestItem: stats.newestItem,
            hitRate: stats.hitRate
        )
    }

    // MARK: - Preloading

    func preloadCriticalData() async {
        guard isOnline else { return }

        // Preload essential data for offline usage
        let criticalKeys: [CacheKey] = [
            .dashboardData,
            .playerList,
            .captainSuggestions,
            .userSettings
        ]

        for key in criticalKeys {
            // In production, this would fetch fresh data from APIs
            await simulateDataFetch(for: key)
        }

        print("📦 Preloaded critical data for offline usage")
    }

    private func simulateDataFetch(for key: CacheKey) async {
        // Simulate fetching and caching data
        let mockData = ["key": key.rawValue, "timestamp": Date().timeIntervalSince1970]
        await cacheData(mockData, for: key)
    }
}

// MARK: - CacheManager

private actor CacheManager {
    private var cache: [String: CacheEntry] = [:]
    private var statistics = CacheStats()

    func store(_ data: some Codable, for key: String, expiry: TimeInterval) {
        do {
            let encoded = try JSONEncoder().encode(data)
            let entry = CacheEntry(
                data: encoded,
                timestamp: Date(),
                expiry: expiry
            )
            cache[key] = entry
            statistics.totalItems = cache.count
            statistics.totalSize += encoded.count
        } catch {
            print("❌ Failed to cache data for key \(key): \(error)")
        }
    }

    func retrieve<T: Codable>(for key: String, type: T.Type) -> T? {
        guard let entry = cache[key] else {
            statistics.misses += 1
            return nil
        }

        do {
            let decoded = try JSONDecoder().decode(type, from: entry.data)
            statistics.hits += 1
            return decoded
        } catch {
            print("❌ Failed to decode cached data for key \(key): \(error)")
            statistics.misses += 1
            return nil
        }
    }

    func isValid(for key: String) -> Bool {
        guard let entry = cache[key] else { return false }
        return Date().timeIntervalSince(entry.timestamp) < entry.expiry
    }

    func exists(for key: String) -> Bool {
        cache[key] != nil
    }

    func getAge(for key: String) -> TimeInterval {
        guard let entry = cache[key] else { return 0 }
        return Date().timeIntervalSince(entry.timestamp)
    }

    func remove(for key: String) {
        if let entry = cache.removeValue(forKey: key) {
            statistics.totalItems = cache.count
            statistics.totalSize -= entry.data.count
        }
    }

    func clearAll() {
        cache.removeAll()
        statistics = CacheStats()
    }

    func hasAnyData() -> Bool {
        !cache.isEmpty
    }

    func getStatistics() -> CacheStats {
        statistics.hitRate = statistics.hits + statistics.misses > 0
            ? Double(statistics.hits) / Double(statistics.hits + statistics.misses)
            : 0.0

        if !cache.isEmpty {
            let timestamps = cache.values.map(\.timestamp)
            statistics.oldestItem = timestamps.min()
            statistics.newestItem = timestamps.max()
        }

        return statistics
    }
}

// MARK: - SyncOperationQueue

private actor SyncOperationQueue {
    private var operations: [SyncOperation] = []

    func add(_ operation: SyncOperation) {
        operations.append(operation)
    }

    func remove(_ id: UUID) {
        operations.removeAll { $0.id == id }
    }

    func getAllOperations() -> [SyncOperation] {
        operations
    }

    func count() -> Int {
        operations.count
    }

    func clear() {
        operations.removeAll()
    }
}

// MARK: - CacheEntry

struct CacheEntry {
    let data: Data
    let timestamp: Date
    let expiry: TimeInterval
}

// MARK: - CacheStats

struct CacheStats {
    var totalItems: Int = 0
    var totalSize: Int = 0
    var hits: Int = 0
    var misses: Int = 0
    var hitRate: Double = 0.0
    var oldestItem: Date?
    var newestItem: Date?
}

// MARK: - CacheKey

enum CacheKey: String, CaseIterable {
    case dashboardData = "dashboard_data"
    case playerList = "player_list"
    case captainSuggestions = "captain_suggestions"
    case tradeRecommendations = "trade_recommendations"
    case cashCowTargets = "cash_cow_targets"
    case userSettings = "user_settings"
    case teamData = "team_data"
    case leagueData = "league_data"
}

// MARK: - ConnectionType

enum ConnectionType: String {
    case wifi = "WiFi"
    case cellular = "Cellular"
    case ethernet = "Ethernet"
    case unknown = "Unknown"

    var icon: String {
        switch self {
        case .wifi: "wifi"
        case .cellular: "antenna.radiowaves.left.and.right"
        case .ethernet: "cable.connector"
        case .unknown: "questionmark.circle"
        }
    }

    var isMetered: Bool {
        self == .cellular
    }
}

// MARK: - NetworkStatus

struct NetworkStatus {
    let isOnline: Bool
    let connectionType: ConnectionType
}

// MARK: - DataFreshness

enum DataFreshness {
    case fresh
    case stale
    case expired
    case noData

    var color: String {
        switch self {
        case .fresh: "green"
        case .stale: "orange"
        case .expired: "red"
        case .noData: "gray"
        }
    }

    var description: String {
        switch self {
        case .fresh: "Fresh"
        case .stale: "Stale"
        case .expired: "Expired"
        case .noData: "No Data"
        }
    }
}

// MARK: - OfflineCapabilities

struct OfflineCapabilities {
    let canViewDashboard: Bool
    let canViewPlayers: Bool
    let canAnalyzeTrades: Bool
    let canSetCaptain: Bool
    let canMakeTrades: Bool
    let canViewHistory: Bool
    let canViewSettings: Bool
}

// MARK: - CacheStatistics

struct CacheStatistics {
    let totalItems: Int
    let totalSize: Int
    let oldestItem: Date?
    let newestItem: Date?
    let hitRate: Double

    var formattedSize: String {
        ByteCountFormatter().string(fromByteCount: Int64(totalSize))
    }

    var formattedHitRate: String {
        String(format: "%.1f%%", hitRate * 100)
    }
}

// MARK: - SyncOperation

struct SyncOperation {
    let id = UUID()
    let type: SyncOperationType
    let data: [String: Any]
    let timestamp: Date
    let priority: OperationPriority

    init(
        type: SyncOperationType,
        data: [String: Any],
        priority: OperationPriority = .normal
    ) {
        self.type = type
        self.data = data
        timestamp = Date()
        self.priority = priority
    }
}

// MARK: - SyncOperationType

enum SyncOperationType: String, CaseIterable {
    case setCaptain = "SET_CAPTAIN"
    case executeTrade = "EXECUTE_TRADE"
    case updateSettings = "UPDATE_SETTINGS"
    case submitTeam = "SUBMIT_TEAM"
}

// MARK: - OperationPriority

enum OperationPriority: Int, CaseIterable {
    case low = 0
    case normal = 1
    case high = 2
    case critical = 3
}

// MARK: - OfflineError

enum OfflineError: Error, LocalizedError {
    case invalidOperationData
    case syncFailed
    case cacheCorrupted

    var errorDescription: String? {
        switch self {
        case .invalidOperationData:
            "Invalid operation data"
        case .syncFailed:
            "Synchronization failed"
        case .cacheCorrupted:
            "Cache data is corrupted"
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
    static let offlineDataUpdated = Notification.Name("offlineDataUpdated")
    static let syncOperationCompleted = Notification.Name("syncOperationCompleted")
}
