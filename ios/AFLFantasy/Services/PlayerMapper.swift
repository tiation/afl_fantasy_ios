import CoreData
import Foundation

// MARK: - PlayerMapper

/// Centralized service for converting between different Player model types
enum PlayerMapper {
    // MARK: - API to CoreData

    /// Maps API Player to CoreData Player entity
    static func mapToEntity(
        from apiPlayer: OpenAPIClient.Player,
        context: NSManagedObjectContext
    ) -> Player {
        let entity = Player(context: context)
        entity.update(from: apiPlayer)
        return entity
    }

    /// Updates existing CoreData Player with API data
    static func updateEntity(
        _ entity: Player,
        from apiPlayer: OpenAPIClient.Player
    ) {
        entity.update(from: apiPlayer)
    }

    // MARK: - CoreData to View Models

    /// Maps CoreData Player to PlayerViewModel
    static func mapToViewModel(from entity: Player) -> PlayerViewModel {
        PlayerViewModel(from: entity)
    }

    /// Maps CoreData Player to PlayerModel
    static func mapToModel(from entity: Player) -> PlayerModel {
        PlayerModel(from: entity)
    }

    /// Maps CoreData Player to EnhancedPlayer
    static func mapToEnhanced(from entity: Player) -> EnhancedPlayer {
        EnhancedPlayer(
            name: entity.name,
            position: PlayerPosition(from: entity.position) ?? .midfielder,
            currentPrice: Int(entity.price),
            currentScore: Int(entity.currentScore),
            averageScore: entity.averageScore,
            breakeven: Int(entity.breakeven),
            consistency: entity.consistency,
            injuryRiskScore: entity.injuryRisk?.riskScore ?? 0,
            priceChange: Int(entity.priceChange),
            cashGenerated: calculateCashGenerated(from: entity),
            isCashCow: entity.isCashCow,
            teamAbbreviation: entity.team,
            projectedScore: entity.nextRoundProjection?.projectedScore ?? 0,
            opponent: entity.nextRoundProjection?.opponent ?? "TBD",
            venue: entity.nextRoundProjection?.venue ?? "TBD",
            rainProbability: entity.nextRoundProjection?.rainProbability ?? 0,
            venueBias: entity.nextRoundProjection?.venueBias ?? 0,
            isDoubtful: entity.isDoubtful,
            contractYear: false, // TODO: Add to CoreData if needed
            gamesPlayed: Int(entity.gamesPlayed)
        )
    }

    // MARK: - View Models to CoreData

    /// Updates CoreData Player from PlayerViewModel
    static func updateEntity(
        _ entity: Player,
        from viewModel: PlayerViewModel
    ) {
        entity.update(from: viewModel)
    }

    // MARK: - Batch Operations

    /// Maps array of API Players to array of PlayerViewModels
    static func mapToViewModels(
        from apiPlayers: [OpenAPIClient.Player],
        context: NSManagedObjectContext
    ) -> [PlayerViewModel] {
        apiPlayers.compactMap { apiPlayer in
            let entity = mapToEntity(from: apiPlayer, context: context)
            return mapToViewModel(from: entity)
        }
    }

    /// Maps array of CoreData Players to array of PlayerViewModels
    static func mapToViewModels(from entities: [Player]) -> [PlayerViewModel] {
        entities.map(mapToViewModel)
    }

    // MARK: - Validation

    /// Validates that a Player entity has required fields
    static func validate(_ entity: Player) -> ValidationResult {
        var errors: [String] = []

        if entity.id.isEmpty {
            errors.append("Player ID is required")
        }

        if entity.name.isEmpty {
            errors.append("Player name is required")
        }

        if entity.team.isEmpty {
            errors.append("Player team is required")
        }

        if PlayerPosition(from: entity.position) == nil {
            errors.append("Valid position is required")
        }

        if entity.price <= 0 {
            errors.append("Player price must be greater than 0")
        }

        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }

    // MARK: - Helper Methods

    private static func calculateCashGenerated(from entity: Player) -> Int {
        // Simple cash generation calculation
        // In reality, this would be more complex
        max(0, Int(entity.price) - Int(entity.breakeven))
    }
}

// MARK: - ValidationResult

struct ValidationResult {
    let isValid: Bool
    let errors: [String]

    var errorMessage: String {
        errors.joined(separator: ", ")
    }
}

// MARK: - PlayerMappingError

enum PlayerMappingError: LocalizedError {
    case invalidAPIData(String)
    case missingRequiredField(String)
    case conversionFailed(String)

    var errorDescription: String? {
        switch self {
        case let .invalidAPIData(message):
            "Invalid API data: \(message)"
        case let .missingRequiredField(field):
            "Missing required field: \(field)"
        case let .conversionFailed(message):
            "Conversion failed: \(message)"
        }
    }
}
