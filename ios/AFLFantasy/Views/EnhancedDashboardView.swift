//
//  EnhancedDashboardView.swift
//  AFL Fantasy Intelligence Platform
//
//  Enhanced dashboard with AI insights and analytics
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - EnhancedDashboardView

struct EnhancedDashboardView: View {
    // MARK: - Environment

    @EnvironmentObject private var dataService: AFLFantasyDataService
    @EnvironmentObject private var toolsClient: AFLFantasyToolsClient
    @EnvironmentObject private var appState: AppState

    // MARK: - State

    @State private var aiRecommendations: [AIRecommendation] = []
    @State private var captainSuggestions: [CaptainSuggestionAnalysis] = []
    @State private var isLoadingAI = false
    @State private var showingAllRecommendations = false
    @State private var selectedRecommendation: AIRecommendation?
    @State private var showingRecommendationDetail = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if dataService.authenticated {
                        authenticatedContent
                    } else {
                        unauthenticatedContent
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    refreshButton
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if dataService.authenticated {
                            Button("Refresh AI") {
                                loadAIInsights()
                            }

                            Button("Settings") {
                                // Settings
                            }

                            Button("Sign Out", role: .destructive) {
                                dataService.logout()
                            }
                        } else {
                            Button("Sign In") {
                                // Show login
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingRecommendationDetail) {
            if let recommendation = selectedRecommendation {
                RecommendationDetailView(recommendation: recommendation)
            }
        }
        .onAppear {
            if dataService.authenticated {
                loadAIInsights()
            }
        }
        .refreshable {
            await refreshAllData()
        }
    }

    // MARK: - Authenticated Content

    private var authenticatedContent: some View {
        VStack(spacing: 16) {
            // Enhanced Status Card
            EnhancedStatusCard()

            // AI Quick Insights
            if !aiRecommendations.isEmpty {
                AIQuickInsightsCard(
                    recommendations: aiRecommendations,
                    onViewAll: {
                        showingAllRecommendations = true
                    },
                    onRecommendationTap: { recommendation in
                        selectedRecommendation = recommendation
                        showingRecommendationDetail = true
                    }
                )
            }

            // Key Metrics with AI Enhancement
            if let dashboardData = dataService.currentDashboardData {
                EnhancedMetricsGrid(
                    dashboardData: dashboardData,
                    recommendations: aiRecommendations
                )
            }

            // Captain Insights
            if !captainSuggestions.isEmpty {
                CaptainInsightsCard(
                    suggestions: Array(captainSuggestions.prefix(3)),
                    currentCaptain: dataService.currentCaptain
                )
            }

            // Quick Actions
            QuickActionsCard()

            // Performance Summary
            PerformanceSummaryCard()

            // Update Information
            UpdateInfoCard()

            // Error Display
            if dataService.hasError {
                ErrorCard()
            }
        }
    }

    // MARK: - Unauthenticated Content

    private var unauthenticatedContent: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)

