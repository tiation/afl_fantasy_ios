import Foundation

// MARK: - TradeAnalyzerService

@MainActor
final class TradeAnalyzerService: ObservableObject {
    @Published var isAnalyzing = false
    @Published var lastAnalysis: TradeAnalysisResult?
    
    func analyzeTrade(
        playersIn: [Player],
        playersOut: [Player], 
        currentBudget: Int,
        tradesRemaining: Int
    ) async throws -> TradeAnalysisResult {
        isAnalyzing = true
        defer { isAnalyzing = false }
        
        // Simulate analysis time
        try await Task.sleep(for: .seconds(2))
        
        let cashImpact = calculateCashImpact(playersIn: playersIn, playersOut: playersOut)
        let pointsImpact = calculatePointsImpact(playersIn: playersIn, playersOut: playersOut)
        let riskAssessment = assessRisk(playersIn: playersIn, playersOut: playersOut)
        
        let result = TradeAnalysisResult(
            overallRating: calculateOverallRating(
                cashImpact: cashImpact,
                pointsImpact: pointsImpact,
                risk: riskAssessment
            ),
            recommendation: generateRecommendation(
                cashImpact: cashImpact,
                pointsImpact: pointsImpact,
                risk: riskAssessment
            ),
            cashImpact: cashImpact,
            pointsPerWeek: pointsImpact,
            riskLevel: riskAssessment,
            detailedMetrics: generateDetailedMetrics(
                playersIn: playersIn,
                playersOut: playersOut,
                cashImpact: cashImpact,
                pointsImpact: pointsImpact
            ),
            recommendations: generateRecommendations(
                playersIn: playersIn,
                playersOut: playersOut,
                riskLevel: riskAssessment
            )
        )
        
        lastAnalysis = result
        return result
    }
    
    // MARK: - Private Analysis Methods
    
    private func calculateCashImpact(playersIn: [Player], playersOut: [Player]) -> Double {
        let totalIn = playersIn.reduce(0) { $0 + Double($1.price) }
        let totalOut = playersOut.reduce(0) { $0 + Double($1.price) }
        return totalOut - totalIn
    }
    
    private func calculatePointsImpact(playersIn: [Player], playersOut: [Player]) -> Double {
        let projectedIn = playersIn.reduce(0) { $0 + $1.projected }
        let projectedOut = playersOut.reduce(0) { $0 + $1.projected }
        return projectedIn - projectedOut
    }
    
    private func assessRisk(playersIn: [Player], playersOut: [Player]) -> RiskLevel {
        // Simple risk assessment based on price and form
        let avgPriceIn = playersIn.isEmpty ? 0 : playersIn.reduce(0) { $0 + $1.price } / playersIn.count
        let avgPriceOut = playersOut.isEmpty ? 0 : playersOut.reduce(0) { $0 + $1.price } / playersOut.count
        
        let priceDifference = abs(Double(avgPriceIn - avgPriceOut))
        
        if priceDifference > 200000 {
            return .high
        } else if priceDifference > 100000 {
            return .medium
        } else {
            return .low
        }
    }
    
    private func calculateOverallRating(
        cashImpact: Double,
        pointsImpact: Double,
        risk: RiskLevel
    ) -> Double {
        var rating = 5.0 // Base rating
        
        // Points impact (most important)
        rating += min(max(pointsImpact / 10.0, -3.0), 3.0)
        
        // Cash impact (moderate importance)
        rating += min(max(cashImpact / 50000.0, -1.5), 1.5)
        
        // Risk penalty
        switch risk {
        case .low: rating += 0.5
        case .medium: rating += 0.0
        case .high: rating -= 1.0
        }
        
        return min(max(rating, 0.0), 10.0)
    }
    
    private func generateRecommendation(
        cashImpact: Double,
        pointsImpact: Double,
        risk: RiskLevel
    ) -> String {
        let overallRating = calculateOverallRating(
            cashImpact: cashImpact,
            pointsImpact: pointsImpact,
            risk: risk
        )
        
        if overallRating >= 7.5 {
            return "Excellent trade! Strong projected point gains with manageable risk."
        } else if overallRating >= 6.0 {
            return "Good trade. Solid improvements expected."
        } else if overallRating >= 4.0 {
            return "Decent trade with some upside potential."
        } else {
            return "Consider alternative options. High risk or limited upside."
        }
    }
    
    private func generateDetailedMetrics(
        playersIn: [Player],
        playersOut: [Player],
        cashImpact: Double,
        pointsImpact: Double
    ) -> [TradeMetric] {
        var metrics: [TradeMetric] = []
        
        if !playersIn.isEmpty {
            let avgProjectedIn = playersIn.reduce(0) { $0 + $1.projected } / Double(playersIn.count)
            metrics.append(TradeMetric(
                title: "Avg Projected (In)",
                value: String(format: "%.1f", avgProjectedIn)
            ))
        }
        
        if !playersOut.isEmpty {
            let avgProjectedOut = playersOut.reduce(0) { $0 + $1.projected } / Double(playersOut.count)
            metrics.append(TradeMetric(
                title: "Avg Projected (Out)",
                value: String(format: "%.1f", avgProjectedOut)
            ))
        }
        
        metrics.append(TradeMetric(
            title: "Weekly Points Gain",
            value: String(format: "%.1f", pointsImpact)
        ))
        
        metrics.append(TradeMetric(
            title: "Remaining Budget Impact",
            value: String(format: "$%.0fK", cashImpact / 1000)
        ))
        
        return metrics
    }
    
    private func generateRecommendations(
        playersIn: [Player],
        playersOut: [Player],
        riskLevel: RiskLevel
    ) -> [String] {
        var recommendations: [String] = []
        
        if riskLevel == .high {
            recommendations.append("Consider the injury risk of players being traded in")
        }
        
        if playersIn.contains(where: { $0.price > 600000 }) {
            recommendations.append("Monitor price changes closely for premium players")
        }
        
        if playersOut.contains(where: { $0.average > 90 }) {
            recommendations.append("Ensure you have captain alternatives before trading out high scorers")
        }
        
        recommendations.append("Check fixture difficulty for next 3-4 weeks")
        
        return recommendations
    }
}

// MARK: - Models

struct TradeAnalysisResult {
    let overallRating: Double
    let recommendation: String
    let cashImpact: Double
    let pointsPerWeek: Double
    let riskLevel: RiskLevel
    let detailedMetrics: [TradeMetric]
    let recommendations: [String]
}

struct TradeMetric {
    let title: String
    let value: String
}

enum RiskLevel: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}
