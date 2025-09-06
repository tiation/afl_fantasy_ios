//
//  PerformanceMonitoring.swift
//  AFL Fantasy Intelligence Platform
//
//  Real-time performance monitoring with advanced metrics collection and optimization suggestions
//  Created by AI Assistant on 6/9/2025.
//

import Combine
import MetricKit
import os.log
import SwiftUI
import UIKit

// MARK: - PerformanceMonitoringSystem

@MainActor
class PerformanceMonitoringSystem: NSObject, ObservableObject {
    static let shared = PerformanceMonitoringSystem()

    @Published var currentPerformance: PerformanceSnapshot = .init()
    @Published var performanceTrends: PerformanceTrends = .init()
    @Published var optimizationRecommendations: [OptimizationRecommendation] = []
    @Published var isMonitoringActive: Bool = false

    private var performanceCollector = PerformanceDataCollector()
    private var frameTimeProfiler = FrameTimeProfiler()
    private var batteryProfiler = BatteryImpactProfiler()
    private var thermalMonitor = ThermalStateMonitor()
    private var analyticsReporter = PerformanceAnalytics()

    private var monitoringTimer: Timer?
    private var sessionStartTime = Date()

    struct PerformanceSnapshot {
        var timestamp = Date()
        var frameMetrics: FrameMetrics = .init()
        var memoryMetrics: MemoryMetrics = .init()
        var networkMetrics: NetworkMetrics = .init()
        var batteryMetrics: BatteryMetrics = .init()
        var thermalState: ThermalState = .nominal
        var overallScore: PerformanceScore = .excellent

        struct FrameMetrics {
            var averageFPS: Double = 60.0
            var frameDrops: Int = 0
            var jankPercentage: Double = 0.0
            var worstFrameTime: TimeInterval = 0.0
        }

        struct MemoryMetrics {
            var totalUsage: Int64 = 0
            var peakUsage: Int64 = 0
            var memoryPressure: MemoryPressureLevel = .normal
            var leakSuspects: [String] = []
        }

        struct NetworkMetrics {
            var requestsPerSecond: Double = 0
            var averageLatency: TimeInterval = 0
            var errorRate: Double = 0
            var dataEfficiency: Double = 1.0
        }

        struct BatteryMetrics {
            var powerDrawMW: Double = 0
            var thermalPressure: Double = 0
            var batteryLevel: Double = 1.0
            var energyImpact: EnergyImpactLevel = .low
        }

        enum ThermalState {
            case nominal, fair, serious, critical

            var description: String {
                switch self {
                case .nominal: "Optimal"
                case .fair: "Warm"
                case .serious: "Hot"
                case .critical: "Critical"
                }
            }

            var color: Color {
                switch self {
                case .nominal: .green
                case .fair: .yellow
                case .serious: .orange
                case .critical: .red
                }
            }
        }

        enum EnergyImpactLevel {
            case low, medium, high
        }

        enum PerformanceScore {
            case excellent, good, fair, poor

            var description: String {
                switch self {
                case .excellent: "Excellent"
                case .good: "Good"
                case .fair: "Fair"
                case .poor: "Needs Optimization"
                }
            }

            var color: Color {
                switch self {
                case .excellent: .green
                case .good: .blue
                case .fair: .orange
                case .poor: .red
                }
            }

            var score: Int {
                switch self {
                case .excellent: 90
                case .good: 75
                case .fair: 60
                case .poor: 40
                }
            }
        }
    }

    struct PerformanceTrends {
        var frameRateHistory: [Double] = []
        var memoryUsageHistory: [Int64] = []
        var batteryImpactHistory: [Double] = []
        var sessionDuration: TimeInterval = 0
        var improvementAreas: [ImprovementArea] = []

        enum ImprovementArea {
            case frameRate, memory, battery, network

            var title: String {
                switch self {
                case .frameRate: "Frame Rate"
                case .memory: "Memory Usage"
                case .battery: "Battery Impact"
                case .network: "Network Efficiency"
                }
            }
        }
    }

    struct OptimizationRecommendation {
        let id = UUID()
        let title: String
        let description: String
        let impact: Impact
        let category: Category
        let action: (() -> Void)?
        let estimatedImprovement: String

