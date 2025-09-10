import SwiftUI
import Combine

// MARK: - AlertsView

struct AlertsView: View {
    @EnvironmentObject var alertsViewModel: AlertsViewModel
    @State private var showingSettings = false

    // Premium UX state
    @State private var searchText = ""
    @State private var selectedType: AlertType? = nil
    @State private var showOnlyUnread = false
    @State private var sortNewestFirst = true
    @State private var presentingDetail: AlertNotification? = nil

    private var displayedAlerts: [AlertNotification] {
        var list = alertsViewModel.alerts
        if showOnlyUnread { list = list.filter { !$0.isRead } }
        if let type = selectedType { list = list.filter { $0.type == type } }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            list = list.filter { $0.title.lowercased().contains(q) || $0.message.lowercased().contains(q) }
        }
        return list.sorted { sortNewestFirst ? $0.timestamp > $1.timestamp : $0.timestamp < $1.timestamp }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: DS.Spacing.l) {
                    // Summary Section
                    alertsSummarySection

                    // Filters
                    filterChips

                    // Alerts List
                    alertsList
                }
                .padding(.horizontal, DS.Spacing.l)
            }
            .navigationTitle("Smart Alerts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: { alertsViewModel.markAllAsRead() }) {
                            Label("Mark all as read", systemImage: "checkmark.circle")
                        }
                        Button(role: .destructive, action: { alertsViewModel.clearAll() }) {
                            Label("Clear history", systemImage: "trash")
                        }
                        
                        Divider()
                        
                        Menu("Demo Alerts") {
                            Button("💰 Price Alert") { alertsViewModel.simulateAlert(.priceChange) }
                            Button("🚨 Injury Alert") { alertsViewModel.simulateAlert(.injury) }
                            Button("🤖 AI Recommendation") { alertsViewModel.simulateAlert(.aiRecommendation) }
                            Button("📰 Breaking News") { alertsViewModel.simulateAlert(.breakingNews) }
                            Button("⏰ Trade Deadline") { alertsViewModel.simulateAlert(.tradeDeadline) }
                        }
                        
                        Menu("Connection") {
                            Button(alertsViewModel.isConnectedToServer ? "🟢 Connected" : "🔴 Disconnected") {
                                // Status display only
                            }
                            .disabled(true)
                            
                            Button("🔄 Reconnect") {
                                alertsViewModel.reconnectWebSocket()
                            }
                            
                            Button("🔌 Test Connection") {
                                alertsViewModel.testWebSocketConnection()
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
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
            .sheet(item: $presentingDetail) { alert in
                AlertDetailView(alert: alert)
                    .presentationDetents([.medium, .large])
            }
            .refreshable {
                alertsViewModel.refresh()
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search alerts")
        }
        .onAppear {
            // Do not auto-mark read on appear; respect user's intent
        }
    }

    // MARK: - Summary Section

    private var alertsSummarySection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Alert Center")
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.Colors.onSurface)
                        
                        // Connection status
                        HStack(spacing: DS.Spacing.xs) {
                            Circle()
                                .fill(alertsViewModel.isConnectedToServer ? DS.Colors.success : DS.Colors.error)
                                .frame(width: 6, height: 6)
                            Text(alertsViewModel.isConnectedToServer ? "Live" : "Offline")
                                .font(DS.Typography.caption)
                                .foregroundColor(DS.Colors.onSurfaceSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Toggle unread filter
                    Toggle(isOn: $showOnlyUnread) {
                        Text("Unread only").font(DS.Typography.caption)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: DS.Colors.primary))
                    .accessibilityLabel("Show unread only")
                }

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

    // MARK: - Filters

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.s) {
                chip(title: "All", icon: "bell", isSelected: selectedType == nil) {
                    selectedType = nil
                }
                ForEach(AlertType.allCases, id: \.self) { type in
                    chip(title: type.displayName, icon: type.systemImageName, isSelected: selectedType == type) {
                        selectedType = type
                    }
                }

                Divider().frame(height: 20)

                chip(title: sortNewestFirst ? "Newest" : "Oldest", icon: sortNewestFirst ? "arrow.down" : "arrow.up", isSelected: true) {
                    sortNewestFirst.toggle()
                }
            }
            .padding(.horizontal, DS.Spacing.xs)
        }
    }

    private func chip(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.xs) {
                Image(systemName: icon).font(.footnote)
                Text(title).font(DS.Typography.caption)
            }
            .padding(.horizontal, DS.Spacing.m)
            .padding(.vertical, DS.Spacing.xs)
            .background(isSelected ? DS.Colors.primary : DS.Colors.surface)
            .foregroundColor(isSelected ? DS.Colors.onPrimary : DS.Colors.onSurface)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(isSelected ? DS.Colors.primary : DS.Colors.outline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Alerts List

    private var alertsList: some View {
        LazyVStack(spacing: DS.Spacing.m) {
            if alertsViewModel.alerts.isEmpty {
                emptyStateView
            } else if displayedAlerts.isEmpty {
                DSCard {
                    VStack(spacing: DS.Spacing.m) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundColor(DS.Colors.onSurfaceVariant)
                        Text("No matches")
                            .font(DS.Typography.title3)
                        Text("Try changing filters or search term.")
                            .font(DS.Typography.body)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }
                    .padding(DS.Spacing.l)
                }
            } else {
                ForEach(displayedAlerts) { alert in
                    AlertRowView(alert: alert)
                        .onTapGesture {
                            presentingDetail = alert
                            alertsViewModel.markAsRead(alert)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if alert.isRead {
                                Button {
                                    alertsViewModel.markAsUnread(alert)
                                } label: {
                                    Label("Mark unread", systemImage: "envelope.badge")
                                }.tint(DS.Colors.warning)
                            } else {
                                Button {
                                    alertsViewModel.markAsRead(alert)
                                } label: {
                                    Label("Mark read", systemImage: "checkmark.circle.fill")
                                }.tint(DS.Colors.success)
                            }
                            Button(role: .destructive) {
                                alertsViewModel.delete(alert)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
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
            HStack(alignment: .top, spacing: DS.Spacing.m) {
                // Alert icon
                Image(systemName: alert.type.systemImageName)
                    .font(.title2)
                    .foregroundColor(alert.type.color)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: DS.Spacing.s) {
                        Text(alert.title)
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.Colors.onSurface)
                            .lineLimit(2)
                        if alert.type == .injury || alert.type == .lateOut {
                            Text("CRITICAL")
                                .font(DS.Typography.overline)
                                .foregroundColor(DS.Colors.onPrimary)
                                .padding(.horizontal, DS.Spacing.xs)
                                .padding(.vertical, 2)
                                .background(DS.Colors.error)
                                .clipShape(Capsule())
                                .accessibilityLabel("Critical")
                        }
                    }

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
                        .accessibilityLabel("Unread")
                }
            }
        }
        .opacity(alert.isRead ? 0.75 : 1.0)
        .dsAccessibility(
            label: "\(alert.type.displayName): \(alert.title). \(alert.message)",
            traits: .isButton
        )
    }
}

