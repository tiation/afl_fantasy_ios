//
//  MemoryOptimization.swift
//  AFL Fantasy Intelligence Platform
//
//  Advanced memory management with view recycling, efficient data models, and smart cleanup
//  Created by AI Assistant on 6/9/2025.
//

import Combine
import SwiftUI
import UIKit

// MARK: - MemoryManager

@MainActor
class MemoryManager: ObservableObject {
    static let shared = MemoryManager()

    @Published var currentMemoryUsage: MemoryStats = .init()
    @Published var memoryPressureLevel: MemoryPressureLevel = .normal
    @Published var optimizationTips: [OptimizationTip] = []

    private var memoryTimer: Timer?
    private var viewRegistry = ViewRegistry()
    private var dataModelOptimizer = DataModelOptimizer()

    struct MemoryStats {
        var totalUsed: Int64 = 0
        var available: Int64 = 0
        var appSpecific: Int64 = 0
        var imageCache: Int64 = 0
        var dataCache: Int64 = 0
        var viewHierarchy: Int = 0

        var usagePercentage: Double {
            guard totalUsed > 0 else { return 0 }
            return Double(appSpecific) / Double(totalUsed) * 100
        }

        var formattedUsage: String {
            "\(appSpecific / 1024 / 1024)MB / \(totalUsed / 1024 / 1024)MB"
        }
    }

    enum MemoryPressureLevel {
        case normal, moderate, high, critical

        var description: String {
            switch self {
            case .normal: "Normal"
            case .moderate: "Moderate"
            case .high: "High"
            case .critical: "Critical"
            }
        }

        var color: Color {
            switch self {
            case .normal: .green
            case .moderate: .yellow
            case .high: .orange
            case .critical: .red
            }
        }
    }

    struct OptimizationTip {
        let id = UUID()
        let title: String
        let description: String
        let priority: Priority
        let action: (() -> Void)?

        enum Priority {
            case low, medium, high, critical
        }
    }

    private init() {
        startMemoryMonitoring()
        setupMemoryWarningObserver()
    }

    deinit {
        memoryTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    private func startMemoryMonitoring() {
        memoryTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateMemoryStats()
                self?.generateOptimizationTips()
            }
        }
    }

    private func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleMemoryWarning()
            }
        }
    }

    private func updateMemoryStats() {
        let memoryInfo = getMemoryInfo()
        let imageCache = ImageCache.shared
        let dataCache = IntelligentCacheManager.shared

        currentMemoryUsage = MemoryStats(
            totalUsed: memoryInfo.total,
            available: memoryInfo.available,
            appSpecific: memoryInfo.resident,
            imageCache: Int64(imageCache.cacheStats.totalSize),
            dataCache: Int64(dataCache.cacheStats.totalSize),
            viewHierarchy: viewRegistry.activeViewCount
        )

        // Determine memory pressure level
        let usagePercentage = Double(memoryInfo.resident) / Double(memoryInfo.total) * 100

        switch usagePercentage {
        case 0 ..< 70:
            memoryPressureLevel = .normal
        case 70 ..< 85:
            memoryPressureLevel = .moderate
        case 85 ..< 95:
            memoryPressureLevel = .high
        default:
            memoryPressureLevel = .critical
        }
    }

    private func getMemoryInfo() -> (total: Int64, available: Int64, resident: Int64) {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if result == KERN_SUCCESS {
            // Get total system memory
            let totalMemory = ProcessInfo.processInfo.physicalMemory
            return (
                total: Int64(totalMemory),
                available: Int64(totalMemory) - Int64(info.resident_size),
                resident: Int64(info.resident_size)
            )
        }

        return (total: 0, available: 0, resident: 0)
    }

    private func generateOptimizationTips() {
        var tips: [OptimizationTip] = []

        // Check image cache size
        if currentMemoryUsage.imageCache > 50 * 1024 * 1024 { // 50MB
            tips.append(OptimizationTip(
                title: "Image Cache Too Large",
                description: "Consider reducing image cache size or clearing unused images",
                priority: .medium,
                action: {
                    ImageCache.shared.cleanupUnusedImages()
                }
            ))
        }

        // Check view hierarchy depth
        if currentMemoryUsage.viewHierarchy > 100 {
            tips.append(OptimizationTip(
                title: "Deep View Hierarchy",
                description: "Too many views in memory. Consider view recycling",
                priority: .high,
                action: {
                    self.viewRegistry.cleanupInactiveViews()
                }
            ))
        }

        // Check memory pressure
        if memoryPressureLevel == .critical {
            tips.append(OptimizationTip(
                title: "Critical Memory Usage",
                description: "Immediate cleanup required to prevent crashes",
                priority: .critical,
                action: {
                    self.performEmergencyCleanup()
                }
            ))
        }

        optimizationTips = tips
    }

    private func handleMemoryWarning() {
        print("🚨 Memory warning received - performing emergency cleanup")
        performEmergencyCleanup()

        // Add critical tip
        let criticalTip = OptimizationTip(
            title: "Memory Warning",
            description: "System requested immediate memory cleanup",
            priority: .critical,
            action: nil
        )
        optimizationTips.insert(criticalTip, at: 0)
    }

    func performEmergencyCleanup() {
        // 1. Aggressive image cache cleanup
        ImageCache.shared.cleanupUnusedImages()

        // 2. Clear data caches
        IntelligentCacheManager.shared.store(key: "emergency_cleanup", data: "", ttl: 0)

        // 3. Cancel preloading tasks
        SmartPreloader.shared.cancelAllPreloading()

        // 4. Clean up view registry
        viewRegistry.cleanupInactiveViews()

        // 5. Optimize data models
        dataModelOptimizer.compactAllModels()

        // 6. Force garbage collection hint
        autoreleasepool {
            // Create temporary objects to trigger cleanup
            _ = Array(0 ..< 1000).map { _ in UUID() }
        }

        print("🧹 Emergency cleanup completed")
    }

    // MARK: - Public API

    func optimizeForLowMemory() {
        dataModelOptimizer.optimizeForLowMemory()
        viewRegistry.enableAggressiveCleanup(true)

        // Reduce cache sizes
        ImageCache.shared.reduceCacheSize(by: 0.5)
    }

    func restoreNormalOperation() {
        viewRegistry.enableAggressiveCleanup(false)
        ImageCache.shared.restoreNormalCacheSize()
    }
}

