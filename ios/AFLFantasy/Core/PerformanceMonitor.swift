//
//  PerformanceMonitor.swift
//  AFL Fantasy Intelligence Platform
//
//  Performance monitoring and optimization utilities
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation
import os
import SwiftUI

// MARK: - PerformanceMonitor

/// Monitor app performance to ensure iOS standards compliance
@MainActor
class PerformanceMonitor: ObservableObject {
    static let shared = PerformanceMonitor()

    private let logger = Logger(subsystem: "com.aflfantasy.app", category: "Performance")

    @Published var isMonitoring = false
    @Published var coldStartTime: TimeInterval?
    @Published var memoryUsage: Double = 0
    @Published var averageFrameTime: Double = 0

    private var appLaunchTime: Date?
    private var frameTimeHistory: [Double] = []
    private var memoryTimer: Timer?

    private init() {
        setupMonitoring()
    }

    // MARK: - Public Methods

    func startColdStartTimer() {
        appLaunchTime = Date()
        logger.info("🚀 Cold start timer started")
    }

    func endColdStartTimer() {
        guard let startTime = appLaunchTime else { return }

        let coldStart = Date().timeIntervalSince(startTime)
        coldStartTime = coldStart

        logger.info("⏱️ Cold start completed: \(coldStart, format: .fixed(precision: 2))s")

        // HIG Performance Budget: Cold launch ≤ 1.8s
        if coldStart > 1.8 {
            logger.warning("⚠️ Cold start exceeded 1.8s budget: \(coldStart, format: .fixed(precision: 2))s")
        } else {
            logger.info("✅ Cold start within budget")
        }

        appLaunchTime = nil
    }

    func recordFrameTime(_ frameTime: Double) {
        frameTimeHistory.append(frameTime)

        // Keep only last 60 frames for rolling average
        if frameTimeHistory.count > 60 {
            frameTimeHistory.removeFirst()
        }

        averageFrameTime = frameTimeHistory.reduce(0, +) / Double(frameTimeHistory.count)

        // HIG Performance Budget: ≥ 58 FPS (≤ 17.2ms per frame)
        if frameTime > 17.2 {
            logger.warning("⚠️ Frame time exceeded budget: \(frameTime, format: .fixed(precision: 2))ms")
        }
    }

    func getCurrentMemoryUsage() -> Double {
        let info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(
                    mach_task_self_,
                    task_flavor_t(MACH_TASK_BASIC_INFO),
                    $0,
                    &count
                )
            }
        }

        if kerr == KERN_SUCCESS {
            return Double(info.resident_size) / 1024 / 1024 // Convert to MB
        } else {
            return 0
        }
    }

    // MARK: - Private Methods

    private func setupMonitoring() {
        // Start memory monitoring
        memoryTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self else { return }

            Task { @MainActor in
                self.memoryUsage = self.getCurrentMemoryUsage()

                // HIG Performance Budget: Steady dashboard ≤ 220 MB
                if self.memoryUsage > 220 {
                    self.logger
                        .warning("⚠️ Memory usage exceeded budget: \(self.memoryUsage, format: .fixed(precision: 1))MB")
                }
            }
        }

        isMonitoring = true
        logger.info("📊 Performance monitoring started")
    }

    deinit {
        memoryTimer?.invalidate()
    }
}

// MARK: - Performance Measurement Extensions

extension View {
    /// Measure and log the performance of view rendering
    func measurePerformance(label: String) -> some View {
        let startTime = CFAbsoluteTimeGetCurrent()

        return onAppear {
            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            Logger(subsystem: "com.aflfantasy.app", category: "ViewPerformance")
                .info("🎨 \(label) rendered in \(timeElapsed * 1000, format: .fixed(precision: 2))ms")
        }
    }
}

// MARK: - Memory Optimization

/// Utility for optimizing memory usage in lists and collections
enum LazyImageCache {
    private static var cache: [String: UIImage] = [:]
    private static let cacheQueue = DispatchQueue(label: "image-cache", qos: .utility)

    static func image(for key: String) -> UIImage? {
        cacheQueue.sync {
            cache[key]
        }
    }

    static func setImage(_ image: UIImage, for key: String) {
        cacheQueue.async {
            // Limit cache size to prevent memory pressure
            if cache.count > 100 {
                // Remove oldest 20% of cached images
                let keysToRemove = Array(cache.keys.prefix(20))
                keysToRemove.forEach { cache.removeValue(forKey: $0) }
            }

            cache[key] = image
        }
    }

    static func clearCache() {
        cacheQueue.async {
            cache.removeAll()
        }
    }
}

// MARK: - Background Task Management

/// Ensures background tasks are properly managed for battery optimization
@MainActor
class BackgroundTaskManager: ObservableObject {
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func beginBackgroundTask(name: String) {
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: name) { [weak self] in
            self?.endBackgroundTask()
        }
    }

    func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}

// MARK: - Network Request Optimization

extension URLSession {
    /// Optimized network configuration for AFL Fantasy
    static let aflOptimized: URLSession = {
        let config = URLSessionConfiguration.default

        // Battery optimization
        config.allowsCellularAccess = true
        config.allowsExpensiveNetworkAccess = true
        config.allowsConstrainedNetworkAccess = true

        // Performance optimization
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 30.0
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(
            memoryCapacity: 10 * 1024 * 1024, // 10MB
            diskCapacity: 50 * 1024 * 1024
        ) // 50MB

        // HTTP/2 and compression
        config.httpMaximumConnectionsPerHost = 4
        config.httpShouldUsePipelining = true

        return URLSession(configuration: config)
    }()
}

// MARK: - Performance Helpers

extension Double {
    /// Format double for performance logging
    func format(precision: Int) -> String {
        String(format: "%.\(precision)f", self)
    }
}

// MARK: - Logging Optimizations

extension Logger {
    /// Performance-optimized logging that respects system settings
    func performanceLog(_ message: String, level: OSLogType = .info) {
        #if DEBUG
            log(level: level, "\(message)")
        #else
            // In release, only log warnings and errors for performance
            if level == .error || level == .fault {
                log(level: level, "\(message)")
            }
        #endif
    }
}
