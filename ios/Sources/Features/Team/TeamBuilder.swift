import Foundation

// MARK: - Team Builder Models

public struct FantasyTeam {
    public let players: [TeamPlayer]
    public let budget: TeamBudget
    public let formation: TeamFormation
    public let captains: CaptainSelection
    public let validation: TeamValidation
    
    public init(players: [TeamPlayer], budget: TeamBudget, formation: TeamFormation,
                captains: CaptainSelection, validation: TeamValidation) {
        self.players = players
        self.budget = budget
        self.formation = formation
        self.captains = captains
        self.validation = validation
    }
}

public struct TeamPlayer {
    public let player: Player
    public let position: TeamPosition
    public let isSelected: Bool
    public let isCaptain: Bool
    public let isViceCaptain: Bool
    public let isOnField: Bool // vs bench
    
    public init(player: Player, position: TeamPosition, isSelected: Bool = false,
                isCaptain: Bool = false, isViceCaptain: Bool = false, isOnField: Bool = true) {
        self.player = player
        self.position = position
        self.isSelected = isSelected
        self.isCaptain = isCaptain
        self.isViceCaptain = isViceCaptain
        self.isOnField = isOnField
    }
}

public enum TeamPosition: String, CaseIterable {
    case def1, def2, def3, def4, def5, def6
    case mid1, mid2, mid3, mid4, mid5, mid6, mid7, mid8
    case ruck1, ruck2
    case fwd1, fwd2, fwd3, fwd4, fwd5, fwd6
    case bench1, bench2, bench3, bench4
    
    public var displayName: String {
        switch self {
        case .def1, .def2, .def3, .def4, .def5, .def6: return "DEF"
        case .mid1, .mid2, .mid3, .mid4, .mid5, .mid6, .mid7, .mid8: return "MID"
        case .ruck1, .ruck2: return "RUC"
        case .fwd1, .fwd2, .fwd3, .fwd4, .fwd5, .fwd6: return "FWD"
        case .bench1, .bench2, .bench3, .bench4: return "BENCH"
        }
    }
    
    public var isOnField: Bool {
        switch self {
        case .bench1, .bench2, .bench3, .bench4: return false
        default: return true
        }
    }
    
    public static var defensePositions: [TeamPosition] {
        [.def1, .def2, .def3, .def4, .def5, .def6]
    }
    
    public static var midFieldPositions: [TeamPosition] {
        [.mid1, .mid2, .mid3, .mid4, .mid5, .mid6, .mid7, .mid8]
    }
    
    public static var ruckPositions: [TeamPosition] {
        [.ruck1, .ruck2]
    }
    
    public static var forwardPositions: [TeamPosition] {
        [.fwd1, .fwd2, .fwd3, .fwd4, .fwd5, .fwd6]
    }
    
    public static var benchPositions: [TeamPosition] {
        [.bench1, .bench2, .bench3, .bench4]
    }
}

public struct TeamBudget {
    public let totalBudget: Int // 10,000,000
    public let spent: Int
    public let remaining: Int
    public let averagePlayerValue: Int
    
    public init(totalBudget: Int = 10_000_000, spent: Int) {
        self.totalBudget = totalBudget
        self.spent = spent
        self.remaining = totalBudget - spent
        self.averagePlayerValue = spent > 0 ? spent / 22 : 0
    }
}

public struct TeamFormation {
    public let defenders: Int
    public let midfielders: Int
    public let rucks: Int
    public let forwards: Int
    public let bench: Int
    
    public static let standard = TeamFormation(defenders: 6, midfielders: 8, rucks: 2, forwards: 6, bench: 4)
    
    public init(defenders: Int, midfielders: Int, rucks: Int, forwards: Int, bench: Int) {
        self.defenders = defenders
        self.midfielders = midfielders
        self.rucks = rucks
        self.forwards = forwards
        self.bench = bench
    }
    
    public var total: Int {
        defenders + midfielders + rucks + forwards + bench
    }
}

