import SwiftUI

// Use PlayerDetailTab from shared models

// MARK: - PlayerDetailTabButton

struct PlayerDetailTabButton: View {
    let tab: PlayerDetailTab
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Spacing.xs) {
                Image(systemName: tab.icon)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                
                Text(tab.rawValue)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
            }
            .foregroundColor(isSelected ? .white : DS.Colors.onSurfaceSecondary)
            .padding(.horizontal, DS.Spacing.m)
            .padding(.vertical, DS.Spacing.s)
            .background(
                RoundedRectangle(cornerRadius: DS.CornerRadius.large)
                    .fill(isSelected ? DS.Colors.primary : DS.Colors.surfaceVariant)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0) {
            // Complete
        } onPressingChanged: { pressing in
            withAnimation(DS.Motion.springFast) {
                isPressed = pressing
            }
        }
    }
}

// MARK: - PlayerDetailStat

struct PlayerDetailStat: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: DS.Spacing.xs) {
            Text(value)
                .font(DS.Typography.smallStat)
                .foregroundColor(color)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(color.opacity(0.8))
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - MetricCard

struct MetricCard: View {
    let title: String
    let value: String
    let trend: String
    let color: Color
    
    var body: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                HStack {
                    Text(title)
                        .font(DS.Typography.caption)
                        .foregroundColor(DS.Colors.onSurfaceSecondary)
                    
                    Spacer()
                    
                    Circle()
                        .fill(color)
                        .frame(width: 6, height: 6)
                }
                
                Text(value)
                    .font(DS.Typography.statNumber)
                    .foregroundColor(color)
                
                Text(trend)
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
            }
        }
    }
}

// MARK: - RecentGameRow

struct RecentGameRow: View {
    let round: String
    let opponent: String
    let score: Double
    let result: String
    
    var resultColor: Color {
        result == "W" ? DS.Colors.success : DS.Colors.error
    }
    
