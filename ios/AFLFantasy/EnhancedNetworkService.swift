//
//  EnhancedNetworkService.swift
//  AFL Fantasy Intelligence Platform
//
//  Enhanced network layer with comprehensive API endpoints, caching, and offline support
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import Combine
import Network

// MARK: - Enhanced Network Service

final class EnhancedNetworkService: ObservableObject {
    static let shared = EnhancedNetworkService()
    
    @Published var isConnected = true
    @Published var connectionQuality: ConnectionQuality = .excellent
    
    private let session: URLSession
    private let cache: URLCache
    private let monitor: NWPathMonitor
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    private var cancellables = Set<AnyCancellable>()
    
    // Configuration
    private let baseURL = "https://api.afldata.com/v1"
    private let timeout: TimeInterval = 30
    private let maxRetries = 3
    private let rateLimitDelay: TimeInterval = 1.0
    
    init() {
        // Configure URLSession with caching
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout * 2
        config.requestCachePolicy = .returnCacheDataElseLoad
        
        // Configure cache (50MB memory, 200MB disk)
        self.cache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024
        )
        config.urlCache = cache
        
        self.session = URLSession(configuration: config)
        
        // Network monitoring
        self.monitor = NWPathMonitor()
        setupNetworkMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionQuality = self?.evaluateConnectionQuality(path: path) ?? .poor
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    private func evaluateConnectionQuality(path: NWPath) -> ConnectionQuality {
        if path.isExpensive {
            return .limited
        } else if path.usesInterfaceType(.wifi) {
            return .excellent
        } else if path.usesInterfaceType(.cellular) {
            return .good
        } else {
            return .poor
        }
    }
}

// MARK: - API Endpoints

extension EnhancedNetworkService {
    
    // MARK: - Player Data
    
    func fetchPlayers() async throws -> [EnhancedPlayer] {
        let endpoint = "/players/enhanced"
        let response: APIResponse<[PlayerAPIModel]> = try await performRequest(endpoint: endpoint)
        
        guard let playerData = response.data else {
            throw AFLFantasyError.dataError("No player data received")
        }
        
        return playerData.map { $0.toEnhancedPlayer() }
    }
    
    func fetchPlayerDetails(playerId: Int) async throws -> EnhancedPlayer {
        let endpoint = "/players/\(playerId)/details"
        let response: APIResponse<PlayerAPIModel> = try await performRequest(endpoint: endpoint)
        
        guard let playerData = response.data else {
            throw AFLFantasyError.dataError("Player not found")
        }
        
        return playerData.toEnhancedPlayer()
    }
    
    // MARK: - Team Data
    
    func fetchUserTeam(teamId: String) async throws -> UserTeam {
        let endpoint = "/teams/\(teamId)"
        let response: APIResponse<UserTeamAPIModel> = try await performRequest(endpoint: endpoint)
        
        guard let teamData = response.data else {
            throw AFLFantasyError.dataError("Team not found")
        }
        
        return teamData.toUserTeam()
    }
    
    // MARK: - Trade Analysis
    
    func analyzeTradeScenario(_ scenario: TradeScenario) async throws -> TradeAnalysisResult {
        let endpoint = "/trades/analyze"
        let body = TradeAnalysisRequest(scenario: scenario)
        
        let response: APIResponse<TradeAnalysisResult> = try await performRequest(
            endpoint: endpoint,
            method: .POST,
            body: body
        )
        
        guard let analysisData = response.data else {
            throw AFLFantasyError.dataError("Trade analysis failed")
        }
        
        return analysisData
    }
    
    // MARK: - Captain Suggestions
    
    func fetchCaptainSuggestions(teamId: String, round: Int) async throws -> [CaptainSuggestion] {
        let endpoint = "/captain/suggestions"
        let params = [
            "team_id": teamId,
            "round": String(round)
        ]
        
        let response: APIResponse<[CaptainSuggestionAPIModel]> = try await performRequest(
            endpoint: endpoint,
            parameters: params
        )
        
        guard let suggestions = response.data else {
            throw AFLFantasyError.dataError("No captain suggestions available")
        }
        
        return try suggestions.map { try $0.toCaptainSuggestion() }
    }
    
    // MARK: - Cash Cow Analysis
    
