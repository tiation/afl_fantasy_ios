//
//  SupportingServices.swift
//  AFL Fantasy Intelligence Platform
//
//  Supporting services for performance monitoring, audio/haptic feedback
//  Created by AI Assistant on 6/9/2025.
//

import Foundation
import AVFoundation
import CoreHaptics
import UIKit

// MARK: - Performance Monitor

final class PerformanceMonitor: ObservableObject {
    static let shared = PerformanceMonitor()
    
    @Published var coldStartTime: TimeInterval = 0
    @Published var averageFrameTime: TimeInterval = 0
    @Published var memoryUsage: Double = 0 // MB
    @Published var isMonitoring: Bool = false
    
    private var coldStartTimer: Date?
    private var frameTimeBuffer: [TimeInterval] = []
    private var displayLink: CADisplayLink?
    private var memoryTimer: Timer?
    
    private init() {
        setupMemoryMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Cold Start Tracking
    
    func startColdStartTimer() {
        coldStartTimer = Date()
    }
    
    func endColdStartTimer() {
        guard let startTime = coldStartTimer else { return }
        coldStartTime = Date().timeIntervalSince(startTime)
        print("🚀 Cold start time: \(String(format: "%.3f", coldStartTime))s")
    }
    
    // MARK: - Frame Rate Monitoring
    
    func startFrameRateMonitoring() {
        guard displayLink == nil else { return }
        
        displayLink = CADisplayLink(target: self, selector: #selector(frameUpdate))
        displayLink?.add(to: .main, forMode: .common)
        isMonitoring = true
    }
    
    func stopFrameRateMonitoring() {
        displayLink?.invalidate()
        displayLink = nil
        isMonitoring = false
    }
    
    @objc private func frameUpdate(_ displayLink: CADisplayLink) {
        let frameTime = displayLink.duration
        frameTimeBuffer.append(frameTime)
        
        // Keep only last 60 frames
        if frameTimeBuffer.count > 60 {
            frameTimeBuffer.removeFirst()
        }
        
        // Update average every 10 frames
        if frameTimeBuffer.count % 10 == 0 {
            averageFrameTime = frameTimeBuffer.reduce(0, +) / Double(frameTimeBuffer.count)
        }
    }
    
    // MARK: - Memory Monitoring
    
    private func setupMemoryMonitoring() {
        memoryTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.updateMemoryUsage()
        }
    }
    
    private func updateMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            memoryUsage = Double(info.resident_size) / (1024 * 1024) // Convert to MB
        }
    }
    
    func stopMonitoring() {
        stopFrameRateMonitoring()
        memoryTimer?.invalidate()
        memoryTimer = nil
    }
    
    // MARK: - Performance Metrics
    
    var currentFPS: Double {
        guard averageFrameTime > 0 else { return 0 }
        return 1.0 / averageFrameTime
    }
    
    var performanceGrade: PerformanceGrade {
        let fps = currentFPS
        let memory = memoryUsage
        
        switch (fps, memory) {
        case (55..., ...150):
            return .excellent
        case (45..., ...200):
            return .good
        case (30..., ...250):
            return .fair
        default:
            return .poor
        }
    }
}

enum PerformanceGrade: String, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    
    var color: UIColor {
        switch self {
        case .excellent: return .systemGreen
        case .good: return .systemBlue
        case .fair: return .systemOrange
        case .poor: return .systemRed
        }
    }
}

// MARK: - AFL Audio Manager

final class AFLAudioManager: ObservableObject {
    @Published var isSoundEnabled: Bool = true
    @Published var soundVolume: Float = 0.7
    
    private var audioEngine: AVAudioEngine?
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        setupAudioSession()
        preloadSounds()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func preloadSounds() {
        // Preload common sounds for better performance
        preloadSound("goal_horn")
        preloadSound("notification_chime")
        preloadSound("trade_complete")
    }
    
