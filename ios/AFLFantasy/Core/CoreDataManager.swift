//
//  CoreDataManager.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import CoreData
import Foundation
import os.log
import SwiftUI

// MARK: - CoreDataManager

@MainActor
class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()

    private let logger = Logger(subsystem: "AFLFantasy", category: "CoreData")

    // MARK: - Core Data Stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AFLFantasy")

        // Configure for better performance and CloudKit if needed
        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores { _, error in
            if let error {
                self.logger.error("Core Data error: \(error.localizedDescription)")
                fatalError("Core Data error: \(error.localizedDescription)")
            } else {
                self.logger.info("Core Data loaded successfully")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Initialization

    private init() {
        // Initialize Core Data stack
        _ = persistentContainer
    }

    // MARK: - Save Context

    func save() {
        guard context.hasChanges else { return }

        do {
            try context.save()
            logger.info("Core Data context saved successfully")
        } catch {
            logger.error("Failed to save Core Data context: \(error.localizedDescription)")
        }
    }

    // MARK: - Batch Operations

    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            persistentContainer.performBackgroundTask { backgroundContext in
                do {
                    let result = try block(backgroundContext)
                    if backgroundContext.hasChanges {
                        try backgroundContext.save()
                    }
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Player Operations

extension CoreDataManager {
    func savePlayer(from enhancedPlayer: EnhancedPlayer) {
        let request: NSFetchRequest<Player> = Player.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", enhancedPlayer.id)

        let player: Player
        if let existingPlayer = try? context.fetch(request).first {
            player = existingPlayer
        } else {
            player = Player(context: context)
            player.id = enhancedPlayer.id
        }

        // Update player attributes
        player.name = enhancedPlayer.name
        player.position = enhancedPlayer.position.rawValue
        player.price = Int32(enhancedPlayer.price)
        player.currentScore = Int32(enhancedPlayer.currentScore)
        player.averageScore = enhancedPlayer.averageScore
        player.breakeven = Int32(enhancedPlayer.breakeven)
        player.consistency = enhancedPlayer.consistency
        player.highScore = Int32(enhancedPlayer.highScore)
        player.lowScore = Int32(enhancedPlayer.lowScore)
        player.priceChange = Int32(enhancedPlayer.priceChange)
        player.isCashCow = enhancedPlayer.isCashCow
        player.isDoubtful = enhancedPlayer.isDoubtful
        player.isSuspended = enhancedPlayer.isSuspended
        player.lastUpdated = Date()

        // Save related entities
        saveRoundProjection(enhancedPlayer.nextRoundProjection, for: player)
        saveSeasonProjection(enhancedPlayer.seasonProjection, for: player)
        saveInjuryRisk(enhancedPlayer.injuryRisk, for: player)
        saveVenuePerformances(enhancedPlayer.venuePerformance, for: player)
        saveAlertFlags(enhancedPlayer.alertFlags, for: player)

        save()
    }

    func fetchPlayers() -> [EnhancedPlayer] {
        let request: NSFetchRequest<Player> = Player.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Player.averageScore, ascending: false)]

        do {
            let players = try context.fetch(request)
            return players.compactMap { convertToEnhancedPlayer($0) }
        } catch {
            logger.error("Failed to fetch players: \(error.localizedDescription)")
            return []
        }
    }

    func fetchFavoritePlayers() -> [EnhancedPlayer] {
        let request: NSFetchRequest<Player> = Player.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Player.averageScore, ascending: false)]

        do {
            let players = try context.fetch(request)
            return players.compactMap { convertToEnhancedPlayer($0) }
        } catch {
            logger.error("Failed to fetch favorite players: \(error.localizedDescription)")
            return []
        }
    }

    func togglePlayerFavorite(_ playerId: String) {
        let request: NSFetchRequest<Player> = Player.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", playerId)

        do {
            if let player = try context.fetch(request).first {
                player.isFavorite.toggle()
                save()
            }
        } catch {
            logger.error("Failed to toggle player favorite: \(error.localizedDescription)")
        }
    }

    private func convertToEnhancedPlayer(_ player: Player) -> EnhancedPlayer? {
        guard let id = player.id,
              let name = player.name,
              let positionString = player.position,
              let position = Position(rawValue: positionString)
        else {
            return nil
        }

        let roundProjection = convertToRoundProjection(player.nextRoundProjection)
        let seasonProjection = convertToSeasonProjection(player.seasonProjection)
        let injuryRisk = convertToInjuryRisk(player.injuryRisk)
        let venuePerformances = convertToVenuePerformances(player.venuePerformances)
        let alertFlags = convertToAlertFlags(player.alertFlags)

        return EnhancedPlayer(
            id: id,
            name: name,
            position: position,
            price: Int(player.price),
            currentScore: Int(player.currentScore),
            averageScore: player.averageScore,
            breakeven: Int(player.breakeven),
            consistency: player.consistency,
            highScore: Int(player.highScore),
            lowScore: Int(player.lowScore),
            priceChange: Int(player.priceChange),
            isCashCow: player.isCashCow,
            isDoubtful: player.isDoubtful,
            isSuspended: player.isSuspended,
            cashGenerated: 0, // Calculate from historical data if needed
            projectedPeakPrice: 0, // Calculate from projections if needed
            nextRoundProjection: roundProjection,
            seasonProjection: seasonProjection,
            injuryRisk: injuryRisk,
            venuePerformance: venuePerformances,
            alertFlags: alertFlags
        )
    }
}

