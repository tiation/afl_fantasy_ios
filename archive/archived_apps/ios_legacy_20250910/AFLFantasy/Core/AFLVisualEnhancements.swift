//
//  AFLVisualEnhancements.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - AFL Team Colors & Branding

extension Color {
    // Official AFL Team Colors
    static let aflTeamColors = AFLTeamColors()

    struct AFLTeamColors {
        // Adelaide Crows
        let adelaide = TeamColors(
            primary: Color(red: 0.0, green: 0.13, blue: 0.36), // Navy
            secondary: Color(red: 1.0, green: 0.17, blue: 0.15), // Red
            accent: Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
        )

        // Brisbane Lions
        let brisbane = TeamColors(
            primary: Color(red: 0.5, green: 0.15, blue: 0.15), // Maroon
            secondary: Color(red: 1.0, green: 0.84, blue: 0.0), // Gold
            accent: Color(red: 0.0, green: 0.28, blue: 0.67) // Blue
        )

        // Carlton Blues
        let carlton = TeamColors(
            primary: Color(red: 0.0, green: 0.28, blue: 0.67), // Blue
            secondary: Color(red: 0.0, green: 0.13, blue: 0.36), // Navy
            accent: Color.white
        )

        // Collingwood Magpies
        let collingwood = TeamColors(
            primary: Color.black,
            secondary: Color.white,
            accent: Color(red: 0.8, green: 0.8, blue: 0.8) // Light grey
        )

        // Essendon Bombers
        let essendon = TeamColors(
            primary: Color(red: 1.0, green: 0.17, blue: 0.15), // Red
            secondary: Color.black,
            accent: Color(red: 0.6, green: 0.6, blue: 0.6) // Grey
        )

        // Fremantle Dockers
        let fremantle = TeamColors(
            primary: Color(red: 0.29, green: 0.0, blue: 0.51), // Purple
            secondary: Color.white,
            accent: Color(red: 0.0, green: 0.66, blue: 0.42) // Green
        )

        // Geelong Cats
        let geelong = TeamColors(
            primary: Color(red: 0.0, green: 0.28, blue: 0.67), // Blue
            secondary: Color.white,
            accent: Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
        )

        // Gold Coast Suns
        let goldCoast = TeamColors(
            primary: Color(red: 1.0, green: 0.17, blue: 0.15), // Red
            secondary: Color(red: 1.0, green: 0.84, blue: 0.0), // Gold
            accent: Color(red: 0.0, green: 0.28, blue: 0.67) // Blue
        )

        // Greater Western Sydney Giants
        let gws = TeamColors(
            primary: Color(red: 1.0, green: 0.5, blue: 0.0), // Orange
            secondary: Color(red: 0.2, green: 0.2, blue: 0.2), // Charcoal
            accent: Color.white
        )

        // Hawthorn Hawks
        let hawthorn = TeamColors(
            primary: Color(red: 0.52, green: 0.27, blue: 0.07), // Brown
            secondary: Color(red: 1.0, green: 0.84, blue: 0.0), // Gold
            accent: Color.black
        )

        // Melbourne Demons
        let melbourne = TeamColors(
            primary: Color(red: 1.0, green: 0.17, blue: 0.15), // Red
            secondary: Color(red: 0.0, green: 0.28, blue: 0.67), // Blue
            accent: Color.white
        )

        // North Melbourne Kangaroos
        let northMelbourne = TeamColors(
            primary: Color(red: 0.0, green: 0.28, blue: 0.67), // Blue
            secondary: Color.white,
            accent: Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
        )

        // Port Adelaide Power
        let portAdelaide = TeamColors(
            primary: Color.black,
            secondary: Color.white,
            accent: Color(red: 0.0, green: 0.66, blue: 0.73) // Teal
        )

        // Richmond Tigers
        let richmond = TeamColors(
            primary: Color.black,
            secondary: Color(red: 1.0, green: 0.84, blue: 0.0), // Gold
            accent: Color(red: 1.0, green: 0.17, blue: 0.15) // Red
        )

