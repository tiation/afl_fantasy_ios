//
//  AFLExperienceManager.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import AVFoundation
import Combine
import Foundation
import SwiftUI

// MARK: - AFLExperienceManager

/// Orchestrates audio, haptic, and visual experiences for cohesive AFL Fantasy interactions
@MainActor
class AFLExperienceManager: ObservableObject {
    // MARK: - Managers

    private let audioManager: AFLAudioManager
    private let hapticsManager: AFLHapticsManager

    // MARK: - State

    @Published var isExperienceEnabled: Bool = true
    @Published var experienceLevel: ExperienceLevel = .full
    @Published var currentTeam: String?
    @Published var isGameDay: Bool = false
    @Published var celebrationMode: Bool = false

    // MARK: - Experience Levels

    enum ExperienceLevel: String, CaseIterable {
        case minimal = "Minimal"
        case standard = "Standard"
        case full = "Full Experience"
        case gameDay = "Game Day"

        var description: String {
            switch self {
            case .minimal: "Essential feedback only"
            case .standard: "Balanced audio and haptics"
            case .full: "Complete sensory experience"
            case .gameDay: "Maximum excitement for game days"
            }
        }
    }

    // MARK: - AFLPageTransition

    enum AFLPageTransition {
        enum TransitionDirection {
            case left, right, up, down
        }
    }

    // MARK: - Experience Types

    enum AFLExperienceType {
        // App Navigation
        case appLaunch
        case tabChange
        case pageTransition(direction: AFLPageTransition.TransitionDirection)

        // Trading Actions
        case tradeInitiated
        case tradeComplete(success: Bool, playerName: String)
        case tradeValidation(isValid: Bool)
        case captainSelection(playerName: String)
        case emergencyTrade

        // Score Updates
        case scoreUpdate(oldScore: Int, newScore: Int, playerName: String?)
        case weeklyScoreReveal(score: Int)
        case rankingChange(oldRank: Int, newRank: Int)

        // Price Changes
        case priceRise(playerName: String, change: Double)
        case priceDrop(playerName: String, change: Double)
        case rookiePromotion(playerName: String)

        // Achievements
        case milestone(type: MilestoneType)
        case perfectCaptain
        case greenTrade
        case redTrade
        case seasonHighScore

        // Game Events
        case gameStart
        case gameEnd
        case goalScored(teamName: String)
        case matchAlert

        // Special Moments
        case celebration
        case commiseration
        case bigNews
        case tradingDeadline
        case seasonEnd

        // Errors & Warnings
        case validationError
        case networkError
        case insufficientFunds
        case tradingClosed
    }

    enum MilestoneType {
        case firstTrade, hundredTrades, perfectWeek, highScore, rankingGoal
    }

    // MARK: - Initialization

    init(audioManager: AFLAudioManager, hapticsManager: AFLHapticsManager) {
        self.audioManager = audioManager
        self.hapticsManager = hapticsManager
        loadSettings()
        setupObservers()
    }

    private func loadSettings() {
        isExperienceEnabled = UserDefaults.standard.bool(forKey: "AFL_Experience_Enabled")
        if let levelString = UserDefaults.standard.string(forKey: "AFL_Experience_Level"),
           let level = ExperienceLevel(rawValue: levelString) {
            experienceLevel = level
        }
        currentTeam = UserDefaults.standard.string(forKey: "AFL_User_Team")

        // Set defaults if not previously set
        if !UserDefaults.standard.bool(forKey: "AFL_Experience_Defaults_Set") {
            isExperienceEnabled = true
            experienceLevel = .full
            UserDefaults.standard.set(true, forKey: "AFL_Experience_Defaults_Set")
            saveSettings()
        }
    }

    private func saveSettings() {
        UserDefaults.standard.set(isExperienceEnabled, forKey: "AFL_Experience_Enabled")
        UserDefaults.standard.set(experienceLevel.rawValue, forKey: "AFL_Experience_Level")
        UserDefaults.standard.set(currentTeam, forKey: "AFL_User_Team")
    }

