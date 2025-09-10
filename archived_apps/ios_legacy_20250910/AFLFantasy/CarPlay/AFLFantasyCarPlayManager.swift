import Foundation
import CarPlay
import SwiftUI

// MARK: - CarPlay Scene Delegate
@available(iOS 14.0, *)
class AFLFantasyCarPlaySceneDelegate: NSObject, CPTemplateApplicationSceneDelegate {
    var interfaceController: CPInterfaceController?
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        setupCarPlayInterface()
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }
    
    private func setupCarPlayInterface() {
        let rootTemplate = createRootTabBarTemplate()
        interfaceController?.setRootTemplate(rootTemplate, animated: true, completion: nil)
    }
    
    private func createRootTabBarTemplate() -> CPTabBarTemplate {
        let teamTab = CPListTemplate(title: "My Team", sections: [createTeamSection()])
        teamTab.tabImage = UIImage(systemName: "person.3.fill")
        teamTab.tabTitle = "Team"
        
        let scoresTab = CPListTemplate(title: "Scores", sections: [createScoresSection()])
        scoresTab.tabImage = UIImage(systemName: "chart.bar.fill")
        scoresTab.tabTitle = "Scores"
        
        let rankingsTab = CPListTemplate(title: "Rankings", sections: [createRankingsSection()])
        rankingsTab.tabImage = UIImage(systemName: "list.number")
        rankingsTab.tabTitle = "Rankings"
        
        return CPTabBarTemplate(templates: [teamTab, scoresTab, rankingsTab])
    }
    
    private func createTeamSection() -> CPListSection {
        let teamItems = [
            createTeamScoreItem(),
            createCaptainItem(),
            createViceCaptainItem(),
            createBenchPlayersItem()
        ]
        
        return CPListSection(items: teamItems, header: "Round 1 Team", sectionIndexTitle: nil)
    }
    
    private func createTeamScoreItem() -> CPListItem {
        let item = CPListItem(text: "Team Score", detailText: "1,247 points", image: UIImage(systemName: "star.circle.fill"))
        item.accessoryType = .disclosureIndicator
        item.handler = { [weak self] item, completion in
            self?.showTeamScoreDetails()
            completion()
        }
        return item
    }
    
    private func createCaptainItem() -> CPListItem {
        let item = CPListItem(text: "Captain", detailText: "P. Dangerfield • 89 pts", image: UIImage(systemName: "crown.fill"))
        item.accessoryType = .disclosureIndicator
        item.handler = { [weak self] item, completion in
            self?.showPlayerDetails(playerName: "Patrick Dangerfield", isCaptain: true)
            completion()
        }
        return item
    }
    
    private func createViceCaptainItem() -> CPListItem {
        let item = CPListItem(text: "Vice Captain", detailText: "L. Neale • 76 pts", image: UIImage(systemName: "shield.fill"))
        item.accessoryType = .disclosureIndicator
        item.handler = { [weak self] item, completion in
            self?.showPlayerDetails(playerName: "Lachie Neale", isCaptain: false)
            completion()
        }
        return item
    }
    
    private func createBenchPlayersItem() -> CPListItem {
        let item = CPListItem(text: "Bench Players", detailText: "3 emergency players", image: UIImage(systemName: "figure.stand"))
        item.accessoryType = .disclosureIndicator
        item.handler = { [weak self] item, completion in
            self?.showBenchPlayers()
            completion()
        }
        return item
    }
    
    private func createScoresSection() -> CPListSection {
        let scoresItems = [
            createCurrentRoundItem(),
            createTeamRankingItem(),
            createTopScorersItem(),
            createLeagueStandingsItem()
        ]
        
        return CPListSection(items: scoresItems, header: "Round 1 Scores", sectionIndexTitle: nil)
    }
    
    private func createCurrentRoundItem() -> CPListItem {
        let item = CPListItem(text: "Current Round", detailText: "Round 1 • In Progress", image: UIImage(systemName: "timer"))
        item.accessoryType = .disclosureIndicator
        item.handler = { [weak self] item, completion in
            self?.showCurrentRoundDetails()
            completion()
        }
        return item
    }
    
    private func createTeamRankingItem() -> CPListItem {
        let item = CPListItem(text: "Your Ranking", detailText: "#15,420 overall", image: UIImage(systemName: "trophy.fill"))
        item.accessoryType = .disclosureIndicator
        return item
    }
    
    private func createTopScorersItem() -> CPListItem {
        let item = CPListItem(text: "Top Scorers", detailText: "Round leaders", image: UIImage(systemName: "flame.fill"))
        item.accessoryType = .disclosureIndicator
        item.handler = { [weak self] item, completion in
            self?.showTopScorers()
            completion()
        }
        return item
    }
    
    private func createLeagueStandingsItem() -> CPListItem {
        let item = CPListItem(text: "League Standings", detailText: "Private leagues", image: UIImage(systemName: "list.bullet"))
        item.accessoryType = .disclosureIndicator
        item.handler = { [weak self] item, completion in
            self?.showLeagueStandings()
            completion()
        }
        return item
    }
    
    private func createRankingsSection() -> CPListSection {
        let rankingItems = [
            createOverallRankingItem(),
            createWeeklyRankingItem(),
            createLeagueRankingItem()
        ]
        
        return CPListSection(items: rankingItems, header: "Your Rankings", sectionIndexTitle: nil)
    }
    
    private func createOverallRankingItem() -> CPListItem {
        return CPListItem(text: "Overall Ranking", detailText: "#15,420 of 1.2M coaches", image: UIImage(systemName: "chart.line.uptrend.xyaxis"))
    }
    
    private func createWeeklyRankingItem() -> CPListItem {
        return CPListItem(text: "Weekly Ranking", detailText: "#8,542 this round", image: UIImage(systemName: "calendar.badge.clock"))
    }
    
    private func createLeagueRankingItem() -> CPListItem {
        return CPListItem(text: "League Ranking", detailText: "2nd in Friends League", image: UIImage(systemName: "person.2.fill"))
    }
    
    // MARK: - Detail Views
    private func showTeamScoreDetails() {
        let detailItems = [
            CPListItem(text: "Total Points", detailText: "1,247", image: UIImage(systemName: "sum")),
            CPListItem(text: "Captain Bonus", detailText: "+89 points", image: UIImage(systemName: "plus.circle")),
            CPListItem(text: "Bench Score", detailText: "145 points", image: UIImage(systemName: "person.crop.square")),
            CPListItem(text: "Trades Used", detailText: "0 of 2", image: UIImage(systemName: "arrow.triangle.2.circlepath"))
        ]
        
        let section = CPListSection(items: detailItems, header: "Score Breakdown", sectionIndexTitle: nil)
        let template = CPListTemplate(title: "Team Score", sections: [section])
        
        interfaceController?.pushTemplate(template, animated: true, completion: nil)
    }
    
    private func showPlayerDetails(playerName: String, isCaptain: Bool) {
        let detailItems = [
            CPListItem(text: "Points", detailText: isCaptain ? "89 (x2)" : "76", image: UIImage(systemName: "star.fill")),
            CPListItem(text: "Position", detailText: "MID", image: UIImage(systemName: "person.fill")),
            CPListItem(text: "Price", detailText: "$650,000", image: UIImage(systemName: "dollarsign.circle")),
            CPListItem(text: "Selected By", detailText: "67.8% of coaches", image: UIImage(systemName: "chart.pie"))
        ]
        
        let section = CPListSection(items: detailItems, header: playerName, sectionIndexTitle: nil)
        let template = CPListTemplate(title: playerName, sections: [section])
        
        interfaceController?.pushTemplate(template, animated: true, completion: nil)
    }
    
    private func showBenchPlayers() {
        let benchItems = [
            CPListItem(text: "E1: Sam Walsh", detailText: "45 points • MID", image: UIImage(systemName: "1.circle")),
            CPListItem(text: "E2: Toby Greene", detailText: "32 points • FWD", image: UIImage(systemName: "2.circle")),
            CPListItem(text: "E3: Jordan Dawson", detailText: "67 points • DEF", image: UIImage(systemName: "3.circle"))
        ]
        
        let section = CPListSection(items: benchItems, header: "Emergency Players", sectionIndexTitle: nil)
        let template = CPListTemplate(title: "Bench", sections: [section])
        
        interfaceController?.pushTemplate(template, animated: true, completion: nil)
    }
    
    private func showCurrentRoundDetails() {
        let roundItems = [
            CPListItem(text: "Games Completed", detailText: "3 of 9 games", image: UIImage(systemName: "checkmark.circle")),
            CPListItem(text: "Next Game", detailText: "Richmond vs Carlton", image: UIImage(systemName: "clock")),
            CPListItem(text: "Round Deadline", detailText: "Thursday 7:30 PM", image: UIImage(systemName: "exclamationmark.triangle")),
            CPListItem(text: "Trade Period", detailText: "Open", image: UIImage(systemName: "arrow.triangle.2.circlepath"))
        ]
        
        let section = CPListSection(items: roundItems, header: "Round 1 Status", sectionIndexTitle: nil)
        let template = CPListTemplate(title: "Round Details", sections: [section])
        
        interfaceController?.pushTemplate(template, animated: true, completion: nil)
    }
    
    private func showTopScorers() {
        let topScorerItems = [
            CPListItem(text: "1. Clayton Oliver", detailText: "156 points • Melbourne", image: UIImage(systemName: "1.circle.fill")),
            CPListItem(text: "2. Lachie Neale", detailText: "143 points • Brisbane", image: UIImage(systemName: "2.circle.fill")),
            CPListItem(text: "3. Patrick Cripps", detailText: "138 points • Carlton", image: UIImage(systemName: "3.circle.fill")),
            CPListItem(text: "4. Marcus Bontempelli", detailText: "135 points • W. Bulldogs", image: UIImage(systemName: "4.circle")),
            CPListItem(text: "5. Touk Miller", detailText: "131 points • Gold Coast", image: UIImage(systemName: "5.circle"))
        ]
        
        let section = CPListSection(items: topScorerItems, header: "Round 1 Top Scorers", sectionIndexTitle: nil)
        let template = CPListTemplate(title: "Top Scorers", sections: [section])
        
        interfaceController?.pushTemplate(template, animated: true, completion: nil)
    }
    
    private func showLeagueStandings() {
        let leagueItems = [
            CPListItem(text: "Friends League", detailText: "2nd place • 1,247 pts", image: UIImage(systemName: "person.3.fill")),
            CPListItem(text: "Work League", detailText: "5th place • 1,186 pts", image: UIImage(systemName: "building.2.fill")),
            CPListItem(text: "Family League", detailText: "1st place • 1,298 pts", image: UIImage(systemName: "house.fill"))
        ]
        
        let section = CPListSection(items: leagueItems, header: "Your Leagues", sectionIndexTitle: nil)
        let template = CPListTemplate(title: "Leagues", sections: [section])
        
        interfaceController?.pushTemplate(template, animated: true, completion: nil)
    }
}

