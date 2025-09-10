import Combine
import Foundation

// MARK: - APIService

/// Main API service for communicating with AFL Fantasy backend
@MainActor
final class APIService: ObservableObject {
    // MARK: - Properties

    private let session: URLSession
    private let baseURL: URL
    private var cancellables = Set<AnyCancellable>()

    @Published var isHealthy = false
    @Published var lastHealthCheck: Date?

    // MARK: - Initialization

    init(baseURL: String = "http://localhost:8080") {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        session = URLSession(configuration: config)

        guard let url = URL(string: baseURL) else {
            fatalError("Invalid base URL: \(baseURL)")
        }
        self.baseURL = url

        // Start health monitoring
        startHealthMonitoring()
    }

    // MARK: - Health Monitoring

    private func startHealthMonitoring() {
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.checkHealth()
                }
            }
            .store(in: &cancellables)

        // Initial health check
        Task {
            await checkHealth()
        }
    }

    @discardableResult
    func checkHealth() async -> Bool {
        do {
            let response = try await request(endpoint: .health, responseType: APIHealthResponse.self)
            isHealthy = response.status == "healthy"
            lastHealthCheck = Date()
            return isHealthy
        } catch {
            isHealthy = false
            lastHealthCheck = Date()
            print("⚠️ Health check failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Player API

    func fetchAllPlayers() async throws -> [Player] {
        try await request(endpoint: .players, responseType: [Player].self)
    }

    func fetchPlayer(id: String) async throws -> Player {
        try await request(endpoint: .player(id), responseType: Player.self)
    }

    // MARK: - Cash Cow API

    func fetchCashCows() async throws -> [CashCowAnalysis] {
        try await request(endpoint: .cashCows, responseType: [CashCowAnalysis].self)
    }

    // MARK: - Captain API

    func fetchCaptainSuggestions(venue: String? = nil, opponent: String? = nil) async throws -> [CaptainSuggestion] {
        let body = CaptainRequest(venue: venue, opponent: opponent)
        return try await request(
            endpoint: .captainSuggestions,
            method: .POST,
            body: body,
            responseType: [CaptainSuggestion].self
        )
    }

    // MARK: - Stats API

    func fetchStats() async throws -> APIStatsResponse {
        try await request(endpoint: .stats, responseType: APIStatsResponse.self)
    }

    // MARK: - Authentication API
    
    func authenticate(email: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(email: email, password: password)
        return try await request(
            endpoint: .login,
            method: .POST,
            body: body,
            responseType: AuthResponse.self
        )
    }
    
    func refreshToken(_ token: String) async throws -> AuthResponse {
        let body = RefreshTokenRequest(refreshToken: token)
        return try await request(
            endpoint: .refreshToken,
            method: .POST,
            body: body,
            responseType: AuthResponse.self
        )
    }
    
    // MARK: - Team Management API
    
    func fetchUserTeams(userId: String) async throws -> [FantasyTeamResponse] {
        try await request(
            endpoint: .userTeams(userId),
            responseType: [FantasyTeamResponse].self
        )
    }
    
    func fetchTeamDetails(teamCode: String) async throws -> FantasyTeamResponse {
        try await request(
            endpoint: .teamDetails(teamCode),
            responseType: FantasyTeamResponse.self
        )
    }
    
    func addTeamToUser(userId: String, teamCode: String) async throws -> FantasyTeamResponse {
        let body = AddTeamRequest(teamCode: teamCode)
        return try await request(
            endpoint: .addTeam(userId),
            method: .POST,
            body: body,
            responseType: FantasyTeamResponse.self
        )
    }
    
    func removeTeamFromUser(userId: String, teamId: String) async throws {
        struct EmptyResponse: Codable {}
        _ = try await request(
            endpoint: .removeTeam(userId, teamId),
            method: .DELETE,
            responseType: EmptyResponse.self
        )
    }
    
    func setActiveTeam(userId: String, teamId: String) async throws -> FantasyTeamResponse {
        let body = SetActiveTeamRequest(teamId: teamId)
        return try await request(
            endpoint: .setActiveTeam(userId),
            method: .PUT,
            body: body,
            responseType: FantasyTeamResponse.self
        )
    }

    // MARK: - Cache Refresh

    func refreshCache() async throws {
        struct RefreshResponse: Codable {
            let status: String
            let message: String
        }
        _ = try await request(
            endpoint: .refreshCache,
            method: .POST,
            body: EmptyBody(),
            responseType: RefreshResponse.self
        )
    }

    // MARK: - Generic Request Handler
    
    private func request<T: Codable>(
        endpoint: APIEndpoint,
        method: HTTPMethod = .GET,
        responseType: T.Type
    ) async throws -> T {
        return try await request(endpoint: endpoint, method: method, body: EmptyBody(), responseType: responseType)
    }

    private func request<T: Codable, U: Codable>(
        endpoint: APIEndpoint,
        method: HTTPMethod = .GET,
        body: U? = nil,
        responseType: T.Type
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Add body for POST requests
        if let body, method == .POST {
            // Only encode if it's not empty body
            if !(body is EmptyBody) {
                request.httpBody = try JSONEncoder().encode(body)
            }
        }

        let (data, response) = try await session.data(for: request)

        // Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AFLFantasyError.networkError("Invalid response")
        }

        guard 200 ... 299 ~= httpResponse.statusCode else {
            throw AFLFantasyError.apiError("HTTP \(httpResponse.statusCode)")
        }

        // Debug logging in development
        #if DEBUG
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 API Response (\(endpoint.path)): \(jsonString.prefix(200))...")
            }
        #endif

        // Decode response
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw AFLFantasyError.dataError("Failed to decode response: \(error.localizedDescription)")
        }
    }
}

