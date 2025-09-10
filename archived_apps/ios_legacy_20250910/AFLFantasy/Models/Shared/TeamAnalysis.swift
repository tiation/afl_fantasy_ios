import Foundation

/// TeamAnalysis provides detailed statistics and recommendations for fantasy teams.
/// This is used by the analysis service to help users optimize their teams.
public struct TeamAnalysis: Codable, Hashable {
    // MARK: - Price Change Model

    public struct PriceChange: Codable, Hashable {
        public let value: Double
        public let percentage: Double
        public let startingPrice: Double

        public init(value: Double, percentage: Double, startingPrice: Double) {
            self.value = value
            self.percentage = percentage
            self.startingPrice = startingPrice
        }

        /// Returns a formatted string representation of the price change.
        public var formattedValue: String {
            let sign = value >= 0 ? "+" : ""
            return "\(sign)$\(String(format: "%.1f", value))k"
        }

        /// Returns a formatted percentage with sign.
        public var formattedPercentage: String {
            let sign = percentage >= 0 ? "+" : ""
            return "\(sign)\(String(format: "%.1f", percentage))%"
        }
    }

    // MARK: - Position Analysis Model

    public struct PositionAnalysis: Codable, Hashable {
        public let position: Position
        public let averageAge: Double
        public let averageValue: Double
        public let totalScore: Int
        public let averageScore: Double
        public let priceChange: PriceChange
        public let potentialUpgrades: [Player]

        public init(
            position: Position,
            averageAge: Double,
            averageValue: Double,
            totalScore: Int,
            averageScore: Double,
            priceChange: PriceChange,
            potentialUpgrades: [Player]
        ) {
            self.position = position
            self.averageAge = averageAge
            self.averageValue = averageValue
            self.totalScore = totalScore
            self.averageScore = averageScore
            self.priceChange = priceChange
            self.potentialUpgrades = potentialUpgrades
        }

        /// Returns a summary string for this position group.
        public var summary: String {
            """
            \(position.displayName)s:
            Avg Score: \(String(format: "%.1f", averageScore))
            Avg Value: $\(String(format: "%.0f", averageValue))k
            Value Change: \(priceChange.formattedValue)
            """
        }
    }

    // MARK: - Properties

    public let startingValue: Double
    public let currentValue: Double
    public let valueChange: PriceChange
    public let bestPlayers: [Player]
    public let worstPlayers: [Player]
    public let cashCows: [Player]
    public let injuredPlayers: [Player]
    public let positionAnalysis: [PositionAnalysis]
    public let recommendations: [String]
    public let insights: [String]

    // MARK: - Initializer

    public init(
        startingValue: Double,
        currentValue: Double,
        valueChange: PriceChange,
        bestPlayers: [Player],
        worstPlayers: [Player],
        cashCows: [Player],
        injuredPlayers: [Player],
        positionAnalysis: [PositionAnalysis],
        recommendations: [String],
        insights: [String]
    ) {
        self.startingValue = startingValue
        self.currentValue = currentValue
        self.valueChange = valueChange
        self.bestPlayers = bestPlayers
        self.worstPlayers = worstPlayers
        self.cashCows = cashCows
        self.injuredPlayers = injuredPlayers
        self.positionAnalysis = positionAnalysis
        self.recommendations = recommendations
        self.insights = insights
    }

    // MARK: - Computed Properties

    /// Returns overall value change as a percentage.
    public var overallValueChangePercentage: Double {
        ((currentValue - startingValue) / startingValue) * 100.0
    }

    /// Returns formatted total value.
    public var formattedValue: String {
        "$\(String(format: "%.0f", currentValue))k"
    }

    /// Returns a summary of key stats.
    public var summary: String {
        """
        Team Value: \(formattedValue)
        Change: \(valueChange.formattedValue) (\(valueChange.formattedPercentage))
        Cash Cows: \(cashCows.count)
        Injured: \(injuredPlayers.count)
        """
    }
}
