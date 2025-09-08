import CoreHaptics
import Foundation
import UIKit

// MARK: - AFLHapticsManager

/// AFLHapticsManager provides consistent, HIG-compliant haptic feedback throughout the app.
/// Use the shared instance for app-wide haptic feedback.
public final class AFLHapticsManager: ObservableObject {
    // MARK: - Shared instance

    public static let shared = AFLHapticsManager()

    // MARK: - Published state

    @Published public var isHapticsEnabled: Bool = true

    // MARK: - Private properties

    private var hapticEngine: CHHapticEngine?
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    public init() {
        setupHapticEngine()
        loadHapticSettings()
    }

    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("Device doesn't support haptics")
            return
        }

        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }

    private func loadHapticSettings() {
        isHapticsEnabled = UserDefaults.standard.bool(forKey: "haptics_enabled")
    }

    // MARK: - App Experience Haptics

    public func onAppLaunch() {
        playCustomHaptic(.appLaunch)
    }

    public func onGoalScored() {
        playCustomHaptic(.goalCelebration)
    }

    public func onTradeCompleted() {
        triggerSuccessHaptic()
    }

    public func onPriceIncrease() {
        playCustomHaptic(.priceUp)
    }

    public func onPriceDecrease() {
        playCustomHaptic(.priceDown)
    }

    public func onPlayerSelected() {
        triggerSelectionHaptic()
    }

    public func onButtonPressed() {
        triggerLightImpact()
    }

    public func onSwipeAction() {
        triggerMediumImpact()
    }

    public func onDataRefreshed() {
        triggerNotificationHaptic()
    }

    public func onPositionSelect() {
        triggerSelectionHaptic()
    }

    // MARK: - Basic Haptic Types

    public func triggerLightImpact() {
        guard isHapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    public func triggerMediumImpact() {
        guard isHapticsEnabled else { return }
        impactGenerator.impactOccurred()
    }

    public func triggerHeavyImpact() {
        guard isHapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    public func triggerSuccessHaptic() {
        guard isHapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }

    public func triggerWarningHaptic() {
        guard isHapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.warning)
    }

    public func triggerErrorHaptic() {
        guard isHapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.error)
    }

    public func triggerSelectionHaptic() {
        guard isHapticsEnabled else { return }
        selectionGenerator.selectionChanged()
    }

    public func triggerNotificationHaptic() {
        triggerSuccessHaptic()
    }

    // MARK: - Custom Haptic Patterns

    private func playCustomHaptic(_ pattern: HapticPattern) {
        guard isHapticsEnabled, let engine = hapticEngine else { return }

        do {
            let hapticPattern = try createHapticPattern(pattern)
            let player = try engine.makePlayer(with: hapticPattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play custom haptic: \(error)")
            // Fallback to basic haptics
            fallbackHaptic(for: pattern)
        }
    }

    private func createHapticPattern(_ pattern: HapticPattern) throws -> CHHapticPattern {
        let events: [CHHapticEvent] = switch pattern {
        case .appLaunch:
            [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ], relativeTime: 0)
            ]

        case .goalCelebration:
            [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ], relativeTime: 0),
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ], relativeTime: 0.2),
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ], relativeTime: 0.4)
            ]

        case .priceUp:
            [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ], relativeTime: 0),
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ], relativeTime: 0.1)
            ]

        case .priceDown:
            [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ], relativeTime: 0),
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ], relativeTime: 0.1)
            ]
        }

        return try CHHapticPattern(events: events, parameters: [])
    }

    private func fallbackHaptic(for pattern: HapticPattern) {
        switch pattern {
        case .appLaunch:
            triggerMediumImpact()
        case .goalCelebration:
            triggerSuccessHaptic()
        case .priceUp:
            triggerLightImpact()
        case .priceDown:
            triggerWarningHaptic()
        }
    }

    // MARK: - Settings

    public func toggleHaptics(_ enabled: Bool) {
        isHapticsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "haptics_enabled")

        if enabled {
            triggerSelectionHaptic() // Confirmation haptic
        }
    }
}

// MARK: - HapticPattern

private enum HapticPattern {
    case appLaunch
    case goalCelebration
    case priceUp
    case priceDown
}
