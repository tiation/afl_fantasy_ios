import Foundation
import Combine
import UserNotifications

class AlertManager: ObservableObject {
    @Published var alerts: [Alert] = []
    @Published var unreadCount: Int = 0
    @Published var lastUpdated: Date = Date()
    @Published var isConnectedToServer: Bool = false
    @Published var latestNotification: Alert?
    
    // Filter and sort preferences
    @Published var selectedTypes: Set<Alert.AlertType> = Set(Alert.AlertType.allCases)
    @Published var selectedPriorities: Set<Alert.Priority> = Set(Alert.Priority.allCases)
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
            alerts = Alert.sampleAlerts
            updateUnreadCount()
            saveAlerts()
        }
    }
    
    func markAsRead(_ alert: Alert) {
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index].isRead = true
            updateUnreadCount()
            saveAlerts()
            lastUpdated = Date()
        }
    }
    
    func markAsUnread(_ alert: Alert) {
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index].isRead = false
            updateUnreadCount()
            saveAlerts()
            lastUpdated = Date()
        }
    }
    
    func delete(_ alert: Alert) {
        alerts.removeAll { $0.id == alert.id }
        updateUnreadCount()
        saveAlerts()
        lastUpdated = Date()
    }
    
    func deleteAlert(_ alert: Alert) {
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
        return AlertSettings() // Return default settings for now
    }
    
    func reconnectWebSocket() {
        // TODO: Implement websocket reconnection
        isConnectedToServer = true
    }
    
    func testWebSocketConnection() {
        // TODO: Test websocket connection
        isConnectedToServer = true
    }
    
    func simulateAlert(_ type: Alert.AlertType = .priceChange) {
        let alert = Alert(
            title: "Simulated \(type.displayName)",
            message: "This is a test \(type.displayName.lowercased()) alert",
            type: type,
            priority: .medium,
            playerName: "Test Player"
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
        alerts = Alert.sampleAlerts
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
              let loadedAlerts = try? JSONDecoder().decode([Alert].self, from: data) else {
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

struct AlertSettings {
    var priceChangeEnabled: Bool = true
    var injuryEnabled: Bool = true
    var teamSelectionEnabled: Bool = true
    var breakevenEnabled: Bool = true
    var tradeEnabled: Bool = true
    var captainEnabled: Bool = true
    
    var minimumPriceChange: Int = 5000
    var pushNotificationsEnabled: Bool = true
    var soundEnabled: Bool = true
}

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
            critical: alerts.filter { $0.priority == .critical }.count,
            high: alerts.filter { $0.priority == .high }.count,
            medium: alerts.filter { $0.priority == .medium }.count,
            low: alerts.filter { $0.priority == .low }.count
        )
    }
}
