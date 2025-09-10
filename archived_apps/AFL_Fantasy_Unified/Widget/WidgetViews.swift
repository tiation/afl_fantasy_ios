//
//  WidgetViews.swift
//  AFL Fantasy Pro - Widget UI Views
//
//  SwiftUI views for displaying widget content including live scores,
//  team overview, and captain recommendations in various widget sizes.
//

import SwiftUI
import WidgetKit

// MARK: - Live Scores Widget View

struct LiveScoresWidgetView: View {
    let entry: LiveScoresEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.regularMaterial)
            
            if let error = entry.error {
                ErrorView(message: error)
            } else if entry.liveMatches.isEmpty {
                NoMatchesView()
            } else {
                switch family {
                case .systemSmall:
                    SmallLiveScoresView(matches: entry.liveMatches)
                case .systemMedium:
                    MediumLiveScoresView(matches: entry.liveMatches)
                case .systemLarge:
                    LargeLiveScoresView(matches: entry.liveMatches)
                default:
                    SmallLiveScoresView(matches: entry.liveMatches)
                }
            }
        }
        .widgetURL(URL(string: "aflfantasypro://live-scores"))
    }
}

struct SmallLiveScoresView: View {
    let matches: [WidgetLiveMatch]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Live Scores")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if let liveMatch = matches.first(where: { $0.isLive }) ?? matches.first {
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(liveMatch.homeTeam)
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(liveMatch.awayTeam)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.primary)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(liveMatch.homeScore)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("\(liveMatch.awayScore)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    HStack {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(liveMatch.isLive ? .red : .gray)
                                .frame(width: 6, height: 6)
                            
                            Text(liveMatch.status)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if liveMatch.isLive {
                            Text(liveMatch.quarter)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct MediumLiveScoresView: View {
    let matches: [WidgetLiveMatch]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Live Scores")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if matches.contains(where: { $0.isLive }) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.red)
                            .frame(width: 6, height: 6)
                        Text("LIVE")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                    }
                }
            }
            
            LazyVStack(spacing: 6) {
                ForEach(matches.prefix(3)) { match in
                    MatchRowView(match: match)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct LargeLiveScoresView: View {
    let matches: [WidgetLiveMatch]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Live Scores")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if matches.contains(where: { $0.isLive }) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                        Text("LIVE")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                    }
                }
            }
            
            LazyVStack(spacing: 8) {
                ForEach(matches.prefix(6)) { match in
                    ExpandedMatchRowView(match: match)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct MatchRowView: View {
    let match: WidgetLiveMatch
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(match.homeTeam)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(match.awayTeam)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.primary)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(match.homeScore)")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("\(match.awayScore)")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .foregroundColor(.primary)
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(match.quarter)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                if match.isLive, let timeRemaining = match.timeRemaining {
                    Text(timeRemaining)
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
            .frame(minWidth: 30)
        }
    }
}

struct ExpandedMatchRowView: View {
    let match: WidgetLiveMatch
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                Circle()
                    .fill(match.isLive ? .red : .gray)
                    .frame(width: 6, height: 6)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(match.homeTeam)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(match.awayTeam)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(match.homeScore)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text("\(match.awayScore)")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(match.quarter)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if match.isLive, let timeRemaining = match.timeRemaining {
                    Text(timeRemaining)
                        .font(.caption)
                        .foregroundColor(.red)
                } else {
                    Text(match.status)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(minWidth: 40)
        }
        .foregroundColor(.primary)
    }
}

// MARK: - Team Overview Widget View

struct TeamOverviewWidgetView: View {
    let entry: TeamOverviewEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.regularMaterial)
            
            if let error = entry.error {
                ErrorView(message: error)
            } else {
                switch family {
                case .systemSmall:
                    SmallTeamOverviewView(team: entry.team, players: entry.topPlayers)
                case .systemMedium:
                    MediumTeamOverviewView(team: entry.team, players: entry.topPlayers)
                default:
                    SmallTeamOverviewView(team: entry.team, players: entry.topPlayers)
                }
            }
        }
        .widgetURL(URL(string: "aflfantasypro://dashboard"))
    }
}

