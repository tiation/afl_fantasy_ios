import Foundation
import Combine

// MARK: - Singleton Extensions

extension AlertManager {
    /// Shared singleton instance of AlertManager
    nonisolated(unsafe) static let shared = AlertManager()
}

// MARK: - Missing Service Protocols

/// Protocol for services that need to manage cached data
protocol CacheableService {
    func clearCache() async
    func refreshCache() async throws
    var lastCacheUpdate: Date? { get }
}

/// Protocol for services that provide real-time updates
protocol LiveUpdateService {
    var isConnected: Bool { get }
    func connect() async
    func disconnect()
}

// MARK: - Service Container

/// Container for managing service instances and dependencies
@MainActor
final class ServiceContainer: ObservableObject {
    static let shared = ServiceContainer()
    
    @Published var services: [String: Any] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        registerServices()
    }
    
    private func registerServices() {
        // Register all service instances
        register(AlertManager.shared, for: AlertManager.self)
        register(UserPreferencesService.shared, for: UserPreferencesService.self)
        // Note: These services may not have shared instances
    }
    
    func register<T>(_ service: T, for type: T.Type) {
        let key = String(describing: type)
        services[key] = service
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        return services[key] as? T
    }
}

// MARK: - Missing Service Implementations

/// Service for managing notification preferences and delivery
final class NotificationService: ObservableObject {
    nonisolated(unsafe) static let shared = NotificationService()
    
    @Published var isEnabled = true
    @Published var badgeCount = 0
    
    private init() {}
    
    func requestPermissions() async -> Bool {
        // Implementation would request notification permissions
        return true
    }
    
    func scheduleLocalNotification(title: String, body: String) {
        // Implementation would schedule a local notification
    }
    
    func clearBadge() {
        badgeCount = 0
    }
}

/// Service for managing app-wide error handling and reporting
final class ErrorReportingService: ObservableObject {
    nonisolated(unsafe) static let shared = ErrorReportingService()
    
    @Published var lastError: AppError?
    @Published var errorHistory: [AppError] = []
    
    private init() {}
    
    func reportError(_ error: Error, context: String = "") {
        let appError = AppError(
            error: error,
            context: context,
            timestamp: Date()
        )
        
        lastError = appError
        errorHistory.insert(appError, at: 0)
        
        // Keep only last 50 errors
        if errorHistory.count > 50 {
            errorHistory = Array(errorHistory.prefix(50))
        }
        
        // In a real app, this would send to crash reporting service
        print("🔴 Error reported: \(error.localizedDescription) - Context: \(context)")
    }
    
    func clearErrors() {
        lastError = nil
        errorHistory.removeAll()
    }
}

/// Simple app error wrapper
struct AppError: Identifiable, Equatable {
    let id = UUID()
    let error: Error
    let context: String
    let timestamp: Date
    
    static func == (lhs: AppError, rhs: AppError) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Network Status Service

/// Service for monitoring network connectivity
final class NetworkStatusService: ObservableObject {
    nonisolated(unsafe) static let shared = NetworkStatusService()
    
    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .wifi
    
    enum ConnectionType: String, CaseIterable {
        case wifi = "WiFi"
        case cellular = "Cellular"
        case ethernet = "Ethernet"
        case none = "None"
    }
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        // In a real implementation, this would use Network framework
        // For now, assume we're always connected
    }
}

// MARK: - Analytics Service

/// Service for tracking user interactions and app usage
final class AnalyticsService: ObservableObject {
    nonisolated(unsafe) static let shared = AnalyticsService()
    
    @Published var isEnabled = true
    
    private init() {}
    
    func track(event: String, parameters: [String: Any] = [:]) {
        guard isEnabled else { return }
        
        // In a real app, this would send to analytics service
        print("📊 Analytics: \(event) - \(parameters)")
    }
    
    func trackScreen(_ screenName: String) {
        track(event: "screen_view", parameters: ["screen_name": screenName])
    }
    
    func trackError(_ error: Error, fatal: Bool = false) {
        track(event: "error", parameters: [
            "error_description": error.localizedDescription,
            "fatal": fatal
        ])
    }
}

// MARK: - Feature Flag Service

/// Service for managing feature flags and A/B testing
final class FeatureFlagService: ObservableObject {
    nonisolated(unsafe) static let shared = FeatureFlagService()
    
    @Published var flags: [String: Bool] = [
        "premium_features": false,
        "ai_recommendations": true,
        "advanced_analytics": true,
        "live_scores": true,
        "push_notifications": true,
        "dark_mode": true
    ]
    
    private init() {}
    
    func isEnabled(_ flagName: String) -> Bool {
        return flags[flagName] ?? false
    }
    
    func setFlag(_ flagName: String, enabled: Bool) {
        flags[flagName] = enabled
    }
}