// MARK: - Alert Detail

struct AlertDetailView: View {
    let alert: AlertNotification

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DS.Spacing.l) {
                    // Icon header
                    VStack(spacing: DS.Spacing.s) {
                        Image(systemName: alert.type.systemImageName)
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(alert.type.color)
                            .padding(DS.Spacing.s)
                            .background(alert.type.color.opacity(0.12))
                            .clipShape(Circle())

                        Text(alert.title)
                            .font(DS.Typography.title2)
                            .multilineTextAlignment(.center)

                        Text(alert.timestamp.formatted(.dateTime))
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }

                    DSCard {
                        VStack(alignment: .leading, spacing: DS.Spacing.m) {
                            Text("Details").font(DS.Typography.title3)
                            Text(alert.message).font(DS.Typography.body)
                        }
                    }

                    // Contextual actions (placeholders)
                    if alert.type == .priceChange || alert.type == .tradeDeadline || alert.type == .captainReminder {
                        DSCard {
                            VStack(alignment: .leading, spacing: DS.Spacing.s) {
                                Text("Quick Actions").font(DS.Typography.title3)
                                HStack(spacing: DS.Spacing.s) {
                                    actionButton(title: "Open Trades", icon: "arrow.left.arrow.right")
                                    actionButton(title: "Watchlist", icon: "eye")
                                }
                            }
                        }
                    }
                }
                .padding(DS.Spacing.l)
            }
            .navigationTitle("Alert")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func actionButton(title: String, icon: String) -> some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(DS.Typography.body)
            .padding()
            .background(DS.Colors.surface)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(DS.Colors.outline, lineWidth: 1))
            .cornerRadius(12)
        }
    }
}


// MARK: - AlertSettingsView