public struct CaptainSelection {
    public let captain: Player?
    public let viceCaptain: Player?
    public let emergencyCaptain: Player?
    
    public init(captain: Player? = nil, viceCaptain: Player? = nil, emergencyCaptain: Player? = nil) {
        self.captain = captain
        self.viceCaptain = viceCaptain
        self.emergencyCaptain = emergencyCaptain
    }
}

public struct TeamValidation {
    public let isValid: Bool
    public let issues: [ValidationIssue]
    public let warnings: [ValidationWarning]
    public let score: TeamScore
    
    public init(isValid: Bool, issues: [ValidationIssue], warnings: [ValidationWarning], score: TeamScore) {
        self.isValid = isValid
        self.issues = issues
        self.warnings = warnings
        self.score = score
    }
}

public struct ValidationIssue {
    public let type: IssueType
    public let message: String
    public let severity: IssueSeverity
    
    public init(type: IssueType, message: String, severity: IssueSeverity) {
        self.type = type
        self.message = message
        self.severity = severity
    }
}

public enum IssueType: String, CaseIterable {
    case budget, formation, captains, duplicates, positions
    
    public var displayName: String {
        switch self {
        case .budget: return "Budget"
        case .formation: return "Formation"
        case .captains: return "Captains"
        case .duplicates: return "Duplicates"
        case .positions: return "Positions"
        }
    }
}

public enum IssueSeverity: String, CaseIterable {
    case error, warning, info
    
    public var displayName: String {
        switch self {
        case .error: return "Error"
        case .warning: return "Warning"
        case .info: return "Info"
        }
    }
    
    public var color: String {
        switch self {
        case .error: return "red"
        case .warning: return "orange"
        case .info: return "blue"
        }
    }
}

public struct ValidationWarning {
    public let message: String
    public let recommendation: String
    
    public init(message: String, recommendation: String) {
        self.message = message
        self.recommendation = recommendation
    }
}

public struct TeamScore {
    public let projectedTotal: Double
    public let projectedAverage: Double
    public let valueRating: Double
    public let riskScore: Double
    public let captainScore: Double
    
    public init(projectedTotal: Double, projectedAverage: Double, valueRating: Double,
                riskScore: Double, captainScore: Double) {
        self.projectedTotal = projectedTotal
        self.projectedAverage = projectedAverage
        self.valueRating = valueRating
        self.riskScore = riskScore
        self.captainScore = captainScore
    }
}

// MARK: - Team Optimization

public struct OptimizationSuggestion {
    public let type: OptimizationType
    public let playerOut: Player?
    public let playerIn: Player?
    public let expectedImprovement: Double
    public let reason: String
    public let priority: OptimizationPriority
    
    public init(type: OptimizationType, playerOut: Player?, playerIn: Player?,
                expectedImprovement: Double, reason: String, priority: OptimizationPriority) {
        self.type = type
        self.playerOut = playerOut
        self.playerIn = playerIn
        self.expectedImprovement = expectedImprovement
        self.reason = reason
        self.priority = priority
    }
}

public enum OptimizationType: String, CaseIterable {
    case upgrade, downgrade, sideways, captain, formation
    
    public var displayName: String {
        switch self {
        case .upgrade: return "Upgrade"
        case .downgrade: return "Downgrade"
        case .sideways: return "Sideways"
        case .captain: return "Captain Change"
        case .formation: return "Formation Tweak"
        }
    }
}

public enum OptimizationPriority: Int, CaseIterable {
    case high = 1, medium = 2, low = 3
    
    public var displayName: String {
        switch self {
        case .high: return "High Priority"
        case .medium: return "Medium Priority"
        case .low: return "Low Priority"
        }
    }
    
    public var color: String {
        switch self {
        case .high: return "red"
        case .medium: return "orange"
        case .low: return "green"
        }
    }
}

// MARK: - Team Builder Service

