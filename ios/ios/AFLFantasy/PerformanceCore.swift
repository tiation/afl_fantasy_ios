//
//  PerformanceCore.swift
//  AFL Fantasy Intelligence Platform
//
//  Smart preloading, caching, and performance optimization system
//  Created by AI Assistant on 6/9/2025.
//

import Combine
import SwiftUI
import UIKit

// MARK: - SmartPreloader

@MainActor
class SmartPreloader: ObservableObject {
    static let shared = SmartPreloader()

    private var preloadTasks: [String: Task<Void, Never>] = [:]
    private var userBehaviorTracker = UserBehaviorTracker()
    private var cacheManager = IntelligentCacheManager.shared

    private init() {}

    // MARK: - Predictive Preloading

    func preloadForTabSwitch(to tab: TabItem, from currentTab: TabItem?) {
        let taskKey = "tab_\(tab.rawValue)"

        // Cancel any existing preload task for this tab
        preloadTasks[taskKey]?.cancel()

        preloadTasks[taskKey] = Task {
            await predictivePreload(for: tab, basedOn: currentTab)
        }
    }

    func preloadPlayerDetails(for playerId: UUID) {
        let taskKey = "player_\(playerId)"

        preloadTasks[taskKey]?.cancel()
        preloadTasks[taskKey] = Task {
            await preloadPlayerData(playerId: playerId)
        }
    }

    func preloadTradeAnalysis(playerIn: String, playerOut: String) {
        let taskKey = "trade_\(playerIn)_\(playerOut)"

        preloadTasks[taskKey]?.cancel()
        preloadTasks[taskKey] = Task {
            await preloadTradeData(playerIn: playerIn, playerOut: playerOut)
        }
    }

    // MARK: - Private Preloading Logic

    private func predictivePreload(for tab: TabItem, basedOn currentTab: TabItem?) async {
        switch tab {
        case .dashboard:
            await preloadDashboardData()
        case .captain:
            await preloadCaptainRecommendations()
        case .trades:
            await preloadTradeData()
        case .cashCow:
            await preloadCashCowData()
        case .settings:
            await preloadSettingsData()
        }
    }

    private func preloadDashboardData() async {
        guard !Task.isCancelled else { return }

        // Preload most likely to be viewed player details
        let highValuePlayers = await identifyHighValuePlayers()

        for playerId in highValuePlayers.prefix(5) {
            guard !Task.isCancelled else { return }
            await preloadPlayerData(playerId: playerId)

            // Small delay to prevent overwhelming the system
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s
        }
    }

    private func preloadCaptainRecommendations() async {
        guard !Task.isCancelled else { return }

        // Preload captain analysis data
        await simulateDataFetch(for: "captain_recommendations", duration: 0.3)
        await simulateDataFetch(for: "venue_analysis", duration: 0.2)
        await simulateDataFetch(for: "weather_data", duration: 0.1)
    }

    private func preloadTradeData() async {
        guard !Task.isCancelled else { return }

        // Preload commonly traded players
        await simulateDataFetch(for: "trade_targets", duration: 0.4)
        await simulateDataFetch(for: "price_predictions", duration: 0.3)
    }

    private func preloadCashCowData() async {
        guard !Task.isCancelled else { return }

        await simulateDataFetch(for: "rookie_analysis", duration: 0.2)
        await simulateDataFetch(for: "breakeven_projections", duration: 0.3)
    }

    private func preloadSettingsData() async {
        guard !Task.isCancelled else { return }

        await simulateDataFetch(for: "user_preferences", duration: 0.1)
        await simulateDataFetch(for: "app_statistics", duration: 0.1)
    }

    private func preloadPlayerData(playerId: UUID) async {
        guard !Task.isCancelled else { return }

        await simulateDataFetch(for: "player_\(playerId)", duration: 0.2)
        await simulateDataFetch(for: "player_stats_\(playerId)", duration: 0.1)
        await simulateDataFetch(for: "player_history_\(playerId)", duration: 0.15)
    }

