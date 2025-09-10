import SwiftUI
import Combine

// MARK: - TeamManager

@MainActor
final class TeamManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published var teams: [FantasyTeam] = []
    @Published var activeTeam: FantasyTeam?
    @Published var isLoading = false
    @Published var error: TeamManagementError?
    
    // MARK: - Private Properties
    
    private let keychain = KeychainService.shared
    private let apiService: APIService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    
    private struct Keys {
        static let teams = "fantasy_teams"
        static let activeTeamId = "active_team_id"
    }
    
    // MARK: - Initialization
    
    init(apiService: APIService = APIService()) {
        self.apiService = apiService
        loadStoredTeams()
        setupActiveTeam()
    }
    
    // MARK: - Public Methods
    
    /// Add a new fantasy team using team code from barcode/QR scan
    func addTeam(code: String, barcodeType: BarcodeType) async {
        isLoading = true
        error = nil
        
        do {
            let teamInfo: FantasyTeam
            
            // Handle different barcode types
            switch barcodeType {
            case .qr:
                teamInfo = try await processQRCode(code)
            default:
                teamInfo = try await processTeamCode(code)
            }
            
            // Check if team already exists
            if teams.contains(where: { $0.code == teamInfo.code }) {
                throw TeamManagementError.teamAlreadyExists
            }
            
            // Add to teams array
            teams.append(teamInfo)
            
            // Set as active team if it's the first one
            if activeTeam == nil {
                activeTeam = teamInfo
                saveActiveTeamId(teamInfo.id)
            }
            
            // Save to storage
            saveTeams()
            
        } catch {
            self.error = error as? TeamManagementError ?? .unknownError
        }
        
        isLoading = false
    }
    
    /// Add team manually with basic info
    func addTeam(name: String, code: String, league: String = "Classic") {
        guard !teams.contains(where: { $0.code == code }) else {
            error = .teamAlreadyExists
            return
        }
        
        let newTeam = FantasyTeam(
            name: name,
            code: code,
            league: league
        )
        
        teams.append(newTeam)
        
        // Set as active team if it's the first one
        if activeTeam == nil {
            activeTeam = newTeam
            saveActiveTeamId(newTeam.id)
        }
        
        saveTeams()
    }
    
    /// Remove a fantasy team
    func removeTeam(_ team: FantasyTeam) {
        teams.removeAll { $0.id == team.id }
        
        // Update active team if removed team was active
        if activeTeam?.id == team.id {
            activeTeam = teams.first
            if let newActiveTeam = activeTeam {
                saveActiveTeamId(newActiveTeam.id)
            } else {
                keychain.delete(Keys.activeTeamId)
            }
        }
        
        saveTeams()
    }
    
    /// Set active team
    func setActiveTeam(_ team: FantasyTeam) {
        activeTeam = team
        saveActiveTeamId(team.id)
    }
    
    /// Refresh team data from API
    func refreshTeams() async {
        isLoading = true
        error = nil
        
        // In a real implementation, this would fetch updated team data from the AFL Fantasy API
        // For now, we'll simulate a network call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Update teams with mock data
        for i in teams.indices {
            teams[i] = FantasyTeam(
                id: teams[i].id,
                name: teams[i].name,
                code: teams[i].code,
                league: teams[i].league,
                isActive: teams[i].isActive,
                players: generateMockPlayers(),
                rank: Int.random(in: 1000...50000),
                points: Int.random(in: 1800...2400),
                createdAt: teams[i].createdAt
            )
        }
        
        saveTeams()
        isLoading = false
    }
    
    /// Get team statistics
    func getTeamStats(for team: FantasyTeam) -> TeamStats {
        return TeamStats(
            totalPoints: team.points ?? 0,
            rank: team.rank ?? 0,
            playersCount: team.players.count,
            averagePointsPerPlayer: team.players.isEmpty ? 0 : Double(team.points ?? 0) / Double(team.players.count)
        )
    }
    
    // MARK: - Private Methods
    
    private func processQRCode(_ qrCode: String) async throws -> FantasyTeam {
        // Parse QR code JSON
        guard let data = qrCode.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw TeamManagementError.invalidTeamCode
        }
        
        guard let teamCode = json["teamCode"] as? String ?? json["team_id"] as? String else {
            throw TeamManagementError.invalidTeamCode
        }
        
        let teamName = json["teamName"] as? String ?? json["name"] as? String ?? "My Team"
        let league = json["league"] as? String ?? "Classic"
        
        return try await fetchTeamDetails(code: teamCode, name: teamName, league: league)
    }
    
    private func processTeamCode(_ code: String) async throws -> FantasyTeam {
        return try await fetchTeamDetails(code: code, name: nil, league: "Classic")
    }
    
    private func fetchTeamDetails(code: String, name: String?, league: String) async throws -> FantasyTeam {
        // Simulate API call to AFL Fantasy to get team details
        // In a real implementation, this would call the actual AFL Fantasy API
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Mock team data based on code
        let teamName = name ?? "Team \(code)"
        let mockPlayers = generateMockPlayers()
        
        return FantasyTeam(
            name: teamName,
            code: code,
            league: league,
            players: mockPlayers,
            rank: Int.random(in: 1000...50000),
            points: Int.random(in: 1800...2400)
        )
    }
    
    private func generateMockPlayers() -> [String] {
        // Generate mock player IDs
        return (1...22).map { "player_\($0)" }
    }
    
    private func loadStoredTeams() {
        guard let data = keychain.getData(for: Keys.teams),
              let storedTeams = try? JSONDecoder().decode([FantasyTeam].self, from: data) else {
            return
        }
        
        teams = storedTeams
    }
    
    private func saveTeams() {
        do {
            let data = try JSONEncoder().encode(teams)
            keychain.store(data, for: Keys.teams)
        } catch {
            print("Failed to save teams: \(error)")
        }
    }
    
    private func setupActiveTeam() {
        guard let activeTeamId = keychain.getString(for: Keys.activeTeamId) else {
            activeTeam = teams.first
            return
        }
        
        activeTeam = teams.first { $0.id == activeTeamId } ?? teams.first
    }
    
    private func saveActiveTeamId(_ id: String) {
        keychain.store(id, for: Keys.activeTeamId)
    }
}