    private func preloadSound(_ soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
        } catch {
            print("Failed to preload sound \(soundName): \(error)")
        }
    }
    
    // MARK: - Sound Effects
    
    func onAppLaunch() {
        playSound("app_launch", volume: 0.5)
    }
    
    func onGoalScored() {
        playSound("goal_horn", volume: 0.8)
        triggerSuccessHaptic()
    }
    
    func onTradeCompleted() {
        playSound("trade_complete", volume: 0.6)
        triggerNotificationHaptic()
    }
    
    func onPriceChange(positive: Bool) {
        let sound = positive ? "price_up" : "price_down"
        playSound(sound, volume: 0.4)
    }
    
    func onNotificationReceived() {
        playSound("notification_chime", volume: 0.5)
    }
    
    func onErrorOccurred() {
        playSound("error_sound", volume: 0.6)
        triggerErrorHaptic()
    }
    
    private func playSound(_ soundName: String, volume: Float? = nil) {
        guard isSoundEnabled else { return }
        
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            // Fallback to system sounds
            playSystemSound(soundName)
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = volume ?? soundVolume
            audioPlayer?.play()
        } catch {
            print("Failed to play sound \(soundName): \(error)")
            playSystemSound(soundName)
        }
    }
    
    private func playSystemSound(_ soundName: String) {
        // Map custom sounds to system sound IDs
        let systemSoundID: SystemSoundID
        
        switch soundName {
        case "goal_horn", "trade_complete":
            systemSoundID = 1016 // Anticipate
        case "notification_chime":
            systemSoundID = 1005 // New Message
        case "error_sound":
            systemSoundID = 1073 // Error
        default:
            systemSoundID = 1104 // Camera Shutter
        }
        
        AudioServicesPlaySystemSound(systemSoundID)
    }
    
    private func triggerSuccessHaptic() {
        AFLHapticsManager.shared.triggerSuccessHaptic()
    }
    
    private func triggerNotificationHaptic() {
        AFLHapticsManager.shared.triggerNotificationHaptic()
    }
    
    private func triggerErrorHaptic() {
        AFLHapticsManager.shared.triggerErrorHaptic()
    }
    
    // MARK: - Settings
    
    func toggleSound(_ enabled: Bool) {
        isSoundEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "sound_enabled")
    }
    
    func setSoundVolume(_ volume: Float) {
        soundVolume = max(0.0, min(1.0, volume))
        UserDefaults.standard.set(soundVolume, forKey: "sound_volume")
    }
}

// MARK: - AFL Haptics Manager

final class AFLHapticsManager: ObservableObject {
    static let shared = AFLHapticsManager()
    
    @Published var isHapticsEnabled: Bool = true
    
    private var hapticEngine: CHHapticEngine?
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    init() {
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
    
    func onAppLaunch() {
        playCustomHaptic(.appLaunch)
    }
    
    func onGoalScored() {
        playCustomHaptic(.goalCelebration)
    }
    
    func onTradeCompleted() {
        triggerSuccessHaptic()
    }
    
    func onPriceIncrease() {
        playCustomHaptic(.priceUp)
    }
    
    func onPriceDecrease() {
        playCustomHaptic(.priceDown)
    }
    
    func onPlayerSelected() {
        triggerSelectionHaptic()
    }
    
    func onButtonPressed() {
        triggerLightImpact()
    }
    
    func onSwipeAction() {
        triggerMediumImpact()
    }
    
    func onDataRefreshed() {
        triggerNotificationHaptic()
    }
    
    // MARK: - Basic Haptic Types
    
    func triggerLightImpact() {
        guard isHapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func triggerMediumImpact() {
        guard isHapticsEnabled else { return }
        impactGenerator.impactOccurred()
    }
    
    func triggerHeavyImpact() {
        guard isHapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    func triggerSuccessHaptic() {
        guard isHapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }
    
    func triggerWarningHaptic() {
        guard isHapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.warning)
    }
    
    func triggerErrorHaptic() {
        guard isHapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.error)
    }
    
    func triggerSelectionHaptic() {
        guard isHapticsEnabled else { return }
        selectionGenerator.selectionChanged()
    }
    
    func triggerNotificationHaptic() {
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
        let events: [CHHapticEvent]
        
        switch pattern {
        case .appLaunch:
            events = [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ], relativeTime: 0)
            ]
            
        case .goalCelebration:
            events = [
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
            events = [
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
            events = [
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
    
    func toggleHaptics(_ enabled: Bool) {
        isHapticsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "haptics_enabled")
        
        if enabled {
            triggerSelectionHaptic() // Confirmation haptic
        }
    }
}

enum HapticPattern {
    case appLaunch
    case goalCelebration
    case priceUp
    case priceDown
}

// MARK: - Cache Manager

final class CacheManager {
    static let shared = CacheManager()
    
    private let cache = NSCache<NSString, NSData>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Setup cache directory
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDirectory.appendingPathComponent("AFLFantasyCache")
        
        // Create cache directory if needed
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Configure memory cache
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        setupCacheCleanup()
    }
    
    private func setupCacheCleanup() {
        // Clean cache on app launch
        cleanExpiredCache()
        
        // Setup periodic cleanup
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            self.cleanExpiredCache()
        }
    }
    
    // MARK: - Memory Cache
    
    func setMemoryCache<T: Codable>(_ object: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(object)
            cache.setObject(data as NSData, forKey: key as NSString)
        } catch {
            print("Failed to cache object: \(error)")
        }
    }
    
