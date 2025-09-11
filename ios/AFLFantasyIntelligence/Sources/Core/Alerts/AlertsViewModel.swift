import Foundation
import Combine
import SwiftUI

@MainActor
class AlertsViewModel: ObservableObject {
    @Published var alerts: [AlertNotification] = []
    @Published var filteredAlerts: [AlertNotification] = []
    @Published var isConnected: Bool = false
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var searchText: String = ""
    @Published var selectedFilter: AlertFilter = .all
    @Published var selectedPriority: AlertPriority? = nil
    @Published var showUnreadOnly: Bool = false
    @Published var isLoading: Bool = false
    @Published var connectionError: String?
    @Published var lastUpdated: Date = Date()
    
    // Computed properties for UI
    var unreadCount: Int {
        alerts.filter { !$0.isRead }.count
    }
    
    var alertStats: (total: Int, critical: Int) {
        (alerts.count, alerts.filter { $0.type.priority == .critical }.count)
    }
    
    var filterCounts: [AlertFilter: Int] {
        var counts: [AlertFilter: Int] = [:]
        for filter in AlertFilter.allCases {
            switch filter {
            case .all:
                counts[filter] = alerts.count
            case .unread:
                counts[filter] = alerts.filter { !$0.isRead }.count
            case .critical:
                counts[filter] = alerts.filter { $0.type.priority == .critical }.count
            case .high:
                counts[filter] = alerts.filter { $0.type.priority == .high }.count
            default:
                counts[filter] = 0
            }
        }
        return counts
    }
    
    // Filter counts
    @Published var tradeAlertCount: Int = 0
    @Published var priceChangeCount: Int = 0
    @Published var injuryAlertCount: Int = 0
    @Published var newsAlertCount: Int = 0
    @Published var totalUnreadCount: Int = 0
    
    enum ConnectionStatus: String {
        case connected = "Connected"
        case connecting = "Connecting"
        case disconnected = "Disconnected"
        case error = "Connection Error"
        
        var color: Color {
            switch self {
            case .connected: return .green
            case .connecting: return .orange
            case .disconnected, .error: return .red
            }
        }
    }
    
    enum AlertFilter: String, CaseIterable {
        case all = "all"
        case unread = "unread"
        case critical = "critical"
        case high = "high"
        case trade = "trade"
        case priceChange = "priceChange"
        case injury = "injury"
        case news = "news"
        
        var displayName: String {
            switch self {
            case .all: return "All"
            case .unread: return "Unread"
            case .critical: return "Critical"
            case .high: return "High"
            case .trade: return "Trades"
            case .priceChange: return "Prices"
            case .injury: return "Injuries"
            case .news: return "News"
            }
        }
        
        var iconName: String {
            switch self {
            case .all: return "bell"
            case .unread: return "bell.badge"
            case .critical: return "exclamationmark.triangle.fill"
            case .high: return "exclamationmark.circle"
            case .trade: return "arrow.triangle.2.circlepath"
            case .priceChange: return "dollarsign.circle"
            case .injury: return "cross.circle"
            case .news: return "newspaper.circle"
            }
        }
        
        var alertType: AlertType? {
            switch self {
            case .trade: return .tradeOpportunity
            case .priceChange: return .priceChange
            case .injury: return .injury
            case .news: return .breakingNews
            default: return nil
            }
        }
    }
    
    private let alertManager: AlertManager
    private let webSocketManager: WebSocketManager
    private var cancellables = Set<AnyCancellable>()
    
    init(alertManager: AlertManager = AlertManager(), webSocketManager: WebSocketManager = WebSocketManager()) {
        self.alertManager = alertManager
        self.webSocketManager = webSocketManager
        
        setupBindings()
        loadInitialAlerts()
    }
    
    private func setupBindings() {
        // Bind alerts from AlertManager
        alertManager.$alerts
            .receive(on: DispatchQueue.main)
            .assign(to: \.alerts, on: self)
            .store(in: &cancellables)
        
        // Bind connection status from WebSocketManager
        webSocketManager.$isConnected
            .receive(on: DispatchQueue.main)
            .assign(to: \.isConnected, on: self)
            .store(in: &cancellables)
        
        // Simulate connection status updates for now
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.lastUpdated = Date()
            }
            .store(in: &cancellables)
        
