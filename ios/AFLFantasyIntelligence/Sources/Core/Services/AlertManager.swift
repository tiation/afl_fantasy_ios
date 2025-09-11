import Foundation
import Combine
import UserNotifications

class AlertManager: ObservableObject {
    @Published var alerts: [AlertNotification] = []
    @Published var unreadCount: Int = 0
    @Published var lastUpdated: Date = Date()
    @Published var isConnectedToServer: Bool = false
    @Published var latestNotification: AlertNotification?
    
    // Filter and sort preferences
    @Published var selectedTypes: Set<AlertType> = Set(AlertType.allCases)
    @Published var selectedPriorities: Set<AlertPriority> = Set(AlertPriority.allCases)
    @Published var sortOption: SortOption = .timestampDesc
    
    private let userDefaults = UserDefaults.standard
    private let alertsKey = "saved_alerts"
    private let preferencesKey = "alert_preferences"
    
    // Notification settings
    @Published var notificationsEnabled: Bool = true
    @Published var quietHoursEnabled: Bool = false
    @Published var quietHoursStart: Date = Calendar.current.date(from: DateComponents(hour: 22, minute: 0))!
    @Published var quietHoursEnd: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0))!
    
    enum SortOption: String, CaseIterable {
        case timestampDesc = "timestamp_desc"
        case timestampAsc = "timestamp_asc"
        case priorityDesc = "priority_desc"
        case typeGroup = "type_group"
        
        var displayName: String {
            switch self {
            case .timestampDesc: return "Newest First"
            case .timestampAsc: return "Oldest First"
            case .priorityDesc: return "High Priority First"
            case .typeGroup: return "Group by Type"
            }
        }
    }
    
    init() {
        loadAlerts()
        loadPreferences()
        setupNotificationObservers()
        
        // Load sample data if no alerts exist
        if alerts.isEmpty {
            alerts = sampleAlerts
            updateUnreadCount()
            saveAlerts()
        }
    }
    
    func markAsRead(_ alert: AlertNotification) {
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index].isRead = true
            updateUnreadCount()
            saveAlerts()
            lastUpdated = Date()
        }
    }
    
    func markAsUnread(_ alert: AlertNotification) {
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index].isRead = false
            updateUnreadCount()
            saveAlerts()
            lastUpdated = Date()
        }
    }
    
    func delete(_ alert: AlertNotification) {
        alerts.removeAll { $0.id == alert.id }
        updateUnreadCount()
        saveAlerts()
        lastUpdated = Date()
    }
    
    func deleteAlert(_ alert: AlertNotification) {
        delete(alert)
    }
    
    func markAllAsRead() {
        for index in alerts.indices {
            alerts[index].isRead = true
        }
        updateUnreadCount()
        saveAlerts()
        lastUpdated = Date()
    }
    
    func clearHistory() {
        alerts.removeAll()
        updateUnreadCount()
        saveAlerts()
        lastUpdated = Date()
    }
    
    func clearAllAlerts() {
        clearHistory()
    }
    
    func updateSettings(_ settings: AlertSettings) {
        savePreferences()
    }
    
    func getSettings() -> AlertSettings {
        return AlertSettings.default // Use the default settings from shared type
    }
    
    func reconnectWebSocket() {
        // TODO: Implement websocket reconnection
        isConnectedToServer = true
    }
    
    func testWebSocketConnection() {
        // TODO: Test websocket connection
        isConnectedToServer = true
    }
    
    func simulateAlert(_ type: AlertType = .priceChange) {
        let alert = AlertNotification(
            title: "Simulated \(type.displayName)",
            message: "This is a test \(type.displayName.lowercased()) alert",
            type: type,
            playerId: "test_player_123"
        )
        alerts.insert(alert, at: 0)
        latestNotification = alert
        updateUnreadCount()
        saveAlerts()
        lastUpdated = Date()
    }
    
    func simulateNewAlert() {
        simulateAlert()
    }
    
    func loadSampleData() {
        alerts = sampleAlerts
        updateUnreadCount()
        saveAlerts()
        lastUpdated = Date()
    }
    
    func requestNotificationPermission() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        if settings.authorizationStatus == .notDetermined {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        }
        
        return settings.authorizationStatus == .authorized
    }
    
    private func updateUnreadCount() {
        unreadCount = alerts.filter { !$0.isRead }.count
    }
    
    private func loadAlerts() {
        guard let data = userDefaults.data(forKey: alertsKey),
              let loadedAlerts = try? JSONDecoder().decode([AlertNotification].self, from: data) else {
            return
        }
        alerts = loadedAlerts
        updateUnreadCount()
    }
    
    private func saveAlerts() {
        guard let data = try? JSONEncoder().encode(alerts) else { return }
        userDefaults.set(data, forKey: alertsKey)
    }
    
    private func loadPreferences() {
        // Load user preferences from UserDefaults
        notificationsEnabled = userDefaults.bool(forKey: "notifications_enabled")
        quietHoursEnabled = userDefaults.bool(forKey: "quiet_hours_enabled")
    }
    
    private func savePreferences() {
        userDefaults.set(notificationsEnabled, forKey: "notifications_enabled")
        userDefaults.set(quietHoursEnabled, forKey: "quiet_hours_enabled")
    }
    
    private func setupNotificationObservers() {
        // Setup notification observers if needed
    }
}

