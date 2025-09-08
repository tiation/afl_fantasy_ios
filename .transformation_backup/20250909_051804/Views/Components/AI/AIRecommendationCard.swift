import SwiftUI

struct AIRecommendationCard: View {
    let title: String
    let recommendations: [AIRecommendation]
    let showConfidence: Bool
    let onSelect: ((AIRecommendation) -> Void)?
    
    init(
        title: String,
        recommendations: [AIRecommendation],
        showConfidence: Bool = true,
        onSelect: ((AIRecommendation) -> Void)? = nil
    ) {
        self.title = title
        self.recommendations = recommendations
        self.showConfidence = showConfidence
        self.onSelect = onSelect
    }
    
    private var topConfidence: Double {
        recommendations.first?.confidence ?? 0
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            // Header
            HStack {
                Text(title)
                    .font(Theme.Font.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                if showConfidence {
                    Text("\(Int(topConfidence * 100))% Confidence")
                        .font(Theme.Font.bodyBold)
                        .foregroundColor(Theme.Colors.success)
                }
            }
            
            // Recommendations
            VStack(spacing: Theme.Spacing.xs) {
                ForEach(recommendations) { rec in
                    RecommendationRow(recommendation: rec)
                        .onTapGesture {
                            onSelect?(rec)
                        }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

struct RecommendationRow: View {
    let recommendation: AIRecommendation
    
    var body: some View {
        HStack(spacing: Theme.Spacing.m) {
            // Type Icon
            ZStack {
                Circle()
                    .fill(Theme.Colors.accent.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Text(recommendation.type.rawValue.prefix(1).uppercased())
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.accent)
            }
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(recommendation.type.rawValue.capitalized)
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(recommendation.reasoning)
                    .font(Theme.Font.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: Theme.Spacing.xxs) {
                Text(recommendation.impact)
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .multilineTextAlignment(.trailing)
                
                Text("Impact")
                    .font(Theme.Font.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            // Confidence Bar
            if recommendation.confidence > 0 {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Theme.Colors.textSecondary.opacity(0.1))
                        
                        Capsule()
                            .fill(Theme.Colors.success)
                            .frame(width: geo.size.width * recommendation.confidence)
                    }
                }
                .frame(width: 60, height: 4)
            }
        }
        .padding()
        .background(Theme.Colors.background)
        .cornerRadius(Theme.Radius.medium)
    }
}

// MARK: - Preview

struct AIRecommendationCard_Previews: PreviewProvider {
    static var sampleRecommendations: [AIRecommendation] {
        [
            AIRecommendation(
                id: UUID().uuidString,
                type: .captain,
                confidence: 0.85,
                reasoning: "Strong form + favorable matchup",
                impact: "High scoring potential",
                timestamp: Date()
            ),
            AIRecommendation(
                id: UUID().uuidString,
                type: .trade,
                confidence: 0.75,
                reasoning: "Consistent high scorer",
                impact: "Steady points",
                timestamp: Date()
            ),
            AIRecommendation(
                id: UUID().uuidString,
                type: .hold,
                confidence: 0.65,
                reasoning: "Good historical vs opponent",
                impact: "Value pick",
                timestamp: Date()
            )
        ]
    }
    
    static var previews: some View {
        VStack(spacing: Theme.Spacing.m) {
            // Full Version
            AIRecommendationCard(
                title: "Captain Suggestions",
                recommendations: sampleRecommendations,
                showConfidence: true
            )
            
            // Simple Version
            AIRecommendationCard(
                title: "Trade Targets",
                recommendations: sampleRecommendations,
                showConfidence: false
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
