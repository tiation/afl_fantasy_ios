import SwiftUI
import UserNotifications
import Combine

@MainActor
final class AlertManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var latestNotification: AlertNotification?
    @Published private(set) var unreadCount = 0
    @Published private(set) var notificationHistory: [AlertNotification] = []
    @Published private(set) var isConnectedToServer = false
    
    // MARK: - Internal Properties
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard
    private let historyLimit = 200
    private var cancellables = Set<AnyCancellable>()
    private var settings: AlertSettings
    
    // WebSocket integration
    private let webSocketManager = WebSocketManager.shared
    
    // MARK: - Keys
    
    private let historyKey = "alert_notification_history"
    private let settingsKey = "alert_settings"
    private var dailyCountKey: String {
        let today = Calendar.current.startOfDay(for: Date())
        return "alert_count_\(Int(today.timeIntervalSince1970))"
    }
    
    // MARK: - Init
    
    init() {
        self.settings = Self.loadSettings()
        setup()
        
        // Connect WebSocketManager to this AlertManager
        webSocketManager.setAlertManager(self)
    }
    
    // MARK: - Public Methods
    
    func requestNotificationPermission() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        let granted = try await notificationCenter.requestAuthorization(options: options)
        
        if granted {
            await MainActor.run {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        return granted
    }
    
    func markAsRead(_ notification: AlertNotification) {
        guard let index = notificationHistory.firstIndex(where: { $0.id == notification.id }) else {
            return
        }
        
        notificationHistory[index].isRead = true
        updateCountsAndSave()
    }
    
    func markAsUnread(_ notification: AlertNotification) {
        guard let index = notificationHistory.firstIndex(where: { $0.id == notification.id }) else {
            return
        }
        
        notificationHistory[index].isRead = false
        updateCountsAndSave()
    }
    
    func delete(_ notification: AlertNotification) {
        notificationHistory.removeAll { $0.id == notification.id }
        updateCountsAndSave()
    }
    
    func markAllAsRead() {
        for index in notificationHistory.indices {
            notificationHistory[index].isRead = true
        }
        updateCountsAndSave()
    }
    
    func clearHistory() {
        notificationHistory = []
        updateCountsAndSave()
    }
    
    func updateSettings(_ newSettings: AlertSettings) {
        self.settings = newSettings
        saveSettings()
    }
    
    func getSettings() -> AlertSettings {
        return settings
    }
    
    // MARK: - Real-time Alert Handling
    
    func handleIncomingAlert(_ update: AlertUpdate) {
        Task { @MainActor in
            await processAlert(update)
        }
    }
    
    // For testing/demo purposes - simulate incoming alerts
    func simulateAlert(_ type: AlertType) {
        let update = generateMockUpdate(for: type)
        handleIncomingAlert(update)
    }
    
    // WebSocket connection controls
    func reconnectWebSocket() {
        webSocketManager.disconnect()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.webSocketManager.connect()
        }
    }
    
    func testWebSocketConnection() {
        // Send a test alert to verify the connection
        let testAlert = AlertUpdate(
            type: .system,
            title: "Connection Test",
            message: "WebSocket connection test successful at \(Date().formatted(.dateTime))",
            playerId: nil,
            data: ["test": "true"]
        )
        handleIncomingAlert(testAlert)
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        loadHistory()
        updateUnreadCount()
        
        // Setup periodic cleanup of old alerts
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.cleanupOldAlerts()
            }
        }
        
        // Observe WebSocket connection state
        webSocketManager.$connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.isConnectedToServer = state.isConnected
            }
            .store(in: &cancellables)
        
        // Ensure connection
        webSocketManager.connect()
    }
    
    private func processAlert(_ update: AlertUpdate) async {
        // Check if alert type is enabled in settings
        guard isAlertTypeEnabled(update.type) else {
            print("🔕 Alert type \(update.type) is disabled in settings")
            return
        }
        
        // Check priority threshold
        guard update.type.priority.rawValue >= settings.minimumPriority.rawValue else {
            print("🔕 Alert priority \(update.type.priority) below threshold \(settings.minimumPriority)")
            return
        }
        
        // Check daily limit
        let todayCount = defaults.integer(forKey: dailyCountKey)
        guard todayCount < settings.maxAlertsPerDay else {
            print("🔕 Daily alert limit reached: \(settings.maxAlertsPerDay)")
            return
        }
        
        // Check quiet hours
        if settings.enableQuietHours && isInQuietHours() {
            print("🔕 Alert suppressed due to quiet hours")
            return
        }
        
        // Create notification
        let notification = AlertNotification(
            id: update.id,
            title: update.title,
            message: update.message,
            type: update.type,
            timestamp: update.timestamp,
            isRead: false,
            playerId: update.playerId
        )
        
        // Add to history
        notificationHistory.insert(notification, at: 0)
        if notificationHistory.count > historyLimit {
            notificationHistory = Array(notificationHistory.prefix(historyLimit))
        }
        
        // Update state
        latestNotification = notification
        updateCountsAndSave()
        
        // Increment daily count
        defaults.set(todayCount + 1, forKey: dailyCountKey)
        
        // Show system notification if enabled
        if settings.pushNotifications {
            await showSystemNotification(for: notification)
        }
        
        print("📱 New alert: \(notification.title)")
    }
    
    private func isAlertTypeEnabled(_ type: AlertType) -> Bool {
        switch type {
        case .priceChange: return settings.priceChanges
        case .injury: return settings.injuries
        case .tradeDeadline: return settings.tradeDeadlines
        case .captainReminder: return settings.captainReminders
        case .breakingNews: return settings.breakingNews
        case .formAlert: return settings.formAlerts
        case .aiRecommendation: return settings.aiRecommendations
        case .priceThreshold: return settings.priceThresholds
        case .milestoneReached: return settings.milestones
        case .fixtureChange: return settings.fixtureChanges
        default: return true // Enable system alerts by default
        }
    }
    
    private func isInQuietHours() -> Bool {
        let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let startComponents = Calendar.current.dateComponents([.hour, .minute], from: settings.quietHoursStart)
        let endComponents = Calendar.current.dateComponents([.hour, .minute], from: settings.quietHoursEnd)
        
        let currentMinutes = (now.hour ?? 0) * 60 + (now.minute ?? 0)
        let startMinutes = (startComponents.hour ?? 0) * 60 + (startComponents.minute ?? 0)
        let endMinutes = (endComponents.hour ?? 0) * 60 + (endComponents.minute ?? 0)
        
        if startMinutes <= endMinutes {
            return currentMinutes >= startMinutes && currentMinutes <= endMinutes
        } else {
            // Overnight quiet hours (e.g., 10 PM to 6 AM)
            return currentMinutes >= startMinutes || currentMinutes <= endMinutes
        }
    }
    
    private func showSystemNotification(for notification: AlertNotification) async {
        let authStatus = await notificationCenter.notificationSettings().authorizationStatus
        guard authStatus == .authorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.message
        content.sound = notification.type.priority == .critical ? .defaultCritical : .default
        content.userInfo = [
            "alertId": notification.id,
            "alertType": notification.type.rawValue
        ]
        
        let request = UNNotificationRequest(
            identifier: notification.id,
            content: content,
            trigger: nil // Show immediately
        )
        
        do {
            try await notificationCenter.add(request)
            updateBadge()
        } catch {
            print("Failed to show notification: \(error)")
        }
    }
    
    private func updateCountsAndSave() {
        updateUnreadCount()
        updateBadge()
        saveHistory()
    }
    
    private func updateUnreadCount() {
        unreadCount = notificationHistory.filter { !$0.isRead }.count
    }
    
    private func updateBadge() {
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(unreadCount) { error in
                if let error = error {
                    print("Failed to set badge count: \(error)")
                }
            }
        } else {
            UIApplication.shared.applicationIconBadgeNumber = unreadCount
        }
    }
    
    private func loadHistory() {
        guard let data = defaults.data(forKey: historyKey),
              let history = try? JSONDecoder().decode([AlertNotification].self, from: data) else {
            return
        }
        
        notificationHistory = history
    }
    
    private func saveHistory() {
        do {
            let data = try JSONEncoder().encode(notificationHistory)
            defaults.set(data, forKey: historyKey)
        } catch {
            print("Failed to save alert history: \(error)")
        }
    }
    
    private static func loadSettings() -> AlertSettings {
        guard let data = UserDefaults.standard.data(forKey: "alert_settings"),
              let settings = try? JSONDecoder().decode(AlertSettings.self, from: data) else {
            return .default
        }
        return settings
    }
    
    private func saveSettings() {
        do {
            let data = try JSONEncoder().encode(settings)
            defaults.set(data, forKey: settingsKey)
        } catch {
            print("Failed to save alert settings: \(error)")
        }
    }
    
    private func cleanupOldAlerts() {
        let oneWeekAgo = Date().addingTimeInterval(-7 * 24 * 3600)
        let originalCount = notificationHistory.count
        
        notificationHistory.removeAll { $0.timestamp < oneWeekAgo && $0.isRead }
        
        if notificationHistory.count != originalCount {
            print("🧹 Cleaned up \(originalCount - notificationHistory.count) old alerts")
            updateCountsAndSave()
        }
    }
    
    private func generateMockUpdate(for type: AlertType) -> AlertUpdate {
        let mockData: (String, String) = {
            switch type {
            case .injury:
                return ("Injury Alert", "Sam Walsh has been ruled out with a hamstring injury")
            case .priceChange:
                return ("Price Rise", "Christian Petracca has increased by $12,000")
            case .tradeDeadline:
                return ("Trade Deadline", "Trades lock in 30 minutes")
            case .aiRecommendation:
                return ("AI Insight", "Consider trading in Lachie Neale based on recent form (confidence: 92%)")
            case .breakingNews:
                return ("Breaking News", "Adelaide vs Port Adelaide moved to Sunday night")
            default:
                return ("Alert", "Sample alert message")
            }
        }()
        
        return AlertUpdate(
            type: type,
            title: mockData.0,
            message: mockData.1,
            playerId: type == .system ? nil : "player_\(Int.random(in: 1...100))"
        )
    }
}

// MARK: - Extensions

extension AlertSettings: Codable {
    enum CodingKeys: CodingKey {
        case priceChanges, injuries, tradeDeadlines, captainReminders
        case breakingNews, formAlerts, aiRecommendations, priceThresholds, milestones, fixtureChanges
        case pushNotifications, inAppAlerts, emailDigest
        case minimumPriority, priceChangeThreshold, maxAlertsPerDay
        case enableQuietHours, quietHoursStart, quietHoursEnd
    }
}
