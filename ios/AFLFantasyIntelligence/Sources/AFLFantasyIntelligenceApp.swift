import SwiftUI
import UserNotifications

// MARK: - AFLFantasyIntelligenceApp

@main
struct AFLFantasyIntelligenceApp: App {
    // MARK: - Dependencies

    @StateObject private var authService = AuthenticationService()
    @StateObject private var apiService = APIService()
    @StateObject private var alertsViewModel = AlertsViewModel()
    @StateObject private var teamManager = TeamManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    ContentView()
                        .environmentObject(apiService)
                        .environmentObject(alertsViewModel)
                        .environmentObject(teamManager)
                } else {
                    LoginView()
                }
            }
            .environmentObject(authService)
            .preferredColorScheme(nil) // Respect system setting
            .onAppear {
                setupApp()
            }
        }
    }

    private func setupApp() {
        // Configure appearance
        configureAppearance()

        // Request notifications permission
        requestNotificationPermission()

        // Start background refresh
        Task {
            await apiService.checkHealth()
        }
    }

    private func configureAppearance() {
        // Configure navigation appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        navAppearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 32, weight: .bold)
        ]

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        // Configure tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("📱 Notification permission granted")
            } else if let error {
                print("❌ Notification permission denied: \(error)")
            }
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    @EnvironmentObject var apiService: APIService
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var teamManager: TeamManager
    @State private var selectedTab = 0
    @State private var previousTab = 0
    @State private var isTabChanging = false

    var body: some View {
        ZStack {
            // Main tab content with enhanced animations
            TabView(selection: $selectedTab) {
                DashboardView(selectedTab: $selectedTab)
                    .dsTabContent(selectedTab: selectedTab, tabIndex: 0)
                    .tabItem { EmptyView() }
                    .tag(0)

                PlayersView()
                    .dsTabContent(selectedTab: selectedTab, tabIndex: 1)
                    .tabItem { EmptyView() }
                    .tag(1)
                
                TeamsView()
                    .dsTabContent(selectedTab: selectedTab, tabIndex: 2)
                    .tabItem { EmptyView() }
                    .tag(2)

                AIToolsView()
                    .dsTabContent(selectedTab: selectedTab, tabIndex: 3)
                    .tabItem { EmptyView() }
                    .tag(3)

                AlertsView()
                    .dsTabContent(selectedTab: selectedTab, tabIndex: 4)
                    .tabItem { EmptyView() }
                    .tag(4)
                
                ProfileView()
                    .dsTabContent(selectedTab: selectedTab, tabIndex: 5)
                    .tabItem { EmptyView() }
                    .tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(.all, edges: .bottom)
            .disabled(isTabChanging) // Prevent interaction during transition
            
            // Enhanced floating tab bar with premium effects
            VStack {
                Spacer()
                
                EnhancedFloatingTabBar(
                    selectedTab: $selectedTab,
                    previousTab: previousTab,
                    tabs: [
                        TabItem(
                            id: 0,
                            title: "Dashboard",
                            icon: "chart.line.uptrend.xyaxis",
                            activeIcon: "chart.line.uptrend.xyaxis",
                            color: DS.Colors.primary
                        ),
                        TabItem(
                            id: 1,
                            title: "Players",
                            icon: "person.3",
                            activeIcon: "person.3.fill",
                            color: DS.Colors.secondary
                        ),
                        TabItem(
                            id: 2,
                            title: "Teams",
                            icon: "person.2.badge.plus",
                            activeIcon: "person.2.badge.plus.fill",
                            color: DS.Colors.info
                        ),
                        TabItem(
                            id: 3,
                            title: "AI Tools",
                            icon: "brain.head.profile",
                            activeIcon: "brain.head.profile",
                            color: DS.Colors.warning
                        ),
                        TabItem(
                            id: 4,
                            title: "Alerts",
                            icon: "bell",
                            activeIcon: "bell.fill",
                            color: DS.Colors.error,
                            badgeCount: alertsViewModel.unreadCount
                        ),
                        TabItem(
                            id: 5,
                            title: "Profile",
                            icon: "person.circle",
                            activeIcon: "person.circle.fill",
                            color: DS.Colors.success
                        )
                    ]
                )
                .padding(.horizontal, DS.Spacing.l)
                .padding(.bottom, 8)
                .dsCardHover(isHovered: false) // Add subtle shadow
            }
        }
        .onChange(of: selectedTab) { newValue in
            handleTabChange(to: newValue)
        }
        .onAppear {
            // Preload content and setup initial state
            setupInitialState()
        }
    }
    
    private func handleTabChange(to newTab: Int) {
        // Enhanced tab change with haptic feedback and visual effects
        isTabChanging = true
        
        // Different haptic feedback based on tab type
        switch newTab {
        case 4 where alertsViewModel.unreadCount > 0: // Alerts with unread
            DSHaptics.warning()
        case 3: // AI Tools
            DSHaptics.medium()
        default:
            DSHaptics.light()
        }
        
        // Reset tab changing state after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + DSAnimations.Duration.standard) {
            isTabChanging = false
        }
        
        previousTab = selectedTab
    }
    
    private func setupInitialState() {
        // Initialize any required state or preload content
        previousTab = selectedTab
    }
}

// MARK: - Tab Models

struct TabItem {
    let id: Int
    let title: String
    let icon: String
    let activeIcon: String
    let color: Color
    let badgeCount: Int
    
    init(id: Int, title: String, icon: String, activeIcon: String, color: Color = DS.Colors.primary, badgeCount: Int = 0) {
        self.id = id
        self.title = title
        self.icon = icon
        self.activeIcon = activeIcon
        self.color = color
        self.badgeCount = badgeCount
    }
}

// MARK: - FloatingTabBar

struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    @State private var tabFrames: [Int: CGRect] = [:]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.id) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab.id
                ) {
                    withAnimation(DS.Motion.spring) {
                        selectedTab = tab.id
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, DS.Spacing.s)
        .padding(.vertical, DS.Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: DS.CornerRadius.xl)
                .fill(.regularMaterial)
                .shadow(
                    color: DS.Shadow.large.color,
                    radius: DS.Shadow.large.radius,
                    x: DS.Shadow.large.x,
                    y: DS.Shadow.large.y
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.CornerRadius.xl)
                .stroke(DS.Colors.outline.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - TabBarButton

struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DS.Spacing.xs) {
                ZStack {
                    // Active background
                    if isSelected {
                        RoundedRectangle(cornerRadius: DS.CornerRadius.medium)
                            .fill(DS.Colors.primaryGradient)
                            .frame(width: 36, height: 36)
                            .shadow(
                                color: DS.Colors.primary.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    }
                    
                    Image(systemName: isSelected ? tab.activeIcon : tab.icon)
                        .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? .white : DS.Colors.onSurfaceSecondary)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                .frame(height: 36)
                
                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? DS.Colors.primary : DS.Colors.onSurfaceSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .onLongPressGesture(minimumDuration: 0) {
            // On press complete
        } onPressingChanged: { pressing in
            withAnimation(DS.Motion.springFast) {
                isPressed = pressing
            }
        }
        .dsAccessibility(
            label: tab.title,
            hint: isSelected ? "Currently selected" : "Tap to switch to \(tab.title)",
            traits: isSelected ? [.button, .selected] : .button
        )
    }
}

// MARK: - Preview

#if DEBUG
    import UserNotifications

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
                .environmentObject(APIService.mock)
                .environmentObject(AuthenticationService())
                .environmentObject(AlertsViewModel())
                .environmentObject(TeamManager.mock)
                .preferredColorScheme(.light)
        }
    }
#endif
