import Foundation

// MARK: - Advanced Filters Model

public struct PlayerFilterCriteria: Codable, Equatable {
    public var position: Position?
    public var minPrice: Int?
    public var maxPrice: Int?
    public var minAverage: Double?
    public var minProjected: Double?
    public var breakevenBelow: Int?
    public var team: String?
    public var ownershipMinPercent: Double?
    public var formLast3Min: Double?
    public var upcomingFixtureDifficultyMax: Int?
    public var injuryStatusIncluded: InjuryStatusFilter = .all
    public var watchlistOnly: Bool = false

    public init(position: Position? = nil,
                minPrice: Int? = nil,
                maxPrice: Int? = nil,
                minAverage: Double? = nil,
                minProjected: Double? = nil,
                breakevenBelow: Int? = nil,
                team: String? = nil,
                ownershipMinPercent: Double? = nil,
                formLast3Min: Double? = nil,
                upcomingFixtureDifficultyMax: Int? = nil,
                injuryStatusIncluded: InjuryStatusFilter = .all,
                watchlistOnly: Bool = false) {
        self.position = position
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.minAverage = minAverage
        self.minProjected = minProjected
        self.breakevenBelow = breakevenBelow
        self.team = team
        self.ownershipMinPercent = ownershipMinPercent
        self.formLast3Min = formLast3Min
        self.upcomingFixtureDifficultyMax = upcomingFixtureDifficultyMax
        self.injuryStatusIncluded = injuryStatusIncluded
        self.watchlistOnly = watchlistOnly
    }
}

public enum InjuryStatusFilter: String, Codable, CaseIterable { case all, healthyOnly, excludeLongTerm }

// MARK: - Presets

public enum PlayerFilterPreset: String, CaseIterable {
    case cashCows = "Cash Cows"
    case premiumOptions = "Premium Options"
    case injuryRisks = "Injury Risks"

    public func criteria() -> PlayerFilterCriteria {
        switch self {
        case .cashCows:
            return PlayerFilterCriteria(maxPrice: 350_000, breakevenBelow: 30)
        case .premiumOptions:
            return PlayerFilterCriteria(minPrice: 700_000, minAverage: 95)
        case .injuryRisks:
            return PlayerFilterCriteria(injuryStatusIncluded: .excludeLongTerm) // Placeholder toggle
        }
    }
}

// MARK: - Filtering Service

public struct PlayerFilteringService {
    public init() {}

    public func apply(criteria: PlayerFilterCriteria, to players: [Player], watchlist: Set<String> = []) -> [Player] {
        var result = players
        if let pos = criteria.position { result = result.filter { $0.position == pos } }
        if let minP = criteria.minPrice { result = result.filter { $0.price >= minP } }
        if let maxP = criteria.maxPrice { result = result.filter { $0.price <= maxP } }
        if let minA = criteria.minAverage { result = result.filter { $0.average >= minA } }
        if let minProj = criteria.minProjected { result = result.filter { $0.projected >= minProj } }
        if let beBelow = criteria.breakevenBelow { result = result.filter { $0.breakeven <= beBelow } }
        if let team = criteria.team, !team.isEmpty { result = result.filter { $0.team == team } }
        if criteria.watchlistOnly { result = result.filter { watchlist.contains($0.id) } }
        // Note: ownership %, form, fixture difficulty require more data; left for integration
        return result
    }
}

