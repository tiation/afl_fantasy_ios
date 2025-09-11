import SwiftUI
import Combine

// MARK: - AlertsView

struct AlertsView: View {
    @EnvironmentObject var alertsViewModel: AlertsViewModel
    @State private var showingSettings = false
    @State private var presentingDetail: AlertNotification?

private var displayedAlerts: [AlertNotification] {
        return alertsViewModel.filteredAlerts
    }

    var body: some View {
        NavigationView {
            List {
                // Summary Section
                Section {
                    alertsSummarySection
                } header: {
                    Text("Overview")
                }
                
                // Filters
                Section {
                    filterChips
                } header: {
                    Text("Filter & Sort")
                }
                
                // Alerts List
                Section {
                    alertsList
                } header: {
                    Text("Alerts")
                }
            }
            .dsFloatingTabBarPadding()
            .navigationTitle("Smart Alerts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: { alertsViewModel.markAllAsRead() }) {
                            Label("Mark all as read", systemImage: "checkmark.circle")
                        }
                        Button(role: .destructive, action: { alertsViewModel.clearAllAlerts() }) {
                            Label("Clear history", systemImage: "trash")
                        }
                        
                        Divider()
                        
                        Button("💰 Price Alert") { alertsViewModel.simulateAlert() }
                        Button("🚨 Live WebSocket Alert") { alertsViewModel.simulateWebSocketAlert() }
                        Button("📊 Load Sample Data") { alertsViewModel.loadSampleData() }
                        Button("🧪 Connection Test") { alertsViewModel.simulateConnectionTest() }
                        
                        Divider()
                        
                        Button("🔄 Reconnect") {
                            alertsViewModel.reconnectWebSocket()
                        }
                        
                        Button("❌ Disconnect") {
                            alertsViewModel.disconnectWebSocket()
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
            }
            .refreshable {
                alertsViewModel.reconnectWebSocket()
            }
            .searchable(text: $alertsViewModel.searchText, prompt: "Search alerts")
        }
    }
    
    // MARK: - Summary Section
    
    private var alertsSummarySection: some View {
        VStack(spacing: DS.Spacing.m) {
            // Header with connection status
            DSGradientCard(gradient: LinearGradient(
                colors: [DS.Colors.primary, DS.Colors.primary.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )) {
                HStack(spacing: DS.Spacing.m) {
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text("Alert Center")
                            .font(DS.Typography.brandTitle)
                            .foregroundColor(.white)
                        
                        // Enhanced connection status
                        HStack(spacing: DS.Spacing.xs) {
                            Circle()
                                .fill(alertsViewModel.isConnected ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                                .scaleEffect(alertsViewModel.isConnected ? 1.0 : 1.2)
                                .animation(
                                    alertsViewModel.isConnected ? 
                                        Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true) :
                                        Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                    value: alertsViewModel.isConnected
                                )
                            
                            Text(alertsViewModel.isConnected ? "Live Updates" : alertsViewModel.connectionStatus.rawValue)
                                .font(DS.Typography.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    Spacer()
                    
                    // Last updated indicator
                    VStack(spacing: DS.Spacing.xs) {
                        Text("Last updated")
                            .font(DS.Typography.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(alertsViewModel.lastUpdated.formatted(.relative(presentation: .numeric)))
                            .font(DS.Typography.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            
            // Statistics cards
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.m), count: 3),
                spacing: DS.Spacing.m
            ) {
                DSStatCard(
                    title: "Unread",
                    value: "\(alertsViewModel.unreadCount)",
                    trend: alertsViewModel.unreadCount > 0 ? .up("New alerts") : nil,
                    icon: "bell.badge",
                    style: alertsViewModel.unreadCount > 0 ? .prominent : .minimal
                )
                
                DSStatCard(
                    title: "Total",
                    value: "\(alertsViewModel.alertStats.total)",
                    trend: nil,
                    icon: "bell",
                    style: .standard
                )
                
                DSStatCard(
                    title: "Critical",
                    value: "\(alertsViewModel.alertStats.critical)",
                    trend: alertsViewModel.alertStats.critical > 0 ? .down("Action needed") : .neutral,
                    icon: "exclamationmark.triangle",
                    style: alertsViewModel.alertStats.critical > 0 ? .gradient : .minimal
                )
            }
        }
    }

    // MARK: - Filters

    private var filterChips: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            Text("Filter & Sort")
                .font(DS.Typography.headline)
                .foregroundColor(DS.Colors.onSurface)
                .padding(.horizontal, DS.Spacing.m)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.s) {
                    // Filter chips using AlertsViewModel.AlertFilter
                    ForEach(AlertsViewModel.AlertFilter.allCases, id: \.self) { filter in
                        let count = alertsViewModel.filterCounts[filter] ?? 0
                        enhancedChip(
                            title: filter.displayName,
                            icon: filter.iconName,
                            count: count,
                            isSelected: alertsViewModel.selectedFilter == filter,
                            color: filter == .critical ? DS.Colors.error : 
                                   filter == .high ? DS.Colors.warning :
                                   filter == .unread ? DS.Colors.primary : DS.Colors.secondary
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                alertsViewModel.selectedFilter = filter
                            }
                        }
                    }

                    // Separator
                    Rectangle()
                        .fill(DS.Colors.outline)
                        .frame(width: 1, height: 24)
                        .padding(.horizontal, DS.Spacing.xs)

                    // Sort picker menu - simplified for now
                    enhancedChip(
                        title: "Latest",
                        icon: "arrow.up.arrow.down",
                        count: nil,
                        isSelected: false,
                        color: DS.Colors.secondary
                    ) {
                        // TODO: Implement sort options
                    }
                }
                .padding(.horizontal, DS.Spacing.m)
            }
        }
    }