        // St Kilda Saints
        let stKilda = TeamColors(
            primary: Color(red: 1.0, green: 0.17, blue: 0.15), // Red
            secondary: Color.black,
            accent: Color.white
        )

        // Sydney Swans
        let sydney = TeamColors(
            primary: Color(red: 1.0, green: 0.17, blue: 0.15), // Red
            secondary: Color.white,
            accent: Color(red: 0.0, green: 0.13, blue: 0.36) // Navy
        )

        // West Coast Eagles
        let westCoast = TeamColors(
            primary: Color(red: 0.0, green: 0.28, blue: 0.67), // Blue
            secondary: Color(red: 1.0, green: 0.84, blue: 0.0), // Gold
            accent: Color.white
        )

        // Western Bulldogs
        let westernBulldogs = TeamColors(
            primary: Color(red: 0.0, green: 0.28, blue: 0.67), // Blue
            secondary: Color(red: 1.0, green: 0.17, blue: 0.15), // Red
            accent: Color.white
        )

        // Helper to get team colors by name
        func colors(for team: String) -> TeamColors {
            switch team.lowercased() {
            case "adelaide", "crows": adelaide
            case "brisbane", "lions": brisbane
            case "carlton", "blues": carlton
            case "collingwood", "magpies": collingwood
            case "essendon", "bombers": essendon
            case "fremantle", "dockers": fremantle
            case "geelong", "cats": geelong
            case "gold coast", "suns": goldCoast
            case "gws", "giants": gws
            case "hawthorn", "hawks": hawthorn
            case "melbourne", "demons": melbourne
            case "north melbourne", "kangaroos": northMelbourne
            case "port adelaide", "power": portAdelaide
            case "richmond", "tigers": richmond
            case "st kilda", "saints": stKilda
            case "sydney", "swans": sydney
            case "west coast", "eagles": westCoast
            case "western bulldogs", "bulldogs": westernBulldogs
            default: AFLTeamColors.TeamColors(primary: .orange, secondary: .white, accent: .blue)
            }
        }
    }

    struct TeamColors {
        let primary: Color
        let secondary: Color
        let accent: Color

