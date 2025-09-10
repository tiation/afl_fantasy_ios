import SwiftUI

struct PlayerCard: View {
    let player: Player
    let showDetails: Bool
    var onTap: (() -> Void)?
    
    init(
        player: Player,
        showDetails: Bool = true,
        onTap: (() -> Void)? = nil
    ) {
        self.player = player
        self.showDetails = showDetails
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: { onTap?() }) {
            VStack(spacing: Theme.Spacing.s) {
                // Header
                HStack {
                    // Name and Position
                    VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                        Text(player.name)
                            .font(Theme.Font.title3)
                            .foregroundColor(Theme.Colors.textPrimary)
                        
                        Text(player.team)
                            .font(Theme.Font.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Position Badge
                    PositionBadge(position: player.position)
                }
                
                if showDetails {
                    // Stats Grid
                    HStack(spacing: Theme.Spacing.m) {
                        // Price
                        StatItem(
                            label: "Price",
                            value: "$\(player.price / 1000)k",
                            trend: player.priceChange
                        )
                        
                        Divider()
                        
                        // Average
                        StatItem(
                            label: "AVG",
                            value: String(format: "%.1f", player.average)
                        )
                        
                        Divider()
                        
                        // Breakeven
                        StatItem(
                            label: "BE",
                            value: "\(player.breakeven)",
                            isPrimary: false
                        )
                        
                        if player.ownership != nil {
                            Divider()
                            
                            // Ownership
                            StatItem(
                                label: "Own",
                                value: "\(Int(player.ownership!))%",
                                isPrimary: false
                            )
                        }
                    }
                    .padding(.top, Theme.Spacing.xs)
                    
                    // Status Indicators
                    if shouldShowStatusRow {
                        HStack(spacing: Theme.Spacing.s) {
                            // Consistency Grade
                            ConsistencyBadge(grade: player.consistency)
                            
                            // Form Indicator
                            if let form = player.formFactor {
                                FormIndicator(value: form)
                            }
                            
                            // Injury Status
                            if let status = player.injuryStatus {
                                InjuryBadge(status: status)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, Theme.Spacing.xs)
                    }
                }
            }
            .padding(Theme.Spacing.m)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var shouldShowStatusRow: Bool {
        showDetails && (
            player.formFactor != nil ||
            player.injuryStatus != nil
        )
    }
}

// MARK: - Supporting Views

private struct StatItem: View {
    let label: String
    let value: String
    let trend: Int?
    let isPrimary: Bool
    
    init(
        label: String,
        value: String,
        trend: Int? = nil,
        isPrimary: Bool = true
    ) {
        self.label = label
        self.value = value
        self.trend = trend
        self.isPrimary = isPrimary
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xxs) {
            Text(label)
                .font(Theme.Font.caption)
                .foregroundColor(Theme.Colors.textSecondary)
            
            HStack(alignment: .lastTextBaseline, spacing: Theme.Spacing.xxs) {
                Text(value)
                    .font(isPrimary ? Theme.Font.statSmall : Theme.Font.bodyBold)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                if let trend = trend {
                    TrendIndicator(value: trend)
                }
            }
        }
    }
}

private struct PositionBadge: View {
    let position: Position
    
    var body: some View {
        Text(position.rawValue)
            .font(Theme.Font.captionBold)
            .foregroundColor(.white)
            .padding(.horizontal, Theme.Spacing.xs)
            .padding(.vertical, Theme.Spacing.xxs)
            .background(backgroundColor)
            .cornerRadius(Theme.Radius.small)
    }
    
    private var backgroundColor: Color {
        switch position {
        case .defender:
            return Color.blue
        case .midfielder:
            return Color.green
        case .ruck:
            return Color.purple
        case .forward:
            return Color.red
        }
    }
}

private struct ConsistencyBadge: View {
    let grade: ConsistencyGrade
    
    var body: some View {
        Text(grade.rawValue)
            .font(Theme.Font.captionBold)
            .foregroundColor(.white)
            .padding(.horizontal, Theme.Spacing.xs)
            .padding(.vertical, Theme.Spacing.xxs)
            .background(backgroundColor)
            .cornerRadius(Theme.Radius.small)
    }
    
    private var backgroundColor: Color {
        switch grade {
        case .a:
            return Theme.Colors.success
        case .b:
            return Color.green
        case .c:
            return Theme.Colors.warning
        case .d:
            return Theme.Colors.error
        }
    }
}

private struct InjuryBadge: View {
    let status: InjuryStatus
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xxs) {
            Image(systemName: icon)
            Text(label)
        }
        .font(Theme.Font.caption)
        .foregroundColor(color)
        .padding(.horizontal, Theme.Spacing.xs)
        .padding(.vertical, Theme.Spacing.xxs)
        .background(color.opacity(0.1))
        .cornerRadius(Theme.Radius.small)
    }
    
    private var icon: String {
        switch status {
        case .healthy:
            return "checkmark.circle.fill"
        case .questionable:
            return "exclamationmark.triangle.fill"
        case .out:
            return "xmark.circle.fill"
        }
    }
    
    private var label: String {
        switch status {
        case .healthy:
            return "Healthy"
        case .questionable:
            return "Questionable"
        case .out:
            return "Out"
        }
    }
    
    private var color: Color {
        switch status {
        case .healthy:
            return Theme.Colors.success
        case .questionable:
            return Theme.Colors.warning
        case .out:
            return Theme.Colors.error
        }
    }
}

private struct FormIndicator: View {
    let value: Double
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xxs) {
            Image(systemName: value > 0 ? "arrow.up.right" : "arrow.down.right")
            Text(formattedValue)
        }
        .font(Theme.Font.caption)
        .foregroundColor(color)
        .padding(.horizontal, Theme.Spacing.xs)
        .padding(.vertical, Theme.Spacing.xxs)
        .background(color.opacity(0.1))
        .cornerRadius(Theme.Radius.small)
    }
    
    private var formattedValue: String {
        let prefix = value > 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.1f", value))"
    }
    
    private var color: Color {
        if value > 5 {
            return Theme.Colors.success
        } else if value < -5 {
            return Theme.Colors.error
        } else {
            return Theme.Colors.textSecondary
        }
    }
}

private struct TrendIndicator: View {
    let value: Int
    
    var body: some View {
        Image(systemName: icon)
            .foregroundColor(color)
            .font(.caption)
    }
    
    private var icon: String {
        value > 0 ? "arrow.up.right" : "arrow.down.right"
    }
    
    private var color: Color {
        value > 0 ? Theme.Colors.success : Theme.Colors.error
    }
}

// MARK: - Preview

struct PlayerCard_Previews: PreviewProvider {
    static let samplePlayer = Player(
        id: "123",
        name: "Marcus Bontempelli",
        team: "Western Bulldogs",
        position: .midfielder,
        price: 750000,
        average: 110.5,
        projected: 115.0,
        breakeven: 95,
        consistency: .a,
        priceChange: 25000,
        ownership: 35.5,
        injuryStatus: nil,
        venueStats: nil,
        formFactor: 5.5,
        dvpImpact: nil
    )
    
    static var previews: some View {
        VStack(spacing: Theme.Spacing.m) {
            PlayerCard(player: samplePlayer)
            
            PlayerCard(
                player: samplePlayer,
                showDetails: false
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
