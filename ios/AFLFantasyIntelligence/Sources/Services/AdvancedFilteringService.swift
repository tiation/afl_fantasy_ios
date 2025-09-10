import Foundation

// MARK: - AdvancedFilteringService

@MainActor
final class AdvancedFilteringService: ObservableObject {
    @Published var isApplying = false
    @Published var activeFilters: PlayerFilterRequest?
    @Published var filteredPlayerCount = 0
    
    func applyFilters(_ filters: PlayerFilterRequest) async throws {
        isApplying = true
        defer { isApplying = false }
        
        // Simulate processing time
        try await Task.sleep(for: .seconds(1))
        
        activeFilters = filters
        
        // Mock filtered count calculation
        let baseCount = 600
        var reductionFactor = 0.0
        
        if !filters.positions.isEmpty {
            reductionFactor += 0.7 // Significant reduction for position filtering
        }
        
        if !filters.teams.isEmpty {
            reductionFactor += 0.6 // Significant reduction for team filtering
        }
        
        if !filters.criteria.isEmpty {
            reductionFactor += Double(filters.criteria.count) * 0.2
        }
        
        if filters.preset != nil {
            reductionFactor += 0.3
        }
        
        if filters.watchlistOnly {
            reductionFactor += 0.8 // Major reduction for watchlist only
        }
        
        filteredPlayerCount = max(20, Int(Double(baseCount) * (1.0 - min(reductionFactor, 0.95))))
    }
    
    func clearFilters() {
        activeFilters = nil
        filteredPlayerCount = 0
    }
}

// MARK: - Filter Models

struct PlayerFilterRequest {
    let positions: [Position]
    let teams: [String]
    let priceRange: ClosedRange<Int>
    let minAverage: Double
    let minProjected: Double
    let maxBreakeven: Int
    let criteria: [FilterCriteria]
    let preset: FilterPreset?
    let watchlistOnly: Bool
    let activeOnly: Bool
    let includeInjuryRisk: Bool
}

enum FilterCriteria: String, CaseIterable, Hashable {
    case highOwnership = "high_ownership"
    case lowOwnership = "low_ownership"
    case priceRising = "price_rising"
    case priceFalling = "price_falling"
    case consistentScorer = "consistent_scorer"
    case volatileScorer = "volatile_scorer"
    case goodFixtures = "good_fixtures"
    case difficultFixtures = "difficult_fixtures"
    case outperformingBreakeven = "outperforming_breakeven"
    case underperformingBreakeven = "underperforming_breakeven"
    case lowInjuryRisk = "low_injury_risk"
    case highInjuryRisk = "high_injury_risk"
    case newToTeam = "new_to_team"
    case veteranPlayer = "veteran_player"
    
    var displayName: String {
        switch self {
        case .highOwnership: return "High Ownership (>20%)"
        case .lowOwnership: return "Low Ownership (<5%)"
        case .priceRising: return "Price Rising"
        case .priceFalling: return "Price Falling"
        case .consistentScorer: return "Consistent Scorer"
        case .volatileScorer: return "Volatile Scorer"
        case .goodFixtures: return "Good Upcoming Fixtures"
        case .difficultFixtures: return "Difficult Fixtures"
        case .outperformingBreakeven: return "Outperforming Breakeven"
        case .underperformingBreakeven: return "Underperforming Breakeven"
        case .lowInjuryRisk: return "Low Injury Risk"
        case .highInjuryRisk: return "High Injury Risk"
        case .newToTeam: return "New to Team"
        case .veteranPlayer: return "Veteran Player (5+ seasons)"
        }
    }
}

enum FilterPreset: String, CaseIterable, Hashable {
    case premiums = "premiums"
    case rookies = "rookies"
    case captainOptions = "captain_options"
    case cashCows = "cash_cows"
    case differentials = "differentials"
    case keepers = "keepers"
    
    var displayName: String {
        switch self {
        case .premiums: return "Premiums"
        case .rookies: return "Rookies"
        case .captainOptions: return "Captain Options"
        case .cashCows: return "Cash Cows"
        case .differentials: return "Differentials"
        case .keepers: return "Keepers"
        }
    }
    
    var icon: String {
        switch self {
        case .premiums: return "crown.fill"
        case .rookies: return "leaf.fill"
        case .captainOptions: return "star.fill"
        case .cashCows: return "dollarsign.circle.fill"
        case .differentials: return "chart.line.uptrend.xyaxis"
        case .keepers: return "lock.fill"
        }
    }
    
    var description: String {
        switch self {
        case .premiums: return "High-priced, proven performers"
        case .rookies: return "Low-priced, high-potential players"
        case .captainOptions: return "Reliable weekly captain choices"
        case .cashCows: return "Price-rising value players"
        case .differentials: return "Low-owned upside plays"
        case .keepers: return "Set-and-forget players"
        }
    }
}
