import Foundation
import Combine

@MainActor
final class CashCowAnalyzerViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var currentCows: [CashCowData] = []
    @Published var potentialPicks: [CashCowData] = []
    @Published var selectedSection: CashCowSection = .current
    
    private let apiClient: APIClient
    private let analyticsService: AnalyticsService
    private var cancellables = Set<AnyCancellable>()
    
    init(apiClient: APIClient = .shared, analyticsService: AnalyticsService = .shared) {
        self.apiClient = apiClient
        self.analyticsService = analyticsService
        
        // Load initial data
        Task {
            await loadData()
        }
    }
    
    enum CashCowSection: CaseIterable {
        case current
        case potential
        
        var title: String {
            switch self {
            case .current:
                return "Current Cows"
            case .potential:
                return "Potential Picks"
            }
        }
    }
    
    func loadData() async {
        isLoading = true
        showError = false
        errorMessage = ""
        
        analyticsService.trackEvent("cash_cow_analyzer_loaded")
        
        do {
            // Simulate API delay for better UX
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // Try to fetch cash cow data from APIClient
            let cashCowResponse = try await withCheckedThrowingContinuation { continuation in
                apiClient.getCashCows()
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                continuation.resume(throwing: error)
                            }
                        },
                        receiveValue: { cashCows in
                            continuation.resume(returning: cashCows)
                        }
                    )
                    .store(in: &self.cancellables)
            }
            
            // Filter into current and potential categories
            self.currentCows = cashCowResponse.filter { cow in
                cow.cashGenerated > 0 && cow.gamesPlayed >= 3
            }.sorted { $0.cashGenerated > $1.cashGenerated }
            
            self.potentialPicks = cashCowResponse.filter { cow in
                cow.projectedPrice > cow.currentPrice &&
                cow.confidence > 0.7 &&
                cow.gamesPlayed <= 5
            }.sorted { ($0.projectedPrice - $0.currentPrice) > ($1.projectedPrice - $1.currentPrice) }
            
            isLoading = false
            
        } catch {
            // Fall back to mock data if APIClient fails
            await loadMockData()
            
            isLoading = false
            // Don't show error for mock data fallback
            print("Cash Cow Analysis using mock data: \(error)")
        }
    }
    
    private func loadMockData() async {
        // Mock current cash cows
        self.currentCows = [
            CashCowData(
                playerId: "1",
                playerName: "Sam Walsh",
                currentPrice: 450000,
                projectedPrice: 480000,
                cashGenerated: 30000,
                recommendation: "Hold - Solid cash generation",
                confidence: 0.85,
                fpAverage: 98.5,
                gamesPlayed: 8
            ),
            CashCowData(
                playerId: "2",
                playerName: "Nick Daicos",
                currentPrice: 520000,
                projectedPrice: 570000,
                cashGenerated: 50000,
                recommendation: "Strong hold - Premium potential",
                confidence: 0.92,
                fpAverage: 105.2,
                gamesPlayed: 7
            ),
            CashCowData(
                playerId: "3",
                playerName: "Hayden Young",
                currentPrice: 380000,
                projectedPrice: 420000,
                cashGenerated: 40000,
                recommendation: "Consider upgrade timing",
                confidence: 0.78,
                fpAverage: 87.3,
                gamesPlayed: 6
            )
        ]
        
        // Mock potential picks
        self.potentialPicks = [
            CashCowData(
                playerId: "4",
                playerName: "Caleb Serong",
                currentPrice: 420000,
                projectedPrice: 470000,
                cashGenerated: 0,
                recommendation: "Potential breakout candidate",
                confidence: 0.73,
                fpAverage: 92.1,
                gamesPlayed: 3
            ),
            CashCowData(
                playerId: "5",
                playerName: "Josh Rachele",
                currentPrice: 350000,
                projectedPrice: 400000,
                cashGenerated: 0,
                recommendation: "Good value pick",
                confidence: 0.71,
                fpAverage: 78.4,
                gamesPlayed: 4
            ),
            CashCowData(
                playerId: "6",
                playerName: "Nic Martin",
                currentPrice: 310000,
                projectedPrice: 360000,
                cashGenerated: 0,
                recommendation: "Budget option with upside",
                confidence: 0.68,
                fpAverage: 71.2,
                gamesPlayed: 5
            )
        ]
    }
    
    func refreshData() async {
        analyticsService.trackEvent("cash_cow_analyzer_refreshed")
        await loadData()
    }
    
    func selectSection(_ section: CashCowSection) {
        selectedSection = section
        analyticsService.trackEvent("cash_cow_section_selected", properties: ["section": section.title])
    }
    
    var displayedCows: [CashCowData] {
        switch selectedSection {
        case .current:
            return currentCows
        case .potential:
            return potentialPicks
        }
    }
    
    var emptyStateMessage: String {
        switch selectedSection {
        case .current:
            return "No current cash cows found. Players typically become cash cows after 3+ games with consistent scoring."
        case .potential:
            return "No potential picks identified. Check back after team sheets are released."
        }
    }
    
    var emptyStateIcon: String {
        switch selectedSection {
        case .current:
            return "dollarsign.circle"
        case .potential:
            return "magnifyingglass"
        }
    }
}

