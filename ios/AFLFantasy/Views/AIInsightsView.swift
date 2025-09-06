//
//  AIInsightsView.swift
//  AFL Fantasy Intelligence Platform
//
//  AI-powered insights and recommendations
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - AIInsightsView

struct AIInsightsView: View {
    // MARK: - Environment

    @EnvironmentObject private var toolsClient: AFLFantasyToolsClient

    // MARK: - State

    @State private var recommendations: [AIRecommendation] = []
    @State private var weeklyInsights: [AIRecommendation] = []
    @State private var selectedCategory: String? = nil
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedRecommendation: AIRecommendation?
    @State private var showingRecommendationDetail = false
    @State private var selectedTab: InsightsTab = .recommendations

    // MARK: - Body

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // AI Status Header
                AIStatusHeader()

                // Tab selector
                InsightsTabSelector(selectedTab: $selectedTab)

                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    // Recommendations Tab
                    RecommendationsTab(
                        recommendations: recommendations,
                        isLoading: isLoading,
                        selectedCategory: $selectedCategory,
                        onRefresh: loadRecommendations,
                        onRecommendationTap: { recommendation in
                            selectedRecommendation = recommendation
                            showingRecommendationDetail = true
                        }
                    )
                    .tag(InsightsTab.recommendations)

                    // Weekly Insights Tab
                    WeeklyInsightsTab(
                        insights: weeklyInsights,
                        isLoading: isLoading,
                        onRefresh: loadWeeklyInsights,
                        onInsightTap: { insight in
                            selectedRecommendation = insight
                            showingRecommendationDetail = true
                        }
                    )
                    .tag(InsightsTab.weekly)

