import Foundation

// MARK: - Fixture Analysis Models

public struct FixtureDifficultyMatrix {
    public let team: String
    public let position: Position
    public let nextRounds: [FixtureDifficultyEntry]
    
    public init(team: String, position: Position, nextRounds: [FixtureDifficultyEntry]) {
        self.team = team
        self.position = position
        self.nextRounds = nextRounds
    }
}

public struct FixtureDifficultyEntry {
    public let round: Int
    public let opponent: String
    public let isHome: Bool
    public let difficulty: FixtureDifficulty // 1 very easy - 5 very hard
    public let venue: String
    public let weatherImpact: WeatherImpact
    
    public init(round: Int, opponent: String, isHome: Bool, difficulty: FixtureDifficulty, venue: String, weatherImpact: WeatherImpact) {
        self.round = round
        self.opponent = opponent
        self.isHome = isHome
        self.difficulty = difficulty
        self.venue = venue
        self.weatherImpact = weatherImpact
    }
}

public struct TeamFormTrend {
    public let team: String
    public let last5: [Int] // aggregate opponent score difficulty trend
    public let trend: TrendDirection
    
    public init(team: String, last5: [Int], trend: TrendDirection) {
        self.team = team
        self.last5 = last5
        self.trend = trend
    }
}

public struct FixturePlanSuggestion {
    public let player: Player
    public let weeks: Int
    public let plan: [FixturePlanStep]
    public let expectedBenefit: Double
    public let rationale: String
    
    public init(player: Player, weeks: Int, plan: [FixturePlanStep], expectedBenefit: Double, rationale: String) {
        self.player = player
        self.weeks = weeks
        self.plan = plan
        self.expectedBenefit = expectedBenefit
        self.rationale = rationale
    }
}

public struct FixturePlanStep {
    public let round: Int
    public let action: String // e.g., "Hold", "Trade In", "Trade Out"
    public let note: String
    
    public init(round: Int, action: String, note: String) {
        self.round = round
        self.action = action
        self.note = note
    }
}

// MARK: - Fixture Analysis Service

@available(iOS 13.0, *)
public class FixtureAnalysisService: ObservableObject {
    @Published public private(set) var difficultyMatrices: [FixtureDifficultyMatrix] = []
    @Published public private(set) var teamForm: [TeamFormTrend] = []
    @Published public private(set) var plans: [FixturePlanSuggestion] = []
    @Published public private(set) var isLoading = false
    
    public init() {}
    
    public func buildDifficultyMatrices(for teams: [String], positions: [Position]) async -> [FixtureDifficultyMatrix] {
        await MainActor.run { self.isLoading = true }
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let matrices = teams.flatMap { team in
            positions.map { pos in
                FixtureDifficultyMatrix(
                    team: team,
                    position: pos,
                    nextRounds: (1...6).map { r in
                        FixtureDifficultyEntry(
                            round: r,
                            opponent: ["COL","ESS","CAR","GEE","FRE"].randomElement() ?? "OPP",
                            isHome: Bool.random(),
                            difficulty: FixtureDifficulty.allCases.randomElement() ?? .medium,
                            venue: "Venue",
                            weatherImpact: WeatherImpact.allCases.randomElement() ?? .none
                        )
                    }
                )
            }
        }
        await MainActor.run { self.difficultyMatrices = matrices; self.isLoading = false }
        return matrices
    }
    
    public func analyzeTeamForm(for teams: [String]) async -> [TeamFormTrend] {
        try? await Task.sleep(nanoseconds: 800_000_000)
        let forms = teams.map { team in
            let last5 = (1...5).map { _ in Int.random(in: 1...5) }
            let trend: TrendDirection = [.stronglyUp, .up, .stable, .down, .stronglyDown].randomElement() ?? .stable
            return TeamFormTrend(team: team, last5: last5, trend: trend)
        }
        await MainActor.run { self.teamForm = forms }
        return forms
    }
    
    public func createFixturePlans(for players: [Player], weeks: Int = 4) async -> [FixturePlanSuggestion] {
        try? await Task.sleep(nanoseconds: 800_000_000)
        let generated = players.prefix(10).map { player in
            FixturePlanSuggestion(
                player: player,
                weeks: weeks,
                plan: (1...weeks).map { r in FixturePlanStep(round: r, action: ["Hold","Trade In","Trade Out"].randomElement()!, note: "Note \(r)") },
                expectedBenefit: Double.random(in: 10...80),
                rationale: "Based on upcoming fixtures and form"
            )
        }
        await MainActor.run { self.plans = generated }
        return generated
    }
}

