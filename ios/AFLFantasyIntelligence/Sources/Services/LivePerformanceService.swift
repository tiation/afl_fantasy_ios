import Foundation
import Combine

// MARK: - LivePerformanceService Protocol
public protocol LivePerformanceServiceProtocol {
    // Publishers for real-time data
    var liveMatchesPublisher: AnyPublisher<[LiveMatchState], Never> { get }
    var performanceSummaryPublisher: AnyPublisher<LivePerformanceSummary, Never> { get }
    var performanceAlertsPublisher: AnyPublisher<[PerformanceAlert], Never> { get }
    
    // Current state properties
    var isConnected: Bool { get }
    var lastUpdateTime: Date? { get }
    
    // Core functions
    func startLiveTracking() async
    func stopLiveTracking()
    func refreshData() async throws
    func getLiveMatches() async throws -> [LiveMatchState]
    func getPerformanceSummary() async throws -> LivePerformanceSummary
    func getPlayerDeltas(for playerIds: [String]) async throws -> [PlayerStatDelta]
    func getTeamPerformance(for teamId: String) async throws -> LiveTeamPerformance
    func getCaptainSuggestions() async throws -> [CaptainCandidate]
    func getTradeTargets() async throws -> [TradeTarget]
}

// MARK: - LivePerformanceService Implementation
public class LivePerformanceService: LivePerformanceServiceProtocol, ObservableObject {
    
    private let baseURL: String
    private let updateInterval: TimeInterval
    private var cancellables = Set<AnyCancellable>()
    private var updateTimer: Timer?
    
    // Publishers
    private let liveMatchesSubject = CurrentValueSubject<[LiveMatchState], Never>([])
    private let performanceSummarySubject = CurrentValueSubject<LivePerformanceSummary, Never>(Self.mockPerformanceSummary)
    private let performanceAlertsSubject = CurrentValueSubject<[PerformanceAlert], Never>([])
    
    public var liveMatchesPublisher: AnyPublisher<[LiveMatchState], Never> {
        liveMatchesSubject.eraseToAnyPublisher()
    }
    
    public var performanceSummaryPublisher: AnyPublisher<LivePerformanceSummary, Never> {
        performanceSummarySubject.eraseToAnyPublisher()
    }
    
    public var performanceAlertsPublisher: AnyPublisher<[PerformanceAlert], Never> {
        performanceAlertsSubject.eraseToAnyPublisher()
    }
    
    // State
    @Published public private(set) var isConnected = false
    @Published public private(set) var lastUpdateTime: Date?
    
    public init(baseURL: String = "http://localhost:8080", updateInterval: TimeInterval = 10.0) {
        self.baseURL = baseURL
        self.updateInterval = updateInterval
    }
    
    // MARK: - Public Methods
    
    public func startLiveTracking() async {
        guard !isConnected else { return }
        
        isConnected = true
        
        // Start periodic updates
        await MainActor.run {
            updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
                Task {
                    try? await self?.refreshData()
                }
            }
        }
        