    private func enhancedChip(
        title: String,
        icon: String,
        count: Int?,
        isSelected: Bool,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.xs) {
                Image(systemName: icon)
                    .font(.footnote)
                    .foregroundColor(isSelected ? .white : color)
                
                Text(title)
                    .font(DS.Typography.caption)
                    .fontWeight(isSelected ? .medium : .regular)
                
                if let count = count, count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.3) : color.opacity(0.1))
                        .foregroundColor(isSelected ? .white : color)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, DS.Spacing.m)
            .padding(.vertical, DS.Spacing.s)
            .background(
                Group {
                    if isSelected {
                        Capsule().fill(color)
                    } else {
                        Capsule()
                            .fill(color.opacity(0.08))
                            .overlay(
                                Capsule().stroke(color.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            )
            .foregroundColor(isSelected ? .white : color)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Alerts List

    private var alertsList: some View {
        LazyVStack(spacing: DS.Spacing.m) {
            if alertsViewModel.alerts.isEmpty {
                emptyStateView
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            } else if displayedAlerts.isEmpty {
                noMatchesView
                    .transition(.opacity.combined(with: .slide))
            } else {
                ForEach(Array(displayedAlerts.enumerated()), id: \.element.id) { index, alert in
                    AlertRowView(alert: alert)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                presentingDetail = alert
                                alertsViewModel.markAsRead(alert)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                withAnimation(.spring()) {
                                    alertsViewModel.markAsRead(alert)
                                }
                            } label: {
                                Label(alert.isRead ? "Mark unread" : "Mark read", 
                                      systemImage: alert.isRead ? "envelope.badge" : "checkmark.circle.fill")
                            }.tint(alert.isRead ? DS.Colors.warning : DS.Colors.success)
                            
                            Button(role: .destructive) {
                                withAnimation(.spring()) {
                                    alertsViewModel.deleteAlert(alert)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .transition(
                            .asymmetric(
                                insertion: .opacity.combined(with: .slide).animation(.spring().delay(Double(index) * 0.05)),
                                removal: .opacity.combined(with: .scale(scale: 0.8)).animation(.easeInOut)
                            )
                        )
                }
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: displayedAlerts.count)
    }
    
    // MARK: - No Matches View
    
    private var noMatchesView: some View {
        DSCard(style: .elevated) {
            VStack(spacing: DS.Spacing.l) {
                ZStack {
                    Circle()
                        .fill(DS.Colors.primary.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(DS.Colors.primary)
                }
                
                VStack(spacing: DS.Spacing.s) {
                    Text("No matching alerts")
                        .font(DS.Typography.title3)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    Text("Try adjusting your filters or search terms to find relevant alerts.")
                        .font(DS.Typography.body)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Quick action to clear filters
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        alertsViewModel.selectedFilter = .all
                        alertsViewModel.searchText = ""
                    }
                } label: {
                    HStack(spacing: DS.Spacing.xs) {
                        Image(systemName: "clear")
                            .font(.caption)
                        Text("Clear Filters")
                            .font(DS.Typography.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, DS.Spacing.m)
                    .padding(.vertical, DS.Spacing.s)
                    .background(DS.Colors.primary.opacity(0.1))
                    .foregroundColor(DS.Colors.primary)
                    .clipShape(Capsule())
                }
            }
            .padding(DS.Spacing.l)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: DS.Spacing.l) {
            // Hero empty state card
            DSGradientCard(gradient: LinearGradient(
                colors: [DS.Colors.success.opacity(0.8), DS.Colors.success.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )) {
                VStack(spacing: DS.Spacing.l) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "checkmark.shield")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(.white)
                    }

                    VStack(spacing: DS.Spacing.s) {
                        Text("All Clear!")
                            .font(DS.Typography.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Text("You're all caught up. New alerts and updates will appear here when available.")
                            .font(DS.Typography.body)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }
                }
                .padding(DS.Spacing.xl)
            }
            
            // Quick actions for empty state
            VStack(spacing: DS.Spacing.m) {
                Text("Get Started")
                    .font(DS.Typography.headline)
                    .foregroundColor(DS.Colors.onSurface)
                
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.m), count: 2),
                    spacing: DS.Spacing.m
                ) {
                    Button {
                        showingSettings = true
                    } label: {
                        DSCard(style: .elevated) {
                            VStack(spacing: DS.Spacing.s) {
                                Image(systemName: "gear")
                                    .font(.title2)
                                    .foregroundColor(DS.Colors.primary)
                                    .frame(width: 40, height: 40)
                                    .background(DS.Colors.primary.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Text("Settings")
                                    .font(DS.Typography.body)
                                    .foregroundColor(DS.Colors.onSurface)
                                    .fontWeight(.medium)
                                
                                Text("Configure alerts")
                                    .font(DS.Typography.caption)
                                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DS.Spacing.m)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        // Simulate some demo alerts
                        alertsViewModel.simulateAlert()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            alertsViewModel.simulateWebSocketAlert()
                        }
                    } label: {
                        DSCard(style: .elevated) {
                            VStack(spacing: DS.Spacing.s) {
                                Image(systemName: "play.circle")
                                    .font(.title2)
                                    .foregroundColor(DS.Colors.secondary)
                                    .frame(width: 40, height: 40)
                                    .background(DS.Colors.secondary.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Text("Demo")
                                    .font(DS.Typography.body)
                                    .foregroundColor(DS.Colors.onSurface)
                                    .fontWeight(.medium)
                                
                                Text("Try sample alerts")
                                    .font(DS.Typography.caption)
                                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DS.Spacing.m)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

// MARK: - AlertRowView

struct AlertRowView: View {
    let alert: AlertNotification
    @State private var isPressed = false
    
    @ViewBuilder
    private var cardStyleView: some View {
        switch alert.type.priority {
        case .critical:
            DSCard(style: .elevated) {
                alertRowContent
            }
        case .high:
            DSGradientCard(gradient: LinearGradient(
                colors: [DS.Colors.warning.opacity(0.8), DS.Colors.warning.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )) {
                alertRowContent
            }
        case .medium:
            DSCard(style: .bordered) {
                alertRowContent
            }
        case .low:
            DSCard(style: .standard) {
                alertRowContent
            }
        }
    }

    @ViewBuilder
    private var alertRowContent: some View {
        HStack(alignment: .top, spacing: DS.Spacing.m) {
                // Enhanced alert icon with priority ring
                ZStack {
                    if alert.type.priority == .critical || alert.type.priority == .high {
                        Circle()
                            .stroke(
                                alert.type.priority == .critical ? DS.Colors.error : DS.Colors.warning,
                                lineWidth: 2
                            )
                            .frame(width: 40, height: 40)
                    }
                    
                    Image(systemName: alert.type.systemImageName)
                        .font(.title2)
                        .foregroundColor(
                            alert.type.priority == .critical ? DS.Colors.error :
                            alert.type.priority == .high ? DS.Colors.warning :
                            DS.Colors.primary
                        )
                        .frame(width: 32, height: 32)
                        .background(
                            (alert.type.priority == .critical ? DS.Colors.error :
                             alert.type.priority == .high ? DS.Colors.warning :
                             DS.Colors.primary).opacity(0.1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    // Title with priority badges
                        HStack(alignment: .firstTextBaseline, spacing: DS.Spacing.s) {
                        Text(alert.title)
                            .font(DS.Typography.headline)
                            .foregroundColor(alert.type.priority == .high ? .white : DS.Colors.onSurface)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        // Enhanced priority indicators
                        HStack(spacing: DS.Spacing.xs) {
                            if alert.type.priority == .critical {
                                Text("CRITICAL")
                                    .font(DS.Typography.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(DS.Colors.error)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            } else if alert.type.priority == .high {
                                Text("HIGH")
                                    .font(DS.Typography.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(DS.Colors.warning)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    Text(alert.message)
                        .font(DS.Typography.body)
                        .foregroundColor(alert.type.priority == .high ? .white.opacity(0.9) : DS.Colors.onSurfaceSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    // Enhanced timestamp with relative time
                    HStack(spacing: DS.Spacing.xs) {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(alert.type.priority == .high ? .white.opacity(0.7) : DS.Colors.onSurfaceVariant)
                        
                        Text(alert.timestamp.formatted(.relative(presentation: .named)))
                            .font(DS.Typography.caption)
                            .foregroundColor(alert.type.priority == .high ? .white.opacity(0.8) : DS.Colors.onSurfaceVariant)
                        
                        Spacer()
                        
                        // Unread indicator with animation
                        if !alert.isRead {
                            HStack(spacing: DS.Spacing.xs) {
                                Circle()
                                    .fill(alert.type.priority == .high ? Color.white : DS.Colors.primary)
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(1.0)
                                    .animation(
                                        Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                        value: alert.isRead
                                    )
                                
                                Text("NEW")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(alert.type.priority == .high ? .white : DS.Colors.primary)
                            }
                        }
                    }
                }
        }
        .padding(alert.type.priority == .critical || alert.type.priority == .high ? DS.Spacing.m : DS.Spacing.s)
    }
    
    var body: some View {
        cardStyleView
            .opacity(alert.isRead ? 0.85 : 1.0)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .onLongPressGesture(minimumDuration: 0) {
                // Do nothing on actual press
            } onPressingChanged: { pressing in
                isPressed = pressing
            }
        .accessibilityLabel("\(alert.type.displayName): \(alert.title). \(alert.message). Priority: \(alert.type.priority.displayName)")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Duplicate AlertDetailView and AlertSettingsView removed
// These views are now in separate files:
// - AlertDetailView in Sources/Features/Alerts/AlertDetailView.swift
// - AlertSettingsView in Sources/Features/Alerts/AlertSettingsView.swift

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

// MARK: - ViewModel is now in AlertsViewModel.swift

// MARK: - Previews

#if DEBUG
struct AlertsView_Previews: PreviewProvider {
    static var previews: some View {
        AlertsView().environmentObject(AlertsViewModel())
    }
}
#endif