@available(iOS 13.0, *)
public class TeamBuilderService: ObservableObject {
    @Published public private(set) var currentTeam: FantasyTeam?
    @Published public private(set) var isOptimizing = false
    @Published public private(set) var optimizationSuggestions: [OptimizationSuggestion] = []
    
    private let totalBudget = 10_000_000
    
    public init() {
        self.currentTeam = createEmptyTeam()
    }
    
    public func addPlayer(_ player: Player, to position: TeamPosition) {
        guard var team = currentTeam else { return }
        
        let teamPlayer = TeamPlayer(player: player, position: position, isSelected: true, isOnField: position.isOnField)
        var updatedPlayers = team.players.filter { $0.position != position }
        updatedPlayers.append(teamPlayer)
        
        let updatedTeam = updateTeamMetrics(players: updatedPlayers)
        currentTeam = updatedTeam
    }
    
    public func removePlayer(from position: TeamPosition) {
        guard var team = currentTeam else { return }
        
        let updatedPlayers = team.players.filter { $0.position != position }
        let updatedTeam = updateTeamMetrics(players: updatedPlayers)
        currentTeam = updatedTeam
    }
    
    public func setCaptain(_ player: Player) {
        guard var team = currentTeam else { return }
        
        var updatedPlayers = team.players.map { teamPlayer in
            var updated = teamPlayer
            updated = TeamPlayer(
                player: teamPlayer.player,
                position: teamPlayer.position,
                isSelected: teamPlayer.isSelected,
                isCaptain: teamPlayer.player.id == player.id,
                isViceCaptain: teamPlayer.isViceCaptain && teamPlayer.player.id != player.id,
                isOnField: teamPlayer.isOnField
            )
            return updated
        }
        
        let captains = CaptainSelection(
            captain: player,
            viceCaptain: team.captains.viceCaptain,
            emergencyCaptain: team.captains.emergencyCaptain
        )
        
        currentTeam = FantasyTeam(
            players: updatedPlayers,
            budget: team.budget,
            formation: team.formation,
            captains: captains,
            validation: team.validation
        )
    }
    
    public func optimizeTeam() async -> [OptimizationSuggestion] {
        await MainActor.run {
            self.isOptimizing = true
        }
        
        // Simulate optimization time
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        let suggestions = generateOptimizationSuggestions()
        
        await MainActor.run {
            self.optimizationSuggestions = suggestions
            self.isOptimizing = false
        }
        
        return suggestions
    }
    
    public func applyOptimization(_ suggestion: OptimizationSuggestion) {
        guard let team = currentTeam else { return }
        
        switch suggestion.type {
        case .upgrade, .downgrade, .sideways:
            if let playerOut = suggestion.playerOut,
               let playerIn = suggestion.playerIn,
               let position = team.players.first(where: { $0.player.id == playerOut.id })?.position {
                removePlayer(from: position)
                addPlayer(playerIn, to: position)
            }
        case .captain:
            if let newCaptain = suggestion.playerIn {
                setCaptain(newCaptain)
            }
        case .formation:
            // Formation changes would require more complex logic
            break
        }
    }
    
    public func clearTeam() {
        currentTeam = createEmptyTeam()
    }
    
    // MARK: - Private Methods
    
    private func createEmptyTeam() -> FantasyTeam {
        let emptyPlayers: [TeamPlayer] = []
        let budget = TeamBudget(spent: 0)
        let formation = TeamFormation.standard
        let captains = CaptainSelection()
        let validation = validateTeam(players: emptyPlayers, budget: budget, formation: formation, captains: captains)
        
        return FantasyTeam(
            players: emptyPlayers,
            budget: budget,
            formation: formation,
            captains: captains,
            validation: validation
        )
    }
    