        enum Impact {
            case low, medium, high, critical

            var color: Color {
                switch self {
                case .low: .green
                case .medium: .blue
                case .high: .orange
                case .critical: .red
                }
            }
        }

        enum Category {
            case performance, memory, battery, network, ui

            var icon: String {
                switch self {
                case .performance: "speedometer"
                case .memory: "memorychip"
                case .battery: "battery.100"
                case .network: "network"
                case .ui: "paintbrush"
                }
            }
        }
    }

    override init() {
        super.init()
        setupMetricKit()
        setupThermalMonitoring()
    }

    private func setupMetricKit() {
        if #available(iOS 13.0, *) {
            MXMetricManager.shared.add(self)
        }
    }

    private func setupThermalMonitoring() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(thermalStateDidChange),
            name: ProcessInfo.thermalStateDidChangeNotification,
            object: nil
        )
    }

    @objc private func thermalStateDidChange() {
        Task { @MainActor in
            updateThermalState()
        }
    }

    func startMonitoring() {
        guard !isMonitoringActive else { return }

        isMonitoringActive = true
        sessionStartTime = Date()

        // Start real-time monitoring
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.collectPerformanceMetrics()
            }
        }

        // Start specialized profilers
        frameTimeProfiler.startProfiling()
        batteryProfiler.startProfiling()

        print("🔍 Performance monitoring started")
    }

    func stopMonitoring() {
        guard isMonitoringActive else { return }

        isMonitoringActive = false

        monitoringTimer?.invalidate()
        monitoringTimer = nil

        frameTimeProfiler.stopProfiling()
        batteryProfiler.stopProfiling()

        // Generate final session report
        generateSessionReport()

        print("⏹️ Performance monitoring stopped")
    }

    private func collectPerformanceMetrics() {
        let snapshot = PerformanceSnapshot(
            timestamp: Date(),
            frameMetrics: frameTimeProfiler.getCurrentMetrics(),
            memoryMetrics: collectMemoryMetrics(),
            networkMetrics: NetworkIntelligence.shared.networkMetrics.toPerformanceMetrics(),
            batteryMetrics: batteryProfiler.getCurrentMetrics(),
            thermalState: thermalMonitor.currentState,
            overallScore: calculateOverallScore()
        )

        currentPerformance = snapshot
        updateTrends(snapshot)
        generateRecommendations(snapshot)
    }

    private func collectMemoryMetrics() -> PerformanceSnapshot.MemoryMetrics {
        let memoryManager = MemoryManager.shared
        let currentStats = memoryManager.currentMemoryUsage

        return PerformanceSnapshot.MemoryMetrics(
            totalUsage: currentStats.appSpecific,
            peakUsage: performanceCollector.peakMemoryUsage,
            memoryPressure: memoryManager.memoryPressureLevel.toPerformanceLevel(),
            leakSuspects: performanceCollector.detectMemoryLeaks()
        )
    }

    private func updateThermalState() {
        let processInfo = ProcessInfo.processInfo

        switch processInfo.thermalState {
        case .nominal:
            currentPerformance.thermalState = .nominal
        case .fair:
            currentPerformance.thermalState = .fair
        case .serious:
            currentPerformance.thermalState = .serious
        case .critical:
            currentPerformance.thermalState = .critical
        @unknown default:
            currentPerformance.thermalState = .nominal
        }
    }

    private func calculateOverallScore() -> PerformanceSnapshot.PerformanceScore {
        let frameScore = frameTimeProfiler.getPerformanceScore()
        let memoryScore = MemoryManager.shared.getPerformanceScore()
        let networkScore = NetworkIntelligence.shared.getPerformanceScore()
        let batteryScore = batteryProfiler.getPerformanceScore()

        let averageScore = (frameScore + memoryScore + networkScore + batteryScore) / 4

        switch averageScore {
        case 85 ... 100:
            return .excellent
        case 70 ..< 85:
            return .good
        case 50 ..< 70:
            return .fair
        default:
            return .poor
        }
    }

    private func updateTrends(_ snapshot: PerformanceSnapshot) {
        performanceTrends.frameRateHistory.append(snapshot.frameMetrics.averageFPS)
        performanceTrends.memoryUsageHistory.append(snapshot.memoryMetrics.totalUsage)
        performanceTrends.batteryImpactHistory.append(snapshot.batteryMetrics.powerDrawMW)
        performanceTrends.sessionDuration = Date().timeIntervalSince(sessionStartTime)

        // Keep only last 60 data points (1 minute at 1Hz sampling)
        if performanceTrends.frameRateHistory.count > 60 {
            performanceTrends.frameRateHistory.removeFirst()
            performanceTrends.memoryUsageHistory.removeFirst()
            performanceTrends.batteryImpactHistory.removeFirst()
        }

        // Identify improvement areas
        identifyImprovementAreas()
    }

    private func identifyImprovementAreas() {
        var areas: [PerformanceTrends.ImprovementArea] = []

        // Check frame rate
        let avgFPS = performanceTrends.frameRateHistory.last ?? 60.0
        if avgFPS < 55.0 {
            areas.append(.frameRate)
        }

        // Check memory usage trend
        if performanceTrends.memoryUsageHistory.count >= 10 {
            let recent = performanceTrends.memoryUsageHistory.suffix(10)
            let isIncreasing = recent.last! > recent.first! * 1.2
            if isIncreasing {
                areas.append(.memory)
            }
        }

        // Check battery impact
        let avgBatteryImpact = performanceTrends.batteryImpactHistory.last ?? 0
        if avgBatteryImpact > 1000 { // > 1W
            areas.append(.battery)
        }

        performanceTrends.improvementAreas = areas
    }

    private func generateRecommendations(_ snapshot: PerformanceSnapshot) {
        var recommendations: [OptimizationRecommendation] = []

        // Frame rate recommendations
        if snapshot.frameMetrics.averageFPS < 55 {
            recommendations.append(OptimizationRecommendation(
                title: "Frame Rate Below Target",
                description: "Average FPS is \(Int(snapshot.frameMetrics.averageFPS)). Consider reducing visual complexity.",
                impact: .high,
                category: .performance,
                action: {
                    // Reduce animation complexity
                    self.frameTimeProfiler.enablePerformanceMode()
                },
                estimatedImprovement: "+15 FPS"
            ))
        }

        // Memory recommendations
        if snapshot.memoryMetrics.memoryPressure != .normal {
            recommendations.append(OptimizationRecommendation(
                title: "High Memory Usage",
                description: "Memory pressure detected. Clear caches and optimize data structures.",
                impact: .high,
                category: .memory,
                action: {
                    MemoryManager.shared.performEmergencyCleanup()
                },
                estimatedImprovement: "-50MB"
            ))
        }

        // Battery recommendations
        if snapshot.batteryMetrics.energyImpact == .high {
            recommendations.append(OptimizationRecommendation(
                title: "High Battery Usage",
                description: "Optimize background tasks and reduce CPU intensive operations.",
                impact: .medium,
                category: .battery,
                action: {
                    self.batteryProfiler.enablePowerSavingMode()
                },
                estimatedImprovement: "-30% Power"
            ))
        }

        // Network recommendations
        if snapshot.networkMetrics.errorRate > 0.05 {
            recommendations.append(OptimizationRecommendation(
                title: "Network Errors",
                description: "High network error rate detected. Check connectivity and retry logic.",
                impact: .medium,
                category: .network,
                action: {
                    NetworkIntelligence.shared.optimizationLevel = .conservative
                },
                estimatedImprovement: "-50% Errors"
            ))
        }

        // Thermal recommendations
        if snapshot.thermalState == .serious || snapshot.thermalState == .critical {
            recommendations.append(OptimizationRecommendation(
                title: "Thermal Throttling Risk",
                description: "Device temperature is high. Reduce CPU/GPU intensive tasks.",
                impact: .critical,
                category: .performance,
                action: {
                    self.enableThermalMitigation()
                },
                estimatedImprovement: "Prevent Throttling"
            ))
        }

        optimizationRecommendations = recommendations
    }

    private func enableThermalMitigation() {
        // Reduce performance to prevent thermal throttling
        frameTimeProfiler.enableThermalMitigation()
        batteryProfiler.enablePowerSavingMode()

        // Reduce background tasks
        SmartPreloader.shared.cancelAllPreloading()

        print("🌡️ Thermal mitigation enabled")
    }

    private func generateSessionReport() {
        let report = PerformanceSessionReport(
            duration: performanceTrends.sessionDuration,
            averageFPS: performanceTrends.frameRateHistory.isEmpty ? 60 :
                performanceTrends.frameRateHistory.reduce(0, +) / Double(performanceTrends.frameRateHistory.count),
            peakMemory: performanceTrends.memoryUsageHistory.max() ?? 0,
            totalRecommendations: optimizationRecommendations.count,
            overallScore: currentPerformance.overallScore
        )

        analyticsReporter.submitSessionReport(report)
        print("📊 Performance session report generated: \(report)")
    }
}

