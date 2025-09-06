//
//  AFLHapticsManager.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import CoreHaptics
import SwiftUI
import UIKit

// MARK: - AFLHapticsManager

/// Comprehensive haptic feedback system for AFL Fantasy with contextual patterns
@MainActor
class AFLHapticsManager: ObservableObject {
    // MARK: - Haptic Engine

    private var hapticEngine: CHHapticEngine?
    private var impactFeedbackGenerator: UIImpactFeedbackGenerator?
    private var notificationFeedbackGenerator: UINotificationFeedbackGenerator?
    private var selectionFeedbackGenerator: UISelectionFeedbackGenerator?

    // MARK: - State

    @Published var isHapticsEnabled: Bool = true
    @Published var hapticsIntensity: Float = 0.8
    @Published var supportsAdvancedHaptics: Bool = false

    // MARK: - Haptic Types

    enum HapticPattern {
        // Basic UI Interactions
        case lightTap
        case mediumTap
        case heavyTap
        case selection
        case success
        case warning
        case error

        // AFL Specific Patterns
        case whistle
        case goalSiren
        case tradeComplete
        case priceRise
        case priceDrop
        case captainSelection
        case scoreUpdate
        case celebration
        case heartbeat
        case powerUp

        // Complex Patterns
        case tradingFrenzy
        case bigScore
        case elimination
        case championship
        case comeback

        var intensity: Float {
            switch self {
            case .lightTap, .selection: 0.3
            case .mediumTap, .warning: 0.6
            case .heavyTap, .success, .error: 0.9
            case .whistle, .tradeComplete: 0.7
            case .goalSiren, .celebration, .championship: 1.0
            case .priceRise: 0.5
            case .priceDrop: 0.8
            case .captainSelection, .scoreUpdate: 0.6
            case .heartbeat: 0.4
            case .powerUp: 0.8
            case .tradingFrenzy, .bigScore: 0.9
            case .elimination: 1.0
            case .comeback: 0.85
            }
        }

        var duration: TimeInterval {
            switch self {
            case .lightTap, .selection: 0.1
            case .mediumTap, .heavyTap: 0.2
            case .success, .warning, .error: 0.3
            case .whistle: 0.5
            case .goalSiren: 1.0
            case .tradeComplete: 0.4
            case .priceRise, .priceDrop: 0.3
            case .captainSelection: 0.6
            case .scoreUpdate: 0.25
            case .celebration: 1.5
            case .heartbeat: 0.8
            case .powerUp: 0.5
            case .tradingFrenzy: 2.0
            case .bigScore: 0.8
            case .elimination: 1.2
            case .championship: 3.0
            case .comeback: 1.0
            }
        }
    }

    // MARK: - Initialization