struct AlertSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var alertsViewModel: AlertsViewModel
    @State private var settings = AlertSettings.default
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Notifications
                Section("Essential Alerts") {
                    Toggle("Price Changes", isOn: $settings.priceChanges)
                    Toggle("Injury Updates", isOn: $settings.injuries)
                    Toggle("Trade Deadlines", isOn: $settings.tradeDeadlines)
                    Toggle("Captain Reminders", isOn: $settings.captainReminders)
                }
                
                // Premium Features
                Section("Premium Alerts") {
                    Toggle("Breaking News", isOn: $settings.breakingNews)
                    Toggle("AI Recommendations", isOn: $settings.aiRecommendations)
                    Toggle("Form & Performance", isOn: $settings.formAlerts)
                    Toggle("Price Targets", isOn: $settings.priceThresholds)
                    Toggle("Milestone Achievements", isOn: $settings.milestones)
                    Toggle("Fixture Changes", isOn: $settings.fixtureChanges)
                }
                
                // Customization
                Section("Customization") {
                    HStack {
                        Text("Minimum Priority")
                        Spacer()
                        Picker("Priority", selection: $settings.minimumPriority) {
                            ForEach(AlertPriority.allCases, id: \.self) { priority in
                                Text(priority.displayName).tag(priority)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    HStack {
                        Text("Price Alert Threshold")
                        Spacer()
                        Text("$\(Int(settings.priceChangeThreshold / 1000))k")
                    }
                    Slider(value: $settings.priceChangeThreshold, in: 5000...50000, step: 5000)
                    
                    Stepper("Max daily alerts: \(settings.maxAlertsPerDay)", value: $settings.maxAlertsPerDay, in: 5...50)
                }
                
                // Delivery
                Section("Delivery") {
                    Toggle("Push Notifications", isOn: $settings.pushNotifications)
                    Toggle("In-App Alerts", isOn: $settings.inAppAlerts)
                    Toggle("Email Digest", isOn: $settings.emailDigest)
                }
                
                // Quiet Hours
                Section("Quiet Hours") {
                    Toggle("Enable Quiet Hours", isOn: $settings.enableQuietHours)
                    if settings.enableQuietHours {
                        DatePicker("Start", selection: $settings.quietHoursStart, displayedComponents: .hourAndMinute)
                        DatePicker("End", selection: $settings.quietHoursEnd, displayedComponents: .hourAndMinute)
                    }
                }
                
                // Advanced
                Section("Advanced") {
                    NavigationLink("Custom Alert Rules") {
                        CustomAlertRulesView()
                    }
                    NavigationLink("Watchlist Integration") {
                        WatchlistAlertsView()
                    }
                }
            }
            .navigationTitle("Alert Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        alertsViewModel.updateSettings(settings)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            settings = alertsViewModel.getCurrentSettings()
        }
    }
}

// MARK: - Custom Alert Rules

struct CustomAlertRulesView: View {
    @State private var rules: [CustomAlertRule] = []
    
    var body: some View {
        List {
            Section("Active Rules") {
                ForEach(rules) { rule in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rule.name)
                            .font(DS.Typography.headline)
                        Text(rule.description)
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }
                }
                .onDelete(perform: deleteRule)
            }
            
            Section {
                Button("+ Add Custom Rule") {
                    // TODO: Present rule creation flow
                }
            }
        }
        .navigationTitle("Custom Rules")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func deleteRule(at offsets: IndexSet) {
        rules.remove(atOffsets: offsets)
    }
}

// MARK: - Watchlist Integration

struct WatchlistAlertsView: View {
    var body: some View {
        Form {
            Section("Watchlist Alerts") {
                Toggle("Price movements on watchlist players", isOn: .constant(true))
                Toggle("Injury updates for watchlist players", isOn: .constant(true))
                Toggle("Form changes for watchlist players", isOn: .constant(false))
            }
            
            Section("Smart Suggestions") {
                Toggle("Suggest removing underperformers", isOn: .constant(true))
                Toggle("Suggest adding trending players", isOn: .constant(false))
            }
        }
        .navigationTitle("Watchlist Alerts")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Supporting Models

struct CustomAlertRule: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let conditions: [AlertCondition]
    let isActive: Bool
    
    init(name: String, description: String, conditions: [AlertCondition], isActive: Bool) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.conditions = conditions
        self.isActive = isActive
    }
}

struct AlertCondition: Codable {
    let type: ConditionType
    let comparisonOperator: ComparisonOperator
    let value: String
    
    enum ConditionType: String, Codable, CaseIterable {
        case price, average, ownership, form
        
        var displayName: String {
            switch self {
            case .price: "Price"
            case .average: "Average"
            case .ownership: "Ownership %"
            case .form: "Form Rating"
            }
        }
    }
    
