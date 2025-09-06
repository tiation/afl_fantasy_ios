//
//  AFLAnimations.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import SwiftUI

// MARK: - AFLAnimationConfig

enum AFLAnimationConfig {
    // MARK: - Timing Constants

    static let ultraFast: TimeInterval = 0.08
    static let fast: TimeInterval = 0.15
    static let standard: TimeInterval = 0.25
    static let medium: TimeInterval = 0.4
    static let slow: TimeInterval = 0.6
    static let dramatic: TimeInterval = 1.0

    // MARK: - Easing Functions

    static let snappy = Animation.interpolatingSpring(stiffness: 400, damping: 22)
    static let bouncy = Animation.interpolatingSpring(stiffness: 300, damping: 15)
    static let smooth = Animation.easeInOut(duration: standard)
    static let gentle = Animation.easeInOut(duration: medium)
    static let dramatic = Animation.easeInOut(duration: slow)

    // MARK: - AFL-Specific Animations

    static let tradeAnimation = Animation.interpolatingSpring(stiffness: 350, damping: 20)
    static let scoreAnimation = Animation.interpolatingSpring(stiffness: 500, damping: 25)
    static let cardFlip = Animation.easeInOut(duration: 0.6)
    static let celebration = Animation.interpolatingSpring(stiffness: 200, damping: 10)

    // MARK: - Delay Functions

    static func staggeredDelay(index: Int, baseDelay: TimeInterval = 0.05) -> TimeInterval {
        TimeInterval(index) * baseDelay
    }

    static func randomDelay(range: ClosedRange<TimeInterval>) -> TimeInterval {
        TimeInterval.random(in: range)
    }
}

// MARK: - Custom Transitions

extension AnyTransition {
    // MARK: - Slide Transitions

    static let slideUpAndFade = AnyTransition.asymmetric(
        insertion: .move(edge: .bottom).combined(with: .opacity),
        removal: .move(edge: .top).combined(with: .opacity)
    )

    static let slideLeftAndFade = AnyTransition.asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal: .move(edge: .leading).combined(with: .opacity)
    )

    // MARK: - Scale Transitions

    static let scaleAndFade = AnyTransition.scale(scale: 0.8).combined(with: .opacity)

    static let popIn = AnyTransition.asymmetric(
        insertion: .scale(scale: 0.6).combined(with: .opacity),
        removal: .scale(scale: 1.2).combined(with: .opacity)
    )

    // MARK: - Rotation Transitions

    static let rotateAndFade = AnyTransition.asymmetric(
        insertion: .modifier(
            active: RotationModifier(angle: 90, opacity: 0),
            identity: RotationModifier(angle: 0, opacity: 1)
        ),
        removal: .modifier(
            active: RotationModifier(angle: -90, opacity: 0),
            identity: RotationModifier(angle: 0, opacity: 1)
        )
    )

    // MARK: - AFL-Themed Transitions

    static let goalCelebration = AnyTransition.asymmetric(
        insertion: .scale(scale: 0.1).combined(with: .opacity).combined(with: .move(edge: .bottom)),
        removal: .scale(scale: 2.0).combined(with: .opacity).combined(with: .move(edge: .top))
    )

    static let cardFlip = AnyTransition.asymmetric(
        insertion: .modifier(
            active: FlipModifier(angle: -90, opacity: 0),
            identity: FlipModifier(angle: 0, opacity: 1)
        ),
        removal: .modifier(
            active: FlipModifier(angle: 90, opacity: 0),
            identity: FlipModifier(angle: 0, opacity: 1)
        )
    )

    static let tradingNotification = AnyTransition.asymmetric(
        insertion: .move(edge: .top).combined(with: .scale(scale: 0.8)),
        removal: .move(edge: .trailing).combined(with: .opacity)
    )
}

// MARK: - Custom View Modifiers

struct RotationModifier: ViewModifier {
    let angle: Double
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(angle))
            .opacity(opacity)
    }
}

struct FlipModifier: ViewModifier {
    let angle: Double
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(angle),
                axis: (x: 0, y: 1, z: 0)
            )
            .opacity(opacity)
    }
}

struct ShakeModifier: ViewModifier {
    @State private var offset: CGFloat = 0
    let intensity: CGFloat
    let duration: TimeInterval

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onAppear {
                shake()
            }
    }

    private func shake() {
        let animation = Animation.easeInOut(duration: 0.1).repeatCount(6, autoreverses: true)
        withAnimation(animation) {
            offset = intensity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            offset = 0
        }
    }
}