                    // AI Analytics Tab
                    AIAnalyticsTab()
                        .tag(InsightsTab.analytics)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("AI Insights")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Refresh All") {
                            refreshAllData()
                        }

                        Button("AI Settings") {
                            // AI settings
                        }
                    } label: {
                        Image(systemName: "brain")
                    }
                }
            }
        }
        .sheet(isPresented: $showingRecommendationDetail) {
            if let recommendation = selectedRecommendation {
                RecommendationDetailView(recommendation: recommendation)
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear {
            loadRecommendations()
            loadWeeklyInsights()
        }
    }

    // MARK: - Methods

    private func loadRecommendations() {
        isLoading = true
        errorMessage = nil

        Task {
            let result = await toolsClient.getAIRecommendations(category: selectedCategory)

            await MainActor.run {
                isLoading = false

                switch result {
                case let .success(recs):
                    recommendations = recs
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func loadWeeklyInsights() {
        Task {
            let result = await toolsClient.getWeeklyInsights()

            await MainActor.run {
                switch result {
                case let .success(insights):
                    weeklyInsights = insights
                case .failure:
                    // Fail silently for weekly insights
                    break
                }
            }
        }
    }

    private func refreshAllData() {
        loadRecommendations()
        loadWeeklyInsights()
    }
}

// MARK: - InsightsTab

enum InsightsTab: String, CaseIterable {
    case recommendations = "Recommendations"
    case weekly = "Weekly"
    case analytics = "Analytics"

    var systemImage: String {
        switch self {
        case .recommendations: "lightbulb.fill"
        case .weekly: "calendar"
        case .analytics: "chart.bar.fill"
        }
    }
}

// MARK: - AIStatusHeader

struct AIStatusHeader: View {
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)

                Text("AI Engine Active")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Spacer()

            Text("Last Analysis: 2 min ago")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

// MARK: - InsightsTabSelector

struct InsightsTabSelector: View {
    @Binding var selectedTab: InsightsTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(InsightsTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                            .font(.caption)

                        Text(tab.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == tab ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedTab == tab ? Color.accentColor : Color.clear)
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding()
    }
}

// MARK: - RecommendationsTab

struct RecommendationsTab: View {
    let recommendations: [AIRecommendation]
    let isLoading: Bool
    @Binding var selectedCategory: String?
    let onRefresh: () -> Void
    let onRecommendationTap: (AIRecommendation) -> Void

    private let categories = ["Trade", "Captain", "Cash", "Risk", "Price"]

    var body: some View {
        VStack(spacing: 0) {
            // Category filter
            CategoryFilterSection(
                selectedCategory: $selectedCategory,
                categories: categories,
                onRefresh: onRefresh
            )

            // Recommendations list
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView("AI analyzing your team...")
                        .padding()

                    ForEach(0 ..< 4) { _ in
                        RecommendationCardPlaceholder()
                    }
                }
                .padding()
            } else if recommendations.isEmpty {
                EmptyRecommendationsView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredRecommendations) { recommendation in
                            RecommendationCard(recommendation: recommendation) {
                                onRecommendationTap(recommendation)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private var filteredRecommendations: [AIRecommendation] {
        if let category = selectedCategory {
            return recommendations.filter { $0.type.localizedCaseInsensitiveContains(category) }
        }
        return recommendations
    }
}

// MARK: - CategoryFilterSection

struct CategoryFilterSection: View {
    @Binding var selectedCategory: String?
    let categories: [String]
    let onRefresh: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button("All") {
                    selectedCategory = nil
                    onRefresh()
                }
                .buttonStyle(CategoryChipStyle(isSelected: selectedCategory == nil))

                ForEach(categories, id: \.self) { category in
                    Button(category) {
                        selectedCategory = category
                        onRefresh()
                    }
                    .buttonStyle(CategoryChipStyle(isSelected: selectedCategory == category))
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
    }
}

// MARK: - CategoryChipStyle

struct CategoryChipStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - RecommendationCard

struct RecommendationCard: View {
    let recommendation: AIRecommendation
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        PriorityBadge(priority: recommendation.priority)

                        Text(recommendation.type.uppercased())
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }

                    Text(recommendation.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                }

                Spacer()

                if recommendation.actionRequired {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }

            // Description
            Text(recommendation.description)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(3)

            // Footer
            HStack {
                AIConfidenceMeter(confidence: recommendation.confidence)

                Spacer()

                Button("View Details") {
                    onTap()
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(priorityBorderColor, lineWidth: recommendation.actionRequired ? 2 : 0)
        )
    }

    private var priorityBorderColor: Color {
        switch recommendation.priority.lowercased() {
        case "critical": .red
        case "high": .orange
        default: .clear
        }
    }
}

// MARK: - PriorityBadge

struct PriorityBadge: View {
    let priority: String

    var body: some View {
        Text(priority.uppercased())
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(priorityColor)
            .cornerRadius(4)
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

// MARK: - AIConfidenceMeter

struct AIConfidenceMeter: View {
    let confidence: Double

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "brain")
                .font(.caption)
                .foregroundColor(.accentColor)

            Text("AI: \(Int(confidence * 100))%")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.accentColor)
        }
    }
}

// MARK: - WeeklyInsightsTab

struct WeeklyInsightsTab: View {
    let insights: [AIRecommendation]
    let isLoading: Bool
    let onRefresh: () -> Void
    let onInsightTap: (AIRecommendation) -> Void

    var body: some View {
        if insights.isEmpty, !isLoading {
            EmptyInsightsView(onRefresh: onRefresh)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Week summary
                    WeekSummaryCard()

                    // Key insights
                    if !insights.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("This Week's Insights")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal)

                            LazyVStack(spacing: 12) {
                                ForEach(insights) { insight in
                                    InsightCard(insight: insight) {
                                        onInsightTap(insight)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - WeekSummaryCard

struct WeekSummaryCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Week Summary")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                SummaryItem(
                    icon: "arrow.up.circle.fill",
                    title: "Top Performer",
                    value: "Marcus Bontempelli",
                    color: .green
                )

                SummaryItem(
                    icon: "exclamationmark.triangle.fill",
                    title: "At Risk",
                    value: "2 players need attention",
                    color: .orange
                )

                SummaryItem(
                    icon: "dollarsign.circle.fill",
                    title: "Cash Generation",
                    value: "$180k potential",
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - SummaryItem

struct SummaryItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Spacer()
        }
    }
}

// MARK: - InsightCard

struct InsightCard: View {
    let insight: AIRecommendation
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Insight type icon
            Image(systemName: insightIcon)
                .font(.title2)
                .foregroundColor(insightColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Button(action: onTap) {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }

    private var insightIcon: String {
        switch insight.type.lowercased() {
        case "trade": "arrow.triangle.2.circlepath"
        case "captain": "star.fill"
        case "cash": "dollarsign.circle"
        case "risk": "exclamationmark.triangle"
        default: "lightbulb.fill"
        }
    }

    private var insightColor: Color {
        switch insight.priority.lowercased() {
        case "critical": .red
        case "high": .orange
        case "medium": .yellow
        default: .blue
        }
    }
}

// MARK: - AIAnalyticsTab

struct AIAnalyticsTab: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // AI Performance
                AIPerformanceSection()

                // Recommendation History
                RecommendationHistorySection()

                // AI Learning
                AILearningSection()
            }
            .padding()
        }
    }
}

// MARK: - AIPerformanceSection

struct AIPerformanceSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Performance")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                PerformanceMetric(
                    title: "Accuracy",
                    value: "87%",
                    trend: "+3%",
                    color: .green
                )

                PerformanceMetric(
                    title: "Recommendations",
                    value: "24",
                    trend: "This week",
                    color: .blue
                )

                PerformanceMetric(
                    title: "Successful Trades",
                    value: "6/8",
                    trend: "75%",
                    color: .orange
                )

                PerformanceMetric(
                    title: "Cash Generated",
                    value: "$340k",
                    trend: "Above target",
                    color: .purple
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
    let trend: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.primary)

            Text(trend)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - RecommendationHistorySection

struct RecommendationHistorySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent AI Actions")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                HistoryItem(
                    action: "Recommended trading out Max Gawn",
                    time: "2 hours ago",
                    status: "Pending"
                )

                HistoryItem(
                    action: "Suggested captain change to Bontempelli",
                    time: "1 day ago",
                    status: "Followed"
                )

                HistoryItem(
                    action: "Identified cash generation opportunity",
                    time: "2 days ago",
                    status: "Successful"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - HistoryItem

struct HistoryItem: View {
    let action: String
    let time: String
    let status: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(action)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(status)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.2))
                .cornerRadius(6)
        }
    }

    private var statusColor: Color {
        switch status.lowercased() {
        case "successful", "followed": .green
        case "pending": .orange
        default: .gray
        }
    }
}

