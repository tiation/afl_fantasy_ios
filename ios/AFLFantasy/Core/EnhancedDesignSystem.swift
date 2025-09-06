//
//  EnhancedDesignSystem.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - EnhancedDesignSystem

/// Enhanced AFL Fantasy Design System with premium visual hierarchy and animations
enum EnhancedDesignSystem {
    // MARK: - Colors

    enum Colors {
        // AFL Primary Colors
        static let aflOrange = Color(red: 1.0, green: 0.4, blue: 0.0) // #FF6600
        static let aflDeepOrange = Color(red: 0.9, green: 0.3, blue: 0.0) // #E54C00
        static let aflGold = Color(red: 1.0, green: 0.8, blue: 0.2) // #FFCC33

        // Semantic Colors
        static let success = Color(red: 0.2, green: 0.8, blue: 0.3) // #33CC4D
        static let warning = Color(red: 1.0, green: 0.6, blue: 0.0) // #FF9900
        static let error = Color(red: 1.0, green: 0.2, blue: 0.2) // #FF3333
        static let info = Color(red: 0.2, green: 0.6, blue: 1.0) // #3399FF

        // Premium Gradients
        static let primaryGradient = LinearGradient(
            gradient: Gradient(colors: [aflOrange, aflDeepOrange]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let goldGradient = LinearGradient(
            gradient: Gradient(colors: [aflGold, Color.yellow]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let successGradient = LinearGradient(
            gradient: Gradient(colors: [success, Color.green]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Background Gradients
        static let darkBackgroundGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color.black.opacity(0.9),
                Color.gray.opacity(0.8)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )

        // Surface Colors
        static let surfacePrimary = Color(.systemBackground)
        static let surfaceSecondary = Color(.secondarySystemBackground)
        static let surfaceTertiary = Color(.tertiarySystemBackground)

        // Text Colors
        static let textPrimary = Color(.label)
        static let textSecondary = Color(.secondaryLabel)
        static let textTertiary = Color(.tertiaryLabel)
        static let textInverse = Color.white
    }

    // MARK: - Typography

    enum Typography {
        // Scales
        static let largeTitle = Font.largeTitle.weight(.heavy)
        static let title1 = Font.title.weight(.bold)
        static let title2 = Font.title2.weight(.semibold)
        static let headline = Font.headline.weight(.semibold)
        static let subheadline = Font.subheadline.weight(.medium)
        static let body = Font.body
        static let callout = Font.callout
        static let caption1 = Font.caption.weight(.medium)
        static let caption2 = Font.caption2

        // AFL Specific
        static let heroTitle = Font.system(size: 48, weight: .black, design: .default)
        static let scoreDisplay = Font.system(size: 64, weight: .heavy, design: .monospaced)
        static let playerName = Font.system(size: 18, weight: .semibold, design: .default)
        static let teamName = Font.system(size: 14, weight: .bold, design: .default)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48

        // Component specific
        static let cardPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let listItemSpacing: CGFloat = 12
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24

        // Component specific
        static let card: CGFloat = 16
        static let button: CGFloat = 12
        static let chip: CGFloat = 20
    }

    // MARK: - Shadows

    enum Shadow {
        static let light = (color: Color.black.opacity(0.1), radius: 4.0, offset: CGSize(width: 0, height: 2))
        static let medium = (color: Color.black.opacity(0.15), radius: 8.0, offset: CGSize(width: 0, height: 4))
        static let heavy = (color: Color.black.opacity(0.2), radius: 12.0, offset: CGSize(width: 0, height: 6))

        // AFL specific
        static let glow = (color: Colors.aflOrange.opacity(0.3), radius: 8.0, offset: CGSize(width: 0, height: 0))
        static let scoreGlow = (color: Colors.aflGold.opacity(0.4), radius: 12.0, offset: CGSize(width: 0, height: 0))
    }

    // MARK: - Animations

    enum Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let bounce = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.2)
        static let elastic = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.1)

        // AFL specific
        static let scoreUpdate = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3)
        static let celebration = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0.2)
    }
}

// MARK: - View Extensions

extension View {
    // MARK: - Card Styling

    func aflCard(padding: CGFloat = EnhancedDesignSystem.Spacing.cardPadding) -> some View {
        self
            .padding(padding)
            .background(EnhancedDesignSystem.Colors.surfaceSecondary)
            .cornerRadius(EnhancedDesignSystem.CornerRadius.card)
            .shadow(
                color: EnhancedDesignSystem.Shadow.medium.color,
                radius: EnhancedDesignSystem.Shadow.medium.radius,
                x: EnhancedDesignSystem.Shadow.medium.offset.width,
                y: EnhancedDesignSystem.Shadow.medium.offset.height
            )
    }

