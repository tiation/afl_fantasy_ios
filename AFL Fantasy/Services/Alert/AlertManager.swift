import SwiftUI
import UserNotifications

@MainActor
final class AlertManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var latestNotification: AlertNotification?
    @Published private(set) var unreadCount = 0
    @Published private(set) var notificationHistory: [AlertNotification] = []
    
    // MARK: - Internal Properties
    
    private let webSocket: WebSocketManager
    private let notificationCenter = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard
    private let historyLimit = 100
    private let maxNotificationsPerDay = 20
    
    private var notificationCountKey: String {
        let today = Calendar.current.startOfDay(for: Date())
        return "notifications_count_\(today.timeIntervalSince1970)"
    }
    
    // MARK: - Init
    
    init(webSocket: WebSocketManager = WebSocketManager()) {
        self.webSocket = webSocket
        setup()
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
    
    func markAllAsRead() {
        notificationHistory = notificationHistory.map { notification in
            var updated = notification
            updated.isRead = true
            return updated
        }
        
        unreadCount = 0
        updateBadge()
        saveHistory()
    }
    
    func markAsRead(_ id: String) {
        guard let index = notificationHistory.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        notificationHistory[index].isRead = true
        unreadCount = notificationHistory.filter { !$0.isRead }.count
        updateBadge()
        saveHistory()
    }
    
    func clearHistory() {
        notificationHistory = []
        unreadCount = 0
        updateBadge()
        saveHistory()
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        // Load notification history
        if let data = defaults.data(forKey: "notification_history"),
           let history = try? JSONDecoder().decode([AlertNotification].self, from: data) {
            notificationHistory = history
            unreadCount = history.filter { !$0.isRead }.count
        }
        
        // Listen for WebSocket alerts
        webSocket.onAlert { [weak self] update in
            self?.handleAlert(update)
        }
        
        // Connect WebSocket
        webSocket.connect()
    }
    
    private func handleAlert(_ update: AlertUpdate) async {
        // Check daily notification limit
        let todayCount = defaults.integer(forKey: notificationCountKey)
        guard todayCount < maxNotificationsPerDay else {
            print("⚠️ Daily notification limit reached")
            return
        }
        
        // Create notification
        let notification = AlertNotification(
            id: UUID().uuidString,
            title: update.title,
            message: update.message,
            type: update.type,
            timestamp: update.timestamp,
            isRead: false,
            playerId: update.playerId,
            data: update.data
        )
        
        // Update notification history
        notificationHistory.insert(notification, at: 0)
        if notificationHistory.count > historyLimit {
            notificationHistory = Array(notificationHistory.prefix(historyLimit))
        }
        
        // Update unread count
        unreadCount += 1
        
        // Update latest notification
        latestNotification = notification
        
        // Save history
        saveHistory()
        
        // Update notification count
        defaults.set(todayCount + 1, forKey: notificationCountKey)
        
        // Show system notification if allowed
        let settings = await notificationCenter.notificationSettings()
        
        if settings.authorizationStatus == .authorized {
            // Create notification content
            let content = UNMutableNotificationContent()
            content.title = update.title
            content.body = update.message
            content.sound = .default
            
            // Add custom data if needed
            if let data = update.data {
                content.userInfo = data
            }
            
            // Create notification request
            let request = UNNotificationRequest(
                identifier: notification.id,
                content: content,
                trigger: nil // Show immediately
            )
            
            // Schedule notification
            try? await notificationCenter.add(request)
        }
        
        // Update app badge
        updateBadge()
    }
    
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(notificationHistory) {
            defaults.set(data, forKey: "notification_history")
        }
    }
    
    private func updateBadge() {
        Task { @MainActor in
            UIApplication.shared.applicationIconBadgeNumber = unreadCount
        }
    }
}

// MARK: - Note
// AlertNotification is defined in Models/Models.swift

// MARK: - Helper Extensions

extension AlertType {
    var icon: String {
        switch self {
        case .injury, .injuryUpdate:
            return "bandage.fill"
        case .selection:
            return "person.fill.checkmark"
        case .priceChange:
            return "dollarsign.circle.fill"
        case .milestone:
            return "star.fill"
        case .system:
            return "info.circle.fill"
        case .lateOut:
            return "clock.badge.exclamationmark.fill"
        case .roleChange:
            return "person.crop.circle.fill.badge.plus"
        case .breakingNews:
            return "newspaper.fill"
        case .tradeDeadline:
            return "calendar.badge.exclamationmark"
        case .captainReminder:
            return "crown.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .injury, .injuryUpdate:
            return Theme.Colors.error
        case .selection:
            return Theme.Colors.success
        case .priceChange:
            return Theme.Colors.accent
        case .milestone:
            return Theme.Colors.warning
        case .system:
            return Theme.Colors.textSecondary
        case .lateOut:
            return Theme.Colors.error
        case .roleChange:
            return Theme.Colors.accent
        case .breakingNews:
            return Theme.Colors.warning
        case .tradeDeadline:
            return Theme.Colors.error
        case .captainReminder:
            return Theme.Colors.accent
        }
    }
}

// MARK: - Notification Views

struct AlertToastView: View {
    let notification: AlertNotification
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.s) {
                // Icon
                Image(systemName: notification.type.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(notification.type.color)
                
                // Content
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(notification.title)
                        .font(Theme.Font.bodyBold)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text(notification.message)
                        .font(Theme.Font.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding()
            .background(Theme.Colors.background)
            .cornerRadius(Theme.Radius.medium)
            .shadow(color: notification.type.color.opacity(0.1), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct NotificationList: View {
    let notifications: [AlertNotification]
    let onMarkRead: (String) -> Void
    let onTap: (AlertNotification) -> Void
    
    var body: some View {
        LazyVStack(spacing: Theme.Spacing.s) {
            ForEach(notifications) { notification in
                NotificationRow(
                    notification: notification,
                    onMarkRead: { onMarkRead(notification.id) },
                    onTap: { onTap(notification) }
                )
            }
        }
    }
}

struct NotificationRow: View {
    let notification: AlertNotification
    let onMarkRead: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.s) {
                // Icon
                Image(systemName: notification.type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(notification.type.color)
                
                // Content
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(notification.title)
                        .font(Theme.Font.bodyBold)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text(notification.message)
                        .font(Theme.Font.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineLimit(2)
                    
                    Text(notification.timestamp.formatted(.relative(presentation: .named)))
                        .font(Theme.Font.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                // Read indicator
                if !notification.isRead {
                    Circle()
                        .fill(notification.type.color)
                        .frame(width: 8, height: 8)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
            .background(Theme.Colors.background)
            .cornerRadius(Theme.Radius.medium)
            .contentShape(Rectangle())
            .swipeActions(edge: .trailing) {
                Button(action: onMarkRead) {
                    Label("Mark as Read", systemImage: "checkmark.circle.fill")
                }
                .tint(Theme.Colors.success)
            }
        }
        .buttonStyle(.plain)
    }
}
