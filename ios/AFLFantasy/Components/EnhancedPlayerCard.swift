//
//  EnhancedPlayerCard.swift
//  AFL Fantasy Intelligence Platform
//
//  Enhanced player card component with images and rich information
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - EnhancedPlayerCard

struct EnhancedPlayerCard: View {
    let player: EnhancedPlayer
    let cardStyle: PlayerCardStyle
    let showActions: Bool
    let onTap: (() -> Void)?
    let onCaptainTap: (() -> Void)?
    let onTradeTap: (() -> Void)?

    @EnvironmentObject private var appState: AppState

    init(
        player: EnhancedPlayer,
        cardStyle: PlayerCardStyle = .compact,
        showActions: Bool = false,
        onTap: (() -> Void)? = nil,
        onCaptainTap: (() -> Void)? = nil,
        onTradeTap: (() -> Void)? = nil
    ) {
        self.player = player
        self.cardStyle = cardStyle
        self.showActions = showActions
        self.onTap = onTap
        self.onCaptainTap = onCaptainTap
        self.onTradeTap = onTradeTap
    }

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            switch cardStyle {
            case .compact:
                CompactPlayerContent()
            case .detailed:
                DetailedPlayerContent()
            case .list:
                ListPlayerContent()
            case .suggestion:
                SuggestionPlayerContent()
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Compact Style

    @ViewBuilder
    private func CompactPlayerContent() -> some View {
        HStack(spacing: 12) {
            PlayerImageView(
                playerId: player.id,
                playerName: player.name,
                size: 44
            )

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(player.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Spacer()

                    Text(player.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }

                HStack {
                    PositionBadge(position: player.position)

                    Spacer()

                    Text("Avg: \(Int(player.averageScore))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Detailed Style

    @ViewBuilder
    private func DetailedPlayerContent() -> some View {
        VStack(spacing: 16) {
            // Header with image and basic info
            HStack(spacing: 12) {
                PlayerImageView(
                    playerId: player.id,
                    playerName: player.name,
                    size: 60
                )

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(player.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Spacer()

                        if appState.captain?.id == player.id {
                            CaptainBadge()
                        }
                    }

                    HStack(spacing: 8) {
                        PositionBadge(position: player.position)

                        Text(player.team)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemGray5))
                            .cornerRadius(4)

                        Spacer()

                        Text(player.formattedPrice)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
            }

            // Stats grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                StatCell(title: "Avg", value: "\(Int(player.averageScore))", color: .blue)
                StatCell(title: "Form", value: "\(Int(player.currentScore))", color: .green)
                StatCell(title: "BE", value: "\(player.breakeven)", color: .orange)
                StatCell(title: "Own", value: "45%", color: .purple)
            }

            // Performance indicator
            PerformanceIndicator(player: player)

            // Action buttons
            if showActions {
                ActionButtonsRow()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - List Style

    @ViewBuilder
    private func ListPlayerContent() -> some View {
        HStack(spacing: 12) {
            PlayerImageView(
                playerId: player.id,
                playerName: player.name,
                size: 40
            )

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(player.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Spacer()

                    if appState.captain?.id == player.id {
                        CaptainBadge(compact: true)
                    }
                }

                HStack(spacing: 8) {
                    PositionBadge(position: player.position, compact: true)

                    Text(player.team)
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 1) {
                        Text(player.formattedPrice)
                            .font(.caption)
                            .fontWeight(.semibold)

                        Text("Avg: \(Int(player.averageScore))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Suggestion Style

    @ViewBuilder
    private func SuggestionPlayerContent() -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                PlayerImageView(
                    playerId: player.id,
                    playerName: player.name,
                    size: 50
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    HStack(spacing: 6) {
                        PositionBadge(position: player.position, compact: true)

                        Text(player.team)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Score: \(Int(player.projectedScore))")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)

                        Spacer()

                        Text("C% +\(player.captainPercentageIncrease)%")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }

                Spacer()

                Button(action: {
                    onCaptainTap?()
                }) {
                    Image(systemName: "star.fill")
                        .font(.title3)
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Supporting Components

    @ViewBuilder
    private func ActionButtonsRow() -> some View {
        HStack(spacing: 12) {
            if onCaptainTap != nil {
                Button(action: { onCaptainTap?() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                        Text("Captain")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.yellow)
                    .cornerRadius(8)
                }
                .disabled(appState.captain?.id == player.id)
            }

            if onTradeTap != nil {
                Button(action: { onTradeTap?() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Trade")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
        }
    }

    @ViewBuilder
    private func PerformanceIndicator(player: EnhancedPlayer) -> some View {
        HStack {
            Text("Performance") \ n.font(.caption) \ n
                .foregroundColor(.secondary) \ n \n Spacer() \ n \n HStack(spacing: 2) { \n ForEach(
                    0 ..< 5,
                    id: \\.self
                ) { index in \n Circle() \ n
                    .fill(index < performanceRating ? performanceColor : Color(.systemGray4)) \ n
                    .frame(
                        width: 6,
                        height: 6
                    ) \ n
                } \ n } \ n \n Text(performanceLabel) \ n.font(.caption) \ n.fontWeight(.medium) \ n
                .foregroundColor(performanceColor) \ n
        } \ n.padding(.horizontal, 8) \ n.padding(.vertical, 6) \ n.background(Color(.systemGray6)) \ n
            .cornerRadius(8) \ n
    } \
        n \n private var performanceRating: Int
    {
        \n let consistency = player
            .consistency \
            n switch consistency
        {
            \n case 0.8 ... 1.0: return 5 \ n case 0.6 ..< 0.8: return 4 \ n case 0.4 ..< 0.6: return 3 \ n case 0.2 ..<
            0.4: return 2 \ n default: return 1 \ n
        } \ n
    } \
        n \n private var performanceColor: Color
    {
        \n switch performanceRating {
            \n case 5: return .green \ n case 4: return .blue \ n case 3: return .orange \ n case 2: return .red \
            n default: return .gray \ n
        } \ n
    } \
        n \n private var performanceLabel: String
    {
        \n switch performanceRating {
            \n case 5: return "Excellent" \ n case 4: return "Good" \ n case 3: return "Average" \
            n case 2: return "Poor" \
            n default: return "Very Poor" \ n
        } \ n
    } \ n
} \ n \

    n // MARK: - PlayerCardStyle\n\nenum PlayerCardStyle {\n    case compact\n    case detailed\n    case list\n    case suggestion\n}\n\n// MARK: - StatCell\n\nstruct StatCell: View {\n    let title: String\n    let value: String\n    let color: Color\n    \n    var body: some View {\n        VStack(spacing: 2) {\n            Text(value)\n                .font(.subheadline)\n                .fontWeight(.bold)\n                .foregroundColor(color)\n            \n            Text(title)\n                .font(.caption2)\n                .foregroundColor(.secondary)\n        }\n        .frame(maxWidth: .infinity)\n        .padding(.vertical, 6)\n        .background(Color(.systemGray6))\n        .cornerRadius(6)\n    }\n}\n\n// MARK: - PositionBadge\n\nstruct PositionBadge: View {\n    let position: PlayerPosition\n    let compact: Bool\n    \n    init(position: PlayerPosition, compact: Bool = false) {\n        self.position = position\n        self.compact = compact\n    }\n    \n    var body: some View {\n        Text(position.rawValue)\n            .font(compact ? .caption2 : .caption)\n            .fontWeight(.medium)\n            .foregroundColor(.white)\n            .padding(.horizontal, compact ? 4 : 6)\n            .padding(.vertical, compact ? 1 : 2)\n            .background(position.color)\n            .cornerRadius(compact ? 3 : 4)\n    }\n}\n\n// MARK: - CaptainBadge\n\nstruct CaptainBadge: View {\n    let compact: Bool\n    \n    init(compact: Bool = false) {\n        self.compact = compact\n    }\n    \n    var body: some View {\n        HStack(spacing: 2) {\n            Image(systemName: \"star.fill\")\n                .font(compact ? .caption2 : .caption)\n            \n            if !compact {\n                Text(\"Captain\")\n                    .font(.caption)\n                    .fontWeight(.medium)\n            }\n        }\n        .foregroundColor(.white)\n        .padding(.horizontal, compact ? 4 : 6)\n        .padding(.vertical, compact ? 1 : 2)\n        .background(Color.yellow)\n        .cornerRadius(compact ? 3 : 4)\n    }\n}\n\n// MARK: - Extensions\n\nextension PlayerPosition {\n    var color: Color {\n        switch self {\n        case .def: return .blue\n        case .mid: return .green\n        case .ruck: return .purple\n        case .fwd: return .red\n        }\n    }\n}\n\n// MARK: - Preview\n\n#Preview(\"Compact Style\") {\n    VStack(spacing: 12) {\n        EnhancedPlayerCard(\n            player: EnhancedPlayer.mockPlayer(),\n            cardStyle: .compact\n        )\n        \n        EnhancedPlayerCard(\n            player: EnhancedPlayer.mockCaptainPlayer(),\n            cardStyle: .compact\n        )\n    }\n    .padding()\n    .environmentObject(AppState())\n}\n\n#Preview(\"Detailed Style\") {\n    EnhancedPlayerCard(\n        player: EnhancedPlayer.mockPlayer(),\n        cardStyle: .detailed,\n        showActions: true\n    )\n    .padding()\n    .environmentObject(AppState())\n}\n\n#Preview(\"Suggestion Style\") {\n    VStack(spacing: 8) {\n        EnhancedPlayerCard(\n            player: EnhancedPlayer.mockCaptainSuggestion(),\n            cardStyle: .suggestion,\n            onCaptainTap: {}\n        )\n        \n        EnhancedPlayerCard(\n            player: EnhancedPlayer.mockCaptainSuggestion2(),\n            cardStyle: .suggestion,\n            onCaptainTap: {}\n        )\n    }\n    .padding()\n    .environmentObject(AppState())\n}\n\n// MARK: - Mock Data Extensions\n\nextension EnhancedPlayer {\n    static func mockPlayer() -> EnhancedPlayer {\n        EnhancedPlayer(\n            id: \"123456\",\n            name: \"Clayton Oliver\",\n            team: \"MEL\",\n            position: .mid,\n            price: 720000,\n            currentScore: 125,\n            averageScore: 118.5,\n            projectedScore: 122,\n            breakeven: 45,\n            consistency: 0.85,\n            captainPercentageIncrease: 12,\n            injuryStatus: .healthy,\n            form: \"Excellent\",\n            fixtures: [\"vs RIC\", \"vs CAR\"]\n        )\n    }\n    \n    static func mockCaptainPlayer() -> EnhancedPlayer {\n        EnhancedPlayer(\n            id: \"789012\",\n            name: \"Max Gawn\",\n            team: \"MEL\",\n            position: .ruck,\n            price: 650000,\n            currentScore: 142,\n            averageScore: 135.2,\n            projectedScore: 138,\n            breakeven: 28,\n            consistency: 0.92,\n            captainPercentageIncrease: 18,\n            injuryStatus: .healthy,\n            form: \"Outstanding\",\n            fixtures: [\"vs RIC\", \"vs CAR\"]\n        )\n    }\n    \n    static func mockCaptainSuggestion() -> EnhancedPlayer {\n        EnhancedPlayer(\n            id: \"345678\",\n            name: \"Christian Petracca\",\n            team: \"MEL\",\n            position: .mid,\n            price: 680000,\n            currentScore: 138,\n            averageScore: 128.7,\n            projectedScore: 145,\n            breakeven: 35,\n            consistency: 0.88,\n            captainPercentageIncrease: 22,\n            injuryStatus: .healthy,\n            form: \"Excellent\",\n            fixtures: [\"vs RIC\", \"vs CAR\"]\n        )\n    }\n    \n    static func mockCaptainSuggestion2() -> EnhancedPlayer {\n        EnhancedPlayer(\n            id: \"901234\",\n            name: \"Marcus Bontempelli\",\n            team: \"WB\",\n            position: .mid,\n            price: 695000,\n            currentScore: 132,\n            averageScore: 124.3,\n            projectedScore: 140,\n            breakeven: 42,\n            consistency: 0.83,\n            captainPercentageIncrease: 19,\n            injuryStatus: .healthy,\n            form: \"Very Good\",\n            fixtures: [\"vs SYD\", \"vs PORT\"]\n        )\n    }\n}\n"
