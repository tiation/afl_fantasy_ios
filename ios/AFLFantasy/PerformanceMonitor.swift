// PerformanceMonitor.swift
// AFL Fantasy Intelligence Platform
// Minimal performance monitoring singleton to resolve missing symbol in AFLFantasyApp

import Foundation

final class PerformanceMonitor {
    static let shared = PerformanceMonitor()

    private var coldStartStartTime: Date?
    private var coldStartEndTime: Date?

    private init() {}

    func startColdStartTimer() {
        coldStartStartTime = Date()
#if DEBUG
        print("[PerformanceMonitor] Cold start timer started at \(coldStartStartTime!)")
#endif
    }

    func endColdStartTimer() {
        coldStartEndTime = Date()
        if let start = coldStartStartTime, let end = coldStartEndTime {
            let elapsed = end.timeIntervalSince(start)
#if DEBUG
            print("[PerformanceMonitor] Cold start completed in \(String(format: "%.2f", elapsed)) seconds")
#endif
        }
    }
}
