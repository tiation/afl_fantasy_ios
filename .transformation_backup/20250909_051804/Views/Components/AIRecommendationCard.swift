import SwiftUI

struct AIRecommendationCard: View {
    let title: String
    let recommendations: [AIRecommendation]
    let showConfidence: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 8) {
                ForEach(recommendations) { recommendation in
                    RecommendationRow(recommendation: recommendation, showConfidence: showConfidence)
                }
            }
        }
    }
}

struct RecommendationRow: View {
    let recommendation: AIRecommendation
    let showConfidence: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(typeColor)
                
                Text(recommendation.reasoning)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            if showConfidence {
                VStack(alignment: .trailing) {
                    Text("\(Int(recommendation.confidence * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(confidenceColor)
                    
                    Text("confidence")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var typeColor: Color {
        switch recommendation.type {
        case .trade: return .blue
        case .captain: return .green
        case .hold: return .orange
        case .sell: return .red
        }
    }
    
    private var confidenceColor: Color {
        if recommendation.confidence >= 0.8 { return .green }
        if recommendation.confidence >= 0.6 { return .orange }
        return .red
    }
}

struct AIRecommendationCard_Previews: PreviewProvider {
    static var previews: some View {
        AIRecommendationCard(
            title: "AI Recommendations",
            recommendations: [
                AIRecommendation(
                    id: "1",
                    type: .captain,
                    confidence: 0.85,
                    reasoning: "Strong form vs weak defense",
                    impact: "High",
                    timestamp: Date()
                ),
                AIRecommendation(
                    id: "2", 
                    type: .trade,
                    confidence: 0.72,
                    reasoning: "Price drop expected",
                    impact: "Medium",
                    timestamp: Date()
                )
            ],
            showConfidence: true
        )
        .padding()
    }
}