        // Initial data load
        do {
            try await refreshData()
        } catch {
            print("Failed to load initial live performance data: \(error)")
            // Fall back to mock data if API fails
            await loadMockData()
        }
    }
    
    public func stopLiveTracking() {
        isConnected = false
        updateTimer?.invalidate()
        updateTimer = nil
        cancellables.removeAll()
    }
    
    public func refreshData() async throws {
        let matches = try await getLiveMatches()
        let summary = try await getPerformanceSummary()
        let alerts = try await getPerformanceAlerts()
        
        await MainActor.run {
            liveMatchesSubject.send(matches)
            performanceSummarySubject.send(summary)
            performanceAlertsSubject.send(alerts)
            lastUpdateTime = Date()
        }
    }
    
    public func getLiveMatches() async throws -> [LiveMatchState] {
        // Try real API first
        do {
            let url = URL(string: "\(baseURL)/api/matches/live")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let matches = try JSONDecoder().decode([LiveMatchState].self, from: data)
            return matches
        } catch {
            // Fall back to mock data
            return Self.mockLiveMatches
        }
    }
    
    public func getPerformanceSummary() async throws -> LivePerformanceSummary {
        // Try real API first
        do {
            let url = URL(string: "\(baseURL)/api/performance/summary")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let summary = try JSONDecoder().decode(LivePerformanceSummary.self, from: data)
            return summary
        } catch {
            // Fall back to mock data
            return Self.mockPerformanceSummary
        }
    }
    
    public func getPlayerDeltas(for playerIds: [String]) async throws -> [PlayerStatDelta] {
        // Try real API first
        do {
            let playerIdsQuery = playerIds.joined(separator: ",")
            let url = URL(string: "\(baseURL)/api/players/deltas?playerIds=\(playerIdsQuery)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let deltas = try JSONDecoder().decode([PlayerStatDelta].self, from: data)
            return deltas
        } catch {
            // Fall back to mock data
            return Self.mockPlayerDeltas.filter { playerIds.contains($0.playerId) }
        }
    }
    
    public func getTeamPerformance(for teamId: String) async throws -> LiveTeamPerformance {
        // Try real API first
        do {
            let url = URL(string: "\(baseURL)/api/teams/\(teamId)/performance")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let performance = try JSONDecoder().decode(LiveTeamPerformance.self, from: data)
            return performance
        } catch {
            // Fall back to mock data
            return Self.mockTeamPerformances.first { $0.team.name.lowercased() == teamId.lowercased() } ?? Self.mockTeamPerformances[0]
        }
    }
    
    public func getCaptainSuggestions() async throws -> [CaptainCandidate] {
        // Try real API first
        do {
            let url = URL(string: "\(baseURL)/api/captains/suggestions")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let suggestions = try JSONDecoder().decode([CaptainCandidate].self, from: data)
            return suggestions
        } catch {
            // Fall back to mock data
            return Self.mockCaptainCandidates
        }
    }
    
    public func getTradeTargets() async throws -> [TradeTarget] {
        // Try real API first
        do {
            let url = URL(string: "\(baseURL)/api/trades/targets")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let targets = try JSONDecoder().decode([TradeTarget].self, from: data)
            return targets
        } catch {
            // Fall back to mock data
            return Self.mockTradeTargets
        }
    }
    
    private func getPerformanceAlerts() async throws -> [PerformanceAlert] {
        // Try real API first
        do {
            let url = URL(string: "\(baseURL)/api/alerts")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let alerts = try JSONDecoder().decode([PerformanceAlert].self, from: data)
            return alerts
        } catch {
            // Fall back to mock data
            return Self.mockPerformanceAlerts
        }
    }
    
    private func loadMockData() async {
        await MainActor.run {
            liveMatchesSubject.send(Self.mockLiveMatches)
            performanceSummarySubject.send(Self.mockPerformanceSummary)
            performanceAlertsSubject.send(Self.mockPerformanceAlerts)
            lastUpdateTime = Date()
        }
    }
}

// MARK: - Mock Data
extension LivePerformanceService {
    
    static let mockLiveMatches: [LiveMatchState] = [
        LiveMatchState(
            id: "match1",
            roundNumber: 23,
            homeTeam: .collingwood,
            awayTeam: .melbourne,
            venue: "MCG",
            status: .live,
            clock: GameClock(quarter: 2, timeRemaining: 600, timeElapsed: 600, isPaused: false),
            weather: WeatherConditions(
                temperature: 18,
                humidity: 65,
                windSpeed: 15,
                windDirection: "NE",
                conditions: "Partly Cloudy"
            ),
            homeScore: TeamScore(goals: 8, behinds: 4, quarterBreakdown: [28, 24]),
            awayScore: TeamScore(goals: 6, behinds: 8, quarterBreakdown: [22, 22])
        ),
        LiveMatchState(
            id: "match2",
            roundNumber: 23,
            homeTeam: .richmond,
            awayTeam: .geelong,
            venue: "Gabba",
            status: .quarterTime,
            clock: GameClock(quarter: 1, timeRemaining: 0, timeElapsed: 1200, isPaused: true),
            weather: WeatherConditions(
                temperature: 22,
                humidity: 70,
                windSpeed: 8,
                windDirection: "W",
                conditions: "Clear"
            ),
            homeScore: TeamScore(goals: 3, behinds: 2, quarterBreakdown: [20]),
            awayScore: TeamScore(goals: 4, behinds: 1, quarterBreakdown: [25])
        )
    ]
    
