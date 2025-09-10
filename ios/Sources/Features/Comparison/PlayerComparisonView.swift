import SwiftUI

@available(iOS 14.0, *)
struct PlayerComparisonView: View {
    @StateObject private var comparisonService = PlayerComparisonService()
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if comparisonService.comparisons.isEmpty {
                        EmptyComparisonState()
                    } else {
                        ComparisonGrid(comparisons: comparisonService.comparisons)
                    }
                    
                    if comparisonService.isLoading {
                        LoadingIndicator()
                    }
                }
                .padding()
            }
            .navigationTitle("Compare Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("Actions") {
                        Button("Clear All") {
                            comparisonService.clearAll()
                        }
                        Button("Export Comparison") {
                            // Export functionality
                        }
                    }
                    .disabled(comparisonService.comparisons.isEmpty)
                }
            }
        }
    }
}

@available(iOS 14.0, *)
private struct EmptyComparisonState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.crop.square.stack")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Players Selected")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add players from the Players tab to start comparing stats, form, and fixtures")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
}

@available(iOS 14.0, *)
private struct ComparisonGrid: View {
    let comparisons: [PlayerComparisonData]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(comparisons, id: \.player.id) { comparison in
                PlayerComparisonCard(comparison: comparison)
            }
        }
        
        if comparisons.count > 1 {
            ComparisonMetricsTable(comparisons: comparisons)
                .padding(.top)
        }
    }
}

@available(iOS 14.0, *)
private struct PlayerComparisonCard: View {
    let comparison: PlayerComparisonData
    @StateObject private var comparisonService = PlayerComparisonService()
    
    private var metrics: ComparisonMetrics {
        comparisonService.generateMetrics(for: comparison)
    }
    
    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 12) {
                // Player Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(comparison.player.name)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Text("\\(comparison.player.team) - \\(comparison.player.position.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        comparisonService.removePlayer(comparison.player.id)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .dsMinimumHitTarget()
                }
                
                Divider()
                
                // Key Stats
                VStack(spacing: 8) {
                    StatRow(label: "Price", value: comparison.player.price.formatted(.currency(code: "AUD")))
                    StatRow(label: "Average", value: String(format: "%.1f", comparison.player.average))
                    StatRow(label: "Projected", value: String(format: "%.1f", comparison.player.projected))
                    StatRow(label: "Breakeven", value: "\\(comparison.player.breakeven)")
                }
                
                Divider()
                
                // Form Trend
                HStack {
                    Text("Form")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        ForEach(comparison.recentForm.suffix(5), id: \\.self) { score in
                            Rectangle()
                                .fill(scoreColor(for: score))
                                .frame(width: 12, height: 20)
                        }
                    }
                    
                    Image(systemName: metrics.formTrend.icon)
                        .foregroundColor(trendColor(metrics.formTrend))
                        .font(.caption)
                }
                
                // Ownership
                HStack {
                    Text("Ownership")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\\(comparison.ownershipPercentage, specifier: \"%.1f\")%")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
    }
    
    private func scoreColor(for score: Double) -> Color {
        switch score {
        case 0..<60: return .red
        case 60..<80: return .orange
        case 80..<100: return .yellow
        case 100..<120: return .green
        default: return .blue
        }
    }
    
    private func trendColor(_ trend: FormTrend) -> Color {
        switch trend {
        case .improving: return .green
        case .stable: return .blue
        case .declining: return .red
        }
    }
}

@available(iOS 14.0, *)
private struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

@available(iOS 14.0, *)
private struct ComparisonMetricsTable: View {
    let comparisons: [PlayerComparisonData]
    @StateObject private var comparisonService = PlayerComparisonService()
    
    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Comparison Metrics")
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 8) {
                        // Headers
                        HStack(spacing: 16) {
                            Text("Player")
                                .frame(width: 100, alignment: .leading)
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            Text("Value")
                                .frame(width: 60, alignment: .center)
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            Text("Form")
                                .frame(width: 80, alignment: .center)
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            Text("Fixtures")
                                .frame(width: 70, alignment: .center)
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            Text("Risk")
                                .frame(width: 60, alignment: .center)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        Divider()
                        
                        // Data rows
                        ForEach(comparisons, id: \\.player.id) { comparison in
                            let metrics = comparisonService.generateMetrics(for: comparison)
                            
                            HStack(spacing: 16) {
                                Text(comparison.player.name)
                                    .frame(width: 100, alignment: .leading)
                                    .font(.caption)
                                    .lineLimit(1)
                                
                                Text(String(format: "%.2f", metrics.valueRating))
                                    .frame(width: 60, alignment: .center)
                                    .font(.caption)
                                
                                Text(metrics.formTrend.displayName)
                                    .frame(width: 80, alignment: .center)
                                    .font(.caption)
                                
                                Text(String(format: "%.1f", metrics.fixtureEase))
                                    .frame(width: 70, alignment: .center)
                                    .font(.caption)
                                
                                Text(metrics.injuryRisk.displayName)
                                    .frame(width: 60, alignment: .center)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
        }
    }
}

@available(iOS 14.0, *)
private struct LoadingIndicator: View {
    var body: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading comparison data...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Player Addition (for integration with PlayersView)

@available(iOS 14.0, *)
extension PlayerComparisonView {
    static func addPlayerToComparison(_ player: Player) {
        // This would be called from PlayersView
        // Implementation would depend on shared state management
        let service = PlayerComparisonService()
        Task {
            await service.addPlayer(player)
        }
    }
}

// MARK: - Previews

@available(iOS 14.0, *)
struct PlayerComparisonView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerComparisonView()
    }
}
