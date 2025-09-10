import Foundation
import Security

// MARK: - KeychainService

/// Secure storage service for sensitive data like API keys
final class KeychainService: Sendable {
    
    // MARK: - Shared Instance
    
    static let shared = KeychainService()
    
    // MARK: - Properties
    
    private let service = "com.aflsi.fantasy-intelligence.keychain"
    
    // MARK: - Private Init
    
    private init() {}
    
    // MARK: - API Key Management
    
    /// Stores the OpenAI API key securely in Keychain
    func storeAPIKey(_ apiKey: String) throws {
        let data = apiKey.data(using: .utf8) ?? Data()
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "openai-api-key",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unableToStore(status)
        }
    }
    
    /// Retrieves the OpenAI API key from Keychain
    func getAPIKey() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "openai-api-key",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.unableToRetrieve(status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.unexpectedData
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    /// Removes the API key from Keychain
    func removeAPIKey() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "openai-api-key"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unableToDelete(status)
        }
    }
    
    /// Checks if API key exists and is valid format
    func hasValidAPIKey() -> Bool {
        guard let apiKey = try? getAPIKey(),
              !apiKey.isEmpty,
              apiKey.hasPrefix("sk-") else {
            return false
        }
        return true
    }
    
    // MARK: - Generic Data Storage Methods
    
    /// Store generic data in Keychain
    func store(_ data: Data, for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }
    
    /// Store string in Keychain
    func store(_ string: String, for key: String) {
        guard let data = string.data(using: .utf8) else { return }
        store(data, for: key)
    }
    
    /// Get data from Keychain
    func getData(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }
    
    /// Get string from Keychain
    func getString(for key: String) -> String? {
        guard let data = getData(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// Delete item from Keychain
    func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - KeychainError

enum KeychainError: Error, LocalizedError {
    case unableToStore(OSStatus)
    case unableToRetrieve(OSStatus)
    case unableToDelete(OSStatus)
    case unexpectedData
    
    var errorDescription: String? {
        switch self {
        case .unableToStore(let status):
            return "Unable to store item in keychain: \(status)"
        case .unableToRetrieve(let status):
            return "Unable to retrieve item from keychain: \(status)"
        case .unableToDelete(let status):
            return "Unable to delete item from keychain: \(status)"
        case .unexpectedData:
            return "Unexpected data format in keychain"
        }
    }
}