    func fetchCashCowRecommendations(teamId: String) async throws -> [CashCowRecommendation] {
        let endpoint = "/cashcows/recommendations"
        let params = ["team_id": teamId]
        
        let response: APIResponse<[CashCowRecommendationAPIModel]> = try await performRequest(
            endpoint: endpoint,
            parameters: params
        )
        
        guard let recommendations = response.data else {
            throw AFLFantasyError.dataError("No cash cow recommendations available")
        }
        
        return recommendations.map { $0.toCashCowRecommendation() }
    }
    
    // MARK: - Analytics Data
    
    func fetchVenuePerformanceData() async throws -> [VenuePerformance] {
        let endpoint = "/analytics/venue-performance"
        let response: APIResponse<[VenuePerformanceAPIModel]> = try await performRequest(endpoint: endpoint)
        
        guard let venueData = response.data else {
            throw AFLFantasyError.dataError("No venue data available")
        }
        
        return venueData.map { $0.toVenuePerformance() }
    }
    
    func fetchPriceProjections(playerId: Int) async throws -> PriceProjection {
        let endpoint = "/analytics/price-projections/\(playerId)"
        let response: APIResponse<PriceProjectionAPIModel> = try await performRequest(endpoint: endpoint)
        
        guard let projectionData = response.data else {
            throw AFLFantasyError.dataError("No projection data available")
        }
        
        return projectionData.toPriceProjection()
    }
    
    func fetchConsistencyData(playerId: Int) async throws -> ConsistencyData {
        let endpoint = "/analytics/consistency/\(playerId)"
        let response: APIResponse<ConsistencyDataAPIModel> = try await performRequest(endpoint: endpoint)
        
        guard let consistencyData = response.data else {
            throw AFLFantasyError.dataError("No consistency data available")
        }
        
        return consistencyData.toConsistencyData()
    }
    
    func fetchTeamAnalytics() async throws -> [TeamAnalytics] {
        let endpoint = "/analytics/team-performance"
        let response: APIResponse<[TeamAnalyticsAPIModel]> = try await performRequest(endpoint: endpoint)
        
        guard let teamData = response.data else {
            throw AFLFantasyError.dataError("No team analytics available")
        }
        
        return teamData.map { $0.toTeamAnalytics() }
    }
    
    // MARK: - Live Updates
    
    func subscribeToLiveUpdates() -> AnyPublisher<LiveUpdate, Never> {
        // WebSocket or Server-Sent Events implementation would go here
        // For now, return a mock publisher
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .compactMap { _ in
                // Mock live update
                LiveUpdate.mock()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Core Request Method

extension EnhancedNetworkService {
    
    private func performRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        parameters: [String: String]? = nil,
        body: Encodable? = nil,
        useCache: Bool = true
    ) async throws -> T {
        
        var urlComponents = URLComponents(string: baseURL + endpoint)!
        
        // Add query parameters
        if let parameters = parameters {
            urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            throw AFLFantasyError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add body for POST/PUT requests
        if let body = body {
            request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }
        
        // Cache policy based on useCache and connection
        if useCache && !isConnected {
            request.cachePolicy = .returnCacheDataDontLoad
        } else if useCache {
            request.cachePolicy = .returnCacheDataElseLoad
        } else {
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        }
        
        return try await performRequestWithRetry(request: request)
    }
    
    private func performRequestWithRetry<T: Codable>(
        request: URLRequest,
        retryCount: Int = 0
    ) async throws -> T {
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AFLFantasyError.networkError("Invalid response")
            }
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                return try JSONDecoder().decode(T.self, from: data)
                
            case 401:
                throw AFLFantasyError.authenticationError
                
            case 429:
                if retryCount < maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(rateLimitDelay * 1_000_000_000))
                    return try await performRequestWithRetry(request: request, retryCount: retryCount + 1)
                } else {
                    throw AFLFantasyError.rateLimitExceeded
                }
                
            case 500...599:
                if retryCount < maxRetries {
                    let delay = pow(2.0, Double(retryCount)) // Exponential backoff
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    return try await performRequestWithRetry(request: request, retryCount: retryCount + 1)
                } else {
                    throw AFLFantasyError.serverError(httpResponse.statusCode)
                }
                
            default:
                throw AFLFantasyError.serverError(httpResponse.statusCode)
            }
            
        } catch {
            if retryCount < maxRetries && isRetryableError(error) {
                let delay = pow(2.0, Double(retryCount))
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await performRequestWithRetry(request: request, retryCount: retryCount + 1)
            } else {
                throw mapNetworkError(error)
            }
        }
    }
    
    private func isRetryableError(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .networkConnectionLost, .cannotConnectToHost:
                return true
            default:
                return false
            }
        }
        return false
    }
    
    private func mapNetworkError(_ error: Error) -> AFLFantasyError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkError("No internet connection")
            case .timedOut:
                return .networkError("Request timed out")
            case .cannotConnectToHost:
                return .networkError("Cannot connect to server")
            default:
                return .networkError(urlError.localizedDescription)
            }
        } else if error is DecodingError {
            return .dataError("Invalid data format")
        } else {
            return .unknownError
        }
    }
}

