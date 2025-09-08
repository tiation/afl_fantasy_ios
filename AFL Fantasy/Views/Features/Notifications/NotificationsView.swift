import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Theme.Colors.background
                    .ignoresSafeArea()
                
                // Content
                Group {
                    if viewModel.notifications.isEmpty {
                        // Empty State
                        VStack(spacing: Theme.Spacing.m) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 48))
                                .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
                            
                            Text("No Notifications")
                                .font(Theme.Font.title3)
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Text("Notifications about your team, price changes, and other important updates will appear here.")
                                .font(Theme.Font.body)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, Theme.Spacing.xl)
                        }
                    } else {
                        // Notifications List
                        ScrollView {
                            VStack(spacing: Theme.Spacing.l) {
                                // Filters
                                notificationFilters
                                
                                // Notifications
                                NotificationList(
                                    notifications: viewModel.filteredNotifications,
                                    onMarkRead: { id in
                                        viewModel.markAsRead(id)
                                    },
                                    onTap: { notification in
                                        viewModel.handleNotificationTap(notification)
                                    }
                                )
                            }
                            .padding()
                        }
                        .refreshable {
                            await viewModel.refresh()
                        }
                    }
                }
                .overlay(alignment: .center) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Leading: Close Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                }
                
                // Principal: Title
                ToolbarItem(placement: .principal) {
                    Text("Notifications")
                        .font(Theme.Font.title3)
                        .foregroundColor(Theme.Colors.textPrimary)
                }
                
                // Trailing: Actions
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: viewModel.markAllAsRead) {
                            Label("Mark All as Read", systemImage: "checkmark.circle.fill")
                        }
                        
                        if !viewModel.notifications.isEmpty {
                            Button(role: .destructive, action: viewModel.clearHistory) {
                                Label("Clear History", systemImage: "trash.fill")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(item: $viewModel.selectedNotification) { notification in
                NotificationDetailView(notification: notification)
            }
            .onAppear {
                viewModel.loadNotifications()
            }
        }
    }
    
    private var notificationFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.s) {
                // All Filter
                filterButton(
                    title: "All",
                    icon: "bell.fill",
                    isSelected: viewModel.selectedFilter == nil
                ) {
                    viewModel.selectedFilter = nil
                }
                
                // Type Filters
                ForEach(AlertUpdate.AlertType.allCases, id: \.self) { type in
                    filterButton(
                        title: filterTitle(for: type),
                        icon: type.icon,
                        isSelected: viewModel.selectedFilter == type
                    ) {
                        viewModel.selectedFilter = type
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func filterButton(
        title: String,
        icon: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                
                Text(title)
                    .font(Theme.Font.caption)
            }
            .foregroundColor(isSelected ? .white : Theme.Colors.textPrimary)
            .padding(.horizontal, Theme.Spacing.s)
            .padding(.vertical, Theme.Spacing.xs)
            .background(isSelected ? Theme.Colors.accent : Theme.Colors.background)
            .cornerRadius(Theme.Radius.full)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.full)
                    .stroke(
                        isSelected ? Theme.Colors.accent : Theme.Colors.textSecondary.opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
    }
    
    private func filterTitle(for type: AlertUpdate.AlertType) -> String {
        switch type {
        case .injury:
            return "Injuries"
        case .selection:
            return "Selection"
        case .priceChange:
            return "Prices"
        case .milestone:
            return "Milestones"
        case .system:
            return "System"
        }
    }
}

struct NotificationDetailView: View {
    let notification: AlertNotification
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Theme.Colors.background
                    .ignoresSafeArea()
                
                // Content
                ScrollView {
                    VStack(spacing: Theme.Spacing.l) {
                        // Icon
                        Image(systemName: notification.type.icon)
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundColor(notification.type.color)
                            .frame(width: 80, height: 80)
                            .background(notification.type.color.opacity(0.1))
                            .clipShape(Circle())
                        
                        // Title
                        Text(notification.title)
                            .font(Theme.Font.title2)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        // Message
                        Text(notification.message)
                            .font(Theme.Font.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        // Timestamp
                        Text(notification.timestamp.formatted(.dateTime))
                            .font(Theme.Font.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .padding(.top, Theme.Spacing.s)
                        
                        // Additional Data (if any)
                        if let data = notification.data, !data.isEmpty {
                            VStack(spacing: Theme.Spacing.s) {
                                ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                    HStack {
                                        Text(key.capitalized)
                                            .font(Theme.Font.caption)
                                            .foregroundColor(Theme.Colors.textSecondary)
                                        
                                        Spacer()
                                        
                                        Text(value)
                                            .font(Theme.Font.bodyBold)
                                            .foregroundColor(Theme.Colors.textPrimary)
                                    }
                                    .padding()
                                    .background(Theme.Colors.background)
                                    .cornerRadius(Theme.Radius.medium)
                                }
                            }
                            .padding(.top, Theme.Spacing.m)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: dismiss.callAsFunction) {
                        Image(systemName: "xmark")
                            .font(.title2)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct NotificationsView_Previews: PreviewProvider {
    static var sampleNotifications: [AlertNotification] {
        [
            .init(
                id: "1",
                type: .injury,
                title: "Marcus Bontempelli Injured",
                message: "Bontempelli (knee) is expected to miss 1-2 weeks. Consider trading or benching.",
                timestamp: Date(),
                data: ["status": "Test", "return": "Round 15"],
                isRead: false
            ),
            .init(
                id: "2",
                type: .priceChange,
                title: "Price Drop Alert",
                message: "Nick Daicos has dropped $32k in value. Current price: $878k",
                timestamp: Date().addingTimeInterval(-3600),
                data: ["magnitude": "-32000", "reason": "Poor form"],
                isRead: true
            ),
            .init(
                id: "3",
                type: .selection,
                title: "Team Selection Update",
                message: "Sam Walsh named in extended squad for Round 14",
                timestamp: Date().addingTimeInterval(-7200),
                data: ["status": "Extended Squad"],
                isRead: false
            )
        ]
    }
    
    static var previews: some View {
        NotificationsView()
            .previewDisplayName("Empty State")
        
        NotificationsView()
            .previewDisplayName("With Notifications")
            .environmentObject(NotificationsViewModel(initialNotifications: sampleNotifications))
        
        NotificationDetailView(notification: sampleNotifications[0])
            .previewDisplayName("Detail View")
    }
}
