import SwiftUI

struct AIToolsView: View {
    @EnvironmentObject var apiService: APIService
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: DS.Spacing.l) {
                    Text("🤖 AI-Powered Tools")
                        .font(DS.Typography.largeTitle)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    Text("Advanced analytics and recommendations powered by machine learning algorithms")
                        .font(DS.Typography.body)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, DS.Spacing.l)
                    
                    aiToolsGrid
                }
                .padding(.horizontal, DS.Spacing.l)
            }
            .navigationTitle("AI Tools")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var aiToolsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.m), count: 2), spacing: DS.Spacing.m) {
            AIToolCard(
                title: "Captain Advisor",
                subtitle: "AI-powered captain recommendations",
                icon: "star.circle.fill",
                color: DS.Colors.primary
            ) {
                // TODO: Navigate to Captain Advisor
            }
            
            AIToolCard(
                title: "Trade Suggester",
                subtitle: "Smart trade opportunities",
                icon: "arrow.triangle.swap",
                color: DS.Colors.success
            ) {
                // TODO: Navigate to Trade Suggester
            }
            
            AIToolCard(
                title: "Team Analyzer",
                subtitle: "Structure & weaknesses analysis",
                icon: "chart.bar.fill",
                color: DS.Colors.warning
            ) {
                // TODO: Navigate to Team Analyzer
            }
            
            AIToolCard(
                title: "Price Predictor",
                subtitle: "Future price change forecasts",
                icon: "chart.line.uptrend.xyaxis",
                color: DS.Colors.info
            ) {
                // TODO: Navigate to Price Predictor
            }
        }
    }
}

struct AIToolCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            DSCard {
                VStack(spacing: DS.Spacing.m) {
                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundColor(color)
                    
                    VStack(spacing: DS.Spacing.xs) {
                        Text(title)
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.Colors.onSurface)
                            .multilineTextAlignment(.center)
                        
                        Text(subtitle)
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(height: 120)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .dsAccessibility(label: title, hint: subtitle)
    }
}

#if DEBUG
struct AIToolsView_Previews: PreviewProvider {
    static var previews: some View {
        AIToolsView()
            .environmentObject(APIService.mock)
    }
}
#endif