// MARK: - Supporting Types

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum ConnectionQuality {
    case excellent  // WiFi, fast connection
    case good      // Cellular, stable
    case limited   // Expensive/metered connection
    case poor      // Slow or unstable
}

struct AnyEncodable: Encodable {
    private let encode: (Encoder) throws -> Void
    
    init<T: Encodable>(_ encodable: T) {
        encode = encodable.encode
    }
    
    func encode(to encoder: Encoder) throws {
        try encode(encoder)
    }
}

// MARK: - API Models

struct PlayerAPIModel: Codable {
    let id: Int
    let name: String
    let position: String
    let team: String
    let price: Int
    let averageScore: Double?
    let lastScore: Int?
    let priceChange: Int?
    let ownership: Double?
    let form: [Int]?
    let projectedScore: Double?
    let injuryRisk: String?
    let venueAdvantage: Double?
    let consistency: Double?
    let isDoubtful: Bool?
    let isCashCow: Bool?
    let breakEvenPrice: Int?
    let cashGenerated: Int?
    let alertFlags: [String]?
    let fixtureRating: Double?
    let opponentStrength: Double?
    
    func toEnhancedPlayer() -> EnhancedPlayer {
        EnhancedPlayer(
            aflPlayerId: id,
            name: name,
            position: PlayerPosition(rawValue: position) ?? .midfielder,
            team: AFLTeam(rawValue: team) ?? .melbourne,
            price: price,
            averageScore: averageScore ?? 0,
            lastScore: lastScore ?? 0,
            priceChange: priceChange ?? 0,
            ownership: ownership ?? 0,
            form: form ?? [],
            projectedScore: projectedScore ?? 0,
            injuryRisk: InjuryRisk(rawValue: injuryRisk ?? "low") ?? .low,
            venueAdvantage: venueAdvantage ?? 0,
            consistency: consistency ?? 0,
            isDoubtful: isDoubtful ?? false,
            isCashCow: isCashCow ?? false,
            breakEvenPrice: breakEvenPrice ?? price,
            cashGenerated: cashGenerated ?? 0,
            alertFlags: alertFlags?.compactMap(AlertFlag.init(rawValue:)) ?? [],
            fixtureRating: fixtureRating ?? 0.5,
            opponentStrength: opponentStrength ?? 0.5
        )
    }
}

struct UserTeamAPIModel: Codable {
    let teamId: String
    let teamName: String
    let players: [PlayerAPIModel]
    let totalValue: Int
    let bankBalance: Int
    let tradesRemaining: Int
    let overallRank: Int
    let weeklyScore: Int
    
    func toUserTeam() -> UserTeam {
        UserTeam(
            teamId: teamId,
            teamName: teamName,
            players: players.map { $0.toEnhancedPlayer() },
            totalValue: totalValue,
            bankBalance: bankBalance,
            tradesRemaining: tradesRemaining,
            overallRank: overallRank,
            weeklyScore: weeklyScore
        )
    }
}

struct TradeAnalysisRequest: Codable {
    let playersOut: [Int] // Player IDs
    let playersIn: [Int] // Player IDs
    
    init(scenario: TradeScenario) {
        self.playersOut = scenario.playersOut.map(\.aflPlayerId)
        self.playersIn = scenario.playersIn.map(\.aflPlayerId)
    }
}

struct TradeAnalysisResult: Codable {
    let costDifference: Int
    let projectedScoreGain: Double
    let confidence: Double
    let aiRecommendation: String
    let riskLevel: String
}

struct CaptainSuggestionAPIModel: Codable {
    let player: PlayerAPIModel
    let confidence: Int
    let projectedPoints: Int
    let formRating: Double
    let fixtureRating: Double
    let opponent: String
    let venue: String?
    let reasoning: String?
    let riskFactors: [String]?
    