struct PulseModifier: ViewModifier {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    let intensity: CGFloat
    let duration: TimeInterval

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                pulse()
            }
    }

    private func pulse() {
        let animation = Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)
        withAnimation(animation) {
            scale = 1.0 + intensity
            opacity = 0.7
        }
    }
}

struct WiggleModifier: ViewModifier {
    @State private var rotation: Double = 0
    let intensity: Double
    let speed: TimeInterval

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .onAppear {
                wiggle()
            }
    }

    private func wiggle() {
        let animation = Animation.easeInOut(duration: speed).repeatForever(autoreverses: true)
        withAnimation(animation) {
            rotation = intensity
        }
    }
}

struct FloatingModifier: ViewModifier {
    @State private var offset: CGFloat = 0
    let amplitude: CGFloat
    let duration: TimeInterval

    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onAppear {
                float()
            }
    }

    private func float() {
        let animation = Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)
        withAnimation(animation) {
            offset = amplitude
        }
    }
}

struct GlowModifier: ViewModifier {
    @State private var intensity: Double = 0.5
    let color: Color
    let radius: CGFloat
    let duration: TimeInterval

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(intensity), radius: radius)
            .onAppear {
                glow()
            }
    }

    private func glow() {
        let animation = Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)
        withAnimation(animation) {
            intensity = 1.0
        }
    }
}

// MARK: - Animated Container Views

struct AFLStaggeredList<Content: View>: View {
    let items: [AnyHashable]
    let content: (Int) -> Content
    @State private var visibleItems: Set<Int> = []

    init<Data: RandomAccessCollection>(
        items: Data,
        @ViewBuilder content: @escaping (Int) -> Content
    ) where Data.Element: Hashable {
        self.items = Array(items)
        self.content = content
    }

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(items.indices, id: \.self) { index in
                content(index)
                    .opacity(visibleItems.contains(index) ? 1 : 0)
                    .offset(y: visibleItems.contains(index) ? 0 : 30)
                    .animation(
                        AFLAnimationConfig.smooth.delay(AFLAnimationConfig.staggeredDelay(index: index)),
                        value: visibleItems.contains(index)
                    )
                    .onAppear {
                        visibleItems.insert(index)
                    }
            }
        }
    }
}

struct AFLAnimatedCounter: View {
    let value: Int
    let duration: TimeInterval
    @State private var animatedValue: Double = 0

    init(value: Int, duration: TimeInterval = 0.5) {
        self.value = value
        self.duration = duration
    }

    var body: some View {
        Text("\(Int(animatedValue))")
            .contentTransition(.numericText())
            .animation(AFLAnimationConfig.smooth, value: animatedValue)
            .onAppear {
                animateToValue()
            }
            .onChange(of: value) { _, _ in
                animateToValue()
            }
    }

    private func animateToValue() {
        withAnimation(.easeOut(duration: duration)) {
            animatedValue = Double(value)
        }
    }
}

struct AFLProgressBar: View {
    let progress: Double
    let teamName: String?
    @State private var animatedProgress: Double = 0

    private var teamColors: Color.TeamColors? {
        guard let team = teamName else { return nil }
        return Color.aflTeamColors.colors(for: team)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.2))

                // Progress fill
                RoundedRectangle(cornerRadius: 6)
                    .fill(teamColors?.gradient ?? LinearGradient.premiumGold)
                    .frame(width: geometry.size.width * animatedProgress)
                    .shadow(color: teamColors?.primary.opacity(0.4) ?? Color.orange.opacity(0.4), radius: 4)
            }
        }
        .frame(height: 12)
        .onAppear {
            withAnimation(AFLAnimationConfig.gentle.delay(0.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newProgress in
            withAnimation(AFLAnimationConfig.smooth) {
                animatedProgress = newProgress
            }
        }
    }
}

struct AFLLoadingSpinner: View {
    let teamName: String?
    @State private var rotation: Double = 0

    private var teamColors: Color.TeamColors? {
        guard let team = teamName else { return nil }
        return Color.aflTeamColors.colors(for: team)
    }

    var body: some View {
        Circle()
            .stroke(
                AngularGradient(
                    colors: [
                        teamColors?.primary.opacity(0.2) ?? Color.orange.opacity(0.2),
                        teamColors?.primary ?? Color.orange,
                        teamColors?.secondary ?? Color.white,
                        teamColors?.primary.opacity(0.2) ?? Color.orange.opacity(0.2)
                    ],
                    startAngle: .degrees(0),
                    endAngle: .degrees(360)
                ),
                lineWidth: 4
            )
            .frame(width: 40, height: 40)
            .rotationEffect(.degrees(rotation))
            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotation)
            .onAppear {
                rotation = 360
            }
    }
}

