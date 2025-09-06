//
//  PlayerCardWithImage.swift
//  AFL Fantasy Intelligence Platform
//
//  Player card component with image support
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI

// MARK: - PlayerCardWithImage

struct PlayerCardWithImage: View {
    let player: EnhancedPlayer
    let size: CGFloat
    let showStats: Bool
    let onTap: (() -> Void)?

    @EnvironmentObject private var appState: AppState

    init(
        player: EnhancedPlayer,
        size: CGFloat = 60,
        showStats: Bool = true,
        onTap: (() -> Void)? = nil
    ) {
        self.player = player
        self.size = size
        self.showStats = showStats
        self.onTap = onTap
    }

    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(spacing: 12) {
                // Player image
                PlayerImageView(
                    playerId: player.id,
                    playerName: player.name,
                    size: size
                )

                // Player information
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(player.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Spacer()

                        if appState.captain?.id == player.id {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                Text("C")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.yellow)
                            .cornerRadius(3)
                        }
                    }

                    HStack(spacing: 8) {
                        // Position badge
                        Text(player.position.rawValue)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(player.position.color)
                            .cornerRadius(3)

                        Text(player.team)
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(player.formattedPrice)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }

                    if showStats {
                        HStack(spacing: 16) {
                            StatPill(title: "Avg", value: "\(Int(player.averageScore))", color: .blue)
                            StatPill(title: "Form", value: "\(Int(player.currentScore))", color: .green)
                            StatPill(title: "BE", value: "\(player.breakeven)", color: .orange)
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - CaptainSuggestionCard

struct CaptainSuggestionCard: View {
    let player: EnhancedPlayer
    let onCaptainTap: () -> Void

    var body: some View {
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
                        Text(player.position.rawValue)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(player.position.color)
                            .cornerRadius(3)

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

                Button(action: onCaptainTap) {
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
}

// MARK: - StatPill

struct StatPill: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)

            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
}

// MARK: - PlayerPosition Extension

extension PlayerPosition {
    var color: Color {
        switch self {
        case .def: .blue
        case .mid: .green
        case .ruck: .purple
        case .fwd: .red
        }
    }
}

// MARK: - Preview

#Preview("Player Card") {
    VStack(spacing: 12) {
        PlayerCardWithImage(
            player: EnhancedPlayer.mockPlayer(),
            size: 60,
            showStats: true
        )

        PlayerCardWithImage(
            player: EnhancedPlayer.mockCaptainPlayer(),
            size: 60,
            showStats: true
        )
    }
    .padding()
    .environmentObject(AppState())
}

#Preview("Captain Suggestions") {
    VStack(spacing: 8) {
        CaptainSuggestionCard(
            player: EnhancedPlayer.mockCaptainSuggestion(),
            onCaptainTap: {}
        )

        CaptainSuggestionCard(
            player: EnhancedPlayer.mockCaptainSuggestion2(),
            onCaptainTap: {}
        )
    }
    .padding()
    .environmentObject(AppState())
}

// MARK: - Mock Data

extension EnhancedPlayer {
    static func mockPlayer() -> EnhancedPlayer {
        EnhancedPlayer(
            id: "123456",
            name: "Clayton Oliver",
            team: "MEL",
            position: .mid,
            price: 720_000,
            currentScore: 125,
            averageScore: 118.5,
            projectedScore: 122,
            breakeven: 45,
            consistency: 0.85,
            captainPercentageIncrease: 12,
            injuryStatus: .healthy,
            form: "Excellent",
            fixtures: ["vs RIC", "vs CAR"]
        )
    }

    static func mockCaptainPlayer() -> EnhancedPlayer {
        EnhancedPlayer(
            id: "789012",
            name: "Max Gawn",
            team: "MEL",
            position: .ruck,
            price: 650_000,
            currentScore: 142,
            averageScore: 135.2,
            projectedScore: 138,
            breakeven: 28,
            consistency: 0.92,
            captainPercentageIncrease: 18,
            injuryStatus: .healthy,
            form: "Outstanding",
            fixtures: ["vs RIC", "vs CAR"]
        )
    }

    static func mockCaptainSuggestion() -> EnhancedPlayer {
        EnhancedPlayer(
            id: "345678",
            name: "Christian Petracca",
            team: "MEL",
            position: .mid,
            price: 680_000,
            currentScore: 138,
            averageScore: 128.7,
            projectedScore: 145,
            breakeven: 35,
            consistency: 0.88,
            captainPercentageIncrease: 22,
            injuryStatus: .healthy,
            form: "Excellent",
            fixtures: ["vs RIC", "vs CAR"]
        )
    }

    static func mockCaptainSuggestion2() -> EnhancedPlayer {
        EnhancedPlayer(
            id: "901234",
            name: "Marcus Bontempelli",
            team: "WB",
            position: .mid,
            price: 695_000,
            currentScore: 132,
            averageScore: 124.3,
            projectedScore: 140,
            breakeven: 42,
            consistency: 0.83,
            captainPercentageIncrease: 19,
            injuryStatus: .healthy,
            form: "Very Good",
            fixtures: ["vs SYD", "vs PORT"]
        )
    }
}
