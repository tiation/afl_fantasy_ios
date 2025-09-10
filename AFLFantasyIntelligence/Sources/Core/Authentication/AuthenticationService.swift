import SwiftUI
import Combine
import LocalAuthentication

// MARK: - AuthenticationService

@MainActor
final class AuthenticationService: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: AuthenticationError?
    
    // MARK: - Private Properties
    
    private let keychain = KeychainService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    
    private struct Keys {
        static let userId = "user_id"
        static let userToken = "auth_token"
        static let userData = "user_data"
        static let biometricEnabled = "biometric_enabled"
    }
    
    // MARK: - Initialization
    
    init() {
        checkExistingAuth()
    }
    
    // MARK: - Public Methods
    
    /// Check if user is already authenticated
    func checkExistingAuth() {
        guard let userData = keychain.getData(for: Keys.userData),
              let user = try? JSONDecoder().decode(User.self, from: userData) else {
            isAuthenticated = false
            return
        }
        
        currentUser = user
        isAuthenticated = true
    }
    
    /// Login with AFL Fantasy credentials
    func login(email: String, password: String) async {
        isLoading = true
        error = nil
        
        do {
            // Simulate API call - replace with actual AFL Fantasy API
            let user = try await authenticateWithAFLFantasy(email: email, password: password)
            
            // Store user data securely
            let userData = try JSONEncoder().encode(user)
            keychain.store(userData, for: Keys.userData)
            keychain.store(user.id, for: Keys.userId)
            if let token = user.authToken {
                keychain.store(token, for: Keys.userToken)
            }
            
            currentUser = user
            isAuthenticated = true
            
        } catch {
            self.error = error as? AuthenticationError ?? .unknownError
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    /// Login with biometric authentication
    func loginWithBiometrics() async {
        guard isBiometricEnabled else {
            error = .biometricNotEnabled
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let success = try await authenticateWithBiometrics()
            if success {
                checkExistingAuth()
            } else {
                error = .biometricAuthenticationFailed
            }
        } catch {
            self.error = .biometricAuthenticationFailed
        }
        
        isLoading = false
    }
    
    /// Logout current user
    func logout() {
        currentUser = nil
        isAuthenticated = false
        
        // Clear keychain
        keychain.delete(Keys.userData)
        keychain.delete(Keys.userId)
        keychain.delete(Keys.userToken)
        keychain.delete(Keys.biometricEnabled)
        
        error = nil
    }
    
    /// Enable biometric authentication
    func enableBiometricAuth() async -> Bool {
        guard await checkBiometricAvailability() else {
            error = .biometricNotAvailable
            return false
        }
        
        do {
            let success = try await authenticateWithBiometrics()
            if success {
                keychain.store("true", for: Keys.biometricEnabled)
                return true
            }
            return false
        } catch {
            self.error = .biometricAuthenticationFailed
            return false
        }
    }
    
    /// Disable biometric authentication
    func disableBiometricAuth() {
        keychain.delete(Keys.biometricEnabled)
    }
    
    // MARK: - Computed Properties
    
    var isBiometricEnabled: Bool {
        keychain.getString(for: Keys.biometricEnabled) == "true"
    }
    
    var biometricType: LABiometryType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        return context.biometryType
    }
    
    // MARK: - Private Methods
    
    private func authenticateWithAFLFantasy(email: String, password: String) async throws -> User {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Mock authentication - replace with actual AFL Fantasy API
        if email.isEmpty || password.isEmpty {
            throw AuthenticationError.invalidCredentials
        }
        
        // Simulate different responses
        if email == "demo@aflapp.com" && password == "password" {
            return User(
                id: "user_123",
                email: email,
                name: "Demo User",
                fantasyTeams: [
                    FantasyTeam(
                        id: "team_1",
                        name: "Demo Team",
                        code: "ABC123",
                        league: "Classic"
                    )
                ],
                authToken: "mock_token_12345"
            )
        } else {
            throw AuthenticationError.invalidCredentials
        }
    }
    
    private func checkBiometricAvailability() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    private func authenticateWithBiometrics() async throws -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"
        
        let reason = "Authenticate to access your AFL Fantasy account"
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return success
        } catch {
            throw AuthenticationError.biometricAuthenticationFailed
        }
    }
}

// MARK: - User Model

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    var fantasyTeams: [FantasyTeam]
    let authToken: String?
    let createdAt: Date
    
    init(
        id: String,
        email: String,
        name: String,
        fantasyTeams: [FantasyTeam] = [],
        authToken: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.fantasyTeams = fantasyTeams
        self.authToken = authToken
        self.createdAt = createdAt
    }
}

// MARK: - FantasyTeam Model

struct FantasyTeam: Codable, Identifiable {
    let id: String
    let name: String
    let code: String // For barcode/QR scanning
    let league: String
    let isActive: Bool
    let players: [String] // Player IDs
    let rank: Int?
    let points: Int?
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        name: String,
        code: String,
        league: String,
        isActive: Bool = true,
        players: [String] = [],
        rank: Int? = nil,
        points: Int? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.league = league
        self.isActive = isActive
        self.players = players
        self.rank = rank
        self.points = points
        self.createdAt = createdAt
    }
}

// MARK: - AuthenticationError

enum AuthenticationError: Error, LocalizedError {
    case invalidCredentials
    case networkError(String)
    case biometricNotAvailable
    case biometricNotEnabled
    case biometricAuthenticationFailed
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .networkError(let message):
            return "Network error: \(message)"
        case .biometricNotAvailable:
            return "Biometric authentication is not available on this device."
        case .biometricNotEnabled:
            return "Biometric authentication is not enabled."
        case .biometricAuthenticationFailed:
            return "Biometric authentication failed. Please try again."
        case .unknownError:
            return "An unknown error occurred. Please try again."
        }
    }
}