    init() {
        setupHapticEngine()
        setupBasicFeedbackGenerators()
        loadSettings()
    }

    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            supportsAdvancedHaptics = false
            return
        }

        do {
            hapticEngine = try CHHapticEngine()
            hapticEngine?.stoppedHandler = { reason in
                print("Haptic engine stopped: \(reason)")
            }
            hapticEngine?.resetHandler = {
                print("Haptic engine reset")
                self.restartHapticEngine()
            }
            try hapticEngine?.start()
            supportsAdvancedHaptics = true
        } catch {
            print("Failed to create haptic engine: \(error)")
            supportsAdvancedHaptics = false
        }
    }

    private func setupBasicFeedbackGenerators() {
        impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        selectionFeedbackGenerator = UISelectionFeedbackGenerator()

        impactFeedbackGenerator?.prepare()
        notificationFeedbackGenerator?.prepare()
        selectionFeedbackGenerator?.prepare()
    }

    private func restartHapticEngine() {
        do {
            try hapticEngine?.start()
        } catch {
            print("Failed to restart haptic engine: \(error)")
        }
    }

    private func loadSettings() {
        isHapticsEnabled = UserDefaults.standard.bool(forKey: "AFL_Haptics_Enabled")
        hapticsIntensity = UserDefaults.standard.float(forKey: "AFL_Haptics_Intensity")

        // Set defaults if not previously set
        if !UserDefaults.standard.bool(forKey: "AFL_Haptics_Defaults_Set") {
            isHapticsEnabled = true
            hapticsIntensity = 0.8
            UserDefaults.standard.set(true, forKey: "AFL_Haptics_Defaults_Set")
            UserDefaults.standard.set(isHapticsEnabled, forKey: "AFL_Haptics_Enabled")
            UserDefaults.standard.set(hapticsIntensity, forKey: "AFL_Haptics_Intensity")
        }

        if hapticsIntensity == 0 { hapticsIntensity = 0.8 }
    }

    // MARK: - Basic Haptic Playback

    func playHaptic(_ pattern: HapticPattern) {
        guard isHapticsEnabled else { return }

        if supportsAdvancedHaptics {
            playAdvancedHaptic(pattern)
        } else {
            playBasicHaptic(pattern)
        }
    }

    private func playBasicHaptic(_ pattern: HapticPattern) {
        switch pattern {
        case .lightTap, .selection:
            selectionFeedbackGenerator?.selectionChanged()

        case .mediumTap, .tradeComplete, .scoreUpdate:
            impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            impactFeedbackGenerator?.impactOccurred()

        case .heavyTap, .goalSiren, .celebration:
            impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedbackGenerator?.impactOccurred()

        case .success, .priceRise:
            notificationFeedbackGenerator?.notificationOccurred(.success)

        case .warning, .priceDrop:
            notificationFeedbackGenerator?.notificationOccurred(.warning)

        case .error, .elimination:
            notificationFeedbackGenerator?.notificationOccurred(.error)

        case .whistle, .captainSelection:
            // Double tap for special actions
            impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackGenerator?.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.impactFeedbackGenerator?.impactOccurred()
            }

        default:
            // Fallback to medium impact for complex patterns
            impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            impactFeedbackGenerator?.impactOccurred()
        }
    }

    private func playAdvancedHaptic(_ pattern: HapticPattern) {
        do {
            let hapticPattern = try createHapticPattern(for: pattern)
            let player = try hapticEngine?.makePlayer(with: hapticPattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play advanced haptic: \(error)")
            playBasicHaptic(pattern) // Fallback
        }
    }

    private func createHapticPattern(for pattern: HapticPattern) throws -> CHHapticPattern {
        let adjustedIntensity = pattern.intensity * hapticsIntensity

        switch pattern {
        case .lightTap, .selection:
            return try createSimpleTap(intensity: adjustedIntensity, sharpness: 0.3, duration: 0.1)

        case .mediumTap:
            return try createSimpleTap(intensity: adjustedIntensity, sharpness: 0.6, duration: 0.2)

        case .heavyTap:
            return try createSimpleTap(intensity: adjustedIntensity, sharpness: 0.9, duration: 0.3)

        case .success, .priceRise:
            return try createSuccessPattern(intensity: adjustedIntensity)

        case .warning, .priceDrop:
            return try createWarningPattern(intensity: adjustedIntensity)

        case .error, .elimination:
            return try createErrorPattern(intensity: adjustedIntensity)

        case .whistle:
            return try createWhistlePattern(intensity: adjustedIntensity)

        case .goalSiren:
            return try createGoalSirenPattern(intensity: adjustedIntensity)

        case .tradeComplete:
            return try createTradeCompletePattern(intensity: adjustedIntensity)

        case .captainSelection:
            return try createCaptainSelectionPattern(intensity: adjustedIntensity)

        case .scoreUpdate:
            return try createScoreUpdatePattern(intensity: adjustedIntensity)

        case .celebration:
            return try createCelebrationPattern(intensity: adjustedIntensity)

        case .heartbeat:
            return try createHeartbeatPattern(intensity: adjustedIntensity)

        case .powerUp:
            return try createPowerUpPattern(intensity: adjustedIntensity)

        case .tradingFrenzy:
            return try createTradingFrenzyPattern(intensity: adjustedIntensity)

        case .bigScore:
            return try createBigScorePattern(intensity: adjustedIntensity)

        case .championship:
            return try createChampionshipPattern(intensity: adjustedIntensity)

        case .comeback:
            return try createComebackPattern(intensity: adjustedIntensity)
        }
    }

    // MARK: - Haptic Pattern Creators

    private func createSimpleTap(intensity: Float, sharpness: Float, duration: TimeInterval) throws -> CHHapticPattern {
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0,
            duration: duration
        )

        return try CHHapticPattern(events: [event], parameters: [])
    }

    private func createSuccessPattern(intensity: Float) throws -> CHHapticPattern {
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0.1
            )
        ]

        return try CHHapticPattern(events: events, parameters: [])
    }

    private func createWarningPattern(intensity: Float) throws -> CHHapticPattern {
        let events = [
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0,
                duration: 0.2
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0.25
            )
        ]

        return try CHHapticPattern(events: events, parameters: [])
    }

    private func createErrorPattern(intensity: Float) throws -> CHHapticPattern {
        let events = (0 ..< 3).map { i in
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                ],
                relativeTime: TimeInterval(i) * 0.1
            )
        }

        return try CHHapticPattern(events: events, parameters: [])
    }

    private func createWhistlePattern(intensity: Float) throws -> CHHapticPattern {
        let events = [
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0,
                duration: 0.3
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0.35
            )
        ]

        return try CHHapticPattern(events: events, parameters: [])
    }

    private func createGoalSirenPattern(intensity: Float) throws -> CHHapticPattern {
        var events: [CHHapticEvent] = []

        for i in 0 ..< 5 {
            events.append(
                CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(
                            parameterID: .hapticIntensity,
                            value: intensity * Float(0.6 + Double(i) * 0.1)
                        ),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                    ],
                    relativeTime: TimeInterval(i) * 0.15,
                    duration: 0.1
                )
            )
        }

        return try CHHapticPattern(events: events, parameters: [])
    }

    private func createTradeCompletePattern(intensity: Float) throws -> CHHapticPattern {
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                ],
                relativeTime: 0.05,
                duration: 0.2
            )
        ]

        return try CHHapticPattern(events: events, parameters: [])
    }

    private func createCaptainSelectionPattern(intensity: Float) throws -> CHHapticPattern {
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0.1,
                duration: 0.4
            )
        ]

        return try CHHapticPattern(events: events, parameters: [])
    }

    private func createScoreUpdatePattern(intensity: Float) throws -> CHHapticPattern {
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: 0.08
            )
        ]

        return try CHHapticPattern(events: events, parameters: [])
    }

    private func createCelebrationPattern(intensity: Float) throws -> CHHapticPattern {
        var events: [CHHapticEvent] = []

        // Create a series of ascending pulses
        for i in 0 ..< 8 {
            events.append(
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(
                            parameterID: .hapticIntensity,
                            value: intensity * Float(0.3 + Double(i) * 0.1)
                        ),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(0.4 + Double(i) * 0.075))
                    ],
                    relativeTime: TimeInterval(i) * 0.12
                )
            )
        }

        return try CHHapticPattern(events: events, parameters: [])
    }

    private func createHeartbeatPattern(intensity: Float) throws -> CHHapticPattern {
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0.15
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0.5
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0.65
            )
        ]

        return try CHHapticPattern(events: events, parameters: [])
    }

    private func createPowerUpPattern(intensity: Float) throws -> CHHapticPattern {
        var events: [CHHapticEvent] = []

        for i in 0 ..< 5 {
            events.append(
                CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(
                            parameterID: .hapticIntensity,
                            value: intensity * Float(0.2 + Double(i) * 0.15)
                        ),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(0.3 + Double(i) * 0.15))
                    ],
                    relativeTime: TimeInterval(i) * 0.08,
                    duration: 0.06
                )
            )
        }

        return try CHHapticPattern(events: events, parameters: [])
    }

    private func createTradingFrenzyPattern(intensity: Float) throws -> CHHapticPattern {
        var events: [CHHapticEvent] = []

        for i in 0 ..< 12 {
            events.append(
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(
                            parameterID: .hapticIntensity,
                            value: intensity * Float.random(in: 0.4 ... 0.9)
                        ),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: Float.random(in: 0.3 ... 0.8))
                    ],
                    relativeTime: TimeInterval(i) * 0.15
                )
            )
        }

        return try CHHapticPattern(events: events, parameters: [])
    }

    private func createBigScorePattern(intensity: Float) throws -> CHHapticPattern {
        let events = [
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0,
                duration: 0.3
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0.35
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0.55
            )
        ]

        return try CHHapticPattern(events: events, parameters: [])
    }

    private func createChampionshipPattern(intensity: Float) throws -> CHHapticPattern {
        var events: [CHHapticEvent] = []

        // Victory fanfare pattern
        let timings: [TimeInterval] = [0, 0.2, 0.4, 0.8, 1.0, 1.5, 2.0, 2.3, 2.6]
        let intensities: [Float] = [0.6, 0.7, 0.8, 0.9, 1.0, 0.8, 0.9, 1.0, 1.0]

        for (i, timing) in timings.enumerated() {
            events.append(
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * intensities[i]),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                    ],
                    relativeTime: timing
                )
            )
        }

        return try CHHapticPattern(events: events, parameters: [])
    }

    private func createComebackPattern(intensity: Float) throws -> CHHapticPattern {
        var events: [CHHapticEvent] = []

        // Slow build to climax
        for i in 0 ..< 6 {
            let relativeIntensity = Float(0.3 + Double(i) * 0.13)
            events.append(
                CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * relativeIntensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(0.2 + Double(i) * 0.12))
                    ],
                    relativeTime: TimeInterval(i) * 0.15,
                    duration: 0.12
                )
            )
        }

        return try CHHapticPattern(events: events, parameters: [])
    }

    // MARK: - Contextual Haptics

    func onAppLaunch() {
        playHaptic(.powerUp)
    }

    func onButtonTap() {
        playHaptic(.lightTap)
    }

    func onTradeComplete(isGood: Bool) {
        playHaptic(isGood ? .tradeComplete : .warning)
    }

    func onCaptainSelection() {
        playHaptic(.captainSelection)
    }

    func onScoreUpdate(improvement: Int) {
        if improvement > 50 {
            playHaptic(.bigScore)
        } else if improvement > 0 {
            playHaptic(.scoreUpdate)
        }
    }

    func onPriceChange(change: Double) {
        if change > 0 {
            playHaptic(.priceRise)
        } else if change < 0 {
            playHaptic(.priceDrop)
        }
    }

    func onMilestoneReached() {
        playHaptic(.celebration)
    }

    func onChampionshipWin() {
        playHaptic(.championship)
    }

    func onTradingDeadline() {
        playHaptic(.tradingFrenzy)
    }

    // MARK: - Settings

    func toggleHaptics() {
        isHapticsEnabled.toggle()
        UserDefaults.standard.set(isHapticsEnabled, forKey: "AFL_Haptics_Enabled")
    }

    func updateIntensity(_ intensity: Float) {
        hapticsIntensity = max(0.1, min(1.0, intensity))
        UserDefaults.standard.set(hapticsIntensity, forKey: "AFL_Haptics_Intensity")
    }

    // Test haptic patterns
    func testPattern(_ pattern: HapticPattern) {
        playHaptic(pattern)
    }
}