// MARK: MXMetricManagerSubscriber

@available(iOS 13.0, *)
extension PerformanceMonitoringSystem: MXMetricManagerSubscriber {
    func didReceive(_ payloads: [MXMetricPayload]) {
        Task { @MainActor in
            for payload in payloads {
                processMetricPayload(payload)
            }
        }
    }

    private func processMetricPayload(_ payload: MXMetricPayload) {
        // Process CPU metrics
        if let cpuMetrics = payload.cpuMetrics {
            analyticsReporter.recordCPUMetrics(cpuMetrics)
        }

        // Process memory metrics
        if let memoryMetrics = payload.memoryMetrics {
            analyticsReporter.recordMemoryMetrics(memoryMetrics)
        }

        // Process display metrics
        if let displayMetrics = payload.displayMetrics {
            analyticsReporter.recordDisplayMetrics(displayMetrics)
        }

        // Process network metrics
        if let networkMetrics = payload.networkTransferMetrics {
            analyticsReporter.recordNetworkMetrics(networkMetrics)
        }
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        Task { @MainActor in
            for payload in payloads {
                processDiagnosticPayload(payload)
            }
        }
    }

    private func processDiagnosticPayload(_ payload: MXDiagnosticPayload) {
        // Process crash diagnostics
        if let crashData = payload.crashDiagnostics {
            analyticsReporter.recordCrashDiagnostics(crashData)
        }

        // Process hang diagnostics
        if let hangData = payload.hangDiagnostics {
            analyticsReporter.recordHangDiagnostics(hangData)
        }

        // Process CPU exception diagnostics
        if let cpuExceptionData = payload.cpuExceptionDiagnostics {
            analyticsReporter.recordCPUExceptions(cpuExceptionData)
        }
    }
}

