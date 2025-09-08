import Foundation
import Combine

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
        self.session = URLSession(configuration: config)
        self.baseURL = URL(string: baseURL)!
        
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
        return try await request(endpoint: .players, responseType: [Player].self)
    }
    
    func fetchPlayer(id: String) async throws -> Player {
        return try await request(endpoint: .player(id), responseType: Player.self)
    }
    
    // MARK: - Cash Cow API
    
    func fetchCashCows() async throws -> [CashCowAnalysis] {
        return try await request(endpoint: .cashCows, responseType: [CashCowAnalysis].self)
    }
    
    // MARK: - Captain API
    
    func fetchCaptainSuggestions(venue: String? = nil, opponent: String? = nil) async throws -> [CaptainSuggestion] {
        let body = CaptainRequest(venue: venue, opponent: opponent)
        return try await request(endpoint: .captainSuggestions, method: .POST, body: body, responseType: [CaptainSuggestion].self)
    }
    
    // MARK: - Stats API
    
    func fetchStats() async throws -> APIStatsResponse {
        return try await request(endpoint: .stats, responseType: APIStatsResponse.self)
    }
    
    // MARK: - Cache Refresh
    
    func refreshCache() async throws {
        struct RefreshResponse: Codable {
            let status: String
            let message: String
        }
        let _ = try await request(endpoint: .refreshCache, method: .POST, body: EmptyBody(), responseType: RefreshResponse.self)
    }
    
    // MARK: - Generic Request Handler
    
    private func request<T: Codable, B: Codable>(
        endpoint: APIEndpoint,
        method: HTTPMethod = .GET,
        body: B? = nil,
        responseType: T.Type
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add body for POST requests
        if let body = body, method == .POST {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        // Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AFLFantasyError.networkError("Invalid response")
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
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

// MARK: - API Models

private struct CaptainRequest: Codable {
    let venue: String?
    let opponent: String?
}

private struct EmptyBody: Codable {}

// MARK: - API Configuration

enum APIEndpoint {
    case health
    case players
    case player(String)
    case cashCows
    case captainSuggestions
    case stats
    case refreshCache
    
    var path: String {
        switch self {
        case .health:
            return "/health"
        case .players:
            return "/api/players"
        case .player(let id):
            return "/api/players/\(id)"
        case .cashCows:
            return "/api/stats/cash-cows"
        case .captainSuggestions:
            return "/api/captain/suggestions"
        case .stats:
            return "/api/stats/summary"
        case .refreshCache:
            return "/api/refresh"
        }
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - Extensions

extension APIService {
    
    /// Convenience method to fetch players with retry logic
    func fetchPlayersWithRetry(maxRetries: Int = 3) async -> Result<[Player], AFLFantasyError> {
        for attempt in 1...maxRetries {
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
