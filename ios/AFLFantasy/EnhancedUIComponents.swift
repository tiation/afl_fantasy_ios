//
//  EnhancedUIComponents.swift
//  AFL Fantasy Intelligence Platform
//
//  Enhanced UI components with smart animations and loading states
//  Created by AI Assistant on 6/9/2025.
//

import SwiftUI
import UIKit

// MARK: - SmartCardModifier

struct SmartCardModifier: ViewModifier {
    let importance: DesignSystem.CardImportance
    let interactionStyle: DesignSystem.InteractionStyle

    @State private var isPressed = false
    @State private var hapticFeedback: UIImpactFeedbackGenerator?

    func body(content: Content) -> some View {
        content
            .padding(DesignSystem.Spacing.m.value)
            .background(cardBackground)
            .cornerRadius(importance.cornerRadius.value)
            .shadow(
                color: DesignSystem.Shadows.low.color.opacity(importance.shadowLevel.opacity),
                radius: importance.shadowLevel.radius,
                x: importance.shadowLevel.offset.width,
                y: importance.shadowLevel.offset.height
            )
            .overlay(
                RoundedRectangle(cornerRadius: importance.cornerRadius.value)
                    .stroke(
                        DesignSystem.Colors.cardBorder(for: importance, isPressed: isPressed),
                        lineWidth: isPressed ? 2 : 1
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(DesignSystem.Motion.smartCardPress, value: isPressed)
            .onTapGesture {
                if interactionStyle != .none {
                    triggerHapticFeedback()
                }
            }
            .onLongPressGesture(
                minimumDuration: 0,
                maximumDistance: .infinity,
                pressing: { pressing in
                    isPressed = pressing
                    if pressing, interactionStyle != .none {
                        triggerHapticFeedback()
                    }
                },
                perform: {}
            )
            .onAppear {
                setupHapticFeedback()
            }
    }

    private var cardBackground: some View {
        // Smart gradient based on importance
        switch importance {
        case .primary:
            LinearGradient(
                colors: [
                    DesignSystem.Colors.surface,
                    DesignSystem.Colors.surface.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            DesignSystem.Colors.cardBackground(for: importance)
        case .tertiary:
            DesignSystem.Colors.cardBackground(for: importance)
        }
    }

    private func setupHapticFeedback() {
        hapticFeedback = UIImpactFeedbackGenerator(style: interactionStyle.feedbackStyle)
        hapticFeedback?.prepare()
    }

    private func triggerHapticFeedback() {
        hapticFeedback?.impactOccurred()
    }
}

// MARK: - SkeletonLoadingModifier

struct SkeletonLoadingModifier: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        content
            .redacted(reason: isLoading ? .placeholder : [])
            .shimmerEffect(isLoading)
    }
}

// MARK: - ShimmerEffectModifier

struct ShimmerEffectModifier: ViewModifier {
    let isActive: Bool
    @State private var moveTo: CGFloat = -0.7

    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: isActive ? [
                                Color.clear,
                                Color.white.opacity(0.4),
                                Color.clear
                            ] : [Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: moveTo * UIScreen.main.bounds.width)
                    .onAppear {
                        if isActive {
                            withAnimation(
                                Animation.linear(duration: 1.5)
                                    .repeatForever(autoreverses: false)
                            ) {
                                moveTo = 0.7
                            }
                        }
                    }
                    .opacity(isActive ? 1 : 0)
            )
            .clipped()
    }
}

// MARK: - EnhancedButtonModifier

struct EnhancedButtonModifier: ViewModifier {
    let style: AFLButtonStyle.Variant
    let isLoading: Bool
    let hapticFeedback: Bool

    @State private var hapticGenerator: UIImpactFeedbackGenerator?

    func body(content: Content) -> some View {
        HStack(spacing: DesignSystem.Spacing.s.value) {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
                    .progressViewStyle(CircularProgressViewStyle())
            }

            content
                .opacity(isLoading ? 0.7 : 1.0)
        }
        .buttonStyle(AFLButtonStyle(variant: style))
        .disabled(isLoading)
        .onAppear {
            if hapticFeedback {
                hapticGenerator = UIImpactFeedbackGenerator(style: .light)
                hapticGenerator?.prepare()
            }
        }
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    if hapticFeedback, !isLoading {
                        hapticGenerator?.impactOccurred()
                    }
                }
        )
    }
}

// MARK: - PlayerCardSkeleton

struct PlayerCardSkeleton: View {
    var body: some View {
        HStack {
            // Position indicator
            Rectangle()
                .frame(width: 6, height: 50)
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: 4) {
                // Player name
                Rectangle()
                    .frame(width: 120, height: 18)
                    .cornerRadius(4)

                HStack(spacing: 8) {
                    // Position badge
                    Rectangle()
                        .frame(width: 40, height: 14)
                        .cornerRadius(4)

                    // Price
                    Rectangle()
                        .frame(width: 60, height: 14)
                        .cornerRadius(4)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                // Current score
                Rectangle()
                    .frame(width: 40, height: 24)
                    .cornerRadius(4)

                // Breakeven
                Rectangle()
                    .frame(width: 35, height: 12)
                    .cornerRadius(4)
            }
        }
        .padding(DesignSystem.Spacing.m.value)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.medium.value)
        .shimmerEffect()
    }
}

