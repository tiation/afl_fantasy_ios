import Foundation
import Combine
import SwiftUI

@MainActor
class AlertsViewModel: ObservableObject {
    @Published var alerts: [Alert] = []
    @Published var filteredAlerts: [Alert] = []
    @Published var isConnected: Bool = false
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var searchText: String = ""
    @Published var selectedFilters: Set<AlertFilter> = []
    @Published var selectedPriority: Alert.Priority? = nil
    @Published var showUnreadOnly: Bool = false
    @Published var isLoading: Bool = false
    @Published var connectionError: String?
    
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
        case trade = "trade"
        case priceChange = "priceChange"
        case injury = "injury"
        case news = "news"
        
        var displayName: String {
            switch self {
            case .trade: return "Trades"
            case .priceChange: return "Prices"
            case .injury: return "Injuries"
            case .news: return "News"
            }
        }
        
        var alertType: Alert.AlertType {
            switch self {
            case .trade: return .trade
            case .priceChange: return .priceChange
            case .injury: return .injury
            case .news: return .news
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
        
        webSocketManager.$connectionStatus
            .receive(on: DispatchQueue.main)
            .map { status in
                switch status {
                case .connected: return .connected
                case .connecting: return .connecting
                case .disconnected: return .disconnected
                case .error(_): return .error
                }
            }
            .assign(to: \.connectionStatus, on: self)
            .store(in: &cancellables)
        
        // Listen for WebSocket messages
        webSocketManager.messagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.handleWebSocketMessage(message)
            }
            .store(in: &cancellables)
        
        // Update filtered alerts when search or filters change
        Publishers.CombineLatest4(
            $alerts,
            $searchText,
            $selectedFilters,
            $selectedPriority
        )
        .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
        .map { alerts, search, filters, priority in
            self.filterAlerts(alerts, search: search, filters: filters, priority: priority)
        }
        .assign(to: \.filteredAlerts, on: self)
        .store(in: &cancellables)
        
        // Update filter counts when alerts change
        $alerts
            .map { alerts in
                let unreadAlerts = alerts.filter { !$0.isRead }
                return (
                    trade: unreadAlerts.filter { $0.type == .trade }.count,
                    priceChange: unreadAlerts.filter { $0.type == .priceChange }.count,
                    injury: unreadAlerts.filter { $0.type == .injury }.count,
                    news: unreadAlerts.filter { $0.type == .news }.count,
                    total: unreadAlerts.count
                )
            }
            .sink { [weak self] counts in
                self?.tradeAlertCount = counts.trade
                self?.priceChangeCount = counts.priceChange
                self?.injuryAlertCount = counts.injury
                self?.newsAlertCount = counts.news
                self?.totalUnreadCount = counts.total
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialAlerts() {
        Task {
            await alertManager.loadAlerts()
            connectWebSocket()
        }
    }
    
    private func filterAlerts(_ alerts: [Alert], search: String, filters: Set<AlertFilter>, priority: Alert.Priority?) -> [Alert] {
        var filtered = alerts
        
        // Apply search filter
        if !search.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(search) ||
                $0.message.localizedCaseInsensitiveContains(search) ||
                ($0.playerName?.localizedCaseInsensitiveContains(search) ?? false)
            }
        }
        
        // Apply type filters
        if !filters.isEmpty {
            let filterTypes = Set(filters.map { $0.alertType })
            filtered = filtered.filter { filterTypes.contains($0.type) }
        }
        
        // Apply priority filter
        if let priority = priority {
            filtered = filtered.filter { $0.priority == priority }
        }
        
        // Apply unread only filter
        if showUnreadOnly {
            filtered = filtered.filter { !$0.isRead }
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
    
    func markAsRead(_ alert: Alert) {
        alertManager.markAsRead(alertId: alert.id)
    }
    
    func markAllAsRead() {
        alertManager.markAllAsRead()
    }
    
    func deleteAlert(_ alert: Alert) {
        alertManager.deleteAlert(alertId: alert.id)
    }
    
    func toggleFilter(_ filter: AlertFilter) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)
        }
    }
    
    func clearFilters() {
        selectedFilters.removeAll()
        selectedPriority = nil
        searchText = ""
        showUnreadOnly = false
    }
    
    func refreshAlerts() async {
        isLoading = true
        await alertManager.loadAlerts()
        isLoading = false
    }
    
    // MARK: - Demo and Testing
    
    func addDemoAlert() {
        let demoAlert = Alert.createDemo()
        alertManager.addAlert(demoAlert)
    }
    
    func simulateDisconnection() {
        webSocketManager.disconnect()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.webSocketManager.connect()
        }
    }
    
    func loadSampleAlerts() {
        let sampleAlerts = Alert.sampleAlerts
        sampleAlerts.forEach { alertManager.addAlert($0) }
    }
    
    // MARK: - Private Methods
    
    private func handleWebSocketMessage(_ message: [String: Any]) {
        // Parse WebSocket message and convert to Alert
        guard let type = message["type"] as? String else { return }
        
        switch type {
        case "alert":
            if let alertData = parseAlertFromMessage(message) {
                alertManager.addAlert(alertData)
            }
        case "alert_update":
            if let alertId = message["alertId"] as? String,
               let isRead = message["isRead"] as? Bool {
                alertManager.updateAlertReadStatus(alertId: alertId, isRead: isRead)
            }
        default:
            break
        }
    }
    
    private func parseAlertFromMessage(_ message: [String: Any]) -> Alert? {
        guard let id = message["id"] as? String,
              let title = message["title"] as? String,
              let messageText = message["message"] as? String,
              let typeString = message["alertType"] as? String,
              let priorityString = message["priority"] as? String,
              let timestampString = message["timestamp"] as? String else {
            return nil
        }
        
        guard let alertType = Alert.AlertType(rawValue: typeString),
              let priority = Alert.Priority(rawValue: priorityString) else {
            return nil
        }
        
        let dateFormatter = ISO8601DateFormatter()
        let timestamp = dateFormatter.date(from: timestampString) ?? Date()
        
        return Alert(
            id: id,
            title: title,
            message: messageText,
            type: alertType,
            priority: priority,
            timestamp: timestamp,
            isRead: false,
            playerName: message["playerName"] as? String,
            playerPrice: message["playerPrice"] as? Double,
            priceChange: message["priceChange"] as? Double,
            team: message["team"] as? String,
            position: message["position"] as? String
        )
    }
}

// MARK: - Preview Support
extension AlertsViewModel {
    static var preview: AlertsViewModel {
        let viewModel = AlertsViewModel()
        viewModel.loadSampleAlerts()
        return viewModel
    }
}