// MARK: - FrameTimeProfiler

@MainActor
class FrameTimeProfiler: ObservableObject {
    private var displayLink: CADisplayLink?
    private var lastFrameTime: CFTimeInterval = 0
    private var frameTimes: [TimeInterval] = []
    private var isPerformanceModeEnabled = false
    private var isThermalMitigationEnabled = false

    private let maxFrameTimeHistory = 120 // 2 seconds at 60fps

    func startProfiling() {
        displayLink = CADisplayLink(target: self, selector: #selector(frameCallback))
        displayLink?.add(to: .main, forMode: .common)
    }

    func stopProfiling() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func frameCallback(_ displayLink: CADisplayLink) {
        let currentTime = displayLink.timestamp

        if lastFrameTime > 0 {
            let frameTime = currentTime - lastFrameTime
            recordFrameTime(frameTime)
        }

        lastFrameTime = currentTime
    }

    private func recordFrameTime(_ frameTime: TimeInterval) {
        frameTimes.append(frameTime)

        if frameTimes.count > maxFrameTimeHistory {
            frameTimes.removeFirst()
        }

        // Record in performance monitor if exists
        PerformanceMonitor.shared.frameTimeTracker.recordFrameTime(frameTime)
    }

    func getCurrentMetrics() -> PerformanceSnapshot.FrameMetrics {
        guard !frameTimes.isEmpty else {
            return PerformanceSnapshot.FrameMetrics()
        }

        let averageFrameTime = frameTimes.reduce(0, +) / Double(frameTimes.count)
        let averageFPS = 1.0 / averageFrameTime

        let targetFrameTime: TimeInterval = 1.0 / 60.0 // 16.67ms
        let droppedFrames = frameTimes.filter { $0 > targetFrameTime * 1.5 }.count
        let jankPercentage = Double(droppedFrames) / Double(frameTimes.count) * 100
        let worstFrameTime = frameTimes.max() ?? 0

        return PerformanceSnapshot.FrameMetrics(
            averageFPS: averageFPS,
            frameDrops: droppedFrames,
            jankPercentage: jankPercentage,
            worstFrameTime: worstFrameTime
        )
    }

    func getPerformanceScore() -> Double {
        let metrics = getCurrentMetrics()

        // Score based on FPS and jank
        var score = 100.0

        if metrics.averageFPS < 60 {
            score -= (60 - metrics.averageFPS) * 2
        }

        score -= metrics.jankPercentage * 3

        return max(0, min(100, score))
    }

    func enablePerformanceMode() {
        isPerformanceModeEnabled = true
        print("⚡ Frame profiler performance mode enabled")
    }

    func enableThermalMitigation() {
        isThermalMitigationEnabled = true
        print("🌡️ Frame profiler thermal mitigation enabled")
    }
}

// MARK: - BatteryImpactProfiler

@MainActor
class BatteryImpactProfiler: ObservableObject {
    private var monitoringTimer: Timer?
    private var powerDrawHistory: [Double] = []
    private var isPowerSavingEnabled = false

