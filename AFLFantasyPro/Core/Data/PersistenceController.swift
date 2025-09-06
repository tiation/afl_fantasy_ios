//
//  PersistenceController.swift
//  AFL Fantasy Pro - Core Data Persistence
//
//  Core Data stack with caching, migration support, and efficient querying.
//  Provides offline data storage for players, teams, matches, and user sessions.
//

import CoreData
import Foundation
import Combine

// MARK: - Persistence Controller

@MainActor
class PersistenceController: ObservableObject {
    
    // MARK: - Shared Instance
    
    static let shared = PersistenceController()
    
    // MARK: - Preview Instance
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Add sample data for previews
        let sampleTeam = CachedTeam(context: context)
        sampleTeam.id = "sample-team"
        sampleTeam.name = "Sample Team"
        sampleTeam.totalScore = 1250
        sampleTeam.lastUpdated = Date()
        
        let samplePlayer = CachedPlayer(context: context)
        samplePlayer.id = "sample-player"
        samplePlayer.displayName = "John Sample"
        samplePlayer.position = "MID"
        samplePlayer.currentPrice = 500000
        samplePlayer.averageScore = 85.5
        samplePlayer.team = sampleTeam
        
        try? context.save()
        return controller
    }()
    
    // MARK: - Properties
    
    let container: NSPersistentContainer
    
    // MARK: - Published Properties
    
    @Published var isLoading = false
    @Published var cacheSize: Int64 = 0
    @Published var lastCacheClean: Date?
    
    // MARK: - Private Properties
    
    private let backgroundContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "AFLFantasyPro")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Configure persistent store
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, 
                                                               forKey: NSPersistentHistoryTrackingKey)
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, 
                                                               forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // Load persistent stores
        container.loadPersistentStores { [weak self] _, error in
            if let error = error {
                print("❌ Core Data failed to load: \(error.localizedDescription)")
                fatalError("Core Data error: \(error)")
            } else {
                print("✅ Core Data loaded successfully")
            }
        }
        
        // Configure contexts
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        backgroundContext = container.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        setupCacheMonitoring()
    }
    
    // MARK: - Public Methods
    
    func save() async throws {
        guard container.viewContext.hasChanges else { return }
        
        try await container.viewContext.perform {
            do {
                try self.container.viewContext.save()
                print("💾 Core Data saved successfully")
            } catch {
                print("❌ Core Data save failed: \(error)")
                throw error
            }
        }
    }
    
    func saveBackground() async throws {
        guard backgroundContext.hasChanges else { return }
        
        try await backgroundContext.perform {
            do {
                try self.backgroundContext.save()
                print("💾 Background Core Data saved successfully")
            } catch {
                print("❌ Background Core Data save failed: \(error)")
                throw error
            }
        }
    }
    
    // MARK: - Player Operations
    
    func cachePlayer(_ player: Player, for round: Int) async throws {
        try await backgroundContext.perform {
            let request: NSFetchRequest<CachedPlayer> = CachedPlayer.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@ AND round == %d", 
                                          player.id, round)
            
            let cachedPlayer: CachedPlayer
            if let existingPlayer = try? self.backgroundContext.fetch(request).first {
                cachedPlayer = existingPlayer
            } else {
                cachedPlayer = CachedPlayer(context: self.backgroundContext)
                cachedPlayer.id = player.id
                cachedPlayer.round = Int32(round)
            }
            
            // Update player data
            self.updateCachedPlayer(cachedPlayer, with: player)
            cachedPlayer.lastUpdated = Date()
        }
        
        try await saveBackground()
    }
    
    func cachePlayers(_ players: [Player], for round: Int) async throws {
        try await backgroundContext.perform {
            for player in players {
                let request: NSFetchRequest<CachedPlayer> = CachedPlayer.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@ AND round == %d", 
                                              player.id, round)
                
                let cachedPlayer: CachedPlayer
                if let existingPlayer = try? self.backgroundContext.fetch(request).first {
                    cachedPlayer = existingPlayer
                } else {
                    cachedPlayer = CachedPlayer(context: self.backgroundContext)
                    cachedPlayer.id = player.id
                    cachedPlayer.round = Int32(round)
                }
                
                self.updateCachedPlayer(cachedPlayer, with: player)
                cachedPlayer.lastUpdated = Date()
            }
        }
        
        try await saveBackground()
    }
    
    func getCachedPlayers(for round: Int) async throws -> [Player] {
        return try await backgroundContext.perform {
            let request: NSFetchRequest<CachedPlayer> = CachedPlayer.fetchRequest()
            request.predicate = NSPredicate(format: "round == %d", round)
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \CachedPlayer.position, ascending: true),
                NSSortDescriptor(keyPath: \CachedPlayer.displayName, ascending: true)
            ]
            
            let cachedPlayers = try self.backgroundContext.fetch(request)
            return cachedPlayers.compactMap { self.convertToPlayer($0) }
        }
    }
    
    // MARK: - Team Operations
    
    func cacheTeam(_ team: Team) async throws {
        try await backgroundContext.perform {
            let request: NSFetchRequest<CachedTeam> = CachedTeam.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@ AND userID == %@", 
                                          team.id, team.userID)
            
            let cachedTeam: CachedTeam
            if let existingTeam = try? self.backgroundContext.fetch(request).first {
                cachedTeam = existingTeam
            } else {
                cachedTeam = CachedTeam(context: self.backgroundContext)
                cachedTeam.id = team.id
                cachedTeam.userID = team.userID
            }
            
            // Update team data
            self.updateCachedTeam(cachedTeam, with: team)
            cachedTeam.lastUpdated = Date()
        }
        
        try await saveBackground()
    }
    
    func getCachedTeam(for userID: String, round: Int) async throws -> Team? {
        return try await backgroundContext.perform {
            let request: NSFetchRequest<CachedTeam> = CachedTeam.fetchRequest()
            request.predicate = NSPredicate(format: "userID == %@ AND round == %d", 
                                          userID, round)
            request.fetchLimit = 1
            
            guard let cachedTeam = try self.backgroundContext.fetch(request).first else {
                return nil
            }
            
            return self.convertToTeam(cachedTeam)
        }
    }
    
    // MARK: - Live Match Operations
    
    func cacheLiveMatches(_ matches: [LiveMatch]) async throws {
        try await backgroundContext.perform {
            // Clear existing live matches first
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: LiveMatch.fetchRequest())
            try? self.backgroundContext.execute(deleteRequest)
            
            // Cache new matches
            for match in matches {
                let cachedMatch = LiveMatch(context: self.backgroundContext)
                self.updateCachedLiveMatch(cachedMatch, with: match)
                cachedMatch.lastUpdated = Date()
            }
        }
        
        try await saveBackground()
    }
    
    func getCachedLiveMatches() async throws -> [LiveMatch] {
        return try await backgroundContext.perform {
            let request: NSFetchRequest<LiveMatch> = LiveMatch.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \LiveMatch.startTime, ascending: true)
            ]
            
            return try self.backgroundContext.fetch(request)
        }
    }
    
    // MARK: - Cache Management
    
    func clearExpiredCache() async throws {
        try await backgroundContext.perform {
            let now = Date()
            
            // Clear old cached players (older than 7 days)
            let playerRequest: NSFetchRequest<CachedPlayer> = CachedPlayer.fetchRequest()
            if let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now) {
                playerRequest.predicate = NSPredicate(format: "lastUpdated < %@", sevenDaysAgo as NSDate)
                let oldPlayers = try self.backgroundContext.fetch(playerRequest)
                for player in oldPlayers {
                    self.backgroundContext.delete(player)
                }
            }
            
            // Clear old live matches (older than 1 day)
            let matchRequest: NSFetchRequest<LiveMatch> = LiveMatch.fetchRequest()
            if let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: now) {
                matchRequest.predicate = NSPredicate(format: "lastUpdated < %@", oneDayAgo as NSDate)
                let oldMatches = try self.backgroundContext.fetch(matchRequest)
                for match in oldMatches {
                    self.backgroundContext.delete(match)
                }
            }
            
            // Clear expired metadata
            let metadataRequest: NSFetchRequest<CacheMetadata> = CacheMetadata.fetchRequest()
            metadataRequest.predicate = NSPredicate(format: "expiresAt < %@", now as NSDate)
            let expiredMetadata = try self.backgroundContext.fetch(metadataRequest)
            for metadata in expiredMetadata {
                self.backgroundContext.delete(metadata)
            }
        }
        
        try await saveBackground()
        await updateCacheSize()
        
        await MainActor.run {
            self.lastCacheClean = Date()
        }
        
        print("🧹 Cleared expired cache entries")
    }
    
    func clearAllCache() async throws {
        try await backgroundContext.perform {
            // Delete all cached entities except user sessions
            let entities = ["CachedPlayer", "CachedTeam", "LiveMatch", "CacheMetadata", "PlayerStats"]
            
            for entityName in entities {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                try? self.backgroundContext.execute(deleteRequest)
            }
        }
        
        try await saveBackground()
        await updateCacheSize()
        
        print("🧹 Cleared all cache")
    }
    
    func calculateCacheSize() async -> Int64 {
        return await backgroundContext.perform {
            var totalSize: Int64 = 0
            
            let entities = ["CachedPlayer", "CachedTeam", "LiveMatch", "CacheMetadata", "PlayerStats"]
            
            for entityName in entities {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                if let count = try? self.backgroundContext.count(for: request) {
                    // Rough estimate: 1KB per entity
                    totalSize += Int64(count * 1024)
                }
            }
            
            return totalSize
        }
    }
    
    // MARK: - User Session Operations
    
    func cacheUserSession(_ session: UserSession) async throws {
        try await backgroundContext.perform {
            // Clear existing sessions for this user
            let request: NSFetchRequest<UserSession> = UserSession.fetchRequest()
            request.predicate = NSPredicate(format: "userID == %@", session.userID ?? "")
            
            let existingSessions = try? self.backgroundContext.fetch(request)
            existingSessions?.forEach { self.backgroundContext.delete($0) }
            
            // Create new session
            let cachedSession = UserSession(context: self.backgroundContext)
            cachedSession.userID = session.userID
            cachedSession.username = session.username
            cachedSession.token = session.token
            cachedSession.refreshToken = session.refreshToken
            cachedSession.expiresAt = session.expiresAt
            cachedSession.lastLoginAt = Date()
        }
        
        try await saveBackground()
    }
    
    func getCachedUserSession(for userID: String) async throws -> UserSession? {
        return try await backgroundContext.perform {
            let request: NSFetchRequest<UserSession> = UserSession.fetchRequest()
            request.predicate = NSPredicate(format: "userID == %@", userID)
            request.fetchLimit = 1
            
            return try self.backgroundContext.fetch(request).first
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func updateCachedPlayer(_ cached: CachedPlayer, with player: Player) {
        cached.displayName = player.displayName
        cached.firstName = player.firstName
        cached.lastName = player.lastName
        cached.position = player.position.rawValue
        cached.currentPrice = player.currentPrice
        cached.averageScore = player.averageScore
        cached.liveScore = Int32(player.liveScore)
        cached.totalScore = Int32(player.totalScore)
        cached.captainScore = Int32(player.captainScore)
        cached.projectedScore = player.projectedScore
        cached.priceChange = player.priceChange
        cached.playingStatus = player.playingStatus.rawValue
        cached.injuryStatus = player.injuryStatus.rawValue
        cached.isAvailable = player.isAvailable
        cached.isCaptain = player.isCaptain
        cached.isViceCaptain = player.isViceCaptain
        cached.isEmergency = player.isEmergency
        cached.photoURL = player.photoURL
    }
    
    private func updateCachedTeam(_ cached: CachedTeam, with team: Team) {
        cached.name = team.name
        cached.fullName = team.fullName
        cached.abbreviation = team.abbreviation
        cached.totalScore = Int32(team.totalScore)
        cached.trades = Int32(team.trades)
        cached.captainID = team.captainID
        cached.viceCaptainID = team.viceCaptainID
        cached.round = Int32(team.round)
        cached.logoURL = team.logoURL
        cached.primaryColor = team.primaryColor
        cached.secondaryColor = team.secondaryColor
    }
    
    private func updateCachedLiveMatch(_ cached: LiveMatch, with match: LiveMatch) {
        cached.id = match.id
        cached.homeTeamName = match.homeTeamName
        cached.awayTeamName = match.awayTeamName
        cached.homeTeamID = match.homeTeamID
        cached.awayTeamID = match.awayTeamID
        cached.homeScore = Int32(match.homeScore)
        cached.awayScore = Int32(match.awayScore)
        cached.startTime = match.startTime
        cached.status = match.status
        cached.quarter = match.quarter
        cached.timeRemaining = match.timeRemaining
        cached.venue = match.venue
        cached.round = Int32(match.round)
        cached.isLive = match.isLive
    }
    
    private func convertToPlayer(_ cached: CachedPlayer) -> Player? {
        guard let id = cached.id,
              let displayName = cached.displayName,
              let positionString = cached.position,
              let position = Player.Position(rawValue: positionString),
              let statusString = cached.playingStatus,
              let playingStatus = Player.PlayingStatus(rawValue: statusString),
              let injuryString = cached.injuryStatus,
              let injuryStatus = Player.InjuryStatus(rawValue: injuryString) else {
            return nil
        }
        
        return Player(
            id: id,
            firstName: cached.firstName ?? "",
            lastName: cached.lastName ?? "",
            displayName: displayName,
            position: position,
            currentPrice: cached.currentPrice,
            averageScore: cached.averageScore,
            liveScore: Int(cached.liveScore),
            totalScore: Int(cached.totalScore),
            captainScore: Int(cached.captainScore),
            projectedScore: cached.projectedScore,
            priceChange: cached.priceChange,
            playingStatus: playingStatus,
            injuryStatus: injuryStatus,
            isAvailable: cached.isAvailable,
            isCaptain: cached.isCaptain,
            isViceCaptain: cached.isViceCaptain,
            isEmergency: cached.isEmergency,
            photoURL: cached.photoURL
        )
    }
    
    private func convertToTeam(_ cached: CachedTeam) -> Team? {
        guard let id = cached.id,
              let name = cached.name,
              let userID = cached.userID else {
            return nil
        }
        
        return Team(
            id: id,
            userID: userID,
            name: name,
            fullName: cached.fullName ?? name,
            abbreviation: cached.abbreviation ?? "",
            totalScore: Int(cached.totalScore),
            trades: Int(cached.trades),
            captainID: cached.captainID,
            viceCaptainID: cached.viceCaptainID,
            round: Int(cached.round),
            logoURL: cached.logoURL,
            primaryColor: cached.primaryColor ?? "#000000",
            secondaryColor: cached.secondaryColor ?? "#FFFFFF"
        )
    }
    
    private func setupCacheMonitoring() {
        // Update cache size periodically
        Timer.publish(every: 300, on: .main, in: .common) // Every 5 minutes
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.updateCacheSize()
                }
            }
            .store(in: &cancellables)
        
        // Initial cache size calculation
        Task {
            await updateCacheSize()
        }
    }
    
    @MainActor
    private func updateCacheSize() async {
        cacheSize = await calculateCacheSize()
    }
}

// MARK: - Extensions for Fetch Requests

extension CachedPlayer {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedPlayer> {
        return NSFetchRequest<CachedPlayer>(entityName: "CachedPlayer")
    }
}

extension CachedTeam {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedTeam> {
        return NSFetchRequest<CachedTeam>(entityName: "CachedTeam")
    }
}

extension LiveMatch {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LiveMatch> {
        return NSFetchRequest<LiveMatch>(entityName: "LiveMatch")
    }
}

extension UserSession {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserSession> {
        return NSFetchRequest<UserSession>(entityName: "UserSession")
    }
}

extension CacheMetadata {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CacheMetadata> {
        return NSFetchRequest<CacheMetadata>(entityName: "CacheMetadata")
    }
}

extension PlayerStats {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayerStats> {
        return NSFetchRequest<PlayerStats>(entityName: "PlayerStats")
    }
}
