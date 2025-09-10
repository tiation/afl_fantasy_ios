import Foundation
import Combine

/// API client for AFL Fantasy app
class APIClient {
    static let shared = APIClient()
    
    private let baseURL = URL(string: "http://localhost:8080")!
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    // MARK: - Player Data
    
    func getPlayerStats(id: String) -> AnyPublisher<Player, Error> {
        get("/api/players/\(id)")
    }
    
    func getPlayerHistory(id: String) -> AnyPublisher<[GameStats], Error> {
        get("/api/players/\(id)/history")
    }
    
    func getPriceProjections(
        ids: [String],
        weeks: Int
    ) -> AnyPublisher<[String: [PriceProjection]], Error> {
        let body: [String: Any] = [
            "playerIds": ids,
            "weeks": weeks
        ]
        return post("/api/players/price-projections", body: body)
    }
    
    // MARK: - Team Management
    
    func getCurrentTeam() -> AnyPublisher<Team, Error> {
        get("/api/team")
    }
    
    func makeTrade(
        playersIn: [String],
        playersOut: [String]
    ) -> AnyPublisher<TradeResult, Error> {
        let body: [String: Any] = [
            "playersIn": playersIn,
            "playersOut": playersOut
        ]
        return post("/api/team/trade", body: body)
    }
    
    // MARK: - Captain Selection
    
    func getCaptainSuggestions(
        venue: String,
        opponent: String,
        factors: [String]
    ) -> AnyPublisher<[CaptainSuggestion], Error> {
        let body: [String: Any] = [
            "venue": venue,
            "opponent": opponent,
            "considerationFactors": factors
        ]
        return post("/api/captain/suggestions", body: body)
    }
    
    // MARK: - Cash Cow Analysis
    
    func getCashCows(
        timeframe: String,
        minConfidence: Double
    ) -> AnyPublisher<[CashCowAnalysis], Error> {
        let params = [
            "timeframe": timeframe,
            "minConfidence": String(minConfidence)
        ]
        return get("/api/cash-cows", params: params)
    }
    
    // MARK: - Price Analytics
    
    func getPriceProjections(
        playerIds: [String],
        timeframe: Int
    ) -> AnyPublisher<[PriceProjection], Error> {
        let body: [String: Any] = [
            "playerIds": playerIds,
            "timeframe": timeframe
        ]
        return post("/api/price/projections", body: body)
    }
    
    // MARK: - Team Analysis
    
    func getTeamAnalysis() -> AnyPublisher<TeamAnalysis, Error> {
        get("/api/team/analysis")
    }
    
    // MARK: - Settings & Preferences
    
    func getSettings() -> AnyPublisher<Settings, Error> {
        get("/api/settings")
    }
    
    func updateSettings(_ settings: Settings) -> AnyPublisher<Settings, Error> {
        put("/api/settings", body: settings)
    }
    
    // MARK: - Generic Request Methods
    
    private func get<T: Decodable>(
        _ path: String,
        params: [String: String] = [:]
    ) -> AnyPublisher<T, Error> {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)!
        if !params.isEmpty {
            components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        var request = URLRequest(url: components.url!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func post<T: Decodable, U: Encodable>(
        _ path: String,
        body: U
    ) -> AnyPublisher<T, Error> {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try! encoder.encode(body)
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func post<T: Decodable>(
        _ path: String,
        body: [String: Any]
    ) -> AnyPublisher<T, Error> {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try! JSONSerialization.data(withJSONObject: body)
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func put<T: Decodable, U: Encodable>(
        _ path: String,
        body: U
    ) -> AnyPublisher<T, Error> {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try! encoder.encode(body)
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - API Client Extensions for Real Data

extension APIClient {
    
    // MARK: - Health & Stats
    
    func getHealthStatus() -> AnyPublisher<APIHealthResponse, Error> {
        get("/health")
    }
    
    func getStatsResponse() -> AnyPublisher<APIStatsResponse, Error> {
        get("/api/stats/summary")
    }
    
    // MARK: - Player Data
    
    func getAllPlayers() -> AnyPublisher<[APIPlayerSummary], Error> {
        get("/api/players")
    }
    
    func getPlayerDetail(id: String) -> AnyPublisher<PlayerDetailResponse, Error> {
        get("/api/players/\(id)")
    }
    
    // MARK: - Cash Cow Analysis
    
    func getCashCows() -> AnyPublisher<[CashCowData], Error> {
        get("/api/stats/cash-cows")
    }
    
    // MARK: - Captain Selection
    
    func getCaptainSuggestions(venue: String?, opponent: String?) -> AnyPublisher<[CaptainSuggestionResponse], Error> {
        let body: [String: Any?] = [
            "venue": venue,
            "opponent": opponent
        ]
        
        // Filter out nil values
        let filteredBody = body.compactMapValues { $0 }
        
        return post("/api/captain/suggestions", body: filteredBody)
    }
    
    // MARK: - Cache Management
    
    func refreshCache() -> AnyPublisher<RefreshResponse, Error> {
        post("/api/refresh", body: [String: String]())
    }
}

// MARK: - Additional Response Models

struct PlayerDetailResponse: Codable {
    let playerId: String
    let fileName: String
    let careerStats: [CareerStat]?
    let opponentSplits: [OpponentSplit]?
    let recentForm: [GameResult]?
    let gameHistory: [GameResult]?
    let venueStats: [VenueStat]?
    let playerInfo: APIPlayerSummary
}

struct CareerStat: Codable {
    let player: String?
    let yr: String?
    let tm: String?
    let fp: Double?
    let gp: Int?
    let price: Int?
}

struct OpponentSplit: Codable {
    let opp: String?
    let gm: Int?
    let fp: Double?
    let avg: Double?
}

struct GameResult: Codable {
    let date: String?
    let opponent: String?
    let fp: Double?
    let score: Int?
}

struct VenueStat: Codable {
    let venue: String?
    let games: Int?
    let avg: Double?
    let best: Double?
}

struct RefreshResponse: Codable {
    let status: String
    let message: String
    let timestamp: String
}
