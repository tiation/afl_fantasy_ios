import Foundation
import Combine

@MainActor
final class TeamBuilderService: ObservableObject {
    @Published private(set) var currentTeamMetrics: TeamMetrics?
    @Published private(set) var validationIssues: [ValidationIssue] = []
    @Published private(set) var suggestions: [OptimizerSuggestion] = []
    @Published private(set) var isOptimizing: Bool = false
    
    private let teamManager: TeamManager
    private var subscriptions = Set<AnyCancellable>()
    
    init(teamManager: TeamManager) {
        self.teamManager = teamManager
        setupSubscriptions()
    }
    
    // MARK: - Public Methods
    
    /// Analyzes team structure and generates validation issues
    func validateTeam() async {
        var issues: [ValidationIssue] = []
        
        // Check position counts
        let positionCounts = Dictionary(grouping: teamManager.selectedTeam, by: \.position)
        for position in Position.allCases {
            let count = positionCounts[position]?.count ?? 0
            if !isValidPositionCount(count, for: position) {
                issues.append(ValidationIssue(
                    category: .positionCount,
                    description: "Invalid \(position.rawValue) count: \(count)",
                    severity: .critical
                ))
            }
        }
        
        // Check salary compliance
        if teamManager.teamValue > 10_000_000 {
            issues.append(ValidationIssue(
                category: .salary,
                description: "Team value exceeds salary cap",
                severity: .critical
            ))
        }
        
        // Check rookie exposure
        let rookieCount = teamManager.selectedTeam.filter { $0.price < 300_000 }.count
        if rookieCount > 8 {
            issues.append(ValidationIssue(
                category: .rookieExposure,
                description: "High rookie exposure: \(rookieCount) players",
                severity: .medium
            ))
        }
        
        validationIssues = issues
    }
    
    /// Generates optimization suggestions based on the selected strategy
    func optimizeTeam(using strategy: OptimizationStrategy) async {
        isOptimizing = true
        defer { isOptimizing = false }
        
        // Analyze current team structure
        await analyzeTeamMetrics()
        
        var suggestions: [OptimizerSuggestion] = []
        
        switch strategy {
        case .balanced:
            suggestions = await generateBalancedSuggestions()
        case .highCeiling:
            suggestions = await generateHighCeilingSuggestions()
        case .consistent:
            suggestions = await generateConsistencySuggestions()
        case .value:
            suggestions = await generateValueSuggestions()
        case .differential:
            suggestions = await generateDifferentialSuggestions()
        }
        
        // Sort suggestions by impact level and confidence
        self.suggestions = suggestions.sorted { s1, s2 in
            if s1.impact == s2.impact {
                return s1.confidence > s2.confidence
            }
            return s1.impact > s2.impact
        }
    }
    
    // MARK: - Private Methods
    
    private func setupSubscriptions() {
        // Update metrics when team changes
        teamManager.$selectedTeam
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.analyzeTeamMetrics()
                    await self?.validateTeam()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func analyzeTeamMetrics() async {
        // Calculate position balance
        let positionBalance = Dictionary(
            grouping: teamManager.selectedTeam,
            by: \.position
        ).mapValues { $0.count }
        
        // Calculate price distribution
        let priceDistribution = Dictionary(
            grouping: teamManager.selectedTeam
        ) { player in
            // Group into 100k brackets
            player.price / 100_000 * 100_000
        }.mapValues { $0.count }
        
        // Count premium and rookie players
        let rookieCount = teamManager.selectedTeam.filter { $0.price < 300_000 }.count
        let premiumCount = teamManager.selectedTeam.filter { $0.price > 600_000 }.count
        
        // Calculate team metrics
        currentTeamMetrics = TeamMetrics(
            positionBalance: positionBalance,
            priceDistribution: priceDistribution,
            rookieCount: rookieCount,
            premiumCount: premiumCount,
            injuryRiskScore: calculateInjuryRisk(),
            valueGenerationPotential: calculateValuePotential(),
            consistencyScore: calculateConsistencyScore(),
            uniquenessScore: calculateUniquenessScore()
        )
    }
    
    private func isValidPositionCount(_ count: Int, for position: Position) -> Bool {
        switch position {
        case .defender, .forward:
            return count >= 6 && count <= 8
        case .midfielder:
            return count >= 8 && count <= 10
        case .ruck:
            return count >= 2 && count <= 3
        }
    }
    
    // MARK: - Score Calculations
    
    private func calculateInjuryRisk() -> Double {
        // TODO: Implement injury risk calculation using player history
        return 50.0
    }
    
    private func calculateValuePotential() -> Double {
        let totalPotential = teamManager.selectedTeam.reduce(0.0) { total, player in
            total + (player.projected - player.average) * 3000 // Simple price change estimate
        }
        return totalPotential
    }
    
    private func calculateConsistencyScore() -> Double {
        guard !teamManager.selectedTeam.isEmpty else { return 0 }
        
        let avgConsistency = teamManager.selectedTeam.reduce(0.0) { total, player in
            // Mock consistency based on averages vs projected
            let volatility = abs(player.projected - player.average) / player.average
            return total + (1 - volatility)
        } / Double(teamManager.selectedTeam.count)
        
        return avgConsistency * 100
    }
    
    private func calculateUniquenessScore() -> Double {
        // TODO: Compare against ownership % when available
        return 50.0
    }
    
    // MARK: - Strategy-specific Suggestions
    
    private func generateBalancedSuggestions() async -> [OptimizerSuggestion] {
        // TODO: Implement balanced strategy suggestions
        return []
    }
    
    private func generateHighCeilingSuggestions() async -> [OptimizerSuggestion] {
        // TODO: Implement high ceiling strategy suggestions
        return []
    }
    
    private func generateConsistencySuggestions() async -> [OptimizerSuggestion] {
        // TODO: Implement consistency strategy suggestions
        return []
    }
    
    private func generateValueSuggestions() async -> [OptimizerSuggestion] {
        // TODO: Implement value strategy suggestions
        return []
    }
    
    private func generateDifferentialSuggestions() async -> [OptimizerSuggestion] {
        // TODO: Implement differential strategy suggestions
        return []
    }
}
