import SwiftUI

@MainActor
final class TeamManagementViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var isLoading = false
    @Published private(set) var isOptimized = false
    @Published private(set) var savedLines: [SavedLine] = []
    @Published private(set) var currentLineup: [FieldPlayer] = []
    @Published private(set) var teamStructure: TeamStructure?
    @Published private(set) var salaryInfo = SalaryInfo(
        totalSalary: 0,
        availableSalary: 0,
        averagePlayerPrice: 0,
        premiumPercentage: 0,
        rookiePercentage: 0
    )
    @Published private(set) var suggestedTrades: [SuggestedTrade] = []
    @Published var selectedLineId: String?
    @Published var showError = false
    @Published var errorMessage = ""
    
    // MARK: - Dependencies
    
    private let teamService: TeamServiceProtocol
    private let lineService: LineServiceProtocol
    private let tradeService: TradeServiceProtocol
    private let optimizationService: OptimizationServiceProtocol
    
    // MARK: - Init
    
    init(
        teamService: TeamServiceProtocol = TeamService(),
        lineService: LineServiceProtocol = LineService(),
        tradeService: TradeServiceProtocol = TradeService(),
        optimizationService: OptimizationServiceProtocol = OptimizationService()
    ) {
        self.teamService = teamService
        self.lineService = lineService
        self.tradeService = tradeService
        self.optimizationService = optimizationService
    }
    
    // MARK: - Public Methods
    
    func loadData() async {
        do {
            isLoading = true
            defer { isLoading = false }
            
            // Load team data
            async let linesTask = lineService.getSavedLines()
            async let lineupTask = teamService.getCurrentLineup()
            async let salaryTask = teamService.getSalaryInfo()
            async let tradesTask = tradeService.getSuggestedTrades()
            
            // Wait for parallel fetches
            (
                savedLines,
                currentLineup,
                salaryInfo,
                suggestedTrades
            ) = try await (
                linesTask,
                lineupTask,
                salaryTask,
                tradesTask
            )
            
            // Update structure based on current lineup
            teamStructure = calculateTeamStructure(from: currentLineup)
            
        } catch {
            handleError(error)
        }
    }
    
    func saveLine() {
        guard let selectedLineId = selectedLineId else { return }
        
        Task {
            do {
                let line = savedLines.first { $0.id == selectedLineId }
                try await lineService.saveLine(
                    id: selectedLineId,
                    name: line?.name ?? "New Line",
                    lineup: currentLineup
                )
                
                // Refresh lines after save
                savedLines = try await lineService.getSavedLines()
                self.selectedLineId = nil
                
            } catch {
                handleError(error)
            }
        }
    }
    
    func optimizeTeam() {
        Task {
            do {
                isLoading = true
                defer { isLoading = false }
                
                // Get optimization suggestions
                let optimizedLineup = try await optimizationService.optimizeLineup(
                    currentLineup,
                    availableSalary: salaryInfo.availableSalary
                )
                
                // Update lineup if optimized
                if optimizedLineup != currentLineup {
                    currentLineup = optimizedLineup
                    isOptimized = true
                    
                    // Refresh related data
                    async let salaryTask = teamService.getSalaryInfo()
                    async let tradesTask = tradeService.getSuggestedTrades()
                    
                    (salaryInfo, suggestedTrades) = try await (salaryTask, tradesTask)
                }
                
            } catch {
                handleError(error)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func calculateTeamStructure(from lineup: [FieldPlayer]) -> TeamStructure {
        var positionBalance: [Position: Int] = [
            .defender: 0,
            .midfielder: 0,
            .ruck: 0,
            .forward: 0
        ]
        
        var totalValue = 0
        
        // Count positions and calculate total value
        for player in lineup where player.isOnField {
            positionBalance[player.position, default: 0] += 1
            totalValue += player.price
        }
        
        // Price tiers
        let premiumCount = lineup.filter { $0.price >= 650000 }.count
        let midPriceCount = lineup.filter { $0.price >= 350000 && $0.price < 650000 }.count
        let rookieCount = lineup.filter { $0.price < 350000 }.count
        
        return TeamStructure(
            totalValue: totalValue,
            bankBalance: 13000000 - totalValue, // Assuming 13M salary cap
            positionBalance: positionBalance,
            premiumCount: premiumCount,
            midPriceCount: midPriceCount,
            rookieCount: rookieCount
        )
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

// MARK: - Service Protocols

protocol TeamServiceProtocol {
    func getCurrentLineup() async throws -> [FieldPlayer]
    func getSalaryInfo() async throws -> SalaryInfo
}

protocol LineServiceProtocol {
    func getSavedLines() async throws -> [SavedLine]
    func saveLine(id: String, name: String, lineup: [FieldPlayer]) async throws
}

protocol TradeServiceProtocol {
    func getSuggestedTrades() async throws -> [SuggestedTrade]
}

protocol OptimizationServiceProtocol {
    func optimizeLineup(_ lineup: [FieldPlayer], availableSalary: Int) async throws -> [FieldPlayer]
}
