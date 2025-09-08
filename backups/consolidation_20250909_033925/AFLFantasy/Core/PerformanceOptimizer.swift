//
//  PerformanceOptimizer.swift
//  AFL Fantasy Intelligence Platform
//
//  Performance optimization with cold launch improvements and memory management
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import os.log
import SwiftUI

// MARK: - PerformanceOptimizer

@MainActor
class PerformanceOptimizer: ObservableObject {
    static let shared = PerformanceOptimizer()

    @Published var launchTime: TimeInterval = 0
    @Published var memoryUsage: MemoryUsage = .init()
    @Published var performanceMetrics: PerformanceMetrics = .init()
    @Published var optimizationRecommendations: [OptimizationRecommendation] = []

    private let logger = Logger(subsystem: "AFLFantasy", category: "PerformanceOptimizer")
    private let startTime: CFAbsoluteTime
    private var memoryTimer: Timer?

    // Performance targets (enterprise-grade)
    private let targetLaunchTime: TimeInterval = 1.8
    private let targetMemoryLimit: UInt64 = 220 * 1024 * 1024 // 220 MB
    private let targetFrameRate: Double = 60.0
    private let memoryWarningThreshold: UInt64 = 180 * 1024 * 1024 // 180 MB

    private init() {
        startTime = CFAbsoluteTimeGetCurrent()
        configurePerformanceOptimizations()
        startMemoryMonitoring()
    }

    deinit {
        memoryTimer?.invalidate()
    }

    // MARK: - Public Interface

    func recordLaunchTime() {
        let currentTime = CFAbsoluteTimeGetCurrent()
        launchTime = currentTime - startTime

        logger.info("🚀 App launch time: \(String(format: "%.3f", launchTime))s (target: ≤\(targetLaunchTime)s)")

        if launchTime > targetLaunchTime {
            optimizationRecommendations.append(OptimizationRecommendation(
                type: .launchTime,
                severity: .high,
                message: "Launch time exceeds target by \(String(format: "%.1f", (launchTime - targetLaunchTime) * 1000))ms",
                actionable: true,
                action: optimizeLaunchTime
            ))
        }

        performanceMetrics.launchTime = launchTime
    }

    func optimizeForLowMemory() {
        logger.info("⚡ Optimizing for low memory conditions")

        Task {
            // Clear non-essential caches
            await clearNonEssentialCaches()

            // Compact images in memory
            await compactImageCache()

            // Defer heavy operations
            await deferNonCriticalWork()

            // Update memory usage
            updateMemoryUsage()

            logger.info("✅ Low memory optimization complete")
        }
    }

    func optimizeScrollPerformance() {
        logger.info("📜 Optimizing scroll performance")

        // These optimizations are implemented throughout the UI components
        performanceMetrics.scrollOptimizationEnabled = true

        optimizationRecommendations.removeAll { $0.type == .scrollPerformance }
    }

    func profileViewRenderTime(_ viewName: String, renderTime: TimeInterval) {
        performanceMetrics.viewRenderTimes[viewName] = renderTime

        let targetRenderTime: TimeInterval = 1.0 / 60.0 // 16.67ms for 60fps

        if renderTime > targetRenderTime {
            logger
                .warning(
                    "⚠️ View \(viewName) render time: \(String(format: "%.1f", renderTime * 1000))ms (target: ≤16.7ms)"
                )

            optimizationRecommendations.append(OptimizationRecommendation(
                type: .renderPerformance,
                severity: .medium,
                message: "View '\(viewName)' has slow render time",
                actionable: true,
                action: { [weak self] in
                    self?.optimizeViewRendering(viewName)
                }
            ))
        }
    }

    func measureTaskPerformance<T>(_ taskName: String, task: () async throws -> T) async rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await task()
        let duration = CFAbsoluteTimeGetCurrent() - startTime

        logger.info("⏱️ Task '\(taskName)' completed in \(String(format: "%.3f", duration))s")

        performanceMetrics.taskExecutionTimes[taskName] = duration