    func aflGlowCard(padding: CGFloat = EnhancedDesignSystem.Spacing.cardPadding) -> some View {
        self
            .padding(padding)
            .background(EnhancedDesignSystem.Colors.surfaceSecondary)
            .cornerRadius(EnhancedDesignSystem.CornerRadius.card)
            .shadow(
                color: EnhancedDesignSystem.Shadow.glow.color,
                radius: EnhancedDesignSystem.Shadow.glow.radius,
                x: EnhancedDesignSystem.Shadow.glow.offset.width,
                y: EnhancedDesignSystem.Shadow.glow.offset.height
            )
            .overlay(
                RoundedRectangle(cornerRadius: EnhancedDesignSystem.CornerRadius.card)
                    .stroke(EnhancedDesignSystem.Colors.aflOrange.opacity(0.3), lineWidth: 1)
            )
    }

    // MARK: - Button Styling

    func aflPrimaryButton() -> some View {
        font(EnhancedDesignSystem.Typography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(EnhancedDesignSystem.Colors.primaryGradient)
            .cornerRadius(EnhancedDesignSystem.CornerRadius.button)
            .shadow(
                color: EnhancedDesignSystem.Shadow.medium.color,
                radius: EnhancedDesignSystem.Shadow.medium.radius,
                x: EnhancedDesignSystem.Shadow.medium.offset.width,
                y: EnhancedDesignSystem.Shadow.medium.offset.height
            )
    }

    func aflSecondaryButton() -> some View {
        font(EnhancedDesignSystem.Typography.headline)
            .foregroundColor(EnhancedDesignSystem.Colors.aflOrange)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(EnhancedDesignSystem.Colors.surfaceSecondary)
            .cornerRadius(EnhancedDesignSystem.CornerRadius.button)
            .overlay(
                RoundedRectangle(cornerRadius: EnhancedDesignSystem.CornerRadius.button)
                    .stroke(EnhancedDesignSystem.Colors.aflOrange, lineWidth: 2)
            )
    }

    // MARK: - Typography

    func aflHeroTitle() -> some View {
        font(EnhancedDesignSystem.Typography.heroTitle)
            .foregroundColor(EnhancedDesignSystem.Colors.textPrimary)
    }

    func aflScoreDisplay() -> some View {
        font(EnhancedDesignSystem.Typography.scoreDisplay)
            .foregroundColor(EnhancedDesignSystem.Colors.aflOrange)
            .shadow(
                color: EnhancedDesignSystem.Shadow.scoreGlow.color,
                radius: EnhancedDesignSystem.Shadow.scoreGlow.radius,
                x: EnhancedDesignSystem.Shadow.scoreGlow.offset.width,
                y: EnhancedDesignSystem.Shadow.scoreGlow.offset.height
            )
    }

    func aflPlayerName() -> some View {
        font(EnhancedDesignSystem.Typography.playerName)
            .foregroundColor(EnhancedDesignSystem.Colors.textPrimary)
    }

    // MARK: - Animations

    func aflBounceOnTap() -> some View {
        scaleEffect(1.0)
            .onTapGesture {
                withAnimation(EnhancedDesignSystem.Animation.bounce) {
                    // Animation will be handled by parent view
                }
            }
    }

    func aflPulseAnimation(_ isAnimating: Bool) -> some View {
        scaleEffect(isAnimating ? 1.05 : 1.0)
            .opacity(isAnimating ? 0.8 : 1.0)
            .animation(
                EnhancedDesignSystem.Animation.elastic.repeatForever(autoreverses: true),
                value: isAnimating
            )
    }

    // MARK: - AFL Background

    func aflBackground() -> some View {
        background(EnhancedDesignSystem.Colors.darkBackgroundGradient)
    }
}

// MARK: - Custom Components

/// Premium AFL-themed button with haptic feedback
struct AFLButton: View {
    let title: String
    let style: Style
    let action: () -> Void

    @State private var isPressed = false

    enum Style {
        case primary
        case secondary
        case success
        case warning
    }

