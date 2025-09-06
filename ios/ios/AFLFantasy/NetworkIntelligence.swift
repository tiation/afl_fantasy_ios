//
//  NetworkIntelligence.swift
//  AFL Fantasy Intelligence Platform
//
//  Smart networking with caching, background refresh, and efficient API batching
//  Created by AI Assistant on 6/9/2025.
//

import Combine
import Network
import SwiftUI

// MARK: - NetworkIntelligence

@MainActor
class NetworkIntelligence: ObservableObject {
    static let shared = NetworkIntelligence()

    @Published var connectionStatus: ConnectionStatus = .unknown
    @Published var networkMetrics: NetworkMetrics = .init()
    @Published var optimizationLevel: OptimizationLevel = .balanced

    private var monitor = NWPathMonitor()
    private var requestBatcher = RequestBatcher()
    private var backgroundRefreshManager = BackgroundRefreshManager()
    private var responseCache = ResponseCacheManager()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")

    enum ConnectionStatus {
        case unknown, offline, cellular, wifi, ethernet

        var isConnected: Bool {
            switch self {
            case .unknown, .offline: false
            default: true
            }
        }

        var icon: String {
            switch self {
            case .unknown: "questionmark.circle"
            case .offline: "wifi.slash"
            case .cellular: "cellularbars"
            case .wifi: "wifi"
            case .ethernet: "cable.connector"
            }
        }

        var description: String {
            switch self {
            case .unknown: "Unknown"
            case .offline: "Offline"
            case .cellular: "Cellular"
            case .wifi: "Wi-Fi"
            case .ethernet: "Ethernet"
            }
        }
    }

    enum OptimizationLevel {
        case aggressive, balanced, conservative

        var maxConcurrentRequests: Int {
            switch self {
            case .aggressive: 8
            case .balanced: 4
            case .conservative: 2
            }
        }

        var batchingDelay: TimeInterval {
            switch self {
            case .aggressive: 0.1
            case .balanced: 0.5
            case .conservative: 1.0
            }
        }

        var cacheStrategy: CacheStrategy {
            switch self {
            case .aggressive: .aggressive
            case .balanced: .balanced
            case .conservative: .conservative
            }
        }
    }

    enum CacheStrategy {
        case aggressive, balanced, conservative

        var defaultTTL: TimeInterval {
            switch self {
            case .aggressive: 900 // 15 minutes
            case .balanced: 300 // 5 minutes
            case .conservative: 60 // 1 minute
            }
        }

        var staleWhileRevalidateWindow: TimeInterval {
            switch self {
            case .aggressive: 1800 // 30 minutes
            case .balanced: 600 // 10 minutes
            case .conservative: 120 // 2 minutes
            }
        }
    }

    struct NetworkMetrics {
        var requestsPerMinute: Int = 0
        var averageResponseTime: TimeInterval = 0
        var cacheHitRate: Double = 0
        var dataUsage: DataUsage = .init()
        var errorRate: Double = 0

        struct DataUsage {
            var sentBytes: Int64 = 0
            var receivedBytes: Int64 = 0

            var totalUsage: Int64 { sentBytes + receivedBytes }
            var formattedTotal: String {
                let mb = Double(totalUsage) / 1024 / 1024
                return String(format: "%.2f MB", mb)
            }
        }
    }

    private init() {
        setupNetworkMonitoring()
        startMetricsTracking()
        configureOptimizationLevel()
    }