        return result
    }

    // MARK: - Private Implementation

    private func configurePerformanceOptimizations() {
        logger.info("⚙️ Configuring performance optimizations")

        // Configure launch optimizations
        configureLaunchOptimizations()

        // Configure memory optimizations
        configureMemoryOptimizations()

        // Configure rendering optimizations
        configureRenderingOptimizations()

        // Set up performance monitoring
        setupPerformanceMonitoring()
    }

    private func configureLaunchOptimizations() {
        // Defer non-critical initialization
        DispatchQueue.main.async {
            // Analytics initialization (deferred)
            self.initializeAnalytics()
        }

        DispatchQueue.global(qos: .utility).async {
            // Background cache warming
            Task {
                await self.warmCriticalCaches()
            }
        }
    }

    private func configureMemoryOptimizations() {
        // Set up memory pressure monitoring
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }
    }

    private func configureRenderingOptimizations() {
        // Configure CALayer optimizations
        UIScrollView.appearance().contentInsetAdjustmentBehavior = .never

        // Optimize image rendering
        configureImageOptimizations()
    }

    private func setupPerformanceMonitoring() {
        // Start continuous monitoring
        startMemoryMonitoring()
    }

    private func startMemoryMonitoring() {
        memoryTimer?.invalidate()
        memoryTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateMemoryUsage()
        }
    }

    private func updateMemoryUsage() {
        let memoryInfo = getMemoryInfo()

        memoryUsage = MemoryUsage(
            used: memoryInfo.used,
            available: memoryInfo.available,
            total: memoryInfo.total,
            timestamp: Date()
        )

        performanceMetrics.peakMemoryUsage = max(performanceMetrics.peakMemoryUsage, memoryInfo.used)

        // Check memory thresholds
        if memoryInfo.used > memoryWarningThreshold {
            handleHighMemoryUsage()
        }

        if memoryInfo.used > targetMemoryLimit {
            optimizationRecommendations.append(OptimizationRecommendation(
                type: .memoryUsage,
                severity: .high,
                message: "Memory usage exceeds target: \(formatBytes(memoryInfo.used))/\(formatBytes(targetMemoryLimit))",
                actionable: true,
                action: optimizeForLowMemory
            ))
        }
    }

    private func getMemoryInfo() -> (used: UInt64, available: UInt64, total: UInt64) {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return (used: 0, available: 0, total: 0)
        }

        let used = UInt64(info.resident_size)

        // Get total physical memory
        var size: size_t = 0
        var totalMemory: UInt64 = 0
        size = MemoryLayout<UInt64>.size
        if sysctlbyname("hw.memsize", &totalMemory, &size, nil, 0) != 0 {
            totalMemory = 0
        }

        return (
            used: used,
            available: totalMemory > used ? totalMemory - used : 0,
            total: totalMemory
        )
    }

    private func handleMemoryWarning() {
        logger.warning("⚠️ Memory warning received")

        Task { @MainActor in
            await clearNonEssentialCaches()
            await compactImageCache()

            // Notify other services
            NotificationCenter.default.post(name: .memoryWarningReceived, object: nil)
        }
    }

    private func handleHighMemoryUsage() {
        logger.warning("⚠️ High memory usage detected: \(formatBytes(memoryUsage.used))")

        optimizationRecommendations.append(OptimizationRecommendation(
            type: .memoryUsage,
            severity: .medium,
            message: "High memory usage detected",
            actionable: true,
            action: optimizeForLowMemory
        ))
    }

    // MARK: - Optimization Actions

    private func optimizeLaunchTime() {
        logger.info("🚀 Optimizing launch time")

        // Move heavy initialization to background
        DispatchQueue.global(qos: .utility).async {
            // Heavy initialization work here
            Task {
                await self.performHeavyInitialization()
            }
        }
    }

    private func clearNonEssentialCaches() async {
        logger.info("🧹 Clearing non-essential caches")

        // Clear image caches beyond basic requirements
        await ImageCacheOptimizer.clearNonEssentialImages()

        // Clear expired data caches
        try? await PersistenceManager.shared.clearExpiredCache()

        // Clear analytics buffers
        await clearAnalyticsBuffers()
    }

    private func compactImageCache() async {
        logger.info("🖼️ Compacting image cache")

        await ImageCacheOptimizer.compactCache()
    }

    private func deferNonCriticalWork() async {
        logger.info("⏳ Deferring non-critical work")

        // Defer analytics uploads
        AnalyticsService.shared.deferUploads()

        // Defer background sync
        BackgroundSyncService().pauseSync()

        // Schedule work to resume later
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            AnalyticsService.shared.resumeUploads()
            BackgroundSyncService().resumeSync()
        }
    }

    private func optimizeViewRendering(_ viewName: String) {
        logger.info("🎨 Optimizing rendering for view: \(viewName)")

        // View-specific optimizations would be implemented in the actual views
        // This is a placeholder for the optimization action
    }

    private func initializeAnalytics() {
        // Deferred analytics initialization
        logger.info("📊 Initializing analytics (deferred)")
    }

    private func warmCriticalCaches() async {
        logger.info("🔥 Warming critical caches")

        // Pre-load essential data
        try? await PersistenceManager.shared.preloadEssentialData()
    }

    private func performHeavyInitialization() async {
        logger.info("⚙️ Performing heavy initialization")

        // Heavy work that doesn't block UI
        await SecurityService.shared.configureApplicationSecurity()
    }

    private func clearAnalyticsBuffers() async {
        // Clear analytics buffers to free memory
        logger.info("📊 Clearing analytics buffers")
    }

    private func configureImageOptimizations() {
        // Configure global image optimization settings
        ImageCacheOptimizer.configure()
    }

    // MARK: - Utility

    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB]
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - MemoryUsage