// MARK: - Interactive Animation Views

struct AFLBouncyButton<Content: View>: View {
    let content: Content
    let action: () -> Void
    @State private var isPressed = false

    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: action) {
            content
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(AFLAnimationConfig.snappy, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onPressureChange { pressure in
            isPressed = pressure > 0
        }
    }
}

struct AFLSwipeableCard<Content: View>: View {
    let content: Content
    let onSwipeLeft: (() -> Void)?
    let onSwipeRight: (() -> Void)?

    @State private var offset = CGSize.zero
    @State private var isDragging = false

    init(
        onSwipeLeft: (() -> Void)? = nil,
        onSwipeRight: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
        self.content = content()
    }

    var body: some View {
        content
            .offset(offset)
            .rotationEffect(.degrees(Double(offset.width / 20)))
            .scaleEffect(isDragging ? 0.98 : 1.0)
            .animation(AFLAnimationConfig.snappy, value: offset)
            .animation(AFLAnimationConfig.smooth, value: isDragging)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                        isDragging = true
                    }
                    .onEnded { gesture in
                        isDragging = false

                        if abs(gesture.translation.x) > 150 {
                            // Swipe detected
                            if gesture.translation.x > 0 {
                                onSwipeRight?()
                            } else {
                                onSwipeLeft?()
                            }

                            // Animate card off screen
                            withAnimation(AFLAnimationConfig.gentle) {
                                offset.x = gesture.translation.x > 0 ? 500 : -500
                            }
                        } else {
                            // Return to center
                            withAnimation(AFLAnimationConfig.bouncy) {
                                offset = .zero
                            }
                        }
                    }
            )
    }
}

struct AFLParallaxScrollView<Content: View>: View {
    let content: Content
    @State private var scrollOffset: CGFloat = 0

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
            }
            .frame(height: 0)

            content
                .offset(y: scrollOffset * 0.5)
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Page Transition System

struct AFLPageTransition: ViewModifier {
    let isActive: Bool
    let direction: TransitionDirection

    enum TransitionDirection {
        case left, right, up, down

        var edge: Edge {
            switch self {
            case .left: .leading
            case .right: .trailing
            case .up: .top
            case .down: .bottom
            }
        }
    }

    func body(content: Content) -> some View {
        content
            .transition(
                .asymmetric(
                    insertion: .move(edge: direction.edge).combined(with: .opacity),
                    removal: .move(edge: direction.edge).combined(with: .opacity)
                )
            )
            .animation(AFLAnimationConfig.smooth, value: isActive)
    }
}

struct AFLTabTransition: ViewModifier {
    let selectedTab: Int
    let tabIndex: Int

    func body(content: Content) -> some View {
        content
            .opacity(selectedTab == tabIndex ? 1 : 0)
            .scaleEffect(selectedTab == tabIndex ? 1 : 0.95)
            .offset(y: selectedTab == tabIndex ? 0 : 20)
            .animation(AFLAnimationConfig.smooth, value: selectedTab)
    }
}

// MARK: - Celebration Animations

struct AFLConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    let teamName: String?

    private var teamColors: Color.TeamColors? {
        guard let team = teamName else { return nil }
        return Color.aflTeamColors.colors(for: team)
    }

    struct ConfettiPiece: Identifiable {
        let id = UUID()
        let color: Color
        let startX: CGFloat
        let endX: CGFloat
        let startY: CGFloat
        let endY: CGFloat
        let rotation: Double
        let scale: CGFloat
        let animationDelay: TimeInterval
    }

    var body: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                RoundedRectangle(cornerRadius: 2)
                    .fill(piece.color)
                    .frame(width: 8 * piece.scale, height: 4 * piece.scale)
                    .position(x: piece.startX, y: piece.startY)
                    .rotationEffect(.degrees(piece.rotation))
                    .animation(
                        .easeIn(duration: 3).delay(piece.animationDelay),
                        value: confettiPieces.count
                    )
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            createConfetti()
        }
    }

    private func createConfetti() {
        let colors = [
            teamColors?.primary ?? .orange,
            teamColors?.secondary ?? .white,
            teamColors?.accent ?? .blue,
            .yellow,
            .red,
            .green
        ]

        confettiPieces = (0 ..< 50).map { _ in
            ConfettiPiece(
                color: colors.randomElement() ?? .orange,
                startX: CGFloat.random(in: 0 ... 400),
                endX: CGFloat.random(in: 0 ... 400),
                startY: -50,
                endY: 800,
                rotation: Double.random(in: 0 ... 720),
                scale: CGFloat.random(in: 0.5 ... 2.0),
                animationDelay: TimeInterval.random(in: 0 ... 2)
            )
        }

        // Clear confetti after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            confettiPieces.removeAll()
        }
    }
}