        // Update filtered alerts when search or filters change
        Publishers.CombineLatest3(
            $alerts,
            $searchText,
            $selectedFilter
        )
        .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
        .map { alerts, search, filter in
            self.filterAlerts(alerts, search: search, filter: filter)
        }
        .assign(to: \.filteredAlerts, on: self)
        .store(in: &cancellables)
        
    }
    
    private func loadInitialAlerts() {
        Task {
            // For now, just simulate loading
            isConnected = false
            connectionStatus = .connecting
            
            // Load sample data for demo
            loadSampleData()
        }
    }
    
    private func filterAlerts(_ alerts: [AlertNotification], search: String, filter: AlertFilter) -> [AlertNotification] {
        var filtered = alerts
        
        // Apply search filter
        if !search.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(search) ||
                $0.message.localizedCaseInsensitiveContains(search)
            }
        }
        
        // Apply filter
        switch filter {
        case .all:
            // No filtering needed
            break
        case .unread:
            filtered = filtered.filter { !$0.isRead }
        case .critical:
            filtered = filtered.filter { $0.type.priority == .critical }
        case .high:
            filtered = filtered.filter { $0.type.priority == .high }
        default:
            if let alertType = filter.alertType {
                filtered = filtered.filter { $0.type == alertType }
            }
        }
        
        // Sort by timestamp (newest first)
        return filtered.sorted { $0.timestamp > $1.timestamp }
    }
    
    // MARK: - Public Actions
    
    func connectWebSocket() {
        webSocketManager.connect()
    }
    
    func disconnectWebSocket() {
        webSocketManager.disconnect()
    }
    
    func markAsRead(_ alert: AlertNotification) {
        // For now, just update the alert in our local array
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index] = AlertNotification(
                id: alert.id,
                title: alert.title,
                message: alert.message,
                type: alert.type,
                timestamp: alert.timestamp,
                isRead: true,
                playerId: alert.playerId
            )
        }
    }
    
    func markAllAsRead() {
        alerts = alerts.map {
            AlertNotification(
                id: $0.id,
                title: $0.title,
                message: $0.message,
                type: $0.type,
                timestamp: $0.timestamp,
                isRead: true,
                playerId: $0.playerId
            )
        }
    }
    
    func clearAllAlerts() {
        alerts.removeAll()
    }
    
    func deleteAlert(_ alert: AlertNotification) {
        alerts.removeAll { $0.id == alert.id }
    }
    
    func reconnectWebSocket() {
        webSocketManager.disconnect()
        webSocketManager.connect()
    }
    
    func refreshAlerts() async {
        isLoading = true
        // Simulate loading delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isLoading = false
    }
    
    // MARK: - Demo and Testing
    
    func simulateAlert() {
        let alert = AlertNotification(
            title: "Price Drop Alert",
            message: "Marcus Bontempelli has dropped $50,000 in value!",
            type: .priceChange
        )
        alerts.append(alert)
    }
    
    func simulateWebSocketAlert() {
        let alert = AlertNotification(
            title: "Live WebSocket Update",
            message: "Real-time connection established successfully",
            type: .system
        )
        alerts.append(alert)
    }
    
    func simulateConnectionTest() {
        connectionStatus = .connecting
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.connectionStatus = .connected
            self.isConnected = true
        }
    }
    
    func loadSampleData() {
        let sampleAlerts = [
            AlertNotification(
                title: "Trade Deadline Reminder",
                message: "Don't forget to make your trades before the deadline!",
                type: .tradeDeadline
            ),
            AlertNotification(
                title: "Injury Update",
                message: "Clayton Oliver is ruled out for 2-3 weeks with a hamstring injury",
                type: .injury
            ),
            AlertNotification(
                title: "Price Rise Alert",
                message: "Sam Walsh has increased by $25,000 in value",
                type: .priceChange,
                timestamp: Date().addingTimeInterval(-3600)
            ),
            AlertNotification(
                title: "Breaking News",
                message: "Major coaching change announced at Richmond FC",
                type: .breakingNews,
                timestamp: Date().addingTimeInterval(-7200),
                isRead: true
            )
        ]
        alerts = sampleAlerts
    }
    
    // MARK: - Settings Management
    
    func updateSettings(_ settings: AlertSettings) {
        // Save settings to UserDefaults or other persistence layer
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "alert_settings")
        }
    }
    
    func getCurrentSettings() -> AlertSettings {
        // Load settings from UserDefaults or return default
        guard let data = UserDefaults.standard.data(forKey: "alert_settings"),
              let settings = try? JSONDecoder().decode(AlertSettings.self, from: data) else {
            return AlertSettings.default
        }
        return settings
    }
    
    // MARK: - Private Methods
    
    private func handleWebSocketMessage(_ message: [String: Any]) {
        // Parse WebSocket message and convert to AlertNotification
        guard let type = message["type"] as? String else { return }
        
        switch type {
        case "alert":
            if let alertData = parseAlertFromMessage(message) {
                alerts.append(alertData)
            }
        case "alert_update":
            if let alertId = message["alertId"] as? String,
               let isRead = message["isRead"] as? Bool {
                if let index = alerts.firstIndex(where: { $0.id == alertId }) {
                    var updatedAlert = alerts[index]
                    updatedAlert = AlertNotification(
                        id: updatedAlert.id,
                        title: updatedAlert.title,
                        message: updatedAlert.message,
                        type: updatedAlert.type,
                        timestamp: updatedAlert.timestamp,
                        isRead: isRead,
                        playerId: updatedAlert.playerId
                    )
                    alerts[index] = updatedAlert
                }
            }
        default:
            break
        }
    }
    
    private func parseAlertFromMessage(_ message: [String: Any]) -> AlertNotification? {
        guard let id = message["id"] as? String,
              let title = message["title"] as? String,
              let messageText = message["message"] as? String,
              let typeString = message["alertType"] as? String,
              let timestampString = message["timestamp"] as? String else {
            return nil
        }
        
        guard let alertType = AlertType(rawValue: typeString) else {
            return nil
        }
        
        let dateFormatter = ISO8601DateFormatter()
        let timestamp = dateFormatter.date(from: timestampString) ?? Date()
        
        return AlertNotification(
            id: id,
            title: title,
            message: messageText,
            type: alertType,
            timestamp: timestamp,
            isRead: false,
            playerId: message["playerId"] as? String
        )
    }
}

// MARK: - Preview Support
extension AlertsViewModel {
    static var preview: AlertsViewModel {
        let viewModel = AlertsViewModel()
        viewModel.loadSampleData()
        return viewModel
    }
}
