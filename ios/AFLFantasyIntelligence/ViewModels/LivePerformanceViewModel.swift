//
//  LivePerformanceViewModel.swift
//  AFL Fantasy Intelligence Platform
//
//  🏆 Live Performance State Management
//  Handles real-time match data, player deltas, and performance analytics
//  Created on 10/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

// MARK: - LivePerformanceViewModel

@MainActor
final class LivePerformanceViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var hasError = false
    @Published var errorMessage: String?
    
    // Live performance data
    @Published var liveMatches: [LiveMatch] = []
    @Published var performanceSummary: LivePerformanceSummary?
    @Published var alerts: [LivePerformanceAlert] = []
    @Published var playerDeltas: [String: PlayerStatDelta] = [:]
    @Published var teamPerformances: [String: TeamPerformance] = [:]
    
    // Derived properties
    @Published var totalLiveScore = 0
    @Published var playersRemaining = 0
    @Published var playersPlaying = 0
    @Published var projectedScore = 0.0
    @Published var riskFactors: [RiskFactor] = []
    @Published var opportunities: [Opportunity] = []
    
    // UI state
    @Published var selectedMatch: LiveMatch?
    @Published var showingDetailView = false
    @Published var autoRefreshEnabled = true
    @Published var refreshInterval: TimeInterval = 30.0
    
    // Performance metrics
    @Published var scoreVelocity: Double = 0 // Points per minute
    @Published var momentum: LiveMomentum = .neutral
    @Published var captainPerformanceRating: Double = 0
    @Published var benchUtilization: Double = 0
    
    // MARK: - Private Properties
    
    private let livePerformanceService: LivePerformanceServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: Timer?
    private var lastUpdateTime = Date()
    
    // MARK: - Initialization
    
    init(livePerformanceService: LivePerformanceServiceProtocol = LivePerformanceService()) {
        self.livePerformanceService = livePerformanceService
        setupBindings()
        setupAutoRefresh()
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    /// Load initial live performance data
    func loadData() {
        guard !isLoading else { return }
        
        Task {
            await performDataLoad()
        }
    }
    
    /// Refresh all live performance data
    func refresh() async {
        isRefreshing = true
        await performDataLoad()
        isRefreshing = false
    }
    
    /// Toggle auto-refresh functionality
    func toggleAutoRefresh() {
        autoRefreshEnabled.toggle()
        if autoRefreshEnabled {
            setupAutoRefresh()
        } else {
            refreshTimer?.invalidate()
            refreshTimer = nil
        }
    }
    
    /// Update refresh interval
    func updateRefreshInterval(_ interval: TimeInterval) {
        refreshInterval = interval
        if autoRefreshEnabled {
            setupAutoRefresh()
        }
    }
    
    /// Select a specific match for detailed viewing
    func selectMatch(_ match: LiveMatch) {
        selectedMatch = match
        showingDetailView = true
        
        // Load detailed data for the selected match
        Task {
            await loadMatchDetails(match.matchId)
        }
    }
    
    /// Get captain candidates based on current performance
    func getCaptainCandidates() -> [CaptainCandidate] {
        guard let summary = performanceSummary else { return [] }
        return summary.captainCandidates.sorted { $0.projectedScore > $1.projectedScore }
    }
    
    /// Get trade targets based on current performance
    func getTradeTargets() -> [TradeTarget] {
        guard let summary = performanceSummary else { return [] }
        return summary.tradeTargets.sorted { $0.urgency.rawValue > $1.urgency.rawValue }
    }
    
    /// Calculate team efficiency score
    func calculateTeamEfficiency() -> Double {
        guard !liveMatches.isEmpty else { return 0 }
        
        let totalPossibleScore = Double(playersPlaying * 120) // Assuming 120 is excellent score
        let actualScore = Double(totalLiveScore)
        
        return totalPossibleScore > 0 ? (actualScore / totalPossibleScore) * 100 : 0
    }
    
    /// Get performance trend over time
    func getPerformanceTrend() -> PerformanceTrend {
        guard let summary = performanceSummary else { return .stable }
        
        let recentVelocity = scoreVelocity
        
        if recentVelocity > 2.0 {
            return .improving
        } else if recentVelocity < -1.0 {
            return .declining
        } else {
            return .stable
        }
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Subscribe to live matches stream
        livePerformanceService.liveMatchesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matches in
                self?.liveMatches = matches
                self?.updateDerivedProperties()
            }
            .store(in: &cancellables)
        
        // Subscribe to performance summary stream
        livePerformanceService.performanceSummaryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] summary in
                self?.performanceSummary = summary
                self?.updatePerformanceMetrics(from: summary)
            }
            .store(in: &cancellables)
        
        // Subscribe to alerts stream
        livePerformanceService.alertsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alerts in
                self?.alerts = alerts
            }
            .store(in: &cancellables)
    }
    
    private func setupAutoRefresh() {
        refreshTimer?.invalidate()
        
        guard autoRefreshEnabled else { return }
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            guard let self = self, !self.isLoading else { return }
            
            Task { @MainActor in
                await self.performQuickRefresh()
            }
        }
    }
    
    private func performDataLoad() async {
        isLoading = true
        hasError = false
        errorMessage = nil
        
        do {
            // Load all live performance data concurrently
            async let matchesTask = livePerformanceService.fetchLiveMatches()
            async let summaryTask = livePerformanceService.fetchPerformanceSummary()
            async let alertsTask = livePerformanceService.fetchLiveAlerts()
            async let deltasTask = livePerformanceService.fetchPlayerDeltas()
            async let teamPerfTask = livePerformanceService.fetchTeamPerformances()
            
            let matches = try await matchesTask
            let summary = try await summaryTask
            let alerts = try await alertsTask
            let deltas = try await deltasTask
            let teamPerf = try await teamPerfTask
            
            // Update properties
            self.liveMatches = matches
            self.performanceSummary = summary
            self.alerts = alerts
            self.playerDeltas = deltas
            self.teamPerformances = teamPerf
            
            updateDerivedProperties()
            updatePerformanceMetrics(from: summary)
            
            lastUpdateTime = Date()
            
        } catch {
            await MainActor.run {
                hasError = true
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    private func performQuickRefresh() async {
        // Quick refresh without loading states for auto-refresh
        do {
            let summary = try await livePerformanceService.fetchPerformanceSummary()
            let deltas = try await livePerformanceService.fetchPlayerDeltas()
            
            self.performanceSummary = summary
            self.playerDeltas = deltas
            
            updateDerivedProperties()
            updatePerformanceMetrics(from: summary)
            
            lastUpdateTime = Date()
            
        } catch {
            // Silent fail for auto-refresh to avoid interrupting user experience
            print("Auto-refresh failed: \(error.localizedDescription)")
        }
    }
    
    private func loadMatchDetails(_ matchId: String) async {
        // Load detailed match data when user selects a specific match
        do {
            let matchDetails = try await livePerformanceService.fetchMatchDetails(matchId)
            // Update selected match with detailed information
            if let index = liveMatches.firstIndex(where: { $0.matchId == matchId }) {
                liveMatches[index] = matchDetails
            }
        } catch {
            print("Failed to load match details: \(error.localizedDescription)")
        }
    }
    
    private func updateDerivedProperties() {
        // Calculate total live score
        totalLiveScore = liveMatches.reduce(0) { sum, match in
            sum + match.playerStats.values.reduce(0) { $0 + $1.currentScore }
        }
        
        // Calculate players remaining and playing
        let allPlayerStats = liveMatches.flatMap { $0.playerStats.values }
        playersPlaying = allPlayerStats.filter { $0.isPlaying }.count
        playersRemaining = allPlayerStats.filter { !$0.hasPlayed && !$0.isPlaying }.count
        
        // Calculate projected score based on current performance
        if playersRemaining > 0 {
            let averageScorePerPlayer = playersPlaying > 0 ? Double(totalLiveScore) / Double(playersPlaying) : 70.0
            projectedScore = Double(totalLiveScore) + (averageScorePerPlayer * Double(playersRemaining))
        } else {
            projectedScore = Double(totalLiveScore)
        }
    }
    
    private func updatePerformanceMetrics(from summary: LivePerformanceSummary?) {
        guard let summary = summary else { return }
        
        // Update momentum
        self.momentum = summary.momentum
        
        // Calculate score velocity (points per minute since last update)
        let timeSinceLastUpdate = Date().timeIntervalSince(lastUpdateTime) / 60.0 // Convert to minutes
        if timeSinceLastUpdate > 0 {
            scoreVelocity = Double(summary.scoreIncrease) / timeSinceLastUpdate
        }
        
        // Update captain performance rating
        if let captain = summary.captainCandidates.first {
            captainPerformanceRating = captain.currentPerformance
        }
        
        // Calculate bench utilization
        let totalBenchScore = summary.benchContribution
        let totalTeamScore = Double(totalLiveScore)
        benchUtilization = totalTeamScore > 0 ? (totalBenchScore / totalTeamScore) * 100 : 0
        
        // Extract risk factors and opportunities
        self.riskFactors = summary.riskFactors
        self.opportunities = summary.opportunities
    }
}

// MARK: - Supporting Types

enum PerformanceTrend {
    case improving
    case stable
    case declining
    
    var color: Color {
        switch self {
        case .improving: return .green
        case .stable: return .blue
        case .declining: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .improving: return "arrow.up.right"
        case .stable: return "arrow.right"
        case .declining: return "arrow.down.right"
        }
    }
}

// MARK: - Extensions

extension LivePerformanceViewModel {
    
    /// Get formatted time since last update
    var timeSinceLastUpdate: String {
        let interval = Date().timeIntervalSince(lastUpdateTime)
        
        if interval < 60 {
            return "\(Int(interval))s ago"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else {
            return "\(Int(interval / 3600))h ago"
        }
    }
    
    /// Check if any matches are currently live
    var hasLiveMatches: Bool {
        liveMatches.contains { $0.state.isLive }
    }
    
    /// Get the most critical alert
    var mostCriticalAlert: LivePerformanceAlert? {
        alerts.max { $0.severity.rawValue < $1.severity.rawValue }
    }
    
    /// Calculate overall performance grade
    var performanceGrade: String {
        let efficiency = calculateTeamEfficiency()
        
        switch efficiency {
        case 90...:
            return "A+"
        case 80..<90:
            return "A"
        case 70..<80:
            return "B+"
        case 60..<70:
            return "B"
        case 50..<60:
            return "C+"
        case 40..<50:
            return "C"
        default:
            return "D"
        }
    }
}
