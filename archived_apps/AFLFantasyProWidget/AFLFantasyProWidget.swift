//
//  AFLFantasyProWidget.swift
//  AFL Fantasy Pro - Widget Extension
//
//  Main widget bundle containing live scores, team overview, and captain picks widgets.
//  Provides at-a-glance information on the home screen for fantasy coaches.
//

import WidgetKit
import SwiftUI

// MARK: - Widget Bundle

@main
struct AFLFantasyProWidgetBundle: WidgetBundle {
    var body: some Widget {
        LiveScoresWidget()
        TeamOverviewWidget()
        CaptainPicksWidget()
    }
}

// MARK: - Live Scores Widget

struct LiveScoresWidget: Widget {
    let kind: String = "LiveScoresWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LiveScoresTimelineProvider()) { entry in
            LiveScoresWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Live Scores")
        .description("Track live AFL match scores and your players' performance")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

// MARK: - Team Overview Widget

struct TeamOverviewWidget: Widget {
    let kind: String = "TeamOverviewWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TeamOverviewTimelineProvider()) { entry in
            TeamOverviewWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Team Overview")
        .description("View your fantasy team score and key player updates")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Captain Picks Widget

struct CaptainPicksWidget: Widget {
    let kind: String = "CaptainPicksWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CaptainPicksTimelineProvider()) { entry in
            CaptainPicksWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Captain Picks")
        .description("Get AI-powered captain recommendations for maximum points")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Timeline Entries

struct LiveScoresEntry: TimelineEntry {
    let date: Date
    let liveMatches: [WidgetLiveMatch]
    let isLoading: Bool
    let error: String?
    
    static let placeholder = LiveScoresEntry(
        date: Date(),
        liveMatches: [
            WidgetLiveMatch.sample1,
            WidgetLiveMatch.sample2
        ],
        isLoading: false,
        error: nil
    )
}

struct TeamOverviewEntry: TimelineEntry {
    let date: Date
    let team: WidgetTeam?
    let topPlayers: [WidgetPlayer]
    let isLoading: Bool
    let error: String?
    
    static let placeholder = TeamOverviewEntry(
        date: Date(),
        team: WidgetTeam.sample,
        topPlayers: [
            WidgetPlayer.sample1,
            WidgetPlayer.sample2,
            WidgetPlayer.sample3
        ],
        isLoading: false,
        error: nil
    )
}

struct CaptainPicksEntry: TimelineEntry {
    let date: Date
    let recommendations: [WidgetCaptainRecommendation]
    let currentCaptain: WidgetPlayer?
    let isLoading: Bool
    let error: String?
    
    static let placeholder = CaptainPicksEntry(
        date: Date(),
        recommendations: [
            WidgetCaptainRecommendation.sample1,
            WidgetCaptainRecommendation.sample2
        ],
        currentCaptain: WidgetPlayer.sample1,
        isLoading: false,
        error: nil
    )
}

// MARK: - Widget Data Models

struct WidgetLiveMatch: Identifiable {
    let id: String
    let homeTeam: String
    let awayTeam: String
    let homeScore: Int
    let awayScore: Int
    let status: String
    let quarter: String
    let isLive: Bool
    let timeRemaining: String?
    
    static let sample1 = WidgetLiveMatch(
        id: "match1",
        homeTeam: "Richmond",
        awayTeam: "Carlton",
        homeScore: 85,
        awayScore: 72,
        status: "Live",
        quarter: "Q3",
        isLive: true,
        timeRemaining: "12:45"
    )
    
    static let sample2 = WidgetLiveMatch(
        id: "match2",
        homeTeam: "Collingwood",
        awayTeam: "Essendon",
        homeScore: 98,
        awayScore: 101,
        status: "Final",
        quarter: "Q4",
        isLive: false,
        timeRemaining: nil
    )
}

struct WidgetTeam {
    let name: String
    let totalScore: Int
    let rank: Int?
    let tradesRemaining: Int
    let captain: String?
    let viceCaptain: String?
    
    static let sample = WidgetTeam(
        name: "My Team",
        totalScore: 1847,
        rank: 12543,
        tradesRemaining: 18,
        captain: "Marcus Bontempelli",
        viceCaptain: "Clayton Oliver"
    )
}

struct WidgetPlayer: Identifiable {
    let id: String
    let name: String
    let position: String
    let currentScore: Int
    let averageScore: Double
    let isPlaying: Bool
    let team: String?
    
    static let sample1 = WidgetPlayer(
        id: "player1",
        name: "Marcus Bontempelli",
        position: "MID",
        currentScore: 127,
        averageScore: 118.5,
        isPlaying: true,
        team: "WBD"
    )
    
    static let sample2 = WidgetPlayer(
        id: "player2",
        name: "Clayton Oliver",
        position: "MID",
        currentScore: 89,
        averageScore: 106.2,
        isPlaying: true,
        team: "MEL"
    )
    
    static let sample3 = WidgetPlayer(
        id: "player3",
        name: "Max Gawn",
        position: "RUC",
        currentScore: 95,
        averageScore: 92.8,
        isPlaying: true,
        team: "MEL"
    )
}

struct WidgetCaptainRecommendation: Identifiable {
    let id: String
    let player: WidgetPlayer
    let confidence: Double // 0.0 to 1.0
    let reason: String
    let projectedScore: Double
    
    static let sample1 = WidgetCaptainRecommendation(
        id: "rec1",
        player: WidgetPlayer.sample1,
        confidence: 0.92,
        reason: "Excellent form vs weak opposition",
        projectedScore: 125.0
    )
    
    static let sample2 = WidgetCaptainRecommendation(
        id: "rec2",
        player: WidgetPlayer.sample2,
        confidence: 0.87,
        reason: "High scoring matchup",
        projectedScore: 115.0
    )
}

// MARK: - Preview Support

#Preview("Live Scores Small", as: .systemSmall) {
    LiveScoresWidget()
} timeline: {
    LiveScoresEntry.placeholder
}

#Preview("Team Overview Medium", as: .systemMedium) {
    TeamOverviewWidget()
} timeline: {
    TeamOverviewEntry.placeholder
}

#Preview("Captain Picks Small", as: .systemSmall) {
    CaptainPicksWidget()
} timeline: {
    CaptainPicksEntry.placeholder
}