    private func setupObservers() {
        // Observe time of day for dynamic experiences
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            Task { @MainActor in
                self.updateContextualState()
            }
        }
    }

    private func updateContextualState() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())

        // Check if it's game day (AFL games typically on weekends)
        let weekday = calendar.component(.weekday, from: Date())
        isGameDay = weekday == 1 || weekday == 7 || // Sunday or Saturday
            (weekday == 6 && hour >= 18) || // Friday night
            (weekday == 5 && hour >= 18) // Thursday night
    }

    // MARK: - Main Experience Trigger

    func triggerExperience(_ type: AFLExperienceType, teamName: String? = nil) {
        guard isExperienceEnabled else { return }

        let team = teamName ?? currentTeam
        let shouldPlay = shouldPlayExperience(type)

        if shouldPlay {
            playAudioExperience(type, teamName: team)
            playHapticExperience(type)
            triggerVisualEffects(type, teamName: team)
        }
    }

    private func shouldPlayExperience(_ type: AFLExperienceType) -> Bool {
        switch experienceLevel {
        case .minimal:
            isEssentialExperience(type)
        case .standard:
            isStandardExperience(type)
        case .full:
            true
        case .gameDay:
            true // All experiences enabled on game day
        }
    }

    private func isEssentialExperience(_ type: AFLExperienceType) -> Bool {
        switch type {
        case .tradeComplete, .validationError, .insufficientFunds, .tradingClosed:
            true
        default:
            false
        }
    }

    private func isStandardExperience(_ type: AFLExperienceType) -> Bool {
        switch type {
        case .appLaunch, .tradeComplete, .scoreUpdate, .milestone,
             .priceRise, .priceDrop, .captainSelection, .validationError:
            true
        default:
            false
        }
    }

    // MARK: - Audio Experience

    private func playAudioExperience(_ type: AFLExperienceType, teamName: String?) {
        switch type {
        case .appLaunch:
            audioManager.onAppLaunch()

        case .tabChange:
            audioManager.onTabChange()

        case let .tradeComplete(success, playerName):
            audioManager.onTradeComplete(isGood: success)
            if success {
                audioManager.playRandomCommentary(for: .goodAction)
            }

        case let .captainSelection(playerName):
            audioManager.onCaptainSelection()

        case let .scoreUpdate(oldScore, newScore, playerName):
            audioManager.onScoreUpdate(oldScore: oldScore, newScore: newScore)

        case let .priceRise(playerName, change):
            audioManager.playSound(.scoreUpdate)
            audioManager.playCommentary(.priceRise)

        case let .priceDrop(playerName, change):
            audioManager.playSound(.crowdGroan)
            audioManager.playCommentary(.priceDrop)

        case .milestone:
            audioManager.onMilestoneReached()

        case let .goalScored(teamName):
            audioManager.playSound(.goalUmpire)
            audioManager.playSound(.crowdCheer)

        case .celebration:
            audioManager.playSound(.celebration)
            audioManager.playSound(.crowdCheer)
            audioManager.playRandomCommentary(for: .excitement)

        case .tradingDeadline:
            audioManager.playSound(.whistleLong)
            audioManager.playCommentary(.suspense)

        case .validationError, .insufficientFunds:
            audioManager.playSound(.buttonError)

        case .bigNews:
            audioManager.playSound(.notification)
            audioManager.playRandomCommentary(for: .excitement)

        default:
            break
        }
    }

    // MARK: - Haptic Experience

    private func playHapticExperience(_ type: AFLExperienceType) {
        switch type {
        case .appLaunch:
            hapticsManager.onAppLaunch()

        case let .tradeComplete(success, _):
            if success {
                hapticsManager.triggerSuccessHaptic()
            } else {
                hapticsManager.triggerErrorHaptic()
            }

        case .captainSelection:
            hapticsManager.triggerMediumImpact()

        case let .scoreUpdate(oldScore, newScore, _):
            if newScore > oldScore {
                hapticsManager.triggerSuccessHaptic()
            } else {
                hapticsManager.triggerWarningHaptic()
            }

        case let .priceRise(_, change):
            hapticsManager.onPriceIncrease()

        case let .priceDrop(_, change):
            hapticsManager.onPriceDecrease()

        case .milestone:
            hapticsManager.triggerSuccessHaptic()

        case .celebration:
            hapticsManager.onGoalScored()

        case .tradingDeadline:
            hapticsManager.triggerWarningHaptic()

        case .validationError, .insufficientFunds, .tradingClosed:
            hapticsManager.triggerErrorHaptic()

        case .goalScored:
            hapticsManager.onGoalScored()

        case .seasonEnd:
            hapticsManager.onGoalScored()

        default:
            hapticsManager.triggerLightImpact()
        }
    }

    // MARK: - Visual Effects

    private func triggerVisualEffects(_ type: AFLExperienceType, teamName: String?) {
        switch type {
        case .celebration, .milestone(.perfectWeek), .seasonHighScore:
            celebrationMode = true
            // Trigger confetti or fireworks in the UI
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.celebrationMode = false
            }

        case .goalScored:
            celebrationMode = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.celebrationMode = false
            }

        default:
            break
        }
    }

    // MARK: - Convenience Methods

    func onSuccessfulTrade(playerName: String, teamName: String? = nil) {
        triggerExperience(.tradeComplete(success: true, playerName: playerName), teamName: teamName)
    }

    func onFailedTrade(playerName: String, reason: String) {
        triggerExperience(.tradeComplete(success: false, playerName: playerName))
    }

    func onCaptainSelected(playerName: String, teamName: String? = nil) {
        triggerExperience(.captainSelection(playerName: playerName), teamName: teamName)
    }

    func onScoreUpdate(from oldScore: Int, to newScore: Int, playerName: String? = nil) {
        triggerExperience(.scoreUpdate(oldScore: oldScore, newScore: newScore, playerName: playerName))
    }

    func onPriceChange(playerName: String, change: Double, teamName: String? = nil) {
        if change > 0 {
            triggerExperience(.priceRise(playerName: playerName, change: change), teamName: teamName)
        } else {
            triggerExperience(.priceDrop(playerName: playerName, change: abs(change)), teamName: teamName)
        }
    }

    func onMilestone(_ type: MilestoneType) {
        triggerExperience(.milestone(type: type))
    }

    func onValidationError(_ error: String) {
        triggerExperience(.validationError)
    }

    func onInsufficientFunds() {
        triggerExperience(.insufficientFunds)
    }

    func onAppLaunch() {
        triggerExperience(.appLaunch)
    }

    func onTabChange() {
        triggerExperience(.tabChange)
    }

    func onCelebration() {
        triggerExperience(.celebration)
    }

    // MARK: - Settings

    func toggleExperience() {
        isExperienceEnabled.toggle()
        saveSettings()
    }

    func updateExperienceLevel(_ level: ExperienceLevel) {
        experienceLevel = level
        saveSettings()
    }

    func updateUserTeam(_ teamName: String) {
        currentTeam = teamName
        saveSettings()
    }

    // MARK: - Context Helpers

    func getTeamColors(for teamName: String?) -> Color.TeamColors? {
        guard let team = teamName ?? currentTeam else { return nil }
        return Color.aflTeamColors.colors(for: team)
    }

    func getTeamEmoji(for teamName: String?) -> String {
        guard let team = teamName ?? currentTeam else { return "🏈" }
        return AFLTeamInfo.emoji(for: team)
    }

    // MARK: - Game Day Features

    func enableGameDayMode() {
        experienceLevel = .gameDay
        isGameDay = true
        audioManager.playBackgroundAmbient(.stadium)
        saveSettings()
    }

    func disableGameDayMode() {
        if experienceLevel == .gameDay {
            experienceLevel = .full
        }
        isGameDay = false
        audioManager.stopBackgroundAmbient()
        saveSettings()
    }
}