// MARK: - Haptic View Modifiers

extension View {
    func withAFLHaptics() -> some View {
        environmentObject(AFLHapticsManager())
    }

    func onAFLHapticTap(
        pattern: AFLHapticsManager.HapticPattern = .lightTap,
        action: @escaping () -> Void
    ) -> some View {
        modifier(AFLHapticTapModifier(pattern: pattern, action: action))
    }
}

struct AFLHapticTapModifier: ViewModifier {
    @EnvironmentObject var hapticsManager: AFLHapticsManager
    let pattern: AFLHapticsManager.HapticPattern
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                hapticsManager.playHaptic(pattern)
                action()
            }
    }
}

// MARK: - Haptics Settings View

struct AFLHapticsSettingsView: View {
    @EnvironmentObject var hapticsManager: AFLHapticsManager

    var body: some View {
        Form {
            Section("✋ Haptic Feedback") {
                Toggle("Enable Haptics", isOn: $hapticsManager.isHapticsEnabled)
                    .onChange(of: hapticsManager.isHapticsEnabled) { _, _ in
                        hapticsManager.toggleHaptics()
                    }

                if hapticsManager.supportsAdvancedHaptics {
                    Label("Advanced Haptics Supported", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Label("Basic Haptics Only", systemImage: "info.circle")
                        .foregroundColor(.orange)
                }
            }

            Section("🎚️ Intensity") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Haptic Intensity")
                        Spacer()
                        Text("\(Int(hapticsManager.hapticsIntensity * 100))%")
                            .foregroundColor(.secondary)
                    }

                    Slider(value: Binding(
                        get: { hapticsManager.hapticsIntensity },
                        set: { hapticsManager.updateIntensity($0) }
                    ), in: 0.1 ... 1.0)
                        .tint(.orange)
                }
            }

            Section("🧪 Test Patterns") {
                VStack(spacing: 12) {
                    HStack {
                        AFLButton(title: "Goal Siren", style: .primary) {
                            hapticsManager.testPattern(.goalSiren)
                        }

                        Spacer()

                        AFLButton(title: "Trade Bell", style: .secondary) {
                            hapticsManager.testPattern(.tradeComplete)
                        }
                    }

                    HStack {
                        AFLButton(title: "Celebration", style: .success) {
                            hapticsManager.testPattern(.celebration)
                        }

                        Spacer()

                        AFLButton(title: "Championship", style: .accent) {
                            hapticsManager.testPattern(.championship)
                        }
                    }
                }
            }
        }
        .navigationTitle("Haptic Settings")
    }
}