    enum ComparisonOperator: String, Codable, CaseIterable {
        case greaterThan, lessThan, equals, between
        
        var displayName: String {
            switch self {
            case .greaterThan: "Greater than"
            case .lessThan: "Less than"
            case .equals: "Equals"
            case .between: "Between"
            }
        }
    }
}

// MARK: - ViewModel

@MainActor
final class AlertsViewModel: ObservableObject {
    @Published var alerts: [AlertNotification] = []
    
    // Temporarily disabled AlertManager integration for build
    // private let alertManager: AlertManager
    private var cancellables = Set<AnyCancellable>()

    var unreadCount: Int { alerts.filter { !$0.isRead }.count }
    var criticalCount: Int { alerts.filter { $0.type == .injury || $0.type == .lateOut }.count }
    var isConnectedToServer: Bool { false } // { alertManager.isConnectedToServer }

    init(/* alertManager: AlertManager = AlertManager() */) {
        // self.alertManager = alertManager
        // setupSubscriptions()
        // loadAlertsFromManager()
        
        // Load initial mock data if no alerts exist
        if alerts.isEmpty {
            loadMockAlerts()
        }
    }
    
    // MARK: - Private Setup
    
    private func setupSubscriptions() {
        // Temporarily disabled AlertManager subscriptions for build
        // No-op
    }
    
    private func loadAlertsFromManager() {
        // Temporarily disabled AlertManager access for build
        // No-op
    }

    // MARK: - Public Methods

