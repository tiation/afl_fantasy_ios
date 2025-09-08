import SwiftUI

// MARK: - MainTabView

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var toolsClient: AFLFantasyToolsClient
    @EnvironmentObject private var hapticsManager: AFLHapticsManager
    @State private var selectedTab: TabItem = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label(selectedTab.title, systemImage: selectedTab.systemImage)
                }
                .tag(TabItem.dashboard)

            TradesView()
                .tabItem {
                    Label(selectedTab.title, systemImage: selectedTab.systemImage)
                }
                .tag(TabItem.trades)

            CaptainAIView()
                .tabItem {
                    Label(selectedTab.title, systemImage: selectedTab.systemImage)
                }
                .tag(TabItem.captain)

            CashCowView()
                .tabItem {
                    Label(selectedTab.title, systemImage: selectedTab.systemImage)
                }
                .tag(TabItem.cashCow)

            SettingsView()
                .tabItem {
                    Label(selectedTab.title, systemImage: selectedTab.systemImage)
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