    deinit {
        monitor.cancel()
    }

    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.updateConnectionStatus(path)
            }
        }
        monitor.start(queue: monitorQueue)
    }

    private func updateConnectionStatus(_ path: NWPath) {
        switch path.status {
        case .satisfied:
            if path.usesInterfaceType(.wifi) {
                connectionStatus = .wifi
            } else if path.usesInterfaceType(.cellular) {
                connectionStatus = .cellular
            } else if path.usesInterfaceType(.wiredEthernet) {
                connectionStatus = .ethernet
            } else {
                connectionStatus = .wifi // Default for satisfied connections
            }
        case .unsatisfied, .requiresConnection:
            connectionStatus = .offline
        @unknown default:
            connectionStatus = .unknown
        }

        // Adjust optimization level based on connection type
        adjustOptimizationForConnection()
    }

    private func adjustOptimizationForConnection() {
        switch connectionStatus {
        case .wifi, .ethernet:
            optimizationLevel = .balanced
        case .cellular:
            optimizationLevel = .conservative
        case .offline, .unknown:
            optimizationLevel = .aggressive // Use cache aggressively
        }

        configureOptimizationLevel()
    }

    private func configureOptimizationLevel() {
        requestBatcher.configure(
            maxConcurrentRequests: optimizationLevel.maxConcurrentRequests,
            batchingDelay: optimizationLevel.batchingDelay
        )

        responseCache.setCacheStrategy(optimizationLevel.cacheStrategy)
    }

    private func startMetricsTracking() {
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateNetworkMetrics()
            }
        }
    }

    private func updateNetworkMetrics() {
        let batcherMetrics = requestBatcher.getMetrics()
        let cacheMetrics = responseCache.getMetrics()

        networkMetrics = NetworkMetrics(
            requestsPerMinute: batcherMetrics.requestsPerMinute,
            averageResponseTime: batcherMetrics.averageResponseTime,
            cacheHitRate: cacheMetrics.hitRate,
            dataUsage: NetworkMetrics.DataUsage(
                sentBytes: batcherMetrics.bytesSent,
                receivedBytes: batcherMetrics.bytesReceived
            ),
            errorRate: batcherMetrics.errorRate
        )
    }

    // MARK: - Public API

    func fetchPlayerData(playerIds: [UUID]) async throws -> [AFLPlayer] {
        if !connectionStatus.isConnected {
            // Try cache first when offline
            if let cachedPlayers = await responseCache.getCachedPlayers(playerIds: playerIds) {
                return cachedPlayers
            }
            throw NetworkError.offline
        }

        // Use request batcher for efficient API calls
        return try await requestBatcher.batchPlayerRequests(playerIds: playerIds)
    }

    func refreshPlayerData(playerIds: [UUID]) async {
        // Background refresh with stale-while-revalidate
        await backgroundRefreshManager.scheduleRefresh(
            key: "players_\(playerIds.count)",
            playerIds: playerIds
        )
    }

    func preloadCriticalData() async {
        guard connectionStatus.isConnected else { return }

        // Preload commonly requested data based on user patterns
        await backgroundRefreshManager.preloadCriticalEndpoints()
    }
}

// MARK: - RequestBatcher

@MainActor
class RequestBatcher: ObservableObject {
    private var pendingRequests: [BatchableRequest] = []
    private var batchingTimer: Timer?
    private var activeRequests: [String: Task<Any, Error>] = [:]

    private var maxConcurrentRequests = 4
    private var batchingDelay: TimeInterval = 0.5

    // Metrics
    private var requestCount = 0
    private var totalResponseTime: TimeInterval = 0
    private var bytesSent: Int64 = 0
    private var bytesReceived: Int64 = 0
    private var errorCount = 0
    private var lastMetricsReset = Date()

    struct BatchableRequest {
        let id: String
        let endpoint: String
        let parameters: [String: Any]
        let priority: Priority
        let continuation: CheckedContinuation<Any, Error>

        enum Priority {
            case low, normal, high, critical

            var sortOrder: Int {
                switch self {
                case .critical: 0
                case .high: 1
                case .normal: 2
                case .low: 3
                }
            }
        }
    }

    struct RequestMetrics {
        let requestsPerMinute: Int
        let averageResponseTime: TimeInterval
        let bytesSent: Int64
        let bytesReceived: Int64
        let errorRate: Double
    }

    func configure(maxConcurrentRequests: Int, batchingDelay: TimeInterval) {
        self.maxConcurrentRequests = maxConcurrentRequests
        self.batchingDelay = batchingDelay
    }

    func batchPlayerRequests(playerIds: [UUID]) async throws -> [AFLPlayer] {
        // Group player requests into efficient batches
        let batchSize = min(20, playerIds.count) // API limit consideration
        var allPlayers: [AFLPlayer] = []

        for batch in playerIds.chunked(into: batchSize) {
            let players = try await performBatchRequest(
                endpoint: "/players/batch",
                parameters: ["player_ids": batch.map(\.uuidString)],
                priority: .normal
            ) as? [AFLPlayer] ?? []

            allPlayers.append(contentsOf: players)
        }

        return allPlayers
    }

