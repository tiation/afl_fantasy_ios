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

    private let apiClient: AFLFantasyAPIClient
    private let keychainManager: KeychainManager

    // MARK: - Cache Management

    private let cacheExpiryInterval: TimeInterval = 300 // 5 minutes
    private var refreshTimer: Timer?

    // MARK: - Initialization

    init(
        apiClient: AFLFantasyAPIClient = AFLFantasyAPIClient(),
        keychainManager: KeychainManager = KeychainManager()
    ) {
        self.apiClient = apiClient
        self.keychainManager = keychainManager

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
        guard keychainManager.hasAFLCredentials(),
              let teamId = keychainManager.getAFLTeamId(),
              let sessionCookie = keychainManager.getAFLSessionCookie()
        else {
            authenticated = false
            return
        }

        let apiToken = keychainManager.getAFLAPIToken()
        let result = await authenticate(teamId: teamId, sessionCookie: sessionCookie, apiToken: apiToken)

        switch result {
        case .success:
            print("✅ Auto-authenticated with stored credentials")
        case let .failure(error):
            print("⚠️ Auto-authentication failed: \(error.localizedDescription)")
            // Clear invalid credentials
            keychainManager.clearAFLCredentials()
            authenticated = false
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

        // Update API client credentials
        apiClient.storeCredentials(teamId: teamId, sessionCookie: sessionCookie, apiToken: apiToken)

        // Test credentials by fetching dashboard data
        let result: Result<DashboardData, AFLFantasyError>
        do {
            let dashboardData = try await apiClient.getDashboardData()
            result = .success(dashboardData)
        } catch let error as AFLFantasyAPIClient.AFLAPIError {
            let aflError = AFLFantasyError.from(aflAPIError: error)
            result = .failure(aflError)
        } catch {
            result = .failure(.networkError(error))
        }

        switch result {
        case let .success(dashboardData):
            // Store credentials securely
            keychainManager.storeAFLCredentials(
                teamId: teamId,
                sessionCookie: sessionCookie,
                apiToken: apiToken
            )

            // Update state
            authenticated = true
            currentDashboardData = dashboardData
            lastUpdateTime = Date()

            // Start periodic refresh
            startPeriodicRefresh()

            return .success(())

        case let .failure(error):
            authenticated = false
            currentDashboardData = nil
            lastError = error
            return .failure(error)
        }
    }

    /// Log out and clear stored credentials
    func logout() {
        refreshTimer?.invalidate()
        refreshTimer = nil

        keychainManager.clearAFLCredentials()

        authenticated = false
        currentDashboardData = nil
        lastError = nil
        lastUpdateTime = nil

        print("✅ Logged out successfully")
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
                var captainData = CaptainData()
                captainData.playerName = playerName
                captainData.score = 0 // Will be updated with actual score
                captainData.ownershipPercentage = 0.0 // Will be updated with actual data
                dashboardData.captain = captainData
                currentDashboardData = dashboardData
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

        let result: Result<DashboardData, AFLFantasyError>
        do {
            let dashboardData = try await apiClient.getDashboardData()
            result = .success(dashboardData)
        } catch let error as AFLFantasyAPIClient.AFLAPIError {
            let aflError = AFLFantasyError.from(aflAPIError: error)
            result = .failure(aflError)
        } catch {
            result = .failure(.networkError(error))
        }

        switch result {
        case let .success(dashboardData):
            currentDashboardData = dashboardData
            lastUpdateTime = Date()
            lastError = nil
            return .success(dashboardData)

        case let .failure(error):
            lastError = error

            // Handle authentication errors by logging out
            if case .authenticationRequired = error {
                logout()
            }

            return .failure(error)
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
        guard let totalValue = currentDashboardData?.teamValue.totalValue else { return nil }
        return Double(totalValue)
    }

    /// Get current team score if available
    var currentTeamScore: Int? {
        currentDashboardData?.teamScore.totalScore
    }

    /// Get current rank if available
    var currentRank: Int? {
        currentDashboardData?.overallRank.currentRank
    }

    /// Get current captain if available
    var currentCaptain: CaptainData? {
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
