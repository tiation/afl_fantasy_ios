// 🏈 AFL Fantasy Models - Essential Types Only
// Core shared types needed across the app (< 400 lines)
// Domain-specific models are in separate files

import Foundation
import Combine

// MARK: - 🏈 Essential Shared Types
// These are the most commonly used types across all features

// MARK: - 📋 Model Organization
// Domain-specific models are split into focused files:
// • PlayerModels.swift - Player, Position, Captain analysis
// • DashboardModels.swift - Live stats, cash cows, game info  
// • TeamModels.swift - Team structure, trades, lineups
// • CoreModels.swift - AI, alerts, settings, users

// MARK: - Critical Shared Enums

/// Universal player positions across AFL Fantasy
enum Position: String, Codable {
    case defender = "DEF"
    case midfielder = "MID"
    case ruck = "RUC"
    case forward = "FWD"
    
    var shortName: String {
        return self.rawValue
    }
}

/// Injury status for player availability
enum InjuryStatus: String, Codable {
    case healthy = "HEALTHY"
    case questionable = "QUESTIONABLE" 
    case out = "OUT"
}

/// Performance consistency rating
enum ConsistencyGrade: String, Codable {
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
}

// MARK: - Universal View States

/// Standard loading state for async operations
enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var data: T? {
        if case .loaded(let data) = self { return data }
        return nil
    }
    
    var error: Error? {
        if case .error(let error) = self { return error }
        return nil
    }
}

/// Standard result wrapper for API responses
struct APIResult<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
    let timestamp: Date
}

// MARK: - Universal Protocols

/// Protocol for models that can be cached
protocol Cacheable: Codable {
    var cacheKey: String { get }
    var cacheExpiry: TimeInterval { get }
}

/// Protocol for models with refresh capabilities
protocol Refreshable {
    mutating func refresh() async throws
    var lastRefreshed: Date { get }
}

/// Protocol for models that can be favorited/watchlisted
protocol Watchable: Identifiable {
    var isWatched: Bool { get set }
    var watchedDate: Date? { get set }
}

// MARK: - Common View Models Base

/// Base class for all ViewModels with common functionality
@MainActor
class BaseViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: Error?
    
    /// Set loading state and clear errors
    func setLoading(_ loading: Bool) {
        isLoading = loading
        if loading {
            error = nil
        }
    }
    
    /// Handle errors consistently
    func handleError(_ error: Error) {
        self.error = error
        isLoading = false
        print("❌ Error in \(String(describing: type(of: self))): \(error)")
    }
    
    /// Clear all states
    func reset() {
        isLoading = false
        error = nil
    }
}

// MARK: - Performance Tracking

/// Track performance metrics across the app
struct PerformanceMetric {
    let operation: String
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    
    init(operation: String, startTime: Date, endTime: Date = Date()) {
        self.operation = operation
        self.startTime = startTime
        self.endTime = endTime
        self.duration = endTime.timeIntervalSince(startTime)
    }
}

/// Performance tracker for monitoring app speed
class PerformanceTracker {
    static let shared = PerformanceTracker()
    private var metrics: [PerformanceMetric] = []
    
    private init() {}
    
    /// Start tracking an operation
    func startOperation(_ name: String) -> Date {
        let startTime = Date()
        return startTime
    }
    
    /// End tracking and record metric
    func endOperation(_ name: String, startTime: Date) {
        let metric = PerformanceMetric(operation: name, startTime: startTime)
        metrics.append(metric)
        
        // Log slow operations (> 100ms)
        if metric.duration > 0.1 {
            print("⚡ Slow operation: \(name) took \(String(format: "%.2f", metric.duration * 1000))ms")
        }
    }
    
    /// Get average duration for operation type
    func averageDuration(for operation: String) -> TimeInterval {
        let operationMetrics = metrics.filter { $0.operation == operation }
        guard !operationMetrics.isEmpty else { return 0 }
        
        let totalDuration = operationMetrics.reduce(0) { $0 + $1.duration }
        return totalDuration / Double(operationMetrics.count)
    }
    
    /// Clear old metrics (keep last 100)
    func cleanup() {
        if metrics.count > 100 {
            metrics = Array(metrics.suffix(100))
        }
    }
}

// MARK: - Error Handling

/// Standard app errors
enum AppError: LocalizedError, Equatable {
    case network(String)
    case parsing(String)
    case storage(String)
    case validation(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .network(let message):
            return "Network Error: \(message)"
        case .parsing(let message):
            return "Data Error: \(message)"
        case .storage(let message):
            return "Storage Error: \(message)"
        case .validation(let message):
            return "Validation Error: \(message)"
        case .unknown(let message):
            return "Unknown Error: \(message)"
        }
    }
}

// MARK: - Utility Extensions

extension Date {
    /// Format for display in the app
    var displayFormat: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Time ago string ("2h ago", "3d ago")
    var timeAgoString: String {
        let interval = Date().timeIntervalSince(self)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

extension String {
    /// Remove AFL team prefixes for cleaner display
    var cleanPlayerName: String {
        return self.replacingOccurrences(of: "^(Adelaide|Brisbane|Carlton|Collingwood|Essendon|Fremantle|Geelong|Gold Coast|GWS|Hawthorn|Melbourne|North Melbourne|Port Adelaide|Richmond|St Kilda|Sydney|West Coast|Western Bulldogs)\\s+", with: "", options: .regularExpression)
    }
    
    /// Capitalize first letter
    var capitalizedFirst: String {
        guard !isEmpty else { return self }
        return prefix(1).capitalized + dropFirst()
    }
}

extension Int {
    /// Format as price string ($50K, $1.2M)
    var priceString: String {
        if self >= 1_000_000 {
            let millions = Double(self) / 1_000_000
            return "$\(String(format: "%.1f", millions))M"
        } else if self >= 1_000 {
            let thousands = Double(self) / 1_000
            return "$\(String(format: "%.0f", thousands))K"
        } else {
            return "$\(self)"
        }
    }
    
    /// Format with thousands separators
    var formattedString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension Double {
    /// Format to 1 decimal place
    var oneDecimal: String {
        return String(format: "%.1f", self)
    }
    
    /// Format as percentage
    var percentageString: String {
        return String(format: "%.1f%%", self * 100)
    }
}

// MARK: - Constants

/// App-wide constants
enum Constants {
    enum Performance {
        static let maxFileLines = 400
        static let maxFunctionLines = 40
        static let maxComplexity = 10
        static let targetFPS = 60
        static let maxMemoryMB = 220
    }
    
    enum UI {
        static let minTouchTarget: CGFloat = 44
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 8
        static let animationDuration: TimeInterval = 0.2
    }
    
    enum API {
        static let timeout: TimeInterval = 30
        static let retryCount = 3
        static let cacheExpiryMinutes = 15
    }
}

/// App version and build info
struct AppInfo {
    static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    static let displayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "AFL Fantasy"
}