struct SmallTeamOverviewView: View {
    let team: WidgetTeam?
    let players: [WidgetPlayer]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My Team")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if let team = team {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Score:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(team.totalScore)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    if let rank = team.rank {
                        HStack {
                            Text("Rank:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("#\(rank)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    HStack {
                        Text("Trades:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(team.tradesRemaining)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct MediumTeamOverviewView: View {
    let team: WidgetTeam?
    let players: [WidgetPlayer]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("My Team")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let team = team {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(team.totalScore)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if let rank = team.rank {
                            Text("Rank #\(rank)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Text("Top Performers")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            LazyVStack(spacing: 4) {
                ForEach(players.prefix(3)) { player in
                    PlayerRowView(player: player)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct PlayerRowView: View {
    let player: WidgetPlayer
    
    var body: some View {
        HStack {
            Text(player.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(player.position)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.tint.opacity(0.2))
                .cornerRadius(4)
                .foregroundColor(.tint)
            
            Spacer()
            
            Text("\(player.currentScore)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Captain Picks Widget View

struct CaptainPicksWidgetView: View {
    let entry: CaptainPicksEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.regularMaterial)
            
            if let error = entry.error {
                ErrorView(message: error)
            } else {
                switch family {
                case .systemSmall:
                    SmallCaptainPicksView(
                        recommendations: entry.recommendations,
                        currentCaptain: entry.currentCaptain
                    )
                case .systemMedium:
                    MediumCaptainPicksView(
                        recommendations: entry.recommendations,
                        currentCaptain: entry.currentCaptain
                    )
                default:
                    SmallCaptainPicksView(
                        recommendations: entry.recommendations,
                        currentCaptain: entry.currentCaptain
                    )
                }
            }
        }
        .widgetURL(URL(string: "aflfantasypro://captain-picks"))
    }
}

struct SmallCaptainPicksView: View {
    let recommendations: [WidgetCaptainRecommendation]
    let currentCaptain: WidgetPlayer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Captain Pick")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if let topRec = recommendations.first {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(topRec.player.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(topRec.player.position)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.tint.opacity(0.2))
                            .cornerRadius(4)
                            .foregroundColor(.tint)
                    }
                    
                    HStack {
                        Text("Confidence:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        ConfidenceBarView(confidence: topRec.confidence, compact: true)
                    }
                    
                    Text(topRec.reason)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct MediumCaptainPicksView: View {
    let recommendations: [WidgetCaptainRecommendation]
    let currentCaptain: WidgetPlayer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Captain Picks")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let captain = currentCaptain {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Current")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(captain.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                }
            }
            
            Text("AI Recommendations")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            LazyVStack(spacing: 6) {
                ForEach(recommendations.prefix(2)) { rec in
                    CaptainRecommendationRowView(recommendation: rec)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct CaptainRecommendationRowView: View {
    let recommendation: WidgetCaptainRecommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(recommendation.player.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                Text(recommendation.player.position)
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(.tint.opacity(0.2))
                    .cornerRadius(3)
                    .foregroundColor(.tint)
            }
            
            HStack {
                ConfidenceBarView(confidence: recommendation.confidence, compact: false)
                
                Spacer()
                
                Text("\(Int(recommendation.projectedScore))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct ConfidenceBarView: View {
    let confidence: Double
    let compact: Bool
    
    var body: some View {
        HStack(spacing: compact ? 2 : 4) {
            ForEach(0..<5) { index in
                RoundedRectangle(cornerRadius: compact ? 1 : 2)
                    .fill(index < Int(confidence * 5) ? .tint : .tint.opacity(0.2))
                    .frame(width: compact ? 3 : 4, height: compact ? 8 : 12)
            }
        }
    }
}

// MARK: - Common Views

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding()
    }
}

struct NoMatchesView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "sportscourt")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("No Matches")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Check back during match days for live scores")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Preview Support

#Preview("Live Scores Small", as: .systemSmall) {
    AFLFantasyProWidgetBundle()
} timeline: {
    LiveScoresEntry.placeholder
}