// MARK: - Related Entity Operations

extension CoreDataManager {
    private func saveRoundProjection(_ projection: RoundProjection, for player: Player) {
        if let existingProjection = player.nextRoundProjection {
            context.delete(existingProjection)
        }

        let roundProjection = RoundProjection(context: context)
        roundProjection.id = UUID()
        roundProjection.round = Int32(projection.round)
        roundProjection.opponent = projection.opponent
        roundProjection.venue = projection.venue
        roundProjection.projectedScore = projection.projectedScore
        roundProjection.confidence = projection.confidence
        roundProjection.temperature = projection.conditions.temperature
        roundProjection.rainProbability = projection.conditions.rainProbability
        roundProjection.windSpeed = projection.conditions.windSpeed
        roundProjection.humidity = projection.conditions.humidity
        roundProjection.player = player
    }

    private func saveSeasonProjection(_ projection: SeasonProjection, for player: Player) {
        if let existingProjection = player.seasonProjection {
            context.delete(existingProjection)
        }

        let seasonProjection = SeasonProjection(context: context)
        seasonProjection.id = UUID()
        seasonProjection.projectedTotalScore = projection.projectedTotalScore
        seasonProjection.projectedAverage = projection.projectedAverage
        seasonProjection.premiumPotential = projection.premiumPotential
        seasonProjection.player = player
    }

    private func saveInjuryRisk(_ risk: InjuryRisk, for player: Player) {
        if let existingRisk = player.injuryRisk {
            context.delete(existingRisk)
        }

        let injuryRisk = InjuryRisk(context: context)
        injuryRisk.id = UUID()
        injuryRisk.riskLevel = risk.riskLevel.rawValue
        injuryRisk.riskScore = risk.riskScore
        injuryRisk.riskFactors = risk.riskFactors.joined(separator: ",")
        injuryRisk.player = player
    }

    private func saveVenuePerformances(_ performances: [VenuePerformance], for player: Player) {
        // Delete existing venue performances
        if let existingPerformances = player.venuePerformances {
            for performance in existingPerformances {
                context.delete(performance as! NSManagedObject)
            }
        }

        // Add new venue performances
        for performance in performances {
            let venuePerformance = VenuePerformance(context: context)
            venuePerformance.id = UUID()
            venuePerformance.venue = performance.venue
            venuePerformance.gamesPlayed = Int32(performance.gamesPlayed)
            venuePerformance.averageScore = performance.averageScore
            venuePerformance.bias = performance.bias
            venuePerformance.player = player
        }
    }

    private func saveAlertFlags(_ flags: [AlertFlag], for player: Player) {
        // Delete existing alert flags
        if let existingFlags = player.alertFlags {
            for flag in existingFlags {
                context.delete(flag as! NSManagedObject)
            }
        }

        // Add new alert flags
        for flag in flags {
            let alertFlag = AlertFlag(context: context)
            alertFlag.id = UUID()
            alertFlag.type = flag.type.rawValue
            alertFlag.priority = flag.priority.rawValue
            alertFlag.message = flag.message
            alertFlag.createdDate = Date()
            alertFlag.player = player
        }
    }
}