    static let mockPlayerDeltas: [PlayerStatDelta] = [
        PlayerStatDelta(
            playerId: "player1",
            playerName: "Max Gawn",
            team: .melbourne,
            position: .ruck,
            salary: 750000,
            currentStats: LivePlayerStats(
                disposals: 12,
                kicks: 8,
                handballs: 4,
                marks: 5,
                tackles: 3,
                hitouts: 28,
                goals: 0,
                behinds: 1,
                frees: 2,
                freesAgainst: 1,
                clangers: 2,
                timeOnGround: 85.0
            ),
            projectedStats: LivePlayerStats(
                disposals: 24,
                kicks: 16,
                handballs: 8,
                marks: 10,
                tackles: 6,
                hitouts: 56,
                goals: 0,
                behinds: 2,
                frees: 4,
                freesAgainst: 2,
                clangers: 4,
                timeOnGround: 85.0
            ),
            fantasyScore: 68.0,
            projectedFantasyScore: 136.0,
            averageComparison: 1.15,
            lastRoundComparison: 0.95,
            breakEvenComparison: 1.25,
            momentum: .building,
            riskFactors: [],
            opportunities: [
                Opportunity(
                    type: .favorableMatchup,
                    confidence: 0.85,
                    description: "Dominating ruck contests",
                    potentialUpside: "+20 points"
                )
            ]
        ),
        PlayerStatDelta(
            playerId: "player2",
            playerName: "Scott Pendlebury",
            team: .collingwood,
            position: .midfielder,
            salary: 680000,
            currentStats: LivePlayerStats(
                disposals: 15,
                kicks: 9,
                handballs: 6,
                marks: 4,
                tackles: 2,
                hitouts: 0,
                goals: 1,
                behinds: 0,
                frees: 1,
                freesAgainst: 0,
                clangers: 1,
                timeOnGround: 92.0
            ),
            projectedStats: LivePlayerStats(
                disposals: 30,
                kicks: 18,
                handballs: 12,
                marks: 8,
                tackles: 4,
                hitouts: 0,
                goals: 2,
                behinds: 0,
                frees: 2,
                freesAgainst: 0,
                clangers: 2,
                timeOnGround: 92.0
            ),
            fantasyScore: 89.0,
            projectedFantasyScore: 178.0,
            averageComparison: 1.28,
            lastRoundComparison: 1.45,
            breakEvenComparison: 1.35,
            momentum: .surging,
            riskFactors: [],
            opportunities: [
                Opportunity(
                    type: .captainCandidate,
                    confidence: 0.92,
                    description: "Exceptional disposal efficiency",
                    potentialUpside: "Captain material"
                )
            ]
        )
    ]
    
    static let mockTeamPerformances: [LiveTeamPerformance] = [
        LiveTeamPerformance(
            team: .collingwood,
            fantasyTotal: 1456.0,
            projectedTotal: 2912.0,
            averageComparison: 1.12,
            topPerformers: Array(mockPlayerDeltas.prefix(3)),
            concerningPerformers: [],
            captainOptions: mockCaptainCandidates,
            tradeTargets: Array(mockTradeTargets.prefix(2))
        )
    ]
    
    static let mockCaptainCandidates: [CaptainCandidate] = [
        CaptainCandidate(
            playerId: "player2",
            playerName: "Scott Pendlebury",
            currentScore: 89.0,
            projectedScore: 178.0,
            captainProbability: 0.92,
            riskLevel: .low,
            reasoning: "Exceptional disposal efficiency and goal scoring"
        ),
        CaptainCandidate(
            playerId: "player1",
            playerName: "Max Gawn",
            currentScore: 68.0,
            projectedScore: 136.0,
            captainProbability: 0.78,
            riskLevel: .medium,
            reasoning: "Dominating ruck contests, consistent performer"
        )
    ]
    
    static let mockTradeTargets: [TradeTarget] = [
        TradeTarget(
            playerId: "player3",
            playerName: "Clayton Oliver",
            team: .melbourne,
            position: .midfielder,
            currentPrice: 720000,
            projectedPriceChange: 15000,
            confidence: 0.85,
            reasoning: "Strong form trend, favorable upcoming fixtures",
            timeframe: .thisWeek
        ),
        TradeTarget(
            playerId: "player4",
            playerName: "Nick Daicos",
            team: .collingwood,
            position: .midfielder,
            currentPrice: 680000,
            projectedPriceChange: -8000,
            confidence: 0.72,
            reasoning: "Price correction expected after recent poor games",
            timeframe: .nextWeek
        )
    ]
    
    static let mockPerformanceAlerts: [PerformanceAlert] = [
        PerformanceAlert(
            type: .breakoutPerformance,
            severity: .high,
            playerId: "player2",
            playerName: "Scott Pendlebury",
            message: "Scott Pendlebury is having a breakout game with 89 points at half time",
            action: "Consider as captain for next round"
        ),
        PerformanceAlert(
            type: .tradeOpportunity,
            severity: .medium,
            playerId: "player3",
            playerName: "Clayton Oliver",
            message: "Clayton Oliver showing strong form - potential trade target",
            action: "Review trade options"
        )
    ]
    
    static let mockPerformanceSummary = LivePerformanceSummary(
        totalFantasyScore: 1456.0,
        projectedTotalScore: 2912.0,
        averageComparison: 1.12,
        rankProjection: RankProjection(
            currentRank: 15432,
            projectedRank: 12890,
            rankChange: 2542,
            confidence: 0.78,
            percentile: 85.2
        ),
        topMovers: Array(mockPlayerDeltas.prefix(3)),
        captainPerformance: CaptainPerformance(
            playerId: "player2",
            playerName: "Scott Pendlebury",
            currentScore: 89.0,
            projectedScore: 178.0,
            alternativeOptions: Array(mockCaptainCandidates.dropFirst())
        ),
        alerts: mockPerformanceAlerts
    )
}
