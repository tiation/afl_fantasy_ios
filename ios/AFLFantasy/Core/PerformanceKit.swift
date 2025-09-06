//
//  PerformanceKit.swift
//  AFL Fantasy Intelligence Platform
//
//  High-performance utilities following iOS best practices
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI
import Combine
import Foundation

// MARK: - Performance-Optimized Components

struct FastPlayerCard: View {
    let player: Player
    
    // Pre-compute expensive operations in init
    private let formattedPrice: String
    private let positionColor: Color
    
    init(player: Player) {
        self.player = player
        self.formattedPrice = "$\(Double(player.currentPrice) / 1000, specifier: "%.1f")k"
        self.positionColor = player.position.color
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm.value) {
            // Fixed-size position indicator prevents layout thrash
            RoundedRectangle(cornerRadius: 4)
                .fill(positionColor)
                .frame(width: 6, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .typography(.headline)
                    .foregroundColor(DesignSystem.Colors.onSurface)
                
                HStack(spacing: DesignSystem.Spacing.xs.value) {
                    Text(player.position.rawValue)
                        .typography(.caption1)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(positionColor.opacity(0.2))
                        .cornerRadius(.small)
                    
                    Text(formattedPrice)
                        .typography(.caption1)
                        .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
                }
            }
            
            Spacer(minLength: 0) // Prevents unnecessary expansion
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(player.currentScore)")
                    .typography(.title2)
                    .foregroundColor(DesignSystem.Colors.primary)
                
                Text("BE: \(player.breakeven)")
                    .typography(.caption1)
                    .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)
            }
        }
        .padding(DesignSystem.Spacing.m.value)
        .performantCard()
    }
}

// MARK: - Lazy Loading Manager

@MainActor
class LazyDataLoader: ObservableObject {
    @Published var isReady = false
    @Published var criticalDataLoaded = false
    
    init() {
        loadCriticalData()
        deferNonCriticalData()
    }
    
    private func loadCriticalData() {
        Task {
            // Simulate loading essential data (theme, user prefs, last state)
            try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
            criticalDataLoaded = true
            isReady = true
        }
    }
    
    private func deferNonCriticalData() {
        // Defer heavy initialization (analytics, additional features)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Load non-critical features
        }
    }
}

// MARK: - Memory-Efficient Image Cache

class FastImageCache {
    static let shared = FastImageCache()
    private let cache = NSCache<NSURL, UIImage>()
    
    private init() {
        cache.countLimit = 50 // Limit to prevent memory issues
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB limit
    }
    
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        let cost = image.size.width * image.size.height * 4 // Estimate bytes
        cache.setObject(image, forKey: url as NSURL, cost: Int(cost))
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

// MARK: - Network Optimizations

class FastNetworking: ObservableObject {
    static let shared = FastNetworking()
    
    private let session: URLSession
    private var responseCache: [String: (Data, Date)] = [:]
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    
    private init() {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(
            memoryCapacity: 10 * 1024 * 1024,  // 10MB
            diskCapacity: 50 * 1024 * 1024     // 50MB
        )
        config.requestCachePolicy = .useProtocolCachePolicy
        config.httpMaximumConnectionsPerHost = 4
        session = URLSession(configuration: config)
    }
    
    func fetchData<T: Codable>(from endpoint: String, type: T.Type) async throws -> T {
        // Check cache first (stale-while-revalidate pattern)
        if let cached = responseCache[endpoint],
           Date().timeIntervalSince(cached.1) < cacheTimeout {
            return try JSONDecoder().decode(T.self, from: cached.0)
        }
        
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw NetworkError.serverError
        }
        
        // Cache the response
        responseCache[endpoint] = (data, Date())
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func clearCache() {
        responseCache.removeAll()
        session.configuration.urlCache?.removeAllCachedResponses()
    }
}

enum NetworkError: Error {
    case invalidURL
    case serverError
    case decodingError
}

// MARK: - Background Processing

class BackgroundWorker {
    static let shared = BackgroundWorker()
    private let queue = DispatchQueue(label: "afl.background", qos: .userInitiated)
    
    private init() {}
    
    func processData<T, R>(_ data: [T], processor: @escaping (T) -> R, completion: @escaping ([R]) -> Void) {
        queue.async {
            let results = data.map(processor)
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
}

// MARK: - Performance Extensions

extension View {
    // Prevents layout thrash with stable sizing
    func stableSize(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        self.frame(
            minWidth: width, maxWidth: width,
            minHeight: height, maxHeight: height
        )
    }
    
    // Cancel work when view disappears
    func cancelOnDisappear<C: Cancellable>(_ cancellable: C?) -> some View {
        self.onDisappear {
            cancellable?.cancel()
        }
    }
    
    // Optimized list row
    func fastListRow() -> some View {
        self
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .buttonStyle(PlainButtonStyle())
    }
    
    // Reduce motion aware animation
    func smartAnimation<V: Equatable>(_ animation: Animation, value: V) -> some View {
        let finalAnimation = UIAccessibility.isReduceMotionEnabled ? 
            .linear(duration: 0.01) : animation
        return self.animation(finalAnimation, value: value)
    }
}

// MARK: - Memory Monitoring

class MemoryMonitor: ObservableObject {
    @Published var currentUsageMB: Double = 0
    @Published var isHighMemory = false
    
    static let shared = MemoryMonitor()
    
    private init() {
        startMonitoring()
        setupMemoryWarningHandler()
    }
    
    private func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            Task { @MainActor in
                self.updateMemoryUsage()
            }
        }
    }
    
    private func setupMemoryWarningHandler() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.handleMemoryWarning()
        }
    }
    
    @MainActor
    private func updateMemoryUsage() {
        let usage = getCurrentMemoryUsage()
        currentUsageMB = usage
        isHighMemory = usage > 80.0 // 80MB threshold
    }
    
    private func handleMemoryWarning() {
        FastImageCache.shared.clearCache()
        FastNetworking.shared.clearCache()
        isHighMemory = true
    }
    
    private func getCurrentMemoryUsage() -> Double {
        let info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        guard kerr == KERN_SUCCESS else { return 0 }
        return Double(info.resident_size) / (1024 * 1024)
    }
}

// MARK: - Performance Budgets

enum PerformanceBudgets {
    static let maxMemoryMB: Double = 100
    static let maxColdStartSeconds: Double = 2.0
    static let maxFrameTimeMS: Double = 16.67 // 60 FPS
    static let maxNetworkLatencyMS: Double = 500
}
