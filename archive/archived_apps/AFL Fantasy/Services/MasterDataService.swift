import Foundation
import Combine

/// MasterDataService - Single source of truth for all data
/// Integrates with the live API server and provides real-time data to the app
@MainActor
final class MasterDataService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var players: [Player] = []
    @Published var healthStatus: APIHealthResponse?
    @Published var isConnected: Bool = false
    @Published var lastUpdate: Date?
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let apiClient = APIClient.shared
    private var cancellables = Set<AnyCancellable>()
    private let refreshInterval: TimeInterval = 300 // 5 minutes
    private var refreshTimer: Timer?
    
    // MARK: - Shared Instance
    
    static let shared = MasterDataService()
    
    private init() {
        startPeriodicRefresh()
        loadInitialData()
    }
    
    // MARK: - Public Methods
    
    func loadInitialData() {
        Task {
            await checkHealth()
            await fetchPlayers()
        }
    }
    
    func refresh() async {
        await checkHealth()
        await fetchPlayers()
    }
    
    func getPlayer(id: String) -> Player? {
        return players.first { $0.id == id }
    }
    
    func getPlayersByPosition(_ position: Position) -> [Player] {
        return players.filter { $0.position == position }
    }
    
    func searchPlayers(query: String) -> [Player] {
        let lowercaseQuery = query.lowercased()
        return players.filter { 
            $0.name.lowercased().contains(lowercaseQuery) ||
            $0.team.lowercased().contains(lowercaseQuery)
        }
    }
    
    // MARK: - Private Methods
    
    private func startPeriodicRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { _ in
            Task { @MainActor in
                await self.refresh()
            }
        }
    }
    
    @discardableResult
    private func checkHealth() async -> Bool {
        do {
            let health = try await withCheckedThrowingContinuation { continuation in
                apiClient.getHealthStatus()
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                continuation.resume(throwing: error)
                            }
                        },
                        receiveValue: { health in
                            continuation.resume(returning: health)
                        }
                    )
                    .store(in: &cancellables)
            }
            
            healthStatus = health
            isConnected = health.status == "healthy"
            lastUpdate = Date()
            errorMessage = nil
            
            print("✅ API Health: \(health.status), Players: \(health.playersCache ?? 0)")
            return true
            
        } catch {
            print("❌ Health check failed: \(error)")
            isConnected = false
            errorMessage = "Connection failed: \(error.localizedDescription)"
            return false
        }
    }
    
    private func fetchPlayers() async {
        guard isConnected else {
            print("⚠️ Skipping player fetch - API not connected")
            return
        }
        
        do {
            let apiPlayers = try await withCheckedThrowingContinuation { continuation in
                apiClient.getAllPlayers()
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                continuation.resume(throwing: error)
                            }
                        },
                        receiveValue: { players in
                            continuation.resume(returning: players)
                        }
                    )
                    .store(in: &cancellables)
            }
            
            // Transform API players to our Player model
            let transformedPlayers = apiPlayers.compactMap { apiPlayer -> Player? in
                guard let position = Position(rawValue: apiPlayer.position ?? "MID") else {
                    return nil
                }
                
                return Player(
                    id: apiPlayer.playerId,
                    name: apiPlayer.name,
                    team: apiPlayer.team ?? "Unknown",
                    position: position,
                    price: 200000, // Default price from API response
                    average: Double(apiPlayer.hasData ? 85 : 0), // Mock average based on hasData
                    projected: Double(apiPlayer.hasData ? 90 : 0), // Mock projected
                    breakeven: apiPlayer.hasData ? 45 : 0, // Mock breakeven
                    consistency: apiPlayer.hasData ? .b : .d, // Mock consistency
                    priceChange: Int.random(in: -5000...5000), // Mock price change
                    ownership: apiPlayer.hasData ? Double.random(in: 0.1...0.8) : nil,
                    injuryStatus: .healthy, // Mock injury status
                    venueStats: nil, // TODO: Implement venue stats
                    formFactor: apiPlayer.hasData ? Double.random(in: 0.8...1.2) : nil,
                    dvpImpact: apiPlayer.hasData ? Double.random(in: -0.3...0.3) : nil
                )
            }
            
            players = transformedPlayers
            lastUpdate = Date()
            errorMessage = nil
            
            print("✅ Fetched \(players.count) players from API")
            
        } catch {
            print("❌ Failed to fetch players: \(error)")
            errorMessage = "Failed to load player data: \(error.localizedDescription)"
            
            // Fallback to mock data if API fails
            if players.isEmpty {
                loadMockPlayers()
            }
        }
    }
    
    private func loadMockPlayers() {
        print("⚠️ Loading mock player data as fallback")
        
        let mockPlayers = [
            Player(
                id: "player1",
                name: "Marcus Bontempelli",
                team: "Western Bulldogs",
                position: .midfielder,
                price: 785000,
                average: 112.5,
                projected: 115.0,
                breakeven: 42,
                consistency: .a,
                priceChange: 3500,
                ownership: 0.65,
                injuryStatus: .healthy,
                venueStats: nil,
                formFactor: 1.15,
                dvpImpact: 0.2
            ),
            Player(
                id: "player2", 
                name: "Clayton Oliver",
                team: "Melbourne",
                position: .midfielder,
                price: 756000,
                average: 108.2,
                projected: 110.0,
                breakeven: 38,
                consistency: .a,
                priceChange: 2800,
                ownership: 0.58,
                injuryStatus: .healthy,
                venueStats: nil,
                formFactor: 1.08,
                dvpImpact: 0.15
            ),
            Player(
                id: "player3",
                name: "Sam Docherty",
                team: "Carlton",
                position: .defender,
                price: 645000,
                average: 95.8,
                projected: 98.0,
                breakeven: 35,
                consistency: .b,
                priceChange: 1200,
                ownership: 0.42,
                injuryStatus: .healthy,
                venueStats: nil,
                formFactor: 1.02,
                dvpImpact: 0.1
            ),
            Player(
                id: "player4",
                name: "Max Gawn",
                team: "Melbourne",
                position: .ruck,
                price: 678000,
                average: 102.4,
                projected: 105.0,
                breakeven: 28,
                consistency: .a,
                priceChange: -800,
                ownership: 0.73,
                injuryStatus: .healthy,
                venueStats: nil,
                formFactor: 1.12,
                dvpImpact: 0.25
            ),
            Player(
                id: "player5",
                name: "Jeremy Cameron",
                team: "Geelong",
                position: .forward,
                price: 612000,
                average: 88.6,
                projected: 92.0,
                breakeven: 31,
                consistency: .b,
                priceChange: 4200,
                ownership: 0.38,
                injuryStatus: .healthy,
                venueStats: nil,
                formFactor: 1.06,
                dvpImpact: 0.12
            )
        ]
        
        players = mockPlayers
        lastUpdate = Date()
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
}

