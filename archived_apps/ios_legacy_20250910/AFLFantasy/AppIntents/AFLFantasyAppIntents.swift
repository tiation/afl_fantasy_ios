import Foundation
import AppIntents
import SwiftUI

// MARK: - Fantasy Team App Intent
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct ViewFantasyTeamAppIntent: AppIntent {
    static var title: LocalizedStringResource = "View Fantasy Team"
    static var description = IntentDescription("View your AFL Fantasy team and current scores")
    static var searchKeywords: [String] = ["fantasy", "team", "afl", "scores", "players"]
    
    @Parameter(title: "Round Number", description: "Specific round to view", default: nil)
    var roundNumber: Int?
    
    static var parameterSummary: some ParameterSummary {
        Summary("View fantasy team \(\.$roundNumber)")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let currentRound = roundNumber ?? getCurrentRound()
        
        // This would typically fetch data through MasterDataService
        let teamScore = await fetchTeamScore(for: currentRound)
        let ranking = await fetchTeamRanking()
        
        return .result(
            dialog: IntentDialog("Your team scored \(teamScore) points this round and is ranked \(ranking)"),
            view: FantasyTeamIntentView(round: currentRound, score: teamScore, ranking: ranking)
        )
    }
    
    private func getCurrentRound() -> Int {
        // Logic to determine current AFL round
        return 1
    }
    
    private func fetchTeamScore(for round: Int) async -> Int {
        // Fetch team score from MasterDataService
        return 1250
    }
    
    private func fetchTeamRanking() async -> Int {
        // Fetch team ranking
        return 15420
    }
}

// MARK: - Captain Selection App Intent
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct SelectCaptainAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Select Captain"
    static var description = IntentDescription("Choose your team captain for the upcoming round")
    static var searchKeywords: [String] = ["captain", "select", "choose", "fantasy", "afl"]
    
    @Parameter(title: "Player Name", description: "Name of the player to make captain")
    var playerName: String?
    
    static var parameterSummary: some ParameterSummary {
        Summary("Make \(\.$playerName) captain")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        if let playerName = playerName {
            // Update captain selection through MasterDataService
            let success = await updateCaptain(playerName: playerName)
            
            if success {
                return .result(dialog: IntentDialog("\(playerName) has been selected as your captain!"))
            } else {
                throw $playerName.needsValueError("Player not found or cannot be selected as captain")
            }
        } else {
            // Show available captains
            let availableCaptains = await getAvailableCaptains()
            return .result(dialog: IntentDialog("Available captains: \(availableCaptains.joined(separator: ", "))"))
        }
    }
    
    private func updateCaptain(playerName: String) async -> Bool {
        // Update captain through MasterDataService
        return true
    }
    
    private func getAvailableCaptains() async -> [String] {
        // Fetch available captain options
        return ["Patrick Dangerfield", "Lachie Neale", "Marcus Bontempelli"]
    }
}

// MARK: - Player Lookup App Intent
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct LookupPlayerAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Player Stats"
    static var description = IntentDescription("Look up statistics and information for any AFL player")
    static var searchKeywords: [String] = ["player", "stats", "lookup", "search", "afl"]
    
    @Parameter(title: "Player Name", description: "Name of the player to look up")
    var playerName: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Show stats for \(\.$playerName)")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let playerStats = await fetchPlayerStats(playerName: playerName)
        
        if let stats = playerStats {
            return .result(
                dialog: IntentDialog("\(playerName): \(stats.totalPoints) points this season, averaging \(stats.averagePoints) per game"),
                view: PlayerStatsIntentView(stats: stats)
            )
        } else {
            throw $playerName.needsValueError("Player not found")
        }
    }
    
    private func fetchPlayerStats(playerName: String) async -> PlayerStats? {
        // Fetch player statistics from MasterDataService
        return PlayerStats(
            name: playerName,
            totalPoints: 1250,
            averagePoints: 89.3,
            gamesPlayed: 14,
            position: "MID"
        )
    }
}

// MARK: - Trade Suggestions App Intent
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct TradeSuggestionsAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Trade Suggestions"
    static var description = IntentDescription("Get AI-powered trade recommendations for your fantasy team")
    static var searchKeywords: [String] = ["trade", "suggestions", "recommendations", "ai", "fantasy"]
    
    @Parameter(title: "Budget Limit", description: "Maximum budget for trades", default: 100000)
    var budgetLimit: Int
    
    static var parameterSummary: some ParameterSummary {
        Summary("Get trade suggestions within \(\.$budgetLimit) budget")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let suggestions = await generateTradeSuggestions(budgetLimit: budgetLimit)
        
        return .result(
            dialog: IntentDialog("Found \(suggestions.count) trade suggestions within your budget"),
            view: TradeSuggestionsIntentView(suggestions: suggestions)
        )
    }
    
    private func generateTradeSuggestions(budgetLimit: Int) async -> [TradeSuggestion] {
        // Generate AI-powered trade suggestions
        return [
            TradeSuggestion(playerOut: "Player A", playerIn: "Player B", cost: 50000, projectedGain: 15.5),
            TradeSuggestion(playerOut: "Player C", playerIn: "Player D", cost: 75000, projectedGain: 22.3)
        ]
    }
}

// MARK: - Supporting Data Models
struct PlayerStats {
    let name: String
    let totalPoints: Int
    let averagePoints: Double
    let gamesPlayed: Int
    let position: String
}

struct TradeSuggestion {
    let playerOut: String
    let playerIn: String
    let cost: Int
    let projectedGain: Double
}

// MARK: - Intent Result Views
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct FantasyTeamIntentView: View {
    let round: Int
    let score: Int
    let ranking: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Round \(round) Team Summary")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(score)")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Overall Rank")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("#\(ranking)")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct PlayerStatsIntentView: View {
    let stats: PlayerStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(stats.name)
                .font(.headline)
            
            HStack {
                Text("\(stats.totalPoints) pts")
                    .font(.title3)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("Avg: \(stats.averagePoints, specifier: "%.1f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("\(stats.gamesPlayed) games • \(stats.position)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct TradeSuggestionsIntentView: View {
    let suggestions: [TradeSuggestion]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended Trades")
                .font(.headline)
            
            ForEach(suggestions.indices, id: \.self) { index in
                let suggestion = suggestions[index]
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Out: \(suggestion.playerOut)")
                            .font(.caption)
                        Spacer()
                        Text("In: \(suggestion.playerIn)")
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("Cost: $\(suggestion.cost)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("+\(suggestion.projectedGain, specifier: "%.1f") pts")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                .padding(.vertical, 4)
                
                if index < suggestions.count - 1 {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
