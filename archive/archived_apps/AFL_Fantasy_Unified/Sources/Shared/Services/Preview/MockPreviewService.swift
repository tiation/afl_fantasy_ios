import Foundation

// MARK: - Preview Dependencies

extension StatsService {
    static var preview: StatsService {
        let service = StatsService()
        // Add mock data here if needed
        return service
    }
}

extension SettingsService {
    static var preview: SettingsService {
        let service = SettingsService()
        // Add mock data here if needed
        return service
    }
}

extension UserService {
    static var preview: UserService {
        let service = UserService()
        // Add mock data here if needed
        return service
    }
}


extension AuthService {
    static var preview: AuthService {
        let service = AuthService()
        // Add mock data here if needed
        return service
    }
}

extension DataService {
    static var preview: DataService {
        let service = DataService()
        // Add mock data here if needed
        return service
    }
}

extension PlayerService {
    static var preview: PlayerService {
        let service = PlayerService()
        // Add mock data here if needed
        return service
    }
}

// MARK: - Mock Data

enum PreviewData {
    static var sampleNotifications: [AlertNotification] {
        [
            AlertNotification(
                id: "1",
                title: "Marcus Bontempelli Injured",
                message: "Bontempelli (knee) is expected to miss 1-2 weeks",
                type: .injury,
                timestamp: Date(),
                isRead: false,
                playerId: "player1",
                data: ["status": "Test", "return": "Round 15"]
            ),
            AlertNotification(
                id: "2",
                title: "Price Drop Alert",
                message: "Nick Daicos has dropped $32k in value",
                type: .priceChange,
                timestamp: Date().addingTimeInterval(-3600),
                isRead: true,
                playerId: "player2",
                data: ["magnitude": "-32000", "reason": "Poor form"]
            ),
            AlertNotification(
                id: "3",
                title: "Team Selection Update",
                message: "Sam Walsh named in extended squad",
                type: .selection,
                timestamp: Date().addingTimeInterval(-7200),
                isRead: false,
                playerId: "player3",
                data: ["status": "Extended Squad"]
            )
        ]
    }
    
    static var samplePlayers: [Player] {
        [
            Player(
                id: "1",
                name: "Marcus Bontempelli",
                team: "WB",
                position: .midfielder,
                price: 878000,
                average: 110.5,
                projected: 108.2,
                breakeven: 95,
                consistency: .a,
                priceChange: 32000,
                ownership: 0.35,
                injuryStatus: .healthy,
                venueStats: nil,
                formFactor: 1.15,
                dvpImpact: 0.05
            ),
            Player(
                id: "2",
                name: "Nick Daicos",
                team: "COLL",
                position: .defender,
                price: 650000,
                average: 95.2,
                projected: 92.8,
                breakeven: 120,
                consistency: .b,
                priceChange: -25000,
                ownership: 0.52,
                injuryStatus: .questionable,
                venueStats: nil,
                formFactor: 0.92,
                dvpImpact: -0.03
            ),
            Player(
                id: "3",
                name: "Max Gawn",
                team: "MELB",
                position: .ruck,
                price: 750000,
                average: 105.8,
                projected: 105.0,
                breakeven: 85,
                consistency: .a,
                priceChange: 0,
                ownership: 0.18,
                injuryStatus: .out,
                venueStats: nil,
                formFactor: 1.0,
                dvpImpact: 0.0
            )
        ]
    }
    
    static var sampleTeamStructure: TeamStructure {
        TeamStructure(
            totalValue: 12500000,
            bankBalance: 250000,
            positionBalance: [
                .defender: 6,
                .midfielder: 8,
                .ruck: 2,
                .forward: 6
            ],
            premiumCount: 8,
            midPriceCount: 6,
            rookieCount: 8
        )
    }
}

// MARK: - Preview Container

class PreviewContainer {
    static var shared = PreviewContainer()
    
    let statsService = StatsService.preview
    let settingsService = SettingsService.preview
    let userService = UserService.preview
    let authService = AuthService.preview
    let dataService = DataService.preview
    let playerService = PlayerService.preview
    
    private init() {}
}
