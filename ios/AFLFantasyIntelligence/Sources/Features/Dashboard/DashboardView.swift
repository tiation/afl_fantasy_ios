import SwiftUI

// MARK: - DashboardView

struct DashboardView: View {
    @EnvironmentObject var apiService: APIService
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingAPIStatus = false
    @Binding var selectedTab: Int

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: DS.Spacing.l) {
                    // Header Section
                    headerSection

                    // Live Performance Section
                    livePerformanceSection

                    // Team Structure Section
                    teamStructureSection

                    // Weekly Projection Section
                    weeklyProjectionSection

                    // Quick Actions Section
                    quickActionsSection
                }
                .padding(.horizontal, DS.Spacing.l)
            }
            .navigationTitle("AFL Fantasy Intelligence")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAPIStatus = true
                    } label: {
                        Image(systemName: apiService
                            .isHealthy ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
                        )
                        .foregroundColor(apiService.isHealthy ? DS.Colors.success : DS.Colors.warning)
                    }
                }
            }
            .refreshable {
                await viewModel.refresh(apiService: apiService)
            }
            .sheet(isPresented: $showingAPIStatus) {
                APIStatusView()
                    .presentationDetents([.medium])
            }
        }
        .task {
            await viewModel.loadData(apiService: apiService)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        DSCard(style: .gradient(DS.Colors.primaryGradient)) {
            VStack(alignment: .leading, spacing: DS.Spacing.l) {
                // Hero content
                HStack {
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text("Round \(viewModel.weeklyStats.round)")
                            .font(DS.Typography.brandHeadline)
                            .foregroundColor(.white.opacity(0.9))

                        Text("2024 AFL Fantasy Season")
                            .font(DS.Typography.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: DS.Spacing.xs) {
                        DSAnimatedCounter(
                            value: viewModel.liveStats.currentScore,
                            font: DS.Typography.heroNumber,
                            color: .white
                        )

                        Text("Total Score")
                            .font(DS.Typography.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                // Progress indicator for round completion
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    HStack {
                        Text("Round Progress")
                            .font(DS.Typography.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text("\(viewModel.liveStats.playersPlaying)/22 played")
                            .font(DS.Typography.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    ProgressView(value: Double(viewModel.liveStats.playersPlaying), total: 22)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                }
            }
        }
        .dsAccessibility(
            label: "Current team score is \(viewModel.liveStats.currentScore) points in round \(viewModel.weeklyStats.round)"
        )
    }

    // MARK: - Live Performance Section

    private var livePerformanceSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.l) {
            HStack {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text("Live Performance")
                        .font(DS.Typography.brandTitle)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    Text("Real-time team statistics")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                }
                
                Spacer()
                
                // Live indicator
                HStack(spacing: DS.Spacing.xs) {
                    Circle()
                        .fill(DS.Colors.error)
                        .frame(width: 8, height: 8)
                        .scaleEffect(1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                            value: Date().timeIntervalSince1970
                        )
                    
                    Text("LIVE")
                        .font(DS.Typography.badge)
                        .foregroundColor(DS.Colors.error)
                }
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.m), count: 2),
                spacing: DS.Spacing.m
            ) {
                DSStatCard(
                    title: "Current Rank",
                    value: "#\(viewModel.liveStats.rank.formatted())",
                    trend: determineRankTrend(),
                    icon: "chart.bar",
                    style: .prominent
                )

                DSStatCard(
                    title: "vs Average",
                    value: String(format: "%.0f", viewModel.liveStats.averageScore),
                    trend: viewModel.liveStats.currentScore > Int(viewModel.liveStats.averageScore) ?
                        .up("+\(viewModel.liveStats.currentScore - Int(viewModel.liveStats.averageScore))") :
                        .down("\(viewModel.liveStats.currentScore - Int(viewModel.liveStats.averageScore))"),
                    icon: "person.3",
                    style: .gradient
                )

                DSStatCard(
                    title: "Active Players",
                    value: "\(viewModel.liveStats.playersPlaying)",
                    trend: .neutral,
                    icon: "figure.run",
                    style: .standard
                )

                DSStatCard(
                    title: "Yet to Play",
                    value: "\(viewModel.liveStats.playersRemaining)",
                    trend: nil,
                    icon: "clock",
                    style: .minimal
                )
            }
        }
    }
    
    private func determineRankTrend() -> DSStatCard.Trend? {
        // Mock rank change logic - in real app, compare with previous rank
        let rankChange = Int.random(in: -500...200)
        if rankChange > 0 {
            return .up("+\(rankChange)")
        } else if rankChange < 0 {
            return .down("\(rankChange)")
        }
        return .neutral
    }

    // MARK: - Team Structure Section

    private var teamStructureSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.l) {
            HStack {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text("Team Structure")
                        .font(DS.Typography.brandTitle)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    Text("Value breakdown and player positions")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                }
                
                Spacer()
            }

            VStack(spacing: DS.Spacing.m) {
                // Financial Overview Cards
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.m), count: 2),
                    spacing: DS.Spacing.m
                ) {
                    DSStatCard(
                        title: "Total Value",
                        value: "$\(viewModel.teamStructure.totalValue.formatted())",
                        trend: nil,
                        icon: "chart.pie",
                        style: .elevated,
                        animated: true
                    )
                    
                    DSStatCard(
                        title: "Bank Balance",
                        value: "$\(viewModel.teamStructure.bankBalance.formatted())",
                        trend: viewModel.teamStructure.bankBalance > 500000 ? 
                            .up("Healthy") : 
                            (viewModel.teamStructure.bankBalance > 100000 ? .neutral : .down("Low")),
                        icon: "banknote",
                        style: .gradient,
                        animated: true
                    )
                }
                
                // Position Balance Card
                DSCard(style: .elevated) {
                    VStack(alignment: .leading, spacing: DS.Spacing.m) {
                        HStack {
                            Image(systemName: "person.3.fill")
                                .font(.title3)
                                .foregroundColor(DS.Colors.primary)
                            
                            Text("Position Balance")
                                .font(DS.Typography.headline)
                                .foregroundColor(DS.Colors.onSurface)
                            
                            Spacer()
                        }
                        
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.s), count: 4),
                            spacing: DS.Spacing.m
                        ) {
                            ForEach(Position.allCases, id: \.self) { position in
                                VStack(spacing: DS.Spacing.xs) {
                                    Text(position.shortName)
                                        .font(DS.Typography.caption)
                                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                                    
                                    ZStack {
                                        Circle()
                                            .fill(DS.Colors.positionColor(for: position).opacity(0.1))
                                            .frame(width: 36, height: 36)
                                        
                                        Text("\(viewModel.teamStructure.positionBalance[position] ?? 0)")
                                            .font(DS.Typography.smallStat)
                                            .foregroundColor(DS.Colors.positionColor(for: position))
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Text(position.maxCount > 0 ? "/\(position.maxCount)" : "")
                                        .font(.system(size: 10))
                                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Weekly Projection Section

    private var weeklyProjectionSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.l) {
            HStack {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text("Weekly Projection")
                        .font(DS.Typography.brandTitle)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    Text("AI-powered score predictions")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                }
                
                Spacer()
                
                DSStatusBadge(
                    text: "AI Powered",
                    style: .success
                )
            }

            DSGradientCard(gradient: LinearGradient(
                colors: [DS.Colors.primary, DS.Colors.primary.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )) {
                HStack(spacing: DS.Spacing.l) {
                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        HStack(spacing: DS.Spacing.xs) {
                            Image(systemName: "brain.head.profile")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Projected Score")
                                .font(DS.Typography.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }

                        DSAnimatedCounter(
                            value: Double(viewModel.weeklyStats.projectedScore),
                            font: DS.Typography.heroNumber,
                            color: .white
                        )
                        .fontWeight(.bold)

                        HStack(spacing: DS.Spacing.s) {
                            Text("Confidence:")
                                .font(DS.Typography.caption)
                                .foregroundColor(.white.opacity(0.7))
                            
                            DSProgressRing(
                                progress: 0.85, // Mock confidence level
                                lineWidth: 2
                            )
                            .frame(width: 16, height: 16)
                            .foregroundColor(.white)
                            
                            Text("85%")
                                .font(DS.Typography.caption)
                                .foregroundColor(.white.opacity(0.9))
                                .fontWeight(.medium)
                        }
                    }

                    Spacer()

                    VStack(spacing: DS.Spacing.s) {
                        DSProgressRing(
                            progress: Double(viewModel.weeklyStats.projectedScore) / 2500.0,
                            lineWidth: 6
                        )
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                        
                        Text("vs 2500 avg")
                            .font(DS.Typography.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            // Additional insights cards
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.m), count: 2),
                spacing: DS.Spacing.m
            ) {
                DSStatCard(
                    title: "Best Captain",
                    value: "Grundy", // Mock data
                    trend: .up("127 pts"),
                    icon: "star.circle",
                    style: .elevated
                )
                
                DSStatCard(
                    title: "Risk Level",
                    value: "Medium", // Mock data
                    trend: .neutral,
                    icon: "shield.checkered",
                    style: .minimal
                )
            }
        }
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.l) {
            HStack {
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text("Quick Actions")
                        .font(DS.Typography.brandTitle)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    Text("Popular shortcuts and tools")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                }
                
                Spacer()
            }

            VStack(spacing: DS.Spacing.m) {
                // Primary action card
                Button {
                    withAnimation {
                        selectedTab = 3 // AI Tools
                    }
                } label: {
                    DSGradientCard {
                        HStack(spacing: DS.Spacing.m) {
                            Image(systemName: "brain.head.profile")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                                Text("Get Captain Suggestions")
                                    .font(DS.Typography.headline)
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                                
                                Text("AI-powered recommendations")
                                    .font(DS.Typography.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Secondary action cards
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.m), count: 2),
                    spacing: DS.Spacing.m
                ) {
                    Button {
                        withAnimation {
                            selectedTab = 4 // Cash Cows
                        }
                    } label: {
                        DSCard(style: .elevated) {
                            VStack(spacing: DS.Spacing.s) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.title2)
                                    .foregroundColor(DS.Colors.success)
                                    .frame(width: 40, height: 40)
                                    .background(DS.Colors.success.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Text("Cash Cows")
                                    .font(DS.Typography.body)
                                    .foregroundColor(DS.Colors.onSurface)
                                    .fontWeight(.medium)
                                
                                Text("Value picks")
                                    .font(DS.Typography.caption)
                                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DS.Spacing.s)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        withAnimation {
                            selectedTab = 5 // Alerts
                        }
                    } label: {
                        DSCard(style: .elevated) {
                            VStack(spacing: DS.Spacing.s) {
                                Image(systemName: "bell.badge")
                                    .font(.title2)
                                    .foregroundColor(DS.Colors.warning)
                                    .frame(width: 40, height: 40)
                                    .background(DS.Colors.warning.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Text("Price Changes")
                                    .font(DS.Typography.body)
                                    .foregroundColor(DS.Colors.onSurface)
                                    .fontWeight(.medium)
                                
                                Text("Market alerts")
                                    .font(DS.Typography.caption)
                                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DS.Spacing.s)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

// MARK: - APIStatusView

struct APIStatusView: View {
    @EnvironmentObject var apiService: APIService
    @Environment(\.dismiss) var dismiss

    private var statusIconName: String {
        apiService.isHealthy ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
    }

    private var statusColor: Color {
        apiService.isHealthy ? DS.Colors.success : DS.Colors.error
    }

    var body: some View {
        NavigationView {
            VStack(spacing: DS.Spacing.l) {
                DSCard {
                    VStack(alignment: .leading, spacing: DS.Spacing.m) {
                        HStack {
                            Image(systemName: statusIconName)
                                .font(.title2)
                                .foregroundColor(statusColor)

                            Text("API Status")
                                .font(DS.Typography.headline)

                            Spacer()
                        }

                        Text(apiService.isHealthy ? "Connected" : "Disconnected")
                            .font(DS.Typography.subheadline)
                            .foregroundColor(statusColor)

                        if let lastCheck = apiService.lastHealthCheck {
                            Text("Last checked: \(lastCheck.formatted(date: .omitted, time: .shortened))")
                                .font(DS.Typography.caption)
                                .foregroundColor(DS.Colors.onSurfaceSecondary)
                        }
                    }
                }

                DSButton("Refresh Connection") {
                    Task {
                        await apiService.checkHealth()
                    }
                }

                Spacer()
            }
            .padding(DS.Spacing.l)
            .navigationTitle("System Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - DashboardViewModel

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var liveStats = LiveStats.mock
    @Published var weeklyStats = WeeklyStats.mock
    @Published var teamStructure = TeamStructure.mock
    @Published var isLoading = false
    
    private var webSocketManager: WebSocketManager?
    private var isConnected = false

    func loadData(apiService: APIService) async {
        isLoading = true
        defer { isLoading = false }

        // Connect WebSocket for live updates if available
        connectWebSocket(baseURL: apiService.currentEndpoint)
        
        // In a real app, these would come from API
        // For now, using mock data

        // Simulate API delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // TODO: Replace with actual API calls when backend supports dashboard endpoint
        // let stats = try? await apiService.fetchStats()
    }

    func refresh(apiService: APIService) async {
        await loadData(apiService: apiService)
    }
    
    // MARK: - WebSocket Support
    
    private func connectWebSocket(baseURL: String) {
        // Convert HTTP to WS URL
        let wsURL = baseURL
            .replacingOccurrences(of: "http://", with: "ws://")
            .replacingOccurrences(of: "https://", with: "wss://")
        
        guard let url = URL(string: "\(wsURL)/ws/live") else { return }
        
        webSocketManager = WebSocketManager(url: url)
        webSocketManager?.onReceiveData = { [weak self] data in
            Task { @MainActor in
                self?.handleWebSocketData(data)
            }
        }
        
        webSocketManager?.connect()
        isConnected = true
    }
    
    private func handleWebSocketData(_ data: Data) {
        // Parse WebSocket updates for live stats
        struct LiveUpdate: Codable {
            let type: String
            let liveStats: LiveStats?
            let alert: AlertNotification?
        }
        
        do {
            let update = try JSONDecoder().decode(LiveUpdate.self, from: data)
            
            if let stats = update.liveStats {
                withAnimation(.easeInOut(duration: 0.3)) {
                    liveStats = stats
                }
            }
            
            if let alert = update.alert {
                // Publish alert notification
                NotificationCenter.default.post(
                    name: NSNotification.Name("NewAlert"),
                    object: alert
                )
            }
        } catch {
            print("Failed to parse WebSocket data: \(error)")
        }
    }
    
    deinit {
        webSocketManager?.disconnect()
    }
}

// MARK: - Previews

#if DEBUG
    struct DashboardView_Previews: PreviewProvider {
        static var previews: some View {
            DashboardView(selectedTab: .constant(0))
                .environmentObject(APIService.mock)
                .preferredColorScheme(.light)
        }
    }
#endif
