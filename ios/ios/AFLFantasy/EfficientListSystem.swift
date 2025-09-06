//
//  EfficientListSystem.swift
//  AFL Fantasy Intelligence Platform
//
//  Advanced list rendering with lazy loading, viewport awareness, and smart pagination
//  Created by AI Assistant on 6/9/2025.
//

import Combine
import SwiftUI

// MARK: - EfficientPlayerList

struct EfficientPlayerList<Content: View>: View {
    let items: [PlayerListItem]
    let content: (PlayerListItem) -> Content

    @State private var visibleRange: Range<Int> = 0 ..< 0
    @State private var preloadBuffer = 5
    @StateObject private var listOptimizer = ListOptimizer()
    @StateObject private var imageCache = ImageCache.shared

    private let itemHeight: CGFloat = 80
    private let screenBuffer: CGFloat = 200

    init(items: [PlayerListItem], @ViewBuilder content: @escaping (PlayerListItem) -> Content) {
        self.items = items
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(items.indices, id: \.self) { index in
                        OptimizedPlayerRow(
                            player: items[index],
                            isVisible: visibleRange.contains(index),
                            onAppear: { handleItemAppear(at: index, in: geometry) },
                            onDisappear: { handleItemDisappear(at: index) }
                        ) {
                            content(items[index])
                        }
                        .id(items[index].id)
                    }

                    if listOptimizer.hasMorePages {
                        LoadingIndicatorView()
                            .onAppear {
                                listOptimizer.loadNextPage()
                            }
                    }
                }
                .padding(.horizontal, 16)
            }
            .onPreferenceChange(VisibleItemsPreferenceKey.self) { visibleItems in
                updateVisibleRange(visibleItems, in: geometry)
            }
        }
        .environmentObject(listOptimizer)
        .onReceive(listOptimizer.$shouldPreloadImages) { shouldPreload in
            if shouldPreload {
                preloadVisibleImages()
            }
        }
    }

    private func handleItemAppear(at index: Int, in geometry: GeometryProxy) {
        // Track item appearance for analytics and preloading
        listOptimizer.trackItemView(at: index)

        // Preload nearby images
        let preloadRange = max(0, index - preloadBuffer) ... min(items.count - 1, index + preloadBuffer)
        for i in preloadRange {
            if let imageUrl = items[i].imageUrl {
                imageCache.preloadImage(url: imageUrl, priority: .medium)
            }
        }

        // Trigger performance optimization if needed
        if index % 20 == 0 {
            listOptimizer.optimizeMemoryUsage()
        }
    }

    private func handleItemDisappear(at index: Int) {
        // Clean up resources for disappeared items
        listOptimizer.trackItemDisappear(at: index)

        // Schedule cleanup of non-visible images (with delay to handle quick scrolling)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if !visibleRange.contains(index), let imageUrl = items[index].imageUrl {
                imageCache.evictIfNotRecentlyUsed(url: imageUrl)
            }
        }
    }

    private func updateVisibleRange(_ visibleItems: [Int], in geometry: GeometryProxy) {
        guard !visibleItems.isEmpty else { return }

        let newRange = visibleItems.min()! ..< (visibleItems.max()! + 1)
        visibleRange = newRange

        // Notify optimizer about visible range changes
        listOptimizer.updateVisibleRange(newRange)
    }

    private func preloadVisibleImages() {
        for index in visibleRange {
            guard index < items.count,
                  let imageUrl = items[index].imageUrl else { continue }

            imageCache.preloadImage(url: imageUrl, priority: .high)
        }
    }
}

// MARK: - OptimizedPlayerRow

struct OptimizedPlayerRow<Content: View>: View {
    let player: PlayerListItem
    let isVisible: Bool
    let onAppear: () -> Void
    let onDisappear: () -> Void
    let content: () -> Content

    @State private var hasAppeared = false
    @StateObject private var imageCache = ImageCache.shared

    var body: some View {
        Group {
            if isVisible || hasAppeared {
                content()
                    .onAppear {
                        if !hasAppeared {
                            hasAppeared = true
                            onAppear()
                        }
                    }
                    .onDisappear {
                        onDisappear()
                    }
            } else {
                // Placeholder for non-visible items
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 80)
                    .redacted(reason: .placeholder)
            }
        }
        .preference(key: VisibleItemsPreferenceKey.self, value: isVisible ? [player.listIndex] : [])
    }
}

// MARK: - ListOptimizer

@MainActor
class ListOptimizer: ObservableObject {
    @Published var hasMorePages = true
    @Published var shouldPreloadImages = false
    @Published var currentPage = 1

    private var visibleItemIndices: Set<Int> = []
    private var itemViewCounts: [Int: Int] = [:]
    private var lastOptimizationTime = Date()
    private let optimizationInterval: TimeInterval = 5.0

    private let pageSize = 50
    private var totalItemsLoaded = 0
    private let maxItemsInMemory = 200

