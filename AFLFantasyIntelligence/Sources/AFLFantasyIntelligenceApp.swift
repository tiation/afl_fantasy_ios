import SwiftUI

@main
struct AFLFantasyIntelligenceApp: App {
    
    // MARK: - Dependencies
    
    @StateObject private var apiService = APIService()
    @StateObject private var alertsViewModel = AlertsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(apiService)
                .environmentObject(alertsViewModel)
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
            } else if let error = error {
                print("❌ Notification permission denied: \(error)")
            }
        }
    }
}

// MARK: - Content View

struct ContentView: View {
    @EnvironmentObject var apiService: APIService
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Dashboard")
                }
            
            PlayersView()
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Players")
                }
            
            AIToolsView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("AI Tools")
                }
            
            CashCowsView()
                .tabItem {
                    Image(systemName: "dollarsign.circle")
                    Text("Cash Cows")
                }
            
            AlertsView()
                .tabItem {
                    Image(systemName: "bell")
                    Text("Alerts")
                }
        }
        .accentColor(DS.Colors.primary)
    }
}

// MARK: - Preview

#if DEBUG
import UserNotifications

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(APIService.mock)
            .environmentObject(AlertsViewModel())
            .preferredColorScheme(.light)
    }
}
#endif