// MARK: - CarPlay Voice Control Support
@available(iOS 14.0, *)
extension AFLFantasyCarPlaySceneDelegate {
    
    // Voice commands for CarPlay
    func setupVoiceCommands() {
        let voiceCommands = [
            "Show my team score",
            "Who is my captain",
            "Show league standings",
            "What's my ranking",
            "Show top scorers"
        ]
        
        // In a real implementation, you would register these with CarPlay voice recognition
        print("Voice commands available: \(voiceCommands)")
    }
    
    // Handle voice command responses
    func handleVoiceCommand(_ command: String) {
        switch command.lowercased() {
        case "show my team score":
            showTeamScoreDetails()
        case "who is my captain":
            showPlayerDetails(playerName: "Patrick Dangerfield", isCaptain: true)
        case "show league standings":
            showLeagueStandings()
        case "what's my ranking":
            // Show ranking summary in alert or information template
            break
        case "show top scorers":
            showTopScorers()
        default:
            break
        }
    }
}

// MARK: - CarPlay Safety Features
@available(iOS 14.0, *)
extension AFLFantasyCarPlaySceneDelegate {
    
    // Ensure CarPlay interface is safe for driving
    private func isSafeForDriving(template: CPTemplate) -> Bool {
        // Implement safety checks for CarPlay templates
        // - Limit text length
        // - Avoid complex interactions
        // - Use large, easy-to-read fonts
        // - Minimize driver distraction
        return true
    }
    