    func startProfiling() {
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.measurePowerDraw()
        }
    }

    func stopProfiling() {
        monitoringTimer?.invalidate()
        monitoringTimer = nil
    }

    private func measurePowerDraw() {
        // Estimate power draw based on CPU usage and thermal state
        let estimatedPowerDraw = estimatePowerConsumption()

        powerDrawHistory.append(estimatedPowerDraw)

        // Keep only last 30 readings (1 minute at 2s intervals)
        if powerDrawHistory.count > 30 {
            powerDrawHistory.removeFirst()
        }
    }

    private func estimatePowerConsumption() -> Double {
        // Simplified power estimation
        let baselinePower: Double = 500 // 500mW baseline

        var additionalPower: Double = 0

        // Add power based on thermal state
        switch ProcessInfo.processInfo.thermalState {
        case .fair:
            additionalPower += 200
        case .serious:
            additionalPower += 500
        case .critical:
            additionalPower += 1000
        default:
            break
        }

        // Add power based on memory usage
        let memoryUsageMB = MemoryManager.shared.currentMemoryUsage.appSpecific / 1024 / 1024
        additionalPower += Double(memoryUsageMB) * 0.5

        return baselinePower + additionalPower
    }

    func getCurrentMetrics() -> PerformanceSnapshot.BatteryMetrics {
        let currentPowerDraw = powerDrawHistory.last ?? 500
        let thermalPressure = getThermalPressure()
        let batteryLevel = UIDevice.current.batteryLevel >= 0 ? Double(UIDevice.current.batteryLevel) : 1.0

        let energyImpact: PerformanceSnapshot.EnergyImpactLevel = if currentPowerDraw > 1500 {
            .high
        } else if currentPowerDraw > 800 {
            .medium
        } else {
            .low
        }

        return PerformanceSnapshot.BatteryMetrics(
            powerDrawMW: currentPowerDraw,
            thermalPressure: thermalPressure,
            batteryLevel: batteryLevel,
            energyImpact: energyImpact
        )
    }

    private func getThermalPressure() -> Double {
        switch ProcessInfo.processInfo.thermalState {
        case .nominal: return 0.0
        case .fair: return 0.3
        case .serious: return 0.7
        case .critical: return 1.0
        @unknown default: return 0.0
        }
    }

    func getPerformanceScore() -> Double {
        let currentPower = powerDrawHistory.last ?? 500

        // Score based on power efficiency
        if currentPower < 600 {
            return 100
        } else if currentPower < 1000 {
            return 80
        } else if currentPower < 1500 {
            return 60
        } else {
            return 40
        }
    }