    var body: some View {
        HStack {
            // Round
            Text(round)
                .font(DS.Typography.subheadline)
                .foregroundColor(DS.Colors.onSurface)
                .fontWeight(.medium)
                .frame(width: 40, alignment: .leading)
            
            // Opponent
            HStack(spacing: DS.Spacing.xs) {
                Text("vs")
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
                
                Text(opponent)
                    .font(DS.Typography.subheadline)
                    .foregroundColor(DS.Colors.onSurface)
                    .fontWeight(.medium)
            }
            .frame(width: 60, alignment: .leading)
            
            Spacer()
            
            // Score
            Text("\(score, specifier: "%.1f")")
                .font(DS.Typography.smallStat)
                .foregroundColor(score > 100 ? DS.Colors.success : score > 80 ? DS.Colors.primary : DS.Colors.warning)
                .fontWeight(.semibold)
            
            // Result
            Text(result)
                .font(DS.Typography.caption)
                .foregroundColor(.white)
                .fontWeight(.bold)
                .frame(width: 20, height: 20)
                .background(Circle().fill(resultColor))
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}

// MARK: - GameLogRow

struct GameLogRow: View {
    let round: String
    let date: String
    let opponent: String
    let score: Double
    let disposals: Int
    let goals: Int
    
    var body: some View {
        HStack(spacing: DS.Spacing.m) {
            VStack(alignment: .leading, spacing: 2) {
                Text(round)
                    .font(DS.Typography.subheadline)
                    .foregroundColor(DS.Colors.onSurface)
                    .fontWeight(.medium)
                
                Text(date)
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("vs \(opponent)")
                    .font(DS.Typography.subheadline)
                    .foregroundColor(DS.Colors.onSurface)
                
                Text("\(disposals)D \(goals)G")
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
            }
            
            Spacer()
            
            Text("\(score, specifier: "%.1f")")
                .font(DS.Typography.smallStat)
                .foregroundColor(score > 100 ? DS.Colors.success : score > 80 ? DS.Colors.primary : DS.Colors.warning)
                .fontWeight(.semibold)
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}

// MARK: - InsightMetric

struct InsightMetric: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: DS.Spacing.xs) {
            Text(value)
                .font(DS.Typography.microStat)
                .foregroundColor(color)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(DS.Colors.onSurfaceSecondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - FixtureRow

struct FixtureRow: View {
    let round: String
    let opponent: String
    let venue: String
    let difficulty: String
    
    var difficultyColor: Color {
        switch difficulty {
        case "Easy": return DS.Colors.success
        case "Medium": return DS.Colors.warning
        case "Hard": return DS.Colors.error
        default: return DS.Colors.neutral
        }
    }
    
    var body: some View {
        HStack {
            Text(round)
                .font(DS.Typography.subheadline)
                .foregroundColor(DS.Colors.onSurface)
                .fontWeight(.medium)
                .frame(width: 40, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("vs \(opponent)")
                    .font(DS.Typography.subheadline)
                    .foregroundColor(DS.Colors.onSurface)
                
                Text(venue)
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.onSurfaceSecondary)
            }
            
            Spacer()
            
            DSStatusBadge(text: difficulty, style: .custom(difficultyColor))
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}

// MARK: - PlayerData

struct PlayerData {
    let player: Player
    let formData: [ChartDataPoint]
    let priceData: [ChartDataPoint]
    let venueData: [ChartDataPoint]
    let recentGames: [GameData]
    let gameLog: [GameLogData]
    let fixtures: [FixtureData]
    let insights: PlayerInsights
    
    static func mock(for player: Player) -> PlayerData {
        return PlayerData(
            player: player,
            formData: ChartDataPoint.mockFormData(),
            priceData: ChartDataPoint.mockPriceData(),
            venueData: ChartDataPoint.mockVenueData(),
            recentGames: GameData.mockRecentGames(),
            gameLog: GameLogData.mockGameLog(),
            fixtures: FixtureData.mockFixtures(),
            insights: PlayerInsights.mock(for: player)
        )
    }
}

// MARK: - GameData

struct GameData {
    let round: String
    let opponent: String
    let score: Double
    let result: String
    
    static func mockRecentGames() -> [GameData] {
        return [
            GameData(round: "R15", opponent: "COL", score: 95.4, result: "W"),
            GameData(round: "R14", opponent: "RIC", score: 88.7, result: "L"),
            GameData(round: "R13", opponent: "ESS", score: 105.3, result: "W"),
            GameData(round: "R12", opponent: "CAR", score: 78.5, result: "L"),
            GameData(round: "R11", opponent: "GEE", score: 92.1, result: "W")
        ]
    }
}

// MARK: - GameLogData

struct GameLogData {
    let round: String
    let date: String
    let opponent: String
    let score: Double
    let disposals: Int
    let goals: Int
    
    static func mockGameLog() -> [GameLogData] {
        let rounds = Array(6...15).reversed()
        let dates = Array(10...19)
        let opponents = ["COL", "RIC", "ESS", "CAR", "GEE", "HAW", "FRE", "STK", "NTH", "SYD"]
        let scores = [95.4, 88.7, 105.3, 78.5, 92.1, 83.6, 89.9, 102.7, 76.3, 88.1]
        let disposals = [28, 24, 31, 20, 26, 23, 25, 29, 19, 24]
        let goals = [1, 0, 2, 0, 1, 0, 1, 2, 0, 1]
        
        return zip(zip(zip(zip(rounds, dates), opponents), scores), zip(disposals, goals)).map { data in
            let ((((round, date), opponent), score), (disp, goal)) = data
            return GameLogData(
                round: "R\(round)",
                date: "Aug \(date)",
                opponent: opponent,
                score: score,
                disposals: disp,
                goals: goal
            )
        }
    }
}

// MARK: - FixtureData

struct FixtureData {
    let round: String
    let opponent: String
    let venue: String
    let difficulty: String
    
    static func mockFixtures() -> [FixtureData] {
        return [
            FixtureData(round: "R16", opponent: "STK", venue: "Marvel", difficulty: "Easy"),
            FixtureData(round: "R17", opponent: "GWS", venue: "MCG", difficulty: "Medium"),
            FixtureData(round: "R18", opponent: "PORT", venue: "AO", difficulty: "Hard")
        ]
    }
}

// MARK: - PlayerInsights

struct PlayerInsights {
    let aiAnalysis: String
    let tradeAnalysis: String
    let buyScore: Double
    let captainScore: Double
    let riskLevel: String
    let confidence: Double
    
    static func mock(for player: Player) -> PlayerInsights {
        let opponent = player.team == "WB" ? "STK" : "WB"
        
        return PlayerInsights(
            aiAnalysis: "Strong captain option this week with favorable matchup vs \(opponent). Recent form trending upward with consistent 90+ scores. Price rise likely.",
            tradeAnalysis: "Current value: \(player.price > 500000 ? "Premium" : "Good value"). Expected price change: +$\(Int.random(in: 15...35))K. Ownership trending up.",
            buyScore: Double.random(in: 7.0...9.5),
            captainScore: Double.random(in: 6.5...9.0),
            riskLevel: player.price > 600000 ? "Low" : "Medium",
            confidence: Double.random(in: 0.80...0.95)
        )
    }
}

// MARK: - Preview

#if DEBUG
struct PlayerDetailComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: DS.Spacing.l) {
            HStack {
                PlayerDetailTabButton(tab: .overview, isSelected: true) {}
                PlayerDetailTabButton(tab: .statistics, isSelected: false) {}
                PlayerDetailTabButton(tab: .similar, isSelected: false) {}
            }
            
            MetricCard(title: "Ownership", value: "23.4%", trend: "+2.1%", color: DS.Colors.info)
            
            RecentGameRow(round: "R15", opponent: "COL", score: 95.4, result: "W")
        }
        .padding()
    }
}
#endif
