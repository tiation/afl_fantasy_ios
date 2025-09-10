import SwiftUI

// MARK: - Dashboard View (inline until properly added to Xcode project)

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    // @StateObject private var avatarLoader = AvatarLoader.shared // Temporarily disabled
    @State private var keychainManager = KeychainManager()
    @State private var showingAFLFantasyImport = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Personalized Header
                    personalizedHeader
                    
                    // AFL Fantasy Import Section (if not connected)
                    if !keychainManager.hasAFLCredentials() {
                        aflFantasyImportSection
                    }
                    
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
            // .sheet(isPresented: $showingAFLFantasyImport) {
            //     AFLFantasyImportView()
            // }
        }
    }
    
    @ViewBuilder
    private var personalizedHeader: some View {
        HStack(spacing: 16) {
            // Avatar - Simple placeholder for now
            let userName = keychainManager.getAFLUsername() ?? "User"
            let initials = getInitials(from: userName)
            
            Circle()
                .fill(Color.blue.gradient)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(initials)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(getGreeting())
                    .font(.headline)
                    .foregroundColor(.primary)
                
                let userName = keychainManager.getAFLUsername() ?? "User"
                Text(userName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                // TODO: Add API connection status when MasterDataService is properly integrated
                
                // Show favorite team if set (TODO: implement when user profile system is ready)
                // if let favoriteTeamId = keychainManager.getFavoriteTeamId(),
                //    let favoriteTeam = AFLTeam.byId(favoriteTeamId) {
                //     HStack(spacing: 6) {
                //         Circle()
                //             .fill(Color(hex: favoriteTeam.primaryColor) ?? .blue)
                //             .frame(width: 8, height: 8)
                //         
                //         Text("\(favoriteTeam.shortName) supporter")
                //             .font(.caption)
                //             .foregroundColor(.secondary)
                //     }
                // }
            }
            
            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder
    private var aflFantasyImportSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "sportscourt.fill")
                    .font(.title)
                    .foregroundStyle(.blue.gradient)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Connect Your AFL Fantasy Team")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Import your actual roster, scores, and rankings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Button {
                showingAFLFantasyImport = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.down.fill")
                        .font(.title3)
                    
                    Text("Import My AFL Fantasy Team")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue.gradient, in: RoundedRectangle(cornerRadius: 12))
            }
            
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Image(systemName: "lock.shield.fill")
                        .foregroundColor(.green)
                    Text("Secure")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Image(systemName: "iphone")
                        .foregroundColor(.blue)
                    Text("Local Only")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Image(systemName: "clock.arrow.2.circlepath")
                        .foregroundColor(.orange)
                    Text("Auto-Sync")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.blue.opacity(0.3), lineWidth: 1)
        )
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
                    icon: "trophy.fill",
                    title: "Current Score", 
                    value: "\(viewModel.liveStats.currentScore)", 
                    color: .blue
                )
                StatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Rank", 
                    value: "#\(viewModel.liveStats.rank)",
                    color: .green
                )
                StatCard(
                    icon: "person.fill",
                    title: "Playing", 
                    value: "\(viewModel.liveStats.playersPlaying)",
                    color: .orange
                )
                StatCard(
                    icon: "clock.fill",
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
    
    // MARK: - Helper Methods
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }
    
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1))
        } else {
            return String(name.prefix(2))
        }
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
