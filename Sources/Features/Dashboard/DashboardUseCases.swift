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
        return response.cashCows
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
        return response.suggestions
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

final class LiveStatsUseCase {
    private let apiClient: AFLAPIClientProtocol
    private let refreshInterval: TimeInterval
    
    init(apiClient: AFLAPIClientProtocol, refreshInterval: TimeInterval = 30.0) {
        self.apiClient = apiClient
        self.refreshInterval = refreshInterval
    }
    
    func livePlayersPublisher() -> AnyPublisher<[AFLPlayer], Error> {
        Timer.publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .prepend(Date()) // Emit immediately
            .flatMap { _ in
                self.apiClient.requestPublisher(.players, responseType: PlayersResponse.self)
                    .map(\.players)
            }
            .eraseToAnyPublisher()
    }
    
    func liveSummaryPublisher() -> AnyPublisher<SummaryResponse, Error> {
        Timer.publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .prepend(Date()) // Emit immediately
            .flatMap { _ in
                self.apiClient.requestPublisher(.summary, responseType: SummaryResponse.self)
            }
            .eraseToAnyPublisher()
    }
}
