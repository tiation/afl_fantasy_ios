import Foundation

// MARK: - Venue Analytics
struct VenueAnalytics: Codable, Identifiable {
    let id = UUID()
    let venueId: String
    let venueName: String
    let city: String
    let state: String
    let playerPerformance: [String: VenuePlayerStats] // playerId -> stats
    let weatherHistoricalImpact: WeatherImpact
    let surfaceType: SurfaceType
    let dimensionsMeters: VenueDimensions
    let altitude: Double // meters above sea level
    let capacity: Int
    let roofType: RoofType
    let lastUpdated: Date
}

// MARK: - Venue Player Statistics
struct VenuePlayerStats: Codable {
    let playerId: String
    let gamesPlayed: Int
    let averageScore: Double
    let bestScore: Int
    let worstScore: Int
    let consistencyRating: Double // 0.0 - 1.0
    let standardDeviation: Double
    let scoringFrequency: ScoringFrequency
    let performanceTrend: TrendDirection
    let recentForm: [Int] // last 5 games at venue
    let seasonalBreakdown: [String: SeasonalVenueStats] // year -> stats
}

struct SeasonalVenueStats: Codable {
    let season: String
    let games: Int
    let avgScore: Double
    let trend: TrendDirection
}

struct ScoringFrequency: Codable {
    let scores100Plus: Int
    let scores80Plus: Int
    let scores60Plus: Int
    let scoresUnder40: Int
    let percentageConsistent: Double // scores within 20 points of average
}

// MARK: - Weather Impact Analysis
struct WeatherImpact: Codable {
    let windImpact: WindImpact
    let rainImpact: RainImpact
    let temperatureImpact: TemperatureImpact
    let humidityImpact: HumidityImpact
    let overallWeatherSensitivity: WeatherSensitivity
}

struct WindImpact: Codable {
    let strongWindGames: Int
    let strongWindAverage: Double
    let calmWindAverage: Double
    let windSensitivityRating: Double // -1.0 to 1.0
}

struct RainImpact: Codable {
    let wetGameCount: Int
    let wetGameAverage: Double
    let dryGameAverage: Double
    let rainSensitivityRating: Double
}

struct TemperatureImpact: Codable {
    let hotGameAverage: Double // 25°C+
    let mildGameAverage: Double // 15-25°C
    let coldGameAverage: Double // <15°C
    let temperatureSensitivity: Double
}

struct HumidityImpact: Codable {
    let highHumidityAverage: Double // 70%+
    let lowHumidityAverage: Double // <70%
    let humiditySensitivity: Double
}

enum WeatherSensitivity: String, Codable, CaseIterable {
    case veryHigh = "very_high"
    case high = "high"
    case moderate = "moderate"
    case low = "low"
    case minimal = "minimal"
    
    var description: String {
        switch self {
        case .veryHigh: return "Very High"
        case .high: return "High"
        case .moderate: return "Moderate"
        case .low: return "Low"
        case .minimal: return "Minimal"
        }
    }
}

// MARK: - Venue Physical Characteristics
struct VenueDimensions: Codable {
    let length: Double
    let width: Double
    let area: Double // square meters
    let goalSquareLength: Double
    let goalSquareWidth: Double
    let centreCircleDiameter: Double
}

enum SurfaceType: String, Codable, CaseIterable {
    case naturalGrass = "natural_grass"
    case artificialGrass = "artificial_grass"
    case hybrid = "hybrid"
    
    var description: String {
        switch self {
        case .naturalGrass: return "Natural Grass"
        case .artificialGrass: return "Artificial Grass"
        case .hybrid: return "Hybrid"
        }
    }
}

enum RoofType: String, Codable, CaseIterable {
    case open = "open"
    case retractable = "retractable"
    case closed = "closed"
    
    var description: String {
        switch self {
        case .open: return "Open"
        case .retractable: return "Retractable"
        case .closed: return "Closed"
        }
    }
}

