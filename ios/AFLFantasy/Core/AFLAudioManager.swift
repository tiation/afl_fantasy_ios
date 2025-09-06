//
//  AFLAudioManager.swift
//  AFL Fantasy Intelligence Platform
//
//  Created by AI Assistant on 6/9/2025.
//  Copyright © 2025 AFL AI. All rights reserved.
//

import AVFoundation
import Combine
import SwiftUI

// MARK: - AFLAudioManager

/// Comprehensive audio system for AFL Fantasy with commentator sounds and dynamic audio
@MainActor
class AFLAudioManager: ObservableObject {
    // MARK: - Audio Engine

    private var audioEngine = AVAudioEngine()
    private var audioSession = AVAudioSession.sharedInstance()
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var backgroundPlayer: AVAudioPlayer?
    private var commentatorPlayer: AVAudioPlayer?

    // MARK: - State

    @Published var isMuted: Bool = false
    @Published var sfxVolume: Float = 0.7
    @Published var commentatorVolume: Float = 0.8
    @Published var backgroundVolume: Float = 0.3
    @Published var isCommentatorEnabled: Bool = true

    // MARK: - Audio Types

    enum SoundEffect: String, CaseIterable {
        // UI Sounds
        case buttonTap = "button_tap"
        case buttonSuccess = "button_success"
        case buttonError = "button_error"
        case cardFlip = "card_flip"
        case slideIn = "slide_in"
        case slideOut = "slide_out"
        case popup
        case notification

        // AFL Specific
        case whistleShort = "whistle_short"
        case whistleLong = "whistle_long"
        case crowdCheer = "crowd_cheer"
        case crowdGroan = "crowd_groan"
        case siren
        case goalUmpire = "goal_umpire"
        case scoreUpdate = "score_update"
        case tradeBell = "trade_bell"
        case cashRegister = "cash_register"
        case celebration

        var fileName: String {
            "\(rawValue).mp3"
        }
    }

    enum CommentatorClip: String, CaseIterable {
        // App Launch
        case welcomeBack = "welcome_back"
        case gameTime = "game_time"
        case letsGo = "lets_go"

        // Navigation
        case dashboard = "checking_the_stats"
        case trades = "trade_time"
        case captain = "captain_selection"
        case cashCows = "rookie_watch"

        // Actions
        case goodTrade = "beauty_of_a_trade"
        case badTrade = "questionable_move"
        case excellentTrade = "masterstroke"
        case priceRise = "rising_star"
        case priceDrop = "falling_fast"
        case milestone = "what_a_legend"

        // Scores
        case highScore = "monster_score"
        case lowScore = "disappointing"
        case consistentScore = "reliable_as_always"

        // General Excitement
        case excitement1 = "unbelievable"
        case excitement2 = "sensational"
        case excitement3 = "brilliant_move"
        case suspense = "edge_of_your_seat"

        var fileName: String {
            "commentator_\(rawValue).mp3"
        }
    }

    enum BackgroundAmbient: String {
        case stadium = "stadium_ambient"
        case crowd = "crowd_ambient"
        case pregame = "pregame_atmosphere"
        case celebration = "celebration_ambient"

        var fileName: String {
            "ambient_\(rawValue).mp3"
        }
    }

    // MARK: - Initialization

