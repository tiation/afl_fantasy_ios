//
//  KeychainManager.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation
import Security

// MARK: - KeychainManager

/// Secure storage manager for AFL Fantasy credentials using iOS Keychain
class KeychainManager {
    // MARK: - Constants

    private enum Keys {
        static let aflTeamId = "afl_fantasy_team_id"
        static let aflSessionCookie = "afl_fantasy_session_cookie"
        static let aflAPIToken = "afl_fantasy_api_token"
    }

    private let service = "com.afl.fantasy.app"

    // MARK: - AFL Fantasy Credentials

    /// Check if AFL Fantasy credentials are stored
    func hasAFLCredentials() -> Bool {
        getAFLTeamId() != nil && getAFLSessionCookie() != nil
    }

    /// Store AFL Fantasy credentials securely
    func storeAFLCredentials(teamId: String, sessionCookie: String, apiToken: String? = nil) {
        store(key: Keys.aflTeamId, value: teamId)
        store(key: Keys.aflSessionCookie, value: sessionCookie)

        if let apiToken {
            store(key: Keys.aflAPIToken, value: apiToken)
        }
    }

    /// Retrieve AFL Fantasy team ID
    func getAFLTeamId() -> String? {
        retrieve(key: Keys.aflTeamId)
    }

    /// Retrieve AFL Fantasy session cookie
    func getAFLSessionCookie() -> String? {
        retrieve(key: Keys.aflSessionCookie)
    }

    /// Retrieve AFL Fantasy API token
    func getAFLAPIToken() -> String? {
        retrieve(key: Keys.aflAPIToken)
    }

    /// Clear all AFL Fantasy credentials
    func clearAFLCredentials() {
        delete(key: Keys.aflTeamId)
        delete(key: Keys.aflSessionCookie)
        delete(key: Keys.aflAPIToken)
    }

    // MARK: - Generic Keychain Operations

    /// Store a value in the keychain
    private func store(key: String, value: String) {
        // Delete existing item if it exists
        delete(key: key)

        // Create new keychain item
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: value.data(using: .utf8) as Any,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            print("Keychain store error for key '\(key)': \(status)")
        }
    }

    /// Retrieve a value from the keychain
    private func retrieve(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8)
        else {
            return nil
        }

        return value
    }

    /// Delete a value from the keychain
    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }

    /// Delete all keychain items for this service
    func clearAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess, status != errSecItemNotFound {
            print("Keychain clear all error: \(status)")
        }
    }
}

// MARK: - Keychain Error Handling

extension KeychainManager {
    /// Human-readable keychain error descriptions
    func keychainErrorDescription(for status: OSStatus) -> String {
        switch status {
        case errSecItemNotFound:
            "Item not found in keychain"
        case errSecDuplicateItem:
            "Duplicate item in keychain"
        case errSecParam:
            "Invalid keychain parameters"
        case errSecAuthFailed:
            "Keychain authentication failed"
        case errSecNotAvailable:
            "Keychain not available"
        case errSecInteractionNotAllowed:
            "Keychain interaction not allowed"
        case errSecUnimplemented:
            "Keychain function not implemented"
        case errSecAllocate:
            "Keychain memory allocation error"
        case errSecUserCanceled:
            "User canceled keychain operation"
        case errSecBadReq:
            "Bad keychain request"
        case errSecInternalError:
            "Internal keychain error"
        default:
            "Unknown keychain error: \(status)"
        }
    }
}

// MARK: - Testing Support

#if DEBUG
    extension KeychainManager {
        /// Store test AFL Fantasy credentials for development
        func storeTestCredentials() {
            storeAFLCredentials(
                teamId: "test_team_12345",
                sessionCookie: "test_session_cookie_value",
                apiToken: "test_api_token_value"
            )
        }

        /// Verify test credentials are stored correctly
        func verifyTestCredentials() -> Bool {
            getAFLTeamId() == "test_team_12345" &&
                getAFLSessionCookie() == "test_session_cookie_value" &&
                getAFLAPIToken() == "test_api_token_value"
        }
    }
#endif
