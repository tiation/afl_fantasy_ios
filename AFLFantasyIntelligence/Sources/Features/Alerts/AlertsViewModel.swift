import SwiftUI
import Combine

@MainActor
final class AlertsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var alerts: [AlertNotification] = []
    @Published private(set) var unreadCount = 0
    @Published private(set) var isConnectedToServer = false
    @Published private(set) var latestAlert: AlertNotification?
    
    // MARK: - Computed Properties
    
    var criticalCount: Int {
        alerts.filter { $0.type.priority == .critical && !$0.isRead }.count
    }
    
    // MARK: - Private Properties
    
    private let alertManager = AlertManager()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init() {
        setupSubscriptions()
    }
    
    // MARK: - Public Methods
    
    func refresh() {
        // Triggers refresh of alerts from AlertManager
        // The published properties will automatically update via subscriptions
    }
    
    func markAsRead(_ alert: AlertNotification) {
        alertManager.markAsRead(alert)
    }
    
    func markAsUnread(_ alert: AlertNotification) {
        alertManager.markAsUnread(alert)
    }
    
    func delete(_ alert: AlertNotification) {
        alertManager.delete(alert)
    }
    
    func markAllAsRead() {
        alertManager.markAllAsRead()
    }
    
    func clearAll() {
        alertManager.clearHistory()
    }
    
    func updateSettings(_ settings: AlertSettings) {
        alertManager.updateSettings(settings)
    }
    
    func getCurrentSettings() -> AlertSettings {
        return alertManager.getSettings()
    }
    
    // MARK: - WebSocket Controls
    
    func reconnectWebSocket() {
        alertManager.reconnectWebSocket()
    }
    
    func testWebSocketConnection() {
        alertManager.testWebSocketConnection()
    }
    
    // MARK: - Demo/Test Methods
    
    func simulateAlert(_ type: AlertType) {
        alertManager.simulateAlert(type)
    }
    
    // MARK: - Permissions
    
    func requestNotificationPermission() async throws -> Bool {
        return try await alertManager.requestNotificationPermission()
    }
    
    // MARK: - Private Methods
    
    private func setupSubscriptions() {
        // Subscribe to AlertManager's published properties
        alertManager.$notificationHistory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] history in
                self?.alerts = history
            }
            .store(in: &cancellables)
        
        alertManager.$unreadCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.unreadCount = count
            }
            .store(in: &cancellables)
        
        alertManager.$isConnectedToServer
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                self?.isConnectedToServer = connected
            }
            .store(in: &cancellables)
        
        alertManager.$latestNotification
            .receive(on: DispatchQueue.main)
            .sink { [weak self] latest in
                self?.latestAlert = latest
            }
            .store(in: &cancellables)
    }
}

// MARK: - Alert Type Extensions for UI

extension AlertType {
    var color: Color {
        switch priority {
        case .low:
            return Color.gray
        case .medium:
            return Color.blue
        case .high:
            return Color.orange
        case .critical:
            return Color.red
        }
    }
}
