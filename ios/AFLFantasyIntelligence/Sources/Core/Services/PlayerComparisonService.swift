import Foundation

// MARK: - PlayerComparisonService

@MainActor
final class PlayerComparisonService: ObservableObject {
    @Published var isAnalyzing = false
    
    func comparePlayers(_ players: [Player]) async throws -> PlayerComparisonData {
        isAnalyzing = true
        defer { isAnalyzing = false }
        
        // Simulate processing work
        try await Task.sleep(for: .seconds(1))
        
        // Build summary metrics across selected players (up to 3 shown in table)
        let top = Array(players.prefix(3))
        let prices = top.map { Double($0.price) }
        let averages = top.map { $0.average }
        let projected = top.map { $0.projected }
        let beValues = top.map { Double($0.breakeven) }
        
        let summaries: [ComparisonSummaryMetric] = [
            .init(metric: "Price", values: prices.map { "$\(Int($0/1000))K" }, bestPlayerIndex: prices.firstIndex(of: prices.min() ?? 0) ?? 0),
            .init(metric: "Average", values: averages.map { String(format: "%.1f", $0) }, bestPlayerIndex: averages.firstIndex(of: averages.max() ?? 0) ?? 0),
            .init(metric: "Projected", values: projected.map { String(format: "%.1f", $0) }, bestPlayerIndex: projected.firstIndex(of: projected.max() ?? 0) ?? 0),
            .init(metric: "Breakeven", values: beValues.map { String(Int($0)) }, bestPlayerIndex: beValues.firstIndex(of: beValues.min() ?? 0) ?? 0)
        ]
        
        // Determine best value = highest projected per $1000 cost
        let values: [Double] = top.map { p in p.projected / Double(max(1, p.price / 1000)) }
        let bestIdx = values.firstIndex(of: values.max() ?? 0) ?? 0
        let bestValue = BestValueResult(playerName: top[bestIdx].name, reason: "Best points-per-dollar among compared players")
        
        // Basic risk assessment based on price and breakeven
        let risk: [PlayerRiskAssessment] = top.map { p in
            let riskLevel: RiskLevel = (p.breakeven > 80) ? .high : (p.breakeven > 40 ? .medium : .low)
            return PlayerRiskAssessment(playerName: p.name, riskLevel: riskLevel)
        }
        
        // Quick recommendations
        var recs: [String] = []
        if let idx = projected.firstIndex(of: projected.max() ?? 0) {
            recs.append("Highest projection: \(top[idx].name)")
        }
        if let idx = beValues.firstIndex(of: beValues.min() ?? 0) {
            recs.append("Best breakeven: \(top[idx].name)")
        }
        if let idx = prices.firstIndex(of: prices.min() ?? 0) {
            recs.append("Cheapest option: \(top[idx].name)")
        }
        
        return PlayerComparisonData(
            summaryMetrics: summaries,
            bestValuePlayer: bestValue,
            riskAssessments: risk,
            recommendations: recs
        )
    }
}

// MARK: - Models

struct PlayerComparisonData {
    let summaryMetrics: [ComparisonSummaryMetric]
    let bestValuePlayer: BestValueResult?
    let riskAssessments: [PlayerRiskAssessment]
    let recommendations: [String]
}

struct ComparisonSummaryMetric {
    let metric: String
    let values: [String] // aligned with players shown
    let bestPlayerIndex: Int
}

struct BestValueResult {
    let playerName: String
    let reason: String
}

struct PlayerRiskAssessment {
    let playerName: String
    let riskLevel: RiskLevel
}

