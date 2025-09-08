import Combine
import Foundation

// MARK: - GameStateProtocol

protocol GameStateProtocol {
    var isProcessing: Bool { get }
    var currentCaptain: EnhancedPlayer? { get }
    var fantasyPoints: Int { get }

    func refreshGameState() async -> Result<Bool, AFLFantasyError>
    func makeCaptain(player: EnhancedPlayer) async -> Result<Bool, AFLFantasyError>
    func makeTrade(in: EnhancedPlayer, out: EnhancedPlayer) async -> Result<Bool, AFLFantasyError>
}

// MARK: - SecureStorageProtocol

protocol SecureStorageProtocol {
    static var shared: SecureStorageProtocol { get }

    func saveCredentials(_ credentials: Data) throws
    func loadCredentials() throws -> Data
    func deleteCredentials() throws
}

// MARK: - AutoSyncProtocol

protocol AutoSyncProtocol {
    var lastSyncDate: Date? { get }
    var autoSyncEnabled: Bool { get set }

    func syncData() async -> Result<Bool, AFLFantasyError>
    func scheduleAutoSync(interval: TimeInterval)
    func cancelAutoSync()
}

