import Foundation
import Combine

@MainActor
final class TeamManager: ObservableObject {
    @Published var selectedTeam: [Player] = []
    @Published var captain: Player?
    @Published var viceCaptain: Player?
    @Published var remainingBudget: Int = 10_000_000
    @Published var tradesRemaining: Int = 30
    @Published var currentRound: Int = 1
    @Published var isLoading: Bool = false
    
    // Multiple team management
    @Published var teams: [FantasyTeam] = []
    @Published var activeTeam: FantasyTeam?
    @Published var error: Error?
    
    private let apiService = APIService()
    private let keychainService = KeychainService.shared
    
    init() {
        loadMockTeam()
    }
    
    // MARK: - Team Management
    
    func addPlayer(_ player: Player) {
        guard selectedTeam.count < 22 else { return }
        guard remainingBudget >= player.price else { return }
        
        selectedTeam.append(player)
        remainingBudget -= player.price
    }
    
    func removePlayer(_ player: Player) {
        selectedTeam.removeAll { $0.id == player.id }
        remainingBudget += player.price
        
        // Clear captaincy if this player was captain/vc
        if captain?.id == player.id {
            captain = nil
        }
        if viceCaptain?.id == player.id {
            viceCaptain = nil
        }
    }
    
    func setCaptain(_ player: Player) {
        guard selectedTeam.contains(where: { $0.id == player.id }) else { return }
        
        // If setting current VC as captain, clear VC
        if viceCaptain?.id == player.id {
            viceCaptain = nil
        }
        
        captain = player
    }
    
    func setViceCaptain(_ player: Player) {
        guard selectedTeam.contains(where: { $0.id == player.id }) else { return }
        guard captain?.id != player.id else { return }
        
        viceCaptain = player
    }
    
    func tradePlayer(out: Player, in: Player) {
        guard tradesRemaining > 0 else { return }
        guard let index = selectedTeam.firstIndex(where: { $0.id == out.id }) else { return }
        
        let priceDifference = `in`.price - out.price
        guard remainingBudget >= priceDifference else { return }
        
        selectedTeam[index] = `in`
        remainingBudget -= priceDifference
        tradesRemaining -= 1
        
        // Update captaincy if needed
        if captain?.id == out.id {
            captain = `in`
        }
        if viceCaptain?.id == out.id {
            viceCaptain = `in`
        }
    }
    
    // MARK: - Data Loading
    
    func refreshTeams() async {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Load from API
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        loadMockTeam()
    }
    
    func refreshTeam() async {
        await refreshTeams()
    }
    
    func saveTeam() async {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Save to API
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
    
    // MARK: - Team Analysis
    
    var teamValue: Int {
        selectedTeam.reduce(0) { $0 + $1.price }
    }
    
    var averageScore: Double {
        guard !selectedTeam.isEmpty else { return 0 }
        return selectedTeam.reduce(0.0) { $0 + $1.average } / Double(selectedTeam.count)
    }
    
    var projectedScore: Double {
        guard !selectedTeam.isEmpty else { return 0 }
        return selectedTeam.reduce(0.0) { $0 + $1.projected } / Double(selectedTeam.count)
    }
    
    func playersByPosition(_ position: Position) -> [Player] {
        selectedTeam.filter { $0.position == position }
    }
    
    // MARK: - Private Methods
    
    private func loadMockTeam() {
        // Load some mock players for demonstration
        // Load some mock players - for now create empty array
        // TODO: Implement proper mock data loading
        selectedTeam = []
        
        if let firstPlayer = selectedTeam.first {
            captain = firstPlayer
        }
        if selectedTeam.count > 1 {
            viceCaptain = selectedTeam[1]
        }
        
        remainingBudget = 10_000_000 - teamValue
        tradesRemaining = 30 - currentRound + 1
    }
    
    // MARK: - Multiple Team Management
    
    func addTeam(code: String, barcodeType: String) async {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Scan and validate team code
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        let newTeam = FantasyTeam(
            id: UUID().uuidString,
            name: "Team \(code)",
            code: code,
            league: "AFL",
            totalSalary: 10_000_000,
            remainingSalary: 2_000_000,
            playerCount: 18,
            averageScore: 85.5,
            currentRank: Int.random(in: 1000...50000)
        )
        
        teams.append(newTeam)
        if activeTeam == nil {
            activeTeam = newTeam
        }
    }
    
    func addTeam(name: String, code: String, league: String) {
        let newTeam = FantasyTeam(
            id: UUID().uuidString,
            name: name,
            code: code,
            league: league,
            totalSalary: 10_000_000,
            remainingSalary: 2_000_000,
            playerCount: 0,
            averageScore: 0.0,
            currentRank: nil
        )
        
        teams.append(newTeam)
        if activeTeam == nil {
            activeTeam = newTeam
        }
    }
    
    func setActiveTeam(_ team: FantasyTeam) {
        activeTeam = team
    }
    
    func removeTeam(_ team: FantasyTeam) {
        teams.removeAll { $0.id == team.id }
        if activeTeam?.id == team.id {
            activeTeam = teams.first
        }
    }
    
    // MARK: - Mock
    
    static var mock: TeamManager {
        let manager = TeamManager()
        // Add some mock teams
        manager.teams = [
            FantasyTeam(
                id: UUID().uuidString,
                name: "Demo Team 1",
                code: "ABC123",
                league: "AFL",
                totalSalary: 10_000_000,
                remainingSalary: 156_000,
                playerCount: 22,
                averageScore: 87.3,
                currentRank: 12543
            )
        ]
        manager.activeTeam = manager.teams.first
        return manager
    }
}
