//
//  PerformanceDashboardView.swift
//  AFL Fantasy Intelligence Platform
//
//  Comprehensive performance dashboard with real-time monitoring and testing
//  Created by AI Assistant on 6/9/2025.
//

import Charts
import SwiftUI

// MARK: - PerformanceDashboardView

struct PerformanceDashboardView: View {
    @StateObject private var performanceMonitor = PerformanceMonitoringSystem.shared
    @StateObject private var testingSuite = PerformanceTestingSuite.shared
    @StateObject private var memoryManager = MemoryManager.shared
    @StateObject private var networkIntelligence = NetworkIntelligence.shared

    @State private var selectedTab: DashboardTab = .overview
    @State private var showingTestResults = false
    @State private var isRunningTests = false

    enum DashboardTab: CaseIterable {
        case overview, realTime, testing, recommendations

        var title: String {
            switch self {
            case .overview: "Overview"
            case .realTime: "Real-time"
            case .testing: "Testing"
            case .recommendations: "Recommendations"
            }
        }

        var icon: String {
            switch self {
            case .overview: "chart.pie"
            case .realTime: "waveform.path.ecg"
            case .testing: "flask"
            case .recommendations: "lightbulb"
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(DashboardTab.allCases, id: \.self) { tab in
                            TabButton(
                                title: tab.title,
                                icon: tab.icon,
                                isSelected: selectedTab == tab
                            ) {
                                selectedTab = tab
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .background(Color(.systemBackground))

                Divider()

                // Content
                ScrollView {
                    LazyVStack(spacing: 16) {
                        switch selectedTab {
                        case .overview:
                            OverviewSection()
                        case .realTime:
                            RealTimeSection()
                        case .testing:
                            TestingSection()
                        case .recommendations:
                            RecommendationsSection()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Performance")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: startMonitoring) {
                            Label("Start Monitoring", systemImage: "play.circle")
                        }

                        Button(action: stopMonitoring) {
                            Label("Stop Monitoring", systemImage: "stop.circle")
                        }

                        Divider()

                        Button(action: runPerformanceTests) {
                            Label("Run Full Test Suite", systemImage: "flask")
                        }

                        Button(action: exportResults) {
                            Label("Export Results", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingTestResults) {
            TestResultsView()
        }
    }

    // MARK: - Overview Section

    @ViewBuilder
    private func OverviewSection() -> some View {
        // Overall Performance Score
        PerformanceScoreCard()

        // Quick Stats Grid
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            QuickStatCard(
                title: "Frame Rate",
                value: String(format: "%.0f FPS", performanceMonitor.currentPerformance.frameMetrics.averageFPS),
                icon: "speedometer",
                color: frameRateColor
            )

            QuickStatCard(
                title: "Memory",
                value: memoryManager.currentMemoryUsage.formattedUsage,
                icon: "memorychip",
                color: memoryManager.memoryPressureLevel.color
            )

            QuickStatCard(
                title: "Network",
                value: networkIntelligence.networkMetrics.dataUsage.formattedTotal,
                icon: "network",
                color: networkStatusColor
            )

            QuickStatCard(
                title: "Battery",
                value: String(format: "%.0fmW", performanceMonitor.currentPerformance.batteryMetrics.powerDrawMW),
                icon: "battery.100",
                color: batteryImpactColor
            )
        }

        // Device Profile Card
        DeviceProfileCard()

        // Recent Benchmark Results
        if testingSuite.benchmarkResults.lastRunDate != nil {
            BenchmarkResultsCard()
        }
    }

    // MARK: - Real-time Section

    @ViewBuilder
    private func RealTimeSection() -> some View {
        // Performance Metrics Chart
        PerformanceChartsView()

        // Memory Stats View
        MemoryStatsView()

        // Network Status View
        NetworkStatusView()

        // Current Optimization Tips
        if !performanceMonitor.optimizationRecommendations.isEmpty {
            OptimizationTipsCard()
        }
    }

    // MARK: - Testing Section

    @ViewBuilder
    private func TestingSection() -> some View {
        // Test Suite Controls
        TestSuiteControlsCard()

        // Test Progress
        if testingSuite.isTestingInProgress {
            TestProgressCard()
        }

        // Recent Test Results
        if !testingSuite.testResults.isEmpty {
            TestResultsSummaryCard()
        }

        // Benchmark History
        BenchmarkHistoryCard()
    }

    // MARK: - Recommendations Section

    @ViewBuilder
    private func RecommendationsSection() -> some View {
        // Performance Recommendations
        if !performanceMonitor.optimizationRecommendations.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("Performance Recommendations")
                    .font(.headline)
                    .padding(.horizontal, 4)

                ForEach(performanceMonitor.optimizationRecommendations, id: \.id) { recommendation in
                    RecommendationCard(recommendation: recommendation)
                }
            }
        } else {
            EmptyRecommendationsView()
        }

        // Performance Tips
        PerformanceTipsCard()
    }

    // MARK: - Component Views

    private func PerformanceScoreCard() -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Overall Performance")
                        .font(.headline)

                    Text(performanceMonitor.currentPerformance.overallScore.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                            .frame(width: 80, height: 80)

                        Circle()
                            .trim(from: 0, to: Double(performanceMonitor.currentPerformance.overallScore.score) / 100)
                            .stroke(
                                performanceMonitor.currentPerformance.overallScore.color,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))

                        Text("\(performanceMonitor.currentPerformance.overallScore.score)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(performanceMonitor.currentPerformance.overallScore.color)
                    }

                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Thermal State Indicator
            HStack {
                Image(systemName: "thermometer")
                    .foregroundColor(performanceMonitor.currentPerformance.thermalState.color)

                Text("Thermal State: \(performanceMonitor.currentPerformance.thermalState.description)")
                    .font(.subheadline)
                    .foregroundColor(performanceMonitor.currentPerformance.thermalState.color)

                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func QuickStatCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)

                Spacer()
            }

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(1)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }

    private func DeviceProfileCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Device Profile")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Model", value: testingSuite.deviceProfile.modelName)
                InfoRow(label: "iOS Version", value: testingSuite.deviceProfile.osVersion)
                InfoRow(label: "Memory", value: "\(testingSuite.deviceProfile.totalMemory / 1024 / 1024 / 1024)GB")
                InfoRow(
                    label: "Screen Size",
                    value: "\(Int(testingSuite.deviceProfile.screenSize.width))×\(Int(testingSuite.deviceProfile.screenSize.height))"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func BenchmarkResultsCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Latest Benchmark")
                    .font(.headline)

                Spacer()

                Text(testingSuite.benchmarkResults.grade)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(testingSuite.benchmarkResults.color)
            }

