import SwiftUI

// DashboardView is now in separate file: AFL Fantasy/Views/Features/Dashboard/DashboardView.swift

// MARK: - Content View

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @EnvironmentObject private var alertManager: AlertManager
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            // Dashboard
            NavigationView {
                DashboardView()
                    .environmentObject(viewModel)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Dashboard")
            }
            .tag(ContentViewModel.Tab.dashboard)
            
            // Team
            NavigationView {
                TeamManagementView()
            }
            .tabItem {
                Image(systemName: "person.2.fill")
                Text("Team")
            }
            .tag(ContentViewModel.Tab.team)
            
            // Cash Cows
            NavigationView {
                CashCowAnalyzerView()
            }
            .tabItem {
                Image(systemName: "dollarsign.circle.fill")
                Text("Cash Cows")
            }
            .tag(ContentViewModel.Tab.cashCows)
            
            // Settings
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
            .tag(ContentViewModel.Tab.settings)
        }
        .onChange(of: alertManager.latestNotification) { _, notification in
            if let notification = notification {
                viewModel.handleNotification(notification)
            }
        }
        .sheet(item: $viewModel.selectedNotification) { notification in
            NotificationDetailView(notification: notification)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            // Setup initial notification permissions
            Task {
                try? await alertManager.requestNotificationPermission()
            }
        }
    }
}

@MainActor
final class ContentViewModel: ObservableObject {
    enum Tab: String, CaseIterable {
        case dashboard
        case team
        case cashCows
        case settings
    }
    
    @Published var selectedTab: Tab = .dashboard
    @Published var selectedNotification: AlertNotification?
    @Published var showError = false
    @Published var errorMessage = ""
    
    func handleNotification(_ notification: AlertNotification) {
        // Handle different notification types
        switch notification.type {
        case .injury, .selection:
            // Show immediately for urgent notifications
            selectedNotification = notification
            
        case .priceChange:
            // Show price drops immediately
            // Note: AlertNotification doesn't have data property in current model
            selectedNotification = notification
            
        case .milestone, .system:
            // Non-urgent, don't show immediately
            break
            
        case .injuryUpdate, .lateOut, .roleChange, .breakingNews, .tradeDeadline, .captainReminder:
            // Handle other alert types
            selectedNotification = notification
        }
        
        // Switch to relevant tab for context
        switch notification.type {
        case .injury, .selection, .injuryUpdate, .lateOut:
            selectedTab = .team
        case .priceChange:
            selectedTab = .cashCows
        case .milestone, .system, .roleChange, .breakingNews, .tradeDeadline, .captainReminder:
            break
        }
    }
}


// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AlertManager())
    }
}
