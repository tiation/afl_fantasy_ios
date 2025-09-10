//
//  MasterDataService.swift
//  AFL Fantasy Intelligence Platform
//
//  🎯 Master Data Service - Single Source of Truth
//  Consolidates AFLFantasyDataService, FantasyAPIService, and DashboardService
//  with unified async/await API, intelligent caching, and performance optimization
//  Created by AI Assistant on 8/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Combine
import Foundation
import Network
import os.log

// MARK: - MasterDataServiceProtocol

/// Unified protocol consolidating all data operations
@MainActor
protocol MasterDataServiceProtocol: ObservableObject {
    // MARK: - Authentication
    var isAuthenticated: Bool { get }
    var currentTeamId: String? { get }
    func authenticate(teamId: String, sessionCookie: String, apiToken: String?) async throws
    func logout() async
    
    // MARK: - Dashboard
    func getDashboardData(forceRefresh: Bool) async throws -> DashboardResponse
    var cachedDashboard: DashboardResponse? { get }
    
    // MARK: - Players
    func getPlayers(position: PlayerPosition?) async throws -> [Player]
    func getPlayerDetails(playerId: Int) async throws -> PlayerDetails
    func searchPlayers(query: String) async throws -> [Player]
    
    // MARK: - Trading
    func getTradeRecommendations() async throws -> [TradeRecommendation]
    func analyzeTradeScenario(playersOut: [Int], playersIn: [Int]) async throws -> TradeAnalysisResult
    
    // MARK: - Captain Analysis
    func getCaptainRecommendations(round: Int?) async throws -> [CaptainSuggestion]
    func analyzeCaptainChoice(playerId: Int, round: Int?) async throws -> CaptainSuggestionAnalysis
    
    // MARK: - Cash Cow Analysis
    func analyzeCashCows() async throws -> [CashCowAnalysis]
    func getPriceProjections(playerIds: [Int]) async throws -> [PriceProjection]
    
    // MARK: - Live Data Streams
    var playerUpdates: AnyPublisher<[Player], Never> { get }
    var priceChanges: AnyPublisher<[PriceChange], Never> { get }
    var liveScores: AnyPublisher<[LiveScore], Never> { get }
    
    // MARK: - Cache Management
    func clearCache() async
    func refreshAllData() async throws
}

// MARK: - MasterDataService

/// Consolidated data service providing single source of truth for all AFL Fantasy data
@MainActor
final class MasterDataService: ObservableObject, MasterDataServiceProtocol {
    
    // MARK: - Published Properties
    
    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var currentTeamId: String?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var lastError: AFLFantasyError?
    @Published private(set) var lastUpdateTime: Date?
    
    // MARK: - Private Properties
    
    private let networkMonitor = NWPathMonitor()
    private let networkQueue = DispatchQueue(label: "network.monitor")
    private let logger = Logger(subsystem: "com.aflfantasy.app", category: "MasterDataService")
    
    // MARK: - Dependencies
    
    private let networkService: NetworkServiceProtocol
    private let keychain: KeychainService
    private let cacheManager: CacheManager
    private let performanceMonitor: PerformanceMonitor
    
    // MARK: - Live Data Subjects
    
    private let playerUpdatesSubject = PassthroughSubject<[Player], Never>()
    private let priceChangesSubject = PassthroughSubject<[PriceChange], Never>()
    private let liveScoresSubject = PassthroughSubject<[LiveScore], Never>()
    
    // MARK: - Background Refresh
    
    private var backgroundRefreshTimer: Timer?
    private let backgroundRefreshInterval: TimeInterval = 300 // 5 minutes
    
    // MARK: - Network State
    