    func toCaptainSuggestion() throws -> CaptainSuggestion {
        CaptainSuggestion(
            player: player.toEnhancedPlayer(),
            confidence: confidence,
            projectedPoints: projectedPoints,
            formRating: formRating,
            fixtureRating: fixtureRating,
            opponent: opponent,
            venue: venue ?? "",
            reasoning: reasoning ?? "",
            riskFactors: riskFactors ?? []
        )
    }
}

struct CashCowRecommendationAPIModel: Codable {
    let playerName: String
    let currentPrice: Int
    let targetPrice: Int
    let cashGenerated: Int
    let projectedWeeks: Int
    let confidence: Double
    let sellUrgency: String
    let reasoning: String?
    
    func toCashCowRecommendation() -> CashCowRecommendation {
        CashCowRecommendation(
            playerName: playerName,
            currentPrice: currentPrice,
            targetPrice: targetPrice,
            cashGenerated: cashGenerated,
            projectedWeeks: projectedWeeks,
            confidence: confidence,
            sellUrgency: sellUrgency,
            reasoning: reasoning ?? ""
        )
    }
}

struct VenuePerformanceAPIModel: Codable {
    let venue: String
    let team: String
    let averageScore: Double
    let gamesPlayed: Int
    let winRate: Double
    let scoreVariance: Double
    
    func toVenuePerformance() -> VenuePerformance {
        VenuePerformance(
            venue: venue,
            team: AFLTeam(rawValue: team) ?? .melbourne,
            averageScore: averageScore,
            gamesPlayed: gamesPlayed,
            winRate: winRate,
            scoreVariance: scoreVariance
        )
    }
}

struct PriceProjectionAPIModel: Codable {
    let playerId: Int
    let currentPrice: Int
    let projectedPrices: [Int]
    let confidence: Double
    let factors: [String]?
    
    func toPriceProjection() -> PriceProjection {
        PriceProjection(
            playerId: playerId,
            currentPrice: currentPrice,
            projectedPrices: projectedPrices,
            confidence: confidence,
            factors: factors ?? []
        )
    }
}

struct ConsistencyDataAPIModel: Codable {
    let playerId: Int
    let weeklyScores: [Int]
    let mean: Double
    let standardDeviation: Double
    let coefficientOfVariation: Double
    
    func toConsistencyData() -> ConsistencyData {
        ConsistencyData(
            playerId: playerId,
            weeklyScores: weeklyScores,
            mean: mean,
            standardDeviation: standardDeviation,
            coefficientOfVariation: coefficientOfVariation
        )
    }
}

struct TeamAnalyticsAPIModel: Codable {
    let team: String
    let averageScore: Double
    let defensiveRating: Double
    let offensiveRating: Double
    let homeAdvantage: Double
    let recentForm: [Int]
    
    func toTeamAnalytics() -> TeamAnalytics {
        TeamAnalytics(
            team: AFLTeam(rawValue: team) ?? .melbourne,
            averageScore: averageScore,
            defensiveRating: defensiveRating,
            offensiveRating: offensiveRating,
            homeAdvantage: homeAdvantage,
            recentForm: recentForm
        )
    }
}

// MARK: - Live Updates

struct LiveUpdate: Codable {
    let type: LiveUpdateType
    let data: LiveUpdateData
    let timestamp: Date
    
    static func mock() -> LiveUpdate {
        LiveUpdate(
            type: .scoreUpdate,
            data: .score(LiveScoreUpdate(
                playerId: 123,
                currentScore: 85,
                isPlaying: true,
                timeRemaining: "Q4 15:30",
                lastAction: "Goal from 45m",
                updated: Date()
            )),
            timestamp: Date()
        )
    }
}

enum LiveUpdateType: String, Codable {
    case scoreUpdate = "score_update"
    case injuryUpdate = "injury_update"
    case priceChange = "price_change"
    case teamChange = "team_change"
}

enum LiveUpdateData: Codable {
    case score(LiveScoreUpdate)
    case injury(InjuryUpdate)
    case priceChange(PriceChangeUpdate)
    case teamChange(TeamChangeUpdate)
}

struct PriceChangeUpdate: Codable {
    let playerId: Int
    let oldPrice: Int
    let newPrice: Int
    let updated: Date
}

struct TeamChangeUpdate: Codable {
    let playerId: Int
    let oldTeam: String
    let newTeam: String
    let updated: Date
}
