import SwiftUI

// MARK: - AIToolsView

struct AIToolsView: View {
    @EnvironmentObject var apiService: APIService
    @StateObject private var openAIService = OpenAIService()
    @StateObject private var playersViewModel = PlayersViewModel()
    
    @State private var selectedTool: AITool?
    @State private var showingSettings = false
    @State private var currentRecommendation: AIRecommendation?
    @State private var showingRecommendation = false
    @State private var showingTradeAnalyzer = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: DS.Spacing.l) {
                    headerSection
                    
                    if openAIService.isConfigured {
                        toolsGrid
                        
                        if let recommendation = currentRecommendation {
                            recommendationCard(recommendation)
                        }
                    } else {
                        setupPrompt
                    }
                }
                .padding(DS.Spacing.l)
                .dsFloatingTabBarPadding()
            }
            .navigationTitle("AI Tools")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            showingTradeAnalyzer = true
                        } label: {
                            Image(systemName: "arrow.left.arrow.right.circle")
                        }
                        .accessibilityLabel("Open Trade Analyzer")
                        
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            AISettingsView()
        }
        .sheet(isPresented: $showingRecommendation) {
            if let recommendation = currentRecommendation {
                AIRecommendationDetailView(recommendation: recommendation)
            }
        }
        .sheet(isPresented: $showingTradeAnalyzer) {
            TradeAnalyzerView()
                .environmentObject(apiService)
        }
        .onAppear {
            loadPlayersIfNeeded()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.title)
                        .foregroundColor(DS.Colors.primary)
                    
                    VStack(alignment: .leading) {
                        Text("AI-Powered Analysis")
                            .font(DS.Typography.headline)
                            .foregroundColor(DS.Colors.onSurface)
                        
                        Text("Get intelligent insights for your fantasy team")
                            .font(DS.Typography.body)
                            .foregroundColor(DS.Colors.onSurfaceSecondary)
                    }
                    
                    Spacer()
                    
                    // Status indicator
                    VStack {
                        Image(systemName: openAIService.isConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(openAIService.isConfigured ? DS.Colors.success : DS.Colors.warning)
                        
                        Text(openAIService.isConfigured ? "Ready" : "Setup Required")
                            .font(DS.Typography.caption)
                            .foregroundColor(openAIService.isConfigured ? DS.Colors.success : DS.Colors.warning)
                    }
                }
            }
        }
    }
    
    // MARK: - Setup Prompt
    
    private var setupPrompt: some View {
        DSCard {
            VStack(spacing: DS.Spacing.l) {
                Image(systemName: "key.fill")
                    .font(.system(size: 48))
                    .foregroundColor(DS.Colors.primary)
                
                Text("Setup Required")
                    .font(DS.Typography.title3)
                    .foregroundColor(DS.Colors.onSurface)
                
                Text("To use AI features, you need to add your OpenAI API key. This enables powerful captain recommendations, trade analysis, and price predictions.")
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                    .multilineTextAlignment(.center)
                
                DSButton("Configure AI Settings") {
                    showingSettings = true
                }
            }
            .padding(DS.Spacing.l)
        }
    }
    
    // MARK: - Tools Grid
    
    private var toolsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DS.Spacing.l) {
            AIToolCard(
                icon: "star.fill",
                title: "Captain Advisor",
                description: "Get AI recommendations for optimal captain choice",
                color: DS.Colors.success,
                isLoading: openAIService.isLoading && selectedTool == .captainAdvisor
            ) {
                getCaptainRecommendation()
            }
            
            AIToolCard(
                icon: "arrow.triangle.swap",
                title: "Trade Suggester",
                description: "Intelligent trade recommendations",
                color: DS.Colors.primary,
                isLoading: openAIService.isLoading && selectedTool == .tradeSuggester
            ) {
                getTradeRecommendation()
            }
            
            AIToolCard(
                icon: "chart.line.uptrend.xyaxis",
                title: "Price Predictor",
                description: "Predict price movements and opportunities",
                color: DS.Colors.info,
                isLoading: openAIService.isLoading && selectedTool == .pricePredictor
            ) {
                getPriceAnalysis()
            }
        }
    }
    
    // MARK: - Recommendation Card
    
    private func recommendationCard(_ recommendation: AIRecommendation) -> some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                HStack {
                    Image(systemName: recommendation.type.icon)
                        .foregroundColor(DS.Colors.primary)
                    
                    Text(recommendation.type.rawValue)
                        .font(DS.Typography.headline)
                        .foregroundColor(DS.Colors.onSurface)
                    
                    Spacer()
                    
                    Text("\(Int(recommendation.confidence * 100))%")
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                }
                
                Text(recommendation.content)
                    .font(DS.Typography.body)
                    .foregroundColor(DS.Colors.onSurface)
                    .lineLimit(4)
                
                HStack {
                    Text(recommendation.timestamp.formatted(.relative(presentation: .named)))
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                    
                    Spacer()
                    
                    Button("View Details") {
                        showingRecommendation = true
                    }
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.primary)
                }
            }
        }
        .onTapGesture {
            showingRecommendation = true
        }
    }
    
    // MARK: - Actions
    
    private func loadPlayersIfNeeded() {
        guard playersViewModel.players.isEmpty else { return }
        
        Task {
            await playersViewModel.loadPlayers(apiService: apiService)
        }
    }
    
    private func getCaptainRecommendation() {
        guard !playersViewModel.players.isEmpty else {
            loadPlayersIfNeeded()
            return
        }
        
        selectedTool = .captainAdvisor
        
        Task {
            do {
                let topPlayers = playersViewModel.players.sorted { $0.projected > $1.projected }.prefix(15)
                let recommendation = try await openAIService.getCaptainRecommendation(for: Array(topPlayers))
                
                await MainActor.run {
                    currentRecommendation = recommendation
                    selectedTool = nil
                }
            } catch {
                await MainActor.run {
                    selectedTool = nil
                }
            }
        }
    }
    
    private func getTradeRecommendation() {
        guard !playersViewModel.players.isEmpty else {
            loadPlayersIfNeeded()
            return
        }
        
        selectedTool = .tradeSuggester
        
        Task {
            do {
                // Mock current team with top players
                let currentTeam = Array(playersViewModel.players.prefix(22))
                let availablePlayers = Array(playersViewModel.players.dropFirst(22).prefix(50))
                
                let recommendation = try await openAIService.getTradeRecommendation(
                    currentTeam: currentTeam,
                    availablePlayers: availablePlayers,
                    budget: 150000,
                    tradesRemaining: 15
                )
                
                await MainActor.run {
                    currentRecommendation = recommendation
                    selectedTool = nil
                }
            } catch {
                await MainActor.run {
                    selectedTool = nil
                }
            }
        }
    }
    
    private func getPriceAnalysis() {
        guard !playersViewModel.players.isEmpty else {
            loadPlayersIfNeeded()
            return
        }
        
        selectedTool = .pricePredictor
        
        Task {
            do {
                let playersToAnalyze = Array(playersViewModel.players.prefix(20))
                let recommendation = try await openAIService.analyzePriceMovements(players: playersToAnalyze, round: 15)
                
                await MainActor.run {
                    currentRecommendation = recommendation
                    selectedTool = nil
                }
            } catch {
                await MainActor.run {
                    selectedTool = nil
                }
            }
        }
    }
}

