//
//  AFLFantasyDataService.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Combine
import Foundation

// MARK: - AFLFantasyDataServiceProtocol

protocol AFLFantasyDataServiceProtocol {
    var dashboardData: AnyPublisher<DashboardData?, Never> { get }
    var isAuthenticated: AnyPublisher<Bool, Never> { get }
    var isLoading: AnyPublisher<Bool, Never> { get }

    func authenticate(teamId: String, sessionCookie: String, apiToken: String?) async -> Result<Void, AFLFantasyError>
    func refreshDashboardData() async -> Result<DashboardData, AFLFantasyError>
    func logout()
}

// MARK: - AFLFantasyDataService

/// Main data service orchestrating AFL Fantasy data management
@MainActor
class AFLFantasyDataService: ObservableObject, @preconcurrency AFLFantasyDataServiceProtocol {
    // MARK: - Published Properties

    @Published private(set) var currentDashboardData: DashboardData?
    @Published private(set) var authenticated: Bool = false
    @Published private(set) var loading: Bool = false
    @Published private(set) var lastError: AFLFantasyError?
    @Published private(set) var lastUpdateTime: Date?

    // MARK: - Publishers

    var dashboardData: AnyPublisher<DashboardData?, Never> {
        $currentDashboardData.eraseToAnyPublisher()
    }

    var isAuthenticated: AnyPublisher<Bool, Never> {
        $authenticated.eraseToAnyPublisher()
    }

    var isLoading: AnyPublisher<Bool, Never> {
        $loading.eraseToAnyPublisher()
    }

    // MARK: - Dependencies

    private let scraper: AFLFantasyScraperServiceProtocol
    private let keychain: KeychainService
    private let dataSyncManager: DataSyncManager

    // MARK: - Cache Management

    private let cacheExpiryInterval: TimeInterval = 300 // 5 minutes
    private var refreshTimer: Timer?

    // MARK: - Initialization

    init(
        scraper: AFLFantasyScraperServiceProtocol = AFLFantasyScraperService.shared,
        keychain: KeychainService = .shared,
        appState: AppState = AppState()
    ) {
        self.scraper = scraper
        self.keychain = keychain
        dataSyncManager = DataSyncManager(scraper: scraper, appState: appState)

        Task {
            await checkStoredCredentials()
        }
    }

    deinit {
        refreshTimer?.invalidate()
    }

    // MARK: - Authentication

    /// Check for stored credentials and authenticate if available
    private func checkStoredCredentials() async {
        do {
            let hasTeamId = await keychain.exists(forKey: "afl_team_id")
            let hasSession = await keychain.exists(forKey: "afl_session_cookie")

            guard hasTeamId, hasSession else {
                authenticated = false
                return
            }

            // Validate stored credentials
            let valid = await keychain.validateStoredCredentials()
            if valid {
                authenticated = true
                await dataSyncManager.refreshAllData()
            } else {
                try await keychain.clearAllCredentials()
                authenticated = false
            }
        } catch {
            authenticated = false
            lastError = .authenticationRequired
        }
    }

    /// Authenticate with AFL Fantasy credentials
    func authenticate(
        teamId: String,
        sessionCookie: String,
        apiToken: String? = nil
    ) async -> Result<Void, AFLFantasyError> {
        loading = true
        lastError = nil

        defer { loading = false }

        do {
            // Store credentials securely
            try await keychain.storeTeamId(teamId)
            try await keychain.storeSessionCookie(sessionCookie)
            if let token = apiToken {
                try await keychain.storeAPIToken(token)
            }

            // Test credentials by fetching team data
            let teamData = try await scraper.fetchTeamData()

            // Update state
            authenticated = true
            currentDashboardData = DashboardData(
                teamValue: .init(teamValue: Double(teamData.teamValue)),
                teamScore: .init(totalScore: teamData.teamScore),
                rank: .init(rank: teamData.overallRank),
                captain: .init(captain: CaptainData.Captain(
                    name: teamData.captainName,
                    team: nil,
                    position: nil
                ))
            )
            lastUpdateTime = teamData.lastUpdated

            // Start periodic refresh
            startPeriodicRefresh()

            return .success(())
        } catch {
            // Clear credentials on failure
            try? await keychain.clearAllCredentials()
            authenticated = false
            currentDashboardData = nil
            lastError = .authenticationRequired
            return .failure(.authenticationRequired)
        }
    }

    /// Log out and clear stored credentials
    func logout() {
        refreshTimer?.invalidate()
        refreshTimer = nil

        Task {
            try? await keychain.clearAllCredentials()
            authenticated = false
            currentDashboardData = nil
            lastError = nil
            lastUpdateTime = nil

            print("✅ Logged out successfully")
        }
    }