    func trackItemView(at index: Int) {
        visibleItemIndices.insert(index)
        itemViewCounts[index, default: 0] += 1

        // Trigger preloading if this is a frequently viewed item
        if itemViewCounts[index, default: 0] > 2 {
            shouldPreloadImages = true
        }
    }

    func trackItemDisappear(at index: Int) {
        visibleItemIndices.remove(index)
    }

    func updateVisibleRange(_ range: Range<Int>) {
        // Clear old visible indices and add new ones
        visibleItemIndices.removeAll()
        visibleItemIndices.formUnion(range)

        // Check if we need to load more data
        if range.upperBound > totalItemsLoaded - 20, hasMorePages {
            loadNextPage()
        }
    }

    func loadNextPage() {
        guard hasMorePages else { return }

        // Simulate loading next page
        Task {
            await simulatePageLoad()

            await MainActor.run {
                totalItemsLoaded += pageSize
                currentPage += 1

                // Stop loading when we reach a reasonable limit
                if currentPage >= 10 {
                    hasMorePages = false
                }
            }
        }
    }

    func optimizeMemoryUsage() {
        let now = Date()
        guard now.timeIntervalSince(lastOptimizationTime) > optimizationInterval else { return }

        lastOptimizationTime = now

        // Clean up view counts for items not recently viewed
        let recentlyViewed = Set(visibleItemIndices)
        itemViewCounts = itemViewCounts.filter { recentlyViewed.contains($0.key) }

        // Trigger image cache cleanup
        ImageCache.shared.cleanupUnusedImages()

        // Reset preloading flag
        shouldPreloadImages = false

        print("🧹 Memory optimization completed. Active items: \(itemViewCounts.count)")
    }

    private func simulatePageLoad() async {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: UInt64.random(in: 200_000_000 ... 800_000_000))
    }
}

// MARK: - ImageCache

@MainActor
class ImageCache: ObservableObject {
    static let shared = ImageCache()

    private var imageCache: [URL: CachedImage] = [:]
    private var preloadQueue = OperationQueue()
    private let maxCacheSize: Int = 100 * 1024 * 1024 // 100MB
    private var currentCacheSize: Int = 0

    struct CachedImage {
        let image: UIImage
        let size: Int
        let createdAt: Date
        var lastAccessed: Date
        var accessCount: Int

        init(image: UIImage) {
            self.image = image
            size = Int(image.size.width * image.size.height * 4) // Rough estimate
            createdAt = Date()
            lastAccessed = Date()
            accessCount = 1
        }

        mutating func markAccessed() {
            lastAccessed = Date()
            accessCount += 1
        }
    }

    enum PreloadPriority {
        case low, medium, high

        var operationPriority: Operation.QueuePriority {
            switch self {
            case .low: .low
            case .medium: .normal
            case .high: .high
            }
        }
    }

    private init() {
        preloadQueue.maxConcurrentOperationCount = 3
        preloadQueue.qualityOfService = .utility

        // Set up memory warning observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    func preloadImage(url: URL, priority: PreloadPriority = .medium) {
        // Skip if already cached
        guard imageCache[url] == nil else {
            imageCache[url]?.markAccessed()
            return
        }

        let operation = PreloadOperation(url: url) { [weak self] image in
            Task { @MainActor in
                self?.storeImage(image, for: url)
            }
        }

        operation.queuePriority = priority.operationPriority
        preloadQueue.addOperation(operation)
    }

    func getImage(for url: URL) -> UIImage? {
        guard var cachedImage = imageCache[url] else {
            // Trigger preload if not cached
            preloadImage(url: url, priority: .high)
            return nil
        }

        cachedImage.markAccessed()
        imageCache[url] = cachedImage
        return cachedImage.image
    }

    private func storeImage(_ image: UIImage, for url: URL) {
        let cachedImage = CachedImage(image: image)

        // Check if we need to evict old images
        if currentCacheSize + cachedImage.size > maxCacheSize {
            evictLeastRecentlyUsedImages(neededSpace: cachedImage.size)
        }

        imageCache[url] = cachedImage
        currentCacheSize += cachedImage.size
    }

    func evictIfNotRecentlyUsed(url: URL) {
        guard let cachedImage = imageCache[url] else { return }

        // Only evict if not accessed in the last 30 seconds
        let timeSinceAccess = Date().timeIntervalSince(cachedImage.lastAccessed)
        if timeSinceAccess > 30, cachedImage.accessCount < 3 {
            imageCache.removeValue(forKey: url)
            currentCacheSize -= cachedImage.size
        }
    }

