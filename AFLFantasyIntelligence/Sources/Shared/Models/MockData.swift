import Foundation

// MARK: - Mock Data Extensions

extension Player {
    static let mockPlayers = [
        Player(
            id: "1",
            name: "Marcus Bontempelli",
            team: "WB",
            position: .midfielder,
            price: 715_000,
            average: 118.5,
            projected: 125.0,
            breakeven: -15
        ),
        Player(
            id: "2",
            name: "Max Gawn",
            team: "MELB",
            position: .ruck,
            price: 652_000,
            average: 105.2,
            projected: 108.0,
            breakeven: -12
        ),
        Player(
            id: "3",
            name: "Nick Daicos",
            team: "COLL",
            position: .defender,
            price: 598_000,
            average: 98.7,
            projected: 102.0,
            breakeven: 8
        ),
        Player(
            id: "4",
            name: "Errol Gulden",
            team: "SYD",
            position: .midfielder,
            price: 587_000,
            average: 96.4,
            projected: 99.0,
            breakeven: 5
        ),
        Player(
            id: "5",
            name: "Zak Butters",
            team: "PA",
            position: .forward,
            price: 612_000,
            average: 101.3,
            projected: 104.0,
            breakeven: -8
        )
    ]
}

extension CashCowAnalysis {
    static let mockCashCows = [
        CashCowAnalysis(
            playerId: "rookie1",
            playerName: "Rookie Rising",
            currentPrice: 278_000,
            projectedPrice: 320_000,
            cashGenerated: 42000,
            recommendation: "HOLD",
            confidence: 0.85,
            fpAverage: 67.2,
            gamesPlayed: 8
        ),
        CashCowAnalysis(
            playerId: "rookie2",
            playerName: "Cash Generator",
            currentPrice: 312_000,
            projectedPrice: 365_000,
            cashGenerated: 53000,
            recommendation: "HOLD",
            confidence: 0.78,
            fpAverage: 71.8,
            gamesPlayed: 9
        )
    ]
}
