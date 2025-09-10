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
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Round \(viewModel.weeklyStats.round)")
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.Colors.onSurface)

                        Text("Current Season")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("\(viewModel.liveStats.currentScore)")
                            .font(DS.Typography.heroNumber)
                            .foregroundColor(DS.Colors.primary)

                        Text("Total Score")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }
                }
            }
        }
        .dsAccessibility(
            label: "Current team score is \(viewModel.liveStats.currentScore) points in round \(viewModel.weeklyStats.round)"
        )
    }

    // MARK: - Live Performance Section

    private var livePerformanceSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            Text("Live Performance")
                .font(DS.Typography.title3)
                .foregroundColor(DS.Colors.onSurface)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.m), count: 2),
                spacing: DS.Spacing.m
            ) {
                DSStatCard(
                    title: "Current Rank",
                    value: "#\(viewModel.liveStats.rank.formatted())",
                    trend: nil,
                    icon: "chart.bar"
                )

                DSStatCard(
                    title: "Average Score",
                    value: String(format: "%.0f", viewModel.liveStats.averageScore),
                    trend: viewModel.liveStats.currentScore > Int(viewModel.liveStats.averageScore) ?
                        .up("+\(viewModel.liveStats.currentScore - Int(viewModel.liveStats.averageScore))") :
                        .down("\(viewModel.liveStats.currentScore - Int(viewModel.liveStats.averageScore))"),
                    icon: "person.3"
                )

                DSStatCard(
                    title: "Players Playing",
                    value: "\(viewModel.liveStats.playersPlaying)/22",
                    trend: nil,
                    icon: "figure.run"
                )

                DSStatCard(
                    title: "Players Remaining",
                    value: "\(viewModel.liveStats.playersRemaining)",
                    trend: nil,
                    icon: "clock"
                )
            }
        }
    }

    // MARK: - Team Structure Section

    private var teamStructureSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            Text("Team Structure")
                .font(DS.Typography.title3)
                .foregroundColor(DS.Colors.onSurface)

            DSCard {
                VStack(spacing: DS.Spacing.m) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total Value")
                                .font(DS.Typography.subheadline)
                                .foregroundColor(DS.Colors.onSurfaceSecondary)
                            Text("$\(viewModel.teamStructure.totalValue.formatted())")
                                .font(DS.Typography.statNumber)
                                .foregroundColor(DS.Colors.onSurface)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("Bank")
                                .font(DS.Typography.subheadline)
                                .foregroundColor(DS.Colors.onSurfaceSecondary)
                            Text("$\(viewModel.teamStructure.bankBalance.formatted())")
                                .font(DS.Typography.statNumber)
                                .foregroundColor(DS.Colors.success)
                        }
                    }

                    Divider()

                    HStack {
                        ForEach(Position.allCases, id: \.self) { position in
                            VStack {
                                Text(position.shortName)
                                    .font(DS.Typography.caption)
                                    .foregroundColor(DS.Colors.onSurfaceSecondary)

                                Text("\(viewModel.teamStructure.positionBalance[position] ?? 0)")
                                    .font(DS.Typography.smallStat)
                                    .foregroundColor(DS.Colors.positionColor(for: position))
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Weekly Projection Section

    private var weeklyProjectionSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            Text("Weekly Projection")
                .font(DS.Typography.title3)
                .foregroundColor(DS.Colors.onSurface)

            DSCard {
                HStack {
                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        Text("Projected Score")
                            .font(DS.Typography.subheadline)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)

                        Text("\(viewModel.weeklyStats.projectedScore)")
                            .font(DS.Typography.statNumber)
                            .foregroundColor(DS.Colors.primary)

                        Text("Based on AI analysis")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceVariant)
                    }

                    Spacer()

                    Image(systemName: "brain.head.profile")
                        .font(.largeTitle)
                        .foregroundColor(DS.Colors.primary.opacity(0.3))
                }
            }
        }
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            Text("Quick Actions")
                .font(DS.Typography.title3)
                .foregroundColor(DS.Colors.onSurface)

            VStack(spacing: DS.Spacing.s) {
                DSButton("Get Captain Suggestions", style: .primary) {
                    withAnimation {
                        selectedTab = 2 // AI Tools
                    }
                }

                DSButton("View Cash Cows", style: .secondary) {
                    withAnimation {
                        selectedTab = 3 // Cash Cows
                    }
                }

                DSButton("Check Price Changes", style: .outline) {
                    withAnimation {
                        selectedTab = 4 // Alerts
                    }
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

    func loadData(apiService: APIService) async {
        isLoading = true
        defer { isLoading = false }

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
