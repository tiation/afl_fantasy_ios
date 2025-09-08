//
//  TimelineProviders.swift
//  AFL Fantasy Pro - Widget Timeline Providers
//
//  Timeline providers for fetching and updating widget data from shared app group.
//  Handles data refresh scheduling and error states.
//

import WidgetKit
import Foundation

// MARK: - Live Scores Timeline Provider

struct LiveScoresTimelineProvider: TimelineProvider {
    typealias Entry = LiveScoresEntry
    
    func placeholder(in context: Context) -> LiveScoresEntry {
        LiveScoresEntry.placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LiveScoresEntry) -> Void) {
        if context.isPreview {
            completion(LiveScoresEntry.placeholder)
        } else {
            fetchLiveScoresData { entry in
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LiveScoresEntry>) -> Void) {
        fetchLiveScoresData { entry in
            var timeline: Timeline<LiveScoresEntry>
            
            if entry.liveMatches.contains(where: { $0.isLive }) {
                // Live matches - update every 30 seconds
                let nextUpdate = Calendar.current.date(byAdding: .second, value: 30, to: Date()) ?? Date()
                timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            } else if !entry.liveMatches.isEmpty {
                // Games today but not live - update every 15 minutes
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
                timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            } else {
                // No games - update every hour
                let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
                timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            }
            
            completion(timeline)
        }
    }
    
    private func fetchLiveScoresData(completion: @escaping (LiveScoresEntry) -> Void) {
        let dataManager = WidgetDataManager.shared
        
        Task {
            do {
                let matches = try await dataManager.fetchLiveMatches()
                let entry = LiveScoresEntry(
                    date: Date(),
                    liveMatches: matches,
                    isLoading: false,
                    error: nil
                )
                completion(entry)
            } catch {
                let entry = LiveScoresEntry(
                    date: Date(),
                    liveMatches: [],
                    isLoading: false,
                    error: error.localizedDescription
                )
                completion(entry)
            }
        }
    }
}

// MARK: - Team Overview Timeline Provider

struct TeamOverviewTimelineProvider: TimelineProvider {
    typealias Entry = TeamOverviewEntry
    
    func placeholder(in context: Context) -> TeamOverviewEntry {
        TeamOverviewEntry.placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TeamOverviewEntry) -> Void) {
        if context.isPreview {
            completion(TeamOverviewEntry.placeholder)
        } else {
            fetchTeamOverviewData { entry in
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TeamOverviewEntry>) -> Void) {
        fetchTeamOverviewData { entry in
            // Update team data every 5 minutes during matches, hourly otherwise
            let hasLivePlayers = entry.topPlayers.contains { $0.isPlaying }
            let updateInterval = hasLivePlayers ? 5 : 60 // minutes
            
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: updateInterval, to: Date()) ?? Date()
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            
            completion(timeline)
        }
    }
    
    private func fetchTeamOverviewData(completion: @escaping (TeamOverviewEntry) -> Void) {
        let dataManager = WidgetDataManager.shared
        
        Task {
            do {
                let (team, players) = try await dataManager.fetchTeamOverview()
                let entry = TeamOverviewEntry(
                    date: Date(),
                    team: team,
                    topPlayers: players,
                    isLoading: false,
                    error: nil
                )
                completion(entry)
            } catch {
                let entry = TeamOverviewEntry(
                    date: Date(),
                    team: nil,
                    topPlayers: [],
                    isLoading: false,
                    error: error.localizedDescription
                )
                completion(entry)
            }
        }
    }
}

// MARK: - Captain Picks Timeline Provider

struct CaptainPicksTimelineProvider: TimelineProvider {
    typealias Entry = CaptainPicksEntry
    
