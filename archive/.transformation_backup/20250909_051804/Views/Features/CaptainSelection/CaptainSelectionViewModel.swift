import SwiftUI

@MainActor
final class CaptainSelectionViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var players: [PlayerOption] = []
    @Published private(set) var selectedPlayerGames: [GameStats] = []
    @Published private(set) var selectedPlayerProjection: Double?
    @Published private(set) var aiRecommendations: [AIRecommendation] = []
    @Published var selectedPlayerId: String?
    @Published var viceCaptainId: String?
    @Published private(set) var isAIEnabled = true
    @Published var showError = false
    @Published var errorMessage = ""
    
    // MARK: - Dependencies
    
    private let playerService: PlayerServiceProtocol
    private let aiService: CaptainAIServiceProtocol
    private let settingsService: SettingsServiceProtocol
    
    // MARK: - Init
    
    init(
        playerService: PlayerServiceProtocol = PlayerService(),
        aiService: CaptainAIServiceProtocol = CaptainAIService(),
        settingsService: SettingsServiceProtocol = SettingsService()
    ) {
        self.playerService = playerService
        self.aiService = aiService
        self.settingsService = settingsService
    }
    
    // MARK: - Public Methods
    
    func loadData() {
        Task {
            do {
                // Load preferences
                isAIEnabled = try await settingsService.isAIEnabled()
                
                // Load players and stats
                async let playersTask = playerService.getTeamPlayers()
                async let recommendationsTask = isAIEnabled ? aiService.getRecommendations() : []
                
                // Wait for parallel fetches
                (players, aiRecommendations) = try await (playersTask, recommendationsTask)
                
                // Set initial selection to current captain
                selectedPlayerId = try? await playerService.getCurrentCaptain()
                viceCaptainId = try? await playerService.getCurrentViceCaptain()
                
                // Load selected player stats if we have a selection
                if let selectedId = selectedPlayerId {
                    try await updatePlayerStats(for: selectedId)
                }
                
            } catch {
                handleError(error)
            }
        }
    }
    
    func updatePlayerStats() {
        guard let selectedId = selectedPlayerId else {
            selectedPlayerGames = []
            selectedPlayerProjection = nil
            return
        }
        
        Task {
            try? await updatePlayerStats(for: selectedId)
        }
    }
    
    func toggleAI() {
        Task {
            do {
                isAIEnabled.toggle()
                
                // Save preference
                try await settingsService.setAIEnabled(isAIEnabled)
                
                if isAIEnabled {
                    // Load recommendations if enabled
                    aiRecommendations = try await aiService.getRecommendations()
                } else {
                    // Clear recommendations if disabled
                    aiRecommendations = []
                }
            } catch {
                handleError(error)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func updatePlayerStats(for playerId: String) async throws {
        async let gamesTask = playerService.getPlayerGames(playerId)
        async let projectionTask = playerService.getProjectedScore(playerId)
        
        (selectedPlayerGames, selectedPlayerProjection) = try await (gamesTask, projectionTask)
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

// MARK: - Note
// Service protocols are defined in Services/ServiceProtocols.swift