// MARK: - TeamStats

struct TeamStats {
    let totalPoints: Int
    let rank: Int
    let playersCount: Int
    let averagePointsPerPlayer: Double
}

// MARK: - TeamManagementError

enum TeamManagementError: Error, LocalizedError {
    case invalidTeamCode
    case teamAlreadyExists
    case networkError(String)
    case apiError(String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidTeamCode:
            return "Invalid team code. Please check the code and try again."
        case .teamAlreadyExists:
            return "This team has already been added to your account."
        case .networkError(let message):
            return "Network error: \(message)"
        case .apiError(let message):
            return "API error: \(message)"
        case .unknownError:
            return "An unknown error occurred. Please try again."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidTeamCode:
            return "Make sure you're scanning a valid AFL Fantasy team code or QR code."
        case .teamAlreadyExists:
            return "You can manage this team from your teams list."
        case .networkError, .apiError:
            return "Check your internet connection and try again."
        case .unknownError:
            return "Please restart the app and try again."
        }
    }
}

// MARK: - Extensions

extension TeamManager {
    /// Get mock team manager for previews
    static let mock: TeamManager = {
        let manager = TeamManager(apiService: APIService.mock)
        manager.teams = [
            FantasyTeam(
                name: "Demo Team",
                code: "ABC123",
                league: "Classic",
                players: ["player_1", "player_2"],
                rank: 12543,
                points: 2147
            ),
            FantasyTeam(
                name: "Draft Team",
                code: "XYZ789",
                league: "Draft",
                players: ["player_3", "player_4"],
                rank: 8901,
                points: 1987
            )
        ]
        manager.activeTeam = manager.teams.first
        return manager
    }()
}