    func cleanupUnusedImages() {
        let now = Date()
        let cutoffTime: TimeInterval = 60 // 1 minute

        let urlsToRemove = imageCache.compactMap { url, cachedImage in
            now.timeIntervalSince(cachedImage.lastAccessed) > cutoffTime ? url : nil
        }

        for url in urlsToRemove {
            if let cachedImage = imageCache.removeValue(forKey: url) {
                currentCacheSize -= cachedImage.size
            }
        }

        print("🗑️ Cleaned up \(urlsToRemove.count) unused images. Cache size: \(currentCacheSize / 1024 / 1024)MB")
    }

    private func evictLeastRecentlyUsedImages(neededSpace: Int) {
        let sortedImages = imageCache.sorted { lhs, rhs in
            // Sort by last accessed time (oldest first) and access count (least accessed first)
            if lhs.value.lastAccessed == rhs.value.lastAccessed {
                return lhs.value.accessCount < rhs.value.accessCount
            }
            return lhs.value.lastAccessed < rhs.value.lastAccessed
        }

        var freedSpace = 0
        for (url, cachedImage) in sortedImages {
            guard freedSpace < neededSpace else { break }

            imageCache.removeValue(forKey: url)
            currentCacheSize -= cachedImage.size
            freedSpace += cachedImage.size
        }
    }

    @objc private func handleMemoryWarning() {
        // Aggressively clean up cache on memory warning
        let originalCount = imageCache.count

        // Keep only the most recently accessed images
        let recentImages = imageCache.filter { _, cachedImage in
            Date().timeIntervalSince(cachedImage.lastAccessed) < 10 // Last 10 seconds
        }

        currentCacheSize = recentImages.values.reduce(0) { $0 + $1.size }
        imageCache = recentImages

        print("⚠️ Memory warning: Reduced image cache from \(originalCount) to \(imageCache.count) images")
    }
}

// MARK: - PreloadOperation

class PreloadOperation: Operation {
    private let url: URL
    private let completion: (UIImage) -> Void

    init(url: URL, completion: @escaping (UIImage) -> Void) {
        self.url = url
        self.completion = completion
        super.init()
    }

    override func main() {
        guard !isCancelled else { return }

        // Simulate image loading (in real app, use URLSession)
        let image = generatePlaceholderImage(for: url)

        guard !isCancelled else { return }
        completion(image)
    }

    private func generatePlaceholderImage(for url: URL) -> UIImage {
        let size = CGSize(width: 60, height: 60)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // Create a simple colored circle as placeholder
            let colors = [UIColor.blue, UIColor.green, UIColor.orange, UIColor.purple, UIColor.red]
            let colorIndex = abs(url.hashValue) % colors.count
            colors[colorIndex].setFill()

            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))

            // Add initials or player number
            let text = String(url.lastPathComponent.prefix(2)).uppercased()
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.white
            ]

            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )

            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}

// MARK: - PlayerListItem

struct PlayerListItem: Identifiable, Hashable {
    let id = UUID()
    let listIndex: Int
    let name: String
    let team: String
    let position: String
    let price: Int
    let points: Int
    let imageUrl: URL?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - LoadingIndicatorView

struct LoadingIndicatorView: View {
    @State private var isAnimating = false

    var body: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)

            Text("Loading more players...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - VisibleItemsPreferenceKey

struct VisibleItemsPreferenceKey: PreferenceKey {
    static var defaultValue: [Int] = []

    static func reduce(value: inout [Int], nextValue: () -> [Int]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - PlayerListExampleView

struct PlayerListExampleView: View {
    @State private var players: [PlayerListItem] = []

    var body: some View {
        NavigationView {
            EfficientPlayerList(items: players) { player in
                PlayerRowView(player: player)
            }
            .navigationTitle("Players")
            .onAppear {
                loadInitialPlayers()
            }
        }
    }

    private func loadInitialPlayers() {
        // Generate sample data
        players = (0 ..< 100).map { index in
            PlayerListItem(
                listIndex: index,
                name: "Player \(index + 1)",
                team: ["COL", "RIC", "ESS", "HAW"].randomElement()!,
                position: ["DEF", "MID", "RUC", "FWD"].randomElement()!,
                price: Int.random(in: 200_000 ... 800_000),
                points: Int.random(in: 45 ... 120),
                imageUrl: URL(string: "https://example.com/player\(index).jpg")
            )
        }
    }
}

// MARK: - PlayerRowView

struct PlayerRowView: View {
    let player: PlayerListItem
    @StateObject private var imageCache = ImageCache.shared

    var body: some View {
        HStack {
            // Player Image
            Group {
                if let image = imageCache.getImage(for: player.imageUrl ?? URL(string: "about:blank")!) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .overlay {
                            ProgressView()
                                .scaleEffect(0.6)
                        }
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Player Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(player.name)
                        .font(.headline)
                        .lineLimit(1)

                    Spacer()

                    Text("$\(player.price / 1000)k")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("\(player.team) - \(player.position)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(player.points) pts")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
            }

            // Action Button
            Button(action: {}) {
                Image(systemName: "plus.circle")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