    func performBatchRequest(
        endpoint: String,
        parameters: [String: Any],
        priority: BatchableRequest.Priority = .normal
    ) async throws -> Any {
        let requestId = UUID().uuidString

        return try await withCheckedThrowingContinuation { continuation in
            let request = BatchableRequest(
                id: requestId,
                endpoint: endpoint,
                parameters: parameters,
                priority: priority,
                continuation: continuation
            )

            addToBatch(request)
        }
    }

    private func addToBatch(_ request: BatchableRequest) {
        pendingRequests.append(request)

        // Sort by priority
        pendingRequests.sort { $0.priority.sortOrder < $1.priority.sortOrder }

        // Schedule batch processing if not already scheduled
        if batchingTimer == nil {
            batchingTimer = Timer.scheduledTimer(withTimeInterval: batchingDelay, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    await self?.processBatch()
                }
            }
        }
    }

    private func processBatch() async {
        batchingTimer?.invalidate()
        batchingTimer = nil

        guard !pendingRequests.isEmpty else { return }

        let batch = Array(pendingRequests.prefix(maxConcurrentRequests))
        pendingRequests.removeFirst(min(maxConcurrentRequests, pendingRequests.count))

        // Process requests concurrently
        await withTaskGroup(of: Void.self) { group in
            for request in batch {
                group.addTask {
                    await self.executeRequest(request)
                }
            }
        }

        // Schedule next batch if there are pending requests
        if !pendingRequests.isEmpty {
            batchingTimer = Timer.scheduledTimer(withTimeInterval: batchingDelay, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    await self?.processBatch()
                }
            }
        }
    }

    private func executeRequest(_ request: BatchableRequest) async {
        let startTime = Date()

        do {
            // Simulate network request
            let responseData = try await performNetworkRequest(
                endpoint: request.endpoint,
                parameters: request.parameters
            )

            // Update metrics
            requestCount += 1
            totalResponseTime += Date().timeIntervalSince(startTime)
            bytesReceived += Int64(responseData.count)

            // Parse response based on endpoint
            let result = parseResponse(data: responseData, endpoint: request.endpoint)
            request.continuation.resume(returning: result)

        } catch {
            errorCount += 1
            request.continuation.resume(throwing: error)
        }
    }

    private func performNetworkRequest(endpoint: String, parameters: [String: Any]) async throws -> Data {
        // Simulate network delay based on connection quality
        let networkDelay = NetworkIntelligence.shared.connectionStatus == .cellular ?
            UInt64.random(in: 200_000_000 ... 1_000_000_000) : // 0.2-1s for cellular
            UInt64.random(in: 50_000_000 ... 300_000_000) // 0.05-0.3s for wifi

        try await Task.sleep(nanoseconds: networkDelay)

        // Simulate response size
        let responseSize = Int.random(in: 1024 ... 10240) // 1-10KB
        let responseData = Data(repeating: 0, count: responseSize)

        bytesSent += Int64(parameters.description.utf8.count)

        return responseData
    }

    private func parseResponse(data: Data, endpoint: String) -> Any {
        // Mock response parsing based on endpoint
        switch endpoint {
        case "/players/batch":
            // Return mock player data
            generateMockPlayers()
        case "/scores":
            generateMockScores()
        case "/trades":
            generateMockTrades()
        default:
            data
        }
    }

    private func generateMockPlayers() -> [AFLPlayer] {
        (0 ..< 10).map { index in
            AFLPlayer(
                id: UUID(),
                name: "Player \(index + 1)",
                team: ["COL", "RIC", "ESS", "HAW"].randomElement()!,
                position: ["DEF", "MID", "RUC", "FWD"].randomElement()!,
                price: Int.random(in: 200_000 ... 800_000),
                gameStats: []
            )
        }
    }

    private func generateMockScores() -> [String: Any] {
        [
            "round": Int.random(in: 1 ... 23),
            "scores": Array(0 ..< 10).map { _ in
                ["player_id": UUID().uuidString, "points": Int.random(in: 40 ... 140)]
            }
        ]
    }

    private func generateMockTrades() -> [String: Any] {
        [
            "trades": Array(0 ..< 5).map { _ in
                [
                    "player_in": UUID().uuidString,
                    "player_out": UUID().uuidString,
                    "price_change": Int.random(in: -50000 ... 50000)
                ]
            }
        ]
    }

    func getMetrics() -> RequestMetrics {
        let now = Date()
        let timeInterval = now.timeIntervalSince(lastMetricsReset)
        let requestsPerMinute = timeInterval > 0 ? Int(Double(requestCount) / timeInterval * 60) : 0
        let averageResponseTime = requestCount > 0 ? totalResponseTime / Double(requestCount) : 0
        let errorRate = requestCount > 0 ? Double(errorCount) / Double(requestCount) : 0

        return RequestMetrics(
            requestsPerMinute: requestsPerMinute,
            averageResponseTime: averageResponseTime,
            bytesSent: bytesSent,
            bytesReceived: bytesReceived,
            errorRate: errorRate
        )
    }
}

