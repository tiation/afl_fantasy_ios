import Foundation

// MARK: - AFLFantasyToolsClient

/// AFLFantasyToolsClient defines the interface for interacting with fantasy tools.
public protocol AFLFantasyToolsClient: AnyObject {
    var isLoading: Bool { get }

    func getPlayers() async throws -> [Player]
    func getCaptainSuggestions() async throws -> [CaptainSuggestion]
    func getCashCows() async throws -> [Player]
    func refreshData() async throws
}

// MARK: - AFLFantasyToolsClientLive

/// AFLFantasyToolsClientLive provides a live implementation of AFLFantasyToolsClient.
@MainActor
public final class AFLFantasyToolsClientLive: AFLFantasyToolsClient, ObservableObject {
    @Published public private(set) var isLoading = false

    public init() {}

    public func getPlayers() async throws -> [Player] {
        // TODO: Replace with real API call + model mapping
        []
    }

    public func getCaptainSuggestions() async throws -> [CaptainSuggestion] {
        // TODO: Replace with real API call + model mapping
        []
    }

    public func getCashCows() async throws -> [Player] {
        // TODO: Replace with real API call + model mapping
        []
    }

    public func refreshData() async throws {
        // TODO: Replace with real API calls
    }
}
