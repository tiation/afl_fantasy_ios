import SwiftUI

struct TeamOptimizationView: View {
    let suggestions: [OptimizationSuggestion]
    let selectedId: UUID?
    let onSelect: ((OptimizationSuggestion) -> Void)?
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            // Header
            HStack {
                Text("Team Optimization")
                    .font(Theme.Font.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Text("\(suggestions.count) Suggestions")
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            // Suggestions List
            ForEach(suggestions) { suggestion in
                SuggestionRow(
                    suggestion: suggestion,
                    isSelected: selectedId == suggestion.id
                )
                .onTapGesture {
                    onSelect?(suggestion)
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

struct SuggestionRow: View {
    let suggestion: OptimizationSuggestion
    let isSelected: Bool
    
    private var impactColor: Color {
        suggestion.impact >= 0 ? Theme.Colors.success : Theme.Colors.error
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            // Main Info
            HStack(spacing: Theme.Spacing.m) {
                // Type Icon
                ZStack {
                    Circle()
                        .fill(Theme.Colors.accent.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: suggestion.type.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.Colors.accent)
                }
                
                // Title & Description
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(suggestion.title)
                        .font(Theme.Font.bodyBold)
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text(suggestion.description)
                        .font(Theme.Font.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                // Impact
                VStack(alignment: .trailing, spacing: Theme.Spacing.xxs) {
                    Text(suggestion.impact >= 0 ? "+\(suggestion.impact)" : "\(suggestion.impact)")
                        .font(Theme.Font.bodyBold)
                        .foregroundColor(impactColor)
                    
                    Text(suggestion.impactType)
                        .font(Theme.Font.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            
            if let changes = suggestion.changes {
                // Changes
                VStack(spacing: Theme.Spacing.xs) {
                    ForEach(changes, id: \.from) { change in
                        HStack(spacing: Theme.Spacing.s) {
                            // From Player
                            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                                Text(change.from)
                                    .font(Theme.Font.caption)
                                    .foregroundColor(Theme.Colors.error)
                                
                                Text("OUT")
                                    .font(Theme.Font.caption2)
                                    .foregroundColor(Theme.Colors.error)
                            }
                            
                            Spacer()
                            
                            // Arrow
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            Spacer()
                            
                            // To Player
                            VStack(alignment: .trailing, spacing: Theme.Spacing.xxs) {
                                Text(change.to)
                                    .font(Theme.Font.caption)
                                    .foregroundColor(Theme.Colors.success)
                                
                                Text("IN")
                                    .font(Theme.Font.caption2)
                                    .foregroundColor(Theme.Colors.success)
                            }
                        }
                    }
                }
                .padding(.top, Theme.Spacing.xs)
            }
        }
        .padding()
        .background(Theme.Colors.background)
        .cornerRadius(Theme.Radius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .stroke(isSelected ? Theme.Colors.accent : .clear)
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Models

struct OptimizationSuggestion: Identifiable {
    let id = UUID()
    let type: SuggestionType
    let title: String
    let description: String
    let impact: Int
    let impactType: String
    let changes: [PlayerChange]?
    let confidence: Double
    
    enum SuggestionType {
        case trade
        case structure
        case role
        case captain
        case bench
        
        var icon: String {
            switch self {
            case .trade:
                return "arrow.left.arrow.right"
            case .structure:
                return "rectangle.grid.2x2"
            case .role:
                return "person.2"
            case .captain:
                return "c.circle"
            case .bench:
                return "chair"
            }
        }
    }
    
    struct PlayerChange {
        let from: String
        let to: String
    }
}

// MARK: - Preview

struct TeamOptimizationView_Previews: PreviewProvider {
    static var sampleSuggestions: [OptimizationSuggestion] {
        [
            .init(
                type: .trade,
                title: "Trade Recommendation",
                description: "Upgrade midfield by trading out underperforming premium",
                impact: 15,
                impactType: "Proj. Points",
                changes: [
                    .init(from: "Josh Kelly", to: "Marcus Bontempelli")
                ],
                confidence: 0.85
            ),
            .init(
                type: .structure,
                title: "Structure Optimization",
                description: "Improve forward line by adding more premium players",
                impact: 25000,
                impactType: "Total Value",
                changes: [
                    .init(from: "Jeremy Cameron", to: "Charlie Curnow"),
                    .init(from: "Nick Larkey", to: "Harry McKay")
                ],
                confidence: 0.75
            ),
            .init(
                type: .captain,
                title: "Captain Strategy",
                description: "Optimize captain rotation based on fixtures",
                impact: 8,
                impactType: "Avg Points",
                changes: nil,
                confidence: 0.90
            )
        ]
    }
    
    static var previews: some View {
        ScrollView {
            TeamOptimizationView(
                suggestions: sampleSuggestions,
                selectedId: sampleSuggestions[0].id,
                onSelect: { _ in }
            )
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
