import Combine
import Foundation

// MARK: - APIService

/// Main API service for communicating with AFL Fantasy backend
@MainActor
final class APIService: ObservableObject {
    // Simple in-memory ETag + response cache for GET endpoints
    private var etagCache: [String: String] = [:]
    private var responseCache: [String: Data] = [:]
    // MARK: - Properties

    private let session: URLSession
    private var baseURL: URL
    private var cancellables = Set<AnyCancellable>()
    private var healthTimer: AnyCancellable?

    @Published var isHealthy = false
    @Published var lastHealthCheck: Date?
    @Published var currentEndpoint: String = ""

    // MARK: - Initialization

    @MainActor
    init(baseURL: String? = nil) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        session = URLSession(configuration: config)

        // Use provided URL or fall back to UserPreferences, then default
        let urlString = baseURL ?? UserPreferencesService.shared.apiBaseURL
        
        // Try to create URL, fall back to localhost if invalid
        if let url = URL(string: urlString) {
            self.baseURL = url
            self.currentEndpoint = urlString
        } else {
            print("⚠️ Invalid base URL: \(urlString), falling back to localhost")
            self.baseURL = URL(string: "http://localhost:8080")!
            self.currentEndpoint = "http://localhost:8080"
        }

        // Start health monitoring
        startHealthMonitoring()
    }

    // MARK: - Health Monitoring

    private func startHealthMonitoring() {
        // Cancel existing timer if any
        healthTimer?.cancel()
        
        // Start new timer
        healthTimer = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.checkHealth()
                }
            }
        
        healthTimer?.store(in: &cancellables)

        // Initial health check
        Task {
            await checkHealth()
        }
    }
    
    // MARK: - Endpoint Management
    
    /// Switch to a new API endpoint without restarting the app
    func switchEndpoint(_ newEndpoint: String) async -> Bool {
        guard let newURL = URL(string: newEndpoint) else {
            print("❌ Invalid endpoint URL: \(newEndpoint)")
            return false
        }
        
        // Update the base URL
        baseURL = newURL
        currentEndpoint = newEndpoint
        
        // Save to preferences
        UserPreferencesService.shared.apiBaseURL = newEndpoint
        
        // Test the new endpoint
        let wasHealthy = await checkHealth()
        
        if wasHealthy {
            print("✅ Successfully switched to endpoint: \(newEndpoint)")
            // Restart health monitoring with new endpoint
            startHealthMonitoring()
        } else {
            print("⚠️ New endpoint not responding: \(newEndpoint)")
        }
        
        return wasHealthy
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
        
        // Add ETag header for cacheable endpoints
        if method == .GET, let etag = etagFor(endpoint: endpoint) {
            request.setValue(etag, forHTTPHeaderField: "If-None-Match")
        }

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

        if httpResponse.statusCode == 304, let cached = cachedResponse(for: endpoint) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                return try decoder.decode(T.self, from: cached)
            } catch {
                throw AFLFantasyError.dataError("Failed to decode cached response: \(error.localizedDescription)")
            }
        }
        
        guard 200 ... 299 ~= httpResponse.statusCode else {
            throw AFLFantasyError.apiError("HTTP \(httpResponse.statusCode)")
        }
        
        // Save ETag and cache response if provided
        if let etag = httpResponse.value(forHTTPHeaderField: "ETag"), method == .GET, isCacheable(endpoint: endpoint) {
            etagCache[endpoint.cacheKey] = etag
            responseCache[endpoint.cacheKey] = data
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
    // MARK: - ETag helpers
    private func isCacheable(endpoint: APIEndpoint) -> Bool {
        switch endpoint {
        case .players, .stats:
            return true
        default:
            return false
        }
    }
    
    private func etagFor(endpoint: APIEndpoint) -> String? {
        guard isCacheable(endpoint: endpoint) else { return nil }
        return etagCache[endpoint.cacheKey]
    }
    
    private func cachedResponse(for endpoint: APIEndpoint) -> Data? {
        guard isCacheable(endpoint: endpoint) else { return nil }
        return responseCache[endpoint.cacheKey]
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
    
    // Authentication
    case login
    case refreshToken
    
    // Team management endpoints
    case userTeams(String) // userId
    case teamDetails(String) // teamCode
    case addTeam(String) // userId
    case removeTeam(String, String) // userId, teamId
    case setActiveTeam(String) // userId
    
    var cacheKey: String {
        switch self {
        case .players: return "/api/players"
        case .stats: return "/api/stats/summary"
        case .health: return "/health"
        case let .player(id): return "/api/players/\(id)"
        case .cashCows: return "/api/stats/cash-cows"
        case .captainSuggestions: return "/api/captain/suggestions"
        case .refreshCache: return "/api/refresh"
        case .login: return "/api/auth/login"
        case .refreshToken: return "/api/auth/refresh"
        case let .userTeams(userId): return "/api/users/\(userId)/teams"
        case let .teamDetails(teamCode): return "/api/teams/\(teamCode)"
        case let .addTeam(userId): return "/api/users/\(userId)/teams"
        case let .removeTeam(userId, teamId): return "/api/users/\(userId)/teams/\(teamId)"
        case let .setActiveTeam(userId): return "/api/users/\(userId)/active-team"
        }
    }
    
    var path: String {
        return cacheKey
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
