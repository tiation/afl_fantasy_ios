//
//  DashboardView.swift
//
//  Main dashboard with real AFL Fantasy data
//

import SwiftUI

@available(iOS 16.0, *)
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingTeamImport = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with API status
                    apiStatusCard
                    
                    // Quick actions
                    quickActionsSection
                    
                    // Player list
                    if !viewModel.players.isEmpty {
                        playersSection
                    }
                    
                    // Cash Cow Analysis
                    if !viewModel.cashCows.isEmpty {
                        cashCowsSection
                    }
                    
                    // Captain Suggestions
                    if !viewModel.captainSuggestions.isEmpty {
                        captainSuggestionsSection
                    }
                }
                .padding()
            }
            .navigationTitle("AFL Fantasy AI")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Import Team") {
                        showingTeamImport = true
                    }
                }
            }
            .refreshable {
                await viewModel.refreshData()
            }
            .sheet(isPresented: $showingTeamImport) {
                TeamImportView()
            }
            .onAppear {
                Task {
                    await viewModel.loadInitialData()
                }
            }
        }
    }
    
    @ViewBuilder
    private var apiStatusCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("API Status")
                    .font(.headline)
                
                if let health = viewModel.apiHealth {
                    Text(health.status.capitalized)
                        .foregroundColor(health.status == "healthy" ? .green : .red)
                        .font(.subheadline)
                    
                    Text("\(health.playersCache ?? 0) players cached")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Checking...")
                        .foregroundColor(.orange)
                        .font(.subheadline)
                }
            }
            
            Spacer()
            
            Button {
                Task { await viewModel.checkAPIHealth() }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ActionCard(
                    title: "Import Team",
                    subtitle: "Connect your AFL Fantasy",
                    icon: "square.and.arrow.down.fill",
                    color: .blue
                ) {
                    showingTeamImport = true
                }
                
                ActionCard(
                    title: "Refresh Data",
                    subtitle: "Update player stats",
                    icon: "arrow.clockwise",
                    color: .green
                ) {
                    Task { await viewModel.refreshData() }
                }
            }
        }
    }
    
    @ViewBuilder
    private var playersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Players")
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.players.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(viewModel.players.prefix(10)) { player in
                    PlayerRow(player: player)
                }
                
                if viewModel.players.count > 10 {
                    Text("... and \(viewModel.players.count - 10) more players")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    @ViewBuilder
    private var cashCowsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cash Cows Analysis")
                .font(.headline)
            
            LazyVStack(spacing: 8) {
                ForEach(viewModel.cashCows.prefix(5)) { cashCow in
                    CashCowRow(cashCow: cashCow)
                }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    @ViewBuilder
    private var captainSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Captain Suggestions")
                .font(.headline)
            
            LazyVStack(spacing: 8) {
                ForEach(viewModel.captainSuggestions.prefix(3)) { suggestion in
                    CaptainSuggestionRow(suggestion: suggestion)
                }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Supporting Views

@available(iOS 16.0, *)
struct PlayerRow: View {
    let player: Player
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(player.team) • \(player.position.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(player.price / 1000)K")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Avg: \(player.average, specifier: "%.1f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

@available(iOS 16.0, *)
struct CashCowRow: View {
    let cashCow: CashCowData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(cashCow.playerName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(cashCow.recommendation)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(cashCow.cashGenerated)K")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                
                if let confidence = cashCow.confidence {
                    Text("\(confidence * 100, specifier: "%.0f")% confidence")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

@available(iOS 16.0, *)
struct CaptainSuggestionRow: View {
    let suggestion: CaptainSuggestionResponse
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.playerName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(suggestion.reasoning)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(suggestion.recommendation)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                Text("\(suggestion.confidence * 100, specifier: "%.0f")%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

@available(iOS 16.0, *)
struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ViewModel

@available(iOS 16.0, *)
@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var players: [Player] = []
    @Published var cashCows: [CashCowData] = []
    @Published var captainSuggestions: [CaptainSuggestionResponse] = []
    @Published var apiHealth: APIHealthResponse?
    @Published var isLoading = false
    
    private let apiClient = AFLFantasyAPIClient.shared
    
    func loadInitialData() async {
        isLoading = true
        defer { isLoading = false }
        
        await checkAPIHealth()
        await loadPlayers()
        await loadCashCows()
        await loadCaptainSuggestions()
    }
    
    func refreshData() async {
        await loadPlayers()
        await loadCashCows() 
        await loadCaptainSuggestions()
        await checkAPIHealth()
    }
    
    func checkAPIHealth() async {
        do {
            let health = try await apiClient.healthCheck()
            self.apiHealth = health
        } catch {
            print("Failed to check API health: \(error)")
        }
    }
    
    private func loadPlayers() async {
        do {
            let fetchedPlayers = try await apiClient.getAllPlayers()
            self.players = fetchedPlayers
        } catch {
            print("Failed to load players: \(error)")
        }
    }
    
    private func loadCashCows() async {
        do {
            let fetchedCashCows = try await apiClient.getCashCowAnalysis()
            self.cashCows = fetchedCashCows
        } catch {
            print("Failed to load cash cows: \(error)")
        }
    }
    
    private func loadCaptainSuggestions() async {
        do {
            let fetchedSuggestions = try await apiClient.getCaptainSuggestions()
            self.captainSuggestions = fetchedSuggestions
        } catch {
            print("Failed to load captain suggestions: \(error)")
        }
    }
}

#Preview {
    DashboardView()
}
