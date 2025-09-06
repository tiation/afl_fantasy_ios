//
//  PersistentAppState.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
import os.log

// MARK: - Persistent App State

@MainActor
class PersistentAppState: ObservableObject {
    @Published var selectedTab: TabItem = .dashboard
    @Published var teamScore: Int = 0
    @Published var teamRank: Int = 0
    @Published var players: [EnhancedPlayer] = []
    @Published var captainSuggestions: [CaptainSuggestion] = []
    @Published var cashCows: [EnhancedPlayer] = []
    @Published var favoritePlayers: [EnhancedPlayer] = []
    
    // Persistence State
    @Published var isLoading = false
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    
    // User Preferences
    @Published var userPreferences: UserPreferencesData?
    
    private let coreDataManager = CoreDataManager.shared
    private let logger = Logger(subsystem: "AFLFantasy", category: "PersistentAppState")
    private let currentUserId = "default_user" // In a real app, this would come from authentication
    
    init() {
        loadPersistedData()
    }
    
    // MARK: - Data Loading
    
    func loadPersistedData() {
        isLoading = true
        
        Task {
            do {
                // Load user preferences
                await loadUserPreferences()
                
                // Load team data
                await loadTeamData()
                
                // Load players
                await loadPlayers()
                
                // Load captain suggestions
                await loadCaptainSuggestions()
                
                // Update derived data
                updateDerivedData()
                
                isLoading = false
                logger.info("Successfully loaded persisted data")
                
            } catch {
                logger.error("Failed to load persisted data: \(error.localizedDescription)")
                isLoading = false
                syncError = error.localizedDescription
            }
        }
    }
    
    private func loadUserPreferences() async {
        if let preferences = coreDataManager.fetchUserPreferences(for: currentUserId) {
            userPreferences = preferences
            selectedTab = TabItem(rawValue: preferences.selectedTab) ?? .dashboard
        } else {
            // Create default preferences
            let defaultPreferences = UserPreferencesData(
                userId: currentUserId,
                teamName: "My Fantasy Team",
                selectedTab: TabItem.dashboard.rawValue,
                notificationsEnabled: true,
                autoRefreshEnabled: true,
                preferredRefreshInterval: 300
            )
            userPreferences = defaultPreferences
            coreDataManager.saveUserPreferences(defaultPreferences)
        }
    }
    
    private func loadTeamData() async {
        if let teamData = coreDataManager.fetchTeamData(for: currentUserId) {
            teamScore = teamData.teamScore
            teamRank = teamData.overallRank
        }
    }
    
    private func loadPlayers() async {
        let persistedPlayers = coreDataManager.fetchPlayers()
        
        if persistedPlayers.isEmpty {
            // Load sample data if no persisted players
            await loadSampleData()
        } else {
            players = persistedPlayers
        }
        
        // Load favorites
        favoritePlayers = coreDataManager.fetchFavoritePlayers()
    }
    
    private func loadCaptainSuggestions() async {
        let currentRound = getCurrentRound()
        // Note: Core Data CaptainSuggestion entities would need conversion to app model
        // captainSuggestions = coreDataManager.fetchCaptainSuggestions(for: currentRound)
        
        // For now, generate suggestions from current players
        generateCaptainSuggestions()
    }
    
    private func updateDerivedData() {
        cashCows = players.filter { $0.isCashCow }
        lastSyncDate = Date()
    }
    
    // MARK: - Data Persistence
    
    func savePlayer(_ player: EnhancedPlayer) {
        Task {
            coreDataManager.savePlayer(from: player)
            
            // Update local state
            if let index = players.firstIndex(where: { $0.id == player.id }) {
                players[index] = player
            } else {
                players.append(player)
            }
            
            updateDerivedData()
        }
    }
    