// MARK: - CaptainRequest

private struct CaptainRequest: Codable {
    let venue: String?
    let opponent: String?
}

// MARK: - Authentication Models

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct AuthResponse: Codable {
    let user: UserResponse
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}

struct UserResponse: Codable {
    let id: String
    let email: String
    let name: String
    let createdAt: String
    let teams: [FantasyTeamResponse]?
    let activeTeamId: String?
}

// MARK: - Team Management Models

struct FantasyTeamResponse: Codable {
    let id: String
    let name: String
    let code: String
    let league: String
    let isActive: Bool
    let players: [String]
    let rank: Int?
    let points: Int?
    let createdAt: String
}

struct AddTeamRequest: Codable {
    let teamCode: String
}

struct SetActiveTeamRequest: Codable {
    let teamId: String
}

// MARK: - EmptyBody

private struct EmptyBody: Codable {}

// MARK: - APIEndpoint

enum APIEndpoint {
    case health
    case players
    case player(String)
    case cashCows
    case captainSuggestions
    case stats
    case refreshCache
    
    // Authentication endpoints
    case login
    case refreshToken
    
    // Team management endpoints
    case userTeams(String) // userId
    case teamDetails(String) // teamCode
    case addTeam(String) // userId
    case removeTeam(String, String) // userId, teamId
    case setActiveTeam(String) // userId

    var path: String {
        switch self {
        case .health:
            "/health"
        case .players:
            "/api/players"
        case let .player(id):
            "/api/players/\(id)"
        case .cashCows:
            "/api/stats/cash-cows"
        case .captainSuggestions:
            "/api/captain/suggestions"
        case .stats:
            "/api/stats/summary"
        case .refreshCache:
            "/api/refresh"
        
        // Authentication
        case .login:
            "/api/auth/login"
        case .refreshToken:
            "/api/auth/refresh"
            
        // Team management
        case let .userTeams(userId):
            "/api/users/\(userId)/teams"
        case let .teamDetails(teamCode):
            "/api/teams/\(teamCode)"
        case let .addTeam(userId):
            "/api/users/\(userId)/teams"
        case let .removeTeam(userId, teamId):
            "/api/users/\(userId)/teams/\(teamId)"
        case let .setActiveTeam(userId):
            "/api/users/\(userId)/active-team"
        }
    }
}

// MARK: - HTTPMethod

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

// MARK: - Extensions

extension APIService {
    /// Convenience method to fetch players with retry logic
    func fetchPlayersWithRetry(maxRetries: Int = 3) async -> Result<[Player], AFLFantasyError> {
        for attempt in 1 ... maxRetries {
            do {
                let players = try await fetchAllPlayers()
                return .success(players)
            } catch let error as AFLFantasyError {
                if attempt == maxRetries {
                    return .failure(error)
                }
                // Wait before retrying
                try? await Task.sleep(nanoseconds: UInt64(attempt * 1_000_000_000)) // 1, 2, 3 seconds
            } catch {
                return .failure(.networkError(error.localizedDescription))
            }
        }
        return .failure(.networkError("Max retries exceeded"))
    }
}

// MARK: - Mock for Previews

#if DEBUG
    extension APIService {
        static let mock: APIService = {
            let service = APIService(baseURL: "http://mock.example.com")
            service.isHealthy = true
            service.lastHealthCheck = Date()
            return service
        }()
    }
#endif
