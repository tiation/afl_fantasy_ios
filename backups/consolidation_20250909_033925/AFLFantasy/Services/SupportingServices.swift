//
//  SupportingServices.swift
//  AFL Fantasy Intelligence Platform
//
//  Supporting services for performance monitoring, audio/haptic feedback
//  Created by AI Assistant on 6/9/2025.
//

import AVFoundation
import CoreHaptics
import Foundation
import UIKit

// MARK: - PerformanceMonitor

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

// MARK: - PerformanceGrade

enum PerformanceGrade: String, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"

    var color: UIColor {
        switch self {
        case .excellent: .systemGreen
        case .good: .systemBlue
        case .fair: .systemOrange
        case .poor: .systemRed
        }
    }
}

// MARK: - AFLAudioManager

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
        let systemSoundID: SystemSoundID = switch soundName {
        case "goal_horn", "trade_complete":
            1016 // Anticipate
        case "notification_chime":
            1005 // New Message
        case "error_sound":
            1073 // Error
        default:
            1104 // Camera Shutter
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

// AFLHapticsManager has been moved to Core/DesignSystem/AFLHapticsManager.swift

// MARK: - CacheManager

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

    func setMemoryCache(_ object: some Codable, forKey key: String) {
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

    func setDiskCache(_ object: some Codable, forKey key: String, expiration: TimeInterval = 3600) {
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
            let files = try fileManager.contentsOfDirectory(
                at: cacheDirectory,
                includingPropertiesForKeys: [.contentModificationDateKey]
            )
            let oneWeekAgo = Date().addingTimeInterval(-604_800) // 1 week

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
            let files = try fileManager.contentsOfDirectory(
                at: cacheDirectory,
                includingPropertiesForKeys: [.fileSizeKey]
            )
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

// MARK: - CacheItem

private struct CacheItem<T: Codable>: Codable {
    let data: T
    let expiration: Date
}

// MARK: - NotificationManager
// Note: NotificationManager moved to dedicated NotificationManager.swift file
// to avoid duplicate definitions

// MARK: - PlayerAlertType

enum PlayerAlertType: String {
    case priceRise = "price_rise"
    case priceWatch = "price_watch"
    case injuryUpdate = "injury_update"
    case formAlert = "form_alert"
}