// MARK: - AFLExperienceEnvironment

struct AFLExperienceEnvironment: ViewModifier {
    @StateObject private var experienceManager: AFLExperienceManager

    init(audioManager: AFLAudioManager, hapticsManager: AFLHapticsManager) {
        _experienceManager = StateObject(wrappedValue: AFLExperienceManager(
            audioManager: audioManager,
            hapticsManager: hapticsManager
        ))
    }

    func body(content: Content) -> some View {
        content
            .environmentObject(experienceManager)
            .overlay(
                Group {
                    if experienceManager.celebrationMode {
                        ZStack {
                            AFLConfettiView(teamName: experienceManager.currentTeam)
                            AFLFireworksView(teamName: experienceManager.currentTeam)
                        }
                        .allowsHitTesting(false)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.5), value: experienceManager.celebrationMode)
                    }
                }
            )
    }
}

// MARK: - AFLExperienceSettingsView

struct AFLExperienceSettingsView: View {
    @EnvironmentObject var experienceManager: AFLExperienceManager
    @EnvironmentObject var audioManager: AFLAudioManager
    @EnvironmentObject var hapticsManager: AFLHapticsManager

    var body: some View {
        Form {
            Section("🎮 Experience Level") {
                Toggle("Enable AFL Experience", isOn: $experienceManager.isExperienceEnabled)
                    .onChange(of: experienceManager.isExperienceEnabled) { _, _ in
                        experienceManager.toggleExperience()
                    }

                Picker("Experience Level", selection: $experienceManager.experienceLevel) {
                    ForEach(AFLExperienceManager.ExperienceLevel.allCases, id: \.self) { level in
                        VStack(alignment: .leading) {
                            Text(level.rawValue)
                                .font(.headline)
                            Text(level.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .tag(level)
                    }
                }
                .onChange(of: experienceManager.experienceLevel) { _, newLevel in
                    experienceManager.updateExperienceLevel(newLevel)
                }

                if let currentTeam = experienceManager.currentTeam {
                    HStack {
                        Text("Your Team:")
                        Spacer()
                        Text(experienceManager.getTeamEmoji(for: currentTeam))
                        Text(currentTeam.capitalized)
                    }
                } else {
                    Text("No team selected - select your favorite AFL team for personalized experiences")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Section("🏟️ Game Day") {
                Toggle("Game Day Mode", isOn: $experienceManager.isGameDay)
                    .onChange(of: experienceManager.isGameDay) { _, isOn in
                        if isOn {
                            experienceManager.enableGameDayMode()
                        } else {
                            experienceManager.disableGameDayMode()
                        }
                    }

                Text("Automatically enhances experiences during AFL game times")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("🧪 Test Experience") {
                VStack(spacing: 12) {
                    HStack {
                        AFLButton(title: "Test Trade", style: .primary) {
                            experienceManager.onSuccessfulTrade(playerName: "Test Player")
                        }

                        Spacer()

                        AFLButton(title: "Test Captain", style: .secondary) {
                            experienceManager.onCaptainSelected(playerName: "Test Captain")
                        }
                    }

                    HStack {
                        AFLButton(title: "Test Score", style: .success) {
                            experienceManager.onScoreUpdate(from: 1800, to: 1950)
                        }

                        Spacer()

                        AFLButton(title: "Test Celebration", style: .accent) {
                            experienceManager.onCelebration()
                        }
                    }
                }
            }

            Section("⚙️ Component Settings") {
                NavigationLink("Audio Settings") {
                    AFLAudioSettingsView()
                        .environmentObject(audioManager)
                }

                NavigationLink("Haptic Settings") {
                    AFLHapticsSettingsView()
                        .environmentObject(hapticsManager)
                }
            }
        }
        .navigationTitle("AFL Experience")
    }
}

// MARK: - View Extensions

extension View {
    func withAFLExperience(audioManager: AFLAudioManager, hapticsManager: AFLHapticsManager) -> some View {
        modifier(AFLExperienceEnvironment(audioManager: audioManager, hapticsManager: hapticsManager))
    }

    func onAFLExperience(_ type: AFLExperienceManager.AFLExperienceType, teamName: String? = nil) -> some View {
        background(
            Color.clear
                .onAppear {
                    // This would need to be called from within a view with the environment
                    // In practice, you'd use @EnvironmentObject var experienceManager: AFLExperienceManager
                    // and call experienceManager.triggerExperience(type, teamName: teamName)
                }
        )
    }
}