                Text("AFL Fantasy Intelligence")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(
                    "AI-powered insights, advanced analytics, and intelligent recommendations for your AFL Fantasy success"
                )
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                Button("Sign In to Unlock AI Features") {
                    // Show login
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Text("✨ Captain Analysis • Trade Intelligence • Cash Generation • Risk Assessment")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Refresh Button

    private var refreshButton: some View {
        Button(action: {
            Task {
                await refreshAllData()
            }
        }) {
            Image(systemName: dataService.loading ? "arrow.clockwise" : "arrow.clockwise")
                .rotationEffect(dataService.loading ? .degrees(360) : .degrees(0))
                .animation(
                    dataService.loading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                    value: dataService.loading
                )
        }
        .disabled(dataService.loading)
    }

    // MARK: - Helper Methods

    private func refreshAllData() async {
        guard dataService.authenticated else { return }

        async let dashboardRefresh = dataService.refreshDashboardData()
        async let aiInsightsRefresh = loadAIInsightsAsync()
        async let captainRefresh = loadCaptainSuggestionsAsync()

        _ = await (dashboardRefresh, aiInsightsRefresh, captainRefresh)
    }

    private func loadAIInsights() {
        Task {
            await loadAIInsightsAsync()
        }
    }

    private func loadAIInsightsAsync() async {
        let result = await toolsClient.getAIRecommendations(category: nil)

        await MainActor.run {
            switch result {
            case let .success(recommendations):
                aiRecommendations = Array(recommendations.prefix(3)) // Show top 3 on dashboard
            case .failure:
                // Fail silently for dashboard
                break
            }
        }
    }

    private func loadCaptainSuggestionsAsync() async {
        let result = await toolsClient.getCaptainSuggestions(round: nil)

        await MainActor.run {
            switch result {
            case let .success(suggestions):
                captainSuggestions = Array(suggestions.prefix(2)) // Show top 2 on dashboard
            case .failure:
                // Fail silently for dashboard
                break
            }
        }
    }
}

// MARK: - EnhancedStatusCard

struct EnhancedStatusCard: View {
    @EnvironmentObject private var dataService: AFLFantasyDataService
    @EnvironmentObject private var toolsClient: AFLFantasyToolsClient

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("System Status")
                        .font(.headline)
                        .foregroundColor(.primary)

                    HStack(spacing: 12) {
                        StatusIndicator(
                            title: "AFL Data",
                            isActive: dataService.authenticated,
                            color: dataService.authenticated ? .green : .red
                        )

                        StatusIndicator(
                            title: "AI Engine",
                            isActive: !toolsClient.isExecutingTool,
                            color: !toolsClient.isExecutingTool ? .green : .orange
                        )
                    }
                }

                Spacer()

