import SwiftUI

@main
struct AFLFantasyApp: App {
    init() {
        setupDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func setupDependencies() {
        let serviceLocator = ServiceLocator.shared
        
        // Register API Client
        let apiClient = AFLAPIClient()
        serviceLocator.register(apiClient, for: AFLAPIClientProtocol.self)
        
        // Register Use Cases
        serviceLocator.register(
            FetchPlayersUseCase(apiClient: apiClient),
            for: FetchPlayersUseCase.self
        )
        
        serviceLocator.register(
            FetchCashCowsUseCase(apiClient: apiClient),
            for: FetchCashCowsUseCase.self
        )
        
        serviceLocator.register(
            FetchSummaryUseCase(apiClient: apiClient),
            for: FetchSummaryUseCase.self
        )
        
        serviceLocator.register(
            FetchCaptainSuggestionsUseCase(apiClient: apiClient),
            for: FetchCaptainSuggestionsUseCase.self
        )
        
        serviceLocator.register(
            LiveStatsUseCase(apiClient: apiClient),
            for: LiveStatsUseCase.self
        )
    }
}

struct ContentView: View {
    var body: some View {
        DashboardView(viewModel: createDashboardViewModel())
    }
    
    private func createDashboardViewModel() -> DashboardViewModel {
        let serviceLocator = ServiceLocator.shared
        
        return DashboardViewModel(
            fetchPlayersUseCase: serviceLocator.resolve(FetchPlayersUseCase.self),
            fetchCashCowsUseCase: serviceLocator.resolve(FetchCashCowsUseCase.self),
            fetchSummaryUseCase: serviceLocator.resolve(FetchSummaryUseCase.self),
            fetchCaptainSuggestionsUseCase: serviceLocator.resolve(FetchCaptainSuggestionsUseCase.self),
            liveStatsUseCase: serviceLocator.resolve(LiveStatsUseCase.self)
        )
    }
}