    init() {
        setupAudioSession()
        loadAudioFiles()
        setupUserDefaults()
    }

    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    private func loadAudioFiles() {
        // Load all sound effects
        for effect in SoundEffect.allCases {
            if let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "mp3") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    player.volume = sfxVolume
                    audioPlayers[effect.rawValue] = player
                } catch {
                    print("Failed to load sound effect \(effect.rawValue): \(error)")
                    // Create synthesized sound as fallback
                    createSynthesizedSound(for: effect)
                }
            } else {
                // Create synthesized sound as fallback
                createSynthesizedSound(for: effect)
            }
        }

        // Load commentator clips
        for clip in CommentatorClip.allCases {
            if let url = Bundle.main.url(forResource: "commentator_\(clip.rawValue)", withExtension: "mp3") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    player.volume = commentatorVolume
                    audioPlayers["commentator_\(clip.rawValue)"] = player
                } catch {
                    print("Failed to load commentator clip \(clip.rawValue): \(error)")
                    // Create synthesized voice as fallback
                    createSynthesizedCommentary(for: clip)
                }
            } else {
                // Create synthesized voice as fallback
                createSynthesizedCommentary(for: clip)
            }
        }
    }

    private func setupUserDefaults() {
        // Load saved settings
        isMuted = UserDefaults.standard.bool(forKey: "AFL_Audio_Muted")
        sfxVolume = UserDefaults.standard.float(forKey: "AFL_SFX_Volume")
        commentatorVolume = UserDefaults.standard.float(forKey: "AFL_Commentator_Volume")
        backgroundVolume = UserDefaults.standard.float(forKey: "AFL_Background_Volume")
        isCommentatorEnabled = UserDefaults.standard.bool(forKey: "AFL_Commentator_Enabled")

        // Set defaults if not previously set
        if sfxVolume == 0 { sfxVolume = 0.7 }
        if commentatorVolume == 0 { commentatorVolume = 0.8 }
        if backgroundVolume == 0 { backgroundVolume = 0.3 }
        if !UserDefaults.standard.bool(forKey: "AFL_Audio_Defaults_Set") {
            isCommentatorEnabled = true
            UserDefaults.standard.set(true, forKey: "AFL_Audio_Defaults_Set")
        }
    }

    // MARK: - Sound Effect Playback

    func playSound(_ effect: SoundEffect, volume: Float? = nil) {
        guard !isMuted else { return }

        if let player = audioPlayers[effect.rawValue] {
            player.volume = volume ?? sfxVolume
            player.stop()
            player.currentTime = 0
            player.play()
        }
    }

    // MARK: - Commentator Playback

    func playCommentary(_ clip: CommentatorClip, delay: TimeInterval = 0) {
        guard !isMuted, isCommentatorEnabled else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if let player = self.audioPlayers["commentator_\(clip.rawValue)"] {
                // Stop current commentator if playing
                self.commentatorPlayer?.stop()
                self.commentatorPlayer = player

                player.volume = self.commentatorVolume
                player.stop()
                player.currentTime = 0
                player.play()
            }
        }
    }

    // MARK: - Random Commentary

    func playRandomCommentary(for context: CommentaryContext) {
        let clips = getCommentaryClips(for: context)
        guard let randomClip = clips.randomElement() else { return }
        playCommentary(randomClip, delay: 0.5)
    }

    enum CommentaryContext {
        case appLaunch
        case navigation
        case goodAction
        case badAction
        case excitement
        case scoring
    }

    private func getCommentaryClips(for context: CommentaryContext) -> [CommentatorClip] {
        switch context {
        case .appLaunch:
            [.welcomeBack, .gameTime, .letsGo]
        case .navigation:
            [.dashboard, .trades, .captain, .cashCows]
        case .goodAction:
            [.goodTrade, .excellentTrade, .priceRise, .milestone]
        case .badAction:
            [.badTrade, .priceDrop, .disappointing]
        case .excitement:
            [.excitement1, .excitement2, .excitement3, .suspense]
        case .scoring:
            [.highScore, .consistentScore, .lowScore]
        }
    }

    // MARK: - Background Ambient

    func playBackgroundAmbient(_ ambient: BackgroundAmbient, loop: Bool = true) {
        guard !isMuted else { return }

        if let url = Bundle.main.url(forResource: ambient.rawValue, withExtension: "mp3") {
            do {
                backgroundPlayer?.stop()
                backgroundPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundPlayer?.volume = backgroundVolume
                backgroundPlayer?.numberOfLoops = loop ? -1 : 0
                backgroundPlayer?.play()
            } catch {
                print("Failed to play background ambient: \(error)")
            }
        }
    }

    func stopBackgroundAmbient() {
        backgroundPlayer?.stop()
        backgroundPlayer = nil
    }

    // MARK: - Contextual Audio

    func onAppLaunch() {
        playSound(.siren, volume: 0.5)
        playRandomCommentary(for: .appLaunch)
        playBackgroundAmbient(.pregame)
    }

    func onTabChange() {
        playSound(.buttonTap)
    }

    func onTradeComplete(isGood: Bool) {
        if isGood {
            playSound(.tradeBell)
            playSound(.crowdCheer)
            playRandomCommentary(for: .goodAction)
        } else {
            playSound(.crowdGroan)
            playRandomCommentary(for: .badAction)
        }
    }

    func onScoreUpdate(oldScore: Int, newScore: Int) {
        if newScore > oldScore {
            playSound(.scoreUpdate)
            if newScore - oldScore > 50 {
                playRandomCommentary(for: .excitement)
            }
        }
    }

    func onCaptainSelection() {
        playSound(.whistleShort)
        playCommentary(.captain, delay: 0.3)
    }

    func onCashCowSell() {
        playSound(.cashRegister)
        playCommentary(.priceRise, delay: 0.2)
    }

    func onMilestoneReached() {
        playSound(.celebration)
        playSound(.crowdCheer)
        playCommentary(.milestone, delay: 0.5)
    }

    // MARK: - Settings

    func updateSFXVolume(_ volume: Float) {
        sfxVolume = volume
        UserDefaults.standard.set(volume, forKey: "AFL_SFX_Volume")

        // Update all SFX players
        for effect in SoundEffect.allCases {
            audioPlayers[effect.rawValue]?.volume = volume
        }
    }

    func updateCommentatorVolume(_ volume: Float) {
        commentatorVolume = volume
        UserDefaults.standard.set(volume, forKey: "AFL_Commentator_Volume")

        // Update commentator players
        for clip in CommentatorClip.allCases {
            audioPlayers["commentator_\(clip.rawValue)"]?.volume = volume
        }
    }

    func updateBackgroundVolume(_ volume: Float) {
        backgroundVolume = volume
        UserDefaults.standard.set(volume, forKey: "AFL_Background_Volume")
        backgroundPlayer?.volume = volume
    }

    func toggleMute() {
        isMuted.toggle()
        UserDefaults.standard.set(isMuted, forKey: "AFL_Audio_Muted")

        if isMuted {
            stopAllSounds()
        }
    }

    func toggleCommentator() {
        isCommentatorEnabled.toggle()
        UserDefaults.standard.set(isCommentatorEnabled, forKey: "AFL_Commentator_Enabled")

        if !isCommentatorEnabled {
            commentatorPlayer?.stop()
        }
    }

    private func stopAllSounds() {
        for player in audioPlayers.values {
            player.stop()
        }
        backgroundPlayer?.stop()
        commentatorPlayer?.stop()
    }

    // MARK: - Synthesized Audio Fallbacks

    private func createSynthesizedSound(for effect: SoundEffect) {
        // Create simple synthesized sounds using AVAudioEngine as fallback
        // This ensures the app works even without audio files
        print("Creating synthesized sound for: \(effect.rawValue)")

        // For now, we'll use system sounds as fallback
        switch effect {
        case .buttonTap, .buttonSuccess, .slideIn:
            // Use system keyboard click sound
            AudioServicesPlaySystemSound(1104)
        case .buttonError:
            // Use system alert sound
            AudioServicesPlaySystemSound(1005)
        case .notification, .popup:
            // Use system notification sound
            AudioServicesPlaySystemSound(1007)
        default:
            // Use default system sound
            AudioServicesPlaySystemSound(1000)
        }
    }

    private func createSynthesizedCommentary(for clip: CommentatorClip) {
        // Use AVSpeechSynthesizer for text-to-speech commentary
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: getCommentaryText(for: clip))

        // Configure voice for AFL commentary feel
        utterance.rate = 0.6
        utterance.pitchMultiplier = 0.9
        utterance.volume = commentatorVolume

        // Use Australian English if available
        if let voice = AVSpeechSynthesisVoice(language: "en-AU") {
            utterance.voice = voice
        }

        synthesizer.speak(utterance)
    }

    private func getCommentaryText(for clip: CommentatorClip) -> String {
        switch clip {
        case .welcomeBack: "Welcome back to AFL Fantasy!"
        case .gameTime: "Game time! Let's see what you've got!"
        case .letsGo: "Let's go! Time to make some moves!"
        case .dashboard: "Checking the stats board!"
        case .trades: "Trade time! Who's in, who's out?"
        case .captain: "Captain selection - this is crucial!"
        case .cashCows: "Rookie watch! Who's making money?"
        case .goodTrade: "Beauty of a trade! Well done!"
        case .badTrade: "That's a questionable move there!"
        case .excellentTrade: "Absolute masterstroke!"
        case .priceRise: "Rising star! The price is climbing!"
        case .priceDrop: "Falling fast! Time to move!"
        case .milestone: "What a legend! Milestone reached!"
        case .highScore: "Monster score! Unbelievable!"
        case .lowScore: "Disappointing result there."
        case .consistentScore: "Reliable as always!"
        case .excitement1: "Unbelievable! What a moment!"
        case .excitement2: "Sensational! That's fantastic!"
        case .excitement3: "Brilliant move! Absolutely brilliant!"
        case .suspense: "You're on the edge of your seat!"
        }
    }
}

