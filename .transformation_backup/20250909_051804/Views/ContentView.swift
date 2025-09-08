import SwiftUI

// MARK: - Dashboard View (inline until properly added to Xcode project)

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Live Stats Section
                    statsSection
                    
                    // Team Structure Section
                    teamStructureSection
                    
                    // Cash Cow Analysis Section
                    cashCowSection
                    
                    // AI Recommendations Section
                    recommendationsSection
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .refreshable {
                await viewModel.refresh()
            }
            .onAppear {
                viewModel.loadData()
            }
        }
    }
    
    @ViewBuilder
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Stats")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "Current Score", 
                    value: "\(viewModel.liveStats.currentScore)",
                    color: .blue
                )
                StatCard(
                    title: "Rank", 
                    value: "#\(viewModel.liveStats.rank)",
                    color: .green
                )
                StatCard(
                    title: "Playing", 
                    value: "\(viewModel.liveStats.playersPlaying)",
                    color: .orange
                )
                StatCard(
                    title: "Remaining", 
                    value: "\(viewModel.liveStats.playersRemaining)",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    @ViewBuilder
    private var teamStructureSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Team Structure")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(viewModel.teamStructure.totalValue / 1000)k")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Bank Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(viewModel.teamStructure.bankBalance / 1000)k")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    @ViewBuilder
    private var cashCowSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cash Generation")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Generated")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(viewModel.cashGenStats.totalGenerated / 1000)k")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("Active Cows")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.cashGenStats.activeCashCows)")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Sell Recs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.cashGenStats.sellRecommendations)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    @ViewBuilder
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Recommendations")
                .font(.headline)
                .foregroundColor(.primary)
            
            if viewModel.recommendations.isEmpty {
                Text("No recommendations available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
            } else {
                AIRecommendationCard(
                    title: "Top Recommendations",
                    recommendations: Array(viewModel.recommendations.prefix(3)),
                    showConfidence: true
                )
                
                if viewModel.recommendations.count > 3 {
                    Button("View All Recommendations") {
                        // Navigate to full recommendations view
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Content View

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @EnvironmentObject private var alertManager: AlertManager
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            // Dashboard
            NavigationView {
                DashboardView()
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
            
            // Cash Cows - Temporarily disabled
            NavigationView {
                Text("Cash Cow Analyzer Coming Soon")
                    .foregroundColor(.secondary)
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
