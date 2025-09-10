import Foundation
import Combine

/// View model for managing alerts and alert settings
@MainActor
final class AlertsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var alerts: [AlertNotification] = []
    @Published var unreadCount = 0
    @Published var alertSettings = AlertSettings.default
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    
    var unreadAlerts: [AlertNotification] {
        alerts.filter { !$0.isRead }
    }
    
    var criticalAlerts: [AlertNotification] {
        alerts.filter { $0.priority == .critical }
    }
    
    var recentAlerts: [AlertNotification] {
        let calendar = Calendar.current
        let oneDayAgo = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return alerts.filter { $0.createdAt > oneDayAgo }
    }
    
    // MARK: - Private Properties
    
    private let alertManager = AlertManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupBindings()
        loadAlerts()
        loadAlertSettings()
    }
    
    // MARK: - Public Methods
    
    /// Load alerts from the alert manager
    func loadAlerts() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let loadedAlerts = try await alertManager.getAllAlerts()
                alerts = loadedAlerts.sorted { $0.createdAt > $1.createdAt }
                updateUnreadCount()
                isLoading = false
            } catch {
                errorMessage = "Failed to load alerts: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    /// Mark an alert as read
    func markAlertAsRead(_ alert: AlertNotification) {
        guard !alert.isRead else { return }
        
        Task {
            do {
                try await alertManager.markAlertAsRead(alertId: alert.id)
                
                // Update local state
                if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
                    alerts[index] = AlertNotification(
                        id: alert.id,
                        type: alert.type,
                        title: alert.title,
                        message: alert.message,
                        priority: alert.priority,
                        createdAt: alert.createdAt,
                        isRead: true,
                        actionURL: alert.actionURL,
                        metadata: alert.metadata
                    )
                    updateUnreadCount()
                }
            } catch {
                errorMessage = "Failed to mark alert as read: \(error.localizedDescription)"
            }
        }
    }
    
    /// Mark all alerts as read
    func markAllAlertsAsRead() {
        let unreadAlertIds = unreadAlerts.map { $0.id }
        guard !unreadAlertIds.isEmpty else { return }
        
        Task {
            do {
                try await alertManager.markAllAlertsAsRead()
                
                // Update local state
                alerts = alerts.map { alert in
                    AlertNotification(
                        id: alert.id,
                        type: alert.type,
                        title: alert.title,
                        message: alert.message,
                        priority: alert.priority,
                        createdAt: alert.createdAt,
                        isRead: true,
                        actionURL: alert.actionURL,
                        metadata: alert.metadata
                    )
                }
                updateUnreadCount()
            } catch {
                errorMessage = "Failed to mark all alerts as read: \(error.localizedDescription)"
            }
        }
    }
    
    /// Delete an alert
    func deleteAlert(_ alert: AlertNotification) {
        Task {
            do {
                try await alertManager.deleteAlert(alertId: alert.id)
                
                // Remove from local state
                alerts.removeAll { $0.id == alert.id }
                updateUnreadCount()
            } catch {
                errorMessage = "Failed to delete alert: \(error.localizedDescription)"
            }
        }
    }
    
    /// Clear all alerts
    func clearAllAlerts() {
        Task {
            do {
                try await alertManager.clearAllAlerts()
                alerts.removeAll()
                updateUnreadCount()
            } catch {
                errorMessage = "Failed to clear all alerts: \(error.localizedDescription)"
            }
        }
    }
    
    /// Update alert settings
    func updateAlertSettings(_ newSettings: AlertSettings) {
        alertSettings = newSettings
        
        Task {
            do {
                try await alertManager.updateAlertSettings(newSettings)
            } catch {
                errorMessage = "Failed to update alert settings: \(error.localizedDescription)"
            }
        }
    }
    
    /// Create a test alert (for development/testing)
    func createTestAlert() {
        let testAlert = AlertNotification(
            id: UUID().uuidString,
            type: .priceChange,
            title: "Test Alert",
            message: "This is a test alert created at \(Date().formatted())",
            priority: .medium,
            createdAt: Date(),
            isRead: false,
            actionURL: nil,
            metadata: [:]
        )
        
        alerts.insert(testAlert, at: 0)
        updateUnreadCount()
    }
    
    /// Refresh alerts from server
    func refreshAlerts() async {
        await loadAlertsAsync()
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Listen to alert manager notifications
        alertManager.alertsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newAlerts in
                self?.alerts = newAlerts.sorted { $0.createdAt > $1.createdAt }
                self?.updateUnreadCount()
            }
            .store(in: &cancellables)
    }
    
    private func loadAlertsAsync() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let loadedAlerts = try await alertManager.getAllAlerts()
            alerts = loadedAlerts.sorted { $0.createdAt > $1.createdAt }
            updateUnreadCount()
        } catch {
            errorMessage = "Failed to load alerts: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func loadAlertSettings() {
        Task {
            do {
                let settings = try await alertManager.getAlertSettings()
                alertSettings = settings
            } catch {
                // Use default settings if loading fails
                alertSettings = AlertSettings.default
            }
        }
    }
    
    private func updateUnreadCount() {
        unreadCount = alerts.filter { !$0.isRead }.count
    }
}

// MARK: - Preview Helper

extension AlertsViewModel {
    static func preview() -> AlertsViewModel {
        let viewModel = AlertsViewModel()
        
        // Add some mock alerts for preview
        viewModel.alerts = [
            AlertNotification(
                id: "1",
                type: .priceChange,
                title: "Price Alert",
                message: "Max Gawn's price has increased by $25,000",
                priority: .high,
                createdAt: Date().addingTimeInterval(-3600),
                isRead: false,
                actionURL: nil,
                metadata: ["playerId": "123", "priceChange": 25000]
            ),
            AlertNotification(
                id: "2",
                type: .injury,
                title: "Injury Update",
                message: "Patrick Dangerfield is a late withdrawal",
                priority: .critical,
                createdAt: Date().addingTimeInterval(-7200),
                isRead: false,
                actionURL: nil,
                metadata: ["playerId": "456"]
            ),
            AlertNotification(
                id: "3",
                type: .teamNews,
                title: "Team News",
                message: "Richmond has made 3 changes to their lineup",
                priority: .medium,
                createdAt: Date().addingTimeInterval(-10800),
                isRead: true,
                actionURL: nil,
                metadata: ["teamId": "richmond"]
            )
        ]
        
        viewModel.updateUnreadCount()
        return viewModel
    }
}
