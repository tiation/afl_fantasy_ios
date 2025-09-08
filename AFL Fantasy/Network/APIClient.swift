import Foundation
import Combine

/// API client for AFL Fantasy app
class APIClient {
    static let shared = APIClient()
    
    private let baseURL = URL(string: "http://localhost:4000")!
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