    @Published private(set) var isNetworkAvailable: Bool = true
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        networkService: NetworkServiceProtocol = NetworkService.shared,
        keychain: KeychainService = .shared,
        cacheManager: CacheManager = .shared,
        performanceMonitor: PerformanceMonitor = .shared
    ) {
        self.networkService = networkService
        self.keychain = keychain
        self.cacheManager = cacheManager
        self.performanceMonitor = performanceMonitor
        
        setupNetworkMonitoring()
        setupBackgroundRefresh()
        
        // Check for stored authentication
        Task {
            await checkStoredAuthentication()
        }
        
        logger.info("🚀 MasterDataService initialized")
    }
    
    deinit {
        backgroundRefreshTimer?.invalidate()
        networkMonitor.cancel()
    }
    
    // MARK: - Authentication
    
    func authenticate(teamId: String, sessionCookie: String, apiToken: String? = nil) async throws {
        logger.info("🔐 Authenticating with team ID: \(teamId.prefix(6))...")
        
        isLoading = true
        lastError = nil
        
        defer { isLoading = false }
        
        do {
            // Store credentials securely
            try await keychain.storeTeamId(teamId)
            try await keychain.storeSessionCookie(sessionCookie)
            if let apiToken = apiToken {
                try await keychain.storeAPIToken(apiToken)
            }
            
            // Test authentication by fetching dashboard
            let dashboardResponse = try await getDashboardData(forceRefresh: true)
            
            // Update authentication state
            isAuthenticated = true
            currentTeamId = teamId
            lastUpdateTime = Date()
            
            logger.info("✅ Authentication successful")
            
            // Start background refresh
            startBackgroundRefresh()
            
        } catch {
            // Clear credentials on failure
            try? await keychain.clearAllCredentials()
            isAuthenticated = false
            currentTeamId = nil
            lastError = error as? AFLFantasyError ?? .authenticationFailed(error.localizedDescription)
            
            logger.error("❌ Authentication failed: \(error)")
            throw lastError!
        }
    }
    
    func logout() async {
        logger.info("🔓 Logging out...")
        
        stopBackgroundRefresh()
        
        try? await keychain.clearAllCredentials()
        await cacheManager.clearAll()
        
        isAuthenticated = false
        currentTeamId = nil
        lastError = nil
        lastUpdateTime = nil
        
        logger.info("✅ Logout complete")
    }
    
    // MARK: - Dashboard
    
    func getDashboardData(forceRefresh: Bool = false) async throws -> DashboardResponse {
        logger.debug("📊 Fetching dashboard data (forceRefresh: \(forceRefresh))")
        
        // Check cache first unless forcing refresh
        if !forceRefresh, let cached = await cacheManager.getDashboard() {
            logger.debug("💾 Returning cached dashboard data")
            return cached
        }
        
        guard isAuthenticated, let teamId = currentTeamId else {
            throw AFLFantasyError.notAuthenticated
        }
        
        do {
            let endpoint = FantasyEndpoints.dashboard(teamId: teamId)
            let response: DashboardResponse = try await networkService.request(endpoint)
            
            // Cache the response
            await cacheManager.storeDashboard(response)
            lastUpdateTime = Date()
            
            logger.info("✅ Dashboard data fetched successfully")
            return response
            
        } catch {
            logger.error("❌ Dashboard fetch failed: \(error)")
            
            // Return cached data if available, otherwise throw error
            if let cached = await cacheManager.getDashboard() {
                logger.info("💾 Returning cached dashboard due to network error")
                return cached
            }
            
            throw error
        }
    }
    
    var cachedDashboard: DashboardResponse? {
        get async {
            await cacheManager.getDashboard()
        }
    }
    
    // MARK: - Players
    
    func getPlayers(position: PlayerPosition? = nil) async throws -> [Player] {
        logger.debug("👥 Fetching players (position: \(position?.rawValue ?? "all"))")
        
        // Check cache first
        if let cached = await cacheManager.getPlayers(position: position) {
            logger.debug("💾 Returning cached players")
            return cached
        }
        
        let endpoint = FantasyEndpoints.players(position: position)
        let players: [Player] = try await networkService.request(endpoint)
        
        // Cache players
        await cacheManager.storePlayers(players, position: position)
        
        logger.info("✅ Players fetched successfully (\(players.count) players)")
        return players
    }
    
    func getPlayerDetails(playerId: Int) async throws -> PlayerDetails {
        logger.debug("👤 Fetching player details for ID: \(playerId)")
        
        if let cached = await cacheManager.getPlayerDetails(playerId: playerId) {
            return cached
        }
        
        let endpoint = FantasyEndpoints.playerDetails(id: playerId)
        let details: PlayerDetails = try await networkService.request(endpoint)
        
        await cacheManager.storePlayerDetails(details, playerId: playerId)
        
        logger.info("✅ Player details fetched for ID: \(playerId)")
        return details
    }
    
    func searchPlayers(query: String) async throws -> [Player] {
        guard query.count >= 2 else { return [] }
        
        logger.debug("🔍 Searching players: '\(query)'")
        
        let endpoint = FantasyEndpoints.searchPlayers(query: query)
        let players: [Player] = try await networkService.request(endpoint)
        
        logger.info("✅ Player search completed (\(players.count) results)")
        return players
    }
    
    // MARK: - Trading
    
    func getTradeRecommendations() async throws -> [TradeRecommendation] {
        guard let teamId = currentTeamId else {
            throw AFLFantasyError.notAuthenticated
        }
        
        logger.debug("💱 Fetching trade recommendations")
        
        let endpoint = FantasyEndpoints.tradeRecommendations(teamId: teamId)
        let recommendations: [TradeRecommendation] = try await networkService.request(endpoint)
        
        logger.info("✅ Trade recommendations fetched (\(recommendations.count) recommendations)")
        return recommendations
    }
    
    func analyzeTradeScenario(playersOut: [Int], playersIn: [Int]) async throws -> TradeAnalysisResult {
        guard let teamId = currentTeamId else {
            throw AFLFantasyError.notAuthenticated
        }
        
        logger.debug("🔬 Analyzing trade scenario")
        
        let endpoint = FantasyEndpoints.tradeAnalysis(
            teamId: teamId,
            playersOut: playersOut,
            playersIn: playersIn
        )
        let analysis: TradeAnalysisResult = try await networkService.request(endpoint)
        
        logger.info("✅ Trade scenario analyzed")
        return analysis
    }
    
    // MARK: - Captain Analysis
    
    func getCaptainRecommendations(round: Int? = nil) async throws -> [CaptainSuggestion] {
        guard let teamId = currentTeamId else {
            throw AFLFantasyError.notAuthenticated
        }
        
        logger.debug("👑 Fetching captain recommendations")
        
        let currentRound = round ?? await getCurrentRound()
        let endpoint = FantasyEndpoints.captainRecommendations(teamId: teamId, round: currentRound)
        let suggestions: [CaptainSuggestion] = try await networkService.request(endpoint)
        
        logger.info("✅ Captain recommendations fetched (\(suggestions.count) suggestions)")
        return suggestions
    }
    
    func analyzeCaptainChoice(playerId: Int, round: Int? = nil) async throws -> CaptainSuggestionAnalysis {
        guard let teamId = currentTeamId else {
            throw AFLFantasyError.notAuthenticated
        }
        
        logger.debug("🔬 Analyzing captain choice: \(playerId)")
        
        let currentRound = round ?? await getCurrentRound()
        let endpoint = FantasyEndpoints.captainAnalysis(
            teamId: teamId,
            playerId: playerId,
            round: currentRound
        )
        let analysis: CaptainSuggestionAnalysis = try await networkService.request(endpoint)
        
        logger.info("✅ Captain choice analyzed")
        return analysis
    }
    
    // MARK: - Cash Cow Analysis
    
    func analyzeCashCows() async throws -> [CashCowAnalysis] {
        guard let teamId = currentTeamId else {
            throw AFLFantasyError.notAuthenticated
        }
        
        logger.debug("🐄 Analyzing cash cows")
        
        let endpoint = FantasyEndpoints.cashCowAnalysis(teamId: teamId)
        let analysis: [CashCowAnalysis] = try await networkService.request(endpoint)
        
        logger.info("✅ Cash cow analysis completed (\(analysis.count) cash cows)")
        return analysis
    }
    
    func getPriceProjections(playerIds: [Int]) async throws -> [PriceProjection] {
        logger.debug("💰 Fetching price projections for \(playerIds.count) players")
        
        let endpoint = FantasyEndpoints.priceProjections(playerIds: playerIds)
        let projections: [PriceProjection] = try await networkService.request(endpoint)
        
        logger.info("✅ Price projections fetched")
        return projections
    }
    
    // MARK: - Live Data Streams
    
    var playerUpdates: AnyPublisher<[Player], Never> {
        playerUpdatesSubject.eraseToAnyPublisher()
    }
    
    var priceChanges: AnyPublisher<[PriceChange], Never> {
        priceChangesSubject.eraseToAnyPublisher()
    }
    
    var liveScores: AnyPublisher<[LiveScore], Never> {
        liveScoresSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Cache Management
    
    func clearCache() async {
        logger.info("🧹 Clearing all cached data")
        await cacheManager.clearAll()
    }
    
    func refreshAllData() async throws {
        logger.info("🔄 Refreshing all data")
        
        guard isAuthenticated else {
            throw AFLFantasyError.notAuthenticated
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Refresh core data in parallel
            async let dashboardTask = getDashboardData(forceRefresh: true)
            async let playersTask = getPlayers()
            
            _ = try await [dashboardTask, playersTask]
            
            lastUpdateTime = Date()
            logger.info("✅ All data refreshed successfully")
            
        } catch {
            logger.error("❌ Data refresh failed: \(error)")
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    private func checkStoredAuthentication() async {
        do {
            let hasCredentials = await keychain.hasValidCredentials()
            if hasCredentials {
                if let teamId = try await keychain.getTeamId() {
                    isAuthenticated = true
                    currentTeamId = teamId
                    startBackgroundRefresh()
                    logger.info("🔐 Restored authentication from keychain")
                }
            }
        } catch {
            logger.error("❌ Failed to check stored authentication: \(error)")
        }
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = path.status == .satisfied
                if path.status == .satisfied {
                    self?.logger.info("📶 Network connection restored")
                } else {
                    self?.logger.warning("📵 Network connection lost")
                }
            }
        }
        networkMonitor.start(queue: networkQueue)
    }
    
    private func setupBackgroundRefresh() {
        // Background refresh will be started after authentication
    }
    
    private func startBackgroundRefresh() {
        stopBackgroundRefresh()
        
        backgroundRefreshTimer = Timer.scheduledTimer(withTimeInterval: backgroundRefreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.performBackgroundRefresh()
            }
        }
        
        logger.info("⏰ Background refresh started")
    }
    
    private func stopBackgroundRefresh() {
        backgroundRefreshTimer?.invalidate()
        backgroundRefreshTimer = nil
        logger.info("⏰ Background refresh stopped")
    }
    
    private func performBackgroundRefresh() async {
        guard isAuthenticated, isNetworkAvailable else { return }
        
        logger.debug("🔄 Performing background refresh")
        
        do {
            // Refresh dashboard data in background
            _ = try await getDashboardData(forceRefresh: true)
            
            // Emit live updates if available
            await emitLiveUpdates()
            
        } catch {
            logger.warning("⚠️ Background refresh failed: \(error)")
        }
    }
    
    private func emitLiveUpdates() async {
        // Simulate live updates - in production this would connect to WebSocket or SSE
        do {
            let players = try await getPlayers()
            playerUpdatesSubject.send(players)
            
            // Simulate price changes
            let priceChanges = generateMockPriceChanges(from: players)
            priceChangesSubject.send(priceChanges)
            
        } catch {
            logger.debug("Live updates failed: \(error)")
        }
    }
    
    private func generateMockPriceChanges(from players: [Player]) -> [PriceChange] {
        // Mock implementation - replace with real data
        return players.prefix(5).compactMap { player in
            PriceChange(
                playerId: player.id,
                oldPrice: player.price,
                newPrice: player.price + Int.random(in: -10000...10000),
                changeAmount: Int.random(in: -10000...10000),
                timestamp: Date()
            )
        }
    }
    
    private func getCurrentRound() async -> Int {
        // Implement current round logic
        return 1 // Placeholder
    }
}

