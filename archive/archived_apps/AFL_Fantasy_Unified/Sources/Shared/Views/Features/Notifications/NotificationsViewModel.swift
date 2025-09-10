import SwiftUI

@MainActor
final class NotificationsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var notifications: [AlertNotification] = []
    @Published private(set) var isLoading = false
    @Published var selectedNotification: AlertNotification?
    @Published var selectedFilter: AlertType?
    @Published var showError = false
    @Published var errorMessage = ""
    
    // MARK: - Computed Properties
    
    var filteredNotifications: [AlertNotification] {
        guard let filter = selectedFilter else {
            return notifications
        }
        return notifications.filter { $0.type == filter }
    }
    
    // MARK: - Dependencies
    
    private var alertManager: AlertManager!
    private let dataService: NotificationDataServiceProtocol
    
    // MARK: - Init
    
    init(
        dataService: NotificationDataServiceProtocol = NotificationDataService(),
        initialNotifications: [AlertNotification]? = nil
    ) {
        self.dataService = dataService
        
        if let initialNotifications = initialNotifications {
            self.notifications = initialNotifications
        }
        
        // Create AlertManager after initialization
        self.alertManager = AlertManager()
    }
    
    // MARK: - Public Methods
    
    func loadNotifications() {
        Task {
            do {
                isLoading = true
                defer { isLoading = false }
                
                // Load saved notifications
                notifications = try await dataService.getNotifications()
                
            } catch {
                handleError(error)
            }
        }
    }
    
    func refresh() async {
        do {
            isLoading = true
            defer { isLoading = false }
            
            // Fetch fresh notifications
            notifications = try await dataService.refreshNotifications()
            
        } catch {
            handleError(error)
        }
    }
    
    func markAsRead(_ id: String) {
        Task {
            do {
                // Update local notification
                guard let index = notifications.firstIndex(where: { $0.id == id }) else {
                    return
                }
                notifications[index].isRead = true
                
                // Update in data service
                try await dataService.markAsRead(id)
                
                // Update alert manager
                alertManager.markAsRead(id)
                
            } catch {
                handleError(error)
            }
        }
    }
    
    func markAllAsRead() {
        Task {
            do {
                // Update local notifications
                notifications = notifications.map { notification in
                    var updated = notification
                    updated.isRead = true
                    return updated
                }
                
                // Update in data service
                try await dataService.markAllAsRead()
                
                // Update alert manager
                alertManager.markAllAsRead()
                
            } catch {
                handleError(error)
            }
        }
    }
    
    func clearHistory() {
        Task {
            do {
                // Clear from data service first
                try await dataService.clearHistory()
                
                // Then clear local notifications
                notifications = []
                
                // Clear alert manager
                alertManager.clearHistory()
                
            } catch {
                handleError(error)
            }
        }
    }
    
    func handleNotificationTap(_ notification: AlertNotification) {
        // Mark as read on tap
        if !notification.isRead {
            markAsRead(notification.id)
        }
        
        // Show notification detail
        selectedNotification = notification
    }
    
    // MARK: - Private Methods
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

// MARK: - Service Protocols

protocol NotificationDataServiceProtocol {
    func getNotifications() async throws -> [AlertNotification]
    func refreshNotifications() async throws -> [AlertNotification]
    func markAsRead(_ id: String) async throws
    func markAllAsRead() async throws
    func clearHistory() async throws
}

protocol NotificationActionHandlerProtocol {
    func handleAction(for notification: AlertNotification) async throws
    func canHandle(_ notification: AlertNotification) -> Bool
}
