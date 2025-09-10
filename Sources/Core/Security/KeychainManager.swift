import Foundation
import Security

@MainActor
final class KeychainManager {
    static let shared = KeychainManager()
    
    private init() {}
    
    private let service = "com.tiaastor.aflfantasy"
    private let server = "aflfantasy.tiaastor.com"
    
    // MARK: - AFL Fantasy Credentials
    func storeAFLCredentials(username: String, password: String) {
        let usernameKey = "afl.username"
        let passwordKey = "afl.password"
        
        // Store username as generic password
        storeGenericPassword(account: usernameKey, password: username.data(using: .utf8)!)
        
        // Store password as internet password with additional security
        storeInternetPassword(account: username, server: server, password: password.data(using: .utf8)!)
    }
    
    func retrieveAFLCredentials() -> (username: String, password: String)? {
        let usernameKey = "afl.username"
        
        guard let usernameData = retrieveGenericPassword(account: usernameKey),
              let username = String(data: usernameData, encoding: .utf8),
              let passwordData = retrieveInternetPassword(account: username, server: server),
              let password = String(data: passwordData, encoding: .utf8) else {
            return nil
        }
        
        return (username, password)
    }
    
    func deleteAFLCredentials() {
        let usernameKey = "afl.username"
        
        if let credentials = retrieveAFLCredentials() {
            deleteInternetPassword(account: credentials.username, server: server)
        }
        deleteGenericPassword(account: usernameKey)
    }
    
    // MARK: - AFL Team ID Storage
    func storeAFLTeamId(_ teamId: String) {
        let teamIdKey = "afl.team.id"
        storeGenericPassword(account: teamIdKey, password: teamId.data(using: .utf8)!)
    }
    
    func retrieveAFLTeamId() -> String? {
        let teamIdKey = "afl.team.id"
        guard let data = retrieveGenericPassword(account: teamIdKey) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func deleteAFLTeamId() {
        let teamIdKey = "afl.team.id"
        deleteGenericPassword(account: teamIdKey)
    }
    
    // MARK: - Clear All Data
    func clearAllData() {
        deleteAFLCredentials()
        deleteAFLTeamId()
    }
    
    // MARK: - Private Keychain Operations
    private func storeGenericPassword(account: String, password: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: password,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error storing generic password: \(status)")
        }
    }
    
    private func retrieveGenericPassword(account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        } else {
            return nil
        }
    }
    
    private func deleteGenericPassword(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    private func storeInternetPassword(account: String, server: String, password: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecAttrAccount as String: account,
            kSecAttrProtocol as String: kSecAttrProtocolHTTPS,
            kSecValueData as String: password,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error storing internet password: \(status)")
        }
    }
    
    private func retrieveInternetPassword(account: String, server: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecAttrAccount as String: account,
            kSecAttrProtocol as String: kSecAttrProtocolHTTPS,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        } else {
            return nil
        }
    }
    
    private func deleteInternetPassword(account: String, server: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server,
            kSecAttrAccount as String: account,
            kSecAttrProtocol as String: kSecAttrProtocolHTTPS
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