// MARK: - Dashboard Data Methods

extension MasterDataService {
    
    func getLiveStats() async -> LiveStats {
        // For now, return mock live stats
        // TODO: Implement real-time scoring when live data is available
        return LiveStats(
            currentScore: Int.random(in: 1800...2200),
            rank: Int.random(in: 15000...45000),
            playersPlaying: Int.random(in: 8...15),
            playersRemaining: Int.random(in: 7...14),
            averageScore: Double.random(in: 1650...1850)
        )
    }
    
    func getTeamStructure() async -> TeamStructure {
        // Mock team structure based on available players
        // TODO: Integrate with actual user team data
        let totalValue = 13000000 // $13M salary cap
        let usedValue = Int.random(in: 12500000...12950000)
        
        return TeamStructure(
            totalValue: usedValue,
            bankBalance: totalValue - usedValue,
            positionBalance: [
                .defender: Int.random(in: 3000000...3500000),
                .midfielder: Int.random(in: 4500000...5000000),
                .ruck: Int.random(in: 800000...1200000),
                .forward: Int.random(in: 3500000...4000000)
            ],
            premiumCount: Int.random(in: 8...12),
            midPriceCount: Int.random(in: 6...10),
            rookieCount: Int.random(in: 4...8)
        )
    }
    
    func getCashGenStats() async -> CashGenStats {
        // Generate cash cow stats based on available players
        let rookiePlayers = players.filter { $0.price < 250000 }
        let activeCows = rookiePlayers.filter { $0.average > 50 }
        
        let totalGenerated = activeCows.reduce(0) { total, player in
            total + Int(Double(player.price - 180000) * Double.random(in: 0.1...0.4))
        }
        
        let sellRecommendations = activeCows.filter { $0.breakeven > 60 }.count
        let holdCount = activeCows.count - sellRecommendations
        
        let recentHistory = activeCows.prefix(5).map { player in
            CashHistory(
                playerId: player.id,
                playerName: player.name,
                generated: Double.random(in: 5000...25000),
                date: Date().addingTimeInterval(-Double.random(in: 0...604800)), // Last week
                action: .hold
            )
        }
        
        return CashGenStats(
            totalGenerated: totalGenerated,
            activeCashCows: activeCows.count,
            sellRecommendations: sellRecommendations,
            holdCount: holdCount,
            recentHistory: Array(recentHistory)
        )
    }
    
    func getAIRecommendations() async -> [AIRecommendation] {
        // Generate AI recommendations based on current data
        let highOwnershipPlayers = players.filter { ($0.ownership ?? 0) > 0.6 }
        let consistentPlayers = players.filter { $0.consistency == .a || $0.consistency == .b }
        
        var recommendations: [AIRecommendation] = []
        
        // Captain recommendation
        if let topCaptain = consistentPlayers.first {
            recommendations.append(AIRecommendation(
                id: "captain_\(topCaptain.id)",
                type: .captain,
                confidence: 0.85,
                reasoning: "Strong recent form (\(String(format: "%.1f", topCaptain.formFactor ?? 1.0))x) and excellent venue record",
                impact: "Expected 15-20 point boost vs alternatives",
                timestamp: Date()
            ))
        }
        
        // Trade recommendation
        if let underperformer = players.filter({ $0.average < 70 && $0.price > 400000 }).first,
           let upgrade = players.filter({ $0.average > 95 && $0.price < underperformer.price + 100000 }).first {
            recommendations.append(AIRecommendation(
                id: "trade_\(underperformer.id)_\(upgrade.id)",
                type: .trade,
                confidence: 0.78,
                reasoning: "Upgrade from underperforming \(underperformer.name) to premium \(upgrade.name)",
                impact: "Projected +\(String(format: "%.0f", upgrade.average - underperformer.average)) points per week",
                timestamp: Date()
            ))
        }
        
        return recommendations
    }
}
