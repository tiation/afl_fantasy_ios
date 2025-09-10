import SwiftUI

@available(iOS 16.0, *)
@main
struct AFLFantasyApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoggedIn {
                    DashboardView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(appState)
            .onAppear {
                appState.checkLoginStatus()
            }
        }
    }
}

// MARK: - App State Management

@available(iOS 16.0, *)
@MainActor
final class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var hasAFLCredentials = false
    
    private let keychainManager = KeychainManager()
    
    func checkLoginStatus() {
        // Check if user has AFL Fantasy credentials
        hasAFLCredentials = keychainManager.hasAFLCredentials()
        
        // For now, consider user logged in if they have any stored credentials
        // In a real app, you'd validate these credentials with your auth system
        isLoggedIn = hasAFLCredentials || keychainManager.getAFLUsername() != nil
    }
    
    func login() {
        isLoggedIn = true
    }
    
    func logout() {
        keychainManager.clearAllData()
        isLoggedIn = false
        hasAFLCredentials = false
    }
}
