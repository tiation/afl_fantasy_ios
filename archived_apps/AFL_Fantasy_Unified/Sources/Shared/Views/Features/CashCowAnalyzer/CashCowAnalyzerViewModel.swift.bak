import SwiftUI

@MainActor
final class CashCowAnalyzerViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var cashStats = CashGenStats(
        totalGenerated: 0,
        activeCashCows: 0,
        sellRecommendations: 0,
        holdCount: 0,
        recentHistory: []
    )
    @Published private(set) var breakEvenTargets: [BreakEvenTarget] = []
    @Published private(set) var sellRecommendations: [SellRecommendation] = []
    @Published private(set) var holdRecommendations: [HoldRecommendation] = []
    @Published private(set) var watchlistPlayers: [WatchlistPlayer] = []
    @Published var selectedTarget: BreakEvenTarget.TimeFrame?
    @Published var showError = false
    @Published var errorMessage = ""
    
    // MARK: - Dependencies
    
    private let cashCowService: CashCowServiceProtocol
    private let priceService: PriceServiceProtocol
    
    // MARK: - Init
    
    init(
        cashCowService: CashCowServiceProtocol = CashCowService(),
        priceService: PriceServiceProtocol = PriceService()
    ) {
        self.cashCowService = cashCowService
        self.priceService = priceService
    }
    
    // MARK: - Public Methods
    
    func loadData() {
        Task {
            do {
                // Load base stats
                async let cashStatsTask = cashCowService.getCashStats()
                async let targetsTask = priceService.getBreakEvenTargets()
                
                (cashStats, breakEvenTargets) = try await (cashStatsTask, targetsTask)
                
                selectedTarget = .twoWeeks
                
                // Load player recommendations
                async let sellTask = cashCowService.getSellRecommendations()
                async let holdTask = cashCowService.getHoldRecommendations()
                async let watchlistTask = cashCowService.getWatchlistPlayers()
                
                let (sell, hold, watchlist) = try await (sellTask, holdTask, watchlistTask)
                
                // Update UI with valid recommendations only
                sellRecommendations = sell.filter { $0.confidence >= 0.7 }
                holdRecommendations = hold.filter { $0.weeksToHold <= 4 }
                watchlistPlayers = watchlist.filter { $0.breakEven < 0 }
                
            } catch {
                handleError(error)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

// MARK: - Note
// Service protocols are defined in Services/ServiceProtocols.swift
