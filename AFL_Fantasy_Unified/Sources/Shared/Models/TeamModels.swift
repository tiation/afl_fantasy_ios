// 🏈 AFL Fantasy Models - Team & Trade Domain
// Team structure, trades, lineups, salary management

import Foundation

// MARK: - Team Models

struct Team: Codable {
    let players: [Player]
    let structure: TeamStructure
    let trades: TradeInfo
}

struct TeamStructure: Codable {
    let totalValue: Int
    let bankBalance: Int
    let positionBalance: [Position: Int]
    let premiumCount: Int
    let midPriceCount: Int
    let rookieCount: Int
    
    init() {
        self.totalValue = 0
        self.bankBalance = 0
        self.positionBalance = [:]
        self.premiumCount = 0
        self.midPriceCount = 0
        self.rookieCount = 0
    }
    
    init(totalValue: Int, bankBalance: Int, positionBalance: [Position: Int], premiumCount: Int, midPriceCount: Int, rookieCount: Int) {
        self.totalValue = totalValue
        self.bankBalance = bankBalance
        self.positionBalance = positionBalance
        self.premiumCount = premiumCount
        self.midPriceCount = midPriceCount
        self.rookieCount = rookieCount
    }
}

struct TradeInfo: Codable {
    let remaining: Int
    let used: Int
}

struct TradeResult: Codable {
    let success: Bool
    let newBalance: Int
    let structureImpact: TeamStructure
    let projectedPointsChange: Double
}

struct SavedLine: Codable, Identifiable {
    let id: String
    let name: String
    let lineup: [FieldPlayer]
    let createdDate: Date
    let totalValue: Int
    let totalScore: Int
    let defCount: Int
    let midCount: Int
    let rucCount: Int
    let fwdCount: Int
}

struct SalaryInfo: Codable {
    let totalSalary: Int
    let availableSalary: Int
    let averagePlayerPrice: Int
    let premiumPercentage: Double
    let rookiePercentage: Double
}

struct SuggestedTrade: Codable, Identifiable {
    let id: String
    let playerOut: Player
    let playerIn: Player
    let cashDifference: Int
    let projectedPointsGain: Double
    let confidence: Double
    let reasoning: String
}

struct TeamAnalysis: Codable {
    let structure: TeamStructure
    let weaknesses: [String]
    let upgradePathways: [String]
    let overallRating: Double
}

struct TeamWeakness: Codable {
    let type: WeaknessType
    let severity: Double
    let recommendation: String
}

enum WeaknessType: String, Codable {
    case positionImbalance = "POSITION_IMBALANCE"
    case premiumLight = "PREMIUM_LIGHT"
    case rookieHeavy = "ROOKIE_HEAVY"
    case injuryRisk = "INJURY_RISK"
    case byeRoundExposure = "BYE_ROUND_EXPOSURE"
}

struct UpgradePathway: Codable {
    let from: Player
    let to: Player
    let cost: Int
    let pointsImprovement: Double
    let confidence: Double
}
