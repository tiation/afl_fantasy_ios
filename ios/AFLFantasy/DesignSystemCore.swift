//
//  DesignSystemCore.swift
//  AFL Fantasy Intelligence Platform
//
//  Full DesignSystem implementation integrated into main target
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI
import UIKit

// MARK: - DesignSystem

enum DesignSystem {
    // MARK: - Spacing Scale (4, 8, 12, 16, 20, 24, 32, 40)

    enum Spacing: CGFloat, CaseIterable {
        case xs = 4 // Extra small
        case s = 8 // Small
        case sm = 12 // Small-medium
        case m = 16 // Medium (standard)
        case l = 20 // Large
        case xl = 24 // Extra large
        case xxl = 32 // Double extra large
        case xxxl = 40 // Triple extra large

        var value: CGFloat { rawValue }
    }

    // MARK: - Typography System

    enum Typography {
        case largeTitle
        case title1
        case title2
        case title3
        case headline
        case body
        case bodySecondary
        case callout
        case caption1
        case caption2
        case footnote

        var font: Font {
            switch self {
            case .largeTitle: .largeTitle.weight(.bold)
            case .title1: .title.weight(.semibold)
            case .title2: .title2.weight(.semibold)
            case .title3: .title3.weight(.medium)
            case .headline: .headline
            case .body: .body
            case .bodySecondary: .body.weight(.medium)
            case .callout: .callout
            case .caption1: .caption
            case .caption2: .caption2
            case .footnote: .footnote
            }
        }

        var uiFont: UIFont {
            switch self {
            case .largeTitle: UIFont.preferredFont(forTextStyle: .largeTitle)
            case .title1: UIFont.preferredFont(forTextStyle: .title1)
            case .title2: UIFont.preferredFont(forTextStyle: .title2)
            case .title3: UIFont.preferredFont(forTextStyle: .title3)
            case .headline: UIFont.preferredFont(forTextStyle: .headline)
            case .body: UIFont.preferredFont(forTextStyle: .body)
            case .bodySecondary: UIFont.preferredFont(forTextStyle: .body)
            case .callout: UIFont.preferredFont(forTextStyle: .callout)
            case .caption1: UIFont.preferredFont(forTextStyle: .caption1)
            case .caption2: UIFont.preferredFont(forTextStyle: .caption2)
            case .footnote: UIFont.preferredFont(forTextStyle: .footnote)
            }
        }
    }

    // MARK: - Color System

    enum Colors {
        // Primary AFL Fantasy Brand
        static let primary = Color.orange
        static let primaryVariant = Color.orange.opacity(0.8)

        // Semantic Colors
        static let success = Color.green
        static let warning = Color.yellow
        static let error = Color.red
        static let info = Color.blue

        // Surface Colors
        static let surface = Color(.secondarySystemBackground)
        static let surfaceElevated = Color(.tertiarySystemBackground)
        static let background = Color(.systemBackground)

        // Content Colors
        static let onSurface = Color(.label)
        static let onSurfaceSecondary = Color(.secondaryLabel)
        static let onSurfaceTertiary = Color(.tertiaryLabel)
        static let onBackground = Color(.label)

        // Interactive States
        static func buttonColor(for state: ButtonState) -> Color {
            switch state {
            case .normal: primary
            case .pressed: primary.opacity(0.8)
            case .disabled: Color(.systemGray3)
            }
        }

        // Position Colors (AFL Fantasy specific)
        static let defender = Color.blue
        static let midfielder = Color.green
        static let ruck = Color.purple
        static let forward = Color.red

        // Performance Colors
        static let priceRise = Color.green
        static let priceDrop = Color.red
        static let priceStable = Color.gray

        enum ButtonState {
            case normal, pressed, disabled
        }
    }

    // MARK: - Motion System

    enum Motion {
        // Standard Durations (respects Reduce Motion)
        static let quick: TimeInterval = 0.15 // 120-160ms
        static let standard: TimeInterval = 0.2 // 200ms
        static let enter: TimeInterval = 0.22 // 220ms
        static let exit: TimeInterval = 0.18 // 180ms

        // Easing Functions
        static let easeInOut = Animation.easeInOut(duration: standard)
        static let bouncy = Animation.interpolatingSpring(
            mass: 1, stiffness: 100, damping: 10, initialVelocity: 0
        )