                if dataService.loading || toolsClient.isExecutingTool {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - StatusIndicator

struct StatusIndicator: View {
    let title: String
    let isActive: Bool
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - AIQuickInsightsCard

struct AIQuickInsightsCard: View {
    let recommendations: [AIRecommendation]
    let onViewAll: () -> Void
    let onRecommendationTap: (AIRecommendation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "brain.head.profile.fill")
                        .font(.title3)
                        .foregroundColor(.accentColor)

                    Text("AI Insights")
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                Spacer()

                Button("View All") {
                    onViewAll()
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }

            VStack(spacing: 8) {
                ForEach(Array(recommendations.prefix(2))) { recommendation in
                    CompactRecommendationRow(recommendation: recommendation) {
                        onRecommendationTap(recommendation)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - CompactRecommendationRow

struct CompactRecommendationRow: View {
    let recommendation: AIRecommendation
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            PriorityIndicator(priority: recommendation.priority)

            VStack(alignment: .leading, spacing: 2) {
                Text(recommendation.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(recommendation.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if recommendation.actionRequired {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            Button(action: onTap) {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - PriorityIndicator

struct PriorityIndicator: View {
    let priority: String

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(priorityColor)
            .frame(width: 4, height: 20)
    }

    private var priorityColor: Color {
        switch priority.lowercased() {
        case "critical": .red
        case "high": .orange
        case "medium": .yellow
        default: .blue
        }
    }
}

// MARK: - EnhancedMetricsGrid

struct EnhancedMetricsGrid: View {
    let dashboardData: DashboardData
    let recommendations: [AIRecommendation]

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            EnhancedMetricCard(
                title: "Team Value",
                value: String(format: "$%.1fM", dashboardData.teamValue.teamValue / 1_000_000),
                subtitle: "Total value",
                color: .blue,
                insight: valueInsight
            )

            EnhancedMetricCard(
                title: "Total Score",
                value: "\(dashboardData.teamScore.totalScore)",
                subtitle: "This round",
                color: .green,
                insight: scoreInsight
            )

            EnhancedMetricCard(
                title: "Rank",
                value: "#\(dashboardData.rank.rank)",
                subtitle: "Overall",
                color: .orange,
                insight: rankInsight
            )

            EnhancedMetricCard(
                title: "Captain",
                value: dashboardData.captain.captain?.name ?? "None",
                subtitle: "Current selection",
                color: .purple,
                insight: captainInsight
            )
        }
    }

    private var valueInsight: String? {
        recommendations.first { $0.type.lowercased().contains("cash") }?.title
    }

    private var scoreInsight: String? {
        recommendations.first { $0.type.lowercased().contains("captain") }?.title
    }

    private var rankInsight: String? {
        recommendations.first { $0.type.lowercased().contains("trade") }?.title
    }

    private var captainInsight: String? {
        recommendations.first { $0.type.lowercased().contains("captain") }?.title
    }
}

// MARK: - EnhancedMetricCard

struct EnhancedMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let insight: String?

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)

            if let insight {
                Text(insight)
                    .font(.caption2)
                    .foregroundColor(.accentColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - CaptainInsightsCard

struct CaptainInsightsCard: View {
    let suggestions: [CaptainSuggestionAnalysis]
    let currentCaptain: CaptainData?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Captain Analysis")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                NavigationLink(destination: CaptainAnalysisView()) {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }

            if let current = currentCaptain {
                CurrentCaptainSummary(captain: current)
            }

            VStack(spacing: 8) {
                ForEach(suggestions) { suggestion in
                    CaptainSuggestionSummary(suggestion: suggestion)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - CurrentCaptainSummary

struct CurrentCaptainSummary: View {
    let captain: CaptainData

    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)

            Text("Current: \(captain.playerName)")
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()

            Text("\(captain.score) pts")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.accentColor.opacity(0.2))
                .cornerRadius(4)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - CaptainSuggestionSummary

struct CaptainSuggestionSummary: View {
    let suggestion: CaptainSuggestionAnalysis

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.player)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(suggestion.team)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.0f", suggestion.projectedScore))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)

                Text("\(Int(suggestion.confidence * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - QuickActionsCard

struct QuickActionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionButton(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Trade Analysis",
                    destination: TradeAnalysisView()
                )

                QuickActionButton(
                    icon: "dollarsign.circle",
                    title: "Cash Generation",
                    destination: CashCowTrackerView()
                )

                QuickActionButton(
                    icon: "star.circle",
                    title: "Captain Picks",
                    destination: CaptainAnalysisView()
                )

                QuickActionButton(
                    icon: "brain",
                    title: "AI Insights",
                    destination: AIInsightsView()
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - PerformanceSummaryCard

struct PerformanceSummaryCard: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Summary")
                .font(.headline)
                .fontWeight(.semibold)

            HStack(spacing: 20) {
                PerformanceMetric(
                    title: "Trades Used",
                    value: "\(appState.tradesUsed)/\(appState.tradesUsed + appState.tradesRemaining)",
                    color: .red
                )

                PerformanceMetric(
                    title: "Bank Balance",
                    value: "$\(appState.bankBalance / 1000)k",
                    color: .blue
                )

                PerformanceMetric(
                    title: "Team Value",
                    value: "$\(appState.teamValue / 1_000_000)M",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - PerformanceMetric

struct PerformanceMetric: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - UpdateInfoCard

struct UpdateInfoCard: View {
    @EnvironmentObject private var dataService: AFLFantasyDataService

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Last Updated")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                if dataService.isCacheFresh {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                }
            }

            Text(dataService.lastUpdateDisplayString)
                .font(.subheadline)
                .foregroundColor(.secondary)

            if !dataService.isCacheFresh {
                Text("Data may be stale - pull to refresh")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - ErrorCard

struct ErrorCard: View {
    @EnvironmentObject private var dataService: AFLFantasyDataService

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)

                Text("Error")
                    .font(.headline)
                    .foregroundColor(.red)

                Spacer()

                Button("Dismiss") {
                    dataService.clearError()
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }

            Text(dataService.errorMessage ?? "An unknown error occurred")
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    EnhancedDashboardView()
        .environmentObject(AFLFantasyDataService())
        .environmentObject(AFLFantasyToolsClient())
        .environmentObject(AppState())
}