        var gradient: LinearGradient {
            LinearGradient(
                colors: [primary, secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        var threeColorGradient: LinearGradient {
            LinearGradient(
                colors: [primary, accent, secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - AFL Themed Gradients

extension LinearGradient {
    // Stadium atmosphere gradients
    static let stadiumSunset = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.6, blue: 0.0), // Orange
            Color(red: 1.0, green: 0.3, blue: 0.3), // Red-orange
            Color(red: 0.4, green: 0.0, blue: 0.6) // Purple
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let grassField = LinearGradient(
        colors: [
            Color(red: 0.2, green: 0.8, blue: 0.2), // Bright green
            Color(red: 0.1, green: 0.6, blue: 0.1) // Dark green
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let nightGame = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.05, blue: 0.2), // Dark blue
            Color.black,
            Color(red: 0.1, green: 0.1, blue: 0.4) // Navy
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let premiumGold = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.84, blue: 0.0), // Gold
            Color(red: 1.0, green: 0.65, blue: 0.0), // Orange gold
            Color(red: 0.8, green: 0.52, blue: 0.0) // Bronze
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let footballLeather = LinearGradient(
        colors: [
            Color(red: 0.65, green: 0.35, blue: 0.15), // Brown
            Color(red: 0.45, green: 0.25, blue: 0.1), // Dark brown
            Color(red: 0.8, green: 0.5, blue: 0.2) // Light brown
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - AFL Team Emojis & Icons

enum AFLTeamInfo {
    static let teamEmojis: [String: String] = [
        "adelaide": "🦅", "crows": "🦅",
        "brisbane": "🦁", "lions": "🦁",
        "carlton": "🔵", "blues": "🔵",
        "collingwood": "⚫", "magpies": "⚫",
        "essendon": "💣", "bombers": "💣",
        "fremantle": "⚓", "dockers": "⚓",
        "geelong": "🐱", "cats": "🐱",
        "gold coast": "☀️", "suns": "☀️",
        "gws": "⭐", "giants": "⭐",
        "hawthorn": "🦅", "hawks": "🦅",
        "melbourne": "😈", "demons": "😈",
        "north melbourne": "🦘", "kangaroos": "🦘",
        "port adelaide": "⚡", "power": "⚡",
        "richmond": "🐅", "tigers": "🐅",
        "st kilda": "😇", "saints": "😇",
        "sydney": "🦢", "swans": "🦢",
        "west coast": "🦅", "eagles": "🦅",
        "western bulldogs": "🐕", "bulldogs": "🐕"
    ]

    static func emoji(for team: String) -> String {
        teamEmojis[team.lowercased()] ?? "🏈"
    }

    static let aflSeasonEmojis = ["🏈", "⚽", "🥅", "🏟️", "🏆", "⭐", "🔥", "⚡", "💪", "🎯"]
}

// MARK: - Enhanced AFL-themed Components

struct AFLTeamCard: View {
    let teamName: String
    let isSelected: Bool
    let action: () -> Void

    private var teamColors: Color.TeamColors {
        Color.aflTeamColors.colors(for: teamName)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Team emoji with glow effect
                Text(AFLTeamInfo.emoji(for: teamName))
                    .font(.system(size: 40))
                    .shadow(color: teamColors.primary.opacity(0.6), radius: isSelected ? 8 : 0)
                    .scaleEffect(isSelected ? 1.1 : 1.0)

                Text(teamName.capitalized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? teamColors.primary : .secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? teamColors.gradient.opacity(0.2) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? teamColors.primary : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 3 : 1
                            )
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

struct AFLScoreCard: View {
    let title: String
    let score: Int
    let subtitle: String?
    let teamName: String?

    private var teamColors: Color.TeamColors? {
        guard let team = teamName else { return nil }
        return Color.aflTeamColors.colors(for: team)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Title with team emoji
            HStack(spacing: 6) {
                if let team = teamName {
                    Text(AFLTeamInfo.emoji(for: team))
                        .font(.title3)
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }

            // Main score
            Text("\(score)")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundColor(teamColors?.primary ?? .primary)
                .contentTransition(.numericText())

            // Subtitle
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(teamColors?.gradient.opacity(0.1) ?? Color(UIColor.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(teamColors?.primary.opacity(0.3) ?? Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: teamColors?.primary.opacity(0.2) ?? Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct AFLPlayerCard: View {
    let player: Player
    let teamName: String?
    let isSelected: Bool
    let onTap: () -> Void

    private var teamColors: Color.TeamColors? {
        guard let team = teamName else { return nil }
        return Color.aflTeamColors.colors(for: team)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with team colors
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(player.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        if let team = teamName {
                            HStack(spacing: 4) {
                                Text(AFLTeamInfo.emoji(for: team))
                                Text(team.capitalized)
                                    .font(.caption)
                                    .foregroundColor(teamColors?.primary ?? .secondary)
                            }
                        }
                    }

                    Spacer()

                    // Price with trend indicator
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("$\(player.price, specifier: "%.0f")k")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(teamColors?.primary ?? .primary)

                        // Price change indicator
                        if let priceChange = player.priceChange {
                            HStack(spacing: 2) {
                                Image(systemName: priceChange > 0 ? "arrow.up" : "arrow.down")
                                Text("$\(abs(priceChange))k")
                            }
                            .font(.caption2)
                            .foregroundColor(priceChange > 0 ? .green : .red)
                        }
                    }
                }

                // Stats row
                HStack(spacing: 16) {
                    StatItem(label: "Avg", value: String(format: "%.1f", player.averageScore))
                    StatItem(label: "Last", value: "\(player.lastScore ?? 0)")
                    StatItem(label: "Own%", value: String(format: "%.1f%%", player.ownership))
                }
                .font(.caption)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? teamColors?.gradient.opacity(0.15) : Color(UIColor.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? teamColors?.primary.opacity(0.5) : Color.clear,
                                lineWidth: isSelected ? 2 : 0
                            )
                    )
            )
            .shadow(
                color: isSelected ? teamColors?.primary.opacity(0.3) : Color.black.opacity(0.1),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }

    private struct StatItem: View {
        let label: String
        let value: String

        var body: some View {
            VStack(spacing: 2) {
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Football-themed Loading Animations

struct AFLLoadingAnimation: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.8

    var body: some View {
        VStack(spacing: 16) {
            // Rotating football
            Text("🏈")
                .font(.system(size: 50))
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: scale)
                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: rotation)

            Text("Loading AFL Data...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .onAppear {
            rotation = 360
            scale = 1.2
        }
    }
}

struct AFLPulsatingDot: View {
    let color: Color
    let size: CGFloat
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.3

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .opacity(opacity)
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: scale)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: opacity)
            .onAppear {
                scale = 1.0
                opacity = 1.0
            }
    }
}

struct AFLWaveLoader: View {
    let teamName: String?
    private let dots = 5
    @State private var animationOffsets: [CGFloat]

    private var teamColors: Color.TeamColors? {
        guard let team = teamName else { return nil }
        return Color.aflTeamColors.colors(for: team)
    }

    init(teamName: String? = nil) {
        self.teamName = teamName
        _animationOffsets = State(initialValue: Array(repeating: 0, count: 5))
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< dots, id: \.self) { index in
                Circle()
                    .fill(teamColors?.primary ?? .orange)
                    .frame(width: 12, height: 12)
                    .offset(y: animationOffsets[index])
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        for index in 0 ..< dots {
            withAnimation(
                .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.1)
            ) {
                animationOffsets[index] = -20
            }
        }
    }
}

// MARK: - Celebration Effects

struct AFLCelebrationOverlay: View {
    @State private var emojis: [CelebrationEmoji] = []
    @State private var isAnimating = false

    struct CelebrationEmoji: Identifiable {
        let id = UUID()
        let emoji: String
        let startX: CGFloat
        let startY: CGFloat
        let endX: CGFloat
        let endY: CGFloat
        let rotation: Double
        let scale: CGFloat
    }

    var body: some View {
        ZStack {
            ForEach(emojis) { emoji in
                Text(emoji.emoji)
                    .font(.system(size: 30 * emoji.scale))
                    .position(
                        x: isAnimating ? emoji.endX : emoji.startX,
                        y: isAnimating ? emoji.endY : emoji.startY
                    )
                    .rotationEffect(.degrees(isAnimating ? emoji.rotation : 0))
                    .opacity(isAnimating ? 0 : 1)
            }
        }
        .allowsHitTesting(false)
    }

    func celebrate() {
        let celebrationEmojis = ["🏆", "⭐", "🔥", "💪", "🎉", "✨", "⚡", "🏈"]
        emojis = []

        for _ in 0 ..< 15 {
            let emoji = CelebrationEmoji(
                emoji: celebrationEmojis.randomElement() ?? "🎉",
                startX: CGFloat.random(in: 50 ... 350),
                startY: CGFloat.random(in: 100 ... 400),
                endX: CGFloat.random(in: 0 ... 400),
                endY: CGFloat.random(in: -100 ... 100),
                rotation: Double.random(in: 0 ... 720),
                scale: CGFloat.random(in: 0.5 ... 1.5)
            )
            emojis.append(emoji)
        }

        withAnimation(.easeOut(duration: 2)) {
            isAnimating = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            emojis.removeAll()
            isAnimating = false
        }
    }
}

// MARK: - Button Styles

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AFLButtonStyle: ButtonStyle {
    let teamName: String?

    private var teamColors: Color.TeamColors? {
        guard let team = teamName else { return nil }
        return Color.aflTeamColors.colors(for: team)
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(teamColors?.secondary ?? .white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(teamColors?.gradient ?? LinearGradient.premiumGold)
                    .shadow(color: teamColors?.primary.opacity(0.4) ?? Color.orange.opacity(0.4), radius: 4, x: 0, y: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