// MARK: - Conversion Helpers

extension CoreDataManager {
    private func convertToRoundProjection(_ projection: RoundProjection?) -> RoundProjection {
        guard let projection else {
            return RoundProjection(
                round: 1,
                opponent: "TBD",
                venue: "TBD",
                projectedScore: 0,
                confidence: 0,
                conditions: WeatherConditions(temperature: 20, rainProbability: 0, windSpeed: 10, humidity: 60)
            )
        }

        return RoundProjection(
            round: Int(projection.round),
            opponent: projection.opponent ?? "TBD",
            venue: projection.venue ?? "TBD",
            projectedScore: projection.projectedScore,
            confidence: projection.confidence,
            conditions: WeatherConditions(
                temperature: projection.temperature,
                rainProbability: projection.rainProbability,
                windSpeed: projection.windSpeed,
                humidity: projection.humidity
            )
        )
    }

    private func convertToSeasonProjection(_ projection: SeasonProjection?) -> SeasonProjection {
        guard let projection else {
            return SeasonProjection(
                projectedTotalScore: 0,
                projectedAverage: 0,
                premiumPotential: 0
            )
        }

        return SeasonProjection(
            projectedTotalScore: projection.projectedTotalScore,
            projectedAverage: projection.projectedAverage,
            premiumPotential: projection.premiumPotential
        )
    }

    private func convertToInjuryRisk(_ risk: InjuryRisk?) -> InjuryRisk {
        guard let risk,
              let riskLevelString = risk.riskLevel,
              let riskLevel = RiskLevel(rawValue: riskLevelString)
        else {
            return InjuryRisk(riskLevel: .low, riskScore: 0, riskFactors: [])
        }

        let riskFactors = risk.riskFactors?.components(separatedBy: ",") ?? []

        return InjuryRisk(
            riskLevel: riskLevel,
            riskScore: risk.riskScore,
            riskFactors: riskFactors
        )
    }

    private func convertToVenuePerformances(_ performances: NSSet?) -> [VenuePerformance] {
        guard let performances = performances as? Set<VenuePerformance> else {
            return []
        }

        return performances.compactMap { performance in
            guard let venue = performance.venue else { return nil }

            return VenuePerformance(
                venue: venue,
                gamesPlayed: Int(performance.gamesPlayed),
                averageScore: performance.averageScore,
                bias: performance.bias
            )
        }
    }

    private func convertToAlertFlags(_ flags: NSSet?) -> [AlertFlag] {
        guard let flags = flags as? Set<AlertFlag> else {
            return []
        }

        return flags.compactMap { flag in
            guard let typeString = flag.type,
                  let type = AlertType(rawValue: typeString),
                  let priorityString = flag.priority,
                  let priority = AlertPriority(rawValue: priorityString),
                  let message = flag.message
            else {
                return nil
            }

            return AlertFlag(type: type, priority: priority, message: message)
        }
    }
}

// MARK: - User Preferences Operations

extension CoreDataManager {
    func saveUserPreferences(_ preferences: UserPreferencesData) {
        let request: NSFetchRequest<UserPreferences> = UserPreferences.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", preferences.userId)

        let userPrefs: UserPreferences
        if let existingPrefs = try? context.fetch(request).first {
            userPrefs = existingPrefs
        } else {
            userPrefs = UserPreferences(context: context)
            userPrefs.id = UUID()
            userPrefs.userId = preferences.userId
        }

        userPrefs.teamName = preferences.teamName
        userPrefs.selectedTab = preferences.selectedTab
        userPrefs.notificationsEnabled = preferences.notificationsEnabled
        userPrefs.autoRefreshEnabled = preferences.autoRefreshEnabled
        userPrefs.preferredRefreshInterval = Int32(preferences.preferredRefreshInterval)
        userPrefs.lastUpdated = Date()

        save()
    }

    func fetchUserPreferences(for userId: String) -> UserPreferencesData? {
        let request: NSFetchRequest<UserPreferences> = UserPreferences.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)

