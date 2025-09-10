import Foundation
import Combine

/// Service for managing user authentication state and operations
@MainActor
final class AuthenticationService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let keychainService = KeychainService.shared
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    private enum Keys {
        static let isLoggedIn = "is_logged_in"
        static let userId = "user_id"
        static let userEmail = "user_email"
    }
    
    // MARK: - Initialization
    
    init() {
        loadAuthenticationState()
    }
    
    // MARK: - Public Methods
    
    /// Authenticate user with email and password
    func login(email: String, password: String) async {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please enter both email and password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // In a real app, this would make an API call
            // For now, simulate login with basic validation
            
            await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            if email.contains("@") && password.count >= 6 {
                // Simulate successful login
                let user = User(
                    id: UUID().uuidString,
                    email: email,
                    name: email.components(separatedBy: "@").first ?? "User",
                    joinDate: Date(),
                    isPremium: false
                )
                
                currentUser = user
                isLoggedIn = true
                saveAuthenticationState()
                
                // Store credentials securely
                try keychainService.storeCredentials(email: email, password: password)
                
            } else {
                errorMessage = "Invalid email or password. Password must be at least 6 characters."
            }
            
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Sign up a new user
    func signUp(name: String, email: String, password: String) async {
        guard !name.isEmpty && !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            // Simulate successful signup
            let user = User(
                id: UUID().uuidString,
                email: email,
                name: name,
                joinDate: Date(),
                isPremium: false
            )
            
            currentUser = user
            isLoggedIn = true
            saveAuthenticationState()
            
            // Store credentials securely
            try keychainService.storeCredentials(email: email, password: password)
            
        } catch {
            errorMessage = "Sign up failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Log out the current user
    func logout() {
        isLoggedIn = false
        currentUser = nil
        errorMessage = nil
        clearAuthenticationState()
        
        // Clear stored credentials
        do {
            try keychainService.clearCredentials()
        } catch {
            print("Error clearing credentials: \(error)")
        }
    }
    
    /// Check if user has premium subscription
    var isPremiumUser: Bool {
        currentUser?.isPremium ?? false
    }
    
    /// Refresh user authentication if needed
    func refreshAuthentication() async {
        // In a real app, this would refresh the auth token
        // For now, just validate the stored credentials
        
        guard let credentials = try? keychainService.getStoredCredentials() else {
            logout()
            return
        }
        
        // Auto-login with stored credentials
        await login(email: credentials.email, password: credentials.password)
    }
    
    // MARK: - Private Methods
    
    private func loadAuthenticationState() {
        isLoggedIn = userDefaults.bool(forKey: Keys.isLoggedIn)
        
        if isLoggedIn {
            // Load user data
            let userId = userDefaults.string(forKey: Keys.userId) ?? ""
            let userEmail = userDefaults.string(forKey: Keys.userEmail) ?? ""
            
            currentUser = User(
                id: userId,
                email: userEmail,
                name: userEmail.components(separatedBy: "@").first ?? "User",
                joinDate: Date(),
                isPremium: false
            )
        }
    }
    
    private func saveAuthenticationState() {
        userDefaults.set(isLoggedIn, forKey: Keys.isLoggedIn)
        userDefaults.set(currentUser?.id, forKey: Keys.userId)
        userDefaults.set(currentUser?.email, forKey: Keys.userEmail)
    }
    
    private func clearAuthenticationState() {
        userDefaults.removeObject(forKey: Keys.isLoggedIn)
        userDefaults.removeObject(forKey: Keys.userId)
        userDefaults.removeObject(forKey: Keys.userEmail)
    }
}

// MARK: - Supporting Models

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let joinDate: Date
    let isPremium: Bool
}

// MARK: - Keychain Extensions

extension KeychainService {
    
    struct UserCredentials {
        let email: String
        let password: String
    }
    
    func storeCredentials(email: String, password: String) throws {
        let credentials = "\(email):\(password)".data(using: .utf8)!
        try storeData(credentials, key: "user_credentials")
    }
    
    func getStoredCredentials() throws -> UserCredentials {
        let data = try getData(key: "user_credentials")
        let credentialString = String(data: data, encoding: .utf8)!
        let components = credentialString.components(separatedBy: ":")
        
        guard components.count == 2 else {
            throw KeychainError.invalidCredentials
        }
        
        return UserCredentials(email: components[0], password: components[1])
    }
    
    func clearCredentials() throws {
        try deleteData(key: "user_credentials")
    }
}

// MARK: - Keychain Error Extensions

extension KeychainError {
    static let invalidCredentials = KeychainError.unableToStore
}
