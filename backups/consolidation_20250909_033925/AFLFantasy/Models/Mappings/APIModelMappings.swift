import Foundation
#if canImport(OpenAPIClient)
    import OpenAPIClient

    // MARK: - API to Domain Mappings

    public extension OpenAPIClient.Player {
        /// Maps an API player model to the domain Player type.
        /// Use this when receiving data from the AFL API.
        func toDomainModel() -> Player {
            Player(
                id: UUID().uuidString, // Generate stable ID
                apiId: id,
                name: name,
                position: Position(rawValue: position.rawValue)!,
                teamId: -1, // TODO: Add team lookup
                teamName: team,
                teamAbbreviation: "", // TODO: Add lookup
                currentPrice: price,
                currentScore: lastScore ?? 0,
                averageScore: Double(avg),
                totalScore: 0, // Calculate from history
                breakeven: 0, // Calculate from price trend
                gamesPlayed: 0, // TODO: Add from stats
                consistency: 0, // Calculate from history
                ceiling: 0, // Calculate from history
                floor: 0, // Calculate from history
                volatility: 0, // Calculate from history
                ownership: Double(ownership ?? 0),
                lastScore: lastScore,
                startingPrice: 0, // Add from historical data
                priceChange: 0, // Calculate
                priceChangeProbability: 0, // Calculate from model
                cashGenerated: 0, // Calculate
                valueGain: 0, // Calculate
                isInjured: false, // Add from status
                isDoubtful: false, // Add from status
                isSuspended: false, // Add from status
                injuryRisk: .low, // Calculate from history
                contractStatus: "Active", // Default
                seasonalTrend: [], // Add from history
                nextRoundProjection: RoundProjection(score: 0, confidence: 0), // Add from prediction
                threeRoundProjection: [], // Add from prediction
                seasonProjection: SeasonProjection(), // Add from prediction
                venuePerformance: [], // Add from history
                opponentPerformance: [:], // Add from history
                isCaptainRecommended: false, // Calculate
                isTradeTarget: false, // Calculate
                isCashCow: false, // Calculate from price trend
                alertFlags: [] // Calculate from status
            )
        }
    }

    // MARK: - Domain to API Mappings

    public extension Player {
        /// Creates an API player model from the domain model.
        /// Use this when sending data to the AFL API.
        func toAPIModel() -> OpenAPIClient.Player {
            OpenAPIClient.Player(
                id: apiId,
                name: name,
                team: teamName,
                position: OpenAPIClient.Player.Position(rawValue: position.rawValue)!,
                price: currentPrice,
                avg: Float(averageScore),
                lastScore: lastScore,
                ownership: Float(ownership ?? 0)
            )
        }
    }
#endif
