import Foundation
import os.log
import SwiftUI

// MARK: - AuthCoordinator

@MainActor
final class AuthCoordinator: ObservableObject {
    // MARK: - Published State

    @Published private(set) var isAuthenticated = false
    @Published private(set) var isAuthenticating = false
    @Published private(set) var error: Error?

    // MARK: - Dependencies

    private let keychain: KeychainService
    private let logger = Logger(subsystem: "AFLFantasy", category: "AuthCoordinator")

    // MARK: - Initialization

    init(keychain: KeychainService = .shared) {
        self.keychain = keychain

        // Check initial auth state
        Task {
            await checkAuthenticationState()
        }
    }

    // MARK: - Public Methods

    func authenticate(teamId: String, sessionCookie: String, apiToken: String? = nil) async {
        guard !isAuthenticating else { return }

        isAuthenticating = true
        error = nil

        do {
            // Store credentials securely
            try await keychain.storeTeamId(teamId)
            try await keychain.storeSessionCookie(sessionCookie)
            if let token = apiToken {
                try await keychain.storeAPIToken(token)
            }

            // Validate stored credentials
            isAuthenticated = await keychain.validateStoredCredentials()
            logger.info("Authentication \(isAuthenticated ? "succeeded" : "failed")")
        } catch {
            self.error = error
            isAuthenticated = false
            logger.error("Authentication failed: \(error.localizedDescription)")
        }

        isAuthenticating = false
    }

    func logout() async {
        do {
            try await keychain.clearAllCredentials()
            isAuthenticated = false
            logger.info("Logout successful")
        } catch {
            self.error = error
            logger.error("Logout failed: \(error.localizedDescription)")
        }
    }

    func clearError() {
        error = nil
    }

    // MARK: - Private Methods

    private func checkAuthenticationState() async {
        do {
            // Check if we have valid credentials
            let hasTeamId = await keychain.exists(forKey: "afl_team_id")
            let hasSession = await keychain.exists(forKey: "afl_session_cookie")
            isAuthenticated = hasTeamId && hasSession

            if isAuthenticated {
                // Validate credentials are usable
                isAuthenticated = await keychain.validateStoredCredentials()
            }

            logger.info("Auth state check: \(isAuthenticated ? "authenticated" : "not authenticated")")
        } catch {
            isAuthenticated = false
            self.error = error
            logger.error("Auth state check failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - AuthError

enum AuthError: LocalizedError {
    case invalidCredentials
    case sessionExpired
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            "Invalid AFL Fantasy credentials"
        case .sessionExpired:
            "AFL Fantasy session expired"
        case let .networkError(error):
            "Network error during authentication: \(error.localizedDescription)"
        }
    }
}
