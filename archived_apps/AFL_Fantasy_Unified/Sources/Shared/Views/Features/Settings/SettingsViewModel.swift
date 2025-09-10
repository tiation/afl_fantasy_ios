import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var isLoading = false
    @Published var username = ""
    @Published var teamName = ""
    @Published var isAIEnabled = true
    @Published var isLiveScoringEnabled = true
    @Published var isPriceAlertsEnabled = true
    @Published var selectedTheme = ThemeOption.system
    @Published var selectedScoreFormat = ScoreFormat.fantasy
    @Published var isAnalyticsEnabled = true
    @Published var leaguePrivacy = LeaguePrivacy.public
    @Published private(set) var cacheSize = "0 MB"
    @Published private(set) var appVersion = ""
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false
    @Published var successMessage = ""
    
    // MARK: - Dependencies
    
    private let settingsService: SettingsServiceProtocol
    private let userService: UserServiceProtocol
    private let authService: AuthServiceProtocol
    private let dataService: DataServiceProtocol
    
    // MARK: - Init
    
    init(
        settingsService: SettingsServiceProtocol = SettingsService(),
        userService: UserServiceProtocol = UserService(),
        authService: AuthServiceProtocol = AuthService(),
        dataService: DataServiceProtocol = DataService()
    ) {
        self.settingsService = settingsService
        self.userService = userService
        self.authService = authService
        self.dataService = dataService
    }
    
    // MARK: - Public Methods
    
    func loadSettings() {
        Task {
            do {
                isLoading = true
                defer { isLoading = false }
                
                // Load all settings in parallel
                async let userTask = userService.getUserProfile()
                async let settingsTask = settingsService.getSettings()
                async let cacheTask = dataService.getCacheSize()
                async let versionTask = settingsService.getAppVersion()
                
                // User profile
                let profile = try await userTask
                username = profile.username
                teamName = profile.teamName
                
                // Feature settings
                let settings = try await settingsTask
                isAIEnabled = settings.aiEnabled
                isLiveScoringEnabled = settings.liveScoring
                isPriceAlertsEnabled = settings.priceAlerts
                selectedTheme = settings.theme
                selectedScoreFormat = settings.scoreFormat
                isAnalyticsEnabled = settings.analyticsEnabled
                leaguePrivacy = settings.leaguePrivacy
                
                // App info
                cacheSize = try await cacheTask
                appVersion = await versionTask
                
            } catch {
                handleError(error)
            }
        }
    }
    
    func updateUsername(_ username: String) {
        Task {
            do {
                try await userService.updateUsername(username)
                self.username = username
                showSuccess(message: "Username updated successfully")
            } catch {
                handleError(error)
            }
        }
    }
    
    func updateTeamName(_ name: String) {
        Task {
            do {
                try await userService.updateTeamName(name)
                self.teamName = name
                showSuccess(message: "Team name updated successfully")
            } catch {
                handleError(error)
            }
        }
    }
    
    func updateLeaguePrivacy(_ privacy: LeaguePrivacy) {
        Task {
            do {
                try await settingsService.updateLeaguePrivacy(privacy.rawValue)
                self.leaguePrivacy = privacy
                showSuccess(message: "League privacy updated successfully")
            } catch {
                handleError(error)
            }
        }
    }
    
    func clearCache() {
        Task {
            do {
                try await dataService.clearCache()
                cacheSize = try await dataService.getCacheSize()
                showSuccess(message: "Cache cleared successfully")
            } catch {
                handleError(error)
            }
        }
    }
    
    func exportData() {
        Task {
            do {
                try await dataService.exportUserData()
                showSuccess(message: "Data exported successfully")
            } catch {
                handleError(error)
            }
        }
    }
    
    func openSupport() {
        Task {
            do {
                try await settingsService.openSupport()
            } catch {
                handleError(error)
            }
        }
    }
    
    func signOut() {
        Task {
            do {
                try await authService.signOut()
                // Navigation handled by auth state change
            } catch {
                handleError(error)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func showSuccess(message: String) {
        successMessage = message
        showSuccess = true
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

// MARK: - Note
// Service protocols are defined in Services/ServiceProtocols.swift
// Data models are defined in Models/Models.swift