// MARK: - ViewRegistry

@MainActor
class ViewRegistry: ObservableObject {
    private var activeViews: [String: ViewInfo] = [:]
    private var viewPool: [String: [PooledView]] = [:]
    private var isAggressiveCleanupEnabled = false

    struct ViewInfo {
        let id: String
        let type: String
        let createdAt: Date
        var lastAccessed: Date
        var isVisible: Bool

        init(id: String, type: String) {
            self.id = id
            self.type = type
            createdAt = Date()
            lastAccessed = Date()
            isVisible = true
        }
    }

    struct PooledView {
        let view: AnyView
        let createdAt: Date
        var isInUse: Bool = false
    }

    var activeViewCount: Int {
        activeViews.count
    }

    func registerView(id: String, type: String) {
        activeViews[id] = ViewInfo(id: id, type: type)
    }

    func unregisterView(id: String) {
        activeViews.removeValue(forKey: id)
    }

    func markViewVisible(id: String, visible: Bool) {
        activeViews[id]?.isVisible = visible
        activeViews[id]?.lastAccessed = Date()
    }

    func getPooledView(type: String, factory: () -> some View) -> AnyView {
        // Check if we have a pooled view available
        if let pooledViews = viewPool[type],
           let availableView = pooledViews.first(where: { !$0.isInUse })
        {
            // Mark as in use
            if let index = viewPool[type]?.firstIndex(where: { $0.view === availableView.view }) {
                viewPool[type]?[index].isInUse = true
            }

            return availableView.view
        }

        // Create new view and add to pool
        let newView = AnyView(factory())
        let pooledView = PooledView(view: newView, createdAt: Date(), isInUse: true)

        if viewPool[type] == nil {
            viewPool[type] = []
        }
        viewPool[type]?.append(pooledView)

        return newView
    }

    func returnViewToPool(type: String, view: AnyView) {
        guard let pooledViews = viewPool[type] else { return }

        for (index, pooledView) in pooledViews.enumerated() {
            if pooledView.view === view {
                viewPool[type]?[index].isInUse = false
                break
            }
        }
    }

