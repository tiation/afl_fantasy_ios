import Foundation

// MARK: - Mock Data Extensions

// MARK: - Mock Data for Player Extensions
// Note: Using mockPlayers from Models.swift to avoid duplication

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
