//
//  BackgroundSyncService.swift
//  AFL Fantasy Intelligence Platform
//
//  Background sync with intelligent refresh patterns and offline support
//  Created by AI Assistant on 6/9/2025.
//

import BackgroundTasks
import Foundation
import os.log
import SwiftUI

// MARK: - BackgroundSyncService

@MainActor
class BackgroundSyncService: ObservableObject {
    @Published var lastSyncTime: Date?
    @Published var isSyncing: Bool = false
    @Published var syncProgress: Double = 0.0
    @Published var syncError: SyncError?
    @Published var nextScheduledSync: Date?
    @Published var syncStats: SyncStatistics = .init()

    private let repository: AFLFantasyRepository
    private let persistenceManager: PersistenceManager
    private let logger = Logger(subsystem: "AFLFantasy", category: "BackgroundSyncService")

    private var syncTimer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private let backgroundTaskIdentifier = "com.aflfantasy.background-sync"

    // Sync configuration
    private let normalRefreshInterval: TimeInterval = 300 // 5 minutes
    private let liveMatchRefreshInterval: TimeInterval = 60 // 1 minute during live matches
    private let offlineRetryInterval: TimeInterval = 30 // 30 seconds when offline
    private let maxBackgroundSyncDuration: TimeInterval = 25 // 25 seconds max for background tasks

    init(
        repository: AFLFantasyRepository = AFLFantasyRepository(),
        persistenceManager: PersistenceManager = PersistenceManager.shared
    ) {
        self.repository = repository
        self.persistenceManager = persistenceManager

        setupBackgroundTaskRegistration()
        setupNotificationObservers()
        startPeriodicSync()
    }

    deinit {
        syncTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public Interface

    func syncNow(force: Bool = false) async {
        guard !isSyncing || force else {
            logger.info("🔄 Sync already in progress, skipping")
            return
        }

        await performSync(isBackground: false)
    }

    func scheduleBackgroundSync() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: normalRefreshInterval)

        do {
            try BGTaskScheduler.shared.submit(request)
            nextScheduledSync = request.earliestBeginDate
            logger.info("📅 Background sync scheduled for \(request.earliestBeginDate?.formatted() ?? "unknown")")
        } catch {
            logger.error("❌ Failed to schedule background sync: \(error.localizedDescription)")
        }
    }

    func pauseSync() {
        syncTimer?.invalidate()
        syncTimer = nil
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: backgroundTaskIdentifier)
        logger.info("⏸️ Sync paused")
    }

    func resumeSync() {
        startPeriodicSync()
        scheduleBackgroundSync()
        logger.info("▶️ Sync resumed")
    }

    // MARK: - Private Implementation

    private func setupBackgroundTaskRegistration() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                self.logger.error("❌ Expected BGAppRefreshTask but got \(type(of: task))")
                task.setTaskCompleted(success: false)
                return
            }
            self.handleBackgroundSync(task: refreshTask)
        }
    }

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.scheduleBackgroundSync()
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.syncNow()
            }
        }

        NotificationCenter.default.addObserver(
            forName: .networkConnectivityRestored,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                // Sync immediately when connectivity is restored
                await self?.syncNow()
            }
        }
    }

    private func startPeriodicSync() {
        syncTimer?.invalidate()

        let interval = determineRefreshInterval()

        syncTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task {
                await self?.performSync(isBackground: false)
            }
        }

        logger.info("⏰ Periodic sync started with \(interval)s interval")
    }

    private func determineRefreshInterval() -> TimeInterval {
        // Check if there are live matches
        let isLiveMatch = isCurrentlyLiveMatch()

        if isLiveMatch {
            return liveMatchRefreshInterval
        } else {
            return normalRefreshInterval
        }
    }

    private func isCurrentlyLiveMatch() -> Bool {
        // In a real implementation, this would check if there are active AFL matches
        let currentHour = Calendar.current.component(.hour, from: Date())
        let currentWeekday = Calendar.current.component(.weekday, from: Date())

        // Simulate match times: Friday 7-10pm, Saturday 1-10pm, Sunday 1-6pm
        switch currentWeekday {
        case 6: // Friday
            return currentHour >= 19 && currentHour <= 22
        case 7: // Saturday
            return currentHour >= 13 && currentHour <= 22
        case 1: // Sunday
            return currentHour >= 13 && currentHour <= 18
        default:
            return false
        }
    }

    private func performSync(isBackground: Bool) async {
        let syncStartTime = Date()

        if isBackground {
            backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "AFL Fantasy Sync") { [weak self] in
                self?.endBackgroundTask()
            }
        }

        defer {
            if isBackground {
                endBackgroundTask()
            }
        }

        isSyncing = true
        syncProgress = 0.0
        syncError = nil

        logger.info("🔄 Starting \(isBackground ? "background" : "foreground") sync")

        do {
            // Phase 1: Sync team data (20% progress)
            syncProgress = 0.1
            let teamData = try await repository.fetchTeamData()
            await persistenceManager.cacheTeamData(teamData)
            syncProgress = 0.2

            // Phase 2: Sync player data (60% progress)
            syncProgress = 0.25
            let players = try await repository.fetchAllPlayers()
            await persistenceManager.cachePlayers(players)
            syncProgress = 0.6

            // Phase 3: Sync live scores if applicable (80% progress)
            if isCurrentlyLiveMatch() {
                syncProgress = 0.65
                let liveScores = try await repository.fetchLiveScores()
                await persistenceManager.cacheLiveScores(liveScores)
            }
            syncProgress = 0.8

            // Phase 4: Sync projections and analysis (100% progress)
            syncProgress = 0.85
            let projections = try await repository.fetchProjections()
            await persistenceManager.cacheProjections(projections)
            syncProgress = 1.0

            // Update sync statistics
            let syncDuration = Date().timeIntervalSince(syncStartTime)
            await updateSyncStatistics(success: true, duration: syncDuration, isBackground: isBackground)

            lastSyncTime = Date()
            isSyncing = false

            logger.info("✅ Sync completed successfully in \(String(format: "%.2f", syncDuration))s")

            // Schedule next background sync
            if !isBackground {
                scheduleBackgroundSync()
            }

        } catch {
            await updateSyncStatistics(
                success: false,
                duration: Date().timeIntervalSince(syncStartTime),
                isBackground: isBackground
            )

            let syncError = SyncError.from(error)
            self.syncError = syncError
            isSyncing = false

            logger.error("❌ Sync failed: \(syncError.localizedDescription)")

            // Schedule retry with exponential backoff
            scheduleRetry(for: syncError)
        }
    }

    private func handleBackgroundSync(task: BGAppRefreshTask) {
        logger.info("🔄 Handling background sync task")

        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        Task {
            await performSync(isBackground: true)
            task.setTaskCompleted(success: self.syncError == nil)

            // Schedule next background sync
            self.scheduleBackgroundSync()
        }
    }

    private func scheduleRetry(for error: SyncError) {
        let retryInterval: TimeInterval = switch error {
        case .networkUnavailable:
            offlineRetryInterval
        case .serverError, .rateLimited:
            normalRefreshInterval * 2 // Double the normal interval
        case .authenticationFailed:
            normalRefreshInterval * 4 // Wait longer for auth issues
        case .dataCorruption, .unknown:
            normalRefreshInterval
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) { [weak self] in
            Task {
                await self?.performSync(isBackground: false)
            }
        }

        logger.info("⏰ Retry scheduled in \(retryInterval)s for error: \(error.localizedDescription)")
    }

    private func updateSyncStatistics(success: Bool, duration: TimeInterval, isBackground: Bool) async {
        if success {
            syncStats.successfulSyncs += 1
            syncStats.totalSyncDuration += duration
            syncStats.averageSyncDuration = syncStats.totalSyncDuration / Double(syncStats.successfulSyncs)
        } else {
            syncStats.failedSyncs += 1
        }

        if isBackground {
            syncStats.backgroundSyncs += 1
        }

        syncStats.lastSyncDuration = duration
        syncStats.totalSyncs = syncStats.successfulSyncs + syncStats.failedSyncs
        syncStats.successRate = Double(syncStats.successfulSyncs) / Double(syncStats.totalSyncs)
    }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}

