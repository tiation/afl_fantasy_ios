import SwiftUI

struct AIPredictionCard: View {
    let title: String
    let prediction: AIPrediction
    
    var body: some View {
        VStack(spacing: Theme.Spacing.m) {
            // Header
            HStack {
                Text(title)
                    .font(Theme.Font.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Text("\(Int(prediction.confidence * 100))% Confidence")
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(confidence(prediction.confidence).color)
            }
            
            // Prediction Score
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack {
                    Text("Predicted Score")
                        .font(Theme.Font.bodyBold)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Text("\(Int(prediction.predictedScore))")
                        .font(Theme.Font.title2)
                        .foregroundColor(Theme.Colors.accent)
                }
            }
            
            // Risk Bars (using factors from model)
            if !prediction.factors.isEmpty {
                VStack(spacing: Theme.Spacing.s) {
                    ForEach(prediction.factors, id: \.name) { factor in
                        PredictionFactorRow(factor: factor)
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

struct PredictionFactorRow: View {
    let factor: PredictionFactor
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            // Title & Impact
            HStack {
                Text(factor.name)
                    .font(Theme.Font.caption)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Text("\(Int(abs(factor.impact) * 100))%")
                    .font(Theme.Font.caption)
                    .foregroundColor(factor.impact >= 0 ? Theme.Colors.success : Theme.Colors.error)
            }
            
            // Impact Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(Theme.Colors.textSecondary.opacity(0.1))
                    
                    // Fill
                    Capsule()
                        .fill(factor.impact >= 0 ? Theme.Colors.success : Theme.Colors.error)
                        .frame(width: geo.size.width * abs(factor.impact))
                }
            }
            .frame(height: 4)
            
            // Description
            Text(factor.description)
                .font(Theme.Font.caption2)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
}

struct RiskBarRow: View {
    let factor: RiskFactor
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            // Title & Score
            HStack {
                Text(factor.name)
                    .font(Theme.Font.caption)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Text("\(Int(factor.score * 100))%")
                    .font(Theme.Font.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            // Risk Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(Theme.Colors.textSecondary.opacity(0.1))
                    
                    // Fill
                    Capsule()
                        .fill(confidence(factor.score).color)
                        .frame(width: geo.size.width * factor.score)
                }
            }
            .frame(height: 4)
        }
    }
}

struct RiskSummaryView: View {
    let factors: [RiskFactor]
    let compact: Bool
    
    init(factors: [RiskFactor], compact: Bool = false) {
        self.factors = factors
        self.compact = compact
    }
    
    private var overallRisk: Double {
        let weightedSum = factors.reduce(0) { $0 + ($1.score * $1.weight) }
        let totalWeight = factors.reduce(0) { $0 + $1.weight }
        return weightedSum / totalWeight
    }
    
    var body: some View {
        HStack(spacing: Theme.Spacing.m) {
            // Risk Level
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(compact ? "Risk" : "Risk Level")
                    .font(Theme.Font.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Text(confidence(overallRisk).label)
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(confidence(overallRisk).color)
            }
            
            if !compact {
                // Risk Bar
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            // Background
                            Capsule()
                                .fill(Theme.Colors.textSecondary.opacity(0.1))
                            
                            // Fill
                            Capsule()
                                .fill(confidence(overallRisk).color)
                                .frame(width: geo.size.width * overallRisk)
                        }
                    }
                    .frame(height: 4)
                    
                    // Bar Labels
                    HStack {
                        Text("Low")
                        Spacer()
                        Text("High")
                    }
                    .font(Theme.Font.caption2)
                    .foregroundColor(Theme.Colors.textSecondary)
                }
            }
        }
    }
}

// MARK: - Helper Types for Preview

struct RiskFactor: Identifiable {
    let id = UUID()
    let name: String
    let score: Double
    let weight: Double
    
    init(name: String, score: Double, weight: Double = 1.0) {
        self.name = name
        self.score = score
        self.weight = weight
    }
}

private func confidence(_ value: Double) -> (color: Color, label: String) {
    switch value {
    case _ where value <= 0.33:
        return (Theme.Colors.success, "Low")
    case _ where value <= 0.66:
        return (Theme.Colors.warning, "Medium")
    default:
        return (Theme.Colors.error, "High")
    }
}

// MARK: - Preview

struct AIPredictionCard_Previews: PreviewProvider {
    static var samplePrediction: AIPrediction {
        AIPrediction(
            id: UUID().uuidString,
            playerId: "player123",
            predictedScore: 105.5,
            confidence: 0.85,
            factors: [
                PredictionFactor(name: "Form", impact: 0.25, description: "Strong recent form"),
                PredictionFactor(name: "Fixtures", impact: 0.45, description: "Favorable upcoming matchups"),
                PredictionFactor(name: "Role Change", impact: -0.15, description: "Slight role adjustment"),
                PredictionFactor(name: "Team Changes", impact: 0.10, description: "Positive team dynamics")
            ],
            timestamp: Date()
        )
    }
    
    // Mock RiskFactors for demonstration
    static var mockFactors: [RiskFactor] {
        [
            .init(name: "Form", score: 0.25, weight: 1.5),
            .init(name: "Fixtures", score: 0.45),
            .init(name: "Role Change", score: 0.75),
            .init(name: "Team Changes", score: 0.55)
        ]
    }
    
    static var previews: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.m) {
                // Full Card
                AIPredictionCard(
                    title: "Trade Analysis",
                    prediction: samplePrediction
                )
                
                // Risk Summary Variations
                HStack {
                    RiskSummaryView(
                        factors: mockFactors,
                        compact: true
                    )
                    
                    Spacer()
                    
                    RiskSummaryView(
                        factors: mockFactors,
                        compact: false
                    )
                }
                .padding()
                .cardStyle()
            }
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
