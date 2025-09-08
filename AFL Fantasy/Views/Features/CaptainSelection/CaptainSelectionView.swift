import SwiftUI

struct CaptainSelectionView: View {
    @StateObject private var viewModel = CaptainSelectionViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Theme.Colors.background
                    .ignoresSafeArea()
                
                // Content
                VStack(spacing: 0) {
                    // Custom Navigation Bar
                    NavigationBar(
                        "Captain Selection",
                        leadingContent: {
                            NavigationBarButton(icon: "chevron.left") {
                                dismiss()
                            }
                        },
                        trailingContent: {
                            NavigationBarButton(
                                icon: "wand.and.stars",
                                isActive: viewModel.isAIEnabled
                            ) {
                                viewModel.toggleAI()
                            }
                        }
                    )
                    
                    ScrollView {
                        VStack(spacing: Theme.Spacing.l) {
                            // AI Recommendations (if enabled)
                            if viewModel.isAIEnabled {
                                AIRecommendationsCard(
                                    recommendations: viewModel.aiRecommendations
                                )
                            }
                            
                            // Recent Performance Chart
                            PerformanceChart(
                                games: viewModel.selectedPlayerGames,
                                projectedScore: viewModel.selectedPlayerProjection
                            )
                            
                            // Captain Options List
                            CaptainOptionsList(
                                players: viewModel.players,
                                selectedId: $viewModel.selectedPlayerId,
                                viceCaptainId: $viewModel.viceCaptainId
                            )
                        }
                        .padding()
                    }
                }
            }
            .onChange(of: viewModel.selectedPlayerId) { _ in
                viewModel.updatePlayerStats()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .onAppear {
                viewModel.loadData()
            }
        }
    }
}

// MARK: - Supporting Views

struct AIRecommendationsCard: View {
    let recommendations: [AIRecommendation]
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            // Header
            HStack {
                Text("AI Recommendations")
                    .font(Theme.Font.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Text("\(Int(topConfidence * 100))% Confidence")
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.success)
            }
            
            // Recommendations
            ForEach(recommendations) { rec in
                HStack(spacing: Theme.Spacing.m) {
                    // Rank Circle
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.accent.opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Text("\(rec.rank)")
                            .font(Theme.Font.bodyBold)
                            .foregroundColor(Theme.Colors.accent)
                    }
                    
                    VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                        Text(rec.playerName)
                            .font(Theme.Font.bodyBold)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text(rec.reason)
                            .font(Theme.Font.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Confidence Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Theme.Colors.textSecondary.opacity(0.1))
                            
                            Capsule()
                                .fill(Theme.Colors.success)
                                .frame(width: geo.size.width * rec.confidence)
                        }
                    }
                    .frame(width: 60, height: 4)
                }
                .padding(.vertical, Theme.Spacing.xs)
            }
        }
        .padding()
        .cardStyle()
    }
    
    private var topConfidence: Double {
        recommendations.first?.confidence ?? 0
    }
}

struct CaptainOptionsList: View {
    let players: [PlayerOption]
    @Binding var selectedId: String?
    @Binding var viceCaptainId: String?
    
    var body: some View {
        VStack(spacing: Theme.Spacing.s) {
            // Header
            HStack {
                Text("Your Team")
                    .font(Theme.Font.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Spacer()
                
                Menu {
                    Button("Sort by Name") {
                        // TODO: Implement sorting
                    }
                    Button("Sort by Position") {
                        // TODO: Implement sorting
                    }
                    Button("Sort by Average") {
                        // TODO: Implement sorting
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title3)
                }
            }
            
            // Player List
            ForEach(players) { player in
                PlayerSelectionRow(
                    player: player,
                    isCaptain: selectedId == player.id,
                    isViceCaptain: viceCaptainId == player.id
                ) { isViceCaptain in
                    if isViceCaptain {
                        if viceCaptainId == player.id {
                            viceCaptainId = nil
                        } else {
                            viceCaptainId = player.id
                        }
                    } else {
                        if selectedId == player.id {
                            selectedId = nil
                        } else {
                            selectedId = player.id
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
}

struct PlayerSelectionRow: View {
    let player: PlayerOption
    let isCaptain: Bool
    let isViceCaptain: Bool
    let onSelect: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: Theme.Spacing.m) {
            // Player Info
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(player.name)
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(player.position.shortName)
                    .font(Theme.Font.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
            
            // Stats
            VStack(alignment: .trailing, spacing: Theme.Spacing.xxs) {
                Text(String(format: "%.1f", player.projectedScore))
                    .font(Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("PROJ")
                    .font(Theme.Font.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .frame(width: 60)
            
            // Selection Controls
            HStack(spacing: Theme.Spacing.s) {
                // Vice Captain Button
                Button {
                    onSelect(true)
                } label: {
                    Image(systemName: isViceCaptain ? "v.circle.fill" : "v.circle")
                        .font(.title3)
                        .foregroundColor(isViceCaptain ? Theme.Colors.accent : Theme.Colors.textSecondary)
                }
                
                // Captain Button
                Button {
                    onSelect(false)
                } label: {
                    Image(systemName: isCaptain ? "c.circle.fill" : "c.circle")
                        .font(.title3)
                        .foregroundColor(isCaptain ? Theme.Colors.accent : Theme.Colors.textSecondary)
                }
            }
        }
        .padding()
        .background(Theme.Colors.background)
        .cornerRadius(Theme.Radius.medium)
    }
}

// Using PlayerOption and AIRecommendation from Models.swift

// MARK: - Preview

struct CaptainSelectionView_Previews: PreviewProvider {
    static var samplePlayers: [PlayerOption] {
        [
            .init(id: "1", name: "Marcus Bontempelli", position: .midfielder, price: 650000, projectedScore: 108.0, isSelected: true),
            .init(id: "2", name: "Jack Macrae", position: .midfielder, price: 620000, projectedScore: 100.5, isSelected: true),
            .init(id: "3", name: "Sam Walsh", position: .midfielder, price: 590000, projectedScore: 95.0, isSelected: true),
            .init(id: "4", name: "Max Gawn", position: .ruck, price: 720000, projectedScore: 112.0, isSelected: true)
        ]
    }
    
    static var sampleRecommendations: [AIRecommendation] {
        [
            .init(id: "1", type: .captain, confidence: 0.85, reasoning: "Strong form + favorable matchup", impact: "High", timestamp: Date()),
            .init(id: "2", type: .captain, confidence: 0.75, reasoning: "Consistent high scorer", impact: "Medium", timestamp: Date()),
            .init(id: "3", type: .captain, confidence: 0.65, reasoning: "Good historical vs opponent", impact: "Medium", timestamp: Date())
        ]
    }
    
    static var previews: some View {
        CaptainSelectionView()
            .previewDisplayName("Full Screen")
        
        ScrollView {
            VStack(spacing: Theme.Spacing.m) {
                AIRecommendationsCard(recommendations: sampleRecommendations)
                
                CaptainOptionsList(
                    players: samplePlayers,
                    selectedId: .constant("1"),
                    viceCaptainId: .constant("2")
                )
                
                PlayerSelectionRow(
                    player: samplePlayers[0],
                    isCaptain: true,
                    isViceCaptain: false
                ) { _ in }
            }
            .padding()
        }
        .previewDisplayName("Components")
        .previewLayout(.sizeThatFits)
    }
}
