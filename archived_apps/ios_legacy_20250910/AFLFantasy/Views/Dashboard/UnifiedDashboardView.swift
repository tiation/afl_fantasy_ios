//
//  UnifiedDashboardView.swift
//  AFL Fantasy Intelligence Platform
//
//  🏆 Consolidated Dashboard - The Ultimate Coaching Advantage
//  Combines best features from DashboardView, DashboardDemoView, and ComprehensiveDashboardView
//  with iOS HIG compliance, accessibility, and performance optimizations
//  Created by AI Assistant on 8/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI
import UIKit

// MARK: - UnifiedDashboardView

struct UnifiedDashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var dashboardService = DashboardService()
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var hapticsManager: AFLHapticsManager
    
    @State private var selectedTimeframe: Timeframe = .week
    @State private var selectedInsight: InsightType = .performance
    @State private var showingTeamAnalysis = false
    @State private var showingPlayerDetail: EnhancedPlayer?
    @State private var isRefreshing = false
    
    // MARK: - Enums
    
    enum Timeframe: String, CaseIterable {
        case week = "This Week"
        case month = "This Month" 
        case season = "Season"
        case projected = "Projected"
        
        var icon: String {
            switch self {
            case .week: return "calendar"
            case .month: return "calendar.badge.plus"
            case .season: return "chart.line.uptrend.xyaxis"
            case .projected: return "crystal.ball"
            }
        }
    }
    
    enum InsightType: String, CaseIterable {
        case performance = "Performance"
        case trades = "Trades"
        case injuries = "Injuries"
        case value = "Value"
        
        var icon: String {
            switch self {
            case .performance: return "chart.bar.fill"
            case .trades: return "arrow.triangle.2.circlepath"
            case .injuries: return "cross.case.fill"
            case .value: return "dollarsign.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .performance: return .blue
            case .trades: return .orange
            case .injuries: return .red
            case .value: return .green
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.hasError {
                    errorStateView
                } else if dashboardService.isLoading && dashboardService.dashboard == nil {
                    loadingStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: DS.Spacing.l) {
                            // Live Performance Header
                            livePerformanceHeader
                            
                            // Timeframe Selector
                            timeframeSelectorView
                            
                            // Quick Stats Grid
                            quickStatsGrid
                            
                            // AI Insights Section
                            aiInsightsSection
                            
                            // Team Composition & Analysis
                            if let dashboard = dashboardService.dashboard {
                                teamCompositionSection(dashboard: dashboard)
                            }
                            
                            // Critical Alerts
                            criticalAlertsSection
                            
                            // Performance Indicators
                            performanceIndicatorSection
                        }
                        .padding(DS.Spacing.m)
                        .opacity(isRefreshing ? 0.7 : 1.0)
                    }
                    .refreshable {
                        await performRefresh()
                    }
                }
            }
            .navigationTitle("🏆 Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Refresh button
                    Button(action: {
                        Task { await performRefresh() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(isRefreshing ? .degrees(360) : .degrees(0))
                            .animation(
                                isRefreshing ? .linear(duration: 1).repeatForever(autoreverses: false) : DS.Motion.standard,
                                value: isRefreshing
                            )
                    }
                    .disabled(isRefreshing)
                    .accessibilityLabel("Refresh dashboard")
                    
                    // Insights menu
                    Menu {
                        ForEach(InsightType.allCases, id: \.rawValue) { insight in
                            Button {
                                selectedInsight = insight
                                hapticsManager.onPositionSelect()
                            } label: {
                                Label(insight.rawValue, systemImage: insight.icon)
                            }
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .accessibilityLabel("Select insights")
                }
            }
            .overlay {
                if isRefreshing && !viewModel.hasError {
                    VStack(spacing: DS.Spacing.s) {
                        AFLLoadingAnimation()
                        Text("Updating...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
                }
            }
        }
        .sheet(item: $showingPlayerDetail) { player in
            PlayerDetailView(player: player)
        }
        .task {
            await performRefresh()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("AFL Fantasy Dashboard")
    }
    
    // MARK: - Live Performance Header
    
    private var livePerformanceHeader: some View {
        VStack(spacing: DS.Spacing.m) {
            HStack(alignment: .top) {
                // Live indicator and score
                VStack(alignment: .leading, spacing: DS.Spacing.s) {
                    HStack(spacing: DS.Spacing.s) {
                        Circle()
                            .fill(viewModel.isLive ? .green : .secondary)
                            .frame(width: 8, height: 8)
                            .accessibilityHidden(true)
                        
                        Text("LIVE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.isLive ? .green : .secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(viewModel.isLive ? "Live scores updating" : "Scores not live")
                    
                    Text("Team Score")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(viewModel.currentScore)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("pts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Current team score: \(viewModel.currentScore) points")
                    
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.scoreChange >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                            .foregroundColor(viewModel.scoreChange >= 0 ? .green : .red)
                        
                        Text("\(abs(viewModel.scoreChange)) from last week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("Score change: \(abs(viewModel.scoreChange)) points \(viewModel.scoreChange >= 0 ? "up" : "down") from last week")
                }
                
                Spacer()
                
                // Rank section
                VStack(alignment: .trailing, spacing: DS.Spacing.s) {
                    Text("Rank")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("#\(formatRank(viewModel.currentRank))")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.rankChange <= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                            .foregroundColor(viewModel.rankChange <= 0 ? .green : .red)
                        
                        Text("\(abs(viewModel.rankChange))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("Rank change: \(abs(viewModel.rankChange)) positions \(viewModel.rankChange <= 0 ? "up" : "down")")
                }
            }
            
            // Projected Performance Bar
            VStack(alignment: .leading, spacing: DS.Spacing.s) {
                HStack {
                    Text("Projected This Round")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.projectedScore)) pts")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                ProgressView(value: viewModel.projectedScore, total: 2400)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(y: 2)
                    .accessibilityLabel("Projected score: \(Int(viewModel.projectedScore)) out of 2400 points")
            }
        }
        .padding(DS.Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.card)
                .fill(.ultraThinMaterial)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Live performance summary")
    }
    
    // MARK: - Timeframe Selector
    
    private var timeframeSelectorView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.s) {
                ForEach(Timeframe.allCases, id: \.rawValue) { timeframe in
                    Button {
                        selectedTimeframe = timeframe
                        hapticsManager.onPositionSelect()
                    } label: {
                        HStack(spacing: DS.Spacing.s) {
                            Image(systemName: timeframe.icon)
                                .font(.caption)
                            
                            Text(timeframe.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, DS.Spacing.m)
                        .padding(.vertical, DS.Spacing.s)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedTimeframe == timeframe ? Color.accentColor : Color(.systemGray5))
                        )
                        .foregroundColor(selectedTimeframe == timeframe ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Select \(timeframe.rawValue) timeframe")
                }
            }
            .padding(.horizontal, DS.Spacing.m)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Timeframe selector")
    }
    
    // MARK: - Quick Stats Grid
    
    private var quickStatsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.m), count: 2), spacing: DS.Spacing.m) {
            StatCard(
                title: "Team Value",
                value: viewModel.teamValue,
                subtitle: "Bank: \(viewModel.bankBalance)",
                icon: "creditcard.fill",
                color: .green
            )
            
            StatCard(
                title: "Trades Left",
                value: "\(viewModel.tradesRemaining)",
                subtitle: "Used: \(viewModel.tradesUsed)",
                icon: "arrow.triangle.2.circlepath",
                color: .blue
            )
            
            StatCard(
                title: "Cash Cows",
                value: "\(viewModel.cashCowCount)",
                subtitle: "\(viewModel.cashGenerationRate)/wk avg",
                icon: "dollarsign.circle.fill",
                color: .orange
            )
            
            StatCard(
                title: "Risk Level", 
                value: viewModel.riskLevel.displayName.replacingOccurrences(of: " Risk", with: ""),
                subtitle: "Overall exposure",
                icon: viewModel.riskLevel.icon,
                color: viewModel.riskLevel.color
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Team statistics")
    }
    
    // MARK: - AI Insights Section
    
    private var aiInsightsSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            HStack {
                Label("AI Insights", systemImage: "brain.head.profile")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
            }
            
            ForEach(viewModel.aiInsights.prefix(3), id: \.id) { insight in
                HStack(alignment: .top, spacing: DS.Spacing.m) {
                    Image(systemName: insight.icon)
                        .font(.title3)
                        .foregroundColor(insight.color)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(insight.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(insight.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer(minLength: 0)
                }
                .padding(.vertical, DS.Spacing.s)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(insight.title): \(insight.description)")
                
                if insight != viewModel.aiInsights.prefix(3).last {
                    Divider()
                }
            }
        }
        .padding(DS.Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.card)
                .fill(.ultraThinMaterial)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("AI insights and recommendations")
    }
    
    // MARK: - Team Composition Section
    
    private func teamCompositionSection(dashboard: DashboardResponse) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            Text("Team Composition")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: DS.Spacing.s) {
                HStack {
                    Text("Current:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(formatCurrency(dashboard.teamValue.current))
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Bank:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(formatCurrency(dashboard.teamValue.bank))
                        .fontWeight(.semibold)
                }
                
                Divider()
                
                HStack {
                    Text("Total:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(formatCurrency(dashboard.teamValue.total))
                        .fontWeight(.bold)
                        .font(.title3)
                }
            }
        }
        .padding(DS.Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.card)
                .fill(.ultraThinMaterial)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Team composition and value breakdown")
    }
    
    // MARK: - Critical Alerts Section
    
    private var criticalAlertsSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            Label("Critical Alerts", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.red)
            
            if viewModel.criticalAlerts.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Text("No critical alerts")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .accessibilityLabel("No critical alerts currently")
            } else {
                ForEach(viewModel.criticalAlerts.prefix(3), id: \.id) { alert in
                    HStack(alignment: .top, spacing: DS.Spacing.m) {
                        Image(systemName: alert.icon)
                            .font(.title3)
                            .foregroundColor(alert.severity.color)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(alert.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text(alert.message)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, DS.Spacing.s)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(alert.severity.rawValue) alert: \(alert.title), \(alert.message)")
                    
                    if alert != viewModel.criticalAlerts.prefix(3).last {
                        Divider()
                    }
                }
            }
        }
        .padding(DS.Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.card)
                .fill(.ultraThinMaterial)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Critical alerts section")
    }
    
    // MARK: - Performance Indicator Section
    
    private var performanceIndicatorSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            Text("Performance Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Team Performance")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(performanceDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: DS.Spacing.m) {
                    PerformanceBar(value: performanceScore, color: performanceColor, label: "Overall")
                    PerformanceBar(value: consistencyScore, color: .blue, label: "Consistency")
                }
            }
        }
        .padding(DS.Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.card)
                .fill(.ultraThinMaterial)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Performance overview with overall score and consistency metrics")
    }
    
    // MARK: - Supporting Views
    
    private var errorStateView: some View {
        VStack(spacing: DS.Spacing.l) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Unable to Load Dashboard")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Please check your connection and try again.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Spacing.l)
            
            Button("Try Again") {
                Task { await performRefresh() }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DS.Spacing.l)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error loading dashboard. Try again button available.")
    }
    
    private var loadingStateView: some View {
        VStack(spacing: DS.Spacing.l) {
            AFLLoadingAnimation()
            
            Text("Loading Dashboard...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DS.Spacing.l)
        .accessibilityLabel("Loading dashboard data")
    }
    
    // MARK: - Helper Methods
    
    @MainActor
    private func performRefresh() async {
        isRefreshing = true
        hapticsManager.onPositionSelect()
        
        async let viewModelRefresh = viewModel.refresh()
        async let serviceRefresh = refreshDashboardService()
        
        await viewModelRefresh
        await serviceRefresh
        
        // Small delay for smooth animation
        try? await Task.sleep(nanoseconds: 300_000_000)
        isRefreshing = false
    }
    
    @MainActor
    private func refreshDashboardService() async {
        do {
            _ = try await dashboardService.getDashboard(forceRefresh: true)
                .singleOutput()
        } catch {
            print("Dashboard service refresh failed: \(error)")
        }
    }
    
    private func formatRank(_ rank: Int) -> String {
        if rank < 1000 { return "\(rank)" }
        return "\(Double(rank) / 1000, specifier: "%.1f")k"
    }
    
    private func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
    
    private var performanceScore: Double {
        let avgScore = appState.players.isEmpty ? 0 : appState.players
            .reduce(0) { $0 + $1.averageScore } / Double(appState.players.count)
        return min(avgScore / 120.0, 1.0) // Normalize to 0-1 scale
    }
    
    private var consistencyScore: Double {
        let avgConsistency = appState.players.isEmpty ? 0 : appState.players
            .reduce(0) { $0 + $1.consistency } / Double(appState.players.count)
        return avgConsistency / 100.0
    }
    
    private var performanceColor: Color {
        switch performanceScore {
        case 0.8...: .green
        case 0.6 ..< 0.8: .blue
        case 0.4 ..< 0.6: .orange
        default: .red
        }
    }
    
    private var performanceDescription: String {
        switch performanceScore {
        case 0.8...: "Excellent team performance"
        case 0.6 ..< 0.8: "Strong team performance"
        case 0.4 ..< 0.6: "Average team performance"
        default: "Room for improvement"
        }
    }
}

// MARK: - StatCard

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(DS.Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.card)
                .fill(.ultraThinMaterial)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value), \(subtitle)")
    }
}

// MARK: - PerformanceBar

struct PerformanceBar: View {
    let value: Double
    let color: Color
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Circle()
                .trim(from: 0, to: value)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 40, height: 40)
                .overlay(
                    Text("\(Int(value * 100))")
                        .font(.caption2)
                        .fontWeight(.bold)
                )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(Int(value * 100)) percent")
    }
}

// MARK: - Design System Extensions

private enum DS {
    enum Spacing {
        static let s: CGFloat = 8
        static let m: CGFloat = 16
        static let l: CGFloat = 24
    }
    
    enum Radius {
        static let card: CGFloat = 12
    }
    
    enum Motion {
        static let standard = Animation.easeInOut(duration: 0.2)
    }
}

// MARK: - Combine Extension

extension Publisher {
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

#Preview {
    UnifiedDashboardView()
        .environmentObject(AppState())
        .environmentObject(AFLHapticsManager.shared)
}
