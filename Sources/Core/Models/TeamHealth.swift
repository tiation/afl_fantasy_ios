import Foundation

// MARK: - TeamHealth Models

@available(iOS 13.0, *)
struct TeamHealth: Codable {
    let bankBalance: Int
    let tradesRemaining: Int
    let captainSet: Bool
    let viceCaptainSet: Bool
    let nextRoundDeadline: Date
    let injuredPlayers: [InjuredPlayer]
    let suspendedPlayers: [SuspendedPlayer]
    let teamValue: Int
    let currentScore: Int
    let rank: Int
    
    init() {
        self.bankBalance = 150000 // $150K
        self.tradesRemaining = 15
        self.captainSet = true
        self.viceCaptainSet = true
        self.nextRoundDeadline = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        self.injuredPlayers = []
        self.suspendedPlayers = []
        self.teamValue = 12500000 // $12.5M
        self.currentScore = 2134
        self.rank = 47291
    }
    
    init(bankBalance: Int, tradesRemaining: Int, captainSet: Bool, viceCaptainSet: Bool, nextRoundDeadline: Date, injuredPlayers: [InjuredPlayer], suspendedPlayers: [SuspendedPlayer], teamValue: Int, currentScore: Int, rank: Int) {
        self.bankBalance = bankBalance
        self.tradesRemaining = tradesRemaining
        self.captainSet = captainSet
        self.viceCaptainSet = viceCaptainSet
        self.nextRoundDeadline = nextRoundDeadline
        self.injuredPlayers = injuredPlayers
        self.suspendedPlayers = suspendedPlayers
        self.teamValue = teamValue
        self.currentScore = currentScore
        self.rank = rank
    }
    
    // MARK: - Computed Properties
    
    var hasInjuries: Bool {
        !injuredPlayers.isEmpty
    }
    
    var hasSuspensions: Bool {
        !suspendedPlayers.isEmpty
    }
    
    var hasAlerts: Bool {
        hasInjuries || hasSuspensions
    }
    
    var alertCount: Int {
        injuredPlayers.count + suspendedPlayers.count
    }
    
    var timeToDeadline: TimeInterval {
        nextRoundDeadline.timeIntervalSinceNow
    }
    
    var isDeadlineClose: Bool {
        timeToDeadline < 24 * 60 * 60 // Less than 24 hours
    }
    
    var deadlineString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: nextRoundDeadline, relativeTo: Date())
    }
}

struct InjuredPlayer: Codable, Identifiable {
    let id: String
    let name: String
    let position: String
    let team: String
    let injuryType: String
    let expectedReturn: String // e.g., "1-2 weeks", "Test"
    
    init(id: String, name: String, position: String, team: String, injuryType: String, expectedReturn: String) {
        self.id = id
        self.name = name
        self.position = position
        self.team = team
        self.injuryType = injuryType
        self.expectedReturn = expectedReturn
    }
}

struct SuspendedPlayer: Codable, Identifiable {
    let id: String
    let name: String
    let position: String
    let team: String
    let reason: String
    let weeksRemaining: Int
    
    init(id: String, name: String, position: String, team: String, reason: String, weeksRemaining: Int) {
        self.id = id
        self.name = name
        self.position = position
        self.team = team
        self.reason = reason
        self.weeksRemaining = weeksRemaining
    }
}

// MARK: - Mock Data

extension TeamHealth {
    static let mock = TeamHealth()
    
    static let mockWithIssues = TeamHealth(
        bankBalance: 75000,
        tradesRemaining: 8,
        captainSet: false,
        viceCaptainSet: true,
        nextRoundDeadline: Calendar.current.date(byAdding: .hour, value: 18, to: Date()) ?? Date(),
        injuredPlayers: [
            InjuredPlayer(
                id: "player1",
                name: "Max Gawn",
                position: "RUC",
                team: "MEL",
                injuryType: "Ankle",
                expectedReturn: "Test"
            )
        ],
        suspendedPlayers: [
            SuspendedPlayer(
                id: "player2",
                name: "Toby Greene",
                position: "FWD",
                team: "GWS",
                reason: "Striking",
                weeksRemaining: 2
            )
        ],
        teamValue: 12300000,
        currentScore: 1876,
        rank: 89432
    )
}
