import SwiftUI
import Combine

/// Test view to demonstrate API integration with real scraped data
struct APITestView: View {
    @StateObject private var viewModel = APITestViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Health Status Section
                    healthSection
                    
                    // Players Section  
                    playersSection
                    
                    // Cash Cows Section
                    cashCowsSection
                    
                    // Captain Suggestions Section
                    captainSection
                }
                .padding()
            }
            .navigationTitle("API Integration Test")
            .refreshable {
                await viewModel.refreshData()
            }
            .onAppear {
                viewModel.loadData()
            }
        }
    }
    
    @ViewBuilder
    private var healthSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🏥 API Health Status")
                .font(.headline)
            
            if let health = viewModel.healthStatus {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Status: \(health.status)")
                        .foregroundColor(health.status == "healthy" ? .green : .red)
                    Text("Players Cached: \(health.playersCached)")
                    if let lastUpdate = health.lastCacheUpdate {
                        Text("Last Updated: \(lastUpdate)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            } else if viewModel.isLoading {
                ProgressView("Checking API health...")
            } else {
                Text("API not responding")
                    .foregroundColor(.red)
            }
        }
    }
    
    @ViewBuilder
    private var playersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("👥 Players (\(viewModel.players.count))")
                .font(.headline)
            
            if !viewModel.players.isEmpty {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(viewModel.players.prefix(5), id: \.id) { player in
                        HStack {
                            Text(player.name)
                                .fontWeight(.medium)
                            Spacer()
                            Text(player.team)
                                .foregroundColor(.secondary)
                            Text(player.position)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                                .font(.caption)
                        }
                    }
                    if viewModel.players.count > 5 {
                        Text("... and \(viewModel.players.count - 5) more")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            } else if viewModel.isLoading {
                ProgressView("Loading players...")
            } else {
                Text("No player data available")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var cashCowsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🐄 Cash Cows (\(viewModel.cashCows.count))")
                .font(.headline)
            
            if !viewModel.cashCows.isEmpty {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(viewModel.cashCows.prefix(3), id: \.playerId) { cow in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(cow.playerName)
                                    .fontWeight(.medium)
                                Text("$\(cow.currentPrice / 1000)k → $\(cow.projectedPrice / 1000)k")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(cow.recommendation)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(cow.recommendation == "SELL" ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                                    .foregroundColor(cow.recommendation == "SELL" ? .red : .green)
                                    .cornerRadius(4)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text("$\(cow.cashGenerated / 1000)k")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            } else if viewModel.isLoading {
                ProgressView("Analyzing cash cows...")
            } else {
                Text("No cash cow opportunities found")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var captainSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("⭐ Captain Suggestions (\(viewModel.captainSuggestions.count))")
                .font(.headline)
            
            if !viewModel.captainSuggestions.isEmpty {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(viewModel.captainSuggestions.prefix(3), id: \.playerId) { captain in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(captain.playerName)
                                    .fontWeight(.medium)
                                Text(captain.reasoning)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(Int(captain.projectedPoints)) pts")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Text("\(Int(captain.confidence * 100))% confidence")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            } else if viewModel.isLoading {
                ProgressView("Getting captain suggestions...")
            } else {
                Text("No captain suggestions available")
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - View Model

@MainActor
final class APITestViewModel: ObservableObject {
    @Published var healthStatus: APIHealthResponse?
    @Published var players: [APIPlayerSummary] = []
    @Published var cashCows: [CashCowData] = []
    @Published var captainSuggestions: [CaptainSuggestionResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    private var cancellables = Set<AnyCancellable>()
    
    func loadData() {
        Task {
            await refreshData()
        }
    }
    
    func refreshData() async {
        isLoading = true
        defer { isLoading = false }
        
        // Load all data concurrently
        async let healthTask = loadHealthStatus()
        async let playersTask = loadPlayers()
        async let cashCowsTask = loadCashCows()
        async let captainTask = loadCaptainSuggestions()
        
        // Wait for all tasks to complete
        await (healthTask, playersTask, cashCowsTask, captainTask)
    }
    
    private func loadHealthStatus() async {
        do {
            let health = try await withCheckedThrowingContinuation { continuation in
                apiClient.getHealthStatus()
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                continuation.resume(throwing: error)
                            }
                        },
                        receiveValue: { health in
                            continuation.resume(returning: health)
                        }
                    )
                    .store(in: &cancellables)
            }
            self.healthStatus = health
        } catch {
            print("Failed to load health status: \(error)")
            self.errorMessage = "API connection failed"
        }
    }
    
    private func loadPlayers() async {
        do {
            let players = try await withCheckedThrowingContinuation { continuation in
                apiClient.getAllPlayers()
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                continuation.resume(throwing: error)
                            }
                        },
                        receiveValue: { players in
                            continuation.resume(returning: players)
                        }
                    )
                    .store(in: &cancellables)
            }
            self.players = players
        } catch {
            print("Failed to load players: \(error)")
        }
    }
    
    private func loadCashCows() async {
        do {
            let cashCows = try await withCheckedThrowingContinuation { continuation in
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
                    .store(in: &cancellables)
            }
            self.cashCows = cashCows
        } catch {
            print("Failed to load cash cows: \(error)")
        }
    }
    
    private func loadCaptainSuggestions() async {
        do {
            let suggestions = try await withCheckedThrowingContinuation { continuation in
                apiClient.getCaptainSuggestions(venue: "MCG", opponent: "Richmond")
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                continuation.resume(throwing: error)
                            }
                        },
                        receiveValue: { suggestions in
                            continuation.resume(returning: suggestions)
                        }
                    )
                    .store(in: &cancellables)
            }
            self.captainSuggestions = suggestions
        } catch {
            print("Failed to load captain suggestions: \(error)")
        }
    }
}

// MARK: - Preview

struct APITestView_Previews: PreviewProvider {
    static var previews: some View {
        APITestView()
    }
}