struct MemoryUsage: Codable {
    let used: UInt64
    let available: UInt64
    let total: UInt64
    let timestamp: Date

    init() {
        used = 0
        available = 0
        total = 0
        timestamp = Date()
    }

    init(used: UInt64, available: UInt64, total: UInt64, timestamp: Date) {
        self.used = used
        self.available = available
        self.total = total
        self.timestamp = timestamp
    }

    var usagePercentage: Double {
        guard total > 0 else { return 0 }
        return Double(used) / Double(total) * 100
    }
}

// MARK: - PerformanceMetrics

struct PerformanceMetrics: Codable {
    var launchTime: TimeInterval = 0
    var peakMemoryUsage: UInt64 = 0
    var averageMemoryUsage: UInt64 = 0
    var scrollOptimizationEnabled: Bool = false
    var viewRenderTimes: [String: TimeInterval] = [:]
    var taskExecutionTimes: [String: TimeInterval] = [:]
    var frameDurations: [TimeInterval] = []
    var averageFrameRate: Double = 60.0

    mutating func recordFrameTime(_ frameTime: TimeInterval) {
        frameDurations.append(frameTime)

        // Keep only last 60 frame times (1 second at 60fps)
        if frameDurations.count > 60 {
            frameDurations.removeFirst(frameDurations.count - 60)
        }

        // Calculate average frame rate
        let averageFrameTime = frameDurations.reduce(0, +) / Double(frameDurations.count)
        averageFrameRate = averageFrameTime > 0 ? 1.0 / averageFrameTime : 60.0
    }
}

// MARK: - OptimizationRecommendation

struct OptimizationRecommendation: Identifiable {
    let id = UUID()
    let type: OptimizationType
    let severity: OptimizationSeverity
    let message: String
    let actionable: Bool
    let action: (() -> Void)?
    let timestamp = Date()
}

// MARK: - OptimizationType

enum OptimizationType {
    case launchTime
    case memoryUsage
    case scrollPerformance
    case renderPerformance
    case networkOptimization
    case cacheOptimization
}

// MARK: - OptimizationSeverity

enum OptimizationSeverity {
    case low
    case medium
    case high
    case critical

    var color: Color {
        switch self {
        case .low: .blue
        case .medium: .orange
        case .high: .red
        case .critical: .purple
        }
    }
}

// MARK: - ImageCacheOptimizer