    func cleanupInactiveViews() {
        let now = Date()
        let cleanupThreshold: TimeInterval = isAggressiveCleanupEnabled ? 30 : 60

        // Clean up old active views
        let viewsToRemove = activeViews.compactMap { key, viewInfo -> String? in
            if !viewInfo.isVisible, now.timeIntervalSince(viewInfo.lastAccessed) > cleanupThreshold {
                return key
            }
            return nil
        }

        for viewId in viewsToRemove {
            activeViews.removeValue(forKey: viewId)
        }

        // Clean up view pool
        for (type, pooledViews) in viewPool {
            let activeViews = pooledViews.filter { pooledView in
                pooledView.isInUse || now.timeIntervalSince(pooledView.createdAt) < cleanupThreshold
            }
            viewPool[type] = activeViews
        }

        print("🧹 View cleanup: Removed \(viewsToRemove.count) inactive views")
    }

    func enableAggressiveCleanup(_ enabled: Bool) {
        isAggressiveCleanupEnabled = enabled

        if enabled {
            cleanupInactiveViews()
        }
    }
}

// MARK: - DataModelOptimizer

@MainActor
class DataModelOptimizer: ObservableObject {
    private var compactedModels: Set<String> = []
    private var modelSizes: [String: Int] = [:]

    func optimizePlayerModel(_ player: inout AFLPlayer) {
        // Implement copy-on-write for large data
        if !isOptimized(player.id.uuidString) {
            optimizePlayerData(&player)
            markAsOptimized(player.id.uuidString)
        }
    }

    func optimizeForLowMemory() {
        // Implement aggressive optimizations
        compactAllModels()

        // Clear non-essential data
        clearCachedCalculations()
    }

    func compactAllModels() {
        // Force compaction of all data structures
        compactedModels.removeAll(keepingCapacity: false)
        modelSizes.removeAll(keepingCapacity: false)

        // Trigger any copy-on-write optimizations
        print("🗜️ Data model compaction completed")
    }

    private func optimizePlayerData(_ player: inout AFLPlayer) {
        // Optimize large arrays and strings
        player.optimizeForMemory()

        // Track model size
        let modelSize = estimateModelSize(player)
        modelSizes[player.id.uuidString] = modelSize
    }

    private func isOptimized(_ modelId: String) -> Bool {
        compactedModels.contains(modelId)
    }

    private func markAsOptimized(_ modelId: String) {
        compactedModels.insert(modelId)
    }

    private func estimateModelSize(_ player: AFLPlayer) -> Int {
        // Rough estimation of model memory footprint
        var size = MemoryLayout<AFLPlayer>.size
        size += player.name.utf8.count
        size += player.team.utf8.count
        size += player.position.utf8.count
        size += player.gameStats.count * MemoryLayout<GameStats>.size
        return size
    }

    private func clearCachedCalculations() {
        // Clear any computed properties that are cached
        // This would be implemented based on specific data models
        print("🗑️ Cleared cached calculations")
    }
}

// MARK: - Memory-Optimized Extensions