            HStack(spacing: 16) {
                VStack {
                    Text("\(testingSuite.benchmarkResults.overallScore)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(testingSuite.benchmarkResults.color)

                    Text("Overall")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    ScoreRow(label: "Performance", score: testingSuite.benchmarkResults.performanceScore)
                    ScoreRow(label: "Memory", score: testingSuite.benchmarkResults.memoryScore)
                    ScoreRow(label: "Network", score: testingSuite.benchmarkResults.networkScore)
                    ScoreRow(label: "UI", score: testingSuite.benchmarkResults.uiScore)
                }
                .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func TestSuiteControlsCard() -> some View {
        VStack(spacing: 16) {
            Text("Performance Testing")
                .font(.headline)

            Button(action: runPerformanceTests) {
                HStack {
                    Image(systemName: isRunningTests ? "stop.circle" : "flask")
                    Text(isRunningTests ? "Stop Tests" : "Run Full Test Suite")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isRunningTests ? Color.red : Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(testingSuite.isTestingInProgress && !isRunningTests)

            if !testingSuite.testResults.isEmpty {
                Button("View Detailed Results") {
                    showingTestResults = true
                }
                .foregroundColor(.accentColor)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func TestProgressCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Test Progress")
                .font(.headline)

            ProgressView(value: testingSuite.testProgress)
                .tint(.accentColor)

            Text("\(Int(testingSuite.testProgress * 100))% Complete")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func TestResultsSummaryCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Test Results")
                    .font(.headline)

                Spacer()

                Text("\(testingSuite.testResults.count) tests")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            let passedCount = testingSuite.testResults.filter { $0.status == .passed }.count
            let warningCount = testingSuite.testResults.filter { $0.status == .warning }.count
            let failedCount = testingSuite.testResults.filter { $0.status == .failed }.count

            HStack(spacing: 20) {
                TestStatusCount(count: passedCount, status: "Passed", color: .green)
                TestStatusCount(count: warningCount, status: "Warning", color: .orange)
                TestStatusCount(count: failedCount, status: "Failed", color: .red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func RecommendationCard(recommendation: PerformanceMonitoringSystem
        .OptimizationRecommendation
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: recommendation.category.icon)
                    .foregroundColor(recommendation.impact.color)

                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.title)
                        .font(.headline)
                        .lineLimit(1)

                    Text(recommendation.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(recommendation.estimatedImprovement)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)

                    if let action = recommendation.action {
                        Button("Apply") {
                            action()
                        }
                        .font(.caption)
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func PerformanceTipsCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Tips")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                TipRow(icon: "speedometer", tip: "Keep frame rate above 55 FPS for smooth experience")
                TipRow(icon: "memorychip", tip: "Monitor memory usage to prevent crashes")
                TipRow(icon: "network", tip: "Use offline capabilities when network is poor")
                TipRow(icon: "battery.100", tip: "Enable power saving when battery is low")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    // MARK: - Helper Views

    private func InfoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }

    private func ScoreRow(label: String, score: Int) -> some View {
        HStack {
            Text(label)
            Text("\(score)")
                .fontWeight(.medium)
        }
    }

    private func TestStatusCount(count: Int, status: String, color: Color) -> some View {
        VStack {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(status)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func TipRow(icon: String, tip: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 16)

            Text(tip)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private func EmptyRecommendationsView() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 50))
                .foregroundColor(.green)

            Text("Great Performance!")
                .font(.headline)

            Text("No performance issues detected. Your app is running optimally.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    // MARK: - Computed Properties

    private var frameRateColor: Color {
        let fps = performanceMonitor.currentPerformance.frameMetrics.averageFPS
        if fps >= 58 { return .green }
        else if fps >= 55 { return .orange }
        else { return .red }
    }

    private var networkStatusColor: Color {
        switch networkIntelligence.connectionStatus {
        case .wifi, .ethernet: .green
        case .cellular: .orange
        case .offline: .red
        case .unknown: .gray
        }
    }

    private var batteryImpactColor: Color {
        let impact = performanceMonitor.currentPerformance.batteryMetrics.energyImpact
        switch impact {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }

    // MARK: - Actions

    private func startMonitoring() {
        performanceMonitor.startMonitoring()
    }

    private func stopMonitoring() {
        performanceMonitor.stopMonitoring()
    }

    private func runPerformanceTests() {
        isRunningTests = true
        Task {
            await testingSuite.runFullTestSuite()
            await MainActor.run {
                isRunningTests = false
            }
        }
    }

    private func exportResults() {
        // Export performance data
        print("📤 Exporting performance results...")
    }
}

// MARK: - TabButton

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)

                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .accentColor : .secondary)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - TestResultsView

struct TestResultsView: View {
    @StateObject private var testingSuite = PerformanceTestingSuite.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(testingSuite.testResults, id: \.id) { result in
                    TestResultRow(result: result)
                }
            }
            .navigationTitle("Test Results")
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

// MARK: - TestResultRow

struct TestResultRow: View {
    let result: PerformanceTestingSuite.TestResult

    var body: some View {
        HStack {
            Image(systemName: result.category.icon)
                .foregroundColor(result.status.color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(result.name)
                    .font(.headline)

                Text("Duration: \(String(format: "%.2fs", result.duration))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let frameRate = result.metrics.frameRate {
                    Text("Frame Rate: \(String(format: "%.0f FPS", frameRate))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing) {
                Circle()
                    .fill(result.status.color)
                    .frame(width: 12, height: 12)

                Text(result.deviceInfo)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - PerformanceDashboardView_Previews

struct PerformanceDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        PerformanceDashboardView()
    }
}
