//
//  KeychainService.swift
//  AFL Fantasy Intelligence Platform
//
//  Secure keychain storage for authentication tokens and sensitive data
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import os.log
import Security

// MARK: - KeychainService

final class KeychainService {
    static let shared = KeychainService()

    private let logger = Logger(subsystem: "AFLFantasy", category: "KeychainService")
    private let serviceName = "com.aflai.fantasy"

    private init() {}

    // MARK: - AFL Fantasy Credentials

    func storeTeamId(_ teamId: String) async throws {
        try await store(data: teamId.data(using: .utf8)!, forKey: "afl_team_id")
    }

    func retrieveTeamId() async throws -> String {
        let data = try await retrieve(forKey: "afl_team_id")
        guard let teamId = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        return teamId
    }

    func storeSessionCookie(_ cookie: String) async throws {
        try await store(data: cookie.data(using: .utf8)!, forKey: "afl_session_cookie")
    }

    func retrieveSessionCookie() async throws -> String {
        let data = try await retrieve(forKey: "afl_session_cookie")
        guard let cookie = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        return cookie
    }

    func storeAPIToken(_ token: String) async throws {
        try await store(data: token.data(using: .utf8)!, forKey: "afl_api_token")
    }

    func retrieveAPIToken() async throws -> String {
        let data = try await retrieve(forKey: "afl_api_token")
        guard let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        return token
    }

    func storeCSRFToken(_ token: String) async throws {
        try await store(data: token.data(using: .utf8)!, forKey: "afl_csrf_token")
    }

    func retrieveCSRFToken() async throws -> String {
        let data = try await retrieve(forKey: "afl_csrf_token")
        guard let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        return token
    }

    func clearAllCredentials() async throws {
        let keys = ["afl_team_id", "afl_session_cookie", "afl_api_token", "afl_csrf_token"]

        for key in keys {
            try await delete(forKey: key)
        }

        logger.info("Cleared all AFL Fantasy credentials")
    }

    // MARK: - Generic Keychain Operations

    private func store(data: Data, forKey key: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData as String: data
        ]

        // Delete any existing item first
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            logger.error("Failed to store keychain item: \(status)")
            throw KeychainError.storageError(status)
        }

        logger.info("Successfully stored keychain item for key: \(key, privacy: .public)")
    }

    private func retrieve(forKey key: String) async throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            logger.error("Failed to retrieve keychain item: \(status)")
            throw KeychainError.retrievalError(status)
        }

        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }

        logger.info("Successfully retrieved keychain item for key: \(key, privacy: .public)")
        return data
    }

    private func delete(forKey key: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            logger.error("Failed to delete keychain item: \(status)")
            throw KeychainError.deletionError(status)
        }

        logger.info("Successfully deleted keychain item for key: \(key, privacy: .public)")
    }

    func exists(forKey key: String) async -> Bool {
        do {
            _ = try await retrieve(forKey: key)
            return true
        } catch {
            return false
        }
    }
}

// MARK: - KeychainError

enum KeychainError: LocalizedError {
    case storageError(OSStatus)
    case retrievalError(OSStatus)
    case deletionError(OSStatus)
    case itemNotFound
    case invalidData

    var errorDescription: String? {
        switch self {
        case let .storageError(status):
            "Failed to store item in keychain: \(status)"
        case let .retrievalError(status):
            "Failed to retrieve item from keychain: \(status)"
        case let .deletionError(status):
            "Failed to delete item from keychain: \(status)"
        case .itemNotFound:
            "Item not found in keychain"
        case .invalidData:
            "Invalid data format in keychain"
        }
    }
}

// MARK: - Keychain Configuration Helper

extension KeychainService {
    func configureForFirstLaunch() async {
        logger.info("Configuring keychain for first launch")

        // Check if credentials exist, if not, we need user authentication
        let hasTeamId = await exists(forKey: "afl_team_id")
        let hasSession = await exists(forKey: "afl_session_cookie")

        if !hasTeamId || !hasSession {
            logger.info("No credentials found - user needs to authenticate")
            // This would trigger the authentication flow in the UI
        }
    }

    func validateStoredCredentials() async -> Bool {
        let requiredKeys = ["afl_team_id"]

        for key in requiredKeys {
            guard await exists(forKey: key) else {
                logger.warning("Missing required credential: \(key, privacy: .public)")
                return false
            }
        }

        return true
    }
}