    // Create driving-optimized templates with minimal text
    private func createSafeCarPlayItem(title: String, subtitle: String, icon: UIImage?) -> CPListItem {
        let item = CPListItem(text: title, detailText: subtitle, image: icon)
        
        // Ensure accessibility for CarPlay
        item.accessibilityLabel = "\(title), \(subtitle)"
        
        return item
    }
}

// MARK: - CarPlay Data Integration
@available(iOS 14.0, *)
extension AFLFantasyCarPlaySceneDelegate {
    
    // Integrate with MasterDataService for real-time updates
    private func fetchCarPlayData() async -> CarPlayData {
        // This would integrate with the MasterDataService
        return CarPlayData(
            teamScore: 1247,
            ranking: 15420,
            captain: "P. Dangerfield",
            captainScore: 89,
            roundNumber: 1,
            gamesInProgress: 3,
            totalGames: 9
        )
    }
    
    // Update CarPlay interface when data changes
    private func updateCarPlayInterface() {
        Task {
            let data = await fetchCarPlayData()
            
            // Update the interface on the main thread
            await MainActor.run {
                // Refresh the current template with new data
                setupCarPlayInterface()
            }
        }
    }
}

// MARK: - CarPlay Data Model
struct CarPlayData {
    let teamScore: Int
    let ranking: Int
    let captain: String
    let captainScore: Int
    let roundNumber: Int
    let gamesInProgress: Int
    let totalGames: Int
}
