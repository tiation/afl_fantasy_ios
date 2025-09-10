import Foundation
import Security

// MARK: - KeychainManager

/// Secure storage manager for AFL Fantasy app credentials and user data
final class KeychainManager {
    
    // MARK: - Properties
    
    private let service = "com.tiaastor.AFLFantasy"
    
    // MARK: - Keys
    
    private enum Key {
        static let aflUsername = "afl-username"
        static let aflPassword = "afl-password" 
        static let aflTeamId = "afl-team-id"
        static let aflSessionCookie = "afl-session-cookie"
        static let avatarURL = "avatar-url"
        static let userProfile = "user-profile"
    }
    
    // MARK: - AFL Fantasy Credentials
    
    /// Store AFL Fantasy username securely
    func storeAFLUsername(_ username: String) {
        store(key: Key.aflUsername, value: username)
    }
    
    /// Get stored AFL Fantasy username
    func getAFLUsername() -> String? {
        return retrieve(key: Key.aflUsername)
    }
    
    /// Store AFL Fantasy password securely
    func storeAFLPassword(_ password: String) {
        store(key: Key.aflPassword, value: password)
    }
    
    /// Get stored AFL Fantasy password
    func getAFLPassword() -> String? {
        return retrieve(key: Key.aflPassword)
    }
    
    /// Store AFL Fantasy team ID
    func storeAFLTeamId(_ teamId: String) {
        store(key: Key.aflTeamId, value: teamId)
    }
    
    /// Get stored AFL Fantasy team ID
    func getAFLTeamId() -> String? {
        return retrieve(key: Key.aflTeamId)
    }
    
    /// Store AFL Fantasy session cookie
    func storeAFLSessionCookie(_ cookie: String) {
        store(key: Key.aflSessionCookie, value: cookie)
    }
    
    /// Get stored AFL Fantasy session cookie
    func getAFLSessionCookie() -> String? {
        return retrieve(key: Key.aflSessionCookie)
    }
    
    /// Check if AFL Fantasy credentials exist
    func hasAFLCredentials() -> Bool {
        return getAFLUsername() != nil && getAFLPassword() != nil
    }
    
    /// Remove all AFL Fantasy credentials
    func clearAFLCredentials() {
        remove(key: Key.aflUsername)
        remove(key: Key.aflPassword)
        remove(key: Key.aflTeamId)
        remove(key: Key.aflSessionCookie)
    }
    
    // MARK: - Avatar Management
    
    /// Store avatar URL
    func storeAvatarURL(_ url: String) {
        store(key: Key.avatarURL, value: url)
    }
    
    /// Get stored avatar URL
    func getAvatarURL() -> String? {
        return retrieve(key: Key.avatarURL)
    }
    
    /// Remove avatar URL
    func clearAvatarURL() {
        remove(key: Key.avatarURL)
    }
    
    // MARK: - User Profile
    
    /// Store user profile data as JSON
    func storeUserProfile<T: Codable>(_ profile: T) throws {
        let data = try JSONEncoder().encode(profile)
        store(key: Key.userProfile, data: data)
    }
    
    /// Get stored user profile
    func getUserProfile<T: Codable>(as type: T.Type) throws -> T? {
        guard let data = retrieveData(key: Key.userProfile) else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
    
    /// Remove user profile
    func clearUserProfile() {
        remove(key: Key.userProfile)
    }
    
    // MARK: - Generic Storage Methods
    
    private func store(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        store(key: key, data: data)
    }
    
    private func store(key: String, data: Data) {
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
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("KeychainManager: Failed to store \(key) - Status: \(status)")
        }
    }
    
    private func retrieve(key: String) -> String? {
        guard let data = retrieveData(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    private func retrieveData(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status != errSecItemNotFound {
                print("KeychainManager: Failed to retrieve \(key) - Status: \(status)")
            }
            return nil
        }
        
        return result as? Data
    }
    
    private func remove(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            print("KeychainManager: Failed to remove \(key) - Status: \(status)")
        }
    }
    
    // MARK: - AI Personalization Settings
    
    /// Get AI personalization settings
    func getAIPersonalizationSettings() -> AIPersonalizationSettings? {
        // For now, return nil - this would typically be stored and retrieved from keychain
        // Implementation would depend on the AIPersonalizationSettings structure
        return nil
    }
    
    // MARK: - Clear All Data
    
    /// Remove all stored data for this app
    func clearAllData() {
        clearAFLCredentials()
        clearAvatarURL()
        clearUserProfile()
    }
}

// MARK: - KeychainManager Error

enum KeychainManagerError: Error, LocalizedError {
    case encodingFailed
    case decodingFailed
    case storageError(OSStatus)
    case retrievalError(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode data for keychain storage"
        case .decodingFailed:
            return "Failed to decode data from keychain"
        case .storageError(let status):
            return "Keychain storage failed with status: \(status)"
        case .retrievalError(let status):
            return "Keychain retrieval failed with status: \(status)"
        }
    }
}
