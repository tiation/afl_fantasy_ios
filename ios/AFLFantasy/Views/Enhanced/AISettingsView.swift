//
//  AISettingsView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - AISettingsView

struct AISettingsView: View {
    @Binding var captainConfidenceThreshold: Double
    @Binding var tradeScoreThreshold: Double
    @Binding var enableAIRecommendations: Bool
    @Binding var enableAdvancedAnalytics: Bool

    @State private var aiProcessingSpeed = 1.0
    @State private var riskTolerance = 0.5
    @State private var enableWeatherFactoring = true
    @State private var enableVenueAnalysis = true
    @State private var enableFormTrends = true
    @State private var enableInjuryPrediction = true

    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    private let successFeedback = UINotificationFeedbackGenerator()

    var body: some View {
        Form {
            Section("🧠 AI Engine") {
                Toggle(isOn: $enableAIRecommendations) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI Recommendations")
                            .font(.headline)
                        Text("Enhanced AI-powered suggestions and analysis")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onChange(of: enableAIRecommendations) { _, _ in
                    impactFeedback.impactOccurred()
                }

                Toggle(isOn: $enableAdvancedAnalytics) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Advanced Analytics")
                            .font(.headline)
                        Text("Deep statistical analysis and predictive modeling")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onChange(of: enableAdvancedAnalytics) { _, _ in
                    impactFeedback.impactOccurred()
                }
            }

            Section("⭐ Captain AI") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Confidence Threshold")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(captainConfidenceThreshold))%")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.green)
                    }

                    Text("Minimum AI confidence required to show captain suggestions")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Slider(value: $captainConfidenceThreshold, in: 50 ... 95, step: 5) {
                        Text("Captain Confidence")
                    } minimumValueLabel: {
                        Text("50%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } maximumValueLabel: {
                        Text("95%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .onChange(of: captainConfidenceThreshold) { _, _ in
                        impactFeedback.impactOccurred()
                    }
                }
                .padding(.vertical, 8)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Expected Suggestions")
                            .font(.subheadline)
                        Text(confidenceSuggestionText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.orange)
                        .font(.title2)
                }
            }

            Section("🔄 Trade AI") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Trade Score Threshold")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(tradeScoreThreshold))%")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.blue)
                    }

                    Text("Minimum trade score required for AI to suggest trades")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Slider(value: $tradeScoreThreshold, in: 60 ... 90, step: 5) {
                        Text("Trade Score")
                    } minimumValueLabel: {
                        Text("60%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } maximumValueLabel: {
                        Text("90%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .onChange(of: tradeScoreThreshold) { _, _ in
                        impactFeedback.impactOccurred()
                    }
                }
                .padding(.vertical, 8)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Trade Frequency")
                            .font(.subheadline)
                        Text(tradeSuggestionText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }

            Section("⚙️ Analysis Factors") {
                Toggle(isOn: $enableWeatherFactoring) {
                    AnalysisFactorRow(
                        icon: "cloud.rain.fill",
                        iconColor: .gray,
                        title: "Weather Analysis",
                        subtitle: "Include weather conditions in predictions"
                    )
                }
                .onChange(of: enableWeatherFactoring) { _, _ in
                    impactFeedback.impactOccurred()
                }

                Toggle(isOn: $enableVenueAnalysis) {
                    AnalysisFactorRow(
                        icon: "building.2.fill",
                        iconColor: .brown,
                        title: "Venue Performance",
                        subtitle: "Factor in ground-specific player performance"
                    )
                }
                .onChange(of: enableVenueAnalysis) { _, _ in
                    impactFeedback.impactOccurred()
                }

                Toggle(isOn: $enableFormTrends) {
                    AnalysisFactorRow(
                        icon: "chart.line.uptrend.xyaxis",
                        iconColor: .green,
                        title: "Form Trends",
                        subtitle: "Recent performance patterns and momentum"
                    )
                }
                .onChange(of: enableFormTrends) { _, _ in
                    impactFeedback.impactOccurred()
                }

                Toggle(isOn: $enableInjuryPrediction) {
                    AnalysisFactorRow(
                        icon: "cross.case.fill",
                        iconColor: .red,
                        title: "Injury Prediction",
                        subtitle: "Predictive injury risk modeling"
                    )
                }
                .onChange(of: enableInjuryPrediction) { _, _ in
                    impactFeedback.impactOccurred()
                }
            }

            Section("🎯 Risk Profile") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Risk Tolerance")
                            .font(.headline)
                        Spacer()
                        Text(riskToleranceText)
                            .font(.title3)
                            .bold()
                            .foregroundColor(riskToleranceColor)
                    }

                    Text("How aggressive should AI recommendations be?")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Slider(value: $riskTolerance, in: 0 ... 1, step: 0.1) {
                        Text("Risk Tolerance")
                    } minimumValueLabel: {
                        Text("Safe")
                            .font(.caption)
                            .foregroundColor(.green)
                    } maximumValueLabel: {
                        Text("Risky")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .onChange(of: riskTolerance) { _, _ in
                        impactFeedback.impactOccurred()
                    }
                }
                .padding(.vertical, 8)
            } footer: {
                Text(
                    "Higher risk tolerance enables more aggressive trade suggestions and captain picks with higher potential rewards."
                )
            }

            Section("🚀 Performance") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Processing Speed")
                            .font(.headline)
                        Spacer()
                        Text(processingSpeedText)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.blue)
                    }

                    Text("Balance between analysis depth and response time")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Slider(value: $aiProcessingSpeed, in: 0.5 ... 2, step: 0.5) {
                        Text("Processing Speed")
                    } minimumValueLabel: {
                        Text("Deep")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } maximumValueLabel: {
                        Text("Fast")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .onChange(of: aiProcessingSpeed) { _, _ in
                        impactFeedback.impactOccurred()
                    }
                }
                .padding(.vertical, 8)

                Button("Optimize for My Device") {
                    impactFeedback.impactOccurred()
                    optimizeForDevice()
                }
                .foregroundColor(.blue)
            }

            Section("🔄 Reset") {
                Button("Reset AI Settings to Default") {
                    impactFeedback.impactOccurred()
                    resetAISettings()
                }
                .foregroundColor(.orange)
            }
        }
        .navigationTitle("🧠 AI Settings")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Computed Properties

    private var confidenceSuggestionText: String {
        switch captainConfidenceThreshold {
        case 50 ..< 65: "2-4 suggestions per round"
        case 65 ..< 80: "1-3 suggestions per round"
        case 80 ..< 90: "1-2 suggestions per round"
        default: "0-1 suggestions per round"
        }
    }

    private var tradeSuggestionText: String {
        switch tradeScoreThreshold {
        case 60 ..< 70: "Frequent suggestions"
        case 70 ..< 80: "Moderate suggestions"
        case 80 ..< 85: "Conservative suggestions"
        default: "Rare suggestions"
        }
    }

    private var riskToleranceText: String {
        switch riskTolerance {
        case 0 ..< 0.3: "Conservative"
        case 0.3 ..< 0.7: "Balanced"
        default: "Aggressive"
        }
    }

    private var riskToleranceColor: Color {
        switch riskTolerance {
        case 0 ..< 0.3: .green
        case 0.3 ..< 0.7: .blue
        default: .red
        }
    }

    private var processingSpeedText: String {
        switch aiProcessingSpeed {
        case 0.5: "Deep Analysis"
        case 1.0: "Balanced"
        case 1.5: "Fast"
        default: "Lightning"
        }
    }

    // MARK: - Helper Methods

    private func optimizeForDevice() {
        // In real app: detect device performance and optimize
        aiProcessingSpeed = 1.5 // Assume modern device
        successFeedback.notificationOccurred(.success)
    }

    private func resetAISettings() {
        captainConfidenceThreshold = 70.0
        tradeScoreThreshold = 75.0
        enableAIRecommendations = true
        enableAdvancedAnalytics = true
        aiProcessingSpeed = 1.0
        riskTolerance = 0.5
        enableWeatherFactoring = true
        enableVenueAnalysis = true
        enableFormTrends = true
        enableInjuryPrediction = true

        successFeedback.notificationOccurred(.success)
    }
}

// MARK: - AnalysisFactorRow

struct AnalysisFactorRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        AISettingsView(
            captainConfidenceThreshold: .constant(75.0),
            tradeScoreThreshold: .constant(80.0),
            enableAIRecommendations: .constant(true),
            enableAdvancedAnalytics: .constant(true)
        )
    }
}
