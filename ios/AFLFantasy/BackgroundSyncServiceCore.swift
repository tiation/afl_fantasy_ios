//
//  BackgroundSyncServiceCore.swift
//  AFL Fantasy Intelligence Platform
//
//  Background sync service integrated into main target
//  Created by AI Assistant on 6/9/2025.
//

import BackgroundTasks
import Foundation
import os.log
import SwiftUI

// MARK: - BackgroundSyncService

@MainActor
class BackgroundSyncService: ObservableObject {
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncTime: Date?
    @Published var syncError: SyncError?
    @Published var syncStats = SyncStatistics()

    private let logger = Logger(subsystem: "AFLFantasy", category: "BackgroundSync")
    private let backgroundTaskIdentifier = "com.afl.ai.AFLFantasy.background-refresh"

    // Configuration
    private let normalRefreshInterval: TimeInterval = 300 // 5 minutes
    private let offlineRetryInterval: TimeInterval = 60 // 1 minute
    private let maxRetryAttempts = 3

    // Background task management
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var currentRetryAttempt = 0

    init() {
        registerBackgroundTasks()
    }

    // MARK: - Public Methods

    func syncNow() async {
        await performSync(isBackground: false)
    }

    func scheduleBackgroundSync() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: normalRefreshInterval)

        do {
            try BGTaskScheduler.shared.submit(request)
            logger.info("📅 Background sync scheduled for \\(request.earliestBeginDate?.description ?? \"unknown\")")
        } catch {
            logger.error("❌ Failed to schedule background sync: \\(error.localizedDescription)")
        }
    }

    func cancelBackgroundSync() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: backgroundTaskIdentifier)
        logger.info("🚫 Background sync cancelled")
    }

    // MARK: - Private Methods

    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: nil
        ) { [weak self] task in
            guard let self else { return }

            Task {
                await self.handleBackgroundSync(task: task as! BGAppRefreshTask)
            }
        }

        logger.info("📋 Background tasks registered")
    }

    private func performSync(isBackground: Bool) async {
        let startTime = Date()

        syncStatus = .syncing
        syncError = nil

        logger.info("🔄 Starting sync (background: \\(isBackground))")

        // Begin background task to prevent termination
        if !isBackground {
            backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
                self?.endBackgroundTask()
            }
        }

        do {
            // Simulate sync operations
            try await syncPlayerData()
            try await syncRoundData()
            try await syncUserTeam()

            // Update sync status
            lastSyncTime = Date()
            syncStatus = .completed
            currentRetryAttempt = 0

            let duration = Date().timeIntervalSince(startTime)
            await updateSyncStatistics(success: true, duration: duration, isBackground: isBackground)

            logger.info("✅ Sync completed successfully in \\(String(format: \"%.2f\", duration))s")

            // Schedule next sync
            if !isBackground {
                scheduleBackgroundSync()
            }

        } catch let error as SyncError {
            syncError = error
            syncStatus = .failed
            currentRetryAttempt += 1

            let duration = Date().timeIntervalSince(startTime)
            await updateSyncStatistics(success: false, duration: duration, isBackground: isBackground)

            logger.error("❌ Sync failed: \\(error.localizedDescription)")

            if currentRetryAttempt < maxRetryAttempts {
                scheduleRetry(for: error)
            }
        } catch {
            let syncError = SyncError.unknown(error)
            self.syncError = syncError
            syncStatus = .failed

            let duration = Date().timeIntervalSince(startTime)
            await updateSyncStatistics(success: false, duration: duration, isBackground: isBackground)

            logger.error("❌ Sync failed with unknown error: \\(error.localizedDescription)")

            scheduleRetry(for: syncError)
        }

        // End background task
        if !isBackground {
            endBackgroundTask()
        }
    }

    private func syncPlayerData() async throws {
        // Simulate API call
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Simulate occasional network errors
        if Bool.random(), currentRetryAttempt == 0 {
            throw SyncError.networkUnavailable
        }

        logger.info("📊 Player data synced")
    }

    private func syncRoundData() async throws {
        // Simulate API call
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        logger.info("🏆 Round data synced")
    }

    private func syncUserTeam() async throws {
        // Simulate API call
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        logger.info("👥 User team data synced")
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

        logger.info("⏰ Retry scheduled in \\(retryInterval)s for error: \\(error.localizedDescription)")
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

// MARK: - SyncStatus

enum SyncStatus {
    case idle
    case syncing
    case completed
    case failed

    var displayText: String {
        switch self {
        case .idle: "Ready"
        case .syncing: "Syncing..."
        case .completed: "Up to date"
        case .failed: "Sync failed"
        }
    }

    var color: Color {
        switch self {
        case .idle: .secondary
        case .syncing: .blue
        case .completed: .green
        case .failed: .red
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
            "Server error (HTTP \\(code))"
        case let .rateLimited(retryAfter):
            if let retryAfter {
                "Rate limited. Retry after \\(Int(retryAfter)) seconds"
            } else {
                "Rate limited. Please try again later"
            }
        case .authenticationFailed:
            "Authentication failed. Please log in again"
        case let .dataCorruption(details):
            "Data corruption detected: \\(details)"
        case let .unknown(error):
            "Sync failed: \\(error.localizedDescription)"
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
