import Foundation
import Security

// MARK: - KeychainService

/// Secure storage service for sensitive data like API keys
final class KeychainService {
    
    // MARK: - Properties
    
    private let service = "com.aflsi.fantasy-intelligence.keychain"
    
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