    // MARK: - Data Fetching

    /// Set captain for the team
    func setCaptain(playerName: String) async throws {
        guard authenticated else {
            throw AFLFantasyError.notAuthenticated
        }

        loading = true
        defer { loading = false }

        // In production, this would call the actual API to set captain
        // For now, we'll simulate the API call and update local state
        do {
            // Simulate API delay
            try await Task.sleep(nanoseconds: 1_000_000_000)

            // Update current captain in dashboard data
            if var dashboardData = currentDashboardData {
                let newCaptain = CaptainData.Captain(
                    name: playerName,
                    team: "Unknown",
                    position: "Unknown"
                )
                let captainWrapper = DashboardData.Captain(captain: newCaptain)
                let updatedDashboardData = DashboardData(
                    teamValue: dashboardData.teamValue,
                    teamScore: dashboardData.teamScore,
                    rank: dashboardData.rank,
                    captain: captainWrapper
                )
                currentDashboardData = updatedDashboardData
            }

            print("✅ Captain set to: \(playerName)")
        } catch {
            throw AFLFantasyError.networkError(error)
        }
    }

    /// Refresh dashboard data
    func refreshDashboardData() async -> Result<DashboardData, AFLFantasyError> {
        guard authenticated else {
            let error = AFLFantasyError.notAuthenticated
            lastError = error
            return .failure(error)
        }

        loading = true
        lastError = nil

        defer { loading = false }

        do {
            let teamData = try await scraper.fetchTeamData()
            let dashboardData = DashboardData(
                teamValue: .init(teamValue: Double(teamData.teamValue)),
                teamScore: .init(totalScore: teamData.teamScore),
                rank: .init(rank: teamData.overallRank),
                captain: .init(captain: CaptainData.Captain(
                    name: teamData.captainName,
                    team: nil,
                    position: nil
                ))
            )

            currentDashboardData = dashboardData
            lastUpdateTime = teamData.lastUpdated
            lastError = nil
            return .success(dashboardData)
        } catch let error as ScraperError {
            lastError = .networkError(error)

            if error == .missingCredentials || error == .authenticationFailed {
                logout()
            }

            return .failure(.networkError(error))
        } catch {
            lastError = .networkError(error)
            return .failure(.networkError(error))
        }
    }

    // MARK: - Periodic Refresh

    /// Start periodic data refresh
    private func startPeriodicRefresh() {
        refreshTimer?.invalidate()

        refreshTimer = Timer.scheduledTimer(withTimeInterval: cacheExpiryInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshDataIfNeeded()
            }
        }
    }

    /// Refresh data if cache has expired
    private func refreshDataIfNeeded() async {
        guard authenticated,
              let lastUpdate = lastUpdateTime,
              Date().timeIntervalSince(lastUpdate) > cacheExpiryInterval
        else {
            return
        }

        _ = await refreshDashboardData()
    }

    // MARK: - Cache Status

    /// Check if cached data is still fresh
    var isCacheFresh: Bool {
        guard let lastUpdate = lastUpdateTime else { return false }
        return Date().timeIntervalSince(lastUpdate) < cacheExpiryInterval
    }

    /// Time remaining until cache expires
    var cacheExpiresIn: TimeInterval {
        guard let lastUpdate = lastUpdateTime else { return 0 }
        let elapsed = Date().timeIntervalSince(lastUpdate)
        return max(0, cacheExpiryInterval - elapsed)
    }
}

// MARK: - Convenience Methods

extension AFLFantasyDataService {
    /// Get formatted string for last update time
    var lastUpdateDisplayString: String {
        guard let lastUpdate = lastUpdateTime else { return "Never" }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastUpdate, relativeTo: Date())
    }

    /// Get current team value if available
    var currentTeamValue: Double? {
        currentDashboardData?.teamValue.teamValue
    }

    /// Get current team score if available
    var currentTeamScore: Int? {
        currentDashboardData?.teamScore.totalScore
    }

    /// Get current rank if available
    var currentRank: Int? {
        currentDashboardData?.rank.rank
    }

    /// Get current captain if available
    var currentCaptain: DashboardData.Captain? {
        currentDashboardData?.captain
    }
}

// MARK: - Error State Management

extension AFLFantasyDataService {
    /// Clear the last error
    func clearError() {
        lastError = nil
    }

    /// Check if there's a current error
    var hasError: Bool {
        lastError != nil
    }

    /// Get user-friendly error message
    var errorMessage: String? {
        lastError?.localizedDescription
    }
}
