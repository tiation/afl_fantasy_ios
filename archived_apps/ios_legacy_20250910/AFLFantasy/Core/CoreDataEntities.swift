import CoreData
import Foundation

// MARK: - CDInjuryRisk

@objc(CDInjuryRisk)
public class CDInjuryRisk: NSManagedObject {
    @NSManaged public var riskLevel: String
    @NSManaged public var details: String?
    @NSManaged public var lastUpdated: Date
    @NSManaged public var player: CDPlayer?
}

// MARK: - CDRoundProjection

@objc(CDRoundProjection)
public class CDRoundProjection: NSManagedObject {
    @NSManaged public var round: Int32
    @NSManaged public var predictedScore: Double
    @NSManaged public var confidence: Double
    @NSManaged public var venue: String?
    @NSManaged public var opponent: String?
    @NSManaged public var player: CDPlayer?
}

// MARK: - CDSeasonProjection

@objc(CDSeasonProjection)
public class CDSeasonProjection: NSManagedObject {
    @NSManaged public var projectedAverage: Double
    @NSManaged public var projectedTotal: Double
    @NSManaged public var breakEvenRounds: Int32
    @NSManaged public var player: CDPlayer?
}

// MARK: - CDPlayerAlert

@objc(CDPlayerAlert)
public class CDPlayerAlert: NSManagedObject {
    @NSManaged public var type: String
    @NSManaged public var priority: String
    @NSManaged public var message: String
    @NSManaged public var triggeredAt: Date
    @NSManaged public var player: CDPlayer?
}

// MARK: - CDPlayerHistory

@objc(CDPlayerHistory)
public class CDPlayerHistory: NSManagedObject {
    @NSManaged public var round: Int32
    @NSManaged public var score: Int32
    @NSManaged public var priceChange: Double
    @NSManaged public var date: Date
    @NSManaged public var player: CDPlayer?
}

// MARK: - CDVenuePerformance

@objc(CDVenuePerformance)
public class CDVenuePerformance: NSManagedObject {
    @NSManaged public var venue: String
    @NSManaged public var gamesPlayed: Int32
    @NSManaged public var averageScore: Double
    @NSManaged public var player: CDPlayer?
}

// MARK: - Core Data Extensions

public extension CDInjuryRisk {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDInjuryRisk> {
        NSFetchRequest<CDInjuryRisk>(entityName: "CDInjuryRisk")
    }
}

public extension CDRoundProjection {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDRoundProjection> {
        NSFetchRequest<CDRoundProjection>(entityName: "CDRoundProjection")
    }
}

public extension CDSeasonProjection {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDSeasonProjection> {
        NSFetchRequest<CDSeasonProjection>(entityName: "CDSeasonProjection")
    }
}

public extension CDPlayerAlert {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDPlayerAlert> {
        NSFetchRequest<CDPlayerAlert>(entityName: "CDPlayerAlert")
    }
}

public extension CDPlayerHistory {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDPlayerHistory> {
        NSFetchRequest<CDPlayerHistory>(entityName: "CDPlayerHistory")
    }
}

public extension CDVenuePerformance {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDVenuePerformance> {
        NSFetchRequest<CDVenuePerformance>(entityName: "CDVenuePerformance")
    }
}