    private func preloadTradeData(playerIn: String, playerOut: String) async {
        guard !Task.isCancelled else { return }

        await simulateDataFetch(for: "trade_analysis_\(playerIn)_\(playerOut)", duration: 0.3)
    }

    // MARK: - Helper Methods

    private func identifyHighValuePlayers() async -> [UUID] {
        // In a real app, this would analyze user behavior, player popularity, etc.
        Array(userBehaviorTracker.frequentlyViewedPlayers.prefix(5))
    }

    private func simulateDataFetch(for key: String, duration: TimeInterval) async {
        guard !Task.isCancelled else { return }

        // Simulate network/processing time
        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))

        // Cache the "fetched" data
        cacheManager.store(key: key, data: "preloaded_\(key)", ttl: 300) // 5 min TTL
    }

    func cancelAllPreloading() {
        for task in preloadTasks.values {
            task.cancel()
        }
        preloadTasks.removeAll()
    }
}

// MARK: - UserBehaviorTracker

class UserBehaviorTracker: ObservableObject {
    private(set) var frequentlyViewedPlayers: [UUID] = []
    private(set) var navigationPatterns: [TabItem] = []
    private(set) var sessionData = SessionData()

    struct SessionData {
        var tabSwitches: [TabItem: Int] = [:]
        var playerViews: [UUID: Int] = [:]
        var searchQueries: [String] = []
        var timeSpentPerTab: [TabItem: TimeInterval] = [:]
        var lastActiveTab: TabItem = .dashboard
        var sessionStartTime = Date()
    }

    func trackTabSwitch(to tab: TabItem, from previousTab: TabItem?) {
        if let previous = previousTab {
            // Track time spent in previous tab
            let timeSpent = Date().timeIntervalSince(sessionData.sessionStartTime)
            sessionData.timeSpentPerTab[previous, default: 0] += timeSpent
        }

        navigationPatterns.append(tab)
        sessionData.tabSwitches[tab, default: 0] += 1
        sessionData.lastActiveTab = tab

        // Keep only last 50 navigation events to prevent memory growth
        if navigationPatterns.count > 50 {
            navigationPatterns.removeFirst(navigationPatterns.count - 50)
        }
    }

    func trackPlayerView(playerId: UUID) {
        sessionData.playerViews[playerId, default: 0] += 1

        // Update frequently viewed players list
        let sortedPlayers = sessionData.playerViews.sorted { $0.value > $1.value }
        frequentlyViewedPlayers = Array(sortedPlayers.prefix(10).map(\.key))
    }

    func trackSearch(query: String) {
        sessionData.searchQueries.append(query)

        // Keep only last 20 searches
        if sessionData.searchQueries.count > 20 {
            sessionData.searchQueries.removeFirst()
        }
    }

    func predictNextTab() -> TabItem? {
        // Simple prediction based on recent navigation patterns
        guard navigationPatterns.count >= 3 else { return nil }

        let recentPattern = Array(navigationPatterns.suffix(3))
        let currentTab = recentPattern.last!

        // Look for common patterns after current tab
        let afterCurrent = navigationPatterns.enumerated().compactMap { index, tab in
            tab == currentTab && index + 1 < navigationPatterns.count
                ? navigationPatterns[index + 1] : nil
        }

        // Return most common next tab
        let frequency = afterCurrent.reduce(into: [:]) { counts, tab in
            counts[tab, default: 0] += 1
        }

        return frequency.max { $0.value < $1.value }?.key
    }
}

// MARK: - IntelligentCacheManager

class IntelligentCacheManager: ObservableObject {
    static let shared = IntelligentCacheManager()

    private var cache: [String: CacheEntry] = [:]
    private var accessPatterns: [String: AccessPattern] = [:]
    private let maxCacheSize = 50 * 1024 * 1024 // 50MB
    private var currentCacheSize = 0

    private struct CacheEntry {
        let data: Any
        let createdAt: Date
        let ttl: TimeInterval
        let size: Int
        var accessCount: Int = 0
        var lastAccessed: Date

        init(data: Any, ttl: TimeInterval) {
            self.data = data
            createdAt = Date()
            lastAccessed = Date()
            self.ttl = ttl
            size = MemoryLayout.size(ofValue: data)
        }

