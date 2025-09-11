import Foundation

/// Defines different strategies for team optimization
enum OptimizationStrategy: String, CaseIterable {
    case balanced = "Balanced"
    case highCeiling = "High Ceiling"
    case consistent = "Consistent Scorers"
    case value = "Value Generation"
    case differential = "Unique Picks"
    
    var description: String {
        switch self {
        case .balanced:
            "Optimizes for a mix of consistency, ceiling, and value"
        case .highCeiling:
            "Prioritizes players with high scoring potential"
        case .consistent:
            "Focuses on players with reliable, stable scoring"
        case .value:
            "Targets players likely to increase in value"
        case .differential:
            "Selects high-upside players with low ownership"
        }
    }
}

/// Represents a suggestion from the optimizer
struct OptimizerSuggestion: Identifiable {
    let id = UUID()
    let type: SuggestionType
    let description: String
    let impact: ImpactLevel
    let trades: [(out: Player, in: Player)]
    let projectedPoints: Double
    let confidence: Double  // 0-1
    
    enum SuggestionType {
        case upgrade
        case rookieDowngrade
        case sidewaysTradeValue
        case positionBalance
        case riskMitigation
    }
    
    enum ImpactLevel: Int, Comparable {
        case low = 1
        case medium
        case high
        case critical
        
        static func < (lhs: ImpactLevel, rhs: ImpactLevel) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

/// Represents a validation issue with the current team structure
struct ValidationIssue: Identifiable {
    let id = UUID()
    let category: Category
    let description: String
    let severity: OptimizerSuggestion.ImpactLevel
    
    enum Category {
        case positionCount
        case salary
        case rookieExposure
        case injuryRisk
        case byeRoundExposure
        case valueDistribution
    }
}

/// Team structure metrics used for analysis and optimization
struct TeamMetrics {
    let positionBalance: [Position: Int]
    let priceDistribution: [Int: Int]  // Price bracket -> Count
    let rookieCount: Int
    let premiumCount: Int
    let injuryRiskScore: Double  // 0-100
    let valueGenerationPotential: Double  // Expected price increase
    let consistencyScore: Double  // 0-100
    let uniquenessScore: Double  // % of differential picks
}
