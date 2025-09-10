import SwiftUI

// MARK: - MainTabView

/// Main tab-based navigation with unified dashboard and performance monitoring
struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var toolsClient: AFLFantasyToolsClient
    @EnvironmentObject private var hapticsManager: AFLHapticsManager
    @State private var selectedTab: TabItem = .dashboard
    @StateObject private var performanceMonitor = PerformanceMonitor.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            UnifiedDashboardView()
                .tabItem {
                    Label(TabItem.dashboard.title, systemImage: TabItem.dashboard.systemImage)
                }
                .tag(TabItem.dashboard)
                .onColdStartCompleted() // Mark cold start completion

            TradesView()
                .tabItem {
                    Label(TabItem.trades.title, systemImage: TabItem.trades.systemImage)
                }
                .tag(TabItem.trades)

            CaptainAIView()
                .tabItem {
                    Label(TabItem.captain.title, systemImage: TabItem.captain.systemImage)
                }
                .tag(TabItem.captain)

            CashCowView()
                .tabItem {
                    Label(TabItem.cashCow.title, systemImage: TabItem.cashCow.systemImage)
                }
                .tag(TabItem.cashCow)

            SettingsView()
                .tabItem {
                    Label(TabItem.settings.title, systemImage: TabItem.settings.systemImage)
                }
                .tag(TabItem.settings)
        }
        .tint(.orange)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .environmentObject(AFLFantasyToolsClient())
        .environmentObject(AFLHapticsManager())
}
