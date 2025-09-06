import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var players: [EnhancedPlayer] = []
    @Published var bankBalance: Int = 1_500_000
    @Published var selectedTab: Tab = .dashboard
    @Published var captainSuggestions: [CaptainSuggestion] = []
    // You can expand this class with more features as needed for the app.

    enum Tab: String, CaseIterable {
        case dashboard
        case captain
        case trades
        case cashCow
        case settings
    }

    init() {
        // Optionally populate with mock data for initial UI rendering
        players = [
            EnhancedPlayer(
                id: "1",
                name: "Sample Cash Cow",
                position: .midfielder,
                price: 410_000,
                currentScore: 82,
                averageScore: 78.5,
                breakeven: 45,
                consistency: 80.0,
                highScore: 99,
                lowScore: 55,
                priceChange: 30000,
                isCashCow: true,
                isDoubtful: false,
                isSuspended: false,
                cashGenerated: 100_000,
                projectedPeakPrice: 480_000,
                nextRoundProjection: RoundProjection(
                    round: 15,
                    opponent: "Richmond",
                    venue: "MCG",
                    projectedScore: 74.0,
                    confidence: 0.77,
                    conditions: WeatherConditions(
                        temperature: 16.0,
                        rainProbability: 0.20,
                        windSpeed: 10.0,
                        humidity: 55.0
                    )
                ),
                seasonProjection: SeasonProjection(
                    projectedTotalScore: 1560.0,
                    projectedAverage: 78.0,
                    premiumPotential: 0.65
                ),
                injuryRisk: InjuryRisk(
                    riskLevel: .low,
                    riskScore: 12.0,
                    riskFactors: []
                ),
                venuePerformance: [],
                alertFlags: []
            )
        ]
        captainSuggestions = []
    }
}