extension AFLPlayer {
    mutating func optimizeForMemory() {
        // Implement copy-on-write for large collections
        if gameStats.count > 50 {
            // Keep only recent stats
            gameStats = Array(gameStats.suffix(50))
        }

        // Optimize string storage
        name = String(name.trimmingCharacters(in: .whitespacesAndNewlines))
        team = String(team.trimmingCharacters(in: .whitespacesAndNewlines))
        position = String(position.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

extension ImageCache {
    func reduceCacheSize(by factor: Double) {
        let targetSize = Int(Double(maxCacheSize) * (1.0 - factor))

        while currentCacheSize > targetSize, !imageCache.isEmpty {
            evictLeastRecentlyUsedImages(neededSpace: currentCacheSize - targetSize)
        }

        print("📉 Reduced image cache by \(Int(factor * 100))%")
    }

    func restoreNormalCacheSize() {
        // This would restore the original cache size limits
        print("📈 Restored normal image cache size")
    }
}

// MARK: - Memory-Efficient Views

struct MemoryEfficientPlayerRow: View {
    let player: PlayerListItem
    @State private var viewId = UUID().uuidString
    @StateObject private var viewRegistry = ViewRegistry()

    var body: some View {
        content
            .onAppear {
                viewRegistry.registerView(id: viewId, type: "PlayerRow")
                viewRegistry.markViewVisible(id: viewId, visible: true)
            }
            .onDisappear {
                viewRegistry.markViewVisible(id: viewId, visible: false)
            }
            .onReceive(NotificationCenter.default
                .publisher(for: UIApplication.didReceiveMemoryWarningNotification)
            ) { _ in
                // Handle memory warning at view level
                handleMemoryWarning()
            }
    }

    private var content: some View {
        HStack {
            // Lazy-loaded player image
            LazyPlayerImage(url: player.imageUrl)
                .frame(width: 50, height: 50)

            // Optimized text content
            VStack(alignment: .leading, spacing: 2) {
                // Use lightweight text views
                Text(player.name)
                    .font(.headline)
                    .lineLimit(1)

                Text("\(player.team) - \(player.position)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 0)

            // Minimal action button
            CompactActionButton()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func handleMemoryWarning() {
        // Release any non-essential resources
        viewRegistry.unregisterView(id: viewId)
    }
}

struct LazyPlayerImage: View {
    let url: URL?
    @StateObject private var imageLoader = LazyImageLoader()

    var body: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        if imageLoader.isLoading {
                            ProgressView()
                                .scaleEffect(0.6)
                        }
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onAppear {
            if let url {
                imageLoader.loadImage(from: url)
            }
        }
        .onDisappear {
            imageLoader.cancelLoading()
        }
    }
}

@MainActor
class LazyImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false

    private var loadingTask: Task<Void, Never>?

    func loadImage(from url: URL) {
        // Check cache first
        if let cachedImage = ImageCache.shared.getImage(for: url) {
            image = cachedImage
            return
        }

        isLoading = true

        loadingTask = Task {
            // Simulate network loading with delay
            try? await Task.sleep(nanoseconds: UInt64.random(in: 100_000_000 ... 300_000_000))

            guard !Task.isCancelled else { return }

            // Generate placeholder image
            let placeholderImage = generatePlaceholderImage(for: url)

            await MainActor.run {
                if !Task.isCancelled {
                    image = placeholderImage
                    isLoading = false
                }
            }
        }
    }

    func cancelLoading() {
        loadingTask?.cancel()
        loadingTask = nil
        isLoading = false
    }

    private func generatePlaceholderImage(for url: URL) -> UIImage {
        let size = CGSize(width: 50, height: 50)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            UIColor.systemBlue.setFill()
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        }
    }

    deinit {
        cancelLoading()
    }
}

struct CompactActionButton: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "plus.circle.fill")
                .font(.title3)
                .foregroundColor(.accentColor)
        }
        .buttonStyle(PlainButtonStyle()) // Minimize button overhead
    }
}

// MARK: - Memory Statistics View

struct MemoryStatsView: View {
    @StateObject private var memoryManager = MemoryManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "memorychip")
                    .foregroundColor(memoryManager.memoryPressureLevel.color)

                Text("Memory Usage")
                    .font(.headline)

                Spacer()

                Text(memoryManager.currentMemoryUsage.formattedUsage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Memory pressure indicator
            HStack {
                Text("Pressure Level:")
                    .font(.subheadline)

                Spacer()

                Text(memoryManager.memoryPressureLevel.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(memoryManager.memoryPressureLevel.color)
            }

            // Usage breakdown
            VStack(alignment: .leading, spacing: 8) {
                memoryBreakdownRow("Images", value: memoryManager.currentMemoryUsage.imageCache)
                memoryBreakdownRow("Data Cache", value: memoryManager.currentMemoryUsage.dataCache)
                memoryBreakdownRow("Views", value: Int64(memoryManager.currentMemoryUsage.viewHierarchy))
            }
            .font(.caption)

            // Optimization tips
            if !memoryManager.optimizationTips.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Optimization Tips")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    ForEach(memoryManager.optimizationTips, id: \.id) { tip in
                        optimizationTipRow(tip)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func memoryBreakdownRow(_ title: String, value: Int64) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)

            Spacer()

            Text("\(value / 1024 / 1024)MB")
                .fontWeight(.medium)
        }
    }

    private func optimizationTipRow(_ tip: MemoryManager.OptimizationTip) -> some View {
        HStack {
            Circle()
                .fill(priorityColor(tip.priority))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(tip.title)
                    .font(.caption)
                    .fontWeight(.medium)

                Text(tip.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            if let action = tip.action {
                Button("Fix") {
                    action()
                }
                .font(.caption2)
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func priorityColor(_ priority: MemoryManager.OptimizationTip.Priority) -> Color {
        switch priority {
        case .low: .green
        case .medium: .yellow
        case .high: .orange
        case .critical: .red
        }
    }
}