    func savePlayers(_ playersToSave: [EnhancedPlayer]) {
        Task {
            isSyncing = true
            
            do {
                try await coreDataManager.performBackgroundTask { context in
                    for player in playersToSave {
                        // Save each player in background context
                        let request: NSFetchRequest<Player> = Player.fetchRequest()
                        request.predicate = NSPredicate(format: "id == %@", player.id)
                        
                        let persistedPlayer: Player
                        if let existingPlayer = try context.fetch(request).first {
                            persistedPlayer = existingPlayer
                        } else {
                            persistedPlayer = Player(context: context)
                            persistedPlayer.id = player.id
                        }
                        
                        // Update player data
                        self.updatePlayerEntity(persistedPlayer, from: player)
                    }
                }
                
                // Reload data from Core Data
                await loadPlayers()
                
                isSyncing = false
                syncError = nil
                logger.info("Successfully saved \\(playersToSave.count) players")
                
            } catch {
                isSyncing = false
                syncError = error.localizedDescription
                logger.error("Failed to save players: \(error.localizedDescription)")
            }
        }
    }
    
    func saveTeamData(score: Int, rank: Int) {
        let teamData = TeamDataModel(
            userId: currentUserId,
            teamName: userPreferences?.teamName,
            teamScore: score,
            overallRank: rank,
            roundRank: 0, // Would be calculated from real data
            bankBalance: 0, // Would come from real data
            totalTransfers: 0 // Would come from real data
        )
        
        coreDataManager.saveTeamData(teamData)
        
        teamScore = score
        teamRank = rank
    }
    
    func saveUserPreferences(_ preferences: UserPreferencesData) {
        coreDataManager.saveUserPreferences(preferences)
        userPreferences = preferences
        selectedTab = TabItem(rawValue: preferences.selectedTab) ?? .dashboard
    }
    
    // MARK: - Favorites Management
    
    func togglePlayerFavorite(_ playerId: String) {
        coreDataManager.togglePlayerFavorite(playerId)
        
        // Update local state
        if let playerIndex = players.firstIndex(where: { $0.id == playerId }) {
            // Note: Would need to update the EnhancedPlayer model to include isFavorite
            // For now, just reload favorites
            favoritePlayers = coreDataManager.fetchFavoritePlayers()
        }
    }
    
    // MARK: - Sync Operations
    
    func syncWithRemoteData() async {
        isSyncing = true
        syncError = nil
        
        do {
            // In a real app, this would fetch from your API
            // For now, just refresh local data
            await loadPersistedData()
            
            isSyncing = false
            lastSyncDate = Date()
            logger.info("Successfully synced data")
            
        } catch {
            isSyncing = false
            syncError = error.localizedDescription
            logger.error("Failed to sync data: \(error.localizedDescription)")
        }
    }
    