// MARK: - AILearningSection

struct AILearningSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Learning")
                .font(.headline)
                .fontWeight(.semibold)

            Text("The AI continuously learns from your decisions and AFL Fantasy patterns to improve recommendations.")
                .font(.body)
                .foregroundColor(.secondary)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Learning Progress")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("Analyzing your preferences...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                CircularProgressView(progress: 0.73)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - CircularProgressView

struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 4)
                .frame(width: 40, height: 40)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .fontWeight(.bold)
        }
    }
}

// MARK: - EmptyRecommendationsView

struct EmptyRecommendationsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Recommendations Yet")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("The AI is analyzing your team. Check back soon for personalized insights.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - EmptyInsightsView

struct EmptyInsightsView: View {
    let onRefresh: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("Weekly Insights Loading")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("AI is preparing your weekly analysis")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Refresh") {
                onRefresh()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - RecommendationCardPlaceholder

struct RecommendationCardPlaceholder: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 60, height: 12)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(width: 150, height: 16)
                }

                Spacer()

                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 24, height: 24)
            }

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(height: 40)

            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 80, height: 12)

                Spacer()

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .redacted(reason: .placeholder)
    }
}

// MARK: - RecommendationDetailView

struct RecommendationDetailView: View {
    let recommendation: AIRecommendation
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    RecommendationDetailHeader(recommendation: recommendation)

                    // Analysis
                    RecommendationAnalysisSection(recommendation: recommendation)

                    // Action items
                    if recommendation.actionRequired {
                        ActionRequiredSection(recommendation: recommendation)
                    }

                    // Additional data
                    if let data = recommendation.data, !data.isEmpty {
                        AdditionalDataSection(data: data)
                    }
                }
                .padding()
            }
            .navigationTitle(recommendation.title)
            .navigationBarTitleDisplayMode(.large)
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

// MARK: - RecommendationDetailHeader

struct RecommendationDetailHeader: View {
    let recommendation: AIRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                PriorityBadge(priority: recommendation.priority)

                Spacer()

                AIConfidenceMeter(confidence: recommendation.confidence)
            }

            Text(recommendation.description)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - RecommendationAnalysisSection

struct RecommendationAnalysisSection: View {
    let recommendation: AIRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Analysis")
                .font(.headline)
                .fontWeight(.semibold)

            Text(recommendation.reasoning)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - ActionRequiredSection

struct ActionRequiredSection: View {
    let recommendation: AIRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Action Required")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.orange)

            Text("This recommendation requires your immediate attention to optimize your team performance.")
                .font(.body)
                .foregroundColor(.primary)

            Button("Take Action") {
                // Handle action
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - AdditionalDataSection

struct AdditionalDataSection: View {
    let data: [String: String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional Information")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(spacing: 8) {
                ForEach(Array(data.keys.sorted()), id: \.self) { key in
                    HStack {
                        Text(key)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(data[key] ?? "")
                            .font(.subheadline)
                            .fontWeight(.medium)
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

// MARK: - Preview

#Preview {
    AIInsightsView()
        .environmentObject(AFLFantasyToolsClient())
}
