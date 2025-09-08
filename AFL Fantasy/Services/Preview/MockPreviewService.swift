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

extension LineService {
    static var preview: LineService {
        let service = LineService()
        // Add mock data here if needed
        return service
    }
}

extension TeamService {
    static var preview: TeamService {
        let service = TeamService()
        // Add mock data here if needed
        return service
    }
}

extension TradeService {
    static var preview: TradeService {
        let service = TradeService()
        // Add mock data here if needed
        return service
    }
}

extension OptimizationService {
    static var preview: OptimizationService {
        let service = OptimizationService()
        // Add mock data here if needed
        return service
    }
}

extension NotificationDataService {
    static var preview: NotificationDataService {
        let service = NotificationDataService()
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
            .init(
                id: "1",
                type: .injury,
                title: "Marcus Bontempelli Injured",
                message: "Bontempelli (knee) is expected to miss 1-2 weeks",
                timestamp: Date(),
                data: ["status": "Test", "return": "Round 15"],
                isRead: false
            ),
            .init(
                id: "2",
                type: .priceChange,
                title: "Price Drop Alert",
                message: "Nick Daicos has dropped $32k in value",
                timestamp: Date().addingTimeInterval(-3600),
                data: ["magnitude": "-32000", "reason": "Poor form"],
                isRead: true
            ),
            .init(
                id: "3",
                type: .selection,
                title: "Team Selection Update",
                message: "Sam Walsh named in extended squad",
                timestamp: Date().addingTimeInterval(-7200),
                data: ["status": "Extended Squad"],
                isRead: false
            )
        ]
    }
    
    static var samplePlayers: [Player] {
        [
            .init(
                id: "1",
                name: "Marcus Bontempelli",
                team: "WB",
                position: "MID",
                price: 878000,
                priceChange: 32000,
                breakEven: 95,
                average: 110.5,
                formTrend: 15,
                ownership: 0.35,
                ownershipTrend: 0.05,
                aiInsights: [
                    "Strong form trend (+15 avg)",
                    "Favorable upcoming fixtures"
                ]
            ),
            .init(
                id: "2",
                name: "Nick Daicos",
                team: "COLL",
                position: "DEF",
                price: 650000,
                priceChange: -25000,
                breakEven: 120,
                average: 95.2,
                formTrend: -8,
                ownership: 0.52,
                ownershipTrend: -0.03,
                injury: .test,
                aiInsights: [
                    "High break-even risk",
                    "Consider trading"
                ]
            ),
            .init(
                id: "3",
                name: "Max Gawn",
                team: "MELB",
                position: "RUC",
                price: 750000,
                priceChange: 0,
                breakEven: 85,
                average: 105.8,
                formTrend: 0,
                ownership: 0.18,
                ownershipTrend: 0,
                injury: .out(weeks: 2),
                aiInsights: [
                    "Strong value opportunity",
                    "Low ownership upside"
                ]
            )
        ]
    }
    
    static var sampleTeamStructure: TeamStructure {
        var structure = TeamStructure()
        structure.defenders = 6
        structure.midfielders = 8
        structure.rucks = 2
        structure.forwards = 6
        structure.premiums = 8
        structure.midPricers = 6
        structure.rookies = 8
        return structure
    }
    
    static var sampleAIRecommendations: [AIRecommendation] {
        [
            .init(
                rank: 1,
                playerName: "Marcus Bontempelli",
                reason: "Strong form + favorable matchup",
                confidence: 0.85,
                details: .init(value: "110.5", subValue: "AVG")
            ),
            .init(
                rank: 2,
                playerName: "Max Gawn",
                reason: "Consistent high scorer",
                confidence: 0.75,
                details: .init(value: "85", subValue: "B/E")
            ),
            .init(
                rank: 3,
                playerName: "Jack Macrae",
                reason: "Good historical vs opponent",
                confidence: 0.65,
                details: .init(value: "35%", subValue: "Owned")
            )
        ]
    }
    
    static var sampleOptimizationSuggestions: [OptimizationSuggestion] {
        [
            .init(
                type: .trade,
                title: "Trade Recommendation",
                description: "Upgrade midfield by trading out underperforming premium",
                impact: 15,
                impactType: "Proj. Points",
                changes: [
                    .init(from: "Josh Kelly", to: "Marcus Bontempelli")
                ],
                confidence: 0.85
            ),
            .init(
                type: .structure,
                title: "Structure Optimization",
                description: "Improve forward line by adding more premium players",
                impact: 25000,
                impactType: "Total Value",
                changes: [
                    .init(from: "Jeremy Cameron", to: "Charlie Curnow"),
                    .init(from: "Nick Larkey", to: "Harry McKay")
                ],
                confidence: 0.75
            ),
            .init(
                type: .captain,
                title: "Captain Strategy",
                description: "Optimize captain rotation based on fixtures",
                impact: 8,
                impactType: "Avg Points",
                changes: nil,
                confidence: 0.90
            )
        ]
    }
    
    static var sampleSalaryInfo: SalaryInfo {
        .init(
            totalSalary: 12500000,
            availableSalary: 250000,
            averagePlayerPrice: 568000,
            premiumPercentage: 0.35,
            rookiePercentage: 0.25
        )
    }
}

// MARK: - Preview Container

class PreviewContainer {
    static var shared = PreviewContainer()
    
    let statsService = StatsService.preview
    let settingsService = SettingsService.preview
    let userService = UserService.preview
    let lineService = LineService.preview
    let teamService = TeamService.preview
    let tradeService = TradeService.preview
    let optimizationService = OptimizationService.preview
    let notificationDataService = NotificationDataService.preview
    let authService = AuthService.preview
    let dataService = DataService.preview
    let playerService = PlayerService.preview
    
    private init() {}
}
