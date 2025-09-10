//
//  CoreIntelligenceDashboardView.swift
//  AFL Fantasy Intelligence Platform
//
//  🏈 Core Intelligence Dashboard - The Ultimate Coaching Advantage
//  Transform raw data into actionable winning strategies with Docker scraper integration
//  Created by AI Assistant on 6/9/2025.
//

import Charts
import SwiftUI

// MARK: - CoreIntelligenceDashboardView

struct CoreIntelligenceDashboardView: View {
    @StateObject private var scraperService = DockerScraperService()
    @StateObject private var viewModel = DashboardViewModel()
    @State private var selectedTimeframe: DashboardTimeframe = .thisWeek
    @State private var showingTeamStructureAnalysis = false
    @State private var showingAlertCenter = false
    @State private var refreshTask: Task<Void, Never>?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Connection Status Banner
                    connectionStatusBanner
                    
                    // Live Performance Tracking
                    livePerformanceSection
                    
                    // Team Structure Analysis
                    teamStructureSection
                    
                    // Weekly Projection Summary
                    weeklyProjectionSection
                    
                    // AI Insights Quick Access
                    aiToolsQuickAccess
                    
                    // Critical Alerts Summary
                    criticalAlertsSection
                    
                    // Performance Metrics Grid
                    performanceMetricsGrid
                }
                .padding()
            }
            .navigationTitle("🧠 Intelligence Hub")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("🔄 Refresh Data") {
                            refreshAllData()
                        }
                        
                        Button("⚙️ Scraper Settings") {
                            // Open scraper configuration
                        }
                        
                        Button("📊 Export Data") {
                            // Export functionality
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .refreshable {
                await refreshData()
            }
            .sheet(isPresented: $showingTeamStructureAnalysis) {
                TeamStructureAnalysisView()
            }
            .sheet(isPresented: $showingAlertCenter) {
                AlertCenterView()
            }
        }
        .onAppear {
            refreshAllData()
        }
        .onDisappear {
            refreshTask?.cancel()
        }
    }
    
    // MARK: - Connection Status Banner
    
    @ViewBuilder
    private var connectionStatusBanner: some View {
        if !scraperService.isConnected {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Docker Scraper Offline")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("Some features may be limited")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Retry") {
                    refreshAllData()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding()
            .background(.orange.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Live Performance Tracking
    
    private var livePerformanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Live Performance Tracking", systemImage: "waveform.path.ecg")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(scraperService.isConnected ? .green : .red)
                        .frame(width: 8, height: 8)
                    
                    Text(scraperService.isConnected ? "LIVE" : "OFFLINE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                IntelligencePerformanceCard(
                    title: "Current Score",
                    value: "\(viewModel.currentScore)",
                    change: viewModel.scoreChange,
                    icon: "target",
                    color: .blue
                )
                
                IntelligencePerformanceCard(
                    title: "Weekly Rank",
                    value: "#\(viewModel.currentRank)",
                    change: -viewModel.rankChange, // Negative because lower rank is better
                    icon: "chart.line.uptrend.xyaxis",
                    color: .orange
                )
                
                IntelligencePerformanceCard(
                    title: "Projected",
                    value: "\(Int(viewModel.projectedScore))",
                    change: 0, // No change for projection
                    icon: "crystal.ball",
                    color: .purple
                )
            }
            
            // Real-time score progression chart
            LiveScoreProgressChart(data: viewModel.scoreProgression)
                .frame(height: 120)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    // MARK: - Team Structure Analysis
    
    private var teamStructureSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Team Structure Analysis", systemImage: "chart.pie")
                    .font(.headline)
                
                Spacer()
                
                Button("View Details") {
                    showingTeamStructureAnalysis = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            
            // Salary cap distribution visualization
            SalaryCapDistributionView(
                defenders: viewModel.defendersValue,
                midfielders: viewModel.midfieldersValue,
                rucks: viewModel.rucksValue,
                forwards: viewModel.forwardsValue
            )
            .frame(height: 100)
            
            // Position balance indicators
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                PositionBalanceIndicator(position: "DEF", grade: viewModel.defenderGrade, count: 6)
                PositionBalanceIndicator(position: "MID", grade: viewModel.midfielderGrade, count: 8)
                PositionBalanceIndicator(position: "RUC", grade: viewModel.ruckGrade, count: 2)
                PositionBalanceIndicator(position: "FWD", grade: viewModel.forwardGrade, count: 6)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    // MARK: - Weekly Projection Summary
    
    private var weeklyProjectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Weekly Projection Summary", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Expected Wins")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(viewModel.expectedWins)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Key Matchups")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(viewModel.keyMatchups)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Confidence")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(viewModel.projectionConfidence * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            
            // Weekly projection chart
            WeeklyProjectionChart(projections: viewModel.weeklyProjections)
                .frame(height: 80)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    // MARK: - AI Tools Quick Access
    
    private var aiToolsQuickAccess: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("AI-Powered Tools", systemImage: "brain")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                NavigationLink(destination: CaptainAdvisorView()) {
                    AIToolCard(
                        title: "Captain Advisor",
                        description: "AI-optimized captaincy",
                        icon: "crown.fill",
                        color: .yellow,
                        confidence: viewModel.captainConfidence
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: TradeAnalysisView()) {
                    AIToolCard(
                        title: "Trade Suggester",
                        description: "ML-powered trades",
                        icon: "arrow.triangle.2.circlepath",
                        color: .blue,
                        confidence: viewModel.tradeConfidence
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: TeamStructureAnalyzer()) {
                    AIToolCard(
                        title: "Structure Analyzer",
                        description: "Optimize your team",
                        icon: "chart.pie.fill",
                        color: .green,
                        confidence: viewModel.structureHealth
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: AlertCenterView()) {
                    AIToolCard(
                        title: "Alert Center",
                        description: "\(viewModel.activeAlerts) active",
                        icon: "bell.badge.fill",
                        color: .red,
                        confidence: nil
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    // MARK: - Critical Alerts Section
    
    @ViewBuilder
    private var criticalAlertsSection: some View {
        if !viewModel.criticalAlerts.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Critical Alerts", systemImage: "exclamationmark.triangle.fill")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    Button("View All") {
                        showingAlertCenter = true
                    }
                    .font(.caption)
                }
                
                ForEach(viewModel.criticalAlerts.prefix(3), id: \.id) { alert in
                    CriticalAlertRow(alert: alert)
                }
            }
            .padding()
            .background(.red.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.red.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Performance Metrics Grid
    
    private var performanceMetricsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Performance Metrics", systemImage: "speedometer")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                IntelligenceMetricCard(
                    title: "Team Value",
                    value: viewModel.teamValue,
                    subtitle: "Bank: \(viewModel.bankBalance)",
                    trend: .positive,
                    icon: "creditcard.fill"
                )
                
                IntelligenceMetricCard(
                    title: "Trades Remaining",
                    value: "\(viewModel.tradesRemaining)",
                    subtitle: "Used: \(viewModel.tradesUsed)",
                    trend: .neutral,
                    icon: "arrow.triangle.2.circlepath"
                )
                
                IntelligenceMetricCard(
                    title: "Consistency",
                    value: "\(Int(viewModel.teamConsistency))%",
                    subtitle: "vs League Avg",
                    trend: viewModel.consistencyTrend,
                    icon: "chart.line.flattrend.xyaxis"
                )
                
                IntelligenceMetricCard(
                    title: "Value Efficiency",
                    value: "\(String(format: "%.2f", viewModel.valueEfficiency))",
                    subtitle: "Points per $1k",
                    trend: viewModel.efficiencyTrend,
                    icon: "target"
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    // MARK: - Helper Methods
    
    private func refreshAllData() {
        refreshTask?.cancel()
        refreshTask = Task {
            await refreshData()
        }
    }
    
    private func refreshData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await viewModel.refresh()
            }
            
            if scraperService.isConnected {
                group.addTask {
                    do {
                        // Fetch fresh data from Docker scraper
                        let _ = try await scraperService.fetchAllPlayers()
                        let _ = try await scraperService.fetchLiveScores()
                    } catch {
                        print("Failed to refresh scraper data: \(error)")
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct IntelligencePerformanceCard: View {
    let title: String
    let value: String
    let change: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if change != 0 {
                HStack(spacing: 2) {
                    Image(systemName: change > 0 ? "arrow.up" : "arrow.down")
                        .font(.caption2)
                    
                    Text("\(abs(change))")
                        .font(.caption2)
                }
                .foregroundColor(change > 0 ? .green : .red)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct IntelligenceMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let trend: MetricTrend
    let icon: String
    
    enum MetricTrend {
        case positive, negative, neutral
        
        var color: Color {
            switch self {
            case .positive: return .green
            case .negative: return .red
            case .neutral: return .gray
            }
        }
        
        var icon: String {
            switch self {
            case .positive: return "arrow.up.circle.fill"
            case .negative: return "arrow.down.circle.fill"
            case .neutral: return "minus.circle.fill"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Image(systemName: trend.icon)
                    .font(.caption)
                    .foregroundColor(trend.color)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .frame(height: 120)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct AIToolCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let confidence: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
                
                if let confidence = confidence {
                    Text("\(Int(confidence * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(color)
                }
            }
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Spacer()
        }
        .padding()
        .frame(height: 100)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct CriticalAlertRow: View {
    let alert: CriticalAlert
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: alert.icon)
                .foregroundColor(.red)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(alert.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(alert.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(alert.timeAgo)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Chart Views

struct LiveScoreProgressChart: View {
    let data: [ScoreDataPoint]
    
    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Time", point.timestamp),
                y: .value("Score", point.score)
            )
            .foregroundStyle(.blue.gradient)
            .lineStyle(StrokeStyle(lineWidth: 2))
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                AxisTick()
                AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .omitted)))
            }
        }
    }
}

struct WeeklyProjectionChart: View {
    let projections: [WeeklyProjection]
    
    var body: some View {
        Chart(projections) { projection in
            BarMark(
                x: .value("Week", projection.week),
                y: .value("Projection", projection.projectedScore)
            )
            .foregroundStyle(.blue.opacity(0.7))
        }
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5))
        }
    }
}

struct SalaryCapDistributionView: View {
    let defenders: String
    let midfielders: String
    let rucks: String
    let forwards: String
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(.blue)
                .frame(width: 60)
            
            Rectangle()
                .fill(.green)
                .frame(width: 120)
            
            Rectangle()
                .fill(.orange)
                .frame(width: 40)
            
            Rectangle()
                .fill(.red)
                .frame(width: 100)
        }
        .cornerRadius(8)
        .overlay(
            HStack {
                Text("DEF")
                Spacer()
                Text("MID")
                Spacer()
                Text("RUC")
                Spacer()
                Text("FWD")
            }
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
        )
    }
}

struct PositionBalanceIndicator: View {
    let position: String
    let grade: String
    let count: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text(position)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(grade)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(gradeColor)
            
            Text("\(count) players")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
    }
    
    private var gradeColor: Color {
        switch grade {
        case "A+", "A": .green
        case "B+", "B": .blue
        case "C+", "C": .orange
        default: .red
        }
    }
}

// MARK: - Preview

#Preview {
    CoreIntelligenceDashboardView()
}