// MARK: - Supporting Types

// Use AlertNotificationSettings from Models.swift instead of duplicate

// MARK: - Additional Types for AlertsView

extension AlertManager {
    struct AlertStats {
        let total: Int
        let unread: Int
        let critical: Int
        let high: Int
        let medium: Int
        let low: Int
    }
    
    var alertStats: AlertStats {
        AlertStats(
            total: alerts.count,
            unread: alerts.filter { !$0.isRead }.count,
            critical: alerts.filter { $0.type.priority == .critical }.count,
            high: alerts.filter { $0.type.priority == .high }.count,
            medium: alerts.filter { $0.type.priority == .medium }.count,
            low: alerts.filter { $0.type.priority == .low }.count
        )
    }
    
    // Sample alerts data
    var sampleAlerts: [AlertNotification] {
        [
            AlertNotification(
                title: "Price Rise Alert",
                message: "Max Gawn has increased by $12,000 in value",
                type: .priceChange,
                timestamp: Date().addingTimeInterval(-300), // 5 minutes ago
                isRead: false,
                playerId: "max_gawn_123"
            ),
            AlertNotification(
                title: "Injury Update",
                message: "Jordan Dawson is now listed as Test for Round 15",
                type: .injury,
                timestamp: Date().addingTimeInterval(-1800), // 30 minutes ago
                isRead: false,
                playerId: "jordan_dawson_456"
            ),
            AlertNotification(
                title: "Late Out",
                message: "Clayton Oliver has been ruled out with a knee injury",
                type: .lateOut,
                timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
                isRead: true,
                playerId: "clayton_oliver_789"
            ),
            AlertNotification(
                title: "Captain Reminder",
                message: "Don't forget to set your captain before lockout",
                type: .captainReminder,
                timestamp: Date().addingTimeInterval(-7200), // 2 hours ago
                isRead: false,
                playerId: nil
            ),
            AlertNotification(
                title: "Trade Deadline",
                message: "Trade deadline is approaching in 2 hours",
                type: .tradeDeadline,
                timestamp: Date().addingTimeInterval(-10800), // 3 hours ago
                isRead: true,
                playerId: nil
            ),
            AlertNotification(
                title: "AI Recommendation",
                message: "Consider trading out Nick Daicos based on upcoming fixtures",
                type: .aiRecommendation,
                timestamp: Date().addingTimeInterval(-21600), // 6 hours ago
                isRead: true,
                playerId: "nick_daicos_321"
            )
        ]
    }
}