    var body: some View {
        Button(action: {
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            action()
        }) {
            Text(title)
                .font(EnhancedDesignSystem.Typography.headline)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(backgroundGradient)
                .cornerRadius(EnhancedDesignSystem.CornerRadius.button)
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .shadow(
                    color: shadowColor,
                    radius: isPressed ? 2 : 6,
                    x: 0,
                    y: isPressed ? 1 : 3
                )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(EnhancedDesignSystem.Animation.quick) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }

    private var textColor: Color {
        switch style {
        case .primary, .success, .warning:
            .white
        case .secondary:
            EnhancedDesignSystem.Colors.aflOrange
        }
    }

    private var backgroundGradient: LinearGradient {
        switch style {
        case .primary:
            EnhancedDesignSystem.Colors.primaryGradient
        case .secondary:
            LinearGradient(colors: [EnhancedDesignSystem.Colors.surfaceSecondary], startPoint: .top, endPoint: .bottom)
        case .success:
            EnhancedDesignSystem.Colors.successGradient
        case .warning:
            LinearGradient(
                gradient: Gradient(colors: [EnhancedDesignSystem.Colors.warning, Color.orange]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary:
            EnhancedDesignSystem.Colors.aflOrange.opacity(0.3)
        case .secondary:
            Color.black.opacity(0.1)
        case .success:
            EnhancedDesignSystem.Colors.success.opacity(0.3)
        case .warning:
            EnhancedDesignSystem.Colors.warning.opacity(0.3)
        }
    }
}

/// Premium loading animation for AFL Fantasy
struct AFLLoadingAnimation: View {
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(
                        EnhancedDesignSystem.Colors.aflOrange.opacity(0.3),
                        lineWidth: 4
                    )
                    .frame(width: 60, height: 60)

                // Animated ring
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        EnhancedDesignSystem.Colors.primaryGradient,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(rotationAngle))
                    .animation(
                        .linear(duration: 1.5).repeatForever(autoreverses: false),
                        value: rotationAngle
                    )

                // Football icon
                Image(systemName: "football.fill")
                    .font(.title2)
                    .foregroundColor(EnhancedDesignSystem.Colors.aflOrange)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(
                        EnhancedDesignSystem.Animation.bounce.repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
            rotationAngle = 360
        }
    }
}

/// AFL-themed score display with glow effect
struct AFLScoreDisplay: View {
    let score: Int
    let label: String
    let color: Color
    @State private var animateScore = false

    var body: some View {
        VStack(spacing: 8) {
            Text("\(score)")
                .font(EnhancedDesignSystem.Typography.scoreDisplay)
                .foregroundColor(color)
                .shadow(
                    color: color.opacity(0.4),
                    radius: animateScore ? 15 : 8,
                    x: 0,
                    y: 0
                )
                .scaleEffect(animateScore ? 1.05 : 1.0)
                .animation(
                    EnhancedDesignSystem.Animation.scoreUpdate,
                    value: score
                )
                .onAppear {
                    withAnimation(EnhancedDesignSystem.Animation.scoreUpdate) {
                        animateScore = true
                    }
                }
                .onChange(of: score) { _, _ in
                    withAnimation(EnhancedDesignSystem.Animation.scoreUpdate) {
                        animateScore.toggle()
                    }
                }

            Text(label)
                .font(EnhancedDesignSystem.Typography.caption1)
                .foregroundColor(EnhancedDesignSystem.Colors.textSecondary)
                .textCase(.uppercase)
                .tracking(1.0)
        }
    }
}

/// AFL team colors helper
extension AFLTeam {
    var primaryColor: Color {
        switch self {
        case .adelaide: Color.red
        case .brisbane: Color.red
        case .carlton: Color.blue
        case .collingwood: Color.black
        case .essendon: Color.red
        case .fremantle: Color.purple
        case .geelong: Color.blue
        case .goldCoast: Color.red
        case .gws: Color.orange
        case .hawthorn: Color.brown
        case .melbourne: Color.red
        case .northMelbourne: Color.blue
        case .portAdelaide: Color.teal
        case .richmond: Color.yellow
        case .stKilda: Color.red
        case .sydney: Color.red
        case .westCoast: Color.blue
        case .westernBulldogs: Color.red
        }
    }

    var secondaryColor: Color {
        switch self {
        case .adelaide: Color.blue
        case .brisbane: Color.blue
        case .carlton: Color.white
        case .collingwood: Color.white
        case .essendon: Color.black
        case .fremantle: Color.white
        case .geelong: Color.white
        case .goldCoast: Color.yellow
        case .gws: Color.black
        case .hawthorn: Color.yellow
        case .melbourne: Color.blue
        case .northMelbourne: Color.white
        case .portAdelaide: Color.black
        case .richmond: Color.black
        case .stKilda: Color.black
        case .sydney: Color.white
        case .westCoast: Color.yellow
        case .westernBulldogs: Color.blue
        }
    }

    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [primaryColor, secondaryColor]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
