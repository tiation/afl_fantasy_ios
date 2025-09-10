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
    
    func refreshTeam() async {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Load from API
        await Task.sleep(nanoseconds: 1_000_000_000)
        
        loadMockTeam()
    }
    
    func saveTeam() async {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Save to API
        await Task.sleep(nanoseconds: 500_000_000)
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
        selectedTeam = Array(MockData.samplePlayers.prefix(18))
        
        if let firstPlayer = selectedTeam.first {
            captain = firstPlayer
        }
        if selectedTeam.count > 1 {
            viceCaptain = selectedTeam[1]
        }
        
        remainingBudget = 10_000_000 - teamValue
        tradesRemaining = 30 - currentRound + 1
    }
}