struct AFLFireworksView: View {
    @State private var fireworks: [Firework] = []
    let teamName: String?

    private var teamColors: Color.TeamColors? {
        guard let team = teamName else { return nil }
        return Color.aflTeamColors.colors(for: team)
    }

    struct Firework: Identifiable {
        let id = UUID()
        let centerX: CGFloat
        let centerY: CGFloat
        let particles: [Particle]
        let delay: TimeInterval
    }

    struct Particle: Identifiable {
        let id = UUID()
        let angle: Double
        let distance: CGFloat
        let color: Color
        let scale: CGFloat
    }

    var body: some View {
        ZStack {
            ForEach(fireworks) { firework in
                ForEach(firework.particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: 6 * particle.scale, height: 6 * particle.scale)
                        .position(
                            x: firework.centerX + cos(particle.angle) * particle.distance,
                            y: firework.centerY + sin(particle.angle) * particle.distance
                        )
                        .animation(
                            .easeOut(duration: 1.5).delay(firework.delay),
                            value: fireworks.count
                        )
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            createFireworks()
        }
    }

    private func createFireworks() {
        fireworks = (0 ..< 5).map { i in
            let particles = (0 ..< 12).map { j in
                Particle(
                    angle: Double(j) * (2 * .pi / 12),
                    distance: CGFloat.random(in: 30 ... 80),
                    color: [teamColors?.primary, teamColors?.secondary, teamColors?.accent].compactMap { $0 }
                        .randomElement() ?? .orange,
                    scale: CGFloat.random(in: 0.5 ... 1.5)
                )
            }

            return Firework(
                centerX: CGFloat.random(in: 100 ... 300),
                centerY: CGFloat.random(in: 100 ... 400),
                particles: particles,
                delay: TimeInterval(i) * 0.3
            )
        }

        // Clear fireworks after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            fireworks.removeAll()
        }
    }
}

// MARK: - View Extensions

extension View {
    // MARK: - Animation Modifiers

    func shake(intensity: CGFloat = 10, duration: TimeInterval = 0.6) -> some View {
        modifier(ShakeModifier(intensity: intensity, duration: duration))
    }

    func pulse(intensity: CGFloat = 0.1, duration: TimeInterval = 1.0) -> some View {
        modifier(PulseModifier(intensity: intensity, duration: duration))
    }

    func wiggle(intensity: Double = 5, speed: TimeInterval = 0.2) -> some View {
        modifier(WiggleModifier(intensity: intensity, speed: speed))
    }

    func floating(amplitude: CGFloat = -10, duration: TimeInterval = 2.0) -> some View {
        modifier(FloatingModifier(amplitude: amplitude, duration: duration))
    }

    func glow(color: Color = .orange, radius: CGFloat = 10, duration: TimeInterval = 1.5) -> some View {
        modifier(GlowModifier(color: color, radius: radius, duration: duration))
    }

    // MARK: - Transition Modifiers

    func pageTransition(isActive: Bool, direction: AFLPageTransition.TransitionDirection) -> some View {
        modifier(AFLPageTransition(isActive: isActive, direction: direction))
    }

    func tabTransition(selectedTab: Int, tabIndex: Int) -> some View {
        modifier(AFLTabTransition(selectedTab: selectedTab, tabIndex: tabIndex))
    }

    // MARK: - Pressure Change Helper

    func onPressureChange(perform action: @escaping (Double) -> Void) -> some View {
        self
    }
}

// MARK: - Animation Presets

enum AFLAnimationPresets {
    static func bounceIn() -> Animation {
        .interpolatingSpring(stiffness: 300, damping: 15)
    }

    static func slideIn(delay: TimeInterval = 0) -> Animation {
        .easeOut(duration: 0.4).delay(delay)
    }

    static func scaleIn(delay: TimeInterval = 0) -> Animation {
        .interpolatingSpring(stiffness: 400, damping: 20).delay(delay)
    }

    static func fadeIn(duration: TimeInterval = 0.3, delay: TimeInterval = 0) -> Animation {
        .easeIn(duration: duration).delay(delay)
    }

    static func celebration() -> Animation {
        .interpolatingSpring(stiffness: 200, damping: 8)
    }

    static func error() -> Animation {
        .easeInOut(duration: 0.1).repeatCount(4, autoreverses: true)
    }
}