        var isExpired: Bool {
            Date().timeIntervalSince(createdAt) > ttl
        }
    }

    private struct AccessPattern {
        var frequency: Double = 1.0
        var recency: TimeInterval = 0
        var importance: CacheImportance = .normal

        var score: Double {
            let recencyFactor = max(0.1, 1.0 - (recency / 3600)) // Decay over 1 hour
            let importanceFactor = importance.multiplier
            return frequency * recencyFactor * importanceFactor
        }
    }

    enum CacheImportance: Double {
        case low = 0.5
        case normal = 1.0
        case high = 2.0
        case critical = 5.0

        var multiplier: Double { rawValue }
    }

    private init() {
        startCacheCleanupTimer()
    }

    // MARK: - Public Interface

    func store(key: String, data: Any, ttl: TimeInterval = 300, importance: CacheImportance = .normal) {
        let entry = CacheEntry(data: data, ttl: ttl)

        // Update access patterns
        if accessPatterns[key] == nil {
            accessPatterns[key] = AccessPattern()
        }
        accessPatterns[key]?.importance = importance

        // Remove old entry if exists
        if let oldEntry = cache[key] {
            currentCacheSize -= oldEntry.size
        }

        // Add new entry
        cache[key] = entry
        currentCacheSize += entry.size

        // Perform cache eviction if needed
        if currentCacheSize > maxCacheSize {
            evictLeastImportantEntries()
        }
    }

    func retrieve<T>(key: String, as type: T.Type) -> T? {
        guard let entry = cache[key], !entry.isExpired else {
            cache.removeValue(forKey: key)
            return nil
        }

        // Update access patterns
        cache[key]?.accessCount += 1
        cache[key]?.lastAccessed = Date()

        if var pattern = accessPatterns[key] {
            pattern.frequency = min(100, pattern.frequency + 0.1)
            pattern.recency = Date().timeIntervalSince(entry.lastAccessed)
            accessPatterns[key] = pattern
        }

        return entry.data as? T
    }

    func preload(keys: [String], priority: TaskPriority = .medium) {
        Task(priority: priority) {
            for key in keys {
                // Simulate preloading data for these keys
                if retrieve(key: key, as: String.self) == nil {
                    // Data not in cache, trigger fetch
                    await simulatePreloadData(for: key)
                }
            }
        }
    }

    // MARK: - Cache Management

    private func evictLeastImportantEntries() {
        let sortedEntries = cache.compactMap { key, _ -> (key: String, score: Double)? in
            guard let pattern = accessPatterns[key] else { return nil }
            return (key: key, score: pattern.score)
        }.sorted { $0.score < $1.score }

        // Remove lowest-scoring entries until under limit
        for (key, _) in sortedEntries.prefix(while: { _ in currentCacheSize > maxCacheSize * 8 / 10 }) {
            if let entry = cache.removeValue(forKey: key) {
                currentCacheSize -= entry.size
            }
        }
    }

    private func startCacheCleanupTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.cleanupExpiredEntries()
        }
    }

    private func cleanupExpiredEntries() {
        let expiredKeys = cache.compactMap { key, entry in
            entry.isExpired ? key : nil
        }

        for key in expiredKeys {
            if let entry = cache.removeValue(forKey: key) {
                currentCacheSize -= entry.size
            }
            accessPatterns.removeValue(forKey: key)
        }
    }

    private func simulatePreloadData(for key: String) async {
        // In a real app, this would make an actual API call
        try? await Task.sleep(nanoseconds: UInt64.random(in: 100_000_000 ... 500_000_000))

        let mockData = "preloaded_data_for_\(key)"
        store(key: key, data: mockData, ttl: 300)
    }

    // MARK: - Statistics

    var cacheStats: CacheStatistics {
        CacheStatistics(
            totalEntries: cache.count,
            totalSize: currentCacheSize,
            hitRate: calculateHitRate(),
            averageEntryAge: calculateAverageAge(),
            mostAccessedKeys: getMostAccessedKeys()
        )
    }

    struct CacheStatistics {
        let totalEntries: Int
        let totalSize: Int
        let hitRate: Double
        let averageEntryAge: TimeInterval
        let mostAccessedKeys: [String]
    }

    private func calculateHitRate() -> Double {
        let totalAccesses = cache.values.reduce(0) { $0 + $1.accessCount }
        let totalRequests = max(1, totalAccesses + cache.count) // Rough estimate
        return Double(totalAccesses) / Double(totalRequests)
    }

    private func calculateAverageAge() -> TimeInterval {
        let now = Date()
        let totalAge = cache.values.reduce(0) { $0 + now.timeIntervalSince($1.createdAt) }
        return cache.isEmpty ? 0 : totalAge / Double(cache.count)
    }

    private func getMostAccessedKeys() -> [String] {
        cache.sorted { $0.value.accessCount > $1.value.accessCount }
            .prefix(5)
            .map(\.key)
    }
}