    func placeholder(in context: Context) -> CaptainPicksEntry {
        CaptainPicksEntry.placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CaptainPicksEntry) -> Void) {
        if context.isPreview {
            completion(CaptainPicksEntry.placeholder)
        } else {
            fetchCaptainPicksData { entry in
                completion(entry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CaptainPicksEntry>) -> Void) {
        fetchCaptainPicksData { entry in
            // Update captain recommendations every 30 minutes
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            
            completion(timeline)
        }
    }
    
    private func fetchCaptainPicksData(completion: @escaping (CaptainPicksEntry) -> Void) {
        let dataManager = WidgetDataManager.shared
        
        Task {
            do {
                let (recommendations, currentCaptain) = try await dataManager.fetchCaptainRecommendations()
                let entry = CaptainPicksEntry(
                    date: Date(),
                    recommendations: recommendations,
                    currentCaptain: currentCaptain,
                    isLoading: false,
                    error: nil
                )
                completion(entry)
            } catch {
                let entry = CaptainPicksEntry(
                    date: Date(),
                    recommendations: [],
                    currentCaptain: nil,
                    isLoading: false,
                    error: error.localizedDescription
                )
                completion(entry)
            }
        }
    }
}

// MARK: - Widget Data Manager

class WidgetDataManager {
    static let shared = WidgetDataManager()
    private let userDefaults = UserDefaults(suiteName: "group.com.aflfantasypro.shared")
    
    private init() {}
    
    // MARK: - Live Matches
    
    func fetchLiveMatches() async throws -> [WidgetLiveMatch] {
        // In a real implementation, this would fetch from shared app group data
        // or make a limited network request if needed
        
        guard let data = userDefaults?.data(forKey: "cached_live_matches"),
              let matches = try? JSONDecoder().decode([WidgetLiveMatch].self, from: data) else {
            // Return sample data if no cached data available
            return [
                WidgetLiveMatch.sample1,
                WidgetLiveMatch.sample2
            ]
        }
        
        return matches
    }
    
    // MARK: - Team Overview
    
    func fetchTeamOverview() async throws -> (WidgetTeam?, [WidgetPlayer]) {
        // Fetch team data from shared app group
        var team: WidgetTeam?
        var players: [WidgetPlayer] = []
        
        if let teamData = userDefaults?.data(forKey: "cached_team"),
           let cachedTeam = try? JSONDecoder().decode(WidgetTeam.self, from: teamData) {
            team = cachedTeam
        }
        
        if let playersData = userDefaults?.data(forKey: "cached_top_players"),
           let cachedPlayers = try? JSONDecoder().decode([WidgetPlayer].self, from: playersData) {
            players = cachedPlayers
        }
        
        // Fallback to sample data
        if team == nil || players.isEmpty {
            team = WidgetTeam.sample
            players = [
                WidgetPlayer.sample1,
                WidgetPlayer.sample2,
                WidgetPlayer.sample3
            ]
        }
        
        return (team, players)
    }
    
    // MARK: - Captain Recommendations
    
    func fetchCaptainRecommendations() async throws -> ([WidgetCaptainRecommendation], WidgetPlayer?) {
        var recommendations: [WidgetCaptainRecommendation] = []
        var currentCaptain: WidgetPlayer?
        
        if let recData = userDefaults?.data(forKey: "cached_captain_recommendations"),
           let cachedRecs = try? JSONDecoder().decode([WidgetCaptainRecommendation].self, from: recData) {
            recommendations = cachedRecs
        }
        
        if let captainData = userDefaults?.data(forKey: "cached_current_captain"),
           let cachedCaptain = try? JSONDecoder().decode(WidgetPlayer.self, from: captainData) {
            currentCaptain = cachedCaptain
        }
        
        // Fallback to sample data
        if recommendations.isEmpty {
            recommendations = [
                WidgetCaptainRecommendation.sample1,
                WidgetCaptainRecommendation.sample2
            ]
        }
        
        if currentCaptain == nil {
            currentCaptain = WidgetPlayer.sample1
        }
        
        return (recommendations, currentCaptain)
    }
    
    // MARK: - Cache Management (called from main app)
    
    func cacheLiveMatches(_ matches: [WidgetLiveMatch]) {
        if let data = try? JSONEncoder().encode(matches) {
            userDefaults?.set(data, forKey: "cached_live_matches")
        }
    }
    
    func cacheTeam(_ team: WidgetTeam) {
        if let data = try? JSONEncoder().encode(team) {
            userDefaults?.set(data, forKey: "cached_team")
        }
    }
    
    func cacheTopPlayers(_ players: [WidgetPlayer]) {
        if let data = try? JSONEncoder().encode(players) {
            userDefaults?.set(data, forKey: "cached_top_players")
        }
    }
    
    func cacheCaptainRecommendations(_ recommendations: [WidgetCaptainRecommendation]) {
        if let data = try? JSONEncoder().encode(recommendations) {
            userDefaults?.set(data, forKey: "cached_captain_recommendations")
        }
    }
    
    func cacheCurrentCaptain(_ captain: WidgetPlayer) {
        if let data = try? JSONEncoder().encode(captain) {
            userDefaults?.set(data, forKey: "cached_current_captain")
        }
    }
}

// MARK: - Codable Conformance

extension WidgetLiveMatch: Codable {}
extension WidgetTeam: Codable {}
extension WidgetPlayer: Codable {}
extension WidgetCaptainRecommendation: Codable {}