    func clearAllData() {
        Task {
            do {
                try await coreDataManager.performBackgroundTask { context in
                    // Delete all entities
                    let entities = ["Player", "AlertFlag", "InjuryRisk", "RoundProjection", 
                                  "SeasonProjection", "VenuePerformance", "UserPreferences", 
                                  "TeamData", "CaptainSuggestion"]
                    
                    for entityName in entities {
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                        try context.execute(deleteRequest)
                    }
                }
                
                // Reset local state
                players = []
                captainSuggestions = []
                cashCows = []
                favoritePlayers = []
                teamScore = 0
                teamRank = 0
                userPreferences = nil
                
                // Reload with fresh data
                await loadPersistedData()
                
                logger.info("Successfully cleared all data")
                
            } catch {
                syncError = error.localizedDescription
                logger.error("Failed to clear data: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func updatePlayerEntity(_ entity: Player, from player: EnhancedPlayer) {
        entity.name = player.name
        entity.position = player.position.rawValue
        entity.price = Int32(player.price)
        entity.currentScore = Int32(player.currentScore)
        entity.averageScore = player.averageScore
        entity.breakeven = Int32(player.breakeven)
        entity.consistency = player.consistency
        entity.highScore = Int32(player.highScore)
        entity.lowScore = Int32(player.lowScore)
        entity.priceChange = Int32(player.priceChange)
        entity.isCashCow = player.isCashCow
        entity.isDoubtful = player.isDoubtful
        entity.isSuspended = player.isSuspended
        entity.lastUpdated = Date()
    }
    
    private func getCurrentRound() -> Int {
        // In a real app, this would be calculated from current date and season schedule
        return 15
    }
    
    private func generateCaptainSuggestions() {
        let topPlayers = players.sorted { $0.averageScore > $1.averageScore }.prefix(3)
        
        captainSuggestions = topPlayers.enumerated().map { index, player in
            let confidence = Int(90 - Double(index) * 5 + player.consistency * 0.1)
            let projectedPoints = Int(player.nextRoundProjection.projectedScore * 2 + Double.random(in: -10...10))
            
            return CaptainSuggestion(
                player: player,
                confidence: confidence,
                projectedPoints: projectedPoints
            )
        }
    }
    
    private func loadSampleData() async {
        // Load the sample data from the original AppState implementation
        let samplePlayers = createSamplePlayers()
        players = samplePlayers
        
        // Save sample data to Core Data for future use
        for player in samplePlayers {
            coreDataManager.savePlayer(from: player)
        }
        
        // Save sample team data
        saveTeamData(score: 1987, rank: 5432)
    }
    
    private func createSamplePlayers() -> [EnhancedPlayer] {
        return [
            EnhancedPlayer(
                id: "1",
                name: "Marcus Bontempelli",
                position: .midfielder,
                price: 850000,
                currentScore: 125,
                averageScore: 118.5,
                breakeven: 85,
                consistency: 92.0,
                highScore: 156,
                lowScore: 85,
                priceChange: 25000,
                isCashCow: false,
                isDoubtful: false,
                isSuspended: false,
                cashGenerated: 0,
                projectedPeakPrice: 0,
                nextRoundProjection: RoundProjection(
                    round: 15,
                    opponent: "Richmond",
                    venue: "Marvel Stadium",
                    projectedScore: 130.0,
                    confidence: 0.88,
                    conditions: WeatherConditions(temperature: 18.0, rainProbability: 0.2, windSpeed: 15.0, humidity: 65.0)
                ),
                seasonProjection: SeasonProjection(projectedTotalScore: 2370.0, projectedAverage: 118.5, premiumPotential: 0.95),
                injuryRisk: InjuryRisk(riskLevel: .low, riskScore: 0.15, riskFactors: []),
                venuePerformance: [
                    VenuePerformance(venue: "Marvel Stadium", gamesPlayed: 6, averageScore: 125.2, bias: 6.7),
                    VenuePerformance(venue: "MCG", gamesPlayed: 4, averageScore: 112.8, bias: -5.7)
                ],
                alertFlags: []
            ),
            EnhancedPlayer(
                id: "2",
                name: "Max Gawn",
                position: .ruck,
                price: 780000,
                currentScore: 98,
                averageScore: 105.2,
                breakeven: 90,
                consistency: 88.0,
                highScore: 144,
                lowScore: 65,
                priceChange: -15000,
                isCashCow: false,
                isDoubtful: true,
                isSuspended: false,
                cashGenerated: 0,
                projectedPeakPrice: 0,
                nextRoundProjection: RoundProjection(
                    round: 15,
                    opponent: "Collingwood",
                    venue: "MCG",
                    projectedScore: 105.0,
                    confidence: 0.75,
                    conditions: WeatherConditions(temperature: 14.0, rainProbability: 0.1, windSpeed: 20.0, humidity: 70.0)
                ),
                seasonProjection: SeasonProjection(projectedTotalScore: 2104.0, projectedAverage: 105.2, premiumPotential: 0.88),
                injuryRisk: InjuryRisk(riskLevel: .moderate, riskScore: 0.35, riskFactors: ["Knee soreness", "Age concern"]),
                venuePerformance: [
                    VenuePerformance(venue: "MCG", gamesPlayed: 8, averageScore: 108.5, bias: 3.3),
                    VenuePerformance(venue: "Marvel Stadium", gamesPlayed: 2, averageScore: 98.0, bias: -7.2)
                ],
                alertFlags: [
                    AlertFlag(type: .injuryRisk, priority: .high, message: "Knee soreness reported at training")
                ]
            ),
            EnhancedPlayer(
                id: "3",
                name: "Touk Miller",
                position: .midfielder,
                price: 720000,
                currentScore: 110,
                averageScore: 108.8,
                breakeven: 75,
                consistency: 89.0,
                highScore: 141,
                lowScore: 78,
                priceChange: 20000,
                isCashCow: false,
                isDoubtful: false,
                isSuspended: false,
                cashGenerated: 0,
                projectedPeakPrice: 0,
                nextRoundProjection: RoundProjection(
                    round: 15,
                    opponent: "Geelong",
                    venue: "GMHBA Stadium",
                    projectedScore: 115.0,
                    confidence: 0.82,
                    conditions: WeatherConditions(temperature: 16.0, rainProbability: 0.4, windSpeed: 25.0, humidity: 68.0)
                ),
                seasonProjection: SeasonProjection(projectedTotalScore: 2176.0, projectedAverage: 108.8, premiumPotential: 0.91),
                injuryRisk: InjuryRisk(riskLevel: .low, riskScore: 0.12, riskFactors: []),
                venuePerformance: [
                    VenuePerformance(venue: "GMHBA Stadium", gamesPlayed: 3, averageScore: 118.7, bias: 9.9),
                    VenuePerformance(venue: "Gabba", gamesPlayed: 5, averageScore: 105.2, bias: -3.6)
                ],
                alertFlags: [
                    AlertFlag(type: .contractYear, priority: .medium, message: "Contract year motivation boost")
                ]
            ),
            EnhancedPlayer(
                id: "4",
                name: "Hayden Young",
                position: .defender,
                price: 550000,
                currentScore: 78,
                averageScore: 85.2,
                breakeven: 45,
                consistency: 76.0,
                highScore: 112,
                lowScore: 45,
                priceChange: 35000,
                isCashCow: true,
                isDoubtful: false,
                isSuspended: false,
                cashGenerated: 120000,
                projectedPeakPrice: 680000,
                nextRoundProjection: RoundProjection(
                    round: 15,
                    opponent: "Sydney",
                    venue: "Optus Stadium",
                    projectedScore: 88.0,
                    confidence: 0.78,
                    conditions: WeatherConditions(temperature: 22.0, rainProbability: 0.0, windSpeed: 12.0, humidity: 55.0)
                ),
                seasonProjection: SeasonProjection(projectedTotalScore: 1704.0, projectedAverage: 85.2, premiumPotential: 0.65),
                injuryRisk: InjuryRisk(riskLevel: .low, riskScore: 0.14, riskFactors: []),
                venuePerformance: [
                    VenuePerformance(venue: "Optus Stadium", gamesPlayed: 6, averageScore: 89.4, bias: 4.2),
                    VenuePerformance(venue: "MCG", gamesPlayed: 2, averageScore: 75.5, bias: -9.7)
                ],
                alertFlags: [
                    AlertFlag(type: .cashCowSell, priority: .high, message: "Approaching breakeven - consider selling")
                ]
            ),
            EnhancedPlayer(
                id: "5",
                name: "Sam Walsh",
                position: .midfielder,
                price: 750000,
                currentScore: 115,
                averageScore: 112.4,
                breakeven: 80,
                consistency: 87.0,
                highScore: 148,
                lowScore: 82,
                priceChange: 30000,
                isCashCow: false,
                isDoubtful: false,
                isSuspended: false,
                cashGenerated: 0,
                projectedPeakPrice: 0,
                nextRoundProjection: RoundProjection(
                    round: 15,
                    opponent: "Hawthorn",
                    venue: "MCG",
                    projectedScore: 118.0,
                    confidence: 0.85,
                    conditions: WeatherConditions(temperature: 15.0, rainProbability: 0.3, windSpeed: 18.0, humidity: 72.0)
                ),
                seasonProjection: SeasonProjection(projectedTotalScore: 2248.0, projectedAverage: 112.4, premiumPotential: 0.93),
                injuryRisk: InjuryRisk(riskLevel: .low, riskScore: 0.18, riskFactors: []),
                venuePerformance: [
                    VenuePerformance(venue: "MCG", gamesPlayed: 5, averageScore: 116.2, bias: 3.8),
                    VenuePerformance(venue: "Marvel Stadium", gamesPlayed: 3, averageScore: 106.7, bias: -5.7)
                ],
                alertFlags: [
                    AlertFlag(type: .contractYear, priority: .low, message: "Contract year - extra motivation expected")
                ]
            )
        ]
    }
}