// MARK: - AIToolCard

struct AIToolCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let isLoading: Bool
    let action: () -> Void
    
    init(icon: String, title: String, description: String, color: Color, isLoading: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.description = description
        self.color = color
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.m) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(color)
                    }
                    
                    Spacer()
                }
                
                Text(title)
                    .font(DS.Typography.headline)
                    .foregroundColor(DS.Colors.onSurface)
                
                Text(description)
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
        }
        .frame(height: 140)
        .opacity(isLoading ? 0.7 : 1.0)
        .onTapGesture {
            if !isLoading {
                action()
            }
        }
        .dsAccessibility(
            label: "\(title): \(description)",
            traits: .isButton
        )
    }
}

// MARK: - AITool

enum AITool: String, CaseIterable {
    case captainAdvisor = "Captain Advisor"
    case tradeSuggester = "Trade Suggester"
    case pricePredictor = "Price Predictor"
}

// MARK: - Extensions

extension AIRecommendationType {
    var icon: String {
        switch self {
        case .captainAdvice: return "star.fill"
        case .tradeAdvice: return "arrow.triangle.swap"
        case .priceAnalysis: return "chart.line.uptrend.xyaxis"
        case .teamStructure: return "chart.bar.xaxis"
        }
    }
}

// MARK: - Previews

#if DEBUG
    struct AIToolsView_Previews: PreviewProvider {
        static var previews: some View {
            AIToolsView()
                .environmentObject(APIService.mock)
        }
    }
#endif