    func markAsRead(_ alert: AlertNotification) {
        // alertManager.markAsRead(alert)
        // Temporary mock implementation
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index].isRead = true
        }
    }

    func markAsUnread(_ alert: AlertNotification) {
        // alertManager.markAsUnread(alert)
        // Temporary mock implementation
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index].isRead = false
        }
    }

    func delete(_ alert: AlertNotification) {
        // alertManager.delete(alert)
        // Temporary mock implementation
        alerts.removeAll { $0.id == alert.id }
    }

    func clearAll() {
        // alertManager.clearHistory()
        // Temporary mock implementation
        alerts.removeAll()
    }

    func markAllAsRead() {
        // alertManager.markAllAsRead()
        // Temporary mock implementation
        for index in alerts.indices {
            alerts[index].isRead = true
        }
    }

    func refresh() {
        // In a real app, this would trigger a network refresh
        // For now, simulate some new alerts
        simulateNewAlerts()
    }
    
    // MARK: - Settings Integration
    
    func updateSettings(_ settings: AlertSettings) {
        // alertManager.updateSettings(settings)
        // Temporary mock implementation - settings would be stored locally
    }
    
    func getCurrentSettings() -> AlertSettings {
        // return alertManager.getSettings()
        // Temporary mock implementation
        return AlertSettings.default
    }
    
    // MARK: - Demo/Testing Methods
    
    func simulateAlert(_ type: AlertType) {
        // alertManager.simulateAlert(type)
        // Temporary mock implementation - create a new alert
        let alert = generateMockAlert(for: type)
        alerts.insert(alert, at: 0)
    }
    
    func reconnectWebSocket() {
        // alertManager.reconnectWebSocket()
        // Temporary mock - no-op
    }
    
    func testWebSocketConnection() {
        // alertManager.testWebSocketConnection()
        // Temporary mock - simulate a test alert
        simulateAlert(.system)
    }
    
    private func simulateNewAlerts() {
        // Simulate 1-2 new alerts for demo
        let alertTypes: [AlertType] = [.priceChange, .injury, .aiRecommendation, .breakingNews]
        let randomType = alertTypes.randomElement() ?? .priceChange
        let alert = generateMockAlert(for: randomType)
        alerts.insert(alert, at: 0)
        
        // Occasionally add a second alert
        if Bool.random() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let secondType = alertTypes.randomElement() ?? .formAlert
                let secondAlert = self.generateMockAlert(for: secondType)
                self.alerts.insert(secondAlert, at: 0)
            }
        }
    }
    
    private func generateMockAlert(for type: AlertType) -> AlertNotification {
        switch type {
        case .priceChange:
            return AlertNotification(
                title: "Price Rise",
                message: "Sample Player increased by $12,000",
                type: .priceChange,
                timestamp: Date(),
                isRead: false,
                playerId: "mock"
            )
        case .injury:
            return AlertNotification(
                title: "Injury Update",
                message: "Sample Player is a test for the weekend",
                type: .injury,
                timestamp: Date(),
                isRead: false,
                playerId: "mock"
            )
        case .aiRecommendation:
            return AlertNotification(
                title: "AI Recommendation",
                message: "Consider trading in Sample Player (confidence: 85%)",
                type: .aiRecommendation,
                timestamp: Date(),
                isRead: false,
                playerId: "mock"
            )
        case .breakingNews:
            return AlertNotification(
                title: "Breaking News",
                message: "Fixture updated for this weekend",
                type: .breakingNews,
                timestamp: Date(),
                isRead: false,
                playerId: nil
            )
        default:
            return AlertNotification(
                title: "System",
                message: "Test alert",
                type: .system,
                timestamp: Date(),
                isRead: false,
                playerId: nil
            )
        }
    }

    // TODO: Wire to real API/WebSocket later
    private func loadMockAlerts() {
        alerts = [
            // Critical alerts
            AlertNotification(
                title: "Late Withdrawal",
                message: "Marcus Bontempelli has been ruled out with hamstring tightness. Consider emergency trade options.",
                type: .lateOut,
                timestamp: Date().addingTimeInterval(-900), // 15 min ago
                isRead: false,
                playerId: "1"
            ),
            AlertNotification(
                title: "Injury Update - Season Ending",
                message: "Max Gawn diagnosed with ACL injury. Expected to miss remainder of season.",
                type: .injury,
                timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
                isRead: false,
                playerId: "2"
            ),
            
            // High priority alerts
            AlertNotification(
                title: "Trade Deadline Warning",
                message: "Round 15 trades lock in 2 hours. You have 2 trades remaining.",
                type: .tradeDeadline,
                timestamp: Date().addingTimeInterval(-1800), // 30 min ago
                isRead: false,
                playerId: nil
            ),
            AlertNotification(
                title: "Breaking: Fixture Change",
                message: "Richmond vs Carlton moved to Sunday 2:10pm due to weather concerns.",
                type: .fixtureChange,
                timestamp: Date().addingTimeInterval(-2700), // 45 min ago
                isRead: true,
                playerId: nil
            ),
            
            // Medium priority alerts  
            AlertNotification(
                title: "Price Target Hit",
                message: "Christian Petracca has reached your target price of $580k. Consider adding to watchlist.",
                type: .priceThreshold,
                timestamp: Date().addingTimeInterval(-5400), // 1.5 hours ago
                isRead: false,
                playerId: "3"
            ),
            AlertNotification(
                title: "AI Recommendation",
                message: "Based on recent form and upcoming fixtures, consider trading in Lachie Neale (confidence: 87%).",
                type: .aiRecommendation,
                timestamp: Date().addingTimeInterval(-7200), // 2 hours ago
                isRead: false,
                playerId: "4"
            ),
            AlertNotification(
                title: "Form Alert",
                message: "Sam Walsh has scored below 80 in 3 consecutive games. Monitor closely.",
                type: .formAlert,
                timestamp: Date().addingTimeInterval(-10800), // 3 hours ago
                isRead: true,
                playerId: "5"
            ),
            
            // Low priority alerts
            AlertNotification(
                title: "Milestone Reached",
                message: "Congratulations! You've reached 100 trades for the season.",
                type: .milestoneReached,
                timestamp: Date().addingTimeInterval(-14400), // 4 hours ago
                isRead: true,
                playerId: nil
            ),
            AlertNotification(
                title: "Captain Reminder",
                message: "Don't forget to set your captain before lockout tomorrow.",
                type: .captainReminder,
                timestamp: Date().addingTimeInterval(-86400), // 1 day ago
                isRead: true,
                playerId: nil
            )
        ]
    }
}

// MARK: - Type Colors (DS mapping)

extension AlertType {
    var color: Color {
        switch self {
        case .priceChange: DS.Colors.primary
        case .injury: DS.Colors.error
        case .lateOut: DS.Colors.error
        case .roleChange: DS.Colors.info
        case .tradeDeadline: DS.Colors.warning
        case .captainReminder: DS.Colors.success
        case .system: DS.Colors.neutral
        
        // Premium alert types
        case .breakingNews: DS.Colors.warning
        case .milestoneReached: DS.Colors.success
        case .priceThreshold: DS.Colors.primary
        case .formAlert: DS.Colors.info
        case .fixtureChange: DS.Colors.warning
        case .aiRecommendation: DS.Colors.primary
        }
    }
}

// MARK: - Previews

#if DEBUG
struct AlertsView_Previews: PreviewProvider {
    static var previews: some View {
        AlertsView().environmentObject(AlertsViewModel())
    }
}
#endif
