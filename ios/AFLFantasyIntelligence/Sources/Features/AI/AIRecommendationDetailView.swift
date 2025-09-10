import SwiftUI

// MARK: - AIRecommendationDetailView

struct AIRecommendationDetailView: View {
    let recommendation: AIRecommendation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.l) {
                    headerSection
                    
                    contentSection
                    
                    if !recommendation.insights.isEmpty {
                        insightsSection
                    }
                    
                    if !recommendation.suggestedActions.isEmpty {
                        actionsSection
                    }
                    
                    metadataSection
                }
                .padding(DS.Spacing.l)
            }
            .navigationTitle(recommendation.type.rawValue)
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
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        DSCard {
            HStack {
                Image(systemName: recommendation.type.icon)
                    .font(.title)
                    .foregroundColor(DS.Colors.primary)
                
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    Text(recommendation.type.rawValue)
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    HStack {
                        Text("Confidence:")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                        
                        Text("\(Int(recommendation.confidence * 100))%")
                            .font(DS.Typography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(confidenceColor)
                        
                        Spacer()
                        
                        Text(recommendation.timestamp.formatted(.relative(presentation: .named)))
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Content Section
    
    private var contentSection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                Text("Recommendation")
                    .font(DS.Typography.title3)
                    .foregroundColor(DS.Colors.onSurface)
                
                Text(recommendation.content)
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.onSurface)
            }
        }
    }
    
    // MARK: - Insights Section
    
    private var insightsSection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                Text("Key Insights")
                    .font(DS.Typography.title3)
                    .foregroundColor(DS.Colors.onSurface)
                
                ForEach(recommendation.insights, id: \.self) { insight in
                    HStack(alignment: .top, spacing: DS.Spacing.m) {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption)
                            .foregroundColor(DS.Colors.warning)
                            .frame(width: 16)
                        
                        Text(insight)
                            .font(DS.Typography.body)
                            .foregroundColor(DS.Colors.onSurface)
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                Text("Suggested Actions")
                    .font(DS.Typography.title3)
                    .foregroundColor(DS.Colors.onSurface)
                
                ForEach(Array(recommendation.suggestedActions.enumerated()), id: \.offset) { index, action in
                    HStack(alignment: .top, spacing: DS.Spacing.m) {
                        Text("\(index + 1).")
                            .font(DS.Typography.body)
                            .fontWeight(.semibold)
                            .foregroundColor(DS.Colors.primary)
                            .frame(width: 20, alignment: .leading)
                        
                        Text(action)
                            .font(DS.Typography.body)
                            .foregroundColor(DS.Colors.onSurface)
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    // MARK: - Metadata Section
    
    private var metadataSection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                Text("Details")
                    .font(DS.Typography.title3)
                    .foregroundColor(DS.Colors.onSurface)
                
                VStack(alignment: .leading, spacing: DS.Spacing.s) {
                    metadataRow(label: "Generated", value: recommendation.timestamp.formatted(.dateTime))
                    
                    metadataRow(label: "Confidence Level", value: confidenceLevel)
                    
                    metadataRow(label: "Type", value: recommendation.type.rawValue)
                    
                    if let round = recommendation.round {
                        metadataRow(label: "Round", value: "Round \(round)")
                    }
                    
                    if !recommendation.playerIds.isEmpty {
                        metadataRow(label: "Players Analyzed", value: "\(recommendation.playerIds.count) players")
                    }
                }
            }
        }
    }
    
    private func metadataRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(DS.Typography.caption)
                .foregroundColor(DS.Colors.onSurfaceSecondary)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .font(DS.Typography.caption)
                .foregroundColor(DS.Colors.onSurface)
            
            Spacer()
        }
    }
    
    // MARK: - Computed Properties
    
    private var confidenceColor: Color {
        switch recommendation.confidence {
        case 0.8...:
            return DS.Colors.success
        case 0.6..<0.8:
            return DS.Colors.warning
        default:
            return DS.Colors.error
        }
    }
    
    private var confidenceLevel: String {
        switch recommendation.confidence {
        case 0.9...:
            return "Very High"
        case 0.8..<0.9:
            return "High"
        case 0.6..<0.8:
            return "Medium"
        case 0.4..<0.6:
            return "Low"
        default:
            return "Very Low"
        }
    }
}

// MARK: - Previews

#if DEBUG
    struct AIRecommendationDetailView_Previews: PreviewProvider {
        static var previews: some View {
            AIRecommendationDetailView(
                recommendation: AIRecommendation(
                    id: UUID(),
                    type: .captainAdvice,
                    content: "Based on current form and upcoming fixtures, I recommend making Max Gawn your captain this round. He has consistently high scores and faces a favorable matchup.",
                    confidence: 0.85,
                    insights: [
                        "Gawn has scored 100+ in 4 of his last 5 games",
                        "Melbourne plays against a team that concedes high scores to ruckmen",
                        "Weather conditions favor contested marking"
                    ],
                    suggestedActions: [
                        "Make Max Gawn your captain",
                        "Consider trading in other Melbourne midfielders",
                        "Monitor weather updates before lockout"
                    ],
                    timestamp: Date(),
                    round: 15,
                    playerIds: ["123", "456"]
                )
            )
        }
    }
#endif
