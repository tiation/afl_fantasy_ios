import Foundation

// MARK: - Player Comparison Models

public struct PlayerComparisonData {
    public let player: Player
    public let recentForm: [Double] // Last 5 games scores
    public let priceHistory: [PricePoint]
    public let upcomingFixtures: [FixturePreview]
    public let ownershipPercentage: Double
    public let injuryHistory: [InjuryRecord]
    
    public init(player: Player, recentForm: [Double] = [], priceHistory: [PricePoint] = [], 
                upcomingFixtures: [FixturePreview] = [], ownershipPercentage: Double = 0,
                injuryHistory: [InjuryRecord] = []) {
        self.player = player
        self.recentForm = recentForm
        self.priceHistory = priceHistory
        self.upcomingFixtures = upcomingFixtures
        self.ownershipPercentage = ownershipPercentage
        self.injuryHistory = injuryHistory
    }
}

public struct PricePoint: Codable {
    public let round: Int
    public let price: Int
    public let date: Date
    
    public init(round: Int, price: Int, date: Date) {
        self.round = round
        self.price = price
        self.date = date
    }
}

public struct FixturePreview: Codable {
    public let round: Int
    public let opponent: String
    public let isHome: Bool
    public let difficulty: Int // 1-5 scale
    
    public init(round: Int, opponent: String, isHome: Bool, difficulty: Int) {
        self.round = round
        self.opponent = opponent
        self.isHome = isHome
        self.difficulty = difficulty
    }
}

public struct InjuryRecord: Codable {
    public let type: String
    public let startRound: Int
    public let endRound: Int?
    public let severity: InjurySeverity
    
    public init(type: String, startRound: Int, endRound: Int?, severity: InjurySeverity) {
        self.type = type
        self.startRound = startRound
        self.endRound = endRound
        self.severity = severity
    }
}

public enum InjurySeverity: String, Codable, CaseIterable {
    case minor, moderate, major
    
    public var displayName: String {
        switch self {
        case .minor: return "Minor"
        case .moderate: return "Moderate"
        case .major: return "Major"
        }
    }
}

// MARK: - Comparison Metrics

public struct ComparisonMetrics {
    public let valueRating: Double // Price vs performance ratio
    public let formTrend: FormTrend
    public let fixtureEase: Double // Average difficulty over next 3 rounds
    public let injuryRisk: InjuryRisk
    
    public init(valueRating: Double, formTrend: FormTrend, fixtureEase: Double, injuryRisk: InjuryRisk) {
        self.valueRating = valueRating
        self.formTrend = formTrend
        self.fixtureEase = fixtureEase
        self.injuryRisk = injuryRisk
    }
}

public enum FormTrend: String, CaseIterable {
    case improving, stable, declining
    
    public var displayName: String {
        switch self {
        case .improving: return "Improving"
        case .stable: return "Stable"
        case .declining: return "Declining"
        }
    }
}

public enum InjuryRisk: String, CaseIterable {
    case low, medium, high
    
    public var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

// MARK: - Comparison Service

@available(iOS 13.0, *)
public class PlayerComparisonService: ObservableObject {
    @Published public private(set) var comparisons: [PlayerComparisonData] = []
    @Published public private(set) var isLoading = false
    
    public init() {}
    
    public func addPlayer(_ player: Player) {
        guard comparisons.count < 4, !comparisons.contains(where: { $0.player.id == player.id }) else { return }
        
        isLoading = true
        
        // Simulate data loading - in real implementation would fetch from API
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let comparisonData = self.generateMockComparisonData(for: player)
            self.comparisons.append(comparisonData)
            self.isLoading = false
        }
    }
    
    public func removePlayer(_ playerId: String) {
        comparisons.removeAll { $0.player.id == playerId }
    }
    
    public func clearAll() {
        comparisons.removeAll()
    }
    
    public func generateMetrics(for data: PlayerComparisonData) -> ComparisonMetrics {
        let valueRating = calculateValueRating(data)
        let formTrend = calculateFormTrend(data.recentForm)
        let fixtureEase = calculateFixtureEase(data.upcomingFixtures)
        let injuryRisk = calculateInjuryRisk(data.injuryHistory)
        
        return ComparisonMetrics(valueRating: valueRating, formTrend: formTrend, 
                               fixtureEase: fixtureEase, injuryRisk: injuryRisk)
    }
    
    // MARK: - Private Helpers
    
    private func generateMockComparisonData(for player: Player) -> PlayerComparisonData {
        let recentForm = (1...5).map { _ in Double.random(in: 40...120) }
        let priceHistory = (1...10).map { round in 
            PricePoint(round: round, price: player.price + Int.random(in: -50000...50000), date: Date())
        }
        let upcomingFixtures = (1...3).map { round in
            FixturePreview(round: round, opponent: "OPP", isHome: Bool.random(), difficulty: Int.random(in: 1...5))
        }
        
        return PlayerComparisonData(
            player: player,
            recentForm: recentForm,
            priceHistory: priceHistory,
            upcomingFixtures: upcomingFixtures,
            ownershipPercentage: Double.random(in: 0...100),
            injuryHistory: []
        )
    }
    
    private func calculateValueRating(_ data: PlayerComparisonData) -> Double {
        guard data.player.price > 0 else { return 0 }
        return data.player.average / Double(data.player.price) * 1_000_000
    }
    
    private func calculateFormTrend(_ recentForm: [Double]) -> FormTrend {
        guard recentForm.count >= 3 else { return .stable }
        let recent = Array(recentForm.suffix(3))
        let older = Array(recentForm.prefix(recentForm.count - 3).suffix(3))
        
        let recentAvg = recent.reduce(0, +) / Double(recent.count)
        let olderAvg = older.reduce(0, +) / Double(max(older.count, 1))
        
        if recentAvg > olderAvg * 1.1 { return .improving }
        if recentAvg < olderAvg * 0.9 { return .declining }
        return .stable
    }
    
    private func calculateFixtureEase(_ fixtures: [FixturePreview]) -> Double {
        guard !fixtures.isEmpty else { return 3.0 }
        return Double(fixtures.map { $0.difficulty }.reduce(0, +)) / Double(fixtures.count)
    }
    
    private func calculateInjuryRisk(_ injuries: [InjuryRecord]) -> InjuryRisk {
        guard !injuries.isEmpty else { return .low }
        let recentInjuries = injuries.filter { $0.startRound >= (25 - 5) } // Last 5 rounds
        
        if recentInjuries.count >= 2 || recentInjuries.contains(where: { $0.severity == .major }) {
            return .high
        } else if recentInjuries.count == 1 {
            return .medium
        }
        return .low
    }
}