        // Reduce Motion Aware Animations
        static var tasteful: Animation {
            UIAccessibility.isReduceMotionEnabled
                ? .linear(duration: 0.01)
                : .easeInOut(duration: standard)
        }

        static var gentleSpring: Animation {
            UIAccessibility.isReduceMotionEnabled
                ? .linear(duration: 0.01)
                : bouncy
        }
    }

    // MARK: - Shadow System

    enum Shadows {
        case low, medium, high

        var offset: CGSize {
            switch self {
            case .low: CGSize(width: 0, height: 2)
            case .medium: CGSize(width: 0, height: 6)
            case .high: CGSize(width: 0, height: 12)
            }
        }

        var radius: CGFloat {
            switch self {
            case .low: 8
            case .medium: 16
            case .high: 32
            }
        }

        var opacity: Double {
            switch self {
            case .low: 0.12
            case .medium: 0.16
            case .high: 0.2
            }
        }

        var color: Color { .black }
    }

    // MARK: - Corner Radius System

    enum CornerRadius: CGFloat {
        case small = 8 // Buttons
        case medium = 12 // Cards
        case large = 16 // Sheets/Dialogs
        case xlarge = 20 // Large containers

        var value: CGFloat { rawValue }
    }

    // MARK: - Icon Sizes

    enum IconSize: CGFloat {
        case small = 16
        case medium = 20
        case large = 24
        case xlarge = 32

        var value: CGFloat { rawValue }
    }
}

// MARK: - View Extensions for Design System

extension View {
    // MARK: - Spacing

    func padding(_ spacing: DesignSystem.Spacing) -> some View {
        padding(spacing.value)
    }

    func padding(_ edges: Edge.Set, _ spacing: DesignSystem.Spacing) -> some View {
        padding(edges, spacing.value)
    }

    // MARK: - Typography

    func typography(_ style: DesignSystem.Typography) -> some View {
        font(style.font)
    }

    // MARK: - Shadows

    func shadow(_ level: DesignSystem.Shadows) -> some View {
        shadow(
            color: level.color.opacity(level.opacity),
            radius: level.radius,
            x: level.offset.width,
            y: level.offset.height
        )
    }

    // MARK: - Corner Radius

    func cornerRadius(_ radius: DesignSystem.CornerRadius) -> some View {
        cornerRadius(radius.value)
    }

    // MARK: - Motion-aware animations

    func animate(_ condition: Bool) -> some View {
        animation(DesignSystem.Motion.tasteful, value: condition)
    }

    func animateSpring(_ condition: Bool) -> some View {
        animation(DesignSystem.Motion.gentleSpring, value: condition)
    }

    // MARK: - Performance-optimized modifiers

    func performantCard() -> some View {
        background(DesignSystem.Colors.surface)
            .cornerRadius(.medium)
            .shadow(.low)
    }

    func performantButton() -> some View {
        padding(.horizontal, .m)
            .padding(.vertical, .sm)
            .background(DesignSystem.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(.small)
            .scaleEffect(1.0) // Prevents layout changes during animation
    }
}

// MARK: - Custom Button Styles

struct AFLButtonStyle: ButtonStyle {
    let variant: Variant

    enum Variant {
        case primary, secondary, ghost
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, DesignSystem.Spacing.m.value)
            .padding(.vertical, DesignSystem.Spacing.sm.value)
            .background(backgroundColorFor(configuration: configuration))
            .foregroundColor(foregroundColorFor(configuration: configuration))
            .cornerRadius(DesignSystem.CornerRadius.small.value)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(DesignSystem.Motion.tasteful, value: configuration.isPressed)
    }

    private func backgroundColorFor(configuration: Configuration) -> Color {
        switch variant {
        case .primary:
            configuration.isPressed
                ? DesignSystem.Colors.primary.opacity(0.8)
                : DesignSystem.Colors.primary
        case .secondary:
            configuration.isPressed
                ? DesignSystem.Colors.surface.opacity(0.8)
                : DesignSystem.Colors.surface
        case .ghost:
            configuration.isPressed
                ? DesignSystem.Colors.primary.opacity(0.1)
                : Color.clear
        }
    }

    private func foregroundColorFor(configuration: Configuration) -> Color {
        switch variant {
        case .primary: .white
        case .secondary: DesignSystem.Colors.onSurface
        case .ghost: DesignSystem.Colors.primary
        }
    }
}
