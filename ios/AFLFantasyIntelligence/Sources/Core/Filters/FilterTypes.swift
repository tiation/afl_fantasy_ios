import Foundation
import SwiftUI

// MARK: - Filter Criteria

enum FilterCriteria: String, CaseIterable, Hashable, Codable, Sendable {
    case highOwnership
    case lowOwnership
    case priceRising
    case outperformingBreakeven
    case consistentScorer
    case goodFixtures
    case lowInjuryRisk

    var displayName: String {
        switch self {
        case .highOwnership: "High Ownership"
        case .lowOwnership: "Low Ownership (Differential)"
        case .priceRising: "Price Rising"
        case .outperformingBreakeven: "Outperforming Breakeven"
        case .consistentScorer: "Consistent Scorer"
        case .goodFixtures: "Favourable Fixtures"
        case .lowInjuryRisk: "Low Injury Risk"
        }
    }
}

// MARK: - Filter Presets

enum FilterPreset: String, CaseIterable, Codable, Sendable {
    case premiums
    case rookies
    case captainOptions
    case cashCows
    case differentials
    case keepers

    var displayName: String {
        switch self {
        case .premiums: "Premiums"
        case .rookies: "Rookies"
        case .captainOptions: "Captain Options"
        case .cashCows: "Cash Cows"
        case .differentials: "Differentials"
        case .keepers: "Keepers"
        }
    }

    var icon: String {
        switch self {
        case .premiums: "star.fill"
        case .rookies: "leaf.fill"
        case .captainOptions: "crown.fill"
        case .cashCows: "dollarsign.circle.fill"
        case .differentials: "sparkles"
        case .keepers: "lock.fill"
        }
    }
}

// MARK: - Performance Filters

struct PerformanceFilters: Codable, Sendable, Hashable {
    var minAverage: Double = 0.0
    var minProjected: Double = 0.0
    var maxBreakeven: Double = 100.0
}

// MARK: - PlayerFilterRequest

struct PlayerFilterRequest: Codable, Sendable {
    var positions: [Position]
    var teams: [String]
    var priceRange: ClosedRange<Int>
    var minAverage: Double
    var minProjected: Double
    var maxBreakeven: Int
    var criteria: [FilterCriteria]
    var preset: FilterPreset?
    var watchlistOnly: Bool
    var activeOnly: Bool
    var includeInjuryRisk: Bool
}

