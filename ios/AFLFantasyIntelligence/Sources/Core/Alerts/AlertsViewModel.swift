import Foundation
import SwiftUI
import Combine

class AlertsViewModel: ObservableObject {
    @Published var alerts: [Alert] = []
    @Published var filteredAlerts: [Alert] = []
    @Published var unreadCount: Int = 0
    @Published var isConnected: Bool = false
    @Published var connectionStatus: String = "Disconnected"
    @Published var lastUpdated: Date = Date()
    @Published var searchText: String = ""
    @Published var selectedFilter: AlertFilter = .all
    @Published var sortOption: AlertManager.SortOption = .timestampDesc
    @Published var filterCounts: [AlertFilter: Int] = [:]
    @Published var alertStats: AlertStats = AlertStats()
    
    private let alertManager = AlertManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum AlertFilter: String, CaseIterable {
        case all = "All"
        case unread = "Unread"
        case critical = "Critical"
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        
        var displayName: String {
            return rawValue
        }
        
        var iconName: String {
            switch self {
            case .all: return "bell"
            case .unread: return "bell.badge"
            case .critical: return "exclamationmark.triangle.fill"
            case .high: return "exclamationmark.circle.fill"
            case .medium: return "info.circle"
            case .low: return "info.circle"
            }
        }
    }
    
    struct AlertStats {
        var total: Int = 0
        var critical: Int = 0
        var high: Int = 0
        var medium: Int = 0
        var low: Int = 0
        var unread: Int = 0
    }
    
    init() {
        setupBindings()
        loadAlerts()
    }
    
    private func setupBindings() {
        // Bind to AlertManager
        alertManager.$alerts
            .sink { [weak self] alerts in
                self?.alerts = alerts
                self?.updateFilteredAlerts()
                self?.updateStats()
            }
            .store(in: &cancellables)
        
        alertManager.$unreadCount
            .assign(to: \.unreadCount, on: self)
            .store(in: &cancellables)
        
        alertManager.$lastUpdated
            .assign(to: \.lastUpdated, on: self)
            .store(in: &cancellables)
        
        alertManager.$isConnectedToServer
            .sink { [weak self] isConnected in
                self?.isConnected = isConnected
                self?.connectionStatus = isConnected ? "Connected" : "Disconnected"
            }
            .store(in: &cancellables)
        
        // Update filtered alerts when search text or filter changes
        Publishers.CombineLatest3($searchText, $selectedFilter, $sortOption)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _, _, _ in
                self?.updateFilteredAlerts()
            }
            .store(in: &cancellables)
    }
    
    private func loadAlerts() {
        // Load from AlertManager
        alerts = alertManager.alerts
        updateFilteredAlerts()
        updateStats()
    }
    
    private func updateFilteredAlerts() {
        var filtered = alerts
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { alert in
                alert.title.localizedCaseInsensitiveContains(searchText) ||
                alert.message.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply selected filter
        switch selectedFilter {
        case .all:
            break
        case .unread:
            filtered = filtered.filter { !$0.isRead }
        case .critical:
            filtered = filtered.filter { $0.priority == .critical }
        case .high:
            filtered = filtered.filter { $0.priority == .high }
        case .medium:
            filtered = filtered.filter { $0.priority == .medium }
        case .low:
            filtered = filtered.filter { $0.priority == .low }
        }
        
        // Apply sorting
        switch sortOption {
        case .timestampDesc:
            filtered = filtered.sorted { $0.timestamp > $1.timestamp }
        case .timestampAsc:
            filtered = filtered.sorted { $0.timestamp < $1.timestamp }
        case .priorityDesc:
            filtered = filtered.sorted { $0.priority.rawValue > $1.priority.rawValue }
        case .typeGroup:
            filtered = filtered.sorted { 
                if $0.type == $1.type {
                    return $0.timestamp > $1.timestamp
                }
                return $0.type.rawValue < $1.type.rawValue
            }
        }
        
        filteredAlerts = filtered
        updateFilterCounts()
    }
    
    private func updateFilterCounts() {
        filterCounts = [:]
        filterCounts[.all] = alerts.count
        filterCounts[.unread] = alerts.filter { !$0.isRead }.count
        filterCounts[.critical] = alerts.filter { $0.priority == .critical }.count
        filterCounts[.high] = alerts.filter { $0.priority == .high }.count
        filterCounts[.medium] = alerts.filter { $0.priority == .medium }.count
        filterCounts[.low] = alerts.filter { $0.priority == .low }.count
    }
    
    private func updateStats() {
        let stats = AlertStats(
            total: alerts.count,
            critical: alerts.filter { $0.priority == .critical }.count,
            high: alerts.filter { $0.priority == .high }.count,
            medium: alerts.filter { $0.priority == .medium }.count,
            low: alerts.filter { $0.priority == .low }.count,
            unread: alerts.filter { !$0.isRead }.count
        )
        alertStats = stats
    }
    
    // MARK: - Actions
    
    func markAsRead(_ alert: Alert) {
        alertManager.markAsRead(alert)
    }
    
    func markAsUnread(_ alert: Alert) {
        alertManager.markAsUnread(alert)
    }
    
    func delete(_ alert: Alert) {
        alertManager.delete(alert)
    }
    
    func markAllAsRead() {
        alertManager.markAllAsRead()
    }
    
    func clearAllAlerts() {
        alertManager.clearAllAlerts()
    }
    
    func simulateAlert() {
        alertManager.simulateAlert()
    }
    
    func simulateWebSocketAlert() {
        alertManager.simulateAlert(.injury)
    }
    
    func loadSampleData() {
        alertManager.loadSampleData()
    }
    
    func simulateConnectionTest() {
        alertManager.testWebSocketConnection()
    }
    
    func reconnectWebSocket() {
        alertManager.reconnectWebSocket()
    }
    
    func disconnectWebSocket() {
        isConnected = false
        connectionStatus = "Disconnected"
    }
    
    func updateAlertSettings(_ newSettings: AlertSettings) {
        alertManager.updateSettings(newSettings)
    }
}
