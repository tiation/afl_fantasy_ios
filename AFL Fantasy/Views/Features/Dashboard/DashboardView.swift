import SwiftUI

/// Perfect Dashboard View with iOS HIG compliance, accessibility, and robust error handling
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Theme.Colors.groupedBackground
                    .ignoresSafeArea()
                
                // Content
                Group {
                    if viewModel.isLoading && viewModel.liveStats.currentScore == 0 {
                        // Initial loading state
                        LoadingState("Loading your dashboard...")
                    } else if viewModel.showError && !viewModel.isLoading {
                        // Error state with retry
                        ErrorState(error: AFLFantasyError.networkError(viewModel.errorMessage)) {
                            Task { await viewModel.refresh() }
                        }
                    } else {
                        // Main content
                        dashboardContent
                    }
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refresh()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    viewModel.loadData()
                }
            }
            .onAppear {
                viewModel.loadData()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("Try Again") {
                    Task { await viewModel.refresh() }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    @ViewBuilder
    private var dashboardContent: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: Theme.Spacing.l) {
                // Header with live indicator
                headerSection
                
                // Live Stats Section
                statsSection
                
                // Team Structure Section
                teamStructureSection
                
                // Cash Generation Section
                cashGenerationSection
                
                // AI Recommendations Section
                recommendationsSection
                
                // Bottom padding for tab bar
                Color.clear.frame(height: Theme.Spacing.l)
            }
            .padding(.horizontal, Theme.Spacing.m)
        }
        .loadingState(viewModel.isLoading)
    }
    
    @ViewBuilder
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Welcome back!")
                    .font(Theme.Font.title2)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                if viewModel.hasLiveGames {
                    HStack(spacing: Theme.Spacing.xs) {
                        Circle()
                            .fill(Theme.Colors.success)
                            .frame(width: 8, height: 8)
                            .animation(Theme.Animation.standard, value: viewModel.hasLiveGames)
                        
                        Text("Live games in progress")
                            .font(Theme.Font.callout)
                            .foregroundColor(Theme.Colors.success)
                    }
                } else {
                    Text("No live games")
                        .font(Theme.Font.callout)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            // Notification indicator
            if viewModel.unreadNotifications > 0 {
                Button {
                    viewModel.openNotifications()
                } label: {
                    ZStack {
                        Image(systemName: "bell")
                            .font(.title2)
                            .foregroundColor(Theme.Colors.accent)
                        
                        if viewModel.unreadNotifications > 0 {
                            Text("\(min(viewModel.unreadNotifications, 99))")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Theme.Colors.error)
                                .clipShape(Circle())
                                .offset(x: 8, y: -8)
                        }
                    }
                }
                .minTouchTarget()
                .accessibilityLabel("Notifications")
                .accessibilityValue("\(viewModel.unreadNotifications) unread")
            }
        }
        .padding(.vertical, Theme.Spacing.s)
    }
    
    @ViewBuilder
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            SectionHeader(
                "Live Stats",
                subtitle: viewModel.hasLiveGames ? "Updating in real-time" : "Next round starting soon"
            )
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Theme.Spacing.m),
                GridItem(.flexible(), spacing: Theme.Spacing.m)
            ], spacing: Theme.Spacing.m) {
                PerfectStatCard(
                    title: "Current Score",
                    value: "\(viewModel.liveStats.currentScore)",
                    color: Theme.Colors.score,
                    icon: "chart.line.uptrend.xyaxis",
                    subtitle: viewModel.hasLiveGames ? "Live" : "Final"
                )
                
                PerfectStatCard(
                    title: "Overall Rank",
                    value: "#\(viewModel.liveStats.rank.formatted())",
                    color: Theme.Colors.rank,
                    icon: "trophy",
                    subtitle: viewModel.liveStats.rank <= 1000 ? "Top 1K" : "Keep climbing!"
                )
                
                PerfectStatCard(
                    title: "Playing",
                    value: "\(viewModel.liveStats.playersPlaying)",
                    color: Theme.Colors.success,
                    icon: "person.fill.checkmark",
                    subtitle: "of 22 players"
                )
                
                PerfectStatCard(
                    title: "Yet to Play",
                    value: "\(viewModel.liveStats.playersRemaining)",
                    color: Theme.Colors.warning,
                    icon: "clock",
                    subtitle: "remaining"
                )
            }
        }
        .padding(Theme.Spacing.m)
        .cardStyle(.elevated)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Live Stats")
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
                ForEach(viewModel.recommendations.prefix(3)) { recommendation in
                    AIRecommendationCard(recommendation: recommendation)
                }
                
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

#Preview {
    DashboardView()
}