// MARK: - SyncError

enum SyncError: Error, LocalizedError {
    case networkUnavailable
    case serverError(Int)
    case rateLimited(retryAfter: TimeInterval?)
    case authenticationFailed
    case dataCorruption(String)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            "Network connection is unavailable"
        case let .serverError(code):
            "Server error (HTTP \(code))"
        case let .rateLimited(retryAfter):
            if let retryAfter {
                "Rate limited. Retry after \(Int(retryAfter)) seconds"
            } else {
                "Rate limited. Please try again later"
            }
        case .authenticationFailed:
            "Authentication failed. Please log in again"
        case let .dataCorruption(details):
            "Data corruption detected: \(details)"
        case let .unknown(error):
            "Sync failed: \(error.localizedDescription)"
        }
    }

    static func from(_ error: Error) -> SyncError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost:
                return .networkUnavailable
            default:
                return .unknown(urlError)
            }
        }

        if let httpError = error as? HTTPError {
            switch httpError.statusCode {
            case 401, 403:
                return .authenticationFailed
            case 429:
                return .rateLimited(retryAfter: httpError.retryAfter)
            case 500 ... 599:
                return .serverError(httpError.statusCode)
            default:
                return .unknown(httpError)
            }
        }

        return .unknown(error)
    }
}

// MARK: - SyncStatistics

struct SyncStatistics: Codable {
    var totalSyncs: Int = 0
    var successfulSyncs: Int = 0
    var failedSyncs: Int = 0
    var backgroundSyncs: Int = 0
    var totalSyncDuration: TimeInterval = 0
    var averageSyncDuration: TimeInterval = 0
    var lastSyncDuration: TimeInterval = 0
    var successRate: Double = 0

    var formattedAverageTime: String {
        String(format: "%.2fs", averageSyncDuration)
    }

    var formattedSuccessRate: String {
        String(format: "%.1f%%", successRate * 100)
    }
}

// MARK: - HTTPError

struct HTTPError: Error {
    let statusCode: Int
    let retryAfter: TimeInterval?

    init(statusCode: Int, retryAfter: TimeInterval? = nil) {
        self.statusCode = statusCode
        self.retryAfter = retryAfter
    }
}

// MARK: - BackgroundSyncModifier

struct BackgroundSyncModifier: ViewModifier {
    @StateObject private var syncService = BackgroundSyncService()

    func body(content: Content) -> some View {
        content
            .environmentObject(syncService)
            .task {
                // Perform initial sync when app launches
                await syncService.syncNow()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // Sync when app becomes active
                Task {
                    await syncService.syncNow()
                }
            }
    }
}

extension View {
    func backgroundSync() -> some View {
        modifier(BackgroundSyncModifier())
    }
}