    private func updateTeamMetrics(players: [TeamPlayer]) -> FantasyTeam {
        let totalSpent = players.reduce(0) { $0 + $1.player.price }
        let budget = TeamBudget(spent: totalSpent)
        let formation = TeamFormation.standard
        
        let captain = players.first { $0.isCaptain }?.player
        let viceCaptain = players.first { $0.isViceCaptain }?.player
        let captains = CaptainSelection(captain: captain, viceCaptain: viceCaptain)
        
        let validation = validateTeam(players: players, budget: budget, formation: formation, captains: captains)
        
        return FantasyTeam(
            players: players,
            budget: budget,
            formation: formation,
            captains: captains,
            validation: validation
        )
    }
    
    private func validateTeam(players: [TeamPlayer], budget: TeamBudget, formation: TeamFormation, captains: CaptainSelection) -> TeamValidation {
        var issues: [ValidationIssue] = []
        var warnings: [ValidationWarning] = []
        
        // Budget validation
        if budget.remaining < 0 {
            issues.append(ValidationIssue(
                type: .budget,
                message: "Team exceeds budget by \(abs(budget.remaining).formatted(.currency(code: "AUD")))",
                severity: .error
            ))
        }
        
        // Formation validation
        let selectedCount = players.count
        if selectedCount < 22 {
            issues.append(ValidationIssue(
                type: .formation,
                message: "Team needs \(22 - selectedCount) more players",
                severity: .error
            ))
        }
        
        // Captain validation
        if selectedCount >= 11 && captains.captain == nil {
            issues.append(ValidationIssue(
                type: .captains,
                message: "No captain selected",
                severity: .warning
            ))
        }
        
        // Position validation
        let positionCounts = Dictionary(grouping: players) { $0.player.position }
        if (positionCounts[.defender]?.count ?? 0) < 6 {
            issues.append(ValidationIssue(
                type: .positions,
                message: "Need more defenders",
                severity: .error
            ))
        }
        
        let projectedTotal = players.reduce(0.0) { $0 + $1.player.projected }
        let score = TeamScore(
            projectedTotal: projectedTotal,
            projectedAverage: selectedCount > 0 ? projectedTotal / Double(selectedCount) : 0,
            valueRating: budget.spent > 0 ? projectedTotal / Double(budget.spent) * 1_000_000 : 0,
            riskScore: Double.random(in: 0.3...0.8),
            captainScore: captains.captain?.projected ?? 0
        )
        
        return TeamValidation(
            isValid: issues.filter { $0.severity == .error }.isEmpty,
            issues: issues,
            warnings: warnings,
            score: score
        )
    }
    
    private func generateOptimizationSuggestions() -> [OptimizationSuggestion] {
        guard let team = currentTeam else { return [] }
        
        var suggestions: [OptimizationSuggestion] = []
        
        // Mock optimization suggestions
        if team.players.count >= 5 {
            let randomPlayer = team.players.randomElement()?.player
            suggestions.append(OptimizationSuggestion(
                type: .upgrade,
                playerOut: randomPlayer,
                playerIn: generateAlternativePlayer(for: randomPlayer),
                expectedImprovement: Double.random(in: 5...25),
                reason: "Better value and upcoming fixtures",
                priority: .medium
            ))
        }
        
        if team.captains.captain != nil {
            let bestCaptainCandidate = team.players.max { $0.player.projected < $1.player.projected }?.player
            suggestions.append(OptimizationSuggestion(
                type: .captain,
                playerOut: team.captains.captain,
                playerIn: bestCaptainCandidate,
                expectedImprovement: Double.random(in: 10...40),
                reason: "Higher ceiling for captaincy",
                priority: .high
            ))
        }
        
        return suggestions.sorted { $0.priority.rawValue < $1.priority.rawValue }
    }
    
    private func generateAlternativePlayer(for player: Player?) -> Player? {
        guard let player = player else { return nil }
        
        return Player(
            id: "alt_\(UUID().uuidString)",
            name: "Alternative Player",
            position: player.position,
            team: "ALT",
            price: player.price + Int.random(in: -50000...50000),
            average: Double.random(in: 70...120),
            projected: Double.random(in: 70...120),
            breakeven: Int.random(in: 40...80)
        )
    }
}
