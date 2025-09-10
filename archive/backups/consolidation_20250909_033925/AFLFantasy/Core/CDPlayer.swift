import CoreData
import Foundation

// MARK: - CDPlayer

@objc(CDPlayer)
public class CDPlayer: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var position: String
    @NSManaged public var currentPrice: Int32
    @NSManaged public var currentScore: Int32
    @NSManaged public var averageScore: Double
    @NSManaged public var breakeven: Int32
    @NSManaged public var consistency: Double
    @NSManaged public var highScore: Int32
    @NSManaged public var lowScore: Int32
    @NSManaged public var priceChange: Int32
    @NSManaged public var isCashCow: Bool
    @NSManaged public var isDoubtful: Bool
    @NSManaged public var isSuspended: Bool
    @NSManaged public var cashGenerated: Int32
    @NSManaged public var projectedPeakPrice: Int32
    @NSManaged public var lastUpdated: Date?

    @NSManaged public var injuryRisk: CDInjuryRisk?
    @NSManaged public var nextRound: CDRoundProjection?
    @NSManaged public var seasonProjection: CDSeasonProjection?
    @NSManaged public var alertFlags: Set<CDPlayerAlert>
    @NSManaged public var history: Set<CDPlayerHistory>
    @NSManaged public var venuePerformance: Set<CDVenuePerformance>
}

extension CDPlayer {
    static var entityName: String { "CDPlayer" }

    var positionEnum: Position {
        get { Position(rawValue: position) ?? .midfielder }
        set { position = newValue.rawValue }
    }

    var asEnhancedPlayer: EnhancedPlayer {
        EnhancedPlayer(
            id: id,
            name: name,
            position: positionEnum,
            price: Int(currentPrice),
            currentScore: Int(currentScore),
            averageScore: averageScore,
            breakeven: Int(breakeven),
            consistency: consistency,
            highScore: Int(highScore),
            lowScore: Int(lowScore),
            priceChange: Int(priceChange),
            isCashCow: isCashCow,
            isDoubtful: isDoubtful,
            isSuspended: isSuspended,
            cashGenerated: Int(cashGenerated),
            projectedPeakPrice: Int(projectedPeakPrice),
            nextRoundProjection: nextRound?.asRoundProjection ?? RoundProjection(
                round: 0,
                opponent: "TBD",
                venue: "TBD",
                projectedScore: 0,
                confidence: 0,
                conditions: WeatherConditions(
                    temperature: 0,
                    rainProbability: 0,
                    windSpeed: 0,
                    humidity: 0
                )
            ),
            seasonProjection: seasonProjection?.asSeasonProjection ?? SeasonProjection(
                projectedTotalScore: 0,
                projectedAverage: 0,
                premiumPotential: 0
            ),
            injuryRisk: injuryRisk?.asInjuryRisk ?? InjuryRisk(
                riskLevel: .low,
                riskScore: 0,
                riskFactors: []
            ),
            venuePerformance: venuePerformance.map(\.asVenuePerformance).sorted { $0.gamesPlayed > $1.gamesPlayed },
            alertFlags: alertFlags.map(\.asAlertFlag)
        )
    }

    static func fetch(_ id: String, in context: NSManagedObjectContext) -> CDPlayer? {
        let request = NSFetchRequest<CDPlayer>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    static func fetchAll(in context: NSManagedObjectContext) -> [CDPlayer] {
        let request = NSFetchRequest<CDPlayer>(entityName: entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "averageScore", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    func update(from player: EnhancedPlayer, in context: NSManagedObjectContext) {
        id = player.id
        name = player.name
        position = player.position.rawValue
        currentPrice = Int32(player.price)
        currentScore = Int32(player.currentScore)
        averageScore = player.averageScore
        breakeven = Int32(player.breakeven)
        consistency = player.consistency
        highScore = Int32(player.highScore)
        lowScore = Int32(player.lowScore)
        priceChange = Int32(player.priceChange)
        isCashCow = player.isCashCow
        isDoubtful = player.isDoubtful
        isSuspended = player.isSuspended
        cashGenerated = Int32(player.cashGenerated)
        projectedPeakPrice = Int32(player.projectedPeakPrice)
        lastUpdated = Date()

        // Update relationships
        if let risk = injuryRisk ?? CDInjuryRisk(context: context) {
            risk.update(from: player.injuryRisk)
            injuryRisk = risk
        }

        if let round = nextRound ?? CDRoundProjection(context: context) {
            round.update(from: player.nextRoundProjection)
            nextRound = round
        }

        if let season = seasonProjection ?? CDSeasonProjection(context: context) {
            season.update(from: player.seasonProjection)
            seasonProjection = season
        }

        // Update alerts (replace all)
        alertFlags.forEach { context.delete($0) }
        alertFlags = Set(player.alertFlags.map { flag in
            let alert = CDPlayerAlert(context: context)
            alert.update(from: flag)
            return alert
        })

        // Update venue performance (add/update only)
        let existing = Dictionary(uniqueKeysWithValues: venuePerformance.map { ($0.venue ?? "", $0) })
        for perf in player.venuePerformance {
            if let existing = existing[perf.venue] {
                existing.update(from: perf)
            } else {
                let new = CDVenuePerformance(context: context)
                new.update(from: perf)
                addToVenuePerformance(new)
            }
        }
    }
}