// MARK: - ResponseCacheManager

@MainActor
class ResponseCacheManager: ObservableObject {
    private var responseCache: [String: CachedResponse] = [:]
    private var cacheStrategy: NetworkIntelligence.CacheStrategy = .balanced

    private var hitCount = 0
    private var missCount = 0

    struct CachedResponse {
        let data: Any
        let cachedAt: Date
        let etag: String?
        let ttl: TimeInterval
        var accessCount: Int = 1

        var isExpired: Bool {
            Date().timeIntervalSince(cachedAt) > ttl
        }

        var isStale: Bool {
            Date().timeIntervalSince(cachedAt) > ttl / 2
        }
    }

    struct CacheMetrics {
        let hitRate: Double
        let totalEntries: Int
        let cacheSize: Int
    }

    func setCacheStrategy(_ strategy: NetworkIntelligence.CacheStrategy) {
        cacheStrategy = strategy

        // Adjust existing cache entries if needed
        adjustCacheForStrategy()
    }

    func cache(key: String, data: Any, etag: String? = nil, customTTL: TimeInterval? = nil) {
        let ttl = customTTL ?? cacheStrategy.defaultTTL

        responseCache[key] = CachedResponse(
            data: data,
            cachedAt: Date(),
            etag: etag,
            ttl: ttl
        )
    }

    func getCached(key: String) -> Any? {
        guard let cachedResponse = responseCache[key] else {
            missCount += 1
            return nil
        }

        if cachedResponse.isExpired {
            responseCache.removeValue(forKey: key)
            missCount += 1
            return nil
        }

        // Update access count
        responseCache[key]?.accessCount += 1
        hitCount += 1

        return cachedResponse.data
    }

    func getCachedPlayers(playerIds: [UUID]) async -> [AFLPlayer]? {
        let cacheKey = "players_\(playerIds.sorted().map(\.uuidString).joined())"
        return getCached(key: cacheKey) as? [AFLPlayer]
    }

    func shouldRevalidate(key: String) -> Bool {
        guard let cachedResponse = responseCache[key] else { return true }
        return cachedResponse.isStale
    }

    private func adjustCacheForStrategy() {
        // Clean up cache based on new strategy
        let now = Date()
        let newTTL = cacheStrategy.defaultTTL

        responseCache = responseCache.compactMapValues { response in
            let age = now.timeIntervalSince(response.cachedAt)

            // Keep if still valid under new strategy
            if age < newTTL {
                return CachedResponse(
                    data: response.data,
                    cachedAt: response.cachedAt,
                    etag: response.etag,
                    ttl: newTTL,
                    accessCount: response.accessCount
                )
            }

            return nil
        }
    }

    func getMetrics() -> CacheMetrics {
        let totalRequests = hitCount + missCount
        let hitRate = totalRequests > 0 ? Double(hitCount) / Double(totalRequests) : 0

        return CacheMetrics(
            hitRate: hitRate,
            totalEntries: responseCache.count,
            cacheSize: responseCache.count * 1024 // Rough estimate
        )
    }

    func clearCache() {
        responseCache.removeAll()
        hitCount = 0
        missCount = 0
    }
}