// MARK: - PerformanceMonitor

@MainActor
class PerformanceMonitor: ObservableObject {
    static let shared = PerformanceMonitor()

    @Published var currentMetrics = PerformanceMetrics()

    private var frameTimeTracker = FrameTimeTracker()
    private var memoryTracker = MemoryTracker()
    private var networkTracker = NetworkTracker()

    struct PerformanceMetrics {
        var averageFrameTime: TimeInterval = 0
        var memoryUsage: Int64 = 0
        var networkRequests: Int = 0
        var cacheHitRate: Double = 0
        var batteryImpact: BatteryImpact = .low
    }

    enum BatteryImpact {
        case low, medium, high

        var description: String {
            switch self {
            case .low: "Minimal"
            case .medium: "Moderate"
            case .high: "High"
            }
        }
    }

    private init() {
        startPerformanceMonitoring()
    }

    private func startPerformanceMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            Task { @MainActor in
                self.updateMetrics()
            }
        }
    }

    private func updateMetrics() {
        currentMetrics = PerformanceMetrics(
            averageFrameTime: frameTimeTracker.averageFrameTime,
            memoryUsage: memoryTracker.currentMemoryUsage,
            networkRequests: networkTracker.requestCount,
            cacheHitRate: IntelligentCacheManager.shared.cacheStats.hitRate,
            batteryImpact: calculateBatteryImpact()
        )
    }

    private func calculateBatteryImpact() -> BatteryImpact {
        let frameTime = frameTimeTracker.averageFrameTime
        let networkActivity = networkTracker.requestsPerMinute

        if frameTime > 0.02 || networkActivity > 30 {
            return .high
        } else if frameTime > 0.018 || networkActivity > 15 {
            return .medium
        } else {
            return .low
        }
    }
}

// MARK: - FrameTimeTracker

class FrameTimeTracker {
    private var frameTimes: [TimeInterval] = []
    private let maxSamples = 60

    var averageFrameTime: TimeInterval {
        guard !frameTimes.isEmpty else { return 0 }
        return frameTimes.reduce(0, +) / Double(frameTimes.count)
    }

    func recordFrameTime(_ time: TimeInterval) {
        frameTimes.append(time)
        if frameTimes.count > maxSamples {
            frameTimes.removeFirst()
        }
    }
}

// MARK: - MemoryTracker

class MemoryTracker {
    var currentMemoryUsage: Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    $0,
                    &count
                )
            }
        }

        return result == KERN_SUCCESS ? Int64(info.resident_size) : 0
    }
}

// MARK: - NetworkTracker

class NetworkTracker {
    private(set) var requestCount: Int = 0
    private var requestTimes: [Date] = []

    var requestsPerMinute: Int {
        let oneMinuteAgo = Date().addingTimeInterval(-60)
        let recentRequests = requestTimes.filter { $0 > oneMinuteAgo }
        return recentRequests.count
    }

    func recordRequest() {
        requestCount += 1
        requestTimes.append(Date())

        // Keep only last hour of requests
        let oneHourAgo = Date().addingTimeInterval(-3600)
        requestTimes = requestTimes.filter { $0 > oneHourAgo }
    }
}