// MARK: - Supporting Models

struct PriceChange: Codable, Identifiable {
    let id = UUID()
    let playerId: Int
    let oldPrice: Int
    let newPrice: Int
    let changeAmount: Int
    let timestamp: Date
}

struct LiveScore: Codable, Identifiable {
    let id = UUID()
    let matchId: String
    let homeTeam: String
    let awayTeam: String
    let homeScore: Int
    let awayScore: Int
    let quarter: String
    let timeRemaining: String?
    let isLive: Bool
}

// MARK: - Cache Manager

/// Intelligent caching system for AFL Fantasy data
actor CacheManager {
    static let shared = CacheManager()
    
    private var dashboardCache: (data: DashboardResponse, timestamp: Date)?
    private var playersCache: [String: (data: [Player], timestamp: Date)] = [:]
    private var playerDetailsCache: [Int: (data: PlayerDetails, timestamp: Date)] = [:]
    
    private let cacheExpiryInterval: TimeInterval = 300 // 5 minutes
    
    private init() {}
    
    func getDashboard() -> DashboardResponse? {
        guard let cache = dashboardCache,
              Date().timeIntervalSince(cache.timestamp) < cacheExpiryInterval else {
            return nil
        }
        return cache.data
    }
    
    func storeDashboard(_ dashboard: DashboardResponse) {
        dashboardCache = (dashboard, Date())
    }
    
    func getPlayers(position: PlayerPosition?) -> [Player]? {
        let key = position?.rawValue ?? "all"
        guard let cache = playersCache[key],
              Date().timeIntervalSince(cache.timestamp) < cacheExpiryInterval else {
            return nil
        }
        return cache.data
    }
    
    func storePlayers(_ players: [Player], position: PlayerPosition?) {
        let key = position?.rawValue ?? "all"
        playersCache[key] = (players, Date())
    }
    
    func getPlayerDetails(playerId: Int) -> PlayerDetails? {
        guard let cache = playerDetailsCache[playerId],
              Date().timeIntervalSince(cache.timestamp) < cacheExpiryInterval else {
            return nil
        }
        return cache.data
    }
    
    func storePlayerDetails(_ details: PlayerDetails, playerId: Int) {
        playerDetailsCache[playerId] = (details, Date())
    }
    
    func clearAll() {
        dashboardCache = nil
        playersCache.removeAll()
        playerDetailsCache.removeAll()
    }
}