// MARK: - Venue Specialists Analysis
struct VenueSpecialist: Codable, Identifiable {
    let id = UUID()
    let playerId: String
    let playerName: String
    let venueId: String
    let venueName: String
    let specialistRating: Double // 0.0 - 10.0
    let averageAtVenue: Double
    let averageElsewhere: Double
    let scoreDifferential: Double
    let confidence: ConfidenceLevel
    let sampleSize: Int
    let lastGameAtVenue: Date?
}

struct VenueAnalysis: Codable {
    let playerId: String
    let venueComparison: [VenueComparison]
    let bestVenues: [VenueRanking]
    let worstVenues: [VenueRanking]
    let overallVenueVariability: Double
    let venueConsistency: VenueConsistency
}

struct VenueComparison: Codable {
    let venueId: String
    let venueName: String
    let games: Int
    let average: Double
    let vsOverallAverage: Double
    let rating: VenueRating
}

struct VenueRanking: Codable {
    let venueId: String
    let venueName: String
    let average: Double
    let games: Int
    let differential: Double
}

enum VenueRating: String, Codable, CaseIterable {
    case excellent = "excellent"
    case good = "good"
    case average = "average"
    case poor = "poor"
    case terrible = "terrible"
    
    var description: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .average: return "Average"
        case .poor: return "Poor"
        case .terrible: return "Terrible"
        }
    }
}

enum VenueConsistency: String, Codable, CaseIterable {
    case veryConsistent = "very_consistent"
    case consistent = "consistent"
    case moderate = "moderate"
    case inconsistent = "inconsistent"
    case veryInconsistent = "very_inconsistent"
    
    var description: String {
        switch self {
        case .veryConsistent: return "Very Consistent"
        case .consistent: return "Consistent"
        case .moderate: return "Moderate"
        case .inconsistent: return "Inconsistent"
        case .veryInconsistent: return "Very Inconsistent"
        }
    }
}

// MARK: - Impact Prediction
struct ImpactPrediction: Codable {
    let playerId: String
    let venueId: String
    let predictedScore: Double
    let confidenceInterval: ConfidenceInterval
    let keyFactors: [ImpactFactor]
    let weatherAdjustment: Double
    let recentFormAdjustment: Double
    let matchupAdjustment: Double
    let finalPrediction: Double
    let reliability: PredictionReliability
}

struct ImpactFactor: Codable {
    let factor: String
    let impact: Double // -10.0 to +10.0
    let confidence: Double // 0.0 to 1.0
    let description: String
}

struct ConfidenceInterval: Codable {
    let lower: Double
    let upper: Double
    let midpoint: Double
}

enum PredictionReliability: String, Codable, CaseIterable {
    case veryHigh = "very_high"
    case high = "high"
    case moderate = "moderate"
    case low = "low"
    case veryLow = "very_low"
    
    var description: String {
        switch self {
        case .veryHigh: return "Very High"
        case .high: return "High"
        case .moderate: return "Moderate"
        case .low: return "Low"
        case .veryLow: return "Very Low"
        }
    }
}

// MARK: - Shared Enums
enum TrendDirection: String, Codable, CaseIterable {
    case stronglyUp = "strongly_up"
    case up = "up"
    case stable = "stable"
    case down = "down"
    case stronglyDown = "strongly_down"
    
    var description: String {
        switch self {
        case .stronglyUp: return "📈 Strongly Up"
        case .up: return "📊 Up"
        case .stable: return "➡️ Stable"
        case .down: return "📉 Down"
        case .stronglyDown: return "📉📉 Strongly Down"
        }
    }
}

enum ConfidenceLevel: String, Codable, CaseIterable {
    case veryHigh = "very_high"
    case high = "high"
    case moderate = "moderate"
    case low = "low"
    case veryLow = "very_low"
    
    var description: String {
        switch self {
        case .veryHigh: return "Very High"
        case .high: return "High"
        case .moderate: return "Moderate"
        case .low: return "Low"
        case .veryLow: return "Very Low"
        }
    }
    
    var percentage: Int {
        switch self {
        case .veryHigh: return 95
        case .high: return 80
        case .moderate: return 65
        case .low: return 45
        case .veryLow: return 25
        }
    }
}