        do {
            if let userPrefs = try context.fetch(request).first {
                return UserPreferencesData(
                    userId: userId,
                    teamName: userPrefs.teamName,
                    selectedTab: userPrefs.selectedTab ?? "Dashboard",
                    notificationsEnabled: userPrefs.notificationsEnabled,
                    autoRefreshEnabled: userPrefs.autoRefreshEnabled,
                    preferredRefreshInterval: Int(userPrefs.preferredRefreshInterval)
                )
            }
        } catch {
            logger.error("Failed to fetch user preferences: \(error.localizedDescription)")
        }

        // Return default preferences if none found
        return UserPreferencesData(
            userId: userId,
            teamName: nil,
            selectedTab: "Dashboard",
            notificationsEnabled: true,
            autoRefreshEnabled: true,
            preferredRefreshInterval: 300
        )
    }
}

// MARK: - Team Data Operations

extension CoreDataManager {
    func saveTeamData(_ teamData: TeamDataModel) {
        let request: NSFetchRequest<TeamData> = TeamData.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", teamData.userId)

        let team: TeamData
        if let existingTeam = try? context.fetch(request).first {
            team = existingTeam
        } else {
            team = TeamData(context: context)
            team.id = UUID()
            team.userId = teamData.userId
        }

        team.teamName = teamData.teamName
        team.teamScore = Int32(teamData.teamScore)
        team.overallRank = Int32(teamData.overallRank)
        team.roundRank = Int32(teamData.roundRank)
        team.bankBalance = Int32(teamData.bankBalance)
        team.totalTransfers = Int32(teamData.totalTransfers)
        team.lastUpdated = Date()

        save()
    }

    func fetchTeamData(for userId: String) -> TeamDataModel? {
        let request: NSFetchRequest<TeamData> = TeamData.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)

        do {
            if let teamData = try context.fetch(request).first {
                return TeamDataModel(
                    userId: userId,
                    teamName: teamData.teamName,
                    teamScore: Int(teamData.teamScore),
                    overallRank: Int(teamData.overallRank),
                    roundRank: Int(teamData.roundRank),
                    bankBalance: Int(teamData.bankBalance),
                    totalTransfers: Int(teamData.totalTransfers)
                )
            }
        } catch {
            logger.error("Failed to fetch team data: \(error.localizedDescription)")
        }

        return nil
    }
}

// MARK: - Captain Suggestions Operations

extension CoreDataManager {
    func saveCaptainSuggestions(_ suggestions: [CaptainSuggestion], for round: Int) {
        // Delete existing suggestions for this round
        let deleteRequest: NSFetchRequest<CaptainSuggestion> = CaptainSuggestion.fetchRequest()
        deleteRequest.predicate = NSPredicate(format: "round == %d", round)

        do {
            let existingSuggestions = try context.fetch(deleteRequest)
            for suggestion in existingSuggestions {
                context.delete(suggestion)
            }
        } catch {
            logger.error("Failed to delete existing captain suggestions: \(error.localizedDescription)")
        }

        // Add new suggestions
        for suggestion in suggestions {
            let captainSuggestion = CaptainSuggestion(context: context)
            captainSuggestion.id = UUID()
            captainSuggestion.playerId = suggestion.player.id
            captainSuggestion.playerName = suggestion.player.name
            captainSuggestion.confidence = Int32(suggestion.confidence)
            captainSuggestion.projectedPoints = Int32(suggestion.projectedPoints)
            captainSuggestion.round = Int32(round)
            captainSuggestion.createdDate = Date()
        }

        save()
    }

    func fetchCaptainSuggestions(for round: Int) -> [CaptainSuggestion] {
        let request: NSFetchRequest<CaptainSuggestion> = CaptainSuggestion.fetchRequest()
        request.predicate = NSPredicate(format: "round == %d", round)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CaptainSuggestion.confidence, ascending: false)]

        do {
            let suggestions = try context.fetch(request)
            // Note: This returns Core Data CaptainSuggestion entities
            // You may need to convert them to your app's CaptainSuggestion model
            return suggestions
        } catch {
            logger.error("Failed to fetch captain suggestions: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: - Data Models

struct UserPreferencesData {
    let userId: String
    let teamName: String?
    let selectedTab: String
    let notificationsEnabled: Bool
    let autoRefreshEnabled: Bool
    let preferredRefreshInterval: Int
}

struct TeamDataModel {
    let userId: String
    let teamName: String?
    let teamScore: Int
    let overallRank: Int
    let roundRank: Int
    let bankBalance: Int
    let totalTransfers: Int
}