// MARK: - Audio View Modifiers

extension View {
    func withAFLAudio() -> some View {
        environmentObject(AFLAudioManager())
    }

    func onAFLTap(sound: AFLAudioManager.SoundEffect = .buttonTap, action: @escaping () -> Void) -> some View {
        modifier(AFLTapModifier(sound: sound, action: action))
    }
}

struct AFLTapModifier: ViewModifier {
    @EnvironmentObject var audioManager: AFLAudioManager
    let sound: AFLAudioManager.SoundEffect
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                audioManager.playSound(sound)
                action()
            }
    }
}

// MARK: - Audio Settings View

struct AFLAudioSettingsView: View {
    @EnvironmentObject var audioManager: AFLAudioManager

    var body: some View {
        Form {
            Section("🔊 Audio Settings") {
                HStack {
                    Image(systemName: audioManager.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .foregroundColor(audioManager.isMuted ? .red : .blue)

                    Toggle("Mute All Sounds", isOn: $audioManager.isMuted)
                        .onChange(of: audioManager.isMuted) { _, _ in
                            audioManager.toggleMute()
                        }
                }

                Toggle("AFL Commentary", isOn: $audioManager.isCommentatorEnabled)
                    .onChange(of: audioManager.isCommentatorEnabled) { _, _ in
                        audioManager.toggleCommentator()
                    }
            }

            Section("🎚️ Volume Controls") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Sound Effects")
                        Spacer()
                        Text("\(Int(audioManager.sfxVolume * 100))%")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: Binding(
                        get: { audioManager.sfxVolume },
                        set: { audioManager.updateSFXVolume($0) }
                    ), in: 0 ... 1)
                        .tint(.orange)
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Commentary")
                        Spacer()
                        Text("\(Int(audioManager.commentatorVolume * 100))%")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: Binding(
                        get: { audioManager.commentatorVolume },
                        set: { audioManager.updateCommentatorVolume($0) }
                    ), in: 0 ... 1)
                        .tint(.blue)
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Background")
                        Spacer()
                        Text("\(Int(audioManager.backgroundVolume * 100))%")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: Binding(
                        get: { audioManager.backgroundVolume },
                        set: { audioManager.updateBackgroundVolume($0) }
                    ), in: 0 ... 1)
                        .tint(.green)
                }
            }

            Section("🎵 Test Sounds") {
                AFLButton(title: "Test Commentary", style: .primary) {
                    audioManager.playRandomCommentary(for: .excitement)
                }

                AFLButton(title: "Test Trade Bell", style: .secondary) {
                    audioManager.playSound(.tradeBell)
                }

                AFLButton(title: "Test Crowd Cheer", style: .success) {
                    audioManager.playSound(.crowdCheer)
                }
            }
        }
        .navigationTitle("Audio Settings")
    }
}