// MARK: - BackgroundRefreshManager

@MainActor
class BackgroundRefreshManager: ObservableObject {
    private var refreshTasks: [String: Task<Void, Never>] = [:]
    private var refreshSchedule: [String: Date] = [:]

    private let criticalEndpoints = [
        "top_players",
        "price_changes",
        "injury_updates",
        "captain_recommendations"
    ]

    func scheduleRefresh(key: String, playerIds: [UUID]) async {
        // Cancel existing refresh task for this key
        refreshTasks[key]?.cancel()

        refreshTasks[key] = Task {
            await performStaleWhileRevalidate(key: key, playerIds: playerIds)
        }
    }

    private func performStaleWhileRevalidate(key: String, playerIds: [UUID]) async {
        let cacheManager = ResponseCacheManager()

        // If we have stale data, return it immediately and refresh in background
        if cacheManager.shouldRevalidate(key: key) {
            // Background refresh
            do {
                let freshData = try await NetworkIntelligence.shared.fetchPlayerData(playerIds: playerIds)
                cacheManager.cache(key: key, data: freshData)
                print("🔄 Background refresh completed for \(key)")
            } catch {
                print("⚠️ Background refresh failed for \(key): \(error)")
            }
        }
    }

    func preloadCriticalEndpoints() async {
        await withTaskGroup(of: Void.self) { group in
            for endpoint in criticalEndpoints {
                group.addTask {
                    await self.preloadEndpoint(endpoint)
                }
            }
        }
    }

    private func preloadEndpoint(_ endpoint: String) async {
        // Skip if recently refreshed
        if let lastRefresh = refreshSchedule[endpoint],
           Date().timeIntervalSince(lastRefresh) < 300
        { // 5 minutes
            return
        }

        refreshSchedule[endpoint] = Date()

        // Simulate preloading critical data
        try? await Task.sleep(nanoseconds: UInt64.random(in: 100_000_000 ... 500_000_000))
        print("📥 Preloaded critical endpoint: \(endpoint)")
    }

    func cancelAllRefreshTasks() {
        for task in refreshTasks.values {
            task.cancel()
        }
        refreshTasks.removeAll()
    }
}

// MARK: - NetworkError

enum NetworkError: Error, LocalizedError {
    case offline
    case timeout
    case serverError(Int)
    case invalidResponse
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .offline:
            "No internet connection available"
        case .timeout:
            "Request timed out"
        case let .serverError(code):
            "Server error: \(code)"
        case .invalidResponse:
            "Invalid response from server"
        case .rateLimited:
            "Too many requests - please try again later"
        }
    }
}

// MARK: - Helper Extensions

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Network Status View

struct NetworkStatusView: View {
    @StateObject private var networkIntelligence = NetworkIntelligence.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Connection Status
            HStack {
                Image(systemName: networkIntelligence.connectionStatus.icon)
                    .foregroundColor(statusColor)

                Text(networkIntelligence.connectionStatus.description)
                    .font(.headline)

                Spacer()

                Text(networkIntelligence.optimizationLevel.description)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(8)
            }

            // Network Metrics
            VStack(alignment: .leading, spacing: 8) {
                metricRow("Requests/min", value: "\(networkIntelligence.networkMetrics.requestsPerMinute)")
                metricRow(
                    "Avg Response",
                    value: String(format: "%.0fms", networkIntelligence.networkMetrics.averageResponseTime * 1000)
                )
                metricRow(
                    "Cache Hit Rate",
                    value: String(format: "%.1f%%", networkIntelligence.networkMetrics.cacheHitRate * 100)
                )
                metricRow("Data Usage", value: networkIntelligence.networkMetrics.dataUsage.formattedTotal)
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private var statusColor: Color {
        switch networkIntelligence.connectionStatus {
        case .wifi, .ethernet: .green
        case .cellular: .orange
        case .offline: .red
        case .unknown: .gray
        }
    }

    private func metricRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

extension NetworkIntelligence.OptimizationLevel {
    var description: String {
        switch self {
        case .aggressive: "Aggressive"
        case .balanced: "Balanced"
        case .conservative: "Conservative"
        }
    }
}
