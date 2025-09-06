//
//  PlayerDetailView.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI
import Charts
import UIKit

struct PlayerDetailView: View {
    let player: EnhancedPlayer
    @State private var selectedTab = 0
    @Environment(\.dismiss) private var dismiss
    
    // Native iOS Haptic Feedback
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Player Header
                    PlayerHeaderView(player: player)
                    
                    // Tab Selection
                    HStack {
                        TabButton(title: "Overview", index: 0, selectedTab: $selectedTab)
                        TabButton(title: "Price", index: 1, selectedTab: $selectedTab)  
                        TabButton(title: "Performance", index: 2, selectedTab: $selectedTab)
                        TabButton(title: "Risk", index: 3, selectedTab: $selectedTab)
                    }
                    .padding(.horizontal)
                    
                    // Tab Content
                    Group {
                        switch selectedTab {
                        case 0:
                            OverviewTab(player: player)
                        case 1:
                            PriceAnalysisTab(player: player)
                        case 2:
                            PerformanceTab(player: player)
                        case 3:
                            RiskTab(player: player)
                        default:
                            OverviewTab(player: player)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle(player.name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PlayerHeaderView: View {
    let player: EnhancedPlayer
    
    var body: some View {
        VStack(spacing: 16) {
            // Main player info
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(player.name)
                        .font(.title2)
                        .bold()
                    
                    HStack(spacing: 12) {
                        Text(player.position.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(player.position.color.opacity(0.2))
                            .cornerRadius(6)
                        
                        Text(player.formattedPrice)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if player.injuryRisk.riskLevel != .low {
                            HStack(spacing: 4) {
                                Text("⚠️")
                                Text(player.injuryRisk.riskLevel.rawValue)
                                    .font(.caption)
                                    .foregroundColor(player.injuryRisk.riskLevel.color)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(player.injuryRisk.riskLevel.color.opacity(0.1))
                            .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(player.currentScore)")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.orange)
                    
                    Text("Current Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Quick stats row
            HStack(spacing: 0) {
                StatBox(title: "Average", value: "\(Int(player.averageScore))", color: .blue)
                StatBox(title: "Breakeven", value: "\(player.breakeven)", color: player.breakeven < 50 ? .green : .red)
                StatBox(title: "Consistency", value: player.consistencyGrade, color: consistencyColor(for: player.consistency))
                StatBox(title: "Price Δ", value: player.priceChangeText, color: player.priceChange >= 0 ? .green : .red)
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    private func consistencyColor(for consistency: Double) -> Color {
        switch consistency {
        case 90...: return .green
        case 80..<90: return .blue
        case 70..<80: return .yellow
        default: return .red
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .bold()
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

struct TabButton: View {
    let title: String
    let index: Int
    @Binding var selectedTab: Int
    
    // Native iOS Haptic Feedback
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        Button {
            // Haptic feedback for tab selection
            if selectedTab != index {
                selectionFeedback.selectionChanged()
            }
            
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        } label: {
            Text(title)
                .font(.caption)
                .foregroundColor(selectedTab == index ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selectedTab == index ? Color.orange : Color.clear)
                .cornerRadius(20)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Tab Views

struct OverviewTab: View {
    let player: EnhancedPlayer
    
    var body: some View {
        VStack(spacing: 16) {
            // Ownership Chart
            OwnershipChart(player: player)
            
            // Next Match Info
            VStack(alignment: .leading, spacing: 12) {
                Text("Next Match")
                    .font(.headline)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("vs \(player.nextRoundProjection.opponent)")
                            .font(.subheadline)
                            .bold()
                        
                        Text("@ \(player.nextRoundProjection.venue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            let conditions = player.nextRoundProjection.conditions
                            Text("\(Int(conditions.temperature))°C")
                                .font(.caption)
                            
                            Text(conditions.rainProbability > 0.5 ? "🌧️" : conditions.rainProbability > 0.3 ? "⛅" : "☀️")
                                .font(.caption)
                                
                            Text("\(Int(conditions.windSpeed))km/h")
                                .font(.caption)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(player.nextRoundProjection.projectedScore))")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.blue)
                        
                        Text("Projected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Season Projection
            VStack(alignment: .leading, spacing: 12) {
                Text("Season Projection")
                    .font(.headline)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Total Points")
                        Spacer()
                        Text("\(Int(player.seasonProjection.projectedTotalScore))")
                            .bold()
                    }
                    
                    HStack {
                        Text("Average per Round")
                        Spacer()
                        Text("\(String(format: "%.1f", player.seasonProjection.projectedAverage))")
                            .bold()
                    }
                    
                    HStack {
                        Text("Premium Potential")
                        Spacer()
                        Text("\(Int(player.seasonProjection.premiumPotential * 100))%")
                            .bold()
                            .foregroundColor(player.seasonProjection.premiumPotential > 0.8 ? .green : player.seasonProjection.premiumPotential > 0.6 ? .orange : .red)
                    }
                }
                .font(.subheadline)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Cash Cow Status
            if player.isCashCow {
                VStack(alignment: .leading, spacing: 12) {
                    Text("💰 Cash Cow Analysis")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Cash Generated")
                            Spacer()
                            Text("$\(player.cashGenerated/1000)k")
                                .bold()
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("Projected Peak Price")
                            Spacer()
                            Text("$\(Int(player.projectedPeakPrice/1000))k")
                                .bold()
                        }
                        
                        if player.breakeven < 50 {
                            HStack {
                                Text("🚀 Sell Signal")
                                    .foregroundColor(.green)
                                Spacer()
                                Text("Consider selling")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .font(.subheadline)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
}

struct PriceAnalysisTab: View {
    let player: EnhancedPlayer
    
    var body: some View {
        VStack(spacing: 16) {
            // Price Trend Chart
            PriceTrendChart(player: player)
            
            // Current Price Info
            VStack(alignment: .leading, spacing: 12) {
                Text("Price Analysis")
                    .font(.headline)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Current Price")
                        Spacer()
                        Text(player.formattedPrice)
                            .bold()
                    }
                    
                    HStack {
                        Text("Price Change")
                        Spacer()
                        Text(player.priceChangeText)
                            .bold()
                            .foregroundColor(player.priceChange >= 0 ? .green : .red)
                    }
                    
                    HStack {
                        Text("Breakeven")
                        Spacer()
                        Text("\(player.breakeven)")
                            .bold()
                            .foregroundColor(player.breakeven < 50 ? .green : .red)
                    }
                    
                    if player.isCashCow {
                        HStack {
                            Text("Peak Price Projection")
                            Spacer()
                            Text("$\(Int(player.projectedPeakPrice/1000))k")
                                .bold()
                                .foregroundColor(.orange)
                        }
                    }
                }
                .font(.subheadline)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Value Analysis
            VStack(alignment: .leading, spacing: 12) {
                Text("Value Analysis")
                    .font(.headline)
                
                let pointsPerDollar = Double(player.averageScore) / (Double(player.price) / 1000.0)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Points per $1k")
                        Spacer()
                        Text("\(String(format: "%.2f", pointsPerDollar))")
                            .bold()
                            .foregroundColor(pointsPerDollar > 15 ? .green : pointsPerDollar > 12 ? .orange : .red)
                    }
                    
                    HStack {
                        Text("Value Rating")
                        Spacer()
                        let valueRating = pointsPerDollar > 15 ? "Excellent" : pointsPerDollar > 12 ? "Good" : pointsPerDollar > 10 ? "Fair" : "Poor"
                        Text(valueRating)
                            .bold()
                            .foregroundColor(pointsPerDollar > 15 ? .green : pointsPerDollar > 12 ? .orange : .red)
                    }
                }
                .font(.subheadline)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

struct PerformanceTab: View {
    let player: EnhancedPlayer
    
    var body: some View {
        VStack(spacing: 16) {
            // Performance Charts
            PlayerPerformanceChart(player: player)
            ConsistencyChart(player: player)
            
            // Performance Metrics
            VStack(alignment: .leading, spacing: 12) {
                Text("Performance Metrics")
                    .font(.headline)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Average Score")
                        Spacer()
                        Text("\(String(format: "%.1f", player.averageScore))")
                            .bold()
                    }
                    
                    HStack {
                        Text("Consistency")
                        Spacer()
                        Text(player.consistencyGrade)
                            .bold()
                            .foregroundColor(consistencyColor(for: player.consistency))
                    }
                    
                    HStack {
                        Text("High Score")
                        Spacer()
                        Text("\(player.highScore)")
                            .bold()
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text("Low Score")
                        Spacer()
                        Text("\(player.lowScore)")
                            .bold()
                            .foregroundColor(.red)
                    }
                }
                .font(.subheadline)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Venue Performance
            if !player.venuePerformance.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Venue Performance")
                        .font(.headline)
                    
                    ForEach(player.venuePerformance.prefix(3), id: \.venue) { venue in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(venue.venue)
                                    .font(.subheadline)
                                    .bold()
                                Text("\(venue.gamesPlayed) games")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(String(format: "%.1f", venue.averageScore))")
                                    .font(.subheadline)
                                    .bold()
                                
                                Text(venue.bias >= 0 ? "+\(String(format: "%.1f", venue.bias))" : "\(String(format: "%.1f", venue.bias))")
                                    .font(.caption)
                                    .foregroundColor(venue.bias >= 0 ? .green : .red)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }
    
    private func consistencyColor(for consistency: Double) -> Color {
        switch consistency {
        case 90...: return .green
        case 80..<90: return .blue
        case 70..<80: return .yellow
        default: return .red
        }
    }
}

struct RiskTab: View {
    let player: EnhancedPlayer
    
    var body: some View {
        VStack(spacing: 16) {
            // Injury Risk
            VStack(alignment: .leading, spacing: 12) {
                Text("Injury Risk Analysis")
                    .font(.headline)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Risk Level")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(player.injuryRisk.riskLevel.rawValue)
                            .font(.title3)
                            .bold()
                            .foregroundColor(player.injuryRisk.riskLevel.color)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Risk Score")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(player.injuryRisk.riskScore * 100))%")
                            .font(.title3)
                            .bold()
                            .foregroundColor(player.injuryRisk.riskLevel.color)
                    }
                }
                
                if !player.injuryRisk.riskFactors.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Risk Factors:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ForEach(player.injuryRisk.riskFactors, id: \.self) { factor in
                            Text("• \(factor)")
                                .font(.caption)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Other Risk Factors
            VStack(alignment: .leading, spacing: 12) {
                Text("Other Risk Factors")
                    .font(.headline)
                
                VStack(spacing: 8) {
                    if player.isDoubtful {
                        HStack {
                            Text("❓ Selection Status")
                            Spacer()
                            Text("Doubtful")
                                .bold()
                                .foregroundColor(.orange)
                        }
                    }
                    
                    if player.isSuspended {
                        HStack {
                            Text("🚫 Suspension")
                            Spacer()
                            Text("Suspended")
                                .bold()
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Weather risk for next match
                    let conditions = player.nextRoundProjection.conditions
                    if conditions.rainProbability > 0.5 {
                        HStack {
                            Text("🌧️ Weather Risk")
                            Spacer()
                            Text("High rain chance")
                                .bold()
                                .foregroundColor(.orange)
                        }
                    }
                    
                    if conditions.windSpeed > 30 {
                        HStack {
                            Text("💨 Wind Risk")
                            Spacer()
                            Text("Strong winds")
                                .bold()
                                .foregroundColor(.orange)
                        }
                    }
                }
                .font(.subheadline)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Active Alerts
            if !player.alertFlags.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("🚨 Active Alerts")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    ForEach(player.alertFlags, id: \.type) { alert in
                        HStack {
                            Text(alertIcon(for: alert.type))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(alertTitle(for: alert.type))
                                    .font(.subheadline)
                                    .bold()
                                
                                Text(alert.message)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(alert.priority.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(alertColor(for: alert.priority).opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    private func alertIcon(for alertType: AlertType) -> String {
        switch alertType {
        case .priceDrop: return "📉"
        case .breakEvenCliff: return "⚠️"
        case .cashCowSell: return "💰"
        case .injuryRisk: return "🏥"
        case .roleChange: return "🔄"
        case .weatherRisk: return "🌧️"
        case .contractYear: return "📋"
        case .premiumBreakout: return "🚀"
        }
    }
    
    private func alertTitle(for alertType: AlertType) -> String {
        switch alertType {
        case .priceDrop: return "Price Drop Alert"
        case .breakEvenCliff: return "Breakeven Cliff"
        case .cashCowSell: return "Cash Cow Sell Signal"
        case .injuryRisk: return "Injury Risk"
        case .roleChange: return "Role Change"
        case .weatherRisk: return "Weather Risk"
        case .contractYear: return "Contract Year"
        case .premiumBreakout: return "Premium Breakout"
        }
    }
    
    private func alertColor(for priority: AlertPriority) -> Color {
        switch priority {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        }
    }
}

// MARK: - Preview

#Preview {
    PlayerDetailView(player: EnhancedPlayer(
        id: "1",
        name: "Marcus Bontempelli",
        position: .midfielder,
        price: 750000,
        currentScore: 120,
        averageScore: 105.5,
        breakeven: 45,
        consistency: 88.0,
        highScore: 156,
        lowScore: 62,
        priceChange: 15000,
        isCashCow: false,
        isDoubtful: false,
        isSuspended: false,
        cashGenerated: 0,
        projectedPeakPrice: 0,
        nextRoundProjection: RoundProjection(
            round: 15,
            opponent: "Richmond",
            venue: "Marvel Stadium",
            projectedScore: 108.0,
            confidence: 0.82,
            conditions: WeatherConditions(
                temperature: 18.0,
                rainProbability: 0.2,
                windSpeed: 15.0,
                humidity: 65.0
            )
        ),
        seasonProjection: SeasonProjection(
            projectedTotalScore: 2110.0,
            projectedAverage: 105.5,
            premiumPotential: 0.95
        ),
        injuryRisk: InjuryRisk(
            riskLevel: .low,
            riskScore: 0.15,
            riskFactors: []
        ),
        venuePerformance: [
            VenuePerformance(venue: "Marvel Stadium", gamesPlayed: 8, averageScore: 110.2, bias: 4.7),
            VenuePerformance(venue: "MCG", gamesPlayed: 6, averageScore: 102.8, bias: -2.7)
        ],
        alertFlags: []
    ))
}
