import Foundation

// MARK: - PlayerSortOrder

// PlayerSortOption moved to SharedTypes.swift to avoid duplicate definition

// Player sort order
enum PlayerSortOrder: String, CaseIterable {
    case score = "Score"
    case price = "Price"
    case name = "Name"
    case position = "Position"
    case ownership = "Ownership"
}

// MARK: - PlayerPosition

// Player position enum
enum PlayerPosition: String, CaseIterable {
    case defender = "DEF"
    case midfielder = "MID"
    case ruck = "RUC"
    case forward = "FWD"
}

// MARK: - RiskLevel

// Risk levels
public enum RiskLevel: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case extreme = "Extreme"
}

// MARK: - AlertPriority

// Alert priority
enum AlertPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

// MARK: - PlayerAnalytics

// Player analytics type
struct PlayerAnalytics: Codable {
    let consistency: Double
    let ceiling: Double
    let floor: Double
    let volatility: Double
    let form: [Int]
    let projectedScore: Double
}

// MARK: - PlayerProjection

// Player projection type
struct PlayerProjection: Codable {
    let nextRound: Double
    let threeRound: Double
    let season: Double
    let confidence: Double
}

// Note: TeamAnalysis is defined in TeamAnalysis.swift

// MARK: - PlayerAlert

// Player alert type
struct PlayerAlert: Codable {
    let id: String
    let playerId: String
    let playerName: String
    let alertType: String
    let priority: AlertPriority
    let message: String
    let createdAt: Date
}

// Note: NetworkStatus is defined in ReachabilityService.swift

// MARK: - User

// User data type
public struct User: Codable {
    public let id: String
    public let username: String
    public let email: String
    public let teamName: String

    public init(id: String, username: String, email: String, teamName: String) {
        self.id = id
        self.username = username
        self.email = email
        self.teamName = teamName
    }
}

// MARK: - LiveScores
// Note: LiveScores is now defined in DataModels.swift to avoid conflicts

// MARK: - AppState

// Comprehensive App State
@MainActor
public class AppState: ObservableObject {
    public static let shared = AppState()

    // Player data
    @Published public var players: [Player] = []
    @Published public var selectedPlayers: [Player] = []

    // Loading and error states
    @Published public var isLoading = false
    @Published public var error: Error?
    @Published public var errorMessage: String?

    // Dashboard data
    @Published public var dashboardData: DashboardData?

    // Authentication
    @Published public var isAuthenticated = false
    @Published public var currentUser: User?

    // Network status
    @Published public var networkStatus: NetworkStatus = .unknown

    public nonisolated init() {}

    // MARK: - Player Methods

    public func updatePlayers(_ players: [Player]) {
        self.players = players
    }

    public func updateDashboardData(_ data: DashboardData) {
        dashboardData = data
    }

    // MARK: - Error Handling

    public func setError(_ error: Error) {
        self.error = error
        errorMessage = error.localizedDescription
    }

    public func clearError() {
        error = nil
        errorMessage = nil
    }

    // MARK: - Authentication

    public func reset() {
        isAuthenticated = false
        currentUser = nil
        dashboardData = nil
        isLoading = false
        clearError()
    }
}

// MARK: - LiveAppState

// Live App State for real-time updates
@MainActor
class LiveAppState: AppState {
    static let liveShared = LiveAppState()

    @Published var liveScores: LiveScores?
    @Published var isLiveDataEnabled = true
    @Published var lastLiveUpdate: Date?

    override init() {
        super.init()
        startLiveUpdates()
    }

    private func startLiveUpdates() {
        // Would integrate with Docker scraper for live updates
        Timer.scheduledTimer(withTimeInterval: 30) { _ in
            Task { @MainActor in
                await self.fetchLiveData()
            }
        }
    }

    private func fetchLiveData() async {
        // Implementation would connect to Docker scraper
        lastLiveUpdate = Date()
    }
}