    func getMemoryCache<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = cache.object(forKey: key as NSString) as Data? else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("Failed to decode cached object: \(error)")
            return nil
        }
    }
    
    // MARK: - Disk Cache
    
    func setDiskCache<T: Codable>(_ object: T, forKey key: String, expiration: TimeInterval = 3600) {
        let cacheItem = CacheItem(data: object, expiration: Date().addingTimeInterval(expiration))
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        do {
            let data = try JSONEncoder().encode(cacheItem)
            try data.write(to: fileURL)
        } catch {
            print("Failed to write cache to disk: \(error)")
        }
    }
    
    func getDiskCache<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        do {
            let data = try Data(contentsOf: fileURL)
            let cacheItem = try JSONDecoder().decode(CacheItem<T>.self, from: data)
            
            if cacheItem.expiration > Date() {
                return cacheItem.data
            } else {
                // Remove expired cache
                try? fileManager.removeItem(at: fileURL)
                return nil
            }
        } catch {
            return nil
        }
    }
    
    // MARK: - Cache Management
    
    func clearMemoryCache() {
        cache.removeAllObjects()
    }
    
    func clearDiskCache() {
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for file in files {
                try fileManager.removeItem(at: file)
            }
        } catch {
            print("Failed to clear disk cache: \(error)")
        }
    }
    
    func clearAllCache() {
        clearMemoryCache()
        clearDiskCache()
    }
    
    private func cleanExpiredCache() {
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey])
            let oneWeekAgo = Date().addingTimeInterval(-604800) // 1 week
            
            for file in files {
                let attributes = try fileManager.attributesOfItem(atPath: file.path)
                if let modificationDate = attributes[.modificationDate] as? Date,
                   modificationDate < oneWeekAgo {
                    try fileManager.removeItem(at: file)
                }
            }
        } catch {
            print("Failed to clean expired cache: \(error)")
        }
    }
    
    func getCacheSize() -> Int64 {
        var totalSize: Int64 = 0
        
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
            for file in files {
                let attributes = try fileManager.attributesOfItem(atPath: file.path)
                if let fileSize = attributes[.size] as? Int64 {
                    totalSize += fileSize
                }
            }
        } catch {
            print("Failed to calculate cache size: \(error)")
        }
        
        return totalSize
    }
}

private struct CacheItem<T: Codable>: Codable {
    let data: T
    let expiration: Date
}

// MARK: - Notification Manager

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var hasPermission: Bool = false
    
    private init() {
        checkPermissionStatus()
    }
    
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                hasPermission = granted
            }
            return granted
        } catch {
            print("Failed to request notification permission: \(error)")
            return false
        }
    }
    
    private func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func schedulePlayerAlert(_ player: EnhancedPlayer, type: PlayerAlertType) {
        guard hasPermission else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "AFL Fantasy Alert"
        content.sound = .default
        
        switch type {
        case .priceRise:
            content.body = "\(player.name)'s price has increased! Consider selling."
        case .priceWatch:
            content.body = "\(player.name) is approaching a price change."
        case .injuryUpdate:
            content.body = "\(player.name) injury status updated."
        case .formAlert:
            content.body = "\(player.name) form has changed significantly."
        }
        
        let identifier = "player-\(player.aflPlayerId)-\(type.rawValue)"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

enum PlayerAlertType: String {
    case priceRise = "price_rise"
    case priceWatch = "price_watch"
    case injuryUpdate = "injury_update"
    case formAlert = "form_alert"
}