// MARK: - TradeAnalysisSkeleton

struct TradeAnalysisSkeleton: View {
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.m.value) {
            // Trade score circle placeholder
            Circle()
                .frame(width: 120, height: 120)

            // Analysis factors
            VStack(spacing: 12) {
                ForEach(0 ..< 4, id: \.self) { _ in
                    HStack {
                        Rectangle()
                            .frame(width: 100, height: 14)
                            .cornerRadius(4)

                        Spacer()

                        Rectangle()
                            .frame(width: 60, height: 14)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.m.value)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.medium.value)
        .shimmerEffect()
    }
}

// MARK: - ScoreUpdateSkeleton

struct ScoreUpdateSkeleton: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Rectangle()
                    .frame(width: 80, height: 12)
                    .cornerRadius(4)

                Rectangle()
                    .frame(width: 120, height: 28)
                    .cornerRadius(6)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Rectangle()
                    .frame(width: 60, height: 12)
                    .cornerRadius(4)

                Rectangle()
                    .frame(width: 80, height: 20)
                    .cornerRadius(4)
            }
        }
        .padding(DesignSystem.Spacing.m.value)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.medium.value)
        .shimmerEffect()
    }
}

// MARK: - LoadingStateManager

@MainActor
class LoadingStateManager: ObservableObject {
    @Published var isLoadingPlayers = false
    @Published var isLoadingTrades = false
    @Published var isLoadingCaptain = false
    @Published var isLoadingScores = false

    func setLoading<T>(_ keyPath: ReferenceWritableKeyPath<LoadingStateManager, T>, to value: T) {
        self[keyPath: keyPath] = value
    }

    func simulateLoading<T>(
        for keyPath: ReferenceWritableKeyPath<LoadingStateManager, Bool>,
        duration: TimeInterval = 1.5
    ) async {
        setLoading(keyPath, to: true)
        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
        setLoading(keyPath, to: false)
    }
}

// MARK: - SmartLoadingView

struct SmartLoadingView<Content: View>: View {
    let isLoading: Bool
    let loadingView: Content
    let content: () -> Content

    init(
        isLoading: Bool,
        @ViewBuilder loadingView: () -> Content,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isLoading = isLoading
        self.loadingView = loadingView()
        self.content = content
    }

    var body: some View {
        if isLoading {
            loadingView
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
        } else {
            content()
                .transition(.opacity.combined(with: .scale(scale: 1.05)))
        }
    }
}

// MARK: - Performance Color Extensions

extension View {
    func performanceBasedColor(
        for currentValue: Double,
        baseline: Double,
        property: PerformanceProperty = .score
    ) -> some View {
        let color = DesignSystem.Colors.performanceColor(for: currentValue, baseline: baseline)
        return foregroundColor(color)
    }
}

enum PerformanceProperty {
    case score, price, consistency, form

    var icon: String {
        switch self {
        case .score: "star.fill"
        case .price: "dollarsign.circle.fill"
        case .consistency: "chart.line.uptrend.xyaxis"
        case .form: "flame.fill"
        }
    }
}

// MARK: - Context-Aware Components

struct ContextualMetricCard: View {
    let title: String
    let value: String
    let context: ViewContext
    let performance: Double?
    let baseline: Double?

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .typography(.caption2)
                .foregroundColor(DesignSystem.Colors.onSurfaceSecondary)

            HStack(spacing: 4) {
                Text(value)
                    .typography(.headline)
                    .performanceBasedColor(
                        for: performance ?? 1.0,
                        baseline: baseline ?? 1.0
                    )

                if let performance, let baseline {
                    Image(systemName: trendIcon(for: performance, baseline: baseline))
                        .font(.caption2)
                        .foregroundColor(DesignSystem.Colors.performanceColor(for: performance, baseline: baseline))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.s.value)
        .background(DesignSystem.Colors.surfaceElevated)
        .cornerRadius(DesignSystem.CornerRadius.small.value)
    }

    private func trendIcon(for current: Double, baseline: Double) -> String {
        let ratio = current / baseline
        switch ratio {
        case 1.1...: return "arrow.up.right"
        case 0.9 ..< 1.1: return "arrow.right"
        default: return "arrow.down.right"
        }
    }
}

enum ViewContext {
    case dashboard, trades, captain, settings

    var primaryMetrics: [String] {
        switch self {
        case .dashboard: ["Score", "Average", "Price Δ", "Projected"]
        case .trades: ["Price", "Breakeven", "Price Δ", "Consistency"]
        case .captain: ["Projected", "Confidence", "Form", "Venue"]
        case .settings: ["Cache", "Sync", "Alerts", "Version"]
        }
    }
}
