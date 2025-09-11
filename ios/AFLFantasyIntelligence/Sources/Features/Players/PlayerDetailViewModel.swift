import Foundation
import Combine

@MainActor
final class PlayerDetailViewModel: ObservableObject {
    @Published var player: Player?
    @Published var selectedTab: PlayerDetailTab = .overview
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var statistics: PlayerStatistics?
    @Published var upcomingFixtures: [Fixture] = []
    @Published var priceHistory: [PricePoint] = []
    @Published var similarPlayers: [Player] = []
    @Published var playerData: PlayerData?
    
    private let apiService = APIService()
    private var cancellables = Set<AnyCancellable>()
    
    func loadPlayerDetails(_ player: Player) {
        self.player = player
        loadStatistics()
        loadUpcomingFixtures()
        loadPriceHistory()
        loadSimilarPlayers()
    }
    
    func selectTab(_ tab: PlayerDetailTab) {
        selectedTab = tab
    }
    
    private func loadStatistics() {
        guard let player = player else { return }
        
        isLoading = true
        
        // Mock statistics for now
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            
            statistics = PlayerStatistics(
                playerId: player.id,
                totalPoints: Int.random(in: 800...2000),
                averagePoints: player.average,
                highestScore: Int.random(in: 80...150),
                lowestScore: Int.random(in: 20...60),
                consistency: Double.random(in: 0.6...0.9),
                injuryRisk: Double.random(in: 0.1...0.7),
                upcomingDifficulty: Int.random(in: 1...5)
            )
            
            isLoading = false
        }
    }
    
    private func loadUpcomingFixtures() {
        guard let player = player else { return }
        
        // Mock upcoming fixtures
        upcomingFixtures = [
            Fixture(
                id: UUID(),
                round: 15,
                homeTeam: player.team,
                awayTeam: "Richmond",
                venue: "MCG",
                date: Date().addingTimeInterval(7 * 24 * 3600),
                difficulty: 3
            ),
            Fixture(
                id: UUID(),
                round: 16,
                homeTeam: "Collingwood",
                awayTeam: player.team,
                venue: "Marvel Stadium",
                date: Date().addingTimeInterval(14 * 24 * 3600),
                difficulty: 4
            ),
            Fixture(
                id: UUID(),
                round: 17,
                homeTeam: player.team,
                awayTeam: "Brisbane",
                venue: "Gabba",
                date: Date().addingTimeInterval(21 * 24 * 3600),
                difficulty: 2
            )
        ]
    }
    
    private func loadPriceHistory() {
        guard let player = player else { return }
        
        // Mock price history
        var history: [PricePoint] = []
        let basePrice = player.price
        let startDate = Date().addingTimeInterval(-30 * 24 * 3600) // 30 days ago
        
        for i in 0..<30 {
            let date = startDate.addingTimeInterval(Double(i) * 24 * 3600)
            let priceVariation = Int.random(in: -10000...10000)
            let price = max(100000, basePrice + priceVariation)
            
            history.append(PricePoint(date: date, price: price))
        }
        
        priceHistory = history.sorted { $0.date < $1.date }
    }
    
    private func loadSimilarPlayers() {
        guard let player = player else { return }
        
        // Mock similar players (same position, similar price range)
        similarPlayers = Player.mockPlayers.filter { otherPlayer in
            otherPlayer.id != player.id &&
            otherPlayer.position == player.position &&
            abs(otherPlayer.price - player.price) < 50000
        }.prefix(5).map { $0 }
    }
}

// MARK: - Supporting Types

enum PlayerDetailTab: String, CaseIterable {
    case overview = "Overview"
    case statistics = "Statistics" 
    case fixtures = "Fixtures"
    case priceHistory = "Price History"
    case similar = "Similar Players"
    
    var displayName: String {
        return rawValue
    }
    
    var icon: String {
        switch self {
        case .overview: return "chart.bar.fill"
        case .statistics: return "chart.line.uptrend.xyaxis"
        case .fixtures: return "calendar"
        case .priceHistory: return "dollarsign.circle.fill"
        case .similar: return "person.2.fill"
        }
    }
}

struct PlayerStatistics {
    let playerId: String
    let totalPoints: Int
    let averagePoints: Double
    let highestScore: Int
    let lowestScore: Int
    let consistency: Double // 0.0 to 1.0
    let injuryRisk: Double // 0.0 to 1.0
    let upcomingDifficulty: Int // 1 to 5
}

struct Fixture: Identifiable {
    let id: UUID
    let round: Int
    let homeTeam: String
    let awayTeam: String
    let venue: String
    let date: Date
    let difficulty: Int // 1 to 5, 1 being easiest
    
    var isHome: Bool {
        // This would be determined based on the player's team
        return true // Simplified for now
    }
    
    var opponent: String {
        return isHome ? awayTeam : homeTeam
    }
}

struct PricePoint: Identifiable {
    let id = UUID()
    let date: Date
    let price: Int
}
