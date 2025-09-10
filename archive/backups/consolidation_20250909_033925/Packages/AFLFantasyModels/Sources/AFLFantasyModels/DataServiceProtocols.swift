import Foundation

// MARK: - ScraperError

public enum ScraperError: Error {
    case missingCredentials
    case authenticationFailed
    case networkError
    case responseParsingError
}

// MARK: - AFLFantasyError

public enum AFLFantasyError: Error {
    case authenticationRequired
    case networkError(Error)
    case notAuthenticated
    case invalidRequest
    case serverError
    case unknown
}

// MARK: - AFLFantasyScraperServiceProtocol

public protocol AFLFantasyScraperServiceProtocol {
    var isProcessing: Bool { get }
    var currentCaptain: EnhancedPlayer? { get }
    var fantasyPoints: Int { get }

    func fetchTeamData() async throws -> TeamData
    func refreshGameState() async throws -> Bool
    func makeCaptain(player: EnhancedPlayer) async throws -> Bool
    func makeTrade(in: EnhancedPlayer, out: EnhancedPlayer) async throws -> Bool
}

// MARK: - KeychainService

public protocol KeychainService {
    var shared: KeychainService { get }

    func exists(forKey key: String) async -> Bool
    func validateStoredCredentials() async -> Bool
    func clearAllCredentials() async throws
    func storeTeamId(_ teamId: String) async throws
    func storeSessionCookie(_ cookie: String) async throws
    func storeAPIToken(_ token: String) async throws
}

// MARK: - DataSyncManager

public protocol DataSyncManager {
    var lastSyncDate: Date? { get }
    var autoSyncEnabled: Bool { get set }

    func syncData() async throws
    func refreshAllData() async
    func scheduleAutoSync(interval: TimeInterval)
    func cancelAutoSync()
}