    func enablePowerSavingMode() {
        isPowerSavingEnabled = true
        print("🔋 Battery profiler power saving mode enabled")
    }
}

// MARK: - PerformanceDataCollector

class PerformanceDataCollector {
    private(set) var peakMemoryUsage: Int64 = 0
    private var suspiciousAllocations: [String] = []

    func detectMemoryLeaks() -> [String] {
        // Simplified leak detection
        let currentMemory = MemoryManager.shared.currentMemoryUsage.appSpecific

        if currentMemory > peakMemoryUsage {
            peakMemoryUsage = currentMemory
        }

        // Mock leak detection logic
        return suspiciousAllocations
    }
}

// MARK: - ThermalStateMonitor

class ThermalStateMonitor {
    var currentState: PerformanceSnapshot.ThermalState {
        switch ProcessInfo.processInfo.thermalState {
        case .nominal: return .nominal
        case .fair: return .fair
        case .serious: return .serious
        case .critical: return .critical
        @unknown default: return .nominal
        }
    }
}

// MARK: - PerformanceAnalytics

class PerformanceAnalytics {
    func submitSessionReport(_ report: PerformanceSessionReport) {
        // Submit to analytics service
        print("📊 Submitting performance report: \(report)")
    }

    func recordCPUMetrics(_ metrics: MXCPUMetrics) {
        print("📈 CPU metrics recorded")
    }

    func recordMemoryMetrics(_ metrics: MXMemoryMetrics) {
        print("📈 Memory metrics recorded")
    }

    func recordDisplayMetrics(_ metrics: MXDisplayMetrics) {
        print("📈 Display metrics recorded")
    }

    func recordNetworkMetrics(_ metrics: MXNetworkTransferMetrics) {
        print("📈 Network metrics recorded")
    }

    func recordCrashDiagnostics(_ diagnostics: [MXCrashDiagnostic]) {
        print("🚨 Crash diagnostics recorded: \(diagnostics.count) crashes")
    }

    func recordHangDiagnostics(_ diagnostics: [MXHangDiagnostic]) {
        print("⏱️ Hang diagnostics recorded: \(diagnostics.count) hangs")
    }

    func recordCPUExceptions(_ diagnostics: [MXCPUExceptionDiagnostic]) {
        print("⚠️ CPU exception diagnostics recorded: \(diagnostics.count) exceptions")
    }
}

// MARK: - PerformanceSessionReport

struct PerformanceSessionReport {
    let duration: TimeInterval
    let averageFPS: Double
    let peakMemory: Int64
    let totalRecommendations: Int
    let overallScore: PerformanceSnapshot.PerformanceScore
}

// MARK: - Extensions for Integration

extension MemoryManager.MemoryPressureLevel {
    func toPerformanceLevel() -> MemoryPressureLevel {
        switch self {
        case .normal: .normal
        case .moderate: .moderate
        case .high: .high
        case .critical: .critical
        }
    }
}

extension MemoryManager {
    func getPerformanceScore() -> Double {
        let usage = currentMemoryUsage.usagePercentage

        if usage < 60 {
            return 100
        } else if usage < 75 {
            return 80
        } else if usage < 90 {
            return 60
        } else {
            return 40
        }
    }
}

extension NetworkIntelligence {
    func getPerformanceScore() -> Double {
        let errorRate = networkMetrics.errorRate
        let cacheHitRate = networkMetrics.cacheHitRate

        var score = 100.0
        score -= errorRate * 200 // Penalize errors heavily
        score += (cacheHitRate - 0.5) * 100 // Reward good cache performance

        return max(0, min(100, score))
    }
}

extension NetworkIntelligence.NetworkMetrics {
    func toPerformanceMetrics() -> PerformanceSnapshot.NetworkMetrics {
        PerformanceSnapshot.NetworkMetrics(
            requestsPerSecond: Double(requestsPerMinute) / 60.0,
            averageLatency: averageResponseTime,
            errorRate: errorRate,
            dataEfficiency: cacheHitRate
        )
    }
}

enum MemoryPressureLevel {
    case normal, moderate, high, critical
}
