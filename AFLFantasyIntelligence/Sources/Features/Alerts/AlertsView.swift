import SwiftUI

// MARK: - AlertsView

struct AlertsView: View {
    @EnvironmentObject var alertsViewModel: AlertsViewModel
    @State private var showingSettings = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: DS.Spacing.l) {
                    // Summary Section
                    alertsSummarySection

                    // Alerts List
                    alertsList
                }
                .padding(.horizontal, DS.Spacing.l)
            }
            .navigationTitle("Smart Alerts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                AlertSettingsView()
                    .presentationDetents([.medium, .large])
            }
            .refreshable {
                alertsViewModel.refresh()
            }
        }
        .onAppear {
            alertsViewModel.markAllAsRead()
        }
    }

    // MARK: - Summary Section

    private var alertsSummarySection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                Text("Alert Center")
                    .font(DS.Typography.headline)
                    .foregroundColor(DS.Colors.onSurface)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: DS.Spacing.m) {
                    VStack {
                        Text("\(alertsViewModel.unreadCount)")
                            .font(DS.Typography.statNumber)
                            .foregroundColor(DS.Colors.error)
                        Text("New")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }

                    VStack {
                        Text("\(alertsViewModel.alerts.count)")
                            .font(DS.Typography.statNumber)
                            .foregroundColor(DS.Colors.primary)
                        Text("Total")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }

                    VStack {
                        Text("\(alertsViewModel.criticalCount)")
                            .font(DS.Typography.statNumber)
                            .foregroundColor(DS.Colors.warning)
                        Text("Critical")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Alerts List

    private var alertsList: some View {
        LazyVStack(spacing: DS.Spacing.m) {
            if alertsViewModel.alerts.isEmpty {
                emptyStateView
            } else {
                ForEach(alertsViewModel.alerts) { alert in
                    AlertRowView(alert: alert)
                        .onTapGesture {
                            alertsViewModel.markAsRead(alert)
                        }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        DSCard {
            VStack(spacing: DS.Spacing.l) {
                Image(systemName: "bell.slash")
                    .font(.system(size: 48))
                    .foregroundColor(DS.Colors.onSurfaceVariant)

                Text("No Alerts")
                    .font(DS.Typography.title3)
                    .foregroundColor(DS.Colors.onSurface)

                Text("You're all caught up! New alerts will appear here.")
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(DS.Spacing.l)
        }
    }
}

// MARK: - AlertRowView

struct AlertRowView: View {
    let alert: AlertNotification

    var body: some View {
        DSCard {
            HStack(spacing: DS.Spacing.m) {
                // Alert icon
                Image(systemName: alert.type.systemImageName)
                    .font(.title2)
                    .foregroundColor(alert.type.color)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(alert.title)
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.onSurface)

                    Text(alert.message)
                        .font(DS.Typography.body)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                        .lineLimit(3)

                    Text(alert.timestamp.formatted(.relative(presentation: .named)))
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceVariant)
                }

                Spacer()

                if !alert.isRead {
                    Circle()
                        .fill(DS.Colors.primary)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .opacity(alert.isRead ? 0.7 : 1.0)
        .dsAccessibility(
            label: "\(alert.type.displayName): \(alert.title). \(alert.message)",
            traits: .isButton
        )
    }
}

// MARK: - AlertSettingsView

struct AlertSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var settings = AlertSettings.default

    var body: some View {
        NavigationView {
            Form {
                Section("Notification Types") {
                    Toggle("Price Changes", isOn: $settings.priceChanges)
                    Toggle("Injury Updates", isOn: $settings.injuries)
                    Toggle("Trade Deadlines", isOn: $settings.tradeDeadlines)
                    Toggle("Captain Reminders", isOn: $settings.captainReminders)
                }

                Section("Delivery") {
                    Toggle("Push Notifications", isOn: $settings.pushNotifications)
                    Toggle("In-App Alerts", isOn: $settings.inAppAlerts)
                }
            }
            .navigationTitle("Alert Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // TODO: Save settings
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - AlertSettings

struct AlertSettings {
    var priceChanges = true
    var injuries = true
    var tradeDeadlines = true
    var captainReminders = true
    var pushNotifications = true
    var inAppAlerts = true

    static let `default` = AlertSettings()
}

// MARK: - AlertsViewModel

@MainActor
final class AlertsViewModel: ObservableObject {
    @Published var alerts: [AlertNotification] = []

    var unreadCount: Int {
        alerts.filter { !$0.isRead }.count
    }

    var criticalCount: Int {
        alerts.filter { $0.type == .injury || $0.type == .lateOut }.count
    }

    init() {
        loadMockAlerts()
    }

    func markAsRead(_ alert: AlertNotification) {
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index].isRead = true
        }
    }

    func markAllAsRead() {
        for index in alerts.indices {
            alerts[index].isRead = true
        }
    }

    func refresh() {
        // TODO: Fetch real alerts from API
        loadMockAlerts()
    }

    private func loadMockAlerts() {
        alerts = [
            AlertNotification(
                title: "Price Rise Alert",
                message: "Marcus Bontempelli has increased by $15,000",
                type: .priceChange,
                timestamp: Date().addingTimeInterval(-3600),
                isRead: false,
                playerId: "1"
            ),
            AlertNotification(
                title: "Injury Update",
                message: "Max Gawn listed as a test for this weekend",
                type: .injury,
                timestamp: Date().addingTimeInterval(-7200),
                isRead: false,
                playerId: "2"
            ),
            AlertNotification(
                title: "Trade Deadline Reminder",
                message: "Round 15 trades lock in 2 hours",
                type: .tradeDeadline,
                timestamp: Date().addingTimeInterval(-1800),
                isRead: true,
                playerId: nil
            )
        ]
    }
}

// MARK: - Extensions

extension AlertType {
    var color: Color {
        switch self {
        case .priceChange:
            DS.Colors.primary
        case .injury:
            DS.Colors.error
        case .lateOut:
            DS.Colors.warning
        case .roleChange:
            DS.Colors.info
        case .tradeDeadline:
            DS.Colors.warning
        case .captainReminder:
            DS.Colors.success
        case .system:
            DS.Colors.neutral
        }
    }
}

// MARK: - Previews

#if DEBUG
    struct AlertsView_Previews: PreviewProvider {
        static var previews: some View {
            AlertsView()
                .environmentObject(AlertsViewModel())
        }
    }
#endif