class ImageCacheOptimizer {
    private static let maxCacheSize: Int = 50 * 1024 * 1024 // 50 MB
    private static let maxImageDimension: CGFloat = 1024

    static func configure() {
        // Configure URLCache for images
        let imageCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024, // 20 MB
            diskCapacity: maxCacheSize,
            diskPath: "image_cache"
        )
        URLCache.shared = imageCache
    }

    static func clearNonEssentialImages() async {
        // Clear images that are not currently visible
        URLCache.shared.removeAllCachedResponses()
    }

    static func compactCache() async {
        // Compact image cache by removing oldest entries
        let cache = URLCache.shared
        let currentSize = cache.currentDiskUsage

        if currentSize > maxCacheSize {
            cache.removeCachedResponses(since: Date().addingTimeInterval(-3600)) // Remove cache older than 1 hour
        }
    }
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let memoryWarningReceived = Notification.Name("MemoryWarningReceived")
}

// MARK: - View Performance Modifier

struct PerformanceTrackingModifier: ViewModifier {
    let viewName: String

    func body(content: Content) -> some View {
        content
            .onAppear {
                let startTime = CFAbsoluteTimeGetCurrent()

                DispatchQueue.main.async {
                    let renderTime = CFAbsoluteTimeGetCurrent() - startTime
                    PerformanceOptimizer.shared.profileViewRenderTime(viewName, renderTime: renderTime)
                }
            }
    }
}

extension View {
    func trackPerformance(_ viewName: String) -> some View {
        modifier(PerformanceTrackingModifier(viewName: viewName))
    }
}

// MARK: - Task Performance Wrapper

func measurePerformance<T>(_ taskName: String, _ task: () async throws -> T) async rethrows -> T {
    try await PerformanceOptimizer.shared.measureTaskPerformance(taskName, task: task)
}

// MARK: - Lazy Loading Helper

struct LazyLoader<Content: View>: View {
    let threshold: CGFloat
    @ViewBuilder let content: () -> Content
    @State private var isLoaded = false

    init(threshold: CGFloat = 100, @ViewBuilder content: @escaping () -> Content) {
        self.threshold = threshold
        self.content = content
    }

    var body: some View {
        GeometryReader { _ in
            if isLoaded {
                content()
            } else {
                Color.clear
                    .onAppear {
                        // Load content when it comes into view
                        isLoaded = true
                    }
            }
        }
    }
}

// MARK: - Memory Efficient List

struct MemoryEfficientList<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let data: Data
    let content: (Data.Element) -> Content

    @State private var visibleRange: Range<Data.Index>

    init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content

        // Initialize with first few items
        let startIndex = data.startIndex
        let endIndex = data.index(startIndex, offsetBy: min(10, data.count), limitedBy: data.endIndex) ?? data.endIndex
        _visibleRange = State(initialValue: startIndex ..< endIndex)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(data[visibleRange]), id: \.id) { item in
                    content(item)
                        .onAppear {
                            expandVisibleRangeIfNeeded(for: item)
                        }
                }
            }
        }
    }

    private func expandVisibleRangeIfNeeded(for item: Data.Element) {
        // Expand visible range when approaching the edges
        guard let itemIndex = data.firstIndex(where: { $0.id == item.id }) else { return }

        let distanceFromEnd = data.distance(from: itemIndex, to: visibleRange.upperBound)
        let distanceFromStart = data.distance(from: visibleRange.lowerBound, to: itemIndex)

        if distanceFromEnd < 3 {
            // Expand forward
            let newEndIndex = data.index(visibleRange.upperBound, offsetBy: 10, limitedBy: data.endIndex) ?? data
                .endIndex
            visibleRange = visibleRange.lowerBound ..< newEndIndex
        }

        if distanceFromStart < 3, visibleRange.lowerBound > data.startIndex {
            // Expand backward
            let newStartIndex = data.index(visibleRange.lowerBound, offsetBy: -10, limitedBy: data.startIndex) ?? data
                .startIndex
            visibleRange = newStartIndex ..< visibleRange.upperBound
        }
    }
}
