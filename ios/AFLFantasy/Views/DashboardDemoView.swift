//
//  DashboardDemoView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Combine
import SwiftUI

// MARK: - DashboardDemoView

/// Demo SwiftUI view for dashboard data integration
struct DashboardDemoView: View {
    // MARK: - Properties

    @StateObject private var dashboardService = DashboardService()
    @State private var showingError = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if dashboardService.isLoading {
                        LoadingView()
                    } else if let dashboard = dashboardService.dashboard {
                        DashboardContent(dashboard: dashboard)
                    } else {
                        EmptyStateView()
                    }
                }
                .padding()
            }
            .navigationTitle("AFL Fantasy Dashboard")
            .refreshable {
                await refreshDashboard(forceRefresh: true)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        Task {
                            await refreshDashboard(forceRefresh: true)
                        }
                    }
                    .disabled(dashboardService.isLoading)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("Retry") {
                    Task {
                        await refreshDashboard()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let error = dashboardService.lastError {
                    Text(error.localizedDescription)
                } else {
                    Text("An unknown error occurred")
                }
            }
        }
        .task {
            await refreshDashboard()
        }
        .onChange(of: dashboardService.lastError) { error in
            showingError = error != nil
        }
    }

    // MARK: - Private Methods

    @MainActor
    private func refreshDashboard(forceRefresh: Bool = false) async {
        do {
            _ = try await dashboardService.getDashboard(forceRefresh: forceRefresh)
                .singleOutput()
        } catch {
            // Error is handled by the service's published properties
            print("Dashboard refresh failed: \(error)")
        }
    }
}

// MARK: - DashboardContent

struct DashboardContent: View {
    let dashboard: DashboardResponse

    var body: some View {
        VStack(spacing: 16) {
            // Team Value Section
            TeamValueCard(teamValue: dashboard.teamValue)

            // Rank Section
            RankCard(rank: dashboard.rank)

            // Top Performers
            if let topPerformers = dashboard.topPerformers, !topPerformers.isEmpty {
                TopPerformersCard(performers: topPerformers)
            }

            // Upcoming Matchups
            if !dashboard.upcomingMatchups.isEmpty {
                MatchupsCard(matchups: dashboard.upcomingMatchups)
            }

            // Last Updated
            LastUpdatedView(date: dashboard.lastUpdated)
        }
    }
}

// MARK: - TeamValueCard

struct TeamValueCard: View {
    let teamValue: TeamValue

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Team Value")
                    .font(.headline)
                Spacer()
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.green)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Current:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(formatCurrency(teamValue.current))
                        .fontWeight(.semibold)
                }

                HStack {
                    Text("Bank:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(formatCurrency(teamValue.bank))
                        .fontWeight(.semibold)
                }

                Divider()

                HStack {
                    Text("Total:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(formatCurrency(teamValue.total))
                        .fontWeight(.bold)
                        .font(.title3)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
}

// MARK: - RankCard

struct RankCard: View {
    let rank: Rank

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Overall Rank")
                    .font(.headline)
                Spacer()
                Image(systemName: "trophy.fill")
                    .foregroundColor(.orange)
            }

            HStack {
                Text("\(formatNumber(rank.overall))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()

                if let league = rank.league {
                    VStack(alignment: .trailing) {
                        Text("League Rank")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(formatNumber(league))")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - TopPerformersCard

struct TopPerformersCard: View {
    let performers: [TopPerformer]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Top Performers")
                    .font(.headline)
                Spacer()
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }

            ForEach(Array(performers.prefix(3).enumerated()), id: \.offset) { index, performer in
                HStack {
                    Text("\(index + 1).")
                        .fontWeight(.semibold)
                        .frame(width: 20, alignment: .leading)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(performer.name)
                            .fontWeight(.medium)
                        Text("\(performer.team) • \(performer.position)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text("\(performer.score)")
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding(.vertical, 4)

                if index < performers.prefix(3).count - 1 {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - MatchupsCard

struct MatchupsCard: View {
    let matchups: [Matchup]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming Matchups")
                    .font(.headline)
                Spacer()
                Image(systemName: "sportscourt.fill")
                    .foregroundColor(.blue)
            }

            ForEach(Array(matchups.prefix(3).enumerated()), id: \.offset) { index, matchup in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(matchup.homeTeam) vs \(matchup.awayTeam)")
                            .fontWeight(.medium)
                        Spacer()
                        Text("R\(matchup.round)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(formatMatchupDate(matchup.startTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)

                if index < matchups.prefix(3).count - 1 {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func formatMatchupDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - LoadingView

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading Dashboard...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(40)
    }
}

// MARK: - EmptyStateView

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Data Available")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Pull to refresh or tap the refresh button to load your dashboard data.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(40)
    }
}

// MARK: - LastUpdatedView

struct LastUpdatedView: View {
    let date: Date

    var body: some View {
        HStack {
            Spacer()
            Text("Last updated: \(formatDate(date))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Combine Extension

extension Publisher {
    /// Convert publisher to async single output
    func singleOutput() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?

            cancellable = self
                .first()
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case let .failure(error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
        }
    }
}

// MARK: - Preview

struct DashboardDemoView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardDemoView()
    }
}
