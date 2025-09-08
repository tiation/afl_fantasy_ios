import Foundation
import Combine

// MARK: - Dashboard Use Cases

/// Fetches all players for dashboard display
final class FetchPlayersUseCase: BaseUseCase<Void, [AFLPlayer]> {
    private let apiClient: AFLAPIClientProtocol
    
    init(apiClient: AFLAPIClientProtocol) {
        self.apiClient = apiClient
    }
    
    override func execute(_ input: Void) async throws -> [AFLPlayer] {
        let response: PlayersResponse = try await apiClient.request(.players)
        return response.players
    }
}

/// Fetches cash cow recommendations
final class FetchCashCowsUseCase: BaseUseCase<Void, [CashCow]> {
    private let apiClient: AFLAPIClientProtocol
    
    init(apiClient: AFLAPIClientProtocol) {
        self.apiClient = apiClient
    }
    
    override func execute(_ input: Void) async throws -> [CashCow] {
        let response: CashCowsResponse = try await apiClient.request(.cashCows)
        return response.cashCows.map { cashCowData in
            CashCow(
                id: cashCowData.playerId,
                name: cashCowData.playerName,
                team: "", // Not provided in CashCowData
                position: "", // Not provided in CashCowData
                price: Double(cashCowData.currentPrice),
                projectedPrice: Double(cashCowData.projectedPrice),
                potentialGain: Double(cashCowData.cashGenerated),
                breakeven: 0, // Not provided in CashCowData
                averageScore: cashCowData.fpAverage,
                gamesPlayed: cashCowData.gamesPlayed,
                ownership: 0.0 // Not provided in CashCowData
            )
        }
    }
}

/// Fetches captain suggestions
final class FetchCaptainSuggestionsUseCase: BaseUseCase<CaptainRequestInput, [CaptainSuggestion]> {
    private let apiClient: AFLAPIClientProtocol
    
    init(apiClient: AFLAPIClientProtocol) {
        self.apiClient = apiClient
    }
    
    override func execute(_ input: CaptainRequestInput) async throws -> [CaptainSuggestion] {
        let parameters: [String: Any] = [
            "round": input.round,
            "venue": input.venue ?? "",
            "opponent": input.opponent ?? "",
            "conditions": input.conditions
        ]
        
        let response: CaptainSuggestionsResponse = try await apiClient.request(.captainSuggestions(parameters))
        return response.suggestions.map { apiSuggestion in
            CaptainSuggestion(
                id: apiSuggestion.playerId,
                name: apiSuggestion.playerName,
                team: "", // Not provided in API response
                projectedScore: apiSuggestion.projectedPoints,
                ceiling: apiSuggestion.projectedPoints * 1.2, // Estimated
                floor: apiSuggestion.projectedPoints * 0.8, // Estimated
                consistency: apiSuggestion.confidence,
                ownership: 0.0, // Not provided in API response
                confidence: apiSuggestion.confidence,
                reasons: [apiSuggestion.reasoning]
            )
        }
    }
}

/// Fetches data summary statistics
final class FetchSummaryUseCase: BaseUseCase<Void, SummaryResponse> {
    private let apiClient: AFLAPIClientProtocol
    
    init(apiClient: AFLAPIClientProtocol) {
        self.apiClient = apiClient
    }
    
    override func execute(_ input: Void) async throws -> SummaryResponse {
        return try await apiClient.request(.summary)
    }
}

// MARK: - Input Models

struct CaptainRequestInput {
    let round: Int
    let venue: String?
    let opponent: String?
    let conditions: [String]
}

// MARK: - Live Stats Use Case (Combine-based)

@available(iOS 15.0, *)
final class LiveStatsUseCase {
    private let apiClient: AFLAPIClientProtocol
    private let refreshInterval: TimeInterval
    
    init(apiClient: AFLAPIClientProtocol, refreshInterval: TimeInterval = 30.0) {
        self.apiClient = apiClient
        self.refreshInterval = refreshInterval
    }
    
    @available(iOS 15.0, *)
    func livePlayersPublisher() -> AnyPublisher<[AFLPlayer], Error> {
        Timer.publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .prepend(Date()) // Emit immediately
            .flatMap(maxPublishers: .max(1)) { _ in
                self.apiClient.requestPublisher(.players, responseType: PlayersResponse.self)
                    .map(\.players)
            }
            .eraseToAnyPublisher()
    }
    
    @available(iOS 15.0, *)
    func liveSummaryPublisher() -> AnyPublisher<SummaryResponse, Error> {
        Timer.publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .prepend(Date()) // Emit immediately
            .flatMap(maxPublishers: .max(1)) { _ in
                self.apiClient.requestPublisher(.summary, responseType: SummaryResponse.self)
            }
            .eraseToAnyPublisher()
    }
}
